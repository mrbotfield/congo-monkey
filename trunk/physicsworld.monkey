#Rem monkeydoc Module congo.physicsworld
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict

Import box2d.common
Import box2d.dynamics
Import congo.textutils

#Rem monkeydoc
Wrapper for the main physics world. Requires box2d module.

Dev note: we used basic variable-rate timestep integration here - we should add a fixed rate option, which is more reliable 
since it is decoupled from our main framerate target.

Todo: add some functions For creating basic shapes (Factory?).
#End
Class PhysicsWorld

	#Rem monkeydoc
	Box2d pixels-to-meters ratio.
	#End
	Global BOX2D_PTM:Float = 32.0
	
	#Rem monkeydoc
	The actual b2World object.
	#End
	Field m_world:b2World = Null 
	
	#Rem monkeydoc
	Simulation parameters - change as required (refer to the the box2d docs).
	#End
	Field m_velocityIterations:Int = 8
	#Rem monkeydoc
	Simulation parameters - change as required (refer to the the box2d docs).
	#End
	Field m_positionIterations:Int = 4
	
	#Rem monkeydoc
	Constr, with gravity vector parameter.
	#End
	'ORIG Method New( gravity:b2Vec2 = New b2Vec2( 0.0, 0.0 ) )
	Method New( gravity:b2Vec2 = New b2Vec2() )
		
		CongoLog( "In PhysicsWorld constr" )
		
		' construct the b2world
		Local allowSleep:Bool = True
		m_world = New b2World( gravity, allowSleep )
		m_world.SetContinuousPhysics( True );
		
	End
	
	' todo?
	' CreateCircleBody:b2Body
	' CreateBoxBody:b2Body
	' CreateEdgeBody:b2Body
	
	#Rem monkeydoc
	Retunrns the box2d b2World.
	#End
	Method GetWorld:b2World()
	
		Return m_world
	
	End
	
	#Rem monkeydoc
	Updates the physics world using the current simulation parameters.
	#End
	Method Update:Void( dTf:Float )
	
		m_world.TimeStep( dTf, m_velocityIterations, m_positionIterations )
		
	End
	
	#Rem monkeydoc
	Call this function to initialise a 'debug draw' view to help with debugging the box2d shapes etc.
	Remember To draw it from your layer (after autofit And cls, but before other mojo graphics calls).
	#End
	Method CreateDebugDraw:b2DebugDraw()
	
		Local debugDraw:b2DebugDraw = New b2DebugDraw()
	 	debugDraw.SetDrawScale( PhysicsWorld.BOX2D_PTM )
      	 	debugDraw.SetFillAlpha(0.3)
       		debugDraw.SetLineThickness(2.0)
       		 debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit)
        	Self.m_world.SetDebugDraw( debugDraw )
		Return debugDraw

	End

End
