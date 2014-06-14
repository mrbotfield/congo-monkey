#Rem monkeydoc Module congo.transition
Layer transition effect classes.
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict

Import mojo
Import congo.sprite
Import congo.easefunction
Import congo.displayutils
Import congo.layer
Import congo.timer
Import congo.autofit

#Rem monkeydoc
Abstract base class for all layer transition effects.

Transitions are designed to be used via CongoApp.RunTransition(), and are run on outgoing and
incoming layers separately. On completion, TransitionCompleted() is called on the current layer. 

Dev note - transitions are implemented in a rather basic way, partly to avoid having 
multiple layers loaded at once, or the use of screen grab images. i.e. they are mostly suited to
simple fades and wipes which remove one layer before revealing the next. This may be improved later.

#End
Class Transition

'Todo - should use properties here.
Public
	#Rem monkeydoc
	Main timer.
	#End
	Field ttimer:Timer = New Timer()
	#Rem monkeydoc
	Delay before effect starts.
	#End
	Field dtimer:Timer = Null
	#Rem monkeydoc
	Optional background sprite for transition. Don't set handle on image or sprite.
	#End
	Field bgSprite:Sprite = Null 
	#Rem monkeydoc
	Set to True to run a transition effect in reverse.
	#End
	Field reverse:Bool = False
	#Rem monkeydoc
	Background color, defaults to black.
	#End
	Field bgColor:Float[] = [ 0.0, 0.0, 0.0 ] 
	#Rem monkeydoc
	Used to identify this transition.
	#End
	Field id:String
	#Rem monkeydoc
	Ease function. Will be linear if none supplied in constr.
	#End
	Field easefn:EaseFunction = Null 
	
	#Rem monkeydoc
	If no ease if specified, linear is used. Not all transitions support an ease function (e.g. fade is linear).
	Use the 'reverse' option to reverse the timeline of an effect. Similarly, not all effects have a reverse.

	Dev note - 'bgSprite' is optional. Originally intended to store a screen grab, so more complex transitions can be
	drawn, but this is currently not implemented.
	Dev note - some transitions may not be draw perfectly if using extreme layer scale/rotate.
	#End
	Method New( duration:Float = 2000, reverse:Bool = False, ease:EaseFunction = Null, delay:Float = 0.0, idstring:String = "" )
	
		ttimer.SetDuration( duration )
		
		If delay > 0.0 dtimer = New Timer( delay )
		id = idstring
		Self.reverse = reverse
		
		easefn = ease
		If Not easefn easefn = New EaseLinear() 
	
	End
	
	#Rem monkeydoc
	Sets the Id property.
	#End
	Method Id:Void( id:String ) Property
		idstring = id
	End
	
	#Rem monkeydoc
	Returns the Id property.
	#End
	Method Id:String() Property
		Return idstring
	End

	Method Update:Void( dT:Int )
	
		If dtimer Then
			dtimer.Update( dT )
			If dtimer.Completed() dtimer = Null
		Else
			ttimer.Update( dT )
		End

	End
	
	#Rem monkeydoc
	Transitions use this to get progress amount. It ensures a range of 0.0 to 1.0.
	#End
	Method Progress:Float()
		
		Local progress:Float = easefn.GetValue( ttimer.Progress() )
		' prev progress:Float = ttimer.Progress()
		
		If reverse progress = 1.0 - progress
		
		If progress > 1.0 progress = 1.0
		If progress < 0.0 progress = 0.0
		
		Return progress
		
	End
	
	#Rem monkeydoc
	Returns True when the transition is complete (internally, just returns the timer completed status).
	#End
	Method Completed:Bool()
	
		Return ttimer.Completed()
		
	End
	
	#Rem monkeydoc
	Abstract draw method -- derived classes must implement this. 
	
	Dev note - since this is called from the end of CongoApp OnRender, the original transform matrix
	will be restored there (i.e. we dont need push/pop matrix here).
	#end
	Method Draw:Void( layer:Layer ) Abstract
	
