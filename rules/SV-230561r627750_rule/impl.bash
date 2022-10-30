#!/bin/bash

set -eu
set -o pipefail
shopt -s inherit_errexit

exec 0</dev/null

source "$ACCIDENT_STIG_IMPL_BASH_LIB_DIR/accident-stig-library.bash"


#
# Group ID (Vulid):       V-230561
#
# Group Title:            SRG-OS-000480-GPOS-00227
#
# Rule ID:                SV-230561r627750_rule
#
# Severity:               CAT II
#
# Rule Version (STIG-ID): RHEL-08-040390
#
# Rule Title:             The tuned package must not be installed unless
#                         mission essential on RHEL 8.
#


# check compliance based on if package is installed
# TODO: validate `rpm` output for non-zero return value
#
if rpm -q tuned >/dev/null; then
	compliance="$ACCIDENT_CONST_NONCOMPLIANT"
else
	compliance="$ACCIDENT_CONST_COMPLIANT"
fi


# if allowed, make compliant

if [ "$compliance" = "$ACCIDENT_CONST_NONCOMPLIANT" -a "$ACCIDENT_STIG_IMPL_ALLOW_IMPLEMENT" -ne 0 ]; then

	# check if we can uninstall the package alone
	# TODO: validate `rpm` output for non-zero return value
	#
	if ! rpm -q --whatrequires tuned >/dev/null; then

		# make compliant
		trace yum remove -y tuned
		compliance="$ACCIDENT_CONST_COMPLIANT"

	else
		warning "other packages require tuned; not automatically removing"
	fi
fi

compliance --rule-id "SV-230561r627750_rule" --status "$compliance"


exit 0
