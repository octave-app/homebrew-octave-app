PSTOEDIT 
Copyright (C) 1993 - 2015 Wolfgang Glunz, wglunz35_AT_pstoedit.net

pstoedit converts PostScript(TM) and PDF files to other vector graphic
formats so that they can be edited graphically. See pstoedit.htm or
index.htm for more details on which formats are supported by pstoedit.

The architecture of pstoedit consists of a PostScript frontend which
needs to call a PostScript interpreter like Ghostscript and the
individual backends which are plugged into a kind of framework.

This framework can be used independently from the PostScript frontend
from any other program. The framework provides a uniform interface to
all different backends. Get in contact with the author if you need
more information on how to use this framework.

If you just find this program useful, have made some improvements or 
implemented other backends please send an email to wglunz35_AT_pstoedit.net.

If this programs saves you a lot of work consider sending a contribution
of any kind.

If you include this program on a CDROM, please send me a copy of the CD,
or if it goes with a book, of the book. 

My home address is:

	Dr. Wolfgang Glunz             
	81825 Muenchen / Germany  
	Josef Brueckl Str. 32    

Compiling pstoedit:
-------------------
You need a C++ compiler, e.g., g++ (newer than 3.0) to compile pstoedit.

It is recommended to have libplotter installed. Then you
get a lot of additional formats for free.

If you have a Unix like system, try the following:
sh configure; 
make
make install; 


Support for SWF needs version 0.3 or higher of ming. Version 0.2 does not work


There are several test cases included. To run them type `make test'.
This works under *nix only.


When building pstoedit under cygwin/Linux you may need to set LDFLAGS to /usr/local/lib in case you have some libraries (e.g. libEMF) installed there.

Under some systems (e.g. cygwin) it is not possible to link static libraries (.a) into a dynamic library (.so/.dll). In this case, you need to have also a shared version of the relevant libs, e.g. of libEMF. In order to get a shared version, you normally need to set the option "--enabled-shared" during the "configure" run for the library.


Installing pstoedit under Windows 9x/NT/2000/XP/Vista/Windows 7:
------------------------------------------------------

best use the pstoeditsetup.exe which is available for 32 and 64 bit environments.



Installing pstoedit under OS/2:
-------------------------------

See the readme.os2 in the os2 directory. There you also find a makefile 
for OS/2.

pstoedit and the -dSAFER option of Ghostscript:
-----------------------------------------------
Ghostscript provides an option -dSAFER that disables all file access
functions of PostScript. Some administrators even install a wrapper
like to following instead of gs directly
#!/bin/sh
gs.real -dSAFER $*

So when a user uses gs he/she actually runs this script. However,
pstoedit needs to have access to files for its operation. So
it is not possible to use this wrapper for gs in combination with pstoedit.
You would get an error message like "Error: /invalidfileaccess in (w)".

As an alternative the following can be done:
1. Install the binary of pstoedit as pstoedit.real
2. Create the following wrapper and name it pstoedit
#!/bin/sh
GS=gs.real
export GS
pstoedit.real -include /??????/local/safer.ps $*

A template for safer.ps can be found in the misc subdirectory.
This way pstoedit can open all the files it needs (the input file and an
output file). After that then -- via the included file -- all file
operations are disabled and the input file is processed. Any file operation
that is executed be the user's PostScript file is disabled this way.


Using pstoedit:
---------------
Before you can use pstoedit you must have a working installation
of Ghostscript (either GNU or Aladdin).

The rest is described in the manual page in /pstoedit.htm.

pstoedit works reasonable with PostScript files containing
	* line drawings
	* text with standard fonts 

Try to run it on golfer.ps or tiger.ps that comes with Ghostscript, e.g., 
pstoedit -f <your format> <local path where GhostScript is installed>/examples/tiger.ps tiger.<suffix>

Some features that are no supported by every backend of pstoedit:
	* bitmap images (just for some backends and only a subset of the PostScript image operators)
	* general fill patterns
	* clipping (only partially via the -sclip option)
	* ... 

Special note about the Java backend:
------------------------------------
The Java backends generate a Java source file that needs other files
in order to be compiled and usable. See the files contrib/java/java1/readme_java.txt 
and contrib/java/java2/readme_java2.htm for more details.

Extending pstoedit:
-------------------
To implement a new backend you can start from drvsampl.cpp.
Please don't forget to send any new backend that might be of interest
for others as well to the author (wglunz35_AT_pstoedit.net) so that
it can be incorporated into future versions of pstoedit. Such
new backends will then be available with the GPL as well.

Acknowledgements:
-----------------

See manual page in pstoedit.htm and the changelog.htm for a list of contributors.

License: 
--------

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.



----------------------------------------------------------------------------
 
