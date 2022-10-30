#!/bin/bash

set -eu
set -o pipefail
shopt -s inherit_errexit

exec 0</dev/null

source "$ACCIDENT_STIG_IMPL_BASH_LIB_DIR/accident-stig-library.bash"


#
# Group ID (Vulid):       V-244537
#
# Group Title:            SRG-OS-000028-GPOS-00009
#
# Rule ID:                SV-244537r743860_rule
#
# Severity:               CAT II
#
# Rule Version (STIG-ID): RHEL-08-020039
#
# Rule Title:             RHEL 8 must have the tmux package installed.
#


# check compliance based on if package is installed
# TODO: validate `rpm` output for non-zero return value
#
if ! rpm -q tmux >/dev/null; then
	compliance="$ACCIDENT_CONST_NONCOMPLIANT"
else
	compliance="$ACCIDENT_CONST_COMPLIANT"
fi


# if allowed, make compliant

if [ "$compliance" = "$ACCIDENT_CONST_NONCOMPLIANT" -a "$ACCIDENT_STIG_IMPL_ALLOW_IMPLEMENT" -ne 0 ]; then

	# make compliant
	trace yum install -y tmux
	compliance="$ACCIDENT_CONST_COMPLIANT"

fi

compliance --rule-id "SV-244537r743860_rule" --status "$compliance"


exit 0
