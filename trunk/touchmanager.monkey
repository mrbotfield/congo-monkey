#Rem monkeydoc Module congo.touchmanager
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
Import mojo
Import congo.point
Import congo.autofit
Import congo.congosettings 
Import congo.displayutils
Import congo.textutils

#Rem monkeydoc
Defines a touch event (or mouse press event), i.e. start position, end position, touch time etc.
#End
Class Touch

	' note - these all use virtual coords (autofit)
	Field touchCurrentPos:Point = New Point()
	Field touchStartPos:Point = New Point()
	Field touchEndPos:Point = New Point() ' this is set only when touch released.
	
	Field touchTimer:Int = 0 ' (ms)
	Field swipeTimer:Int = 0 ' (ms)
	Field touchHeld:Bool = False ' can use this to detect hold.
	
	Field touchState:Int = TouchState.CONGO_TOUCHSTATE_NONE
	Field swipeState:Int  = SwipeState.CONGO_SWIPESTATE_NONE
	Field swipeMotion:Int = SwipeMotion.CONGO_SWIPEMOTION_MISC
	
	' Rests all data for this touch to default 'off' state. 
	' You can use this to cancel a touch after processing it.
	Method Reset:Void()
		
		touchTimer = 0.0
		swipeTimer = 0.0
	 	touchHeld = False 
		touchState = TouchState.CONGO_TOUCHSTATE_NONE
	 	swipeState  = SwipeState.CONGO_SWIPESTATE_NONE
	
	End

End

#Rem monkeydoc
Definitions for touch state.
#End
Class TouchState

	Global CONGO_TOUCHSTATE_NONE:Int		= 0
	Global CONGO_TOUCHSTATE_DOWN:Int		= 1
	Global CONGO_TOUCHSTATE_RELEASED:Int	= 2	

End

#Rem monkeydoc
Definitions for swipe state.
#End
Class SwipeState

	Global CONGO_SWIPESTATE_NONE:Int		= 0
	Global CONGO_SWIPESTATE_SWIPING:Int		= 1
	Global CONGO_SWIPESTATE_COMPLETE:Int	= 2
	
End

#Rem monkeydoc
Definitions for touch swipe type/direction.
#End
Class SwipeMotion

	Global CONGO_SWIPEMOTION_MISC:Int	= 0 ' (no specific motion)
	Global CONGO_SWIPEMOTION_LEFT:Int	= 1
	Global CONGO_SWIPEMOTION_RIGHT:Int	= 2
	Global CONGO_SWIPEMOTION_UP:Int 	= 3
	Global CONGO_SWIPEMOTION_DOWN:Int 	= 4
End

#Rem monkeydoc
TouchManager is central singleton class to deal with touch input (and equivalent mouse input).

** THIS CLASS IS UNDER DEVELOPMENT ** - it is useable but has limited functionality.

Uses autofit virtual coords. Remember to call the Update in your main loop [Dev note -
todo, move Update to CongoApp Update loop].

See CongoSettings for multi-touch setting.

Note: In Monkey, devices with a mouse but no touch screen will simply return mouse data.

Note: we dont have the concept of touch 'targets' yet, or passing touch data to other layers/sprites. 