End

#Rem monkeydoc
Fade-out transition.
#End
Class TransitionFadeOut Extends Transition
	
	Method New( duration:Int = 1000, reverse:Bool = False, ease:EaseFunction = Null, delay:Int = 0, idstring:String = "" )
		Super.New( duration, reverse, ease, delay, idstring )
	End

	Method Draw:Void( layer:Layer )
	
		layer.Draw() ' draw layer first
		
		If dtimer Return ' waits
	
		Local progress:Float = Progress()
		
		' optional sprite 'bg'
		If bgSprite bgSprite.Draw()
		
		SetAlpha( progress )
			
		SetColor( bgColor[0], bgColor[1], bgColor[2]  )
		DrawRect( -0.5*VDeviceWidth(), -0.5*VDeviceHeight(), 2.0*VDeviceWidth(), 2.0*VDeviceHeight() ) ' bit ugly :/
		SetAlpha( 1.0 )
		SetColor( 255, 255, 255 ) ' Important!
		
	End

End

#Rem monkeydoc
Wipe transition. Wipes across from right.
#End
Class TransitionWipeAcross Extends Transition
	
	Method New( duration:Int = 1000, reverse:Bool = False, ease:EaseFunction = Null, delay:Int = 0, idstring:String = "" )
		Super.New( duration, reverse, ease, delay, idstring )
	End

	Method Draw:Void( layer:Layer )
	
		layer.Draw() ' draw layer first
		
		If dtimer Return ' waits
	
		Local progress:Float = Progress()
		
		' optional sprite 'bg'
		If bgSprite bgSprite.Draw()
		
		' SetAlpha( progress )
			
		SetColor( bgColor[0], bgColor[1], bgColor[2]  ) 
	
		Translate( (1.0-progress)*VDeviceWidth(), 0.0 )
		DrawRect( -10.0, -0.5*VDeviceHeight(), 2.0*VDeviceWidth(), 2.0*VDeviceHeight() ) ' bit ugly :/
		Translate( -(1.0-progress)*VDeviceWidth(), 0.0 )
		
		SetColor( 255, 255, 255 ) ' Important!
		
	End

End

#Rem monkeydoc
Wipe diagonal transition. Wipes from top left to bottom right.
#End
Class TransitionWipeDiagonal Extends Transition
	
	Method New( duration:Int = 1000, reverse:Bool = False, ease:EaseFunction = Null, delay:Int = 0, idstring:String = "" )
		Super.New( duration, reverse, ease, delay, idstring )
	End

	Method Draw:Void( layer:Layer )
	
		layer.Draw() ' draw layer first
		
		If dtimer Return ' waits
	
		Local progress:Float = Progress()
		
		' optional sprite 'bg'
		If bgSprite bgSprite.Draw()
			
		SetColor( bgColor[0], bgColor[1], bgColor[2]  )
	
		Rotate( 45.0 )
		DrawRect( -VDeviceHeight(), -VDeviceHeight(), progress*4.0*VDeviceWidth(), progress*4.0*VDeviceHeight() ) ' bit ugly :/
		Rotate( -45.0 )
		
		SetColor( 255, 255, 255 ) ' Important!
		
	End

End

