# Makefile

# default target
all:

XML := U_RHEL_8_V1R7_Manual_STIG/U_RHEL_8_STIG_V1R7_Manual-xccdf.xml
XSL := U_RHEL_8_V1R7_Manual_STIG/STIG_unclass.xsl
HTML := ${XML:.xml=.html}

all: ${HTML}

${HTML}: ${XSL} ${XML}
	xsltproc --nonet -o $@ $^