Dev note: todo, private fields, properties.
#End
Class TouchManager

	Field touches:Touch[]	
	
	' (adjust these if required)
	Field minHoldTime:Float 		= 300  ' (ms).
	Field swipeStartTolerance:Float 	= 15   ' movement required before swipe begins (in virtual points).
	Field minSwipeDistance:Float		= 30   ' movement required to register a completed swipe (in virtual points)
	Field maxGestureTime:Float 		= 750 ' (ms) gestures not recognised if they take longer than this time.
	
	Private
	
	' Singleton code
	Global m_tman_instance:TouchManager ' shared instance
	
	#Rem monkeydoc
	Private constr.
	#End
	Method New()
		CongoLog( "TouchManager New instance." )
		If m_tman_instance Then Error(" Error - cannot create new instance of TouchManager singleton")
		m_tman_instance = Self
		m_tman_instance.init()
	End
	
	#Rem monkeydoc
	Internal. Called from constr.
	#End
	Method init:Void()

		CongoLog( "TouchManager init. Max multitouch setting is " + CONGO_MAX_MULTITOUCH )
		touches = touches.Resize( CONGO_MAX_MULTITOUCH )
		For Local i:Int = 0 Until  CONGO_MAX_MULTITOUCH
			touches[i]	= New Touch()
		Next
	End
	
	Public
	
	#Rem monkeydoc
	Use this to access the shared instance.
	#End
	Function getInstance:TouchManager()
	
		If Not m_tman_instance Then
			m_tman_instance = New TouchManager()
		End
		
		Return m_tman_instance
	End
	
	#Rem monkeydoc
	Use this to access the first touch (will always be valid). If not using multi-touch, this is all you need in most cases.
	#End
	Method GetTouch:Touch() Property
		Return touches[0]
	End
	
	#Rem monkeydoc
	Gives full access to the array of touches. Array will be of length CONGO_MAX_MULTITOUCH. First touch is always at 0.
	#End
	Method GetTouches:Touch[]() Property
		Return touches
	End
	
	#Rem monkeydoc
	Updates the touchmanager data. Call this from your Update loop to keep touch data synced (once per update).

	Dev note: todo, automatically call update from CongoApp?
	#End
	Method Update:Void( dT:Int )
		
		For Local i:Int = 0 Until CONGO_MAX_MULTITOUCH
		
			If TouchDown( i ) > 0 Then
		
				touches[i].touchCurrentPos.Set( VTouchX(i), VTouchY(i) )
				
				If touches[i].touchState = TouchState.CONGO_TOUCHSTATE_NONE Then
					touches[i].touchStartPos.Set( VTouchX(i), VTouchY(i) )
					touches[i].touchState = TouchState.CONGO_TOUCHSTATE_DOWN
				End
	   			
 				touches[i].touchTimer += dT
 				If touches[i].touchHeld = False And touches[i].touchTimer > minHoldTime Then
 					touches[i].touchHeld = True
	 	  		End
	 	  		
	 	  		' see if we are a swipe. do quick manhatten dist check - it gets called a lot
	 	  		If touches[i].swipeState = SwipeState.CONGO_SWIPESTATE_NONE Then
	 	  			
	 	  			' do simple manhatten dist test check first.
	 	  			Local dist:Float = Abs( touches[i].touchCurrentPos.y - touches[i].touchStartPos.y ) +
	 	  			 			 Abs ( touches[i].touchCurrentPos.x - touches[i].touchStartPos.x )  
	 	  			If dist > swipeStartTolerance touches[i].swipeState = SwipeState.CONGO_SWIPESTATE_SWIPING		
	 	  		End
	 	  		
		 	  	If touches[i].swipeState = SwipeState.CONGO_SWIPESTATE_SWIPING touches[i].swipeTimer += dT
		 	 
	 	  	Else If touches[i].touchState = TouchState.CONGO_TOUCHSTATE_DOWN ' touch now ended.
	  	 		
	  	 		touches[i].touchState = TouchState.CONGO_TOUCHSTATE_RELEASED
	  	 		touches[i].touchEndPos.Set( VTouchX(i), VTouchY(i) )
	  	 		
	  	 		' detect final swipe type
	  	 		If Point.PointDist( touches[i].touchStartPos, touches[i].touchEndPos ) > minSwipeDistance Then
	  	 			touches[i].swipeState = SwipeState.CONGO_SWIPESTATE_COMPLETE
					
					' see if it matches a gesture
		  	 		If touches[i].swipeTimer < maxGestureTime touches[i].swipeMotion = DetectGesture( i )

	  	 		Else 
	  	 			touches[i].swipeState = SwipeState.CONGO_SWIPESTATE_NONE
	  	 		End
	   		
	   		Else If touches[i].touchState = TouchState.CONGO_TOUCHSTATE_RELEASED Then
	  	 		
	  	 		touches[i].Reset()
	 	  
	  	 	End
	   	Next
	End

Private
	
	#Rem monkeydoc
	Internal. Detects gestures such as swipe up, swipe left etc (see SwipeMotion states). 
	The range of gestures is fairly basic currently.
	
	Note, we don't check for doubling-back or other things that might invalidate a gesture.
	#End
	Method DetectGesture:Int( index:Int = 0 )
		
		Local motionType:Int = SwipeMotion.CONGO_SWIPEMOTION_MISC
		
	  	Local delta:Point = Point.PointSub( touches[index].touchEndPos, touches[index].touchStartPos )
	  	If delta.y > 1.5 * minSwipeDistance And Abs(delta.x) < 0.5* delta.y Then
	  	 	motionType = SwipeMotion.CONGO_SWIPEMOTION_UP
	  	Else If -delta.y > 1.5 * minSwipeDistance And Abs(delta.x) < -0.5* delta.y Then
	  	 	motionType = SwipeMotion.CONGO_SWIPEMOTION_DOWN
	  	Else If delta.x > 1.5 * minSwipeDistance And Abs(delta.y) < 0.5* delta.x Then
	  		motionType = SwipeMotion.CONGO_SWIPEMOTION_LEFT
	  	Else If -delta.x > 1.5 * minSwipeDistance And Abs(delta.y) < -0.5* delta.x Then
	  	 	motionType = SwipeMotion.CONGO_SWIPEMOTION_RIGHT
	  	Else ' arbitrary swipe
	  	 	motionType = SwipeMotion.CONGO_SWIPEMOTION_MISC
	  	End
	
		Return motionType
	
	End

End
