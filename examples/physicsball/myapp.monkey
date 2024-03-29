' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.
' Physicsball - Congo sample app.
'
' Run in Debug mode to see collision log output.

Strict

Import mojo

Import congo
Import gamelayer

Function Main:Int()

	' can overide congo defaults here.
	CONGO_HD_SUFFIX = ""
	CONGO_XHD_SUFFIX = ""
	CONGO_ENABLE_HD_IMAGES = True 
	CONGO_ENABLE_XHD_IMAGES = False
	
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
	 	SetVirtualDisplay ( 550, 550 ) ' Autofit magic. You may also need to set this in other target settings (html size, flash size etc).

		If IsUsingXHDResources() Then
			CongoLog( "Is using XHD resources" )
		Else If IsUsingHDResources() Then
			CongoLog( "Is using HD resources" )
		Else
			CongoLog( "Is using regular SD resources" )
		End
		
	    ' create and set our starting layer
	    CongoApp.SetScreenColor( 0, 0, 0 ) 
		Local al:AppLayer = New GameLayer( VDeviceWidth(), VDeviceHeight() )
	  	CongoApp.SetCurrentLayer( al )
	    
	    Return 0
	    
	End

End