#Rem monkeydoc
Strips transition. Horizontal strips move across from each side.
#End
Class TransitionStrips Extends Transition
	
	Method New( duration:Int = 1000, reverse:Bool = False, ease:EaseFunction = Null, delay:Int = 0, idstring:String = "" )
		Super.New( duration, reverse, ease, delay, idstring )
	End

	Method Draw:Void( layer:Layer )
	
		layer.Draw() ' draw layer first
		
		If dtimer Return ' waits
	
		Local progress:Float = Progress()
		
		' optional sprite 'bg'
		If bgSprite bgSprite.Draw()
		
		Local size:Float = 0.1*Max( VDeviceWidth(), VDeviceWidth()  )
		
		SetColor( bgColor[0], bgColor[1], bgColor[2]  )
		
		For Local i:Int = 0 To 20 Step 2
			DrawRect( -2.0*VDeviceWidth() + 1.1*(progress)*VDeviceWidth(), -0.5*VDeviceHeight() + i*size, 2.0*VDeviceWidth(), 2+size )
		End
		For Local i:Int = 1 To 20 Step 2
			DrawRect( VDeviceWidth() - 1.1*(progress)*VDeviceWidth(), -0.5*VDeviceHeight() + i*size, 2.0*VDeviceWidth(), 2+size )
		End
		
		SetColor( 255, 255, 255 ) ' Important!
		
	End

End

#Rem monkeydoc
Drop strips transition. Strips drop down then fill out.
#End
Class TransitionDropStrips Extends Transition
	
	Method New( duration:Int = 1000, reverse:Bool = False, ease:EaseFunction = Null, delay:Int = 0, idstring:String = "" )
		Super.New( duration, reverse, ease, delay, idstring )
	End

	Method Draw:Void( layer:Layer )
	
		layer.Draw() ' draw layer first
		
		If dtimer Return ' waits
	
		Local progress:Float = Progress()
		
		' optional sprite 'bg'
		If bgSprite bgSprite.Draw()
		
		Local size:Float = 0.1*Max( VDeviceWidth(), VDeviceWidth()  )
		
		SetColor( bgColor[0], bgColor[1], bgColor[2]  )
		
		Local bsz:Float
		For Local yb:Int = 0 Until 20
			For Local xb:Int = 0 Until 20
				
				bsz = size * progress	
				DrawRect( -0.5*VDeviceWidth() + xb*size, -0.5*VDeviceHeight() + yb*bsz, 2+bsz, 2+bsz )
					
			Next
		Next
		
		SetColor( 255, 255, 255 ) ' Important!
		
	End

End

#Rem monkeydoc
Grid squares transition. A grid of squares enlarges to fill screen.
#End
Class TransitionGridSquares Extends Transition
	
	Method New( duration:Int = 1000, reverse:Bool = False, ease:EaseFunction = Null, delay:Int = 0, idstring:String = "" )
		Super.New( duration, reverse, ease, delay, idstring )
	End

	Method Draw:Void( layer:Layer )
	
		layer.Draw() ' draw layer first
		
		If dtimer Return ' waits
	
		Local progress:Float = Progress()
		
		' optional sprite 'bg'
		If bgSprite bgSprite.Draw()
		
		Local size:Float = 0.1*Max( VDeviceWidth(), VDeviceWidth()  )
		
		SetColor( bgColor[0], bgColor[1], bgColor[2]  )
		
		Local bsz:Float
		For Local yb:Int = 0 Until 20
			For Local xb:Int = 0 Until 20
				
				bsz = size * progress
				'bsz = size * 0.5	
				DrawRect( -0.5*VDeviceWidth() + xb*size - 0.5*bsz, -0.5*VDeviceHeight() + yb*size - 0.5*bsz , 2+bsz, 2+bsz )
					
			Next
		Next
		
		SetColor( 255, 255, 255 ) ' Important!
		
	End

End

#Rem monkeydoc
Spin out transition. Spins the whole screen and zooms out.
#End
Class TransitionSpinOut Extends Transition
	
	Method New( duration:Int = 1000, reverse:Bool = False, ease:EaseFunction = Null, delay:Int = 0, idstring:String = "" )
		Super.New( duration, reverse, ease, delay, idstring )
	End

	Method Draw:Void( layer:Layer )
	
		If dtimer Then
			layer.Draw()
			Return ' waits
		End
	
		Local progress:Float = Progress()
		
		' optional sprite 'bg'
		If bgSprite bgSprite.Draw()
		
		' remember to translate to layer centre, and back, before drawing layer as normal
		Translate( layer.Position.X + layer.Handle.X, layer.Position.Y + layer.Handle.Y )
		Rotate( progress*720.0)
		Scale( 1.0-progress, 1.0-progress )
		Translate( -layer.Position.X - layer.Handle.X, -layer.Position.Y - layer.Handle.Y )
		
		layer.Draw() ' draw after transform
	End

