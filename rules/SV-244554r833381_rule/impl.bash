#!/bin/bash

set -eu
set -o pipefail
shopt -s inherit_errexit

exec 0</dev/null

source "$ACCIDENT_STIG_IMPL_BASH_LIB_DIR/accident-stig-library.bash"


#
# Group ID (Vulid):       V-244554
#
# Group Title:            SRG-OS-000480-GPOS-00227
#
# Rule ID:                SV-244554r833381_rule
#
# Severity:               CAT II
#
# Rule Version (STIG-ID): RHEL-08-040286
#
# Rule Title:             RHEL 8 must enable hardening for the Berkeley
#                         Packet Filter Just-in-time compiler.
#


config_file="90-accident-stig-harden-bpf.conf"

rule_template_sysctl_file \
	--rule-id "SV-244554r833381_rule" \
	--reboot-file "$ACCIDENT_STIG_IMPL_RUN_DIR/needs_reboot" \
	--sysctl-key "net.core.bpf_jit_harden" \
	--sysctl-target-value "2" \
	--config-source-file "$ACCIDENT_STIG_IMPL_RULE_DIR_RES/$config_file" \
	--config-destination-file "/etc/sysctl.d/$config_file" \
	;


exit 0
