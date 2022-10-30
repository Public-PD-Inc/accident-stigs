#!/bin/bash

set -eu
set -o pipefail
shopt -s inherit_errexit
shopt -s nullglob

exec 0</dev/null

bindir="${BASH_SOURCE[0]%/*}"
bindir="${bindir:-/}"
test -n "${bindir%%/*}" && bindir="$PWD/$bindir"

libdir="$bindir/../lib"
rulesdir="$bindir/../rules"

source "$libdir/accident-stig-library.bash"


#
# process command-line arguments
#

debug=0

while [ "$#" -gt 0 ]; do
	case "$1" in
		--mode)
			shift 1
			mode="$1"
			shift 1
			;;
		--rules)
			shift 1
			rule_dir_names="$1"
			shift 1
			;;
		--debug)
			shift 1
			debug=1
			;;
		*)
			echo "$0: unknown option: $1" >&2
			exit 1
			;;
	esac
done


#
# validate/handle command-line arguments
#

if [ ! -v mode ]; then
	error 'missing --mode'
fi

if [ -z "$mode" ]; then
	error 'empty $mode'
fi

if [ "$debug" -ne 0 ]; then
	export ACCIDENT_STIG_IMPL_SHOW_DEBUG=1
else
	export ACCIDENT_STIG_IMPL_SHOW_DEBUG=0
fi

case "$mode" in
	"check-only")
		export ACCIDENT_STIG_IMPL_ALLOW_IMPLEMENT=0
		;;
	"implement")
		export ACCIDENT_STIG_IMPL_ALLOW_IMPLEMENT=1
		;;
	*)
		error "unknown value for --mode: $mode"
		;;
esac

# convert comma-separated rule_dir_names to array
if [ -v rule_dir_names ] && [ -n "$rule_dir_names" ]; then
	IFS=',' read -a rule_dir_names <<< "$rule_dir_names"
fi


#
# main logic
#

export ACCIDENT_STIG_IMPL_BASH_LIB_DIR="$libdir"
export ACCIDENT_STIG_IMPL_BASH_ETC_DIR="$bindir/../etc"

source "$ACCIDENT_STIG_IMPL_BASH_LIB_DIR/accident-stig-default-settings.bash"

if [ -e "$ACCIDENT_STIG_IMPL_BASH_ETC_DIR/accident-stig-settings.bash" ]; then
source "$ACCIDENT_STIG_IMPL_BASH_ETC_DIR/accident-stig-settings.bash"
fi

# create stig-impl status directory
runfs="$(awk '($2=="/run"){print $3}' /proc/mounts)"
if [ "$runfs" != "tmpfs" ]; then
	error "why is /run not mounted as a tmpfs?"
fi
run_dir="/run/accident-stig-impl"
if ! [ -d "$run_dir" ]; then
	mkdir "$run_dir"
fi

# create array rule_dir_list
if [ ! -v rule_dir_names ]; then
	# use all rules
	rule_dir_list=("$rulesdir"/SV-*_rule "$rulesdir"/group-*)
else
	# only use rules specified in rule_dir_names
	rule_dir_list=()
	for rule_dir_name in "${rule_dir_names[@]}"; do
		rule_dir_list+="$rulesdir/$rule_dir_name"
	done
fi

# iterate over each rule directory
for dir in "${rule_dir_list[@]}"; do

	test -d "$dir" || continue

	# execute first implementation executable
	for exe_name in impl impl.bash; do

		exe="$dir/$exe_name"

		# TODO: how to not hard code this file descriptor?
		export ACCIDENT_STIG_IMPL_COMPLIANCE_REPORTING_FD=60
		if [ -x "$exe" ]; then

			# found implementor executable

			# prepare environment

			rule_id="${dir##*/}"

			export ACCIDENT_STIG_IMPL_RUN_DIR="$run_dir/$rule_id"
			if ! [ -d "$ACCIDENT_STIG_IMPL_RUN_DIR" ]; then
				mkdir "$ACCIDENT_STIG_IMPL_RUN_DIR"
			fi

			export ACCIDENT_STIG_IMPL_RULE_DIR_BIN="$dir"
			export ACCIDENT_STIG_IMPL_RULE_DIR_RES="$dir"

			if ! "$exe" 60>&1 1>&2; then
				error "$exe exited with status $?"
			fi

			# stop the search for more executables
			break
		fi

	done

done

# done
exit 0
