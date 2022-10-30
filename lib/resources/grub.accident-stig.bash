# /etc/default/grub.accident-stig.bash

# this script is sourced by /etc/default/grub
#
# Therefore:
# ${BASH_SOURCE[0]} = this script
# ${BASH_SOURCE[1]} = /etc/default/grub
# ${BASH_SOURCE[2]} = grub2-mkconfig or grubby
#
# if we're being sourced by something else: please go away?

# sanity check out shell
# (note that grub2-mkconfig is literally written in bash)
#
if [ "$SHELL" = "/bin/bash" ]; then

	# only run the following when sourced from grub2-mkconfig
	# (or else grubby will naively collapse our GRUB_CMDLINE_LINUX
	# amendments into /etc/default/grub...)
	#
	if [ "${BASH_SOURCE[2]}" = "/sbin/grub2-mkconfig" ]; then

		# iterate over and source "our" config files
		for file in /etc/default/grub.accident-stig.d/*; do

			case "$file" in

				*.sh|*.bash)
					source "$file"
					;;

			esac

		done

	fi

else
	echo "warning: /etc/default/grub.accident-stig.bash requires bash" >&2
fi
