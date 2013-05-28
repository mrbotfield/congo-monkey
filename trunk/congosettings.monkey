#Rem monkeydoc Module congo.congosettings
General Congo module settings. Some are user-definable, see individual comments below. 
Entries can be edited here or overridden in code, e.g. at the start of your main app file.
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict

' Internal strings and identifiers.
#Rem monkeydoc
(Internal) Module name string.
#End
Global CONGO_NAME_STRING:String 	= "Congo"
#Rem monkeydoc
(Internal) Module version number string.
#End
Global CONGO_VERSION_STRING:String = "0.51"
#Rem monkeydoc
(Internal) Error message string.
#End
Global CONGO_ERROR_STRING:String 	= "ERROR (" + CONGO_NAME_STRING + "):"
#Rem monkeydoc
(Internal) Warning message string.
#End
Global CONGO_WARNING_STRING:String = "Warning (" + CONGO_NAME_STRING + "):"

' User-definable settings. These can be overridden at the start of your main app file (do anywhere before resource loading etc).

#Rem monkeydoc
Congo has the concept of sd, hd and xhd resources. It loads the specific resource based on device width (in pixels) and 
these user options. i.e. enable CONGO_ENABLE_HD_IMAGES to load hd resources on supported devices. Use CongoImageLoader() to 
perform this automatically.

See also CONGO_HD_DEVICE_WIDTHREQ and CONGO_XHD_DEVICE_WIDTHREQ.

Note - on iOS you can use this *instead* of the @2x' filename convention. This also means you can use hd resources on a non-retina iPad.

Note - you should not mix sd and hd (or xhd) resources -- keep a consistent set.

Note - for browser targets you might want to disable hd for performance, these are really intended for mobile targets.
#End
Global CONGO_ENABLE_HD_IMAGES:Bool = True

#Rem monkeydoc
Extra-high def setting. See entry for CONGO_ENABLE_HD_IMAGES.
#End
Global CONGO_ENABLE_XHD_IMAGES:Bool = True


#Rem monkeydoc
Resource suffix for sd. Case sensitive (best to use lower-case throughout). 

Note - folder names do not require forward slashes.

Note - Flash can not use file names containing hyphens or dashes. 
#End
Global CONGO_SD_SUFFIX:String	= ""
#Rem monkeydoc
Resource folder name for sd resources.
#End
Global CONGO_SD_FOLDER:String 	= "sd"
#Rem monkeydoc
Resource suffix for hd.
#End
Global CONGO_HD_SUFFIX:String 	= "-hd"
#Rem monkeydoc
Resource folder name for hd resources.
#End
Global CONGO_HD_FOLDER:String 	= "hd"
#Rem monkeydoc
Resource suffix for hd.
#End
Global CONGO_XHD_SUFFIX:String 	= "-xhd"
#Rem monkeydoc
Resource folder name for xhd resources.
#End
Global CONGO_XHD_FOLDER:String 	= "xhd"

#Rem monkeydoc
Change this to determine the threshold screen width where hd images will be used (if enabled above). 
Default of 640 pixels means that devices with 320x480 displays (e.g. iPhone3G, basic Android) will not use HD images,
whilst iPhone4 and all iPads will, since they have widths of 640 and 768 pixels respectively.

Note - for browser targets >640 wide you might want to disable hd, these are really intended for mobile targets.
#End
Global CONGO_HD_DEVICE_WIDTHREQ:Int 	= 640 	' Default 640, e.g. retina iOS.
#Rem monkeydoc
As for CONGO_HD_DEVICE_WIDTHREQ, but for xhd resources. 
#End
Global CONGO_XHD_DEVICE_WIDTHREQ:Int 	= 1280	' Default 1280, e.g. retina iPad (width 1536) will use this.

#Rem monkeydoc
Maximum number of simultaneous touches handled by TouchManager. For single touch only, set to 1.
Must be set before TouchManager init is called.
#End
Global CONGO_MAX_MULTITOUCH:Int = 1 

#Rem monkeydoc
Folder name for all audio files, leave blank for top-level.
#End
Global CONGO_AUDIO_FOLDER:String = "audio"

#Rem monkeydoc
Maximum number of simultaneous sound channels supported by AudioPlayer.
8 is a good conservative number for general use, but up to 32 are available, depending on target.
#End
Global CONGO_MAX_AUDIO_CHANNEL:Int = 8

#Rem monkeydoc
Set this to prevent autofit from drawing any border clip region. This lets you fill the entire device 
screen, e.g. showing a background image outside of the autofit game region. Useful for supporting 
different mobile aspect ratios whilst retaining consistent autofit  virtual coordinates.
#End
Global CONGO_AUTOFIT_NOBORDERS:Bool = False

#Rem monkeydoc
[Used?] Enable Box2d physics debug draw mode. 
Note, you may need to make your bg/main layer transparant to see it.
#End
Global CONGO_PHYSICS_DEBUGDRAW:Bool = True
