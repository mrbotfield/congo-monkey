#Rem monkeydoc Module congo.displayitem
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2014. This code is released under the MIT License - see LICENSE.txt.

Strict
' (not mojo dependent)

''Import congo.textutils
Import congo.point
Import congo.rect
Import congo.action
Import congo.congoapp

#Rem monkeydoc
Abstract base class for all displayable items (Sprites, Layers, etc).

Has position, scale, actions, and other base properties. Holds a hierarchy of child items which are processed in Update().
#End
Class DisplayItem Abstract

Private 

	' Basic properties:
	Field position:Point = New Point()	' position relative to Parent. See SetPosition or Position property.
	Field angle:Float = 0.0  		' see SetAngle or Angle property.
	Field zOrder:Float = 0.0 		' see ZOrder property. Use AddChild or ReorderChild to modify.
	Field xScale:Float = 1.0 		' see SetScale or XScale property. -1 will flip about y
	Field yScale:Float = 1.0 		' see SetScale or YScale property. -1 will flip about x
	Field alpha:Float = 1.0	  	' use SetOpacity or Opacity property.
	Field hidden:Bool = False 		' use SetHidden. 
	
	' Further properties:
	Field handle:Point = New Point() 	' item handle, affects zoom/rotate transforms. Default 0,0 at center.
	Field resScaler:Float = 1.0		' Internal scale factor to deal with hi-res displays. Usually let CongoImageLoader set this. 
	
	' Children, parent, sorting.
	Field children:DisplayItem[] 		' children in z-order. See AddChild, Children().
	Field numChildren:Int = 0		' See NumChildren(). (we could use the array size, but keep this counter instead).
	Field parent:DisplayItem = Null	' useful link back our parent, or Null if none.
	Field dirtyZOrder:Bool = False 	' Internal, triggers z-sorting.
	Field useLazySort:Bool = False 	' Set this to avoid full z-order child sort. See notes with function.
	
	' Actions
	Field actions:List<Action> = New List<Action> ' currently running Actions.
	
	' User-defined data. May be used for any purpose, e.g. game object types, dead/alive status etc.
	Field customId:Int = 0
	Field customFlag:Bool = False
	Field customName:String = ""
	Field customItemRef:DisplayItem = Null	' i.e. can refer to another sprite/item.
	
	' Experimental. Note, you can use GetMatrix in a derived class to store the global transform if you wish.
	' Field trMatrix:Float[6] 				' (currently unused) stores current transformation matrix generated in Draw step.
	' Field trMatrixDirty:Bool = True 		' (currently unused)
	