End

#Rem monkeydoc
Slide left transition. Slides the screen off to the left.
#End
Class TransitionSlideLeft Extends Transition
	
	Method New( duration:Int = 1000, reverse:Bool = False, ease:EaseFunction = Null, delay:Int = 0, idstring:String = "" )
		Super.New( duration, reverse, ease, delay, idstring )
	End

	Method Draw:Void( layer:Layer )
	
		If dtimer Then
			layer.Draw()
			Return ' waits
		End
	
		Local progress:Float = Progress()
		
		' optional sprite 'bg'
		If bgSprite bgSprite.Draw()
		
		Translate( -progress*layer.width, 0.0 )
		
		layer.Draw() ' draw after transform
	End

End

#Rem monkeydoc
Slide down transition. Slides the screen down from top.
#End
Class TransitionSlideDown Extends Transition
	
	Method New( duration:Int = 1000, reverse:Bool = False, ease:EaseFunction = Null, delay:Int = 0, idstring:String = "" )
		Super.New( duration, reverse, ease, delay, idstring )
	End

	Method Draw:Void( layer:Layer )
	
		If dtimer Then
			layer.Draw()
			Return ' waits
		End
	
		Local progress:Float = Progress()
		
		' optional sprite 'bg'
		If bgSprite bgSprite.Draw()
		
		Translate( 0.0, +progress*layer.LayerHeight )
		
		layer.Draw() ' draw after transform
	End

End

#Rem monkeydoc
Zoom transition. Zooms the screen in.
#End
Class TransitionZoom Extends Transition
	
	Method New( duration:Int = 1000, reverse:Bool = False, ease:EaseFunction = Null, delay:Int = 0, idstring:String = "" )
		Super.New( duration, reverse, ease, delay, idstring )
	End

	Method Draw:Void( layer:Layer )
	
		If dtimer Then
			layer.Draw()
			Return ' waits
		End
	
		Local progress:Float = Progress()
		
		' optional sprite 'bg'
		If bgSprite bgSprite.Draw()
		
		' remember to translate to layer centre, and back, before drawing layer as normal
		Translate( layer.Position.x + layer.Handle.X, layer.Position.Y + layer.Handle.Y )
		Scale( 1.0 + progress, 1.0 + progress )
		Translate( -layer.Position.x - layer.Handle.X, -layer.Position.Y - layer.Handle.Y )
		
		layer.Draw() ' draw after transform
	End

End

#Rem monkeydoc
Door open transition.
Dev note - requires 2 draw calls of layer.
#End
Class TransitionDoorsOpen Extends Transition
	
	Method New( duration:Int = 1000, reverse:Bool = False, ease:EaseFunction = Null, delay:Int = 0, idstring:String = "" )
		Super.New( duration, reverse, ease, delay, idstring )
	End

	Method Draw:Void( layer:Layer )
	
		If dtimer Then
			layer.Draw()
			Return ' waits
		End
	
		Local progress:Float = Progress()
		
		' optional sprite 'bg'
		If bgSprite bgSprite.Draw()
		
		' NB scissor uses device pixel coords, NOT virtual/autofit. unaffected by transforms.
		SetScissor( 0.0, 0.0, 0.5*(1.0-progress)*DeviceWidth(), DeviceHeight() )
		Translate( -0.5*progress*layer.LayerWidth, 0.0 )
		layer.Draw() 
		
		SetScissor( (0.5+0.5*progress)*DeviceWidth(), 0.0, 0.5*(1.0-progress)*DeviceWidth(), DeviceHeight() )
		Translate( +progress*layer.LayerWidth, 0.0 )
		layer.Draw() 
		
		SetScissor( 0.0, 0.0, DeviceWidth(), DeviceHeight() ) ' Important! 
		
	End

