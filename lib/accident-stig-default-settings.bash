# accident-stig-settings.bash

# This file is sourced to set environment variables that affect rule
# implementation.

# The SV-230296r627750_rule implementation checks for a history of
# remote logins to the root user, and warns the user instead of
# implementing the rule if there have been remote logins for root. We do
# this to avoid breaking remote administration and other scripted
# events.
#
# Set this variable to 1 if you have determined that you no longer
# "need" logins to the root user, and the rule will be implemented.
export ACCIDENT_STIG_SETTING_SSHD_ROOT_LOGON_RULE_BYPASS_WARNING="0"
