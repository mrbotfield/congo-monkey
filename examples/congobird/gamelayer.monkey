' (c) Barry R Smith 2014. This code is released under the MIT License - see LICENSE.txt.
' Congo Bird - Congo sample app.

Strict
Import mojo
Import congo

Class GameItemType
	Global WALLGAP:Int  = 1	
	' (can add more items here. Wall items have id < 100)
End

Class GameLayer Extends AppLayer 
	
Public
	Field player:AnimatedSprite		' animated bird sprite
	Field vely:Float = 0.0
	Field score:Int = 0
	Field hiscore:Int = 0
	Field crashed:Bool = False
	Field started:Bool = False
	Field gravity:Float = 15.0 		' low gravity = floaty, more time to react.
	Field flappy:Float = 0.5 		' amount each flap pushes up. Adjust along with gravity.
	Field speed:Float = 2.5			' horizontal scrolling speed, set in RestartGame().
	Field gapsizey:Float = 440.0	' vertical gap between mid pts of barriers (virtual coords).
	Field gapsizex:Float = 192.0 	' horizontal spacing between barriers (virtual coords). Can adjust.
	Field wallimagehgt:Float = 268.0 ' fixed, depends on our graphic.
	Field touchhold:Bool = False 	' used for detecting tap versus hold of button.
	Field prevwitem:Sprite = Null 	' used for placing new wall items, see UpdateLevel().
	Field levelitems:List<Sprite> = New List<Sprite> ' stores all the game items. See also GetGameItem().
	
	' main bg image
	Field bgw1:Sprite = Null
	Field bgw2:Sprite = Null
	Field bgwshift:Float = 0.0
	Field bgwwidth:Float = 432
	' edge bg strips.
	Field bgl1:Sprite = Null
	Field bgl2:Sprite = Null
	Field bgsshift:Float = 0.0
	Field bgswidth:Float = 427.0
	
	' fonts, labels, sounds
	Field font1:AngelFont = Null
	Field scorelabel:TextLabel = Null
	Field sfx_thud:Sound = Null
	Field sfx_flap:Sound = Null
	
	' New layer with specified size in device points (assumes autofit virtual coords).
	Method New( w:Int, h:Int)	
		Super.New( w, h ) ' (call to Super.New must be before other code)	
				
		' main scrolling bg
		bgw1 = New Sprite( CongoResourceLoader( "bgw.png", Image.MidHandle ))
		AddChildWithZOrder( bgw1, 0 )		
		bgw2 = New Sprite( CongoResourceLoader( "bgw.png", Image.MidHandle ))
		AddChildWithZOrder( bgw2, 1 )
		bgw1.SetPosition( 0, 240.0 ) 
		bgw2.SetPosition( bgwwidth, 240.0 ) 

		' scrolling edge strips.
		bgl1 = New Sprite( CongoResourceLoader( "lowedge.png", Image.MidHandle ))
		bgl2 = New Sprite( CongoResourceLoader( "lowedge.png", Image.MidHandle ))
		AddChildWithZOrder( bgl1, 12 ) ' (above backdrop image)
		AddChildWithZOrder( bgl2, 13 )
		
		' player graphics.			
		Local img:Image = CongoResourceLoader( "birdanim.png" ) ' note - no mid handle for anim/sprite sheets. 
		player = New AnimatedSprite( img, 4, 4, 1 ) ' 4 cols, 1 row = 4 frames total.
	  	AddChildWithZOrder( player, 10 ) ' (in front of bg)

		' load font, sounds.
		font1 = CongoFontLoader( "04b19" )
		scorelabel = New TextLabel( "", font1, VDeviceWidth()/2.0, 5.0, AngelFont.ALIGN_CENTER )
		AddChildWithZOrder( scorelabel, 100 ) ' (top-most item)
		sfx_thud = CongoSoundLoader( "thud.wav" )
		sfx_flap = CongoSoundLoader( "flap.wav" )
		RestartGame() ' Let's go!
	End
	
	' Make sure to reset all relevant game data here.
	Method RestartGame:Void()
		crashed = False
		started = False ' waits for player
		touchhold = False
		score = 0
		vely = 0.0
		speed = 2.5 ' reset starting speed (you could make game get faster).
		scorelabel.SetText( score )
		' remove any prev level items
		If levelitems.Count() > 0 Then
			For Local item:Sprite = Eachin levelitems
				Self.RemoveChild( item )
			Next
		End
		levelitems = New List<Sprite>  ' can now start with a new empty list, discards prev list.
		scorelabel.SetPosition( VDeviceWidth()/2.0, 5.0 )
		player.SetPosition( 70.0, 130.0 )
		player.SetAngle( 0.0 )
		player.StartAnim( 60, -1, False, True ) ' looping animation frames.
		' before player starts game, show a repeating tween effect on bird.
	  	Local ac1:Action = New ActionMoveBy( player, 0.0, +20.0, 600, New EaseInOutQuad() )
		Local ac2:Action = New ActionMoveBy( player, 0.0, -20.0, 600, New EaseInOutQuad() )
		Local seq:Action = New ActionSequence( [ ac1, ac2 ], player, -1 )
		player.RunAction( seq )
	End
	
	' returns a game item. Re-uses one if possible (good practise to not use new/delete every time).
	Method GetGameItem:Sprite()
		Local item:Sprite
		If levelitems.Count() > 0 And levelitems.First().Position.x < -200.0 Then ' gone off left of screen.
			item = levelitems.RemoveFirst()
			item.RemoveAllChildren() 
		Else
			item = New Sprite() ' (will set image later)
			AddChild( item ) '  (only required if its a new sprite -- don't add children twice!)
		End
		Return item
	End
	
	' Adds new game item to the level and returns it. You could add other item types here if you wish.
	Method AddGameItem:Sprite( type:Int )
		CongoLog( "AddGameItem - type " + type + ". Tot items currently " + levelitems.Count() )
		Local item:Sprite = GetGameItem()
		item.CustomId = type ' stores the type - we might want different collision code for each item etc.
		' we must reset all data since item may be re-used
		item.CustomFlag = False 
		item.SetScale( 1.0 )
		item.SetHidden( False )
		Select type
			Case GameItemType.WALLGAP ' gap item - a lower rock with an upper child item.
				item.SetMainImage( CongoResourceLoader( "barrier.png", Image.MidHandle ))
				Self.ReorderChild( item, 1 )
				Local top:Sprite = New Sprite( CongoResourceLoader( "barrier.png", Image.MidHandle ))
				top.YScale = -1.0 ' flip the image
				item.AddChild( top ) ' note, is a child of main item
				top.SetPosition( 0.0, -gapsizey ) ' (position is relative to parent)
			Default
			Error( "wrong type in AddGameItem " + type )
		End
		levelitems.AddLast( item )
		Return item
	End
	
	Method Draw:Void()
		Super.Draw()

		' Some Debug info:
		SetColor( 0, 0, 255 )
		DrawBox( New Rect( 0, 0, VDeviceWidth(), VDeviceHeight() )) ' box around *virtual* area.
		SetColor( 255, 255, 255 )
		DrawText( "Congo Demo", 10, 10 )
		DrawText( "Size (px): " + DeviceWidth() + " " + DeviceHeight(), 10, 440 )
	'	Local aspect:Float = DeviceAspectRatio()
		DrawText( "Asp ratio: " + String( DeviceAspectRatio() )[..5], 310, 460, 1.0, 0.5 )
		If IsUsingXHDResources() Then
			DrawText( "XHD Resources", 10, 460 )
		Else If IsUsingHDResources() Then
			DrawText( "HD Resources", 10, 460 )
		Else
			DrawText( "SD Resources", 10, 460 )
		End
		If CONGO_AUTOFIT_NOBORDERS = False DrawText( "(Letterboxed)", 310, 440, 1.0, 0.5 )
	End
	
	Method Update:Void( dT:Int )
		Super.Update( dT ) ' required - the super class deals with child updates etc.		
		UpdateLevel( dT )  ' does main level item update function (see below).		
	
		' scrolling bg and edge sprites
		bgwshift -= 0.015*Float(dT)*speed ' 1/4 speed of main item movement
		' Need to allow for 1/2 image width + possible border pixels, depending on device display.
		If bgwshift < -235.0 bgwshift += bgwwidth
		bgw1.SetPosition( bgwshift, 240.0 ) 
		bgw2.SetPosition( bgwshift +bgwwidth -1.0, 240.0 )  ' (the -1.0 prevents seam showing).
		' lower edge bg strip. Covers bottom edge of virtual area.
		bgsshift -= 0.06*Float(dT)*speed ' same speed as item movement
		If bgsshift < -235.0 bgsshift += bgswidth
		bgl1.SetPosition( bgsshift, 510.0 ) 
		bgl2.SetPosition( bgsshift + bgswidth -1.0, 510.0 ) ' (the -1.0 prevents seam showing).

		' player input: tap/click (or space bar) to fly! (touch 0 is also mouse click).
		If Not crashed And ( TouchDown(0) Or KeyDown( KEY_SPACE ) )
			If Not started Then
				started = True
				scorelabel.SetText( score )
				player.RemoveAllActions() ' don't want the initial bird actions now.
			End
			If touchhold = False Then 
				vely = -flappy*gravity ' (these gameplay constants can be adjusted, see top of file).
				SoundPlayer.Play( sfx_flap )
				touchhold = True 
			End	
		Else
			touchhold = False
		End

		' update velocity, and checks for game area limits.
		If started Then 
			vely += 0.001*Float(dT)*gravity ' gravity effect.
			player.Position.y += 0.06*Float(dT)*vely ' (note - allows for framerate change by scaling with dT).
		End
		If player.Position.y < 20.0 player.Position.y = 20.0 ' stop player going off top...
		If player.Position.y > ( VDeviceHeight() - 5.0 ) ' hit ground - game over!
			PlayerCrashed()
			speed = 0.0 ' stop items scrolling
			player.Position.y = VDeviceHeight() - 5.0
		Else ' tilts bird sprite depending on velocity
			Local tilt:Float = 0.0
			If vely < 0 Then
				tilt = -vely *1.5
			Else
				tilt = -Abs(vely*vely) *0.4  ' tilt more when falling fast!
			End
			player.SetAngle( Max( tilt, -80.0 )) ' (prevent rotate beyond vertical)
		End
	End
	
	' moves items, checks for collisions, and adds new items to level.
	Method UpdateLevel:Void( dT:Int )
		For Local item:Sprite = Eachin levelitems
			item.Position.x -= 0.06*Float(dT)*speed ' (note, also takes account of framerate via dT)
			If item.CustomId = GameItemType.WALLGAP Then
				If Not crashed And Abs( player.Position.x - item.Position.x ) < 35 And 
						( item.Position.y - player.Position.y < (wallimagehgt/2.0 +10) Or item.Position.y - player.Position.y > gapsizey-(wallimagehgt/2.0 +10) ) Then
					PlayerCrashed() ' hit a barrier - game over!
				End
			' (if you add new item types, can check collision here)
			End
			' see if we've passed thru any new gaps - player scores a point.
			If Not crashed And item.CustomId = GameItemType.WALLGAP And item.CustomFlag = False And player.Position.x - item.Position.x > 40 Then
				item.CustomFlag = True ' (flag it so we dont count it again)
				score += 1
				scorelabel.SetText( score )
			End
		End
		
		' Adds new game items as required.
		If started Then ' (wait until player triggers start)	
			If levelitems.Count() = 0 Or prevwitem = Null Then ' add a first item
				Local item:Sprite = AddGameItem( GameItemType.WALLGAP )
				item.SetPosition( VDeviceWidth() + 200.0, 450.0 )
				prevwitem = item
				Return
			Else If levelitems.Last().Position.x < VDeviceWidth() + 150.0 Then ' last item is close - add another.
				Local item:Sprite = AddGameItem( GameItemType.WALLGAP )
				item.SetPosition( prevwitem.Position.x + gapsizex, prevwitem.Position.y + Rnd( -300.0, 300.0 ) ) ' random step up/down from previous barrier.
				item.Position.y = Clamp( item.Position.y, 350.0, 540.0 ) ' clamp to vertical game area limits.
				prevwitem = item
			End
		End
	End
	
	Method PlayerCrashed:Void()
		If crashed Return
		crashed = True
		SoundPlayer.Play( sfx_thud )
		player.PauseAnim()
		' check hiscore. 
		If score > hiscore Then 
			hiscore = score
			scorelabel.SetText( "New Best! " + hiscore )
		Else
			scorelabel.SetText( "Score: " + score + " ~nBest: " + hiscore )
		End
		 ' does delayed call to restart game. (Note the action Id).
		Local restart:Action = New ActionDelay( Self, 2500, 1, 1 )
		Self.RunAction( restart )
	End
	
	Method ActionCompleted:Void( actionId:Int )
		' you could go to a main menu here, but we'll just restart game.
		If actionId = 1 RestartGame() 
	End

End
