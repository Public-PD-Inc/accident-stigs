# accident-stig-enable-slub-poison.sh

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

GRUB_CMDLINE_LINUX+=" slub_debug=P "
