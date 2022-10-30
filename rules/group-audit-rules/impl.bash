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


rules_file="70-accident-stig.rules"

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

	if [ -e "/etc/audit/rules.d/$rules_file" ]; then
		compliance="$ACCIDENT_CONST_COMPLIANT"
	else
		compliance="$ACCIDENT_CONST_NONCOMPLIANT"
	fi

	# if allowed, make compliant

	if [ "$compliance" = "$ACCIDENT_CONST_NONCOMPLIANT" -a "$ACCIDENT_STIG_IMPL_ALLOW_IMPLEMENT" -ne 0 ]; then

		if [ ! -e "/etc/audit/rules.d/$rules_file" ]; then

			# make compliant
			trace cp -nv "$ACCIDENT_STIG_IMPL_RULE_DIR_RES/$rules_file" -T "/etc/audit/rules.d/$rules_file"

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
	warning "A reboot is required to apply new audit rules."
fi

compliance --rule-id "SV-230386r627750_rule" --status "$compliance"
compliance --rule-id "SV-230402r627750_rule" --status "$compliance"
compliance --rule-id "SV-230403r627750_rule" --status "$compliance"
compliance --rule-id "SV-230404r627750_rule" --status "$compliance"
compliance --rule-id "SV-230405r627750_rule" --status "$compliance"
compliance --rule-id "SV-230406r627750_rule" --status "$compliance"
compliance --rule-id "SV-230407r627750_rule" --status "$compliance"
compliance --rule-id "SV-230408r627750_rule" --status "$compliance"
compliance --rule-id "SV-230409r627750_rule" --status "$compliance"
compliance --rule-id "SV-230410r627750_rule" --status "$compliance"
compliance --rule-id "SV-230412r627750_rule" --status "$compliance"
compliance --rule-id "SV-230413r810463_rule" --status "$compliance"
compliance --rule-id "SV-230418r627750_rule" --status "$compliance"
compliance --rule-id "SV-230419r627750_rule" --status "$compliance"
compliance --rule-id "SV-230421r627750_rule" --status "$compliance"
compliance --rule-id "SV-230422r627750_rule" --status "$compliance"
compliance --rule-id "SV-230423r627750_rule" --status "$compliance"
compliance --rule-id "SV-230424r627750_rule" --status "$compliance"
compliance --rule-id "SV-230425r627750_rule" --status "$compliance"
compliance --rule-id "SV-230426r627750_rule" --status "$compliance"
compliance --rule-id "SV-230427r627750_rule" --status "$compliance"
compliance --rule-id "SV-230428r627750_rule" --status "$compliance"
compliance --rule-id "SV-230429r627750_rule" --status "$compliance"
compliance --rule-id "SV-230430r627750_rule" --status "$compliance"
compliance --rule-id "SV-230431r627750_rule" --status "$compliance"
compliance --rule-id "SV-230432r627750_rule" --status "$compliance"
compliance --rule-id "SV-230433r627750_rule" --status "$compliance"
compliance --rule-id "SV-230434r744002_rule" --status "$compliance"
compliance --rule-id "SV-230435r627750_rule" --status "$compliance"
compliance --rule-id "SV-230436r627750_rule" --status "$compliance"
compliance --rule-id "SV-230437r627750_rule" --status "$compliance"
compliance --rule-id "SV-230438r810464_rule" --status "$compliance"
compliance --rule-id "SV-230439r810465_rule" --status "$compliance"
compliance --rule-id "SV-230444r627750_rule" --status "$compliance"
compliance --rule-id "SV-230446r627750_rule" --status "$compliance"
compliance --rule-id "SV-230447r627750_rule" --status "$compliance"
compliance --rule-id "SV-230448r627750_rule" --status "$compliance"
compliance --rule-id "SV-230449r810455_rule" --status "$compliance"
compliance --rule-id "SV-230455r810459_rule" --status "$compliance"
compliance --rule-id "SV-230456r810462_rule" --status "$compliance"
compliance --rule-id "SV-230462r627750_rule" --status "$compliance"
compliance --rule-id "SV-230463r627750_rule" --status "$compliance"
compliance --rule-id "SV-230464r627750_rule" --status "$compliance"
compliance --rule-id "SV-230465r627750_rule" --status "$compliance"
compliance --rule-id "SV-230466r627750_rule" --status "$compliance"
compliance --rule-id "SV-230467r627750_rule" --status "$compliance"


exit 0
