#Rem monkeydoc Module congo.applayer
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
Import mojo

Import congo.layer
Import congo.textutils

#Rem monkeydoc 
An AppLayer is essentially just a regular layer but can be set as the current 'top level' 
layer in CongoApp, and has a number of extra features such as receiving Pause/Resume calls.
Typically, you will want to derive from AppLayer to create your game/menu layers.
#End
Class AppLayer Extends Layer
	
Private	

	Method New()
		' here to prevent Monkey allowing direct use of a default constr.
		' (see http://www.monkeycoder.co.nz/Community/posts.php?topic=834 )
	End

Public
	#Rem monkeydoc
	Creates an applayer with specified size (in device points, ie autofit virtual coords).
	#End
	Method New( w:Int, h:Int )
		
		Super.New( w, h )

	End	

	#Rem monkeydoc
	Derived classes can implement this to deal with transitions. CongoApp calls this when an outgoing
	transition on a layer completes. For example, you may want to do resource clean-up, create the new
	layer, then call SetCurrentLayer to show it. Use the transition id to differentiate transitions.
	#End
	Method TransitionCompleted:Void( id:String )

		CongoLog( "TransitionCompleted, id is " + id )

	End
	
	#Rem monkeydoc
	This gets called by CongoApp when game is paused. Override as required.
	#End
	Method LayerPaused:Void()
	'	(overide in derived class as required)
	End
	
	#Rem monkeydoc
	This gets called by CongoApp when game is resumed. Override as required.
	#End
	Method LayerResumed:Void()
	'	(overide in derived class as required)
	End

End
