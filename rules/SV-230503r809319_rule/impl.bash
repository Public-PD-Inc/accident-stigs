#!/bin/bash

set -eu
set -o pipefail
shopt -s inherit_errexit

exec 0</dev/null

source "$ACCIDENT_STIG_IMPL_BASH_LIB_DIR/accident-stig-library.bash"


#
# Group ID (Vulid):       V-230503
#
# Group Title:            SRG-OS-000114-GPOS-00059
#
# Rule ID:                SV-230503r809319_rule
#
# Severity:               CAT II
#
# Rule Version (STIG-ID): RHEL-08-040080
#
# Rule Title:             RHEL 8 must be configured to disable USB mass
#                         storage.
#


config_file="50-accident-stig-blacklist-usb-storage.conf"

reboot_file="$ACCIDENT_STIG_IMPL_RUN_DIR/needs_reboot"

# check for pending reboot from previous run
need_reboot=0
if [ -e "$reboot_file" ]; then
	need_reboot=1
fi

# if pending reboot, assume compliant
if [ "$need_reboot" -ne 0 ]; then
	compliance="$ACCIDENT_CONST_COMPLIANT"

# if no pending reboot, check compliance now
else

	if [ -e "/etc/modprobe.d/$config_file" ]; then
		compliance="$ACCIDENT_CONST_COMPLIANT"
	else
		compliance="$ACCIDENT_CONST_NONCOMPLIANT"
	fi

	# if allowed, make compliant

	if [ "$compliance" = "$ACCIDENT_CONST_NONCOMPLIANT" -a "$ACCIDENT_STIG_IMPL_ALLOW_IMPLEMENT" -ne 0 ]; then

		if [ ! -e "/etc/modprobe.d/$config_file" ]; then

			# make compliant
			trace cp -nv "$ACCIDENT_STIG_IMPL_RULE_DIR_RES/$config_file" -T "/etc/modprobe.d/$config_file"

			# assume compliant until next reboot
			compliance="$ACCIDENT_CONST_COMPLIANT"
			touch "$reboot_file"
			need_reboot=1

		else
			warning "Target config file already exists. Did someone override the setting?"
		fi
	fi
fi

if [ "$need_reboot" -ne 0 ]; then
	warning "A reboot is required to apply new config files."
fi

compliance --rule-id "SV-230503r809319_rule" --status "$compliance"


exit 0
