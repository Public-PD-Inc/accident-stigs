#!/bin/bash

set -eu
set -o pipefail
shopt -s inherit_errexit

exec 0</dev/null

source "$ACCIDENT_STIG_IMPL_BASH_LIB_DIR/accident-stig-library.bash"


#
# Group ID (Vulid):       V-230296
#
# Group Title:            SRG-OS-000109-GPOS-00056
#
# Rule ID:                SV-230296r627750_rule
#
# Severity:               CAT II
#
# Rule Version (STIG-ID): RHEL-08-010550
#
# Rule Title:             RHEL 8 must not permit direct logons to the
#                         root account using remote access via SSH.
#



rule_id="SV-230296r627750_rule"

reboot_file="$ACCIDENT_STIG_IMPL_RUN_DIR/needs_reboot"
config_file="50-accident-stig-disable-root-login.conf"

config_source_file="$ACCIDENT_STIG_IMPL_RULE_DIR_RES/$config_file"
config_destination_file="/etc/ssh/sshd_config.d/$config_file"



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

	# read current kernel cmdline arguments into array
	read _ PermitRootLogin < <(sshd -T | grep -i '^PermitRootLogin ')


	if [ "$PermitRootLogin" = "no" ]; then
		compliance="$ACCIDENT_CONST_COMPLIANT"
	else
		compliance="$ACCIDENT_CONST_NONCOMPLIANT"

		# if allowed, make compliant

		if [ "$compliance" = "$ACCIDENT_CONST_NONCOMPLIANT" -a "$ACCIDENT_STIG_IMPL_ALLOW_IMPLEMENT" -ne 0 ]; then

			if [ ! -e "/etc/ssh/sshd_config.d/$config_file" ]; then

				# check for remote root logins
				root_has_logged_in=0
				while read -r user console remote times; do
					if [ "$remote" = '0.0.0.0' ]; then
						continue;
					fi;
					#printf '%s\t%s\t%s\t%s\n' "$user" "$console" "$remote" "$times";
				root_has_logged_in=1
				done < <(last -i root | { grep . || true; } | { grep -v '^\S\+ begins ' || true; })

				should_implement=1

				if [ "$root_has_logged_in" -ne 0 ]; then
					warning 'There is a history of remote logins for root.'
					should_implement=0
				fi

				if [ "$should_implement" -eq 0 ]; then
					if [ "$ACCIDENT_STIG_SETTING_SSHD_ROOT_LOGON_RULE_BYPASS_WARNING" -ne 0 ]; then
						should_implement=1
					else
						warning 'Not disabling root login without ACCIDENT_STIG_SETTING_SSHD_ROOT_LOGON_RULE_BYPASS_WARNING=1'
					fi
				fi

				if [ "$should_implement" -ne 0 ]; then
					# make compliant
					setup_sshd_dropin_skeleton
					trace cp -nv "$config_source_file" -T "$config_destination_file"

					# assume compliant until next reboot
					compliance="$ACCIDENT_CONST_COMPLIANT"
					touch "$reboot_file"
					need_reboot=1
				fi

			else
				warning "Target config file already exists. Did someone override the setting?"
			fi

		fi

	fi

fi

if [ "$need_reboot" -ne 0 ]; then
	warning "A reboot is required to verify the effective value of PermitRootLogin"
fi

compliance --rule-id "$rule_id" --status "$compliance"



exit 0
