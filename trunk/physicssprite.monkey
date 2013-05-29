#Rem monkeydoc Module congo.physicssprite
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
Import congo.sprite
Import congo.physicsworld

Import box2d.common
Import box2d.dynamics

#Rem monkeydoc
A sprite with built-in physics behaviour. Requires box2d module.
See also: PhysicsWorld class.

** THIS CLASS IS UNDER DEVELOPMENT ** - it is useable but has limited functionality.

Todo - private fields, properties.
#End
Class PhysicsSprite Extends Sprite
	
	#Rem monkeydoc
	The box2d body.
	#End
	Field m_body:b2Body = Null 

	#Rem monkeydoc
	User-defined type.
	You can use this field to label different game objects (helpful when casting etc).
	#End
	Field objType:Int = 0

	#Rem monkeydoc
	User-defined name. See also objType.
	You can use this field to label different game objects (helpful when casting etc).
	#End
	Field objName:String
	
	#Rem monkeydoc
	Set this to False to prevent the Sprite rotating to match the underlying box2d body.
	#End
	Field doRotateSprite:Bool = True ' ie rotates sprite to match physics option. Disable for fixed or custom rotation.
	
	#Rem monkeydoc
	Main Update function. The Sprite is moved and (optionally) rotated to match the underlying box2d body.
	Derived classes can override this if required.
	#End
	Method Update:Void( dT:Int )
	
		Super.Update( dT )
		
		Self.Position.X = m_body.GetPosition().x*PhysicsWorld.BOX2D_PTM
		Self.Position.Y = m_body.GetPosition().y*PhysicsWorld.BOX2D_PTM
		
		If doRotateSprite Self.Angle = -1.0 * 57.29577951 * m_body.GetAngle() ' (converts radians to degrees)
			
	End
	
	#Rem monkeydoc
	Gives the body a kick of linear velocity in the specified direction.
	Will wake-up the body if it was sleeping.
	#End
	Method AddVelocity:Void( vel:b2Vec2 )
	
		Local cur:b2Vec2 = m_body.GetLinearVelocity()
		cur.x += vel.x
		cur.y += vel.y
		m_body.SetAwake( True ) ' required
		m_body.SetLinearVelocity( cur )
		
	End
	
	Method GetVelocity:b2Vec2()
		Return m_body.GetLinearVelocity()
	End
	
	#Rem monkeydoc
	Contact handler.
	Derived classes can implement these as required.
	#End
	Method HandleAddContact:Void( spr:PhysicsSprite )
	
		' (nothing here - derived classes can implement).
	End
	
	#Rem monkeydoc
	Contact handler.
	Derived classes can implement these as required.
	#End
	Method HandleRemoveContact:Void( spr:PhysicsSprite )
	
		' (nothing here - derived classes can implement).
	
	End

End
