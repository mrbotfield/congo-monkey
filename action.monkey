#Rem monkeydoc Module congo.action
Action classes, for sprite move/scale/fade tweens. Various ease functions are supported.
Multiple Actions can be run simultaneously, or sequences can be set up via ActionSequence.

All timing is in milliseconds. Completed actions trigger the ActionCompleted 'callback' in DisplayItem.

Actions can generally be applied to any DisplayItem object, which includes layers etc.

Todo - rename alpha to opac, since we changed the fn name in DisplayItem?
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2014. This code is released under the MIT License - see LICENSE.txt.

Strict
Import mojo

Import congo.displayitem
Import congo.easefunction
Import congo.timer

#Rem monkeydoc
Abstract base class for all actions
#End
Class Action Abstract

Private

	Field m_actionId:Int = 0 		' user defined IDs should be > 0.

	Field m_isComplete:Bool = False ' See IsComplete property.
	Field m_repeats:Int = 1 		' Use -1 for repeat forever 
	
	Field m_rptCounter:Int = 1		' counter for looping.
	Field m_item:DisplayItem = Null
	Field m_timer:Timer = New Timer()	' main timer.
	
	Field m_easefn:EaseFunction = Null ' (gets set below. sequences wont have an ease fn)
	
Public

	#Rem monkeydoc
	Initialises data common to all actions. Derived classes call this in their constr.
	#End
	Method Init:Void( item:DisplayItem, duration:Float, ease:EaseFunction, repeats:Int = 1, actionId:Int = 0 )
		
		If actionId < 0 
			Error( CONGO_ERROR_STRING + "actionId less than 0 are reserved." )
			Throw New Throwable()
			Return
		End
		
		m_item = item
		m_actionId = actionId
		m_timer.SetDuration( duration )
		m_repeats = repeats
		m_rptCounter = m_repeats
	
		m_easefn = ease
	End
	
	#Rem monkeydoc
	Returns True is action is complete. Will still return False if action has repeats to run.
	#End
	Method IsComplete:Bool() Property
		Return m_isComplete
	End
	
	#Rem monkeydoc
	Derived actions must implement this.
	#End
	Method Update:Void( dT:Float ) Abstract
	
	#Rem monkeydoc
	Derived actions must implement this. Takes the current item/sprite data and stores it.
	e.g. ActionMoveTo will store the current item/sprite position.
	#End
	Method ResetItemData:Void() Abstract
	
	#Rem monkeydoc
	Internal. Gets called when actions complete each cycle. They are then repeated if more loops remain, 
	else the ActionCompleted callback is triggered.
	#End
	Method OnTimerComplete:Void()
		
		If m_rptCounter > 0 m_rptCounter -= 1
		'Print "OnTimerComplete m_rptCounter is now " + m_rptCounter
		m_timer.Reset() ' gets reset to 0, in case we repeat
		If m_rptCounter = 0 Then
			m_isComplete = True
			m_item.ActionCompleted( m_actionId )
		End
	End
End

#Rem monkeydoc
Delay action. Waits for the specified time. Note - special case, no ease function is used.
#End
Class ActionDelay Extends Action

	Method New( item:DisplayItem, duration:Float, repeats:Int = 1, actionId:Int = 0 )
		Super.Init( item, duration, Null, repeats, actionId )
	End
	
	Method Update:Void( dT:Float )

		If m_isComplete Return
		
		m_timer.Update( dT )
		
		' (nothing else to update - sprite doesnt change)
		
		If m_timer.Completed() Then
			OnTimerComplete()
			m_rptCounter = m_repeats
		End
	End
	
	Method ResetItemData:Void()
		' (nothing to do)
	End

End

#Rem monkeydoc
MoveTo action. Moves the item to the new position.
#End
Class ActionMoveTo Extends Action

Private
	Field m_x1:Float
	Field m_y1:Float
	Field m_x2:Float
	Field m_y2:Float

Public

	Method New( item:DisplayItem, x:Float, y:Float, duration:Float, ease:EaseFunction, repeats:Int = 1, actionId:Int = 0 )
		Super.Init( item, duration, ease, repeats, actionId )
		ResetItemData()
		m_x2 = x
		m_y2 = y
	End
	
	Method ResetItemData:Void()
		m_x1 = m_item.Position.x
		m_y1 = m_item.Position.y
		m_rptCounter = m_repeats
		
	End
	
	Method Update:Void( dT:Float )

		If m_isComplete Return
		
		m_timer.Update( dT )
		
		Local tt:Float = m_easefn.GetValue( m_timer.Progress() )
		m_item.Position.x = m_x1 + ( m_x2 - m_x1) * tt
		m_item.Position.y = m_y1 + ( m_y2 - m_y1) * tt
		
		If m_timer.Completed() Then
			OnTimerComplete()
			' reset our data to reflect final sprite, in case we need to repeat
			' (note - for some actions a repeat makes no sense, but we'll be consistent)
			ResetItemData()
		End
	End
	
