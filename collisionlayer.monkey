#Rem monkeydoc Module congo.collisionlayer
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
Import mojo

Import congo.layer

#Rem monkeydoc
Helper class for CollisionLayer. A CollisionDef contains 2 lists of Sprites that can collide.

Dev note /todo: could use DisplayItems throughout?
#End
Class CollisionDef
Private
	Field firstGroup:List<Sprite> = New List<Sprite>
	Field secondGroup:List<Sprite> = New List<Sprite>

Public

	#Rem monkeydoc
	Creates a new CollisionDef using the 2 lists provided.
	#End
	Method New( group1:List<Sprite>, group2:List<Sprite> )
		firstGroup = group1
		secondGroup = group2
	End
End

#Rem monkeydoc
A layer class with simple collision detection enabled. Derives from Layer.

** CLASS UNDER DEVELOPMENT ** Useable, but some limitations.

Use CollisionDef to define lists of Sprites that can collide. Each pair of lists is then compared
using the CollisionRect defined by the Sprites. 
Sprites can be in multiple lists, but obviously keep lists as small as possible.
Currently, items must be direct top-level children of the layer (Todo - improve this).

Collisions are reported in CollisionOccured(), which derived classes can override. 
Sprites do not collide if they are hidden or if
they explicity have collisions disabled. Collision rects are AABB. Off-screen Sprites will still collide. 

CollisionOccured may receive multiple calls for a collision pair, be sure to process them with this in mind.
Do not destroy sprites from inside CollisionOccured since the sprite lists are still being processed.

The setting SetMaxCollisionDistance is used to quickly remove Sprites from further checks (very large
sprites may require require special treatment here).

Dev note - the method here is fairly 'brute force'. We could do more optimisation or introduce a grid/tree technique.

(note - if using physics/box2d its best to use the collision methods there).
#End
Class CollisionLayer Extends AppLayer ' was layer

Private

	Field m_enableCollisions:Bool = True ' enabled by default	
	Field m_collisionDefs:List< CollisionDef > = New List< CollisionDef >
	Field m_maxCollisionDist:Float ' see SetMaxCollisionDistance
	
Public
	
	#Rem monkeydoc
	Creates a new collision layer with specified size. See Layer documentation for more details.
	#End
	Method New( w:Int, h:Int )
		
		Super.New( w, h )
		
		SetMaxCollisionDistance( 200.0 )
	
	End	
	
	#Rem monkeydoc
	Overrides the Update method to add the collision check.
	#End
	Method Update:Void( dT:Int )
	
		Super.Update( dT ) ' (update child sprites before we do collision det)
		
		If CollisionsEnabled() Then
			For Local cdef:CollisionDef = Eachin m_collisionDefs
				DoCollisionCheck( cdef.firstGroup, cdef.secondGroup )
			Next
		End
	
	End
	
	#Rem monkeydoc
	Use this to enable or disable all collisions on this layer
	#end
	Method EnableCollisions:Void( state:Bool = True ) Property
	
		m_enableCollisions = state 
	
	End
	
	#Rem monkeydoc
	Returns True if collisions enabled. 
	#End
	Method CollisionsEnabled:Bool() Property
	
		Return m_enableCollisions

	End
	
	#Rem monkeydoc
	This is used to optimise collision checks. If the (manhattan) distance between 2 sprites is greater 
	than the MaxCollisionDistance, no further checks are done.
	Default is 200 points. Adjust as required, especially if using large/zoomed-in sprites.
	
	Dev note/todo: this setting does not take zoom into account.
	#End
	Method SetMaxCollisionDistance:Void( dist:Float = 200.0 ) Property
	
		m_maxCollisionDist = dist
	
	End
	
	#Rem monkeydoc
	Use this to add a collision definition. Any number of definitions can be added, but efficiency will 
	eventually be an issue (depending on size of each list).
	#End
	Method AddCollisionDef:Void( cdef:CollisionDef )
	
		m_collisionDefs.AddLast( cdef )
	
	End
	
	#Rem monkeydoc
	Performs a collision check between 2 lists of sprites. Called automatically in Update(), you don't usually 
	need to manually call this. For any collision, CollisionOccured() is called.

	Dev note / limitation: currently assumes the spites are in the same coordinate space -- wont yet work with nested child sprites.
	#End
	Method DoCollisionCheck:Void( gpa:List<Sprite>, gpb:List<Sprite> )
	
		For Local spr1:Sprite = Eachin gpa
			For Local spr2:Sprite = Eachin gpb
				' do quick tests before doing full rect intersect. NB use global coords.
				If Not ( spr1.CollisionsDisabled Or spr2.CollisionsDisabled Or spr1.Hidden Or spr2.Hidden ) And 
						 Point.ManHatDist( spr1.Position, spr2.Position ) < m_maxCollisionDist Then
					
					' ok, need to check rect intersect
					If SpriteRectsIntersect( spr1, spr2 ) Then
						CollisionOccured( spr1, spr2 )
					End
				End
			Next
		Next

	End
		
	#Rem monkeydoc
	Collisions trigger this function, derived classes can override this. 
	Do not delete a Sprite inside this function. Sprites can be in multiple collisions each Update().
	You could call DisableCollisions on a Sprite to avoid repeat collisions.
	#End
	Method CollisionOccured:Void( sprite1:Sprite, sprite2:Sprite )
	
		' (nothing here - derived classes can implement)
	End

End
