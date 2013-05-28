#Rem monkeydoc Module congo.timer
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt. 

Strict
Import mojo
Import congo.congosettings

#Rem monkeydoc
A simple timer class. 

Note - we work in milliseconds (as Monkey/Mojo tends to), but choose to use Floats here.
#End
Class Timer

Private
	
	Field m_curtime:Float = 0.0
	Field m_duration:Float = 0.0
	'Field m_paused:Bool = False ' currently no pause
	
Public

	#Rem monkeydoc
	Creates a timer with zero duration.
	#End
	Method New()
	End
	
	#Rem monkeydoc
	Creates a timer of specified duration (in milliseconds). Timers start at 0.0.
	#End
	Method New( duration:Float, current:Float = 0.0 )
		m_curtime = current
		SetDuration( duration )
	End

	#Rem monkeydoc
	(Deprecated - use Duration property).
	Sets the timer duration.
	#End
	Method SetDuration:Void( duration:Float )
		m_duration = duration
	End

	#Rem monkeydoc
	Sets the duration of the timer, in milliseconds.
	#End
	Method Duration:Void( duration:Float ) Property
		m_duration = duration
	End 

	#Rem monkeydoc
	Returns the duration of the timer, in milliseconds.
	#End
	Method Duration:Float() Property
		Return m_duration
	End

	#Rem monkeydoc
	Returns the current time in milliseconds.
	#End
	Method CurrentTime:Float() Property
		Return m_curtime
	End

	#Rem monkeydoc
	Sets the current time in milliseconds. (not usually required in normal use, Update sets the time). See also Reset().
	#End
	Method CurrentTime:Void( time:Float ) Property
		m_curtime = time
	End

	#Rem monkeydoc
	Returns the proportion completed, i.e. starts at 0.0, ends at 1.0.

	Note - could return > 1.0 if timer steps beyond duration (for efficiency we dont clamp it here). Returns 1.0 if duration is zero.
#End
	Method Progress:Float()
		If m_duration <> 0.0 Return Self.CurrentTime() / Self.Duration()
		Return 1.0
	End

	#Rem monkeydoc
	Resets the current time to 0.0. The timer will continue running.
	#End
	Method Reset:Void( time:Float = 0.0 )
		m_curtime = time
	End
	
	#Rem monkeydoc
	Updates the timer. Generally called from a parent or layer's Update method.
	#End 
	Method Update:Void( dT:Float )
		m_curtime += dT
	End

	#Rem monkeydoc
	Returns True if the current time exceeds or equals the Timer's duration.
	#End
	Method Completed:Bool()
		Return ( m_curtime >= m_duration )	
	End

End

