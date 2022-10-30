# accident-stig-enable-page-poison.sh

#
# Group ID (Vulid):       V-230277
#
# Group Title:            SRG-OS-000134-GPOS-00068
#
# Rule ID:                SV-230277r792884_rule
#
# Severity:               CAT II
#
# Rule Version (STIG-ID): RHEL-08-010421
#
# Rule Title:             RHEL 8 must clear the page allocator to
#                         prevent use-after-free attacks.
#

GRUB_CMDLINE_LINUX+=" page_poison=1 "
