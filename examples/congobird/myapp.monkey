' (c) Barry R Smith 2014. This code is released under the MIT License - see LICENSE.txt.
' CongoBird - Congo sample app.

Strict ' (good practise to use monkey's strict mode)
Import mojo
Import congo
Import gamelayer

Function Main:Int()

	' Can overide congo defaults here.
	CONGO_SD_FOLDER = "sd"
	CONGO_HD_FOLDER = "hd"
	CONGO_XHD_FOLDER = "xhd"
	CONGO_AUDIO_FOLDER = "audio"
	
	CONGO_HD_SUFFIX = ""
	CONGO_XHD_SUFFIX = ""
	CONGO_HD_DEVICE_WIDTHREQ = 640
	CONGO_XHD_DEVICE_WIDTHREQ = 1280
	CONGO_ENABLE_HD_IMAGES  = True 
	CONGO_ENABLE_XHD_IMAGES = True
	
	New MyApp
	Return 0
	
End
Class MyApp Extends CongoApp

Public
	
	Method OnCreate:Int()
		
		CongoLog( "In MyApp OnCreate" )
		Super.OnCreate() ' *Required* for CongoApps.
		
		SetUpdateRate ( 60 )
		CongoLog( "Actual device size (pixels): " + DeviceWidth() + " x " + DeviceHeight() )
		Local aratio:Float = DeviceAspectRatio()
		' Our graphics are made to support 4:3 to 16:9 aspect ratios. If the display is outside
		' this then we'll letterbox it, rather than see graphics outside the game area.
		If aratio < 1.33 Or aratio > 1.78 Then
			CongoLog( "Aspect ratio outside those supported, will letterbox " + aratio )
			CONGO_AUTOFIT_NOBORDERS = False
		Else
			CongoLog( "Aspect ratio supported: " + aratio )
			CONGO_AUTOFIT_NOBORDERS = True
		End
	
		If IsUsingXHDResources() Then
			CongoLog( "XHD - IsUsingXHDResources" )
		Else If IsUsingHDResources() Then
			CongoLog( "HD - IsUsingHDResources" )
		End

		SetVirtualDisplay ( 320, 480 ) ' Autofit magic
		
		 ' basic way to randomise seed using clock - do before creating game layer!
		Local date:Int[] = GetDate()
		Seed = date[4]*100 + date[5]*10 + date[6]
		
		CongoApp.SetScreenColor( 0,0,0 )
	  	CongoApp.SetCurrentLayer( New GameLayer( VDeviceWidth(), VDeviceHeight() ) )

		Return 0
	
	End

End