End

#Rem monkeydoc
MoveBy action. Moves the item by the specified amount.
#End
Class ActionMoveBy Extends Action

Private
	Field m_x1:Float
	Field m_y1:Float
	Field m_x2:Float
	Field m_y2:Float

Public

	Method New( item:DisplayItem, x:Float, y:Float, duration:Float, ease:EaseFunction, repeats:Int = 1, actionId:Int = 0 )
		Super.Init( item, duration, ease, repeats, actionId )
		ResetItemData()
		m_x2 = x
		m_y2 = y
	End
	
	Method ResetItemData:Void()
		m_x1 = m_item.Position.x
		m_y1 = m_item.Position.y
		m_rptCounter = m_repeats
	End
	
	Method Update:Void( dT:Float )

		If m_isComplete Return
		
		m_timer.Update( dT )
		
		Local tt:Float = m_easefn.GetValue( m_timer.Progress() )
		m_item.Position.x = m_x1 + m_x2 * tt
		m_item.Position.y = m_y1 + m_y2 * tt
		
		If m_timer.Completed() Then
			OnTimerComplete()
			' reset our data to reflect final sprite, in case we need to repeat
			' (note - for some actions a repeat makes no sense, but we'll be consistent)
			ResetItemData()
		End
	End
	
End

#Rem monkeydoc
FadeTo action. Fades the item to the new amount.
#End
Class ActionFadeTo Extends Action

Private
	Field m_alpha1:Float
	Field m_alpha2:Float

Public

	Method New( item:DisplayItem, alpha:Float, duration:Float, ease:EaseFunction, repeats:Int = 1, actionId:Int = 0 )
		Super.Init( item, duration, ease, repeats, actionId )
		ResetItemData()
		m_alpha2 = alpha
	End

	Method ResetItemData:Void()
		m_alpha1 = m_item.Opacity
		m_rptCounter = m_repeats
	End
	
	Method Update:Void( dT:Float )

		If m_isComplete Return
		
		m_timer.Update( dT )
		
		Local tt:Float = m_easefn.GetValue( m_timer.Progress() )
		m_item.SetOpacity( m_alpha1 + ( m_alpha2 - m_alpha1) * tt )
		
		If m_timer.Completed() Then
			OnTimerComplete()
			' reset our data to reflect final sprite, in case we need to repeat
			' (note - for some actions a repeat makes no sense, but we'll be consistent)
			ResetItemData()
		End
	End
	
End

#Rem monkeydoc
ScaleTo action. Scales the item to the new amount. Note, you must provide x and y scale.
#End
Class ActionScaleTo Extends Action

Private
	Field m_x1scale:Float
	Field m_y1scale:Float
	Field m_x2scale:Float
	Field m_y2scale:Float

Public

	Method New( item:DisplayItem, xScale:Float, yScale:Float, duration:Float, ease:EaseFunction, repeats:Int = 1, actionId:Int = 0 )
		Super.Init( item, duration, ease, repeats, actionId )
		ResetItemData()
		m_x2scale = xScale
		m_y2scale = yScale
	End
	
	Method ResetItemData:Void()
		m_x1scale = m_item.XScale
		m_y1scale = m_item.YScale
		m_rptCounter = m_repeats
	End

	Method Update:Void( dT:Float )

		If m_isComplete Return
		
		m_timer.Update( dT )
		
		Local tt:Float = m_easefn.GetValue( m_timer.Progress() )
		m_item.XScale = m_x1scale + ( m_x2scale - m_x1scale ) * tt
		m_item.YScale = m_y1scale + ( m_y2scale - m_y1scale ) * tt
		
		If m_timer.Completed() Then
			OnTimerComplete()
			' reset our data to reflect final sprite, in case we need to repeat
			' (note - for some actions a repeat makes no sense, but we'll be consistent)
			ResetItemData()
		End
	End
	
End

#Rem monkeydoc
RotateTo action. Rotates the item to the new angle. Angle is counter-clockwise in degrees.
#End
Class ActionRotateTo Extends Action

Private
	Field m_angle1:Float
	Field m_angle2:Float

Public
	
	Method New( item:DisplayItem, angle:Float, duration:Float, ease:EaseFunction, repeats:Int = 1, actionId:Int = 0 )
		Super.Init( item, duration, ease, repeats, actionId )
		ResetItemData()
		m_angle2 = angle
	End
	
	Method ResetItemData:Void()
		m_angle1 = m_item.Angle
		m_rptCounter = m_repeats
	End
	
	Method Update:Void( dT:Float )

		If m_isComplete Return
		
		m_timer.Update( dT )
		
		Local tt:Float = m_easefn.GetValue( m_timer.Progress() )
		m_item.Angle = m_angle1 + ( m_angle2 - m_angle1 ) * tt
		
		If m_timer.Completed() Then
			OnTimerComplete()
			' reset our data to reflect final sprite, in case we need to repeat
			' (note - for some actions a repeat makes no sense, but we'll be consistent)
			ResetItemData()
		End
	End
	
