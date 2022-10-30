#!/bin/bash

set -eu
set -o pipefail
shopt -s inherit_errexit

exec 0</dev/null

source "$ACCIDENT_STIG_IMPL_BASH_LIB_DIR/accident-stig-library.bash"


#
# Group ID (Vulid):       V-230278
#
# Group Title:            SRG-OS-000134-GPOS-00068
#
# Rule ID:                SV-230278r792886_rule
#
# Severity:               CAT II
#
# Rule Version (STIG-ID): RHEL-08-010422
#
# Rule Title:             RHEL 8 must disable virtual syscalls.
#


config_file="50-accident-stig-disable-vsyscall.sh"

rule_template_grub_cmdline_file \
	--rule-id "SV-230278r792886_rule" \
	--reboot-file "$ACCIDENT_STIG_IMPL_RUN_DIR/needs_reboot" \
	--cmdline-argument-pattern "^vsyscall=" \
	--cmdline-required-argument "vsyscall=none" \
	--config-source-file "$ACCIDENT_STIG_IMPL_RULE_DIR_RES/$config_file" \
	--config-destination-file "/etc/default/grub.accident-stig.d/$config_file" \
	;


exit 0
