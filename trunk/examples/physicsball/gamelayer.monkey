' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
Import mojo
Import congo

Import ball
Import contactlistener

Class GameLayer Extends AppLayer
	
Public

	Field m_physicsWorld:PhysicsWorld = Null
	Field m_debugDraw:b2DebugDraw = Null
	
	' New layer with specified size in device points (assumes autofit virtual coords).
	Method New( w:Int, h:Int)
		
		Super.New( w, h ) ' (call to Super.New must be before other code)
		CongoLog( "New gamelayer" )
		
		' physics
	  	m_physicsWorld = New PhysicsWorld( New b2Vec2(0, 25) ) ' downward gravity

		Local tmpimg:Image = CongoResourceLoader( "bg.png",  Image.MidHandle )
		Local bg:Sprite = New Sprite( tmpimg )
		AddChild( bg )
		
		bg.Position.x = 550/2
		bg.Position.y = 550/2
	
		' add some balls!
		For Local i:Int = 0 To 3
			Local b:Ball = New Ball( Rnd(0, 550)/PhysicsWorld.BOX2D_PTM, Rnd(-150, -50)/PhysicsWorld.BOX2D_PTM, m_physicsWorld )
			b.AddVelocity( New b2Vec2( Rnd(-5.0, 5.0), 0.0 ) )
			AddChild( b )
		Next
		
		' builds the walls
		InitEdges()
		
		' Set the contact listener
		Local cl:ContactListener = New ContactListener()
		m_physicsWorld.GetWorld().SetContactListener( cl )
		
		' debug draw  - enable as required
	  	#If CONFIG="debug" Then
	  		m_debugDraw = m_physicsWorld.CreateDebugDraw()
	  		' can use this to see the debugdraw more clearly!
			' Self.SetOpacity( 0.5 ) 
	    #End
		
	End

	Method InitEdges:Void()
		
		Local groundBodyDef:b2BodyDef = New b2BodyDef()
		
		' Bottom edge. wider than game area so the ball can bounce off screen. Slightly below screen height, for effect.
		Local groundBox:b2PolygonShape = New b2PolygonShape()
		groundBox.SetAsEdge( New b2Vec2( -1000/PhysicsWorld.BOX2D_PTM, 570/PhysicsWorld.BOX2D_PTM ),
  							 New b2Vec2( 2000/PhysicsWorld.BOX2D_PTM, 570/PhysicsWorld.BOX2D_PTM ) )
		Local boxShapeDef:b2FixtureDef = New b2FixtureDef()
		boxShapeDef.shape = groundBox
		boxShapeDef.filter.categoryBits = 8 ' (2=player, 4=ball, 8=enemy/obstacle/wall)
		boxShapeDef.restitution = 0.0 ' (1.0 is perfect elastic bounce)
		Local groundBody:b2Body = m_physicsWorld.GetWorld().CreateBody(groundBodyDef) 
		groundBody.CreateFixture( boxShapeDef )
		
		' Left edge (off screen left, and taller than screen)
		Local leftBody:b2Body = m_physicsWorld.GetWorld().CreateBody(groundBodyDef) 
		Local leftBox:b2PolygonShape = New b2PolygonShape()
		leftBox.SetAsEdge( New b2Vec2( -400/PhysicsWorld.BOX2D_PTM, -500/PhysicsWorld.BOX2D_PTM ),
  							 New b2Vec2( -400/PhysicsWorld.BOX2D_PTM, 1000/PhysicsWorld.BOX2D_PTM ) ) 
		boxShapeDef.shape = leftBox	
		leftBody.CreateFixture( boxShapeDef )
		
		' Right edge (off screen right, and taller than screen)
		Local rightBody:b2Body = m_physicsWorld.GetWorld().CreateBody(groundBodyDef) 
		Local rightBox:b2PolygonShape = New b2PolygonShape()
		rightBox.SetAsEdge( New b2Vec2( 950/PhysicsWorld.BOX2D_PTM, -500/PhysicsWorld.BOX2D_PTM ),
  							 New b2Vec2( 950/PhysicsWorld.BOX2D_PTM, 1000/PhysicsWorld.BOX2D_PTM ) ) 
		boxShapeDef.shape = rightBox	
		rightBody.CreateFixture( boxShapeDef )
	
	End	

	Method Draw:Void()
		
		' (note - debugdraw must be done first)
		#If CONFIG="debug" Then
			m_physicsWorld.GetWorld().DrawDebugData() 
		#End
			
		Super.Draw()
		
	End
	
	Method Update:Void( dT:Int )
		
		m_physicsWorld.Update( Float(dT/1000.0) ) ' (physics update time is in seconds)
		Super.Update( dT )
		
	End

End
