#Rem monkeydoc Module congo.displayutils
Various standalone functions relating to display and image handling. Includes resource handling (with Texture Packer support), display resolution checks, cursor hide/show, screen capture, and so on. Some have platform-specific native code.
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
Import mojo
Import congo.congosettings
Import congo.texturecache
Import congo.sprite
Import congo.textutils
Import congo.point
Import congo.rect
Import congo.congoapp
Import congo.angelfont

' (Dev note - make sure imports are before other variables, and Extern is before Public functions etc)

#If TARGET="ios"
	Import "native/displayutils.${TARGET}.cpp"
	Extern
#Rem monkeydoc
[iOS only] Returns the content scale factor, i.e. 'Retina' displays return 2.0. Other targets will return 1.0.
#End
	Function GetContentScaleFactor:Float() = "GetContentScaleFactor" ' (note - names must match exactly!)
#End

#If TARGET="glfw"
	Import "native/displayutils.${TARGET}.cpp"
	Extern
	#Rem monkeydoc
	DEPRECATED - use mojo HideMouse instead.
	[GLFW] Hides the mouse cursor.
	#End
	Function HideMouseCursor:Void() = "HideMouseCursor"
	#Rem monkeydoc
	DEPRECATED - use mojo ShowMouse instead.
	[GLFW] Restores the mouse cursor.
	#End
	Function RestoreMouseCursor:Void() = "RestoreMouseCursor"
#End

#If TARGET="html5"
	Import "native/displayutils.${TARGET}.js"
	Extern
	#Rem monkeydoc
	DEPRECATED - use mojo HideMouse instead.
	[HTML5] Hides the mouse cursor.
	#End
	Function HideMouseCursor:Void() = "HideMouseCursor"
	#Rem monkeydoc
	DEPRECATED - use mojo ShowMouse instead.
	[HTML5] Restores the mouse cursor.
	#End
	Function RestoreMouseCursor:Void() = "RestoreMouseCursor"
#End

#If TARGET="flash"
	Import "native/displayutils.${TARGET}.as"
	Extern
	#Rem monkeydoc
	DEPRECATED - use mojo HideMouse instead.
	[Flash] Hides the mouse cursor.
	#End
	Function HideMouseCursor:Void() = "HideMouseCursor"
	#Rem monkeydoc
	DEPRECATED - use mojo ShowMouse instead.
	[Flash] Restores the mouse cursor.
	#End
	Function RestoreMouseCursor:Void() = "RestoreMouseCursor"
#End

Public

#Rem monkeydoc
(dummy function for unsupported devices - returns 1.0).
#End
#If TARGET<>"ios"
	Function GetContentScaleFactor:Float()
		Return 1.0
	End
#End

#If TARGET<>"html5" And TARGET<>"flash" And TARGET<>"glfw"
#Rem monkeydoc
(empty function for unsupported devices - see main entries)
#End
	Function HideMouseCursor:Void()
	End
#Rem monkeydoc
(empty function for unsupported devices - see main entries)
#End
	Function RestoreMouseCursor:Void()
	End
#End

#Rem monkeydoc
Enables iOS retina modes where supported.
** TODO/Dev note - this function is no longer used **. Remove? 
ResScaler does the scaling, whilst IOS_RETINA_ENABLED=True is the default in monkey, which means retina
devices will report their full 2x display sizes -- we don't need to scale this; autofit sees double the pixels.

Call this early on, i.e. must be before any autofit/layout code or resource loading is performed.
Internally, calling this function will multiply subsequent resource scalers by 2.0 if the display is Retina.

The Monkey iOS retina config setting must also be set to True for this to work correctly.
#End
Function EnableCongoRetina:Void()

	CONGO_DEVICE_CONTENT_SCALE = GetContentScaleFactor()
	CongoLog( CONGO_NAME_STRING + ": EnableCongoRetina called, device scale set to " + CONGO_DEVICE_CONTENT_SCALE )

End

#Rem monkeydoc
Internal. Stores the current device scale factor. Don't set this manually, use EnableCongoRetina().
TODO/dev note - this is currently not used! Remove? ResScaler does all the scaling in the displayitem.
#End
Global CONGO_DEVICE_CONTENT_SCALE:Float = 1.0

#Rem monkeydoc
Main resource loading funtion.

This function loads a resource via the shared Texturecache, using sd, hd or xhd resolution versions depending on current settings.
If a file does not exist, an error will be generated. Note, you should not mix sd/hd/xhd resources, use a consistent set.
#End
Function CongoResourceLoader:Image( imagename:String, flags:Int = Image.DefaultFlags )

	Local imagefullp:String = imagename
	
	imagefullp = GetFullResourceName( imagename )
	
	Local img:Image = TextureCache.getInstance().AddResource( imagefullp,  flags )
	If img = Null Then
		Error( CONGO_ERROR_STRING + "Image is Null for file: " + imagefullp )
	End
	Return img

