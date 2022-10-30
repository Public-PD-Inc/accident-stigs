# stig-library.bash

# Do not directly execute this file; it is meant to be sourced.


# constants
declare -r ACCIDENT_CONST_COMPLIANT="compliant"
declare -r ACCIDENT_CONST_NONCOMPLIANT="noncompliant"


# stacktrace -- print bash call stack
#
# Usage: stacktrace
#
stacktrace()
{
	printf '\n'
	printf 'stacktrace:\n'
	local i
	for ((i = 1; i < "${#BASH_SOURCE[@]}" - 1; i++)); do
		caller "$i"
	done
	printf '\n'
}


# error -- print error message and terminate bash
#
# Usage: error "$message"
#
error()
{
	printf 'error: %s\n' "$*" >&2
	stacktrace >&2
	exit 1
}


# warning -- print warning message
#
# Usage: warning "$message"
#
warning()
{
	printf 'warning: %s\n' "$*" >&2
}


# debug -- print debug message (if enabled)
#
# Usage: debug "$message"
#
debug()
{
	if [ "$ACCIDENT_STIG_IMPL_SHOW_DEBUG" -ne 0 ]; then
		printf 'debug: %s\n' "$*" >&2
	fi
}


# trace -- run a command with xtrace enabled
#
# The rest of the arguments are executed as the command
#
trace()
{
	# hidden from xtrace
	{

		local rval=0
		local xtrace=0

		# save current xtrace value
		if [[ -o xtrace ]]; then
			xtrace=1
		fi

		# enable xtrace
		set -x

	} 2>/dev/null

	"$@" ||
	# hidden from xtrace
	{

		# record non-zero exit status
		rval="$?";

	} 2>/dev/null

	# hidden from xtrace
	{

		# restore xtrace
		if [ "$xtrace" -eq 0 ]; then
			set +x
		fi

		# replay program exit status
		return "$rval"

	} 2>/dev/null
}


# compliance -- output compliance status for a given STIG rule
#
# Usage: compliance --rule-id "$rule_id" --status "$compliance_status"
#
compliance()
{
	local rule_id
	local compliance_status

	while [ "$#" -gt 0 ]; do
		case "$1" in
			--rule-id)
				shift 1
				rule_id="$1"
				shift 1
				;;
			--status)
				shift 1
				compliance_status="$1"
				shift 1
				;;
			*)
				error "$0: unknown option: $1"
				;;
		esac
	done

	if [ ! -v rule_id ]; then
		error 'missing --rule-id'
	fi

	if [ -z "$rule_id" ]; then
		error 'empty $rule_id'
	fi

	if [ ! -v compliance_status ]; then
		error 'missing --status'
	fi

	if [ -z "$compliance_status" ]; then
		error 'empty $compliance_status'
	fi

	case "$compliance_status" in
		"compliant")
			;;
		"noncompliant")
			;;
		*)
			error "unknown value for --compliance: $compliance_status"
			;;
	esac

	printf '%s\t%s\n' "$compliance_status" "$rule_id" >&"$ACCIDENT_STIG_IMPL_COMPLIANCE_REPORTING_FD"
}


# compliant -- convenience function
#              (calls compliance --status "compliant")
#
compliant()
{
	compliance "$@" --status "compliant"
}


# noncompliant -- convenience function
#              (calls compliance --status "noncompliant")
#
noncompliant()
{
	compliance "$@" --status "noncompliant"
}


