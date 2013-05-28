#Rem monkeydoc Module congo.rect
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.



' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see license.txt.
'
' Rect: a simple rectangle class, including functions for checking intersection with points or rects.
' We define the origin of the rect to the top left coordinate.
'
' (Note - the functions are not 'inlined' until Monkey supports it. If using intensively, 
' might be worth copy/pasting in place).
'
' Part of the 'Congo' module for Monkey.
' 

Strict
'(not mojo-dependent)

Import congo.point
Import congo.textutils

#Rem monkeydoc
A rectangle class, including functions for checking intersection with points or other rects.
We define the origin of the rect to the top left coordinate.
#End
Class Rect	
	
Private

	Field m_x:Float = 0.0
	Field m_y:Float = 0.0
	Field m_width:Float = 0.0
	Field m_height:Float = 0.0

Public
	
	#Rem monkeydoc
	Construct a rect by providing the top left coordinate, together with the width and height.
	#End
	Method New( x:Float, y:Float, width:Float = 0.0, height:Float = 0.0 )
	
		m_x = x
		m_y = y
		m_width = width
		m_height = height

	End
	
	#Rem monkeydoc
	Construct a rect by providing the top left and bottom right coordinates.
	#End
	Method New( pt1:Point, pt2:Point )
		
		m_width = pt2.x - pt1.x
		m_height = pt2.y - pt1.y
		m_x = pt1.x
		m_y = pt1.y
	
	End
	
	#Rem monkeydoc
	X position of top-left corner.
	#End
	Method X:Float() Property
		Return m_x
	End
	#Rem monkeydoc
	Sets X position of top-left corner.
	#End
	Method X:Void( x:Float ) Property
		m_x = x
	End
	#Rem monkeydoc
	Y position of top-left corner.
	#End
	Method Y:Float() Property
		Return m_y
	End
	#Rem monkeydoc
	Sets Y position of top-left corner.
	#End
	Method Y:Void( y:Float ) Property
		m_y = y
	End
	Method x:Float() Property
		Return m_x
	End
	Method x:Void( x:Float ) Property
		m_x = x
	End
	Method y:Float() Property
		Return m_y
	End
	Method y:Void( y:Float ) Property
		m_y = y
	End
	#Rem monkeydoc
	Returns the rect width.
	#End
	Method Width:Float() Property
		Return m_width
	End
	#Rem monkeydoc
	Sets the rect width.
	#End
	Method Width:Void( wid:Float ) Property
		m_width = wid
	End
	#Rem monkeydoc
	Returns the rect height.
	#End
	Method Height:Float() Property
		Return m_height
	End
	#Rem monkeydoc
	Sets the rect height.
	#End
	Method Height:Void( hgt:Float ) Property
		m_height = hgt
	End
	
	#Rem monkeydoc
	Returns the rect area (width x height).
	#End
	Method Area:Float()
		Return width*height
	End
	
	#Rem monkeydoc
	Outputs some debug information about the rect, useful for testing.
	#End
	Method PrintInfo:Void()
		CongoLog( "Rect x: " + x + " y: " + y + " w: " + Width + " h: " + Height )
	End

	#Rem monkeydoc	
	Returns True if any part of the rect intersects the provided rect (or if the edges align exactly).
	#End
	Method Intersects:Bool( rect2:Rect )
		
		If Self.x > rect2.x + rect2.Width Or Self.x + Self.Width < rect2.x Return False
		If Self.y > rect2.y + rect2.Height Or Self.y + Self.Height < rect2.y Return False
		Return True
		
	End
	
	#Rem monkeydoc
	Returns True if the provided point lies within the rect (or lies exactly on an edge).
	#End
	Method Contains:Bool( point:Point )
	
		If point.x < Self.x Or point.y < Self.y Or
		   point.x > Self.x + Self.Width Or point.y > Self.y + Self.Height Return False
		Return True
		
	End
	
	' Functions which operate on other Rects.
	
	#Rem monkeydoc
	Returns True if any part of the 2 rects intersect (incl if the edges align exactly).
	#End
	Function Intersects:Bool( rect1:Rect, rect2:Rect )
	
		If rect1.x > rect2.x + rect2.Width Or rect1.x + rect1.Width < rect2.x Return False
		If rect1.y > rect2.y + rect2.Height Or rect1.y + rect1.Height < rect2.y Return False
		Return True
	
	End
	
	#Rem monkeydoc
	Returns True if the point lies within any part of the rect (or exactly on an edge).
	#End
	Function Contains:Bool( rect:Rect, point:Point )
	
		If point.x < rect.x Or point.y < rect.y Or
		   point.x > rect.x + rect.Width Or point.y > rect.y + rect.Height Return False
		Return True
		
	End

End
