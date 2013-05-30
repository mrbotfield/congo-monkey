' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.
' Simplebenchmark - Congo sample app.

' Touch/press to add more sprites. Run in Release mode for accurate fps testing.

Strict

#IOS_RETINA_ENABLED=False
#IOS_ACCELEROMETER_ENABLED=False

Import mojo
Import congo

Function Main:Int()

	' can overide congo settings here
	congosettings.CONGO_ENABLE_HD_IMAGES = False	' currently using sd only for this test.
	congosettings.CONGO_SD_FOLDER = ""
	
	New MyApp
	Return 0
	
End

Class MyApp Extends CongoApp
	
	Field  rtimer:Int
	Field  rframes:Int
	Global rfps:Int
	
	Method OnCreate:Int()
	
		Super.OnCreate() ' *Required* for CongoApps.
		CongoLog( "Congo example OnCreate" )
		
	  	SetUpdateRate (60)
	  	CongoLog( "Device size " + DeviceWidth() + " x " + DeviceHeight() + " (pixel units)" ) 
	 	SetVirtualDisplay ( 320, 240 ) ' (wont use hd resources)
	 	
	 	#If CONFIG="debug"
		CongoLog( "*** Debug mode. For accurate benchmarking use Release mode *** " )
	 	#End
	     
	    ' create and set our starting layer 
	  	CongoApp.SetCurrentLayer( New MainLayer( VDeviceWidth(), VDeviceHeight() ) )
	    
	    Return 0
	    
	End
	
	' (Dev note, we measure 'render-time' but Monkey can actually skip OnRender internally to do OnUpdate loops).
	Method OnRender:Int()
	
		Super.OnRender()
		
		rframes += 1
		Local wait:Int = Millisecs() - rtimer
		If wait >= 1000 Then
			rfps = rframes
			rframes = 0
			rtimer += wait
		End
		Return 0
	End
	
End

Class MySprite Extends Sprite

	Field velx:Float
	Field vely:Float
	Field mactions:Bool = False 
	
	Method New( img:Image, hasActions:Bool = False )
	
		mactions = hasActions
		SetMainImage( img )
		
		If Not mactions Then 
			velx = Rnd(1, 2 )
			vely = Rnd( 1, 2 )
			If Rnd(1)>=0.5 velx = -velx
			If Rnd(1)>=0.5 vely = -vely
		End
		SetAngle( Rnd( 360 ) )

	End
	
	Method Update:Void( dT:Int )
	
		Super.Update( dT )
		If Not mactions Then
			SetPosition( Position.x + velx, Position.y + vely )
			If Position.x < 0 Or Position.x > VDeviceWidth() velx = -velx	
			If Position.y < 0 Or Position.y > VDeviceHeight() vely = -vely	
		End
	End

End

Class MainLayer Extends AppLayer
	
	Method New( w:Int, h:Int )
		
		Super.New( w, h )
		CongoApp.SetScreenColor( 40, 100, 40 )
		MakeSprites()

	End
	
	Method MakeSprites:Void( num:Int = 100 )
		
		Local withActions:Bool = False ' change to true to test Actions
		
		Local spr:MySprite = Null
		For Local i:Int = 0 Until num
			spr = New MySprite( CongoResourceLoader( "monkeyface.png", Image.MidHandle  ), withActions )
		
			spr.SetPosition( Rnd(VDeviceWidth()), Rnd(VDeviceWidth()) )
			spr.SetAngle( Rnd(360) )
			spr.SetScale( Rnd(0.75,1.5) )
			spr.SetOpacity( Rnd(1.0) )
			AddChild( spr )
			If withActions Then
				spr.RunAction( New ActionCombined( spr, Rnd(VDeviceWidth()), Rnd(VDeviceHeight()), Rnd(1.0), Rnd(0.75,1.5), Rnd(-360,360), 60*1000, New EaseLinear() ) )
			End
		End
	End
	
	Method Update:Void( dT:Int ) ' dT in millisecs
		
		Super.Update( dT ) ' dont forget this!
		
		If MouseHit(0) MakeSprites( 25 )
	End
	
	Method Draw:Void()
	
		Super.Draw()
		DrawText( "FPS: " + MyApp.rfps + "  Sprites: " + Self.NumChildren(), 5, 5, 0, 0 )
	End
	
End