# rule_template_sysctl_file -- generic installation of sysctl config file
#
#
rule_template_sysctl_file()
{
	local rule_id
	local reboot_file
	local sysctl_key
	local sysctl_target_value
	local config_source_file
	local config_destination_file
	local need_reboot
	local compliance
	local value
	local sysctl_path

	while [ "$#" -gt 0 ]; do
		case "$1" in
			--rule-id)
				shift 1
				rule_id="$1"
				shift 1
				;;
			--reboot-file)
				shift 1
				reboot_file="$1"
				shift 1
				;;
			--sysctl-key)
				shift 1
				sysctl_key="$1"
				shift 1
				;;
			--sysctl-target-value)
				shift 1
				sysctl_target_value="$1"
				shift 1
				;;
			--config-source-file)
				shift 1
				config_source_file="$1"
				shift 1
				;;
			--config-destination-file)
				shift 1
				config_destination_file="$1"
				shift 1
				;;
			*)
				error "$0: unknown option: $1"
				;;
		esac
	done

	if [ -z "${rule_id:-}" ]; then
		error "empty or absent --rule-id"
	fi

	if [ -z "${reboot_file:-}" ]; then
		error "empty or absent --reboot-file"
	fi

	if [ -z "${sysctl_key:-}" ]; then
		error "empty or absent --sysctl-key"
	fi

	if [ -z "${config_source_file:-}" ]; then
		error "empty or absent --config-source-file"
	fi

	if [ -z "${config_destination_file:-}" ]; then
		error "empty or absent --config-destination-file"
	fi

	sysctl_path="/proc/sys/${sysctl_key//./\/}"
	if [ ! -e "$sysctl_path" ]; then
		error "path does not exist: $sysctl_path"
	fi

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

		value="$(cat "$sysctl_path")"

		if [ "$value" = "$sysctl_target_value" ]; then
			compliance="$ACCIDENT_CONST_COMPLIANT"
		else
			compliance="$ACCIDENT_CONST_NONCOMPLIANT"
		fi

		# if allowed, make compliant

		if [ "$compliance" = "$ACCIDENT_CONST_NONCOMPLIANT" -a "$ACCIDENT_STIG_IMPL_ALLOW_IMPLEMENT" -ne 0 ]; then

			if [ ! -e "$config_destination_file" ]; then

				# make compliant
				trace cp -nv "$config_source_file" -T "$config_destination_file"

				# assume compliant until next reboot
				compliance="$ACCIDENT_CONST_COMPLIANT"
				touch "$reboot_file"
				need_reboot=1

			else
				warning "Target config file ($config_destination_file) already exists. Did someone override the setting?"
			fi
		fi
	fi

	if [ "$need_reboot" -ne 0 ]; then
		warning "A reboot is required to verify the value of $sysctl_key."
	fi

	compliance --rule-id "$rule_id" --status "$compliance"
}

# cmp_else_overwrite_file -- copy file if not exact match on destination
#
# Usage: cmp_else_overwrite_file "$source_file" "$destination_file"
#
cmp_else_overwrite_file()
{
	local source_file="$1"
	local destination_file="$2"

	local overwrite=0

	if [ ! -e "$destination_file" ]; then
		overwrite=1
	fi

	if [ "$overwrite" -eq 0 ]; then

		local rval=0
		cmp -s "$source_file" "$destination_file" || rval="$?"

		case "$rval" in
			0)
				# files are the same, no need to re-write identical content
				;;
			1)
				# files are different
				overwrite=1
				;;
			*)
				error "unexpected return value from cmp: $rval"
				;;
		esac

	fi

	if [ "$overwrite" -ne 0 ]; then
		trace cp -v "$source_file" -T "$destination_file"
	fi
}

# setup_grub_dropin_skeleton -- modify /etc/default/grub to support drop-ins
#
# Usage: setup_grub_dropin_skeleton
#
setup_grub_dropin_skeleton()
{
	# make the drop-ins directory
	if [ ! -d /etc/default/grub.accident-stig.d ]; then
		trace mkdir /etc/default/grub.accident-stig.d
	fi

	# add the drop-ins entry-point
	cmp_else_overwrite_file "$ACCIDENT_STIG_IMPL_BASH_LIB_DIR/resources/grub.accident-stig.bash" "/etc/default/grub.accident-stig.bash"

	# add the source command if not already present
	if ! grep -qe '^\s*\(\.\|source\)\s\+/etc/default/grub\.accident-stig\.bash\s*$' /etc/default/grub; then

		debug "updating /etc/default/grub"

		local tmpfile="$(mktemp)"
		test -n "$tmpfile" || error 'assertion failed'

		# copy (and "fix") /etc/default/grub to temporary file
		cat /etc/default/grub | tr -d '\r' | sed -e '$a\' > "$tmpfile"

		# add the source command
		printf '%s\n' '. /etc/default/grub.accident-stig.bash' >> "$tmpfile"

		# write back to /etc/default/grub
		cat "$tmpfile" > /etc/default/grub

		rm "$tmpfile"
		unset tmpfile

	fi
}


