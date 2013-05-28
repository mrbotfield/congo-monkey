#Rem monkeydoc Module congo.easefunction
EaseFunction and derived classes.

Useful sites for tween/ease functions:

	http://gizma.com/easing/, http://www.robertpenner.com/easing/

	- see also the Tweening.monkey example that comes with Monkey.
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
Import mojo

#Rem monkeydoc
Base class for all ease functions. Derived classes implement the GetValue abstract method.
#End
Class EaseFunction Abstract

Public

	#Rem monkeydoc
	Abstract method.
	Returns a value between 0.0 and 1.0 for the given progress value t. 
	t should be in range 0.0 to 1.0. If t => 1.0, will return 1.0.

	Derived classes must implement this.
	#End
	Method GetValue:Float( t:Float ) Abstract

End

#Rem monkeydoc
Returns 0.0 for all values of t less than 1.0. i.e. a step function.
#End
Class EaseNone Extends EaseFunction

	#Rem monkeydoc
	Returns a value between 0.0 and 1.0 for the given progress value t. 
	t should be in range 0.0 to 1.0. If t => 1.0, will return 1.0.
	#End
	Method GetValue:Float( t:Float )
		If t >= 1.0 Return 1.0  
		Return 0.0 ' ie will jump to end state.
	End
End

#Rem monkeydoc
Linear ease.
#End
Class EaseLinear Extends EaseFunction

	#Rem monkeydoc
	Returns a value between 0.0 and 1.0 for the given progress value t. 
	t should be in range 0.0 to 1.0. If t => 1.0, will return 1.0.
	#End
	Method GetValue:Float( t:Float )
		If t >= 1.0 Return 1.0
		Return t
	End
End

#Rem monkeydoc
Ease-in, quadratic (accelerates from zero).
#End
Class EaseInQuad Extends EaseFunction

	#Rem monkeydoc
	Returns a value between 0.0 and 1.0 for the given progress value t. 
	t should be in range 0.0 to 1.0. If t => 1.0, will return 1.0.
	#End
	Method GetValue:Float( t:Float )
		If t >= 1.0 Return 1.0
		Return t*t
	End
End

#Rem monkeydoc
Ease-out, quadratic (decelerates to zero).
#End
Class EaseOutQuad Extends EaseFunction

	#Rem monkeydoc
	Returns a value between 0.0 and 1.0 for the given progress value t. 
	t should be in range 0.0 to 1.0. If t => 1.0, will return 1.0.
	#End
	Method GetValue:Float( t:Float )
		If t >= 1.0 Return 1.0
		Return -t * (t-2.0)
	End
End

#Rem monkeydoc
Ease in and out, quadratic (accelerates to halfway, then decelerates).
#End
Class EaseInOutQuad Extends EaseFunction

	#Rem monkeydoc
	Returns a value between 0.0 and 1.0 for the given progress value t. 
	t should be in range 0.0 to 1.0. If t => 1.0, will return 1.0.
	#End
	Method GetValue:Float( t:Float )
		If t >= 1.0 Return 1.0
		If t < 0.5 Return ( 2.0*t*t )
		t -= 1
		Return 1.0  - ( t*t*2.0 )
	End
End

#Rem monkeydoc
Ease-in, cubic (accelerates from zero). Changes faster than quadratic.
#End
Class EaseInCube Extends EaseFunction

	#Rem monkeydoc
	Returns a value between 0.0 and 1.0 for the given progress value t. 
	t should be in range 0.0 to 1.0. If t => 1.0, will return 1.0.
	#End
	Method GetValue:Float( t:Float )
		If t >= 1.0 Return 1.0
		Return t*t*t
	End
End

#Rem monkeydoc
Ease-out, cubic (decelerates to zero). Changes faster than quadratic.
#End
Class EaseOutCube Extends EaseFunction

	#Rem monkeydoc
	Returns a value between 0.0 and 1.0 for the given progress value t. 
	t should be in range 0.0 to 1.0. If t => 1.0, will return 1.0.
	#End
	Method GetValue:Float( t:Float )
		If t >= 1.0 Return 1.0
		t -= 1.0
		Return 1.0 + ( t*t*t ) 
	End
End

#Rem monkeydoc
Ease in and out, cubic (accelerates to halfway, then decelerates).
#End
Class EaseInOutCube Extends EaseFunction

	#Rem monkeydoc
	Returns a value between 0.0 and 1.0 for the given progress value t. 
	t should be in range 0.0 to 1.0. If t => 1.0, will return 1.0.
	#End
	Method GetValue:Float( t:Float )
		If t >= 1.0 Return 1.0
		If t <= 0.5 Return ( t*t*t*4.0)
		t -= 1.0
		Return 1.0 + ( t*t*t*4.0 )
	End
End

#Rem monkeydoc
Ease-in, quartic (accelerates from zero). Changes faster than cubic.
#End
Class EaseInQuart Extends EaseFunction ' Quart changes faster than cube.

	#Rem monkeydoc
	Returns a value between 0.0 and 1.0 for the given progress value t. 
	t should be in range 0.0 to 1.0. If t => 1.0, will return 1.0.
	#End
	Method GetValue:Float( t:Float )
		If t >= 1.0 Return 1.0
		Return t*t*t*t
	End
End

#Rem monkeydoc
Ease-out, quartic (decelerates to zero). Changes faster than cubic.
#End
Class EaseOutQuart Extends EaseFunction

	#Rem monkeydoc
	Returns a value between 0.0 and 1.0 for the given progress value t. 
	t should be in range 0.0 to 1.0. If t => 1.0, will return 1.0.
	#End
	Method GetValue:Float( t:Float )
		If t >= 1.0 Return 1.0
		t -= 1.0
		Return 1.0 - ( t*t*t*t )
	End
End

#Rem monkeydoc
Ease in and out, quartic (accelerates to halfway, then decelerates).
#End
Class EaseInOutQuart Extends EaseFunction

	#Rem monkeydoc
	Returns a value between 0.0 and 1.0 for the given progress value t. 
	t should be in range 0.0 to 1.0. If t => 1.0, will return 1.0.
	#End
	Method GetValue:Float( t:Float )
		If t >= 1.0 Return 1.0
		If t <= 0.5 Return ( t*t*t*t*8.0)
		t = ( 2.0*t ) - 2.0
		Return 0.5 + ( 1.0 - t*t*t*t) / 2.0
	End
End
