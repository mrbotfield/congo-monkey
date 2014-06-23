Strict
Import mojo
Import congo

Import commonlayer
Import gamelayer

' Main menu class, with button to start game. 
Class MainMenuLayer Extends CommonLayer
	
Public
	
	Field playbutton:Button = Null
	Field moregames:Button = Null
	Field clickfx:Sound = Null
	
	' New layer with specified size in device points (assumes autofit virtual coords).
	Method New( w:Int, h:Int)
		
		Super.New( w, h ) ' (must be before other code)
		CongoLog( "New mainmenulayer" )
		
		CongoApp.SetScreenColor( 110, 160, 120 )
		
		' preload sounds, start music.
		clickfx = CongoSoundLoader( "button.wav" )
		PlayMusic( GetMusicResourceName( "marching.mp3" ) )

		' hide pause button for menu
		pausebutton.SetHidden( True )

		' Note - dont set midhandle for texture atlases. Also, Xml filename does not need extn.
		Local atlas1:Image = CongoResourceLoader( "sheet1tp.png" )
	
		' Logo. Make it gently rock back and forth.
		Local logo:Sprite = New Sprite( atlas1, "sheet1tp", "titlelogo.png" )
		AddChild( logo )
		logo.SetPosition( 240, 140 )
		logo.SetAngle( +5 )
		Local rot1ac:Action = New ActionRotateTo( logo, -5, 5000, New EaseInOutQuad() )
		Local rot2ac:Action = New ActionRotateTo( logo, +5, 5000, New EaseInOutQuad() )
		Local rocker:Action = New ActionSequence( [ rot1ac, rot2ac ], logo, -1 ) ' endless repeat		
		logo.RunAction( rocker )
		
		' add a sheep - just for fun. Rotate and enlarge - a good test...
		Local sheep:Sprite = New Sprite( atlas1, "sheet1tp", "sheep.png" )
		sheep.SetPosition( -5, 260 ) ' off left side
		' tweak for wide iphone 5 :
		Local wid:Int = Min( DeviceWidth(), DeviceHeight() ) ' note - pixel units.
		Local hgt:Int = Max( DeviceWidth(), DeviceHeight() )
		If (wid = 320 And hgt = 568) Or (wid = 640 And hgt = 1136) sheep.SetPosition( -25, 260 )
		sheep.SetAngle( -60 )
		sheep.SetScale( 1.3 ) 
		AddChild( sheep )
		
		' ... and animate eyelids. Uses a non-center handle to create the open/close stretch effect.
		Local eyelids:Sprite = New Sprite( atlas1, "sheet1tp", "eyelids.png" )
		sheep.AddChild( eyelids ) 		' note, child of sheep sprite.
		eyelids.SetPosition( 0, -25 ) 	' Relative to parent. ie top middle of sheep (virtual coords).
		
		eyelids.SetHandle( 0, -4 ) ' top handle.  Virtual coords. Congo handles are relative to centre (unlike Monkey Image handles)
		eyelids.YScale = 0.0 		' start open.
		Local delay:Action = New ActionDelay( eyelids, 1000 ) ' wait a second
		Local sc1:Action = New ActionScaleTo( eyelids, 1.0, 1.0, 250, New EaseLinear() ) ' open eyes
		Local sc2:Action = New ActionScaleTo( eyelids, 1.0, 0.0, 250, New EaseLinear() ) ' close eyes
		Local delay2:Action = New ActionDelay( eyelids, 1000 )
		Local blink:Action = New ActionSequence( [ delay, sc1, sc2, delay2 ], eyelids, -1 ) ' continuous blinking.
		eyelids.RunAction( blink )
		
		' buttons
		Local upimg:Image = ImageFromTP( atlas1, "sheet1tp", "playup.png" )
		Local downimg:Image = ImageFromTP( atlas1, "sheet1tp", "playdown.png" )
		playbutton = New Button( upimg, downimg, ButtonType.CONGO_BUTTONTYPE_CLICKER, "play" )
		playbutton.SetActivateSound( clickfx )
		AddChild( playbutton )
		playbutton.SetPosition( 240, 220)
		
		' (button image isnt on main atlas. no big reason, but it is easier to swap out this way).
		upimg = CongoResourceLoader( "moregames.png", Image.MidHandle ) ' mid handle image.
		downimg = upimg
		moregames = New Button( upimg, downimg, ButtonType.CONGO_BUTTONTYPE_CLICKER, "moregames" )
		moregames.SetActivateSound( clickfx )
		AddChild( moregames )
		moregames.SetPosition( 240, 360 )
		moregames.SetScale( 0.5 )
		Local delayb:Action = New ActionDelay( moregames, 2000 ) ' wait
		Local reveal:Action = New ActionMoveBy( moregames, 0.0, -55.0, 250, New EaseInQuad() )
		Local butact:Action = New ActionSequence( [ delayb, reveal ], moregames )
		moregames.RunAction( butact )
		
		RestoreMouseCursor() ' since we hide it during game.
		
		CongoApp.RunTransition( New TransitionFadeOut( 500, True ) ) ' fades in (reversed)
		
	End
	
	Method Update:Void( dT:Int )

		Local tman:TouchManager = TouchManager.getInstance() 
	   	tman.Update( dT ) ' required - buttons use the touchmanager.
		Super.Update( dT )

	End
	
	Method ButtonActivated:Void( button:Sprite )
	
		Super.ButtonActivated( button ) ' common layer checks ui buttons
		CongoLog( "ButtonActivated (mainmenu), button id " + button.CustomName )
	
		If button.CustomName = "moregames" Then
			OpenUrl( "http://goodreactions.com/" )
		Else If button.CustomName  = "play" Then
			If CongoApp.RunTransition( New TransitionGridSquares( 500, False, New EaseLinear(), 0, "play" ) ) Then
				playbutton.SetEnabled( False )
				StopMusic()
			End
		End
		
	End
	
	Method TransitionCompleted:Void( id:String )		
		CongoLog( "TransitionCompleted (mainmenu), id is " + id )
		If id = "play" Then
			' clear textures then make new layer
			TextureCache.getInstance().RemoveAll()
			CongoApp.SetCurrentLayer( New GameLayer( VDeviceWidth(), VDeviceHeight() ), False )
		End
		
	End
	
End
