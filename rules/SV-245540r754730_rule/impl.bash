#!/bin/bash

set -eu
set -o pipefail
shopt -s inherit_errexit

exec 0</dev/null

source "$ACCIDENT_STIG_IMPL_BASH_LIB_DIR/accident-stig-library.bash"


#
# Group ID (Vulid):       V-245540
#
# Group Title:            SRG-OS-000191-GPOS-00080
#
# Rule ID:                SV-245540r754730_rule
#
# Severity:               CAT II
#
# Rule Version (STIG-ID): RHEL-08-010001
#
# Rule Title:             The RHEL 8 operating system must implement the
#                         Endpoint Security for Linux Threat Prevention
#                         tool.
#


compliance="compliant"

if ! rpm -q McAfeeTP >/dev/null; then
	compliance="noncompliant"
fi

# TODO: test on a real system
# TODO: maybe check systemd unit status, instead
if ! pgrep -i '^mfetpd$'; then
	compliance="noncompliant"
fi

compliance --rule-id "SV-245540r754730_rule" --status "$compliance"


exit 0