End

#Rem monkeydoc
Similar to CongoResourceLoader, this function loads an sd/hd/xhd Angelfont font resource. 

Data files for the hd font should have the hd extension, and so on. 
The fontname argument should be the regular (sd) font name without extension. 

Texturecache is not used since AngelFont caches images itself.

If using bmGlyph, export in 'Sparrow' xml format.
#End
Function CongoFontLoader:AngelFont( fontname:String )

	fontname = GetFullResourceName( fontname )
	
	CongoLog( "CongoFontLoader loading " + fontname )
	
	Local af:AngelFont = New AngelFont()
	af.LoadFontXml( fontname )
	Return af

End

#Rem monkeydoc
Returns True if the current settings and display size support hd (double-size) resources.
See CongoSettings to change the display size settings. 

Generally you don't need to use this manually, since CongoImageLoader() and the Sprite class
deal with it automatically. However, if you are doing some custom resource handling or other
graphics code you may need to use this.
#End
Function IsUsingHDResources:Bool()

	Local wid:Int = Min( DeviceWidth(), DeviceHeight() ) ' note - pixel units.
	Return( CONGO_ENABLE_HD_IMAGES And wid >= CONGO_HD_DEVICE_WIDTHREQ )

End

#Rem monkeydoc
Returns True if the current settings and display size support xhd (4x-size) resources.
See CongoSettings to change the display size settings. 

Generally you don't need to use this manually, since CongoImageLoader() and the Sprite class
deal with it automatically. However, if you are doing some custom resource handling or other
graphics code you may need to use this.
#End
Function IsUsingXHDResources:Bool()

	Local wid:Int = Min( DeviceWidth(), DeviceHeight() ) ' note - pixel units.
	Return( CONGO_ENABLE_XHD_IMAGES And wid >= CONGO_XHD_DEVICE_WIDTHREQ )

End

#Rem monkeydoc
Returns the display aspect ratio width/height, where width is the longest edge. Uses pixel coordinates reported by the device.
#End
Function DeviceAspectRatio:Float()

	Local longest:Int  = Max( DeviceWidth(), DeviceHeight() ) 
	Local shortest:Int = Min( DeviceWidth(), DeviceHeight() ) 
	Return Float(longest) / Float(shortest)

End

#Rem monkeydoc
Handy function which returns a full resource name with the correct sd/hd/xhd folder and file extension added.

Used by CongoImageLoader and CongoFontLoader, but can be used to obtain any resource name if it follows the 
correct naming convention.
#End
Function GetFullResourceName:String( file:String )

	Local extn:String = ""
	Local spl:String[] = file.Split( "." )
	
	' if extn, store it and chop it off.
	If spl.Length() > 1 And spl[spl.Length()-1].Length() > 0 Then
		extn = spl[ spl.Length()-1 ]
		file = ""
		For Local i:Int=0 Until spl.Length()-1 ' deals with multiple dots in file name
			file += spl[i]
			If i < spl.Length() -2 file += "."
		End
	End

	'  add any folder name and the suffix (depends on options)
	If IsUsingXHDResources() Then
		If CONGO_XHD_FOLDER <> "" file = CONGO_XHD_FOLDER.Replace("/", "" ) + "/" + file
		file += CONGO_XHD_SUFFIX
	Else If IsUsingHDResources() Then
		If CONGO_HD_FOLDER <> "" file = CONGO_HD_FOLDER.Replace("/", "" ) + "/" + file
		file += CONGO_HD_SUFFIX
	Else
		If CONGO_SD_FOLDER <> "" file = CONGO_SD_FOLDER.Replace("/", "" ) + "/" + file
		file += CONGO_SD_SUFFIX
	End
	
	' add exnt back
	If extn <> "" file += "." + extn
	

	CongoLog( "GetFullResourceName returning: " + file )
	
	Return file

End

#Rem monkeydoc
Function which returns an Image grabbed from a TexturePacker atlas (exported in Generic xml format). 
The Image is stored in the shared Texturecache for future use (to avoid processing the xml each time). 
Will throw exception if no image is loaded.

Used by Sprite class LoadFromTP(), but can also be used standalone. Image will be Null if a name match cannot be found.

Use the regular (sd) resource name for the xml and image names.
Note, all names are case-sensitive when searching the xml for names.

