' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict

Import congo.physicssprite
Import congo.physicsworld

Import ball

Class ContactListener Extends b2ContactListener
	
	
	Method BeginContact:Void( contact:b2Contact ) 

		' (Note - as per box2d manual, dont make a copy of pointers sent here, use copies if req.)
		
		'CongoLog( "ContactListener - BeginContact" )
		
		Local fixtureA:b2Fixture = contact.GetFixtureA()
		Local fixtureB:b2Fixture = contact.GetFixtureB()
		If Not fixtureA Or Not fixtureB Return
		
		Local bodyA:b2Body = fixtureA.GetBody()
		Local bodyB:b2Body = fixtureB.GetBody()
		
		' Get the physicssprite by casting the userdata. We cant assume the order of objects in a contact.
		' Note - walls arent physicssprites so wont have userdata.
		If bodyA And bodyB 
		
			Local pspriteA:PhysicsSprite = Null
			Local pspriteB:PhysicsSprite = Null

			If bodyA.GetUserData() pspriteA = PhysicsSprite( bodyA.GetUserData() ) 
			If bodyB.GetUserData() pspriteB = PhysicsSprite( bodyB.GetUserData() ) 
			
			' flip order so ball is always spriteA. Other item could be ball or wall etc.
			If pspriteB And pspriteB.objType = 1 Then
				Local tmpb:PhysicsSprite = pspriteB
				pspriteB = pspriteA
				pspriteA = tmpb
			End
			
			Local theball:Ball = Null
			If pspriteA And pspriteA.objType = 1 theball = Ball(pspriteA)
			
			' tell the ball it had a collision
			If theball theball.HandleAddContact( pspriteB ) 

		End
	
	End
	
End
