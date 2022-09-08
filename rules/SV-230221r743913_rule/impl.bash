#!/bin/bash

set -eu
set -o pipefail
shopt -s inherit_errexit

exec 0</dev/null

source "$ACCIDENT_STIG_IMPL_BASH_LIB_DIR/accident-stig-library.bash"


#
# Group ID (Vulid):       V-230221
#
# Group Title:            SRG-OS-000480-GPOS-00227
#
# Rule ID:                SV-230221r743913_rule
#
# Severity:               CAT I
#
# Rule Version (STIG-ID): RHEL-08-010000
#
# Rule Title:             RHEL 8 must be a vendor-supported release.
#


# read /etc/redhat-release into variable
readarray -t lines < /etc/redhat-release


# validate assumptions about file content

if [ "${#lines[@]}" -lt 1 ]; then
	error 'no lines in /etc/redhat-release'
fi

if [ "${#lines[@]}" -gt 1 ]; then
	# TODO: does /etc/redhat-release ever have more than one line?
	error 'too many lines in /etc/redhat-release'
fi

test "${#lines[@]}" -eq 1 || error 'assertion failed'


# read first line
line="${lines[0]}"


# determine version number by extraction pattern

version=""

if false; then true
elif [[ "$line" =~ ^Red\ Hat\ Enterprise\ Linux\ Server\ release\ (8\.[0-9]+)([[:space:]].*)?$ ]]; then version="${BASH_REMATCH[1]}"
elif [[ "$line" =~ ^Rocky\ Linux\ release\ (8\.[0-9]+)([[:space:]].*)?$ ]]; then version="${BASH_REMATCH[1]}"

# most general / least certain case
elif [[ "$line" =~ (^|[[:space:]])(8.[0-9]+)($|[[:space:]]) ]]; then
	version="${BASH_REMATCH[2]}"
	warning 'We did not match any specific vendor version pattern. Version number may be wrong.'

# no version number?
else
	error 'no version number (is this even a RHEL8-derived distribution?)'

fi

test -n "${version:-}" || error '$version was not set'


# determine EOL date for version

case "$version" in
	8.1)
		eol='2021-11-30'
		;;
	8.2)
		eol='2022-04-30'
		;;
	8.3)
		eol='2022-11-30' # TODO: fix
		;;
	8.4)
		eol='2023-11-30'
		;;
	8.5)
		eol='2022-04-30'
		;;
	8.6)
		eol='2024-04-30'
		;;
	8.7)
		eol='2023-04-30'
		;;
	8.8)
		eol='2025-04-30'
		;;
	8.9)
		eol='2024-04-30'
		;;
	8.10)
		eol='2029-05-31'
		;;
	*)
		error "Unknown version number: $version"
		;;
esac

test -n "${eol:-}" || error '$eol was not set'


# determine compliance by checking if we're before EOL date

if [ "$(date +%s)" -lt "$(date +%s -ud "$eol")" ]; then
	compliance="compliant"
else
	compliance="noncompliant"
fi

compliance --rule-id "SV-230221r743913_rule" --status "$compliance"


exit 0