Public
	#Rem monkeydoc
	Default constr creates an empty item.
	#End
	Method New()
		'(nothing to do here)
	End
	
	#Rem monkeydoc
	Sets the current position.
	#End
	Method SetPosition:Void( pos:Point )
		Self.position.x = pos.x
		Self.position.y = pos.y
	End
	
	#Rem monkeydoc
	Sets the current position.
	#End
	Method SetPosition:Void( xpos:Float, ypos:Float )
		Self.position.x = xpos
		Self.position.y = ypos
	End
	
	#Rem monkeydoc
	Sets the current position.
	#End
	Method Position:Void( pos:Point ) Property
		Self.position.x = pos.x
		Self.position.y = pos.y
	End
	
	#Rem monkeydoc
	Returns the current position.
	#End
	Method Position:Point() Property
		Return Self.position
	End
	
	#Rem monkeydoc
	Returns the current rotation angle.
	#End
	Method Angle:Float() Property
		Return Self.angle
	End
	
	#Rem monkeydoc
	Sets the current rotation angle in degrees (counter-clockwise).
	#End
	Method Angle:Void( rot:Float ) Property
		Self.angle = rot
	End
	
	#Rem monkeydoc
	Sets the current rotation angle in degrees (counter-clockwise).
	#End
	Method SetAngle:Void( rot:Float ) Property
		Self.angle = rot
	End
	
	#Rem monkeydoc
	Returns the Z order. See AddChild() or ReorderChild() to change Z order (cant set it directly).
	#End
	Method ZOrder:Float() Property
		Return zOrder
	End
	
	#Rem monkeydoc
	Set both x and y scale factors to the same amount.
	#End 
	Method SetScale:Void( scale:Float )
		Self.xScale = scale
		Self.yScale = scale
	End
	
	#Rem monkeydoc
	Sets the x and y scale factors separately.
	#End
	Method SetScale:Void( xscl:Float, yscl:Float )
		Self.xScale = xscl
		Self.yScale = yscl
	End
	
	#Rem monkeydoc
	Returns the X scale factor.
	#End
	Method XScale:Float() Property
		Return xScale
	End
	
	#Rem monkeydoc
	Returns the Y scale factor.
	#End
	Method YScale:Float() Property
		Return yScale
	End
	
	#Rem monkeydoc
	Sets the X scale factor.
	#End
	Method XScale:Void( scale:Float ) Property
		xScale = scale
	End
	
	#Rem monkeydoc
	Sets the Y scale factor.
	#End
	Method YScale:Void( scale:Float ) Property
		yScale = scale
	End
	
	#Rem monkeydoc
	Sets the opacity (alpha) of this tiem and optionally all (current) child items.
	1.0 is fully opaque, 0.0 is fully transparent. Not to be confused with mojo function SetAlpha() which controls the
	Draw state alpha.
	#End
	Method SetOpacity:Void( alphaLevel:Float, andChildren:Bool = true )
		
		If alphaLevel < 0 alphaLevel = 0 ' (bad things happen below 0)
		Self.alpha = alphaLevel
		If andChildren Then
			For Local i:Int=0 Until numChildren
				children[i].SetOpacity(alphaLevel)
			Next
		End
	End
	
	#Rem monkeydoc
	Returns the opacity (alpha). Range is 0.0 (transparent) to 1.0 (fully opaque).
	#End
	Method Opacity:Float() Property
		Return Self.alpha
	End
	
	#Rem monkeydoc
	Used to hide an item. Hidden items (and their children) are not drawn, but still receive Updates. See also SetOpacity.
	#End
	Method SetHidden:Void( state:Bool = True )
		hidden = state
	End
	
	#Rem monkeydoc
	Returns True if currently hidden.
	#End
	Method Hidden:Bool() Property
		Return hidden
	End
	
	#Rem monkeydoc
	Used to hide an item. Hidden items (and their children) are not drawn, but still receive Updates. See also SetOpacity.
	#End
	Method Hidden:Void( state:Bool ) Property
		hidden = state
	End
	
	#Rem monkeydoc
	Sets the item handle (anchor point), givent in virtual coords.
	
	The handle is subtracted before rotation and scale are applied, thus providing a 'local' origin.
	Note, the handle is relative to the centre of the item, unlike Monkey's Image handles which are at the top-left.
	#End
	Method SetHandle:Void( xpos:Float, ypos:Float, adjustForResScale:Bool = False )
		
		If adjustForResScale Then
			Self.Handle.x = xpos*Self.ResScaler
			Self.Handle.y = ypos*Self.ResScaler
		Else 
			Self.Handle.x = xpos
			Self.Handle.y = ypos
		End
	End
	
	#Rem monkeydoc
	Returns the item's handle position.
	#End
	Method Handle:Point() Property
		Return Self.handle
	End
	
	#Rem monkeydoc
	(Advanced use) Returns the internal res scale factor. Default is 1.0.
	#End
	Method ResScaler:Float() Property
		Return resScaler
	End
	
	#Rem monkeydoc
	(Advanced use) Sets the internal res scale factor. DisplayItems leave this as 1.0, but Sprite's will 
	set this via CongoResourceLoader when hi-res images are used, which we need to scale for.
	#End
	Method ResScaler:Void( rscale:Float ) Property
		resScaler = rscale
	End
	
	#Rem monkeydoc
	Returns the current number of child items owned by this displayitem.
	#End
	Method NumChildren:Int() Property
		Return numChildren
	End
	
	#Rem monkeydoc
	Returns the parent item, or Null if no parent.
	#End
	Method Parent:DisplayItem() Property
		Return parent
	End
	
	#Rem monkeydoc
	Returns the array of child items, if you need to access them directly.

	Dev note - be careful if manipulating the array, numChildren is stored separately.
	#End
	Method Children:DisplayItem[]() Property
		Return children
	End
	
	#Rem monkeydoc
	Returns True if the specified item is a direct child of this item (not a nested child).
	#End
	Method HasChild:Bool( ditem:DisplayItem )
		Return ditem.Parent = Self
	End
	 
	#Rem monkeydoc
	Returns the named child, or null if none. Uses CustomName.
	#End 
	Method GetChildByCustomName:DisplayItem( customName:String )
		For Local i:Int=0 Until numChildren
			If children[i].CustomName = customName Return children[i]
		Next
		Return Null
	End
	
	#Rem monkeydoc
	Adds a child item. Z order is 0 by default, will be added after other items with the same Z order.
	Adding an child twice will throw an error.
	See also HasChild(), AddChildWithZOrder() and ReorderChild().
	#End
	Method AddChild:Void( child:DisplayItem )
		
		If child.parent <> Null 
			CongoLog( CONGO_ERROR_STRING + "Child already has a parent, we can't add it again." )
			Throw New Throwable()
			Return
		End
		
		If child = Null CongoLog( CONGO_WARNING_STRING + "Child item is null." )
		
		If numChildren = children.Length() Then
			' extend capacity. Expensive, but hopefully not called often. Tip: re-use objects in object pools.
			' For large changes you could resize the list in advance. NB null entries cause problems elsewhere.
			 children = children.Resize( children.Length() + 1 )
			' CongoLog( "AddChild: increased capacity to " + m_children.Length() )
		End
		
		children[ numChildren ] = child
		child.parent = Self
		numChildren += 1
		CongoLog( CONGO_NAME_STRING + " - AddChild: now has " + numChildren + " children" )
	End
	
	#Rem monkeydoc
	Removes a child item. Throws an Error If the item is Not a child.
	
	Removing children from the array is not very efficient, its not recommended to use this in
	cpu-critical code (e.g. it is always better to re-use pools of sprites/items).
	#End
	Method RemoveChild:Void( child:DisplayItem )
		
		CongoLog( CONGO_NAME_STRING + " - RemoveChild: starting with " + numChildren + " children" )
		
		If child.parent <> Self 
			CongoLog( CONGO_ERROR_STRING + "Not a child item, can't remove it." )
			Throw New Throwable()
			Return
		End
		
		Local locate:Int = -1
		For Local i:Int=0 Until numChildren
			If children[i] = child Then 
				locate = i
				children[i].parent = Null
				children[i] = Null
			End
		Next
		
		If locate < 0 Or locate >= numChildren Then
			CongoLog( CONGO_ERROR_STRING + "Cant locate child in RemoveChild." )
			Throw New Throwable()
			Return
		End
		
		' rebuild the child list, ignoring the removed child.
		' This is not fast. We could leave Null entries but that might cause issues elsewhere.
		Local newch:DisplayItem[]
		newch = newch.Resize( numChildren -1 )
		
		Local nxtc:Int = 0
		For Local i:Int=0 Until locate
				newch[nxtc] = children[i]
				nxtc += 1
		Next
		For Local i:Int=locate+1 Until numChildren
				If i < numChildren Then 
					newch[nxtc] = children[i]
					nxtc += 1
				End
		Next
		
		children = newch
		numChildren = children.Length()
		
		CongoLog( CONGO_NAME_STRING + " - RemoveChild: item now has " + numChildren + " children" )
		
	End
	
	#Rem monkeydoc
	As AddChild() but will reorder based on the provided Z order.
	#End
	Method AddChildWithZOrder:Void( child:DisplayItem, zOrder:Float = 0.0 )
		AddChild( child )
		ReorderChild( child, zOrder )
	End
	
	#Rem monkeydoc
	Changes an existing child's Z order. A re-sort is scheduled for the next update loop.
	#End
	Method ReorderChild:Void( child:DisplayItem, z:Float )
		If child.zOrder = z Return
		child.zOrder = z
		If numChildren > 1 dirtyZOrder = True
	End
	
	#Rem monkeydoc
	Sends child to front (highest Z order). A re-sort is scheduled for the next update loop.
	#End
	Method SendChildToFront:Void( child:DisplayItem )
		
		For Local i:Int = 0 Until children.Length
			Local di:DisplayItem = children[i]
			If di.zOrder >= child.zOrder ReorderChild( child, di.zOrder + 1 )
		Next
		
	End
	
	#Rem monkeydoc
	Sends child to back (lowest Z order). A re-sort is scheduled for the next update loop.
	#End
	Method SendChildToBack:Void( child:DisplayItem )
	
		For Local i:Int = 0 Until children.Length
			Local di:DisplayItem = children[i]
			If di.zOrder <= child.zOrder ReorderChild( child, di.zOrder - 1 )
		Next
		
	End
	
	#Rem monkeydoc
	For advanced use. Returns a recursive list of all child items related to this one. 
	The search is breadth-first, as each child node is visited. Function is not
	particularly efficient as it must process each child array and construct new lists.
	#End
	Method RecursiveChildList:List<DisplayItem>()
		Local result:List<DisplayItem> = New List<DisplayItem>

		'  add recursively to our list
		Local ch:List<DisplayItem> = New List<DisplayItem>( Self.Children() )
		
		For Local di:DisplayItem = Eachin ch
			result.AddLast( di )
			Local rec:List<DisplayItem> = di.RecursiveChildList()
			For Local add:DisplayItem = Eachin rec
				result.AddLast( add )
			Next
		Next
		
		Return result
		
	End

	#Rem monkeydoc
	(Internal). Flag which triggers child resorting. Normally you don't need to use this.
	#End
	Method DirtyZOrder:Bool() Property
		Return dirtyZOrder
	End

	#Rem monkeydoc
	Option which enables a more efficient Z sorting algorithm. 
	It may take a number of update loops to fully sort all children since only one 'sweep' is done per Update loop.
	#End
	Method UseLazySort:Bool() Property
		Return useLazySort
	End
	
	#Rem monkeydoc
	Runs an Action (or ActionSequence) on the item.

	Note - avoid running two actions which affect the same data, e.g. a MoveTo and a MoveBy at the same time.
	#End
	Method RunAction:Void( action:Action )
		actions.AddLast( action )
		CongoLog( CONGO_NAME_STRING + " - Added an action, now has " + actions.Count() + " actions." )
	End
	
	#Rem monkeydoc
	(Advanced use). Returns the list of Actions. Some Actions may be running, some may have completed.
	#End
	Method Actions:List<Action>() Property
	
		Return actions
	
	End
	
	#Rem monkeydoc
	Stops and removes all Actions applied to this item.
	#End
	Method RemoveAllActions:Void()

		actions.Clear()

	End
	
	#Rem monkeydoc
	Removes all children.

	Note, if the TextureCache was used to store associated Images, they will remain there unless cleared.
	#End
	Method RemoveAllChildren:Void()
		
		children = [] ' GC should clear them from here...
		numChildren = 0
		
	End
	
	#Rem monkeydoc
	A user-defined custom int property.
	#End
	Method CustomId:Int() Property
		Return customId
	End
	
	#Rem monkeydoc
	A user-defined custom int property.
	#End
	Method CustomId:Void( value:Int ) Property
		customId = value
	End
	
	#Rem monkeydoc
	A user-defined custom bool property.
	#End
	Method CustomFlag:Bool() Property
		Return customFlag
	End
	
	#Rem monkeydoc
	A user-defined custom bool property.
	#End
	Method CustomFlag:Void( state:Bool ) Property
		customFlag = state
	End
	
	#Rem monkeydoc
	A user-defined custom string property.
	#End
	' User-defined name string property.
	Method CustomName:String() Property
		Return customName
	End
	
	#Rem monkeydoc
	A user-defined custom string property.
	#End
	Method CustomName:Void( name:String ) Property
		customName = name
	End	
	
	#Rem monkeydoc
	A user-defined custom item property.
	#End
	Method CustomItemRef:DisplayItem() Property
		Return customItemRef
	End	

	#Rem monkeydoc
	A user-defined custom item property.

	Note - remember to clear this if you are expecting the referenced item to be deleted by garbage collection.
	Also, be careful if the referenced item is deleted elsewhere, the pointer may not then be valid here.
	#End
	Method CustomItemRef:Void( item:DisplayItem ) Property
		customItemRef = item
	End
	
	#Rem monkeydoc
	Main draw routine. See also PaintItem().

	Transforms get applied before drawing child sprites, so they'll be affected by them
	(see http://www.monkeycoder.co.nz/Community/posts.php?topic=2412).

	For debugging/testing, uncomment the DrawBoundingRect() line at the end of this function.

	Dev note - we could combine the 3 transforms into a single transform, but the benchmark shows no improvement.

	Dev note - derived classes can override this, but with caution since it affects child transforms etc.
	#End
	Method Draw:Void()
	
		If Hidden Return 
		
		PushMatrix()
		Translate( Position.x + Handle.x, Position.y + Handle.y )
		If Angle Rotate(Angle)
		Scale( XScale/ResScaler, YScale/ResScaler ) 		
		' reverse the handle translate so our position (and child posns) arent affected.
		Translate( -ResScaler*Handle.x, -ResScaler*Handle.y )
		'  GetMatrix( trMatrix ) ' (Experimental) Store our global transform so we can use it later.	

		' Does the actual item render - derived classes must implement this.
		PaintItem()

		' need to undo res scaler since child items have their own. But, we do pass down the parents general scale factor.
		Scale( ResScaler, ResScaler )
		
		' Draw children (our current transform applies to them).
		' Todo - allow children with negative z order to draw below us - these are always above.
		For Local i:Int=0 Until NumChildren
			Children[i].Draw()
		Next
		
		PopMatrix()
		
		' For debugging/testing: enable this line to draw all bounding rects (local coords apply here).
		'   DrawBoundingRect()
		
	End
	
	#Rem monkeydoc
	Derived classes should implement this. It is called from Draw() to paint the item's content, separate to the transforms etc.
	#End
	Method PaintItem:Void() ' Abstract
		' (nothing to draw)
	End
	
	#Rem monkeydoc
	Main Update loop. Deals with Actions and Children. Derived classes can override this. 
	Pause state is also dealt with here.
	See also UpdateChildren().
	#End
	Method Update:Void( dT:Int )

		If Not CongoApp.IsPaused() Then 
	
			If Actions.Count() > 0 Then
			For Local acn:Action = Eachin Actions ' TODO check dead actions here?
				acn.Update( dT )
			Next
			End
		End
		
		If NumChildren > 0 UpdateChildren( dT )  
		
	End
	
	#Rem monkeydoc
	Updates the items children. Called from main Update() loop. It is kept separate for clarity and in case you want
	to write a custom Update() function.
	#End
	Method UpdateChildren:Void( dT:Int )
	
		If DirtyZOrder = False Then  
			' regular update loop
			For Local i:Int=0 Until NumChildren
				Children[i].Update( dT )
			Next
		Else If UseLazySort Then  
			' do 1 neighbour swap check for child list, whilst we update
			For Local i:Int=0 Until NumChildren 
				Children[i].Update( dT )
				If i > 0 And Children[i-1].ZOrder > Children[i].ZOrder Then
					Local spr:DisplayItem = Children[i]
					Children[i] = Children[i-1]		
					Children[i-1] = spr
				End
			Next
		Else 
			' update loop then full sort
			For Local i:Int=0 Until NumChildren
				Children[i].Update( dT )
			FullSortZOrder()
			Next 
		End
			
	End
	
	#Rem monkeydoc
	Gets called when an Action finishes. Cleans-up finished Actions from our list.
	Derived classes can override this as required, i.e. to retain or reuse the action instead.
	actionId is 0 unless defined when creating the action.
	#End
	Method ActionCompleted:Void( actionId:Int )

		' clean-up completed actions.
		' TODO move this to addaction? that wont clean everything, but better than calling it here every time (could be endless action).
		If actions.Count() > 0 Then
			Local toDelete:List<Action> = New List<Action>
			For Local acn:Action = Eachin actions
				If acn.IsComplete() toDelete.AddLast( acn )
			Next
			For Local dacn:Action = Eachin toDelete
				actions.RemoveEach( dacn )
			Next
		End
		
		' CongoLog( "ActionCompleted, id = " + actionId + ". item has " + m_actions.Count() + " active actions." )
	End
	
	#Rem monkeydoc
	Gets called when a child button is activated. Derived classes should override this.
	The situations which trigger an 'activated' state depens on the button type. Use CustomId or CustomString to identify buttons.
	#End
	Method ButtonActivated:Void( button:Sprite )
		
		'( derived classes should overide this).
		CongoLog( "ButtonActivated (DisplayItem)" )

	End
	
' Private methods

Private	

	#Rem monkeydoc
  	Insertion sort for children Z-ordering. See http://rosettacode.org/wiki/Sorting_algorithms/Insertion_sort

	See also http://www.monkeycoder.co.nz/Community/posts.php?topic=2034 User:impixi code sample.
	This is reasonably fast if the list is short and/or there are few changes to the order each step.
	See also UseLazySort for a faster sort.
	#End
	Method FullSortZOrder:Void()
	
		'Local moves:Int = 0 ' for debugging
		For Local i:Int = 1 Until Children.Length
			Local spr:DisplayItem = Children[i]
			Local j:Int = i - 1
			While ((j >= 0) And (Children[j].ZOrder > spr.ZOrder))
				Children[j + 1] = Children[j]
				j -= 1
				' For debugging:
				'	moves += 1 
				'	CongoLog( "sorted " + j+1 + " to " + j )
			Wend
			Children[j+1] = spr
		Next
		' CongoLog( "Sort done in " + moves + " moves" )
	End
	

End