End

#Rem monkeydoc
RotateBy action. Rotates the item by the specified amount. Angle is counter-clockwise in degrees.
#End
Class ActionRotateBy Extends Action

Private
	Field m_angle1:Float
	Field m_dangle:Float

Public

	Method New( item:DisplayItem, angle:Float, duration:Float, ease:EaseFunction, repeats:Int = 1, actionId:Int = 0 )
		Super.Init( item, duration, ease, repeats, actionId )
		ResetItemData()
		m_dangle = angle
	End
	
	Method ResetItemData:Void()
		m_angle1 = m_item.Angle
		m_rptCounter = m_repeats
	End
	
	Method Update:Void( dT:Float )

		If m_isComplete Return
		
		m_timer.Update( dT )
		
		Local tt:Float = m_easefn.GetValue( m_timer.Progress() )
		m_item.Angle = m_angle1 + m_dangle*tt
		
		If m_timer.Completed() Then
			OnTimerComplete()
			' reset our data to reflect final sprite, in case we need to repeat
			ResetItemData()
		End
	End
	
End

#Rem monkeydoc
Combined MoveTo, ScaleTo, FadeTo and RotateTo actions.
This is a little ugly, but since its quite common to combine basic actions, this does all 4 main tweens in one, which 
is more efficient than running 4 separate actions.
#End
Class ActionCombined Extends Action

Private
	' note - we do MoveTo, ScaleTo (for both axes). FadeTo, and RotateTo
	Field m_x1:Float
	Field m_y1:Float
	Field m_x2:Float
	Field m_y2:Float
	Field m_alpha1:Float
	Field m_alpha2:Float
	Field m_scale1:Float
	Field m_scale2:Float
	Field m_angle1:Float
	Field m_angle2:Float

Public

	Method New( item:DisplayItem, x:Float, y:Float, alpha:Float, scale:Float, angle:Float, duration:Float, ease:EaseFunction, repeats:Int = 1, actionId:Int = 0 )
		Super.Init( item, duration, ease, repeats, actionId )
		ResetItemData()
		m_x2 = x
		m_y2 = y
		m_alpha2 = alpha
		m_scale2 = scale
		m_angle2 = angle
	End
	
	Method ResetItemData:Void()
		m_x1 = m_item.Position.x
		m_y1 = m_item.Position.y
		m_alpha1 = m_item.Opacity
		m_scale1 = m_item.XScale
		m_angle1 = m_item.Angle
		m_rptCounter = m_repeats
	End
	
	Method Update:Void( dT:Float )

		If m_isComplete Return
		
		m_timer.Update( dT )
		
		Local tt:Float = m_easefn.GetValue( m_timer.Progress() )
		m_item.Position.x = m_x1 + ( m_x2 - m_x1 ) * tt
		m_item.Position.y = m_y1 + ( m_y2 - m_y1 ) * tt
		m_item.Angle = m_angle1 + ( m_angle2 - m_angle1 ) * tt
		m_item.XScale = m_scale1 + ( m_scale2 - m_scale1 ) * tt
		m_item.YScale = m_item.XScale
		m_item.SetOpacity( m_alpha1 + ( m_alpha2 - m_alpha1) * tt )
		
		If m_timer.Completed() Then
			OnTimerComplete()
			ResetItemData()
		End
	End
	
End

#Rem monkeydoc
Special action which runs a sequence of actions in order. No ease function required.
Provide the actions as an array.
#End
Class ActionSequence Extends Action

	Private
	Field m_actions:Action[]
	Field m_curIndex:Int = 0
	
	Method New( actions:Action[], item:DisplayItem, repeats:Int = 1, actionId:Int = 0 )

		Super.Init( item, -1.0, Null, repeats, actionId )
		m_actions = actions
	End
	
	Method ResetItemData:Void()
		' ( nothing to do )
	End
	
	Method Update:Void( dT:Float )
		
		If m_isComplete Return
		
		' special case, update current actions in seq
		m_actions[m_curIndex].Update( dT )
		
		If m_actions[m_curIndex].m_isComplete Then
			If Self.m_rptCounter <> 0 Then  ' reset data since we'll run it again. allow for repeatforver too (-1)
				m_actions[m_curIndex].m_isComplete = False 
			End
			
			m_curIndex += 1
			
			If m_curIndex >= m_actions.Length() Then 
				OnTimerComplete()
				If m_rptCounter <> 0 Then ' go back to first action (allows repeatforever also).
					m_curIndex = 0
				End
			End
			
			' need to reset data for next action
			If m_curIndex < m_actions.Length()
				m_actions[m_curIndex].ResetItemData()
			End
		End
	End

End
