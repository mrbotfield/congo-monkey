' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
Import mojo
Import congo

Import sheep
Import commonlayer
Import mainmenulayer

' main game layer
Class GameLayer Extends CommonLayer
	
Public

	Field score:Int = 0
	Field hiscore:Int = 0
	Field lives:Int = 3
	Field shots:Int = 0
	Field hits:Int = 0
	
	Field atlas1:Image = Null 					 ' main sprite sheet atlas.
	Field crosshair:Sprite = Null 				 ' player controls this
	Field muzzleflash:AnimatedSprite = Null				 ' animated gun fire effect
	Field canshoot:Bool = True
	Field launcher:Timer = New Timer( 800 ) 	 ' used to time launches of sheep.
	Field launchduration:Float = 800
	Field risespeed:Float = 1.4				 	 ' the sheep rise speed.
	Field sheep:List<Sheep> = New List<Sheep>	 ' stores all sheep. we re-use them as required.
	Field emitterpool:ParticleEmitterPool = New ParticleEmitterPool()

	' Fonts, labels
	Field font1:AngelFont = Null
	Field scorelabel:TextLabel = Null
	
	' Sounds
	Field sfx_gunburst:Sound = Null
	Field sfx_balloon:Sound  = Null
	Field sfx_reaction:Sound = Null
	Field sfx_sheep:Sound = Null
	
	' Creates the New layer with specified size (assumes virtual coords).
	Method New( w:Int, h:Int )
		
		Super.New( w, h ) ' (must be before other code)
		CongoApp.SetScreenColor( 0, 0, 0 )
		
		' Load game state
		Local nloaded:Int = GameData.getInstance().LoadAll()
		If GameData.getInstance().Exists( "hiscore" ) hiscore = GameData.getInstance().RetrieveInt( "hiscore" )
		If GameData.getInstance().Exists( "muted" ) Then
			Local muted:Bool = GameData.getInstance().RetrieveBool( "muted" )
			SoundPlayer.MuteAll( muted )
			If SoundPlayer.Muted() SetMusicVolume( 0.0 )
			If Not SoundPlayer.Muted() SetMusicVolume( 1.0 )
		End	
		
		' preload sounds 
		sfx_gunburst = CongoSoundLoader( "gunburst.wav" )
		sfx_balloon  = CongoSoundLoader( "balloon.wav" )
		sfx_reaction = CongoSoundLoader( "reaction.wav" )
		sfx_sheep    = CongoSoundLoader( "sheep.wav" )
	
		' Main texture atlas.
		atlas1 = CongoResourceLoader( "sheet1tp.png" ) ' (note - dont set midhandle for texture atlases)
		
		LoadBackground()
		SetupParticles()
		
		crosshair = New Sprite( atlas1, "sheet1tp", "crosshair.png" )	  	
	  	crosshair.SetPosition( 240, 160 )
	  	AddChildWithZOrder( crosshair, 1000 ) ' keep on top
	  	
	  	' add muzzle flash animation as child of crosshair. 4 frames, 1 row.
		Local anim:Image = CongoResourceLoader( "powflash.png" ) ' note - no mid handle for sheets. 
		muzzleflash = New AnimatedSprite( anim, 4, 4, 1 )	
	  	crosshair.AddChild( muzzleflash )
	  	muzzleflash.SetHidden()  ' hide till we shoot
	  	
		font1 = CongoFontLoader( "duedat" )
		scorelabel = New TextLabel( "SCORE 0000" + "  LIVES " + lives, font1, 240, 5, AngelFont.ALIGN_CENTER )
		AddChildWithZOrder( scorelabel, 1000 ) ' keep on top
		
		HideMouseCursor() ' special fn to hide the OS curosr (see DisplayUtils).
		CongoApp.RunTransition( New TransitionFadeOut( 1000, True ) ) ' fade-in
		
	End
	
	Method SetupParticles:Void()
	
	  	For Local i:Int = 0 Until 3
	  		Local particles:ParticleEmitter = New ParticleEmitter( 3, 10 ) ' 10 stars
			particles.InitSuperNovaExample() ' start from built-in sample	
			particles.gravity.y = +0.05 / 1000.0
			particles.startVelY = 0.0
	 		particles.startVelYVariance = 0.015
			particles.startSize = 0.5
			particles.blendMode = AlphaBlend
			particles.fadeRate = 0.25 / 1000.0
			AddChild( particles )
			emitterpool.AddEmitter( particles )
			particles.SetHidden()	
	  	End
	
	End
	
	Method LoadBackground:Void()
	
		' We check for tablet/ipad (sd and retina), iphone5 wide, else we use size bg (sd, hd, or xhd resolutions).
		Local wid:Int = Min( DeviceWidth(), DeviceHeight() ) ' note - pixel units.
		Local hgt:Int = Max( DeviceWidth(), DeviceHeight() )
		Local bg:Sprite = Null
		If (wid = 768 And hgt = 1024) Or ( wid = 1536 And hgt = 2045 ) Then
			bg = New Sprite( CongoResourceLoader( "bgipad.png", Image.MidHandle ) )
			CONGO_AUTOFIT_NOBORDERS = True ' we can fill the screen.
			CongoLog( "** Using IPAD bg")
		Else If (wid = 640 And hgt = 1136) Then
			bg = New Sprite( CongoResourceLoader( "bgiphone5w.png", Image.MidHandle ) )
			CONGO_AUTOFIT_NOBORDERS = True ' we can fill the screen.
			CongoLog( "** Using IPHONE5 bg")
		Else
			' Regular bg and autofit area.
			bg = New Sprite( CongoResourceLoader( "bg.png", Image.MidHandle ) ) 
		End
		
		AddChild( bg )
		bg.SetPosition( 240, 160 ) ' our virtual coord centre
	
	End
		
	' re-uses a sheep, or makes a new one.
	Method AddSheep:Void( id:Int = 0 )

		If lives <= 0 Return
		launcher.Duration = launchduration
		launcher.Reset() ' schedule next one
		
		Local newsheep:Sheep = Null
		For Local spr:Sheep = Eachin sheep
			If Not newsheep And spr.Hidden Then
				newsheep = spr 
				CongoLog( "Re-used a sheep" )
			End
		End
		If newsheep = Null Then ' make a new one
			newsheep = New Sheep( -risespeed )
			AddChild( newsheep )
			sheep.AddLast( newsheep )
			CongoLog( "Created a new sheep" )
		Else ' reset the old one
			newsheep.SetSpeed( -risespeed ) 
			newsheep.Reset()
		End
		
		' reorder so that large sheep are at front
		ReorderChild( newsheep, 100*newsheep.XScale )
	End
	
	Method AddToScore:Void( amnt:Int )
		If lives < 1 Return 
		score += amnt
		UpdateLabels()
	End
	
	Method LoseALife:Void()
		If lives < 1 Return
		lives -= 1
		UpdateLabels()
		If lives < 1 GameOver()
	End
	
	Method GameOver:Void()
		pausebutton.SetEnabled( False )
		Self.SetOpacity( 0.75 )
		scorelabel.SetOpacity( 1.0 )
		CongoApp.RunTransition( New TransitionStrips( 250, False, Null, 5000, "gameover" ) ) ' note delay		
		' re-use the score label. move in from bottom
		scorelabel.SetPosition( 240, 400 ) 
		Local move:Action = New ActionMoveBy( scorelabel, 0, -265, 300, New EaseInQuad() )
		scorelabel.RunAction( move )
		scorelabel.SetText( "GAME OVER!~n" )
		If score <= hiscore Then
			scorelabel.AppendText( "SCORE: " + score + "  HI-SCORE: " + hiscore )
		Else
			scorelabel.AppendText( "+++ New HI-SCORE: " + score + " +++" )
			hiscore = score
		End
		If shots > 0 scorelabel.AppendText( "~n" + "ACCURACY: " + Int(100*hits/shots) + " PERCENT" )

		' make sure hiscore and settings are stored:
		PersistGameData()
			
	End
	
	Method PersistGameData:Void()
		GameData.getInstance().StoreInt( "hiscore", hiscore )
		GameData.getInstance().StoreBool( "muted", SoundPlayer.Muted() )
		GameData.getInstance().SaveAll()
	End
	
	Method UpdateLabels:Void()
		scorelabel.SetText( "SCORE " + score + "  LIVES " + lives )
	End
	
	Method Shoot:Void()
		
		If lives < 1 Return
		SoundPlayer.Play( sfx_gunburst )
		shots += 1
		' run the muzzle flash anim
		muzzleflash.SetHidden( False )
		muzzleflash.StartAnim( 30, 1, False, False, True ) ' run anim once, hide on complete.
		muzzleflash.SetAngle( Rnd(0, 360 ) ) ' vary it for effect.
	   	muzzleflash.SetScale( Rnd( 0.4, 0.8 ) )
	   	
	   	' For efficiency we do quick coord tests before doing full distance check.
	   	For Local spr:Sheep = Eachin sheep
	   		
	   		If spr.IsDead = False And Abs( crosshair.Position.X - spr.Position.X ) < 30*spr.YScale  Then
	   
	   			' Better check to see if we shot close to the balloon or the sheep. Allow for sprite scale.
	   			Local dist:Float = Point.PointDist( crosshair.Position, spr.Position )
	   			If dist < 28 * spr.XScale Then ' Sheep hit! Stop and fade. Lose a life.
		   			CongoLog( "SHEEP HIT - dist is " + dist )
		   			Local fade:Action = New ActionFadeTo( spr, 0.0, 1000, New EaseLinear() )
		   			spr.RunAction( fade )
		   			Local spin:Action = New ActionRotateBy( spr, 360, 500, New EaseLinear(), -1 )
					spr.RunAction( spin )
					spr.GetBalloon().SetHidden( True )
		   			spr.SetAccel( 0.0 )
		   			spr.SetSpeed( 0.0 )
		   			spr.IsDead = True
		   			spr.SetAccel( +0.01 ) ' drop the sheep
		   			SoundPlayer.Play( sfx_sheep )
		   			LoseALife()
		   		Else If spr.GetBalloon().Hidden = False ' check balloon hit 
		   			Local balloonpt:Point = New Point( spr.Position.X, spr.Position.Y - 100*spr.YScale ) 
	   				dist = Point.PointDist( crosshair.Position, balloonpt )
	   				If dist < 24 * spr.XScale Then ' Balloon hit! pop it, drop sheep, add to score.
	   					CongoLog( "BALLOON HIT - dist is " + dist )
	   					hits += 1
	   					SoundPlayer.Play( sfx_balloon )
	   					spr.GetBalloon().SetHidden( True )
	   					
	   					Local particles:ParticleEmitter = emitterpool.NextEmitter()
	   					If particles Then
	   						particles.ResetAll()
	   						particles.SetScale( spr.XScale ) ' match the sheep size
	   						particles.SetHidden( False )
							particles.SetPosition( crosshair.Position )
						End
	   					spr.SetAccel( +0.01 ) ' drop the sheep (can still be hit later)
	   					AddToScore( 500 )
	   				End
	   			End 		
	   		End 
	   	End

	End
	
	Method Draw:Void()
		
		Super.Draw()
		
		' darken when paused
		If CongoApp.IsPaused() Then
			SetColor(0,0,0)
			SetAlpha( 0.25 )
			DrawRect( 0, 0, VDeviceWidth(), VDeviceHeight() )
			SetColor( 255, 255, 255 )
			SetAlpha( 1.0 )
		End
		
	End

	Method Update:Void( dT:Int )
	
		Local tman:TouchManager = TouchManager.getInstance()
	   	tman.Update( dT )
		Super.Update( dT )
		If CongoApp.IsPaused() Return ' do after Super.Update so we get button updates.
	
		launcher.Update( dT )
		If launcher.Completed() AddSheep()
		
		' gradually make game hard - decrease time to new sheep, and speed up the risespeed
		If launchduration > 100.0 launchduration -= 0.015 * dT*(60.0/1000.0)
		If risespeed < 2.5 risespeed += 0.0001 * dT*(60.0/1000.0)
	   	
		If VMouseX() > 0 crosshair.SetPosition( VMouseX(), VMouseY() ) ' (virtual coords)		  
	   	Local touch:Touch = tman.GetTouch()
	   	If touch
	   		If  canshoot And touch.touchState = TouchState.CONGO_TOUCHSTATE_DOWN Then 
	   			Shoot()
	   			canshoot = False ' prevents constant shooting.
	   		Else If touch.touchState = TouchState.CONGO_TOUCHSTATE_RELEASED Then
	   			canshoot = True
	   		End
		End
	   	
	   	If lives < 1 Return ' return if gameover
	
	   	' check for sheep reaching top, or falling off bottom. Hidden sheep will be re-used later.
		For Local shp:Sheep = Eachin sheep
			If shp.Hidden = False Then
				If shp.Position.Y < -50 Then ' sheep escaped off top
					shp.Hidden = True
					LoseALife()
					SoundPlayer.Play( sfx_reaction )
				Else If shp.GetBalloon().Hidden And shp.Position.Y > 400 Then' a rescued sheep, let it fall off
	   				shp.Hidden = True
	   			End
	   		End
	   	End
	 
	End
	
	Method TransitionCompleted:Void( id:String )		
		
		' note - be sure to check id, we have an intro transition and a gameover transition.
		CongoLog( "TransitionCompleted (gamelayer), id is " + id )
		If id = "gameover" Then
			' clear textures then make new layer
			TextureCache.getInstance().RemoveAll()
			CongoApp.SetCurrentLayer( New MainMenuLayer( VDeviceWidth(), VDeviceHeight() ), False )
		End	
	End
	
	Method LayerPaused:Void()
		RestoreMouseCursor()
		crosshair.SetHidden( True )
		Super.LayerPaused()
	End
	
	Method LayerResumed:Void()
		HideMouseCursor()
		crosshair.SetHidden( False )
		Super.LayerResumed()
	End
	
End
