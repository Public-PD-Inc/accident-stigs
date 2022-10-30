#!/bin/bash

set -eu
set -o pipefail
shopt -s inherit_errexit

exec 0</dev/null

source "$ACCIDENT_STIG_IMPL_BASH_LIB_DIR/accident-stig-library.bash"


#
# Group ID (Vulid):       V-230311
#
# Group Title:            SRG-OS-000480-GPOS-00227
#
# Rule ID:                SV-230311r833305_rule
#
# Severity:               CAT II
#
# Rule Version (STIG-ID): RHEL-08-010671
#
# Rule Title:             RHEL 8 must disable the kernel.core_pattern.
#


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

	value="$(cat /proc/sys/kernel/core_pattern)"

	if [ "$value" = "|/bin/false" ]; then
		compliance="$ACCIDENT_CONST_COMPLIANT"
	else
		compliance="$ACCIDENT_CONST_NONCOMPLIANT"
	fi

	# if allowed, make compliant

	if [ "$compliance" = "$ACCIDENT_CONST_NONCOMPLIANT" -a "$ACCIDENT_STIG_IMPL_ALLOW_IMPLEMENT" -ne 0 ]; then

		if [ ! -e /etc/sysctl.d/90-accident-stig-disable-core-dumps.conf ]; then

			# make compliant
			trace cp -nv "$ACCIDENT_STIG_IMPL_RULE_DIR_RES/90-accident-stig-disable-core-dumps.conf" -T /etc/sysctl.d/90-accident-stig-disable-core-dumps.conf

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
	warning "A reboot is required to verify the value of kernel.core_pattern."
fi

compliance --rule-id "SV-230311r833305_rule" --status "$compliance"


exit 0