End

#Rem monkeydoc
Circle transition. Circle grows to fill screen
#End
Class TransitionCircleGrow Extends Transition
	
	Method New( duration:Int = 1000, reverse:Bool = False, ease:EaseFunction = Null, delay:Int = 0, idstring:String = "" )
		Super.New( duration, reverse, ease, delay, idstring )
	End

	Method Draw:Void( layer:Layer )
	
		If dtimer Then
			layer.Draw()
			Return ' waits
		End
		
		layer.Draw() ' draw layer first
	
		Local progress:Float = Progress()
		
		' optional sprite 'bg'
		If bgSprite bgSprite.Draw()
		
		SetColor( bgColor[0], bgColor[1], bgColor[2]  )
		
		Local size:Float = Max( VDeviceWidth(), VDeviceWidth()  )
		Translate( layer.Position.X + layer.Handle.X, layer.Position.Y + layer.Handle.Y )
		DrawCircle( 0.0, 0.0, progress*size )
		Translate( -layer.Position.X - layer.Handle.X, -layer.Position.Y - layer.Handle.Y )
		
		SetColor( 255, 255, 255 ) ' Important!
	End

End

#Rem monkeydoc
Block-out transition. Covers the screen with random blocks until it is filled. Use reverse to reveal.
#End
Class TransitionBlockOut Extends Transition
	
	Const nlblks:Int = 20
	Field blocks:Int[] = New Int[nlblks*nlblks]
	Field nfilled:Int = 0
	
	Method New( duration:Int = 1000, reverse:Bool = False, ease:EaseFunction = Null, delay:Int = 0, idstring:String = "" )
		Super.New( duration, reverse, ease, delay, idstring )
	End

	Method Draw:Void( layer:Layer )
	
		If dtimer Then
			layer.Draw()
			Return ' waits
		End
		
		layer.Draw() ' draw layer first
	
		Local progress:Float = Progress()
		
		' reverse behavior slightly different here:
		If reverse progress = 1.0 - progress
		
		' optional sprite 'bg'
		If bgSprite bgSprite.Draw()
		
		SetColor( bgColor[0], bgColor[1], bgColor[2]  )
	
		Local xr:Int
		Local yr:Int
		Local size:Float = 0.1*Max( VDeviceWidth(), VDeviceWidth()  )
		
		While nfilled < progress * nlblks * nlblks
		
			' find an unfilled block to fill
			xr = Rnd(nlblks)
			yr = Rnd(nlblks)
			Local arpos:Int = xr*yr 
			While arpos >= 0 And blocks[arpos] = 1
				arpos -= 1
			End
			' search other way
			If arpos < 0 Or blocks[arpos] = 1 arpos = xr*yr
			While arpos < nlblks And blocks[arpos] = 1
				arpos += 1
			End
			If arpos >= nlblks*nlblks arpos = 0
			blocks[arpos] = 1
			nfilled += 1
			
		End
		
		Local arraypos:Int = 0
		For Local yb:Int = 0 Until nlblks
			For Local xb:Int = 0 Until nlblks
				
				If Not reverse Then
					If blocks[arraypos] = 1 Or progress > 0.95 Then
						DrawRect( -0.5*VDeviceWidth() + xb*size, -0.5*VDeviceHeight() + yb*size, 2+size, 2+size )
					End
				Else
					If blocks[arraypos] = 0 Or progress < 0.05 Then
						DrawRect( -0.5*VDeviceWidth() + xb*size, -0.5*VDeviceHeight() + yb*size, 2+size, 2+size )
					End
				End
				arraypos += 1
			Next
		Next
	
		SetColor( 255, 255, 255 ) ' Important!		
	End

End
