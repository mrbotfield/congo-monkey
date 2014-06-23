' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.
' SoftTarget - Congo sample app.

Strict

Import mojo

Import congo
Import mainmenulayer

Function Main:Int()

	' can overide congo defaults here.
	CONGO_AUDIO_FOLDER = "audio"
	CONGO_HD_SUFFIX = ""
	CONGO_XHD_SUFFIX = ""
	CONGO_ENABLE_HD_IMAGES = True 
	CONGO_ENABLE_XHD_IMAGES = True
	
	New MyApp
	Return 0
	
End

' main app class. best to keep this simple, put most code in layer classes.
Class MyApp Extends CongoApp
	
	Method OnCreate:Int()
	
		CongoLog( "In MyApp OnCreate" )
		
		Super.OnCreate() ' *Required* for CongoApps.
		
	  	SetUpdateRate (60)
		CongoLog( "Device width = " + DeviceWidth() + ", height = " + DeviceHeight() + " (pixel units)" )
	  	 	
	 	EnableCongoRetina() ' call this early on, ie must be before any autofit/layout setup. 
	 	SetVirtualDisplay ( 480, 320 ) ' Autofit magic. You may also need to set this in other target settings (html size, flash size etc).

		If IsUsingXHDResources() Then
			CongoLog( "Is using XHD resources" )
		Else If IsUsingHDResources() Then
			CongoLog( "Is using HD resources" )
		Else
			CongoLog( "Is using regular SD resources" )
		End
		
		' We check for tablet/ipad (sd and retina), iphone5 wide, we can disable borders for these [could use aspect ratio]
		Local wid:Int = Min( DeviceWidth(), DeviceHeight() ) ' note - pixel units.
		Local hgt:Int = Max( DeviceWidth(), DeviceHeight() )
		Local bg:Sprite = Null
		If (wid = 768 And hgt = 1024) Or ( wid = 1536 And hgt = 2045 ) Then
			CONGO_AUTOFIT_NOBORDERS = True ' we can fill the screen.
		Else If (wid = 320 And hgt = 568) Or (wid = 640 And hgt = 1136) Then
			CONGO_AUTOFIT_NOBORDERS = True ' we can fill the screen.
		Else
			' Regular bg and autofit area.
			 CONGO_AUTOFIT_NOBORDERS = False
		End
		
	    ' create and set our starting layer
 	    CongoApp.SetScreenColor( 0, 0, 0 ) 
		Local al:AppLayer = New MainMenuLayer( VDeviceWidth(), VDeviceHeight() )
	  	CongoApp.SetCurrentLayer( al )
	    
	    Return 0
	    
	End

End
