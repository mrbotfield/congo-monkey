' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
Import congo

' We extend Sprite to make our Sheep class. The balloon is a child sprite.
Class Sheep Extends Sprite

Private

	Field m_vely:Float = 0.0
	Field m_accely:Float = 0.0
	Field m_balloon:Sprite = Null
	Field m_isDead:Bool = False

Public
	Method New( vely:Float )
	
		Local atlas1:Image = CongoResourceLoader( "sheet1tp.png" ) ' (nb - dont using midhandle for atlases)
		Self.LoadFromTP( atlas1, "sheet1tp", "sheep.png" )

		' add a random color balloon.
		Local balloonname:String
		Local color:Int = Rnd( 0, 4 )
		Select color
			Case 0
			balloonname = "redballoon.png"
			Case 1 
			balloonname = "blueballoon.png"
			Case 2
			balloonname = "greenballoon.png"
			Case 3
			balloonname = "yellowballoon.png"
			Default
			balloonname = "redballoon.png"
		End
		
		m_balloon = New Sprite( atlas1, "sheet1tp", balloonname )	
		AddChild( m_balloon )
		m_balloon.SetPosition( 0.0, -80 ) ' above sheep.

		SetSpeed( vely )
		Reset()

	End
	
	Method IsDead:Bool() Property
		Return m_isDead
	End
	
	Method IsDead:Void( state:Bool ) Property
		m_isDead = state
	End
	
	Method GetBalloon:Sprite()
		Return m_balloon
	End

	Method Update:Void( dT:Int )

		Super.Update( dT ) ' required!

		' since we do custom update we must deal with pause too:
		If CongoApp.IsPaused() Return 
		m_vely += m_accely*dT
		Self.Position.Y += m_vely*Self.YScale * dT*(60.0/1000.0) ' (allows for variable dT)
		
	End
	
	Method SetSpeed:Void( vely:Float )
		m_vely = vely
	End
	
	Method SetAccel:Void( acc:Float )
		m_accely = acc
	End
	
	Method Reset:Void()
		
		IsDead = False ' we live again!
		SetHidden( False )
		m_balloon.SetHidden( False )
		SetOpacity( 1.0 )
		m_balloon.SetOpacity( 0.75 )
		RemoveAllActions()
		SetAngle( 0.0 )
		SetPosition( Rnd( 50, 430), Rnd( 420, 480 ) ) ' start below bottom of scene. Avoid edges, awkward for player.	
		SetScale( Rnd( 0.55, 0.85 ) )
		SetAccel( 0.0 )

	End

End
