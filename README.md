# Automated implementation of RHEL 8 STIG

## About

This repository is a collection of scripts allowing system
administrators to check and/or implement guidance from the Red Hat
Enterprise Linux (RHEL) 8 Secure Technical Implementation Guide (STIG),
in order to make their systems compliant.

## Usage

Clone the repository.

Run the following as root:

```
bin/compliance.bash --mode implement
```

## Contribution

### Obtaining guidance reference material

The RHEL 8 STIG reference material and STIG Viewer are publicly
available from <https://public.cyber.mil/>.

For developer convenience, this repository provides a viewable copy of
the RHEL 8 STIG XCCDF, accessible from the below link:

<https://public-pd-inc.github.io/accident-stigs/doc-U_RHEL_8_V1R7_STIG/U_RHEL_8_V1R7_Manual_STIG/U_RHEL_8_STIG_V1R7_Manual-xccdf.xml>

A pre-XSLT-transformed copy is available at the below link:

<https://public-pd-inc.github.io/accident-stigs/doc-U_RHEL_8_V1R7_STIG/U_RHEL_8_V1R7_Manual_STIG/U_RHEL_8_STIG_V1R7_Manual-xccdf.html>

Additionally, a copy of STIG Viewer is also available at the below link:

<https://github.com/public-pd-inc/accident-stigs/raw/files-U_STIGViewer_2-16.zip/U_STIGViewer_2-16.zip>

### Project architecture

The `bin/compliance.bash` file is the main entry point of this tool.  It
configures environment variables, locates, and calls executables
designed to check and/or implement rules.

The `rules/` directory is where rule implementations are stored.  Each
implementor is stored in a subdirectory of `rules/`.

If an implementor implements one specific rule, its subdirectory name is
the rule ID from the STIG, and must be in the format of
`rules/SV-*_rule/`.

If an implementor simultaneously implements multiple rules, its
subdirectory name is chosen by the developer, and must be in the format
of `rules/group-*/`.

Implementor subdirectories of `rules/` contain the implementor
executable (named `impl.bash` or `impl`), and any files necessary to
implement the rule(s).

#### Environment variables

When `bin/compliance.bash` calls the implementor executable, it passes
no command-line arguments, and sets the following environment variables:

##### `ACCIDENT_STIG_IMPL_ALLOW_IMPLEMENT`

Set to `0` when the user only wants to check compliance (the system must
not be modified), or `1` when the user would like the tool to make their
system compliant.

##### `ACCIDENT_STIG_IMPL_BASH_LIB_DIR`

Set to the absolute path of the directory containing the
`accident-stig-library.bash` file.
This is set by `bin/compliance.bash` to be this repository's `lib/`
directory.

##### `ACCIDENT_STIG_IMPL_COMPLIANCE_REPORTING_FD`

Set to the file descriptor used for reporting rule compliance.
This value is used by the `compliance` function defined in
`lib/accident-stig-library.bash`.

##### `ACCIDENT_STIG_IMPL_RULE_DIR_BIN`

Set to the absolute path of the directory containing executables used to
implement a rule.
This is set by `bin/compliance.bash` to be the implementor's
subdirectory of `rules/`.

##### `ACCIDENT_STIG_IMPL_RULE_DIR_RES`

Set to the absolute path of the directory containing static files used
to implement a rule.
This is set by `bin/compliance.bash` to be the implementor's
subdirectory of `rules/`.

##### `ACCIDENT_STIG_IMPL_RUN_DIR`

Set to the absolute path of the ephemeral directory where implementors
can store status information.
This is set by `bin/compliance.bash` to `/var/run/accident-stig-impl/X`
where `X` is the rule/group ID.
This can be used, for example, to avoid re-implementing a rule that was
already implemented but won't take affect until after the next reboot.

##### `ACCIDENT_STIG_IMPL_SHOW_DEBUG`

Set to `0` when debug messages should not printed, or `1` when debug
messages should be displayed.
This is enabled by `bin/compliance.bash` when given the `--debug`
argument.
This is used by the `debug` function defined in
`lib/accident-stig-library.bash`.
