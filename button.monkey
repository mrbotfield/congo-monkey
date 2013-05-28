#Rem monkeydoc Module congo.button
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
Import mojo

Import congo.animatedsprite
Import congo.rect
Import congo.touchmanager
Import congo.soundplayer

#Rem monkeydoc
Definitions of Button types.
#End
Class ButtonType
	#Rem monkeydoc
	Defines a regular 'clickable' button, activated on release.
	#End
	Global CONGO_BUTTONTYPE_CLICKER:Int		= 0 

	#Rem monkeydoc
	Same as a 'clicker' button but is activated on press rather than release.
	#End
	Global CONGO_BUTTONTYPE_PRESSER:Int 	= 1

	#Rem monkeydoc
	Defines a button that stays down when pressed.
	#End
	Global CONGO_BUTTONTYPE_ONCE:Int		= 2

	#Rem monkeydoc
	Defines an on/off toggle button.
	#End
	Global CONGO_BUTTONTYPE_TOGGLE:Int		= 3	

End

#Rem monkeydoc
A UI button class, with various click/toggle modes.

** THIS CLASS IS UNDER DEVELOPMENT ** - it is useable but has limited functionality.

The Parent (or other specified target) receives a ButtonActivated call. Use customId or customString to identify buttons.

Dev note: we use the multi-frame Image feature of AnimatedSprite to store the up/down images.
Dev note: currently buttons do not work if they are children of other items (hitbox needs adjusting for parent).
#End
Class Button Extends AnimatedSprite

Private
	Field m_hitbox:Rect = Null ' cached on first Update. Assumes we dont move though!
	Field m_stayDown:Bool = False
	Field m_type:Int = ButtonType.CONGO_BUTTONTYPE_CLICKER 
	Field m_down:Bool = False 
	Field m_enabled:Bool = True
	Field m_target:DisplayItem = Null
	Field m_sound:Sound = Null
	
Public

	#Rem monkeydoc
	Creates a button using the provided images. normalImg and downImg can be the same Image if required.
	The name can be used to identify the button when receiving calls to ButtonActivated. If Target is
	left as Null then the Parent will receive the ButtonActivated call, or you can choose a different DisplayItem target.

	Tip: for a simple press effect, try setting the downImg Sprite handles to +1 pixel (normalImg and downImg must be different Images).
	#End
	Method New( normalImg:Image, downImg:Image, type:Int = ButtonType.CONGO_BUTTONTYPE_CLICKER, name:String ="", target:DisplayItem = Null, sound:Sound = Null )
	
		m_type = type	
		Self.CustomName = name
		m_target = target
		SetMainImage( normalImg )
		SetImage( downImg, 1 )
		SetActivateSound( sound )
		PauseAnim() ' we control the frames manually

	End

	#Rem monkeydoc	
	Use this to disable the button; no image changes or activation calls will occur. Hiding a button has the same effect.
	#End
	Method SetEnabled:Void( state:Bool )
	
		m_enabled = state
	
	End

	#Rem monkeydoc
	Sets a default sound for when the button is activated.
	#End
	Method SetActivateSound:Void( snd:Sound )
	
		m_sound = snd

	End

	#Rem monkeydoc
	Returns True if the button is currently enabled.
	#End
	Method IsEnabled:Bool()
	
		Return m_enabled
		
	End

	#Rem monkeydoc
	Returns True if currently in the 'down' state (applies to all button types). Usually you would use 
	ButtonActivated() to detect button activations, but you may still want to read the state.
	#End
	Method IsDown:Bool()
	
		If curImageNum = 0 Return False
		Return True 
	
	End
	
	#Rem monkeydoc
	Overrides the Super class Update function. Assumes Touchmanager is updated.
	#End
	Method Update:Void( dT:Int )
	
		Super.Update( dT )
		
		If Not m_enabled Or Hidden() Return		
		
		Local tman:TouchManager = TouchManager.getInstance()
		
		If m_down And m_type = ButtonType.CONGO_BUTTONTYPE_ONCE Return
		
		If Not m_down And tman.touches[0].touchState = TouchState.CONGO_TOUCHSTATE_DOWN Then
			
			' do quick test, can return if touch is not near us
			If Point.ManHatDist( tman.touches[0].touchStartPos, Self.Position ) > 
						XScale*BoundingBoxHeight() + YScale*BoundingBoxWidth() Then
				Return
				
			End
			
			m_hitbox = GetBoundingRect()

			If Rect.Contains( m_hitbox, tman.touches[0].touchStartPos ) Then

				m_down = True
				If m_type = ButtonType.CONGO_BUTTONTYPE_TOGGLE Then
					If CurImageNumber = 0 Then
						GoToFrame( 1 )
					Else If CurImageNumber = 1 Then
						GoToFrame( 0 )
					End
				Else
					GoToFrame( 1 )
				End
				
				' we're activated
				If m_type = ButtonType.CONGO_BUTTONTYPE_PRESSER Or 
						m_type = ButtonType.CONGO_BUTTONTYPE_ONCE  Activate()
				End
			
				Else If m_down And tman.touches[0].touchState = TouchState.CONGO_TOUCHSTATE_RELEASED Then
		
					m_down = False
					If Rect.Contains( m_hitbox, tman.touches[0].touchEndPos ) And 
						Rect.Contains( m_hitbox, tman.touches[0].touchStartPos ) Then
				
						If m_type = ButtonType.CONGO_BUTTONTYPE_TOGGLE Then
						' (do nothing to img, we toggled it on press)
						Activate()
						Else If m_type = ButtonType.CONGO_BUTTONTYPE_CLICKER Then 
						GoToFrame( 0 )
						Activate()
						Else If m_type = ButtonType.CONGO_BUTTONTYPE_PRESSER Then 
						GoToFrame( 0 )
					End				
				Else ' release was ouside box, cancel it.
					GoToFrame( 0 )
			End
		End
		
	End 

	#Rem monkeydoc
	Gets called from Update when the button is activated. ButtonActivated() is then called on the parent or specified target. 
	The Touch is reset to avoid repeat processing. 
	#End
	Method Activate:Void()

		If m_sound SoundPlayer.Play ( m_sound )

		If m_target Then
			m_target.ButtonActivated( Self )
			CongoLog( "ButtonActivated to custom target" )
		Else If Parent() Then
			Parent.ButtonActivated( Self )
			CongoLog( "ButtonActivated to parent target" )
		End
		
		' reset the touch so we dont pass it on to another event
		TouchManager.getInstance().touches[0].Reset()
	
	End
	
End
