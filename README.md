# Macro Core

Much quality.  Many standards.  The **Macro Core** library exists to save time
and development effort!  Herein ye shall find a veritable host of production
quality SAS macros.  These are a mix of tools, utilities, functions and code
generators that are useful in the context of Application Development on the SAS
platform.  [Contributions](https://github.com/Boemska/macrocore/blob/master/CONTRIBUTING.md)
are welcomed.

# Components

**Base** library
 * OS independent
 * Not metadata aware
 * No X command
 * Prefixes:  _mf_, _mp_

**Meta** library
 * OS independent
 * Metadata aware
 * No X command
 * Prefixes: _mm_

**xcmd** library:
 * OS specific
 * Metadata aware
 * X command enabled
 * Prefixes: _mw_,_mu_,_mx_

# Installation
First, download the repo to a location your SAS system can access. Then update your sasautos path to include the components you wish to have available,eg:

```sas
options insert=(sasautos="/your/path/macrocore/base");
options insert=(sasautos="/your/path/macrocore/meta");
```

The above can be done directly in your sas program, via an autoexec, or an initialisation program.

Alternatively - for quick access - simply run the following!  This file contains all the macros.

```
filename mc url "https://raw.githubusercontent.com/Boemska/macrocore/master/macrocore.sas";
%inc mc;
```

# Standards

## File Properties
 - filenames much match macro names
 - filenames must be lowercase
 - macro names must be lowercase
 - one macro per file
 - prefixes:
   - _mf_ for macro functions (can be used in open code).
   - _mp_ for macro procedures (which generate sas code)
   - _mm_ for metadata macros (interface with the metadata server).
   - _mw_ for macros that only work in Windows (should work in ALL versions of windows)
   - _mu_ for macros that only work in Unix type environments (should work in ALL types of unix environment)
   - _mx_ for macros that use X command and will work in both windows and unix environments.
 - follow verb-noun convention
 - unix style line endings (lf)
 - individual lines should be no more than 80 characters long
 - UTF-8
 - no trailing white space
 - no trailing empty lines

## Header Properties
The **Macro Core** documentation is created using [doxygen](http://www.stack.nl/~dimitri/doxygen/).  A full list of attributes can be found [here](http://www.stack.nl/~dimitri/doxygen/manual/commands.html) but the following are most relevant:

 - file.  This needs to be present in order to be recognised by doxygen.
 - brief. This is a short (one sentence) description of the macro.
 - details.  A longer description, which can contain doxygen [markdown](http://www.stack.nl/~dimitri/doxygen/manual/markdown.html).
 - param.  Name of each input param followed by a description.
 - return.  Explanation of what is returned by the macro.
 - version.  The EARLIEST SAS version in which this macro is known to work.
 - author.  Author name, contact details optional
 - copyright.  Must be GNU GENERAL PUBLIC LICENSE v3.

All macros must be commented in the doxygen format, to enable the [online documentation](https://boemska.github.io/macrocore.github.io/).

## Coding Standards

*  Indentation = 2 spaces.  No tabs!
*  Macro variables should not have the trailing dot (`&var` not `&var.`) unless necessary to prevent incorrect resolution
*  The closing `%mend;` should not contain the macro name.
*  All macros should be defined with brackets, even if no variables are needed - ie `%macro x();` not `%macro x;`
*  Mandatory parameters should be positional, all optional parameters should be keyword (var=) style.
*  All dataset references to be 2 level (eg `work.blah`, not `blah`).
*  Avoid naming collisions!  All macro variables should be local scope.  Use system generated work tables where possible - eg `data ; set sashelp.class; run;  data &output;  set &syslast; run;`

# General Notes

* All macros should be compatible with SAS versions from support level B and above (so currently 9.2 and later).  If an earlier version is not supported, then the macro should say as such in the header documentation, and exit gracefully (eg `%if %sysevalf(&sysver<9.3) %then %return`).
