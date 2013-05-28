#Rem monkeydoc Module congo.scrolllayer
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
Import mojo

Import congo.layer
Import congo.point
Import congo.touchmanager
Import congo.textutils

#Rem monkeydoc
A layer with drag, swipe, inertia and bounce effects. 
Supports vertical or horizontal scrolling, and snapping to 'page' positions.

** CLASS UNDER DEVELOPMENT ** Needs more features, testing, tidy-up properties etc.
#End
Class ScrollLayer Extends Layer

Public 

	Field dragStartPos:Point = New Point()
	Field velocity:Point = New Point()
	Field maxSpeed:Float = 10.0
	Field xlocked:Bool = True
	Field ylocked:Bool = False
	Field inertia:Float = 0.9 ' (1.0 is no damping, will scroll forever!)
	Field bounce:Bool = True
	
	Field leftLimit:Float  = -300
	Field rightLimit:Float = +300
	Field topLimit:Float   = -300
	Field botLimit:Float   = +300
	
	' layer will 'snap' to these points if within the snapDist.
	Field snapPoints:List<Point> = New List<Point>
	Field snapDist:Float = 15.0
	
Private

	Method New()
		' here to prevent Monkey allowing direct use of default constr.
	End

Public

	#Rem monkeydoc
	Creates a scrolllayer with specified size (in device points, ie autofit virtual coords).
	#End
	Method New( w:Int, h:Int )
		
		Super.New( w, h )
		
		dragStartPos.x = Position.x
		dragStartPos.y = Position.y
		
		' Testing:
		AddSnapPoint( New Point( 0, -150 ) )
	
	End	
	
	#Rem monkeydoc
	Adds a 'snap' point. The layer will lock to these if moving slowly enough.
	#End
	Method AddSnapPoint:Void( pt:Point )
	
		snapPoints.AddLast( pt )
	
	End
	
	Method Update:Void( dT:Int )
		
		Local tman:TouchManager = TouchManager.getInstance()
		' (assumed tman is updated by parent). 
		Super.Update( dT )
	   	
	   	 If tman.touches[0].touchState = TouchState.CONGO_TOUCHSTATE_DOWN Then
	   	 	' deal with touch drag start (also interrupts any scrolling)
	   	 	If tman.touches[0].touchTimer < 50 Then
	 	  		velocity.x = 0
	   			velocity.y = 0
	   			dragStartPos.x = Position.x
	   			dragStartPos.y = Position.y
	   		End
	  		If Not xlocked Self.Position.x = dragStartPos.x + tman.touches[0].touchCurrentPos.x - tman.touches[0].touchStartPos.x
	   		If Not ylocked Self.Position.y = dragStartPos.y + tman.touches[0].touchCurrentPos.y - tman.touches[0].touchStartPos.y

	   	Else If tman.touches[0].touchState = TouchState.CONGO_TOUCHSTATE_RELEASED Then
	   		dragStartPos.x = Position.x
	   		dragStartPos.y = Position.y
	   	End
	   	   	   	
	   	' swipe/velocity effect
	   	If tman.touches[0].swipeState = SwipeState.CONGO_SWIPESTATE_COMPLETE And tman.touches[0].swipeTimer < 250 Then
	   		If Not xlocked velocity.x +=  tman.touches[0].touchEndPos.x - tman.touches[0].touchStartPos.x
	   		If Not ylocked velocity.y +=  tman.touches[0].touchEndPos.y - tman.touches[0].touchStartPos.y
	   	End	   	
	   	
	   	' check snap points. Dev note- not perfect, could be improved.
	   	If tman.touches[0].touchState = TouchState.CONGO_TOUCHSTATE_NONE And
	   		Abs(velocity.x) < 5.0 And Abs(velocity.y) < 5.0 Then
	   		
	   		For Local pt:Point = Eachin snapPoints
	   			If Not ylocked Then
	   				If Abs(Position.y - pt.y) < snapDist Then
		   				If Position.y > pt.y velocity.y = -0.5
		   				If Position.y < pt.y velocity.y = +0.5
		   			End
	   			End
	   			If Not xlocked Then
	   				If Abs(Position.x - pt.x) < snapDist Then
		   				If Position.x > pt.x velocity.x = -0.5
		   				If Position.x < pt.x velocity.x = +0.5
		   			End
	   			End
	   		Next
	   	End	   	
	   	
	   	' speed limits
	   	If velocity.x > maxSpeed velocity.x = maxSpeed
	   	If velocity.x < -maxSpeed velocity.x = -maxSpeed
	   	If velocity.y > maxSpeed velocity.y = maxSpeed
	   	If velocity.y < -maxSpeed velocity.y = -maxSpeed
	
		' main vel movement
		Self.SetPosition( Position.x + velocity.x, Position.y + velocity.y )
			
		' edge limits
		If Self.Position.x < leftLimit Then
			Self.Position.x = leftLimit
			If bounce velocity.x *= -0.5
		Else If Self.Position.x > rightLimit Then 
			Self.Position.x = rightLimit
			If bounce velocity.x *= -0.5
		End
		If Self.Position.y < topLimit Then
			Self.Position.y = topLimit
			If bounce velocity.y *= -0.5
		Else If Self.Position.y > botLimit Then
			Self.Position.y = botLimit
			If bounce velocity.y *= -0.5
		End	
		
		' inertia
		If inertia > 0.0 Then
			velocity.x *= inertia
			velocity.y *= inertia
		End
	End
	
End
