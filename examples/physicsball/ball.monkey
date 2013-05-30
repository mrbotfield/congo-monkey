' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict

Import congo.physicssprite
Import congo.physicsworld

Class Ball Extends PhysicsSprite
	
	Field m_fixture:b2FixtureDef ' (sometimes need this if using collision filtering).
	Field m_physicsWorld:PhysicsWorld = Null
	
	Method New( xpos:Float, ypos:Float, world:PhysicsWorld )
	
		CongoLog( "In Ball constr" )
		m_physicsWorld = world
		
		' (bit ugly, but we passed in phys coords)
		SetPosition( xpos*PhysicsWorld.BOX2D_PTM, ypos*PhysicsWorld.BOX2D_PTM )
		
		Local tmpimg:Image = CongoResourceLoader( "ballf.png",  Image.MidHandle )
		Self.SetMainImage( tmpimg )
		
		Local circleShape:b2CircleShape = New b2CircleShape()
		circleShape.m_radius = 40.0/PhysicsWorld.BOX2D_PTM
		Local circleFixture:b2FixtureDef = New b2FixtureDef()
		circleFixture.filter.categoryBits = 4 ' just an example (2=player, 4=ball, 8=enemy/obstacle/wall)
		circleFixture.shape = circleShape
		circleFixture.density = 10.0
		circleFixture.friction = 1.0
		circleFixture.restitution = 0.8
		
		Local bdef:b2BodyDef = New 	b2BodyDef()
		bdef.type = b2Body.b2_Body
		bdef.position.Set( xpos, ypos )
		bdef.linearDamping = 0.0
		bdef.angularDamping = 0.0
		' bdef.allowSleep = False ' can disable this to avoid any sleep issues, ball getting frozen etc.
		
		m_body = world.GetWorld().CreateBody(bdef)	
		m_body.CreateFixture( circleFixture );
		m_body.SetUserData(Self) 'required for contact listener
		Self.objType = 1 ' we'll use this to identify the ball in collisions
		Self.CustomName = "ball" ' could also use this name
		
	End	
	
	Method Update:Void( dT:Int )
	
		Super.Update( dT )
	
	End

	Method HandleAddContact:Void( spr:PhysicsSprite )
	
		' For physicssprites we check the custom Type. Note, edges arent physicssprites, so they send Null.
		If spr And spr.objType = 1 CongoLog( "BALL to BALL collision" )
		If Not spr CongoLog( "BALL to EDGE collision" )
		
	End
	
	Method HandleRemoveContact:Void( spr:PhysicsSprite )
	
	End

End

