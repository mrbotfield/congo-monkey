#Rem monkeydoc Module congo.layer
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
Import mojo

Import congo.sprite
Import congo.transition
Import congo.textutils

#Rem monkeydoc
A general layer class. Derives from DisplayItem.

A Layer is essentially an empty DisplayItem 'node' to add more DisplayItems/Sprites too.
It has a centred handle by default so that zoom/rotate transforms occur from it's centre.

See also: AppLayer, a top-level layer with extra features required by CongoApp (transitions etc).
#End
Class Layer Extends DisplayItem

Private
	Field layerWidth:Int
	Field layerHeight:Int
	
Public
	Method New()
		' here to prevent Monkey allowing direct use of default constr.
		Error( CONGO_ERROR_STRING + "dont use the default constr for layer." )
			Throw New Throwable()
		' (see http://www.monkeycoder.co.nz/Community/posts.php?topic=834 )
	End

Public

#Rem monkeydoc
	Creates a layer with specified size (in device points, ie autofit virtual coords).
	
	Dev note - no defaults due to Monkey issue http://monkeycoder.co.nz/Community/posts.php?topic=1150 )
#End
	Method New( w:Int, h:Int )
		
		layerWidth = w
		layerHeight = h
		CongoLog( "New Layer with size " + w + " x " + h )
		SetHandle( 0.5*w, 0.5*h ) ' so rotation/scaling is from centre.	
	End	

	#Rem monkeydoc
	Returns the layer width.
	#End
	Method LayerWidth:Int() Property
		Return layerWidth
	End
	
	#Rem monkeydoc
	Returns the layer height.
	#End

	Method LayerHeight:Int() Property
		Return layerHeight
	End
	
	Method Update:Void( dT:Int )
		Super.Update( dT )
	End
	
	Method Draw:Void()
		Super.Draw()
	End
	
	#Rem monkeydoc
	Returns True if the 2 Sprites' bounding rects intersect.
	Both sprites must be direct children of the layer.

	Dev note - sprites must have same parent - todo, improve this. Todo: change to DisplayItem.
	#End
	Function SpriteRectsIntersect:Bool( spr1:Sprite, spr2:Sprite )
	
		Return Rect.Intersects( spr1.GetBoundingRect(), spr2.GetBoundingRect() )
	
	End
	
	#Rem monkeydoc
	Returns True if the Sprite's bounding rect contains the given point.
	Sprite must be direct child of the layer.

	Dev note - todo, improve this.
	#End
	Function SpriteRectContainsPoint:Bool( spr:Sprite, point:Point )
		
		Return spr.GetBoundingRect().Contains( point )
		
	End

End
