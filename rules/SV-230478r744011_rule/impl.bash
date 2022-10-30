#!/bin/bash

set -eu
set -o pipefail
shopt -s inherit_errexit

exec 0</dev/null

source "$ACCIDENT_STIG_IMPL_BASH_LIB_DIR/accident-stig-library.bash"


#
# Group ID (Vulid):       V-230478
#
# Group Title:            SRG-OS-000480-GPOS-00227
#
# Rule ID:                SV-230478r744011_rule
#
# Severity:               CAT II
#
# Rule Version (STIG-ID): RHEL-08-030680
#
# Rule Title:             RHEL 8 must have the packages required for
#                         encrypting offloaded audit logs installed.
#


# check compliance based on if package is installed
# TODO: validate `rpm` output for non-zero return value
#
if ! rpm -q rsyslog-gnutls >/dev/null; then
	compliance="$ACCIDENT_CONST_NONCOMPLIANT"
else
	compliance="$ACCIDENT_CONST_COMPLIANT"
fi


# if allowed, make compliant

if [ "$compliance" = "$ACCIDENT_CONST_NONCOMPLIANT" -a "$ACCIDENT_STIG_IMPL_ALLOW_IMPLEMENT" -ne 0 ]; then

	# make compliant
	trace yum install -y rsyslog-gnutls
	compliance="$ACCIDENT_CONST_COMPLIANT"

fi

compliance --rule-id "SV-230478r744011_rule" --status "$compliance"


exit 0
