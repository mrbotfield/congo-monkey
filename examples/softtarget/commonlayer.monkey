' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
Import mojo
Import congo


' Common layer with ui buttons for sound, pause etc. Base class for other app layers. 
Class CommonLayer Extends AppLayer
	
Public
	
	Field pausebutton:Button = Null
	Field soundbutton:Button = Null
	Field click:Sound = Null
	
	' New layer with specified size in device points (assumes autofit virtual coords).
	Method New( w:Int, h:Int)
		
		Super.New( w, h ) ' (must be before other code)
		CongoLog( "New commonlayer" )
		
		' load game state
		Local nloaded:Int = GameData.getInstance().LoadAll()
		If GameData.getInstance().Exists( "muted" ) Then
			Local muted:Bool = GameData.getInstance().RetrieveBool( "muted" )
			SoundPlayer.MuteAll( muted )
			If SoundPlayer.Muted() SetMusicVolume( 0.0 )
			If Not SoundPlayer.Muted() SetMusicVolume( 1.0 )
		End		
		
		click = CongoSoundLoader( "button.wav" )
		
		' Note - dont set midhandle for texture atlases. Also, Xml filename does not need extn.
		Local atlas1:Image = CongoResourceLoader( "sheet1tp.png" )
	
		Local congologo:Sprite = New Sprite( CongoResourceLoader( "madewithcongo.png", Image.MidHandle )) ' (not on atlas).
		congologo.SetPosition( 445, 303 ) ' lower-right corner.
		congologo.SetScale( 0.65 )
		congologo.SetOpacity( 0.7 )
		AddChildWithZOrder( congologo, 1000 ) ' keep on top
		
		Local tmpimg:Image = ImageFromTP( atlas1, "sheet1tp", "pause.png" )
		pausebutton = New Button( tmpimg, tmpimg, ButtonType.CONGO_BUTTONTYPE_CLICKER, "pause" )
		pausebutton.SetPosition( 12, 12 )
		tmpimg = ImageFromTP( atlas1, "sheet1tp", "soundon.png" )
	 	Local tmpimg2:Image = ImageFromTP( atlas1, "sheet1tp", "soundoff.png" )
		soundbutton = New Button( tmpimg, tmpimg2, ButtonType.CONGO_BUTTONTYPE_TOGGLE, "sound" )
		soundbutton.SetPosition( 480-12, 12 )
		AddChildWithZOrder( pausebutton, 1000 ) ' keep on top
		AddChildWithZOrder( soundbutton, 1000 )
		' make sure sound button state matches current game state
		If SoundPlayer.Muted() soundbutton.GoToFrame( 1 ) ' bit ugly, add a function in Button?
		
	End
	
	Method Draw:Void()
	
		Super.Draw()
		
		' fade-out when paused
		If CongoApp.IsPaused() Then
			SetColor(0,0,0)
			SetAlpha( 0.5 )
			DrawRect( 0, 0, VDeviceWidth(), VDeviceHeight() )
			SetColor( 255, 255, 255 )
			SetAlpha( 1.0 )
		End

	End
	
	Method ButtonActivated:Void( button:Sprite )
		
		CongoLog( "ButtonActivated (commonlayer), button name " + button.CustomName )
		If button.CustomName = "pause" Then
			If CongoApp.IsPaused() SoundPlayer.Play ( click )
			CongoApp.TogglePaused()
		Else If button.CustomName = "sound" And Not CongoApp.IsPaused() Then
			SoundPlayer.ToggleMuteAll()
			If SoundPlayer.Muted() SetMusicVolume( 0.0 )
			If Not SoundPlayer.Muted() SetMusicVolume( 1.0 )
			SoundPlayer.Play ( click )
			' save state
			GameData.getInstance().StoreBool( "muted", SoundPlayer.Muted() )
			Local result:Int = GameData.getInstance().SaveAll()
		End
				
	End
	
End
