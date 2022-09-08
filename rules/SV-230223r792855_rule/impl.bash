#!/bin/bash

set -eu
set -o pipefail
shopt -s inherit_errexit

exec 0</dev/null

source "$ACCIDENT_STIG_IMPL_BASH_LIB_DIR/accident-stig-library.bash"


#
# Group ID (Vulid):       V-230223
#
# Group Title:            SRG-OS-000033-GPOS-00014
#
# Rule ID:                SV-230223r792855_rule
#
# Severity:               CAT I
#
# Rule Version (STIG-ID): RHEL-08-010020
#
# Rule Title:             RHEL 8 must implement NIST FIPS-validated
#                         cryptography for the following: to provision
#                         digital signatures, to generate cryptographic
#                         hashes, and to protect data requiring
#                         data-at-rest protections in accordance with
#                         applicable federal laws, Executive Orders,
#                         directives, policies, regulations, and
#                         standards.
#


status_file="$ACCIDENT_STIG_IMPL_RUN_DIR/fips.needs_reboot"

compliance="$ACCIDENT_CONST_COMPLIANT"

if ! [ -e "$status_file" ]; then

	if ! fips-mode-setup --is-enabled; then

		compliance="$ACCIDENT_CONST_NONCOMPLIANT"

		if [ "$ACCIDENT_STIG_IMPL_ALLOW_IMPLEMENT" -ne 0 ]; then

			# make compliant
			trace fips-mode-setup --enable
			touch "$status_file"
			compliance="$ACCIDENT_CONST_COMPLIANT"

		fi

	fi

else

	warning 'A reboot is required to fully enable FIPS; assuming compliant'

fi

compliance --rule-id "SV-230223r792855_rule" --status "$compliance"


exit 0
