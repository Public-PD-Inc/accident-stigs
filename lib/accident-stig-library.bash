# stig-library.bash

# Do not directly execute this file; it is meant to be sourced.


# constants
declare -r ACCIDENT_CONST_COMPLIANT="compliant"
declare -r ACCIDENT_CONST_NONCOMPLIANT="noncompliant"


# stacktrace -- print bash call stack
#
# Usage: stacktrace
#
stacktrace()
{
	printf '\n'
	printf 'stacktrace:\n'
	local i
	for ((i = 1; i < "${#BASH_SOURCE[@]}" - 1; i++)); do
		caller "$i"
	done
	printf '\n'
}


# error -- print error message and terminate bash
#
# Usage: error "$message"
#
error()
{
	printf 'error: %s\n' "$*" >&2
	stacktrace >&2
	exit 1
}


# warning -- print warning message
#
# Usage: warning "$message"
#
warning()
{
	printf 'warning: %s\n' "$*" >&2
}


# debug -- print debug message (if enabled)
#
# Usage: debug "$message"
#
debug()
{
	if [ "$ACCIDENT_STIG_IMPL_SHOW_DEBUG" -ne 0 ]; then
		printf 'debug: %s\n' "$*" >&2
	fi
}


# trace -- run a command with xtrace enabled
#
# The rest of the arguments are executed as the command
#
trace()
{
	# hidden from xtrace
	{

		local rval=0
		local xtrace=0

		# save current xtrace value
		if [[ -o xtrace ]]; then
			xtrace=1
		fi

		# enable xtrace
		set -x

	} 2>/dev/null

	"$@" ||
	# hidden from xtrace
	{

		# record non-zero exit status
		rval="$?";

	} 2>/dev/null

	# hidden from xtrace
	{

		# restore xtrace
		if [ "$xtrace" -eq 0 ]; then
			set +x
		fi

		# replay program exit status
		return "$rval"

	} 2>/dev/null
}


# compliance -- output compliance status for a given STIG rule
#
# Usage: compliance --rule-id "$rule_id" --status "$compliance_status"
#
compliance()
{
	local rule_id
	local compliance_status

	while [ "$#" -gt 0 ]; do
		case "$1" in
			--rule-id)
				shift 1
				rule_id="$1"
				shift 1
				;;
			--status)
				shift 1
				compliance_status="$1"
				shift 1
				;;
			*)
				error "$0: unknown option: $1"
				;;
		esac
	done

	if [ ! -v rule_id ]; then
		error 'missing --rule-id'
	fi

	if [ -z "$rule_id" ]; then
		error 'empty $rule_id'
	fi

	if [ ! -v compliance_status ]; then
		error 'missing --status'
	fi

	if [ -z "$compliance_status" ]; then
		error 'empty $compliance_status'
	fi

	case "$compliance_status" in
		"compliant")
			;;
		"noncompliant")
			;;
		*)
			error "unknown value for --compliance: $compliance_status"
			;;
	esac

	printf '%s\t%s\n' "$compliance_status" "$rule_id" >&"$ACCIDENT_STIG_IMPL_COMPLIANCE_REPORTING_FD"
}


# compliant -- convenience function
#              (calls compliance --status "compliant")
#
compliant()
{
	compliance "$@" --status "compliant"
}


# noncompliant -- convenience function
#              (calls compliance --status "noncompliant")
#
noncompliant()
{
	compliance "$@" --status "noncompliant"
}
