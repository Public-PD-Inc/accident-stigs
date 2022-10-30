# accident-stig-disable-vsyscall.sh

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

GRUB_CMDLINE_LINUX+=" vsyscall=none "
