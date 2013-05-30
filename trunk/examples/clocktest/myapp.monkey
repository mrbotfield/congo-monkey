' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.
' Clocktest - Congo sample app.

Strict

#IOS_RETINA_ENABLED=True
#IOS_ACCELEROMETER_ENABLED=False
#MOJO_IMAGE_FILTERING_ENABLED=True

Import mojo
Import congo

Function Main:Int()

	' (can overide congo settings here)
	New MyApp
	Return 0
	
End

' Clocktest - uses Sprites and Actions to display a clock.
'
'   Hands are children of the clock face, and we set rotation handles to achieve the correct rotation effect.
'   Virtual display size set via autofit. hd and xhd resources are loaded for hi-res displays.
'   The resource loader is used to store the shared images.
Class MyApp Extends CongoApp
	
	Method OnCreate:Int()
	
		Super.OnCreate() ' *Required* for CongoApps.
		CongoLog( "Congo example OnCreate" )
		
	  	SetUpdateRate (60)
	  	CongoLog( "Device size " + DeviceWidth() + " x " + DeviceHeight() + " (pixel units)" ) 
	 	SetVirtualDisplay ( 480, 320 ) ' virtual display size
	    ' create and set our starting layer 
	  	CongoApp.SetCurrentLayer( New MainLayer( VDeviceWidth(), VDeviceHeight() ) )
	    Return 0
	    
	End
	
End

Class MainLayer Extends AppLayer
	
	Method New( w:Int, h:Int )
		
		Super.New( w, h )
		CongoApp.SetScreenColor( 230, 230, 230 )
		
		Local clockface:Sprite = New Sprite( CongoResourceLoader( "clockface.png", Image.MidHandle )) 
		AddChild( clockface )
		clockface.SetPosition( 240, 150 ) ' at center. 
		
		Local hrhand:Sprite = New Sprite( CongoResourceLoader( "clockhand.png", Image.MidHandle )) 
		hrhand.SetHandle( 0, +35 ) ' hand is approx 100 tall, we'll put handle nr base.
		clockface.AddChild( hrhand )
		hrhand.SetPosition( 1, -0.5*(100-35) ) ' so the handle is at the center
		hrhand.SetScale( 1.0, 0.65 ) ' shorter.
		hrhand.SetAngle( -90 ) ' start at 3 o'clock

		Local minhand:Sprite = New Sprite( CongoResourceLoader( "clockhand.png", Image.MidHandle )) 
		minhand.SetHandle( 0, +35 )
		clockface.AddChild( minhand )
		minhand.SetPosition( 1, -0.5*(100-35) )

		Local sechand:Sprite = New Sprite( CongoResourceLoader( "clockhand.png", Image.MidHandle )) 
		sechand.SetHandle( 0, +35 )
		clockface.AddChild( sechand )
		sechand.SetPosition( 1, -0.5*(100-35) )
		sechand.SetScale( 0.5, 1.0 ) ' thinner.
		
		'clockface.SetScale( 2.0 ) ' for scale testing
		
		' set up continuous actions to move the hands	
		Local ac:Action = New ActionRotateBy( sechand, -360/60, 1000, New EaseInOutQuart(), -1 ) ' ease for a nicer movement.
		sechand.RunAction( ac )
		ac = New ActionRotateBy( minhand, -360/60, 1000*60, New EaseLinear(), -1 )
		minhand.RunAction( ac )
		ac = New ActionRotateBy( hrhand, -360/60, 1000*60*60, New EaseLinear(), -1 )
		hrhand.RunAction( ac )
	End
	
End
