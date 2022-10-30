#!/bin/bash

set -eu
set -o pipefail
shopt -s inherit_errexit

exec 0</dev/null

source "$ACCIDENT_STIG_IMPL_BASH_LIB_DIR/accident-stig-library.bash"


#
# Group ID (Vulid):       V-230546
#
# Group Title:            SRG-OS-000480-GPOS-00227
#
# Rule ID:                SV-230546r833361_rule
#
# Severity:               CAT II
#
# Rule Version (STIG-ID): RHEL-08-040282
#
# Rule Title:             RHEL 8 must restrict usage of ptrace to
#                         descendant  processes.
#


rule_template_sysctl_file \
	--rule-id "SV-230546r833361_rule" \
	--reboot-file "$ACCIDENT_STIG_IMPL_RUN_DIR/needs_reboot" \
	--sysctl-key "kernel.yama.ptrace_scope" \
	--sysctl-target-value "1" \
	--config-source-file "$ACCIDENT_STIG_IMPL_RULE_DIR_RES/90-accident-stig-restrict-ptrace.conf" \
	--config-destination-file "/etc/sysctl.d/90-accident-stig-restrict-ptrace.conf" \
	;


exit 0
