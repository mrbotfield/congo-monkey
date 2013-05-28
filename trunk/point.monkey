#Rem monkeydoc Module congo.point
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
'(not mojo-dependent)

#Rem monkeydoc
A simple point class and associated point/vector functions.
#End
Class Point
	
Private 
	
	Field m_x:Float = 0.0
	Field m_y:Float = 0.0

Public
	
	#Rem monkeydoc
	Creates a point with the given coordinates.
	#End
	Method New( x:Float = 0.0, y:Float = 0.0 )

		Set( x, y )

	End	
	
	#Rem monkeydoc
	Creates a point with coordinates equal to the provided Point.
	#End
	Method New( p:Point )
	
		Set( p.x, p.y )
	
	End
	
	#Rem monkeydoc
	Alternative method to set coordinates.
	#End
	Method Set:Void( x:Float = 0.0, y:Float = 0.0 )
	
		m_x = x
		m_y = y
	
	End
	
	#Rem monkeydoc
	Sets the coordinates to be equal to the provided Point.
	
	Dev note - 'somepoint = mypoint' will make both points reference the *same object*!.
	#End
	Method Set:Void( pt:Point )
	
		Set( pt.x, pt.y )
	
	End
	
	#Rem monkeydoc
	Returns the X coordinate.
	#End
	Method X:Float() Property
		Return m_x
	End
	#Rem monkeydoc
	Set the X coordinate.
	#End
	Method X:Void( xpos:Float ) Property
		m_x = xpos
	End
	#Rem monkeydoc
	Returns the Y coordinate.
	#End
	Method Y:Float() Property
		Return m_y
	End
	#Rem monkeydoc
	Sets the Y coordinate.
	#End
	Method Y:Void( ypos:Float ) Property
		m_y = ypos
	End
	#Rem monkeydoc
	Returns the X coordinate (alternative).
	#End
	Method x:Float() Property
		Return m_x
	End
	#Rem monkeydoc
	Sets the X coordinate (alternative).
	#End
	Method x:Void( xpos:Float ) Property
		m_x = xpos
	End
	#Rem monkeydoc
	Returns the Y coordinate (alternative).
	#End
	Method y:Float() Property
		Return m_y
	End
	#Rem monkeydoc
	Sets the Y coordinate (alternative).
	#End
	Method y:Void( ypos:Float ) Property
		m_y = ypos
	End
	
	#Rem monkeydoc
	Returns the length of the vector (from origin to the Point).
	#End
	Method Length:Float()
		Return Sqrt( m_x*m_x + m_y*m_y )
	End
	
	#Rem monkeydoc
	Returns the square of the length of the vector (from origin to the Point).
	More efficient than Length() since it avoids a Sqrt calculation.
	#End
	Method LengthSq:Float() ' (avoids a call to Sqrt)
		Return m_x*m_x + m_y*m_y
	End
	
	' Functions which operate on other Point(s), usually returning result in a new Point.
	
	#Rem monkeydoc
	Function which returns the distance between two points.
	#End
 	Function PointDist:Float( p1:Point, p2:Point )
		Return Sqrt( Pow(p2.y-p1.y,2) + Pow(p2.x-p1.x,2) )
	End
	
	#Rem monkeydoc
	Function which returns the square of the distance between two points.
	More efficient than PointDist() since it avoids a Sqrt calculation.
	#End
	Function PointDistSq:Float( p1:Point, p2:Point ) ' (avoids a call to Sqrt)
		Return Pow(p2.y-p1.y,2) + Pow(p2.x-p1.x,2)
	End
	
	#Rem monkeydoc
	Returns a new point which is the addition of the two provided points.
	#End
	Function PointAdd:Point( p1:Point, p2:Point )
		Return New Point( p1.x + p2.x, p1.y + p2.y )
	End
	
	#Rem monkeydoc
	Returns a new point which is the subtraction of the two provided points.
	#End
	Function PointSub:Point( p1:Point, p2:Point )
		Return New Point( p1.x - p2.x, p1.y - p2.y )
	End

	#Rem monkeydoc
	Scales the provided vector and returns the result as a new point. 
	#End
	Function PointMult:Point( p:Point, amount:Float )
		Return New Point( p.x * amount, p.y * amount )
	End
	
	#Rem monkeydoc
	Normalizes the provided vector and returns the unit vector as a new point. 
	#End
	Function PointNormalize:Point( p:Point )
		Local lenr:Float = 1.0 / Sqrt( Pow(p.y,2) + Pow(p.x,2) )
		Return New Point( p.x * lenr, p.y * lenr )
	End
	
	#Rem monkeydoc
	Returns the dot product of the two vectors. 
	#End
	Function PointDot:Float( p1:Point, p2:Point )
		Return ( p1.x * p2.x ) + ( p1.y * p2.y ) 
	End
	
	#Rem monkeydoc
	Returns the 'manhatten' distance between two points. Much cheaper than a full distance calculation. 
	#End
	Function ManHatDist:Float( p1:Point, p2:Point )
		Return Abs( p2.y - p1.y ) + Abs ( p2.x - p1.x ) 
	End
	
	#Rem monkeydoc
	Returns the angle (in radians) between the two vectors.
	#End
	' Dev note - uses: angle = acos ( a . b / ||a|| ||b|| )
	Function PointAngle:Float( p1:Point, p2:Point )
		Return ACosr( 00000 ) ' HERE
	End
	
End
