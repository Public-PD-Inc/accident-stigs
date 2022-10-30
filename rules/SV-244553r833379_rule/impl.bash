#!/bin/bash

set -eu
set -o pipefail
shopt -s inherit_errexit

exec 0</dev/null

source "$ACCIDENT_STIG_IMPL_BASH_LIB_DIR/accident-stig-library.bash"


#
# Group ID (Vulid):       V-244553
#
# Group Title:            SRG-OS-000480-GPOS-00227
#
# Rule ID:                SV-244553r833379_rule
#
# Severity:               CAT II
#
# Rule Version (STIG-ID): RHEL-08-040279
#
# Rule Title:             RHEL 8 must ignore IPv4 Internet Control
#                         Message Protocol (ICMP) redirect messages.
#


config_file="90-accident-stig-disable-all-inbound-icmpv4-redirects.conf"

rule_template_sysctl_file \
	--rule-id "SV-244553r833379_rule" \
	--reboot-file "$ACCIDENT_STIG_IMPL_RUN_DIR/needs_reboot" \
	--sysctl-key "net.ipv4.conf.all.accept_redirects" \
	--sysctl-target-value "0" \
	--config-source-file "$ACCIDENT_STIG_IMPL_RULE_DIR_RES/$config_file" \
	--config-destination-file "/etc/sysctl.d/$config_file" \
	;


exit 0
