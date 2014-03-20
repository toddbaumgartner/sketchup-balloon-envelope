sketchup-balloon-envelope
=========================

Create 3d models of Hot Air Balloon Envelopes in Sketchup.  Uses the Sketchup Ruby API.

This was developed using Sketchup 2014 on a Mac.  I haven't really tested it under Windows.

This can be installed into Sketchup by going into Preferences -> Extensions.
Extensions -> Install Extension
Select the file balloon_envelope.rbz.

Close and reopen Sketchup and you should have a new option under Plugins.
Draw Envelope will add it to your drawing.

This plugin searches the following paths for Envelope.csv:

~/Documents
~/My Documents
/tmp

The first one located will be drawn.


To create a file that is compatible with the plugin, use the included Deering_gore_pattern.xls
Plug in the appropriate values for the design you are making.
Once everything looks good, change over to the Gores worksheet in Excel.

Then you need to do a Save As to save that workseet as Envelope.csv.  Place it in your Documents directory, and the plugin 
should be able to located it and draw it.


