# 3d printed vacuum clamp

This is a (mostly) 3d printed vacuum clamp for workholding.  It is designed to be used with workpieces that may not form a perfect seal in all sections; the sealing surface on the clamp is divided into cells that each have limited air flow so the whole vacuum isn't lost if some of the cells aren't sealed.

## Additional Components Needed

* A vacuum pump
* Vacuum tubing
* Adapter fitting from vacuum tubing to 1/8 NPT male
* A gasket (see below for how to make this)

## Settings

The vacuum clamp is written in OpenSCAD and has a number of configuration options.  I highly recommend editing these and compiling your own customized STL instead of using the STL I built to my own specifications.  When rendering, OpenSCAD will output several pieces of information calculated from the settings.  These can be important for making the gasket and redrilling the holes.

## Printing

The print settings don't seem to be critical for this.  There are no steep overhangs or other particularly difficult-to-print parts.  I'd suggest increasing the number of perimeters and top/bottom layers, and maybe increasing your infill percentage; but it seems to work alright without these modifications.  I'd recommend using a relatively strong filament to print - I used PETG.

## Chasing the threads

The 3d printed pipe threads can be a bit rough, so I recommend chasing the threads with a tap (1/8" NPT) if you have one on hand.  Otherwise, use plenty of thread sealant.

## Drilling holes

Limiting airflow to the different cells in the vacuum clamp relies on small holes in the surface.  You can try 3d printing these holes as-is, but generally 3d printers don't do a great job with holes this small, so I recommend drilling out the vacuum holes in each cell.  The OpenSCAD code will output the size of the drill to use for this (calculated from the parameters in the file).  The default size that corresponds to the default parameters is 0.5mm.

These holes can be drilled by hand, but it's difficult to be accurate, is tedious, and will often break the drill bit.  Machine drilling in a drill press is recommended; or, even better, using a CNC mill.  A javascript file (run using Node.JS) is included that produces gcode to peck drill in the appropriate grid pattern (make sure to edit the settings in the file to match the vacuum clamp).  You can also use any other tool to produce this gcode.  The needed parameters (spacing, depth, etc) are given in the output of OpenSCAD.

## Gasket

The gasket for use with this vacuum clamp can be made a few different ways.

### Milling the gasket

The way that has worked best for me is to mill the gasket out of soft EPDM foam rubber sheet.  The default settings expect a 1/4" thick gasket; EPDM foam sheet can be readily found in this thickness.  What has worked for me is to tape the foam sheet to a sacrificial material, then cut out the gasket, taking out only a small layer on each pass.

Using this method also allows for the offcut squares to be used to seal up unused cells (if the workpiece doesn't cover the whole clamp).  The kerf/tool diameter for cutting the gasket is one of the parameters in the OpenSCAD file, which alters the structure to ensure a reasonable seal is formed.  The default tool diameter is 1.5mm.

A javascript file is provided to generate gcode to do this.  Be sure to edit the file as needed then run using Node.JS.  Instead of using this gcode generator, you can use a different tool to produce this gcode.  In the OpenSCAD file, setting the 'part' parameter to 'gasket2d' instead of 'base' will cause it to generate a 2 dimensional representation of the gasket shape, which can be exported as a DXF and imported into a different tool to generate the gcode.

It's possible that a drag knife could work better than a milling cutter for this, but I haven't tried it.

### Printing the gasket

It's possible that a gasket can be itself 3d printed using a flexible filament.  I haven't tried this, but the OpenSCAD file provides the ability to generate the needed STL for this by setting the 'part' parameter to 'gasket'.

### Molding the gasket

I've also experimented with molding the gasket using RTV silicone and a 3d printed mold.  I was unable to make this work well, but it's possible that it could be made to work with some additional effort.

## Reaming locating pin holes

There are holes provided for locating pins to position a workpiece relative to the clamp.  I recommend printing these slightly smaller than necessary, then reaming them to the appropriate size, to ensure a good fit.

