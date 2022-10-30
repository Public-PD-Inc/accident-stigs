#!/bin/bash

set -eu
set -o pipefail
shopt -s inherit_errexit

exec 0</dev/null

source "$ACCIDENT_STIG_IMPL_BASH_LIB_DIR/accident-stig-library.bash"


#
# Group ID (Vulid):       V-230312
#
# Group Title:            SRG-OS-000480-GPOS-00227
#
# Rule ID:                SV-230312r833308_rule
#
# Severity:               CAT II
#
# Rule Version (STIG-ID): RHEL-08-010672
#
# Rule Title:             RHEL 8 must disable acquiring, saving, and
#                         processing core dumps.
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

	# assume compliant until proven otherwise
	compliance="$ACCIDENT_CONST_COMPLIANT"

	# get unit status

	unit_file_state="$(systemctl show systemd-coredump.socket | sed -ne 's/^UnitFileState=\(.*\)$/\1/p')"
	active_state="$(systemctl show systemd-coredump.socket | sed -ne 's/^ActiveState=\(.*\)$/\1/p')"

	# check status validity

	case "$unit_file_state" in
		"enabled")
			;;
		"disabled")
			;;
		"masked")
			;;
		"static")
			;;
		*)
			error "unknown value: $unit_file_state"
			;;
	esac

	case "$active_state" in
		"active")
			;;
		"inactive")
			;;
		*)
			error "unknown value: $active_state"
			;;
	esac

	# check for non-compliance

	if [ "$unit_file_state" != "masked" ]; then
		compliance="$ACCIDENT_CONST_NONCOMPLIANT"
	fi

	if [ "$active_state" != "inactive" ]; then
		compliance="$ACCIDENT_CONST_NONCOMPLIANT"
	fi

	# if allowed, make compliant

	if [ "$compliance" = "$ACCIDENT_CONST_NONCOMPLIANT" -a "$ACCIDENT_STIG_IMPL_ALLOW_IMPLEMENT" -ne 0 ]; then
		if [ "$unit_file_state" != "masked" ]; then

			# make compliant
			trace systemctl mask systemd-coredump.socket

			# assume compliant until next reboot
			compliance="$ACCIDENT_CONST_COMPLIANT"
			touch "$reboot_file"
			need_reboot=1

		else
			warning "Unit already masked?"
		fi
	fi
fi

if [ "$need_reboot" -ne 0 ]; then
	warning "A reboot is required to verify that systemd-coredump.socket won't start."
fi

compliance --rule-id "SV-230312r833308_rule" --status "$compliance"


exit 0
