THyperImages 2.2.0 for Delphi 3, 4 and 5.
Copyright (C) 1998-1999 
by Noatak Racing Team

Table of content
- - - - - - - - -

- Installation
- Experts considerations
- JPEG and GIF support
- Known problems


Installation
- - - - - - -

- Remove previous versions of THyperImages.

- Unzip all the files in a new folder with
the Use Folder Names option.

- * Remove the {$DEFINE SHAREWARE} directive from the HyperIm.inc file.

- Compile the package HyperIm3.dpk, HyperIm4.dpk or HyperIm5.dpk.

- Install the compiled package in Delphi IDE.

- Add the path of the package and units to the library search path
in the IDE.

- Close Delphi before using THyperImages.

* Registered version only.


Experts considerations
- - - - - - - - - - - -

The shareware version includes the experts (help and code generation
experts).
For the registered version, if you have Delphi pro or above, you can
enable or not the {$DEFINE USEEXPERTS} directive from the HyperIm.inc file.
This will compile the experts into the component.
If you do not have Delphi pro or above, you can replace the Experts.pas
file with the Experts.dcu compiled unit from the shareware version and
enable the {$DEFINE USEEXPERS} directive. (You have to remove the
Expert.pas file or Delphi will try to recompile it and delphi standard
does not have the libraries needed to do that)


JPEG and GIF support
- - - - - - - - - - -

Delphi comes with a JPEG unit, but it is not installed by
default.
To obtain JPEG support at design time, you just have to install a
design package containing the JPEG unit.
Delphi 5 has JPEG support in its default packages.
Delphi 4 with a package called VCLJPG40 or 50, you just have to install
it.
In Delphi 3, you have to include the JPEG unit in a package or
create a special package for it, and install it.
To have JPEG support at run time, you have to add the JPEG unit to
your uses clause.

The same considerations are valid for GIF or any other graphic format,
except that no GIF support unit is included in Delphi and that 
you will need an LZW patent license from Unisys in order to
provide end-user GIF support legally in any commercial or shareware
application.

However, you can download freeware GIF support libraries from Delphi
Super Page or other Delphi sites.
The 2 that have been tested with THyperImages are TGifImage by
Anders Melander (http://www.melander.dk/delphi/gifimage) and
RX VCL extension library by Fedor Koshevnikov, Igor Pavluk and
Serge Korolev.
Both seem to work good with THyperImages.


Known problems
- - - - - - - -

After compiling the package HyperImx.dpk, you have to close Delphi
and reopen it before working on a project.

Running a application with a THyperImages component having the
InverOnHot property set to True in the Delphi IDE will sometimes cause
the application to crash when you move the mouse above the hotspots.
When you run the same application as standalone (outside the IDE),
everything is fine.

When you save a metafile (wmf) in the component with Delphi 3 and
read it again, you get some absurde display.
This come from a bug in the way Delphi streams the metafile format
to the dfm file.
The problem does not exist with enhanced metafiles (emf) and is
correted in Delphi 4.
There is no problem also if you load the metafile from a file instead
of the dfm file.
