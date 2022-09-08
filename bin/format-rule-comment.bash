#!/bin/bash

# Used to produce descriptive comment blocks for implementor scripts.
#
# For example (pardon the long lines):
#
#   You run bin/format-rule-comment.bash
#
#   You copy the following from the webpage, paste as standard input:
#
#     Group ID (Vulid): V-230224
#     Group Title: SRG-OS-000185-GPOS-00079
#     Rule ID: SV-230224r809268_rule
#     Severity: CAT II
#     Rule Version (STIG-ID): RHEL-08-010030
#     Rule Title: All RHEL 8 local disk partitions must implement cryptographic mechanisms to prevent unauthorized disclosure or modification of all information that requires at rest protection.
#
#   You Ctrl-D, and bin/format-rule-comment.bash outputs the following:
#
#     #
#     # Group ID (Vulid):       V-230224
#     #
#     # Group Title:            SRG-OS-000185-GPOS-00079
#     #
#     # Rule ID:                SV-230224r809268_rule
#     #
#     # Severity:               CAT II
#     #
#     # Rule Version (STIG-ID): RHEL-08-010030
#     #
#     # Rule Title:             All RHEL 8 local disk partitions must
#     #                         implement cryptographic mechanisms to prevent
#     #                         unauthorized disclosure or modification of all
#     #                         information that requires at rest protection.
#     #




# sponge up input before processing in case of early termination
base64 -w0 | tac | base64 -d |

# effectively dos2unix
tr -d '\r' |

# format the input
{
	# read one line at a time
	while read -r line; do

		# look for specific STIG "key: value"-formatted lines
		if [[ "$line" =~ ^((Group\ ID\ \(Vulid\)|Group\ Title|Rule\ ID|Severity|Rule\ Version\ \(STIG-ID\)|Rule\ Title)+):\ (.*)$ ]]; then

			prefix="${BASH_REMATCH[1]}:"
			body="${BASH_REMATCH[3]}"

			# separate sections of the comment
			# (also comes before first section)
			printf '#\n'

		else

			prefix=""
			body="$line"

		fi

		# break long lines to fit in our target width
		body="$(fold -sw47 <<< "$body")"

		# for each line of the now multi-line body,
		# print it, while prefixing the first one with $prefix
		while read -r line; do

			# print the line, but avoid creating trailing whitespace
			if [ -n "$line" ]; then
				printf '%s%s\n' "$(printf '# %-23s ' "$prefix")" "$line"
			else
				printf '#\n'
			fi

			# empty the prefix (does not affect first line)
			prefix=""

		done <<< "$body"

	done

	# make symmetric with first line of comment
	printf '#\n'
} |

# sponge up output before displaying to help separate from input
base64 -w0 | tac | base64 -d