# rule_template_grub_cmdline_file -- generic installation of grub drop-in
#
#
rule_template_grub_cmdline_file()
{
	local rule_id
	local reboot_file

	local cmdline_argument_pattern
	local cmdline_required_argument

	local config_source_file
	local config_destination_file

	local need_reboot
	local compliance

	local values
	local value

	local file
	local regenerated

	local cmdline

	while [ "$#" -gt 0 ]; do
		case "$1" in
			--rule-id)
				shift 1
				rule_id="$1"
				shift 1
				;;
			--reboot-file)
				shift 1
				reboot_file="$1"
				shift 1
				;;
			--cmdline-argument-pattern)
				shift 1
				cmdline_argument_pattern="$1"
				shift 1
				;;
			--cmdline-required-argument)
				shift 1
				cmdline_required_argument="$1"
				shift 1
				;;
			--config-source-file)
				shift 1
				config_source_file="$1"
				shift 1
				;;
			--config-destination-file)
				shift 1
				config_destination_file="$1"
				shift 1
				;;
			*)
				error "$0: unknown option: $1"
				;;
		esac
	done

	if [ -z "${rule_id:-}" ]; then
		error "empty or absent --rule-id"
	fi

	if [ -z "${reboot_file:-}" ]; then
		error "empty or absent --reboot-file"
	fi

	if [ -z "${cmdline_argument_pattern:-}" ]; then
		error "empty or absent --cmdline-argument-pattern"
	fi

	if [ -z "${cmdline_required_argument:-}" ]; then
		error "empty or absent --cmdline-required-argument"
	fi

	if [ -z "${config_source_file:-}" ]; then
		error "empty or absent --config-source-file"
	fi

	if [ -z "${config_destination_file:-}" ]; then
		error "empty or absent --config-destination-file"
	fi


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
		read -a cmdline < /proc/cmdline

		# find values matching $pattern
		values=()
		for arg in "${cmdline[@]}"; do
			if [[ "$arg" =~ $cmdline_argument_pattern ]]; then
				values+=("$arg")
			fi
		done

		# if there is more than one value, then have to assume non-compliant
		if [ "${#values[@]}" -gt 1 ]; then

			warning "multiple kernel cmdline values matching pattern ${pattern}: ${values[*]}"
			warning "we can't trust which one is used; so assuming non-compliant"

			compliance="$ACCIDENT_CONST_NONCOMPLIANT"

		# if there is one value, then it must match or else it is non-compliant
		elif [ "${#values[@]}" -eq 1 ]; then

			value="${values[0]}"

			if [ "$value" = "$cmdline_required_argument" ]; then
				compliance="$ACCIDENT_CONST_COMPLIANT"
			else
				warning "non-compliant kernel cmdline value present: $value"

				compliance="$ACCIDENT_CONST_NONCOMPLIANT"
			fi

		# if there are no values, then add the compliant value by config file
		else

			test "${#values[@]}" -eq 0 || error 'assertion failed'

			compliance="$ACCIDENT_CONST_NONCOMPLIANT"

			# if allowed, make compliant

			if [ "$compliance" = "$ACCIDENT_CONST_NONCOMPLIANT" -a "$ACCIDENT_STIG_IMPL_ALLOW_IMPLEMENT" -ne 0 ]; then

				if [ ! -e "/etc/default/grub.accident-stig.d/$config_file" ]; then

					# make compliant
					setup_grub_dropin_skeleton
					trace cp -nv "$config_source_file" -T "$config_destination_file"

					# assume compliant until next reboot
					compliance="$ACCIDENT_CONST_COMPLIANT"
					touch "$reboot_file"
					need_reboot=1

					# regenerate grub config file
					#
					# TODO: verify that grub is being used
					# TODO: more intelligent selection of config file
					# TODO: do this once after all rules have executed
					#
					for file in /etc/grub2.cfg /etc/grub2-efi.cfg; do
						regenerated=0
						if [ -L "$file" ]; then
							trace grub2-mkconfig -o "$file"
							regenerated=1
						fi

						if [ "$regenerated" -eq 0 ]; then
							warning "did not find standard grub config symlink, so we didn't actually update grub configuration"
						fi
					done

				else
					warning "Target config file already exists. Did someone override the setting?"
				fi

			fi

		fi

	fi

	if [ "$need_reboot" -ne 0 ]; then
		warning "A reboot is required to verify the presence of $cmdline_required_argument."
	fi

	compliance --rule-id "$rule_id" --status "$compliance"
}


# setup_sshd_dropin_skeleton -- modify /etc/ssh/sshd_config to support drop-ins
#
# Usage: setup_sshd_dropin_skeleton
#
setup_sshd_dropin_skeleton()
{
	# make the drop-ins directory
	if [ ! -d /etc/ssh/sshd_config.d ]; then
		trace mkdir /etc/ssh/sshd_config.d
	fi

	# add the include directive if not already present
	if ! grep -qe '^\s*[Ii][Nn][Cc][Ll][Uu][Dd][Ee]\s\+\(/etc/ssh/\)\?sshd_config.d/\*\.conf\s*$' /etc/ssh/sshd_config; then

		debug "updating /etc/ssh/sshd_config"

		# this is the include directive to add
		str='Include /etc/ssh/sshd_config.d/*.conf'

		local tmpfile="$(mktemp)"
		test -n "$tmpfile" || error 'assertion failed'

		# copy/process /etc/ssh/sshd_config to temporary file
		{

			# add the include directive before first line
			# (so drop-ins can override default options)
			printf '%s\n' "$str"

			# copy/fix original file
			cat /etc/ssh/sshd_config | tr -d '\r' | sed -e '$a\'

		} > "$tmpfile"

		# write back to /etc/default/grub
		cat "$tmpfile" > /etc/ssh/sshd_config

		rm "$tmpfile"
		unset tmpfile

	fi
}
