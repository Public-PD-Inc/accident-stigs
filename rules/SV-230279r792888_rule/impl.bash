#!/bin/bash

set -eu
set -o pipefail
shopt -s inherit_errexit

exec 0</dev/null

source "$ACCIDENT_STIG_IMPL_BASH_LIB_DIR/accident-stig-library.bash"


#
# Group ID (Vulid):       V-230279
#
# Group Title:            SRG-OS-000134-GPOS-00068
#
# Rule ID:                SV-230279r792888_rule
#
# Severity:               CAT II
#
# Rule Version (STIG-ID): RHEL-08-010423
#
# Rule Title:             RHEL 8 must clear SLUB/SLAB objects to prevent
#                         use-after-free attacks.
#


config_file="50-accident-stig-enable-slub-poison.sh"

# TODO: accept other forms of the slub_debug command-line argument(s)
rule_template_grub_cmdline_file \
	--rule-id "SV-230279r792888_rule" \
	--reboot-file "$ACCIDENT_STIG_IMPL_RUN_DIR/needs_reboot" \
	--cmdline-argument-pattern "^slub_debug=" \
	--cmdline-required-argument "slub_debug=P" \
	--config-source-file "$ACCIDENT_STIG_IMPL_RULE_DIR_RES/$config_file" \
	--config-destination-file "/etc/default/grub.accident-stig.d/$config_file" \
	;


exit 0