Dev note about 'GrabImage': this is not inefficient since a grabbed image and its source image share the same
surface texture in mojo - no copying occurs. See http://www.monkeycoder.co.nz/Community/posts.php?topic=1934 and 
http://www.monkeycoder.co.nz/Community/posts.php?topic=4176.
#End
Function ImageFromTP:Image( tpimg:Image, dataName:String, imageName:String )

	Local theImage:Image = Null
	If ( tpimg = Null ) Error( CONGO_ERROR_STRING + "Supplied Texturepacker image appears to be null" )

	dataName = GetFullResourceName( dataName )

	' check cache first
	theImage = TextureCache.getInstance().GetImage( imageName )
	If theImage <> Null Return theImage

	Local atlasFileStr:String = mojo.LoadString( dataName + ".xml" ) ' (bug fix, mojo and os both have LoadString).
	CongoLog( "TP xml file - loaded " + atlasFileStr.Length() + " chars." )
	If atlasFileStr.Length() = 0 CongoLog( CONGO_WARNING_STRING + "Texturepacker file empty or wrong filename." )
		
	If Not atlasFileStr.Contains( "<?xml version=" ) Then
		CongoLog( CONGO_WARNING_STRING + "Texturepacker file doesn't appear to contain valid xml header." )
	End
	
	Local spriteLines:String[] = atlasFileStr.Split( "<sprite n=" )
		
	' find best match to our imageName
	Local strMatch:Int = -1
	For Local i:Int = 0 To spriteLines.Length() - 1
		' look for our name (xml contains the name in quotes). Checks for extns too, depends how the TP atlas was made.
		If spriteLines[i].Contains( "~q" + imageName + "~q" ) Or 
		   spriteLines[i].Contains( "~q" + imageName + CONGO_HD_SUFFIX + "~q" ) Or 
		   spriteLines[i].Contains( "~q" + imageName + CONGO_XHD_SUFFIX + "~q" ) Then
		   		strMatch = i
		End
	End
		
	If strMatch = -1 Then
		Print CONGO_WARNING_STRING + "Could not find match for " + imageName + " in the Texturepacker xml."
	Else
		' we assume the first 4 sets of quotes contain: name, x, y, width, height.
		' Theres also the text before the first quote, hence 9 entries (or more - TP can add extras for trimming etc).
		Local splitLine:String[] = spriteLines[strMatch].Split( "~q" )
		If splitLine.Length() < 9 Then
			Print CONGO_WARNING_STRING + "Could not process Texturepacker line (check quotes?) : " + spriteLines[strMatch]
		Else
			Local readX:Int = Int( splitLine[3] )
			Local readY:Int = Int( splitLine[5] )
			Local readW:Int = Int( splitLine[7] )
			Local readH:Int = Int( splitLine[9] )
			CongoLog( CONGO_NAME_STRING + " - Texturepacker input read for " + imageName + " : " + readX + " " + readY + " " + readW + " " + readH )
			theImage = tpimg.GrabImage( readX, readY, readW, readH, 1, Image.MidHandle )
			' cache it
			TextureCache.getInstance().AddImage( theImage, imageName )
			
		End	
	End
		
	If theImage = Null Then
		Print CONGO_ERROR_STRING + "Could not load image from texturepacker file, check data."
		Throw New Throwable()
	End
		
	Return theImage
	
End	
	
#Rem monkeydoc
Returns a new Image containing a screen shot of device display.
Monkey/mojo requires that this is called from within the render loop. 

Note, the Image may be large, and has the dimensions of the device in pixels.
#End
Function GrabScreenShot:Image()
		
		Local img:Image = CreateImage( DeviceWidth(), DeviceHeight() )
		img.SetHandle( 0.5*img.Width(), 0.5*img.Height() )
		Local pixels:Int[] = New Int[ DeviceWidth() * DeviceHeight() ]
		ReadPixels(pixels, 0.0, 0.0, DeviceWidth(), DeviceHeight() ) ' direct grab from device screen
		img.WritePixels( pixels, 0.0, 0.0, DeviceWidth(), DeviceHeight() )
		CongoLog( "GrabScreenShot. size is " + img.Width() + " x " + img.Height() )
		Return img
	
End

#Rem monkeydoc
Simple rectangle drawing routine, used for debug drawing of bounding rects etc.
#End
Function DrawBox:Void( r:Rect )

	DrawLine( r.x, r.y, r.x + r.Width, r.y )
	DrawLine( r.x, r.y, r.x, r.y + r.Height )
	DrawLine( r.x + r.Width, r.y, r.x + r.Width, r.y + r.Height )
	DrawLine( r.x, r.y + r.Height, r.x + r.Width, r.y + r.Height )
		
End
