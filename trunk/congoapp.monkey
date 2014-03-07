#Rem monkeydoc Module congo.congoapp
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
Import mojo
Import congo.sprite
Import congo.applayer
Import congo.congosettings
Import congo.autofit
Import congo.transition
Import congo.displayutils
Import congo.textutils
Import congo.soundplayer

#Rem monkeydoc
Main app class - derive your main game app from this class. CongoApp deals with applayers, transitions and so on.
Currently, CongoApp can only have one active applayer.

Derives from the mojo App class.
#End
Class CongoApp Extends App

Public	 
	
	Field gameMilliSecs:Float = 0.0
	Field dT:Float = 0.0
	
	#Rem monkeydoc
	Pause state. Use IsPaused() to access this.
	#End
	Global paused:Bool = False
	
	#Rem monkeydoc
	See SetCurrentLayer() to set this. Under normal use there can only be 1 active applayer.
	(this is a shared data member so we can access it from a non-member function).
	#End
	Global currentLayer:AppLayer = Null
	
	#Rem monkeydoc
	See RunTransition(). 
	#End
	Global transition:Transition = Null 
	
	#Rem monkeydoc
	See SetScreenColor().
	#End
	Global clsColor:Float[] = [ 0.0, 0.0, 0.0 ]

	#Rem monkeydoc
	(Advanced use). On creation, the app class stores a global image res scaler. Usually you can let CongoImageLoader set a 
	Sprite's own res scaler, but this provides another way to access this, e.g. if you need to scale something
	outside of a regular Sprite.
	#End
	Global imageResScaler:Float = 1.0
	
	#Rem monkeydoc
	Used for framerate calculation, see comments in code to enable.
	#End
	Field  rendertimer:Int
	#Rem monkeydoc
	Used for framerate calculation, see comments in code to enable.
	#End
	Field  renderframes:Int
	#Rem monkeydoc
	Used for framerate calculation, see comments in code to enable.
	#End
	Global renderfps:Int

Private
	#Rem monkeydoc
	Used by pause routine to store the current rate, ready for resume.
	#End
	Global m_resumeUpdateRate:Int 
	
Public
	
	#Rem monkeydoc
	Overrides mojo App method.
	#End
	Method OnCreate:Int()

		CongoLog( "CongoApp: OnCreate. " + CONGO_NAME_STRING + " version " + CONGO_VERSION_STRING )
		
		If IsUsingXHDResources() Then
			imageResScaler = 4.0
		Else If IsUsingHDResources() Then
			imageResScaler = 2.0
		Else
			imageResScaler = 1.0
		End

		SetPaused( False ) ' ensures the function gets processed by Monkey trans (flash native uses it even if we dont).
		Return 0
	
	End
	
	#Rem monkeydoc
	Sets the base background color for drawing. Will be seen through transparent sections and some transition effects. 
	Default is black. Can be called from anywhere (not a member function).
	#End
	Function SetScreenColor:Void( r:Float, g:Float, b:Float )
		clsColor = [ r, g, b ]
	End
	
	#Rem monkeydoc 
	Returns True when game is paused. Various Update() functions use this to pause themselves. You may need to use
	it if you write some custom Update() method.
	#End
	Function IsPaused:Bool()
		Return paused
	End
	
	#Rem monkeydoc 
	The main pause function. See also TogglePaused(). Will pause sounds and music, but will still call Update() 
	methods of layers/sprites and so on. Draw() methods are also still called but at a reduced framerate of 10fps 
	(To reduce unnecessary cpu usage). If using custom Update code you need to check IsPaused() after 
	Super.Update() and return if paused. 
	#End
	Function SetPaused:Void( state:Bool )
		
		If paused = state Return 
		paused = state

		If paused Then
			m_resumeUpdateRate = UpdateRate()
			SetUpdateRate( 10 )
			' [BRS] Was using PauseAll but hangs in Flash - a bug? Use StopAll for now.
			SoundPlayer.StopAll()
			PauseMusic() ' mojo fn
			If currentLayer currentLayer.LayerPaused()
			CongoLog( "SetPaused TRUE" )
		Else
			SetUpdateRate( m_resumeUpdateRate )
			SoundPlayer.ResumeAll()
			ResumeMusic() ' mojo fn
			If currentLayer currentLayer.LayerResumed()
			CongoLog( "SetPaused FALSE" )
		End

	End
	
	#Rem monkeydoc
	Convenience function to toggle the pause state. See also SetPaused().
	#End
	Function TogglePaused:Void()
		If paused Then
			SetPaused( False )
		Else 
			SetPaused( True )
		End		
	End
	
	#Rem monkeydoc
	This function controls the currently displayed applayer. As a non-member, it can be called from anywhere.
	 Any previous layer is 'discarded' (GC will discard it). Textures will be retained unless the optional 
	clearTextureCache parameter is set. 
	TODO: clearTextureCache should be removed? The new layer already exists before the cache is cleared! Clear it manually beforehand.
	#End
	Function SetCurrentLayer:Void( layer:AppLayer, clearTextureCache:Bool = False )
		
		If currentLayer currentLayer.RemoveAllChildren() ' not really needed, but we'll do it.
		If clearTextureCache TextureCache.getInstance().RemoveAll()
	
		currentLayer = layer
	End
	
	#Rem monkeydoc
	Sets a transition effect to run over the current layer.
	If a transition already exists you can not set a new one, the function will return False.
	#End
	Function RunTransition:Bool( trans:Transition )

		If transition Then
			CongoLog( CONGO_WARNING_STRING + "Can not set a transition if one is already running." )
			Return False 
		Else
			transition = trans
		End
		Return True
	End
	
	#Rem monkeydoc
	Overrides mojo App OnUpdate() method.

	Dev note - we follow the basic idea of using the standard OnUpdate and OnRender steps in mojo. In reality, this
	separation is not mandatory, you can in fact do everything in OnRender to avoid Monkey's update/render 
	smoothing algorithm, see http://www.monkeycoder.co.nz/Community/posts.php?topic=1436. Since we use a delta time
	method, it may in fact not be sensible to mix these two, but we'll use it for now.
	#End
	Method OnUpdate:Int()
	
		Local curTime:Int = Millisecs()
	  	dT =  curTime - gameMilliSecs
	  	If dT > 100 dT = 100 ' cap at min 10fps worse case to avoid bad glitches.
	   	gameMilliSecs = curTime		
	   	
	  	If currentLayer currentLayer.Update( dT )

	  	If transition Then
	  		transition.Update( dT )
	  		If transition.Completed() Then
	  			Local id:String = transition.id
	  			transition = Null ' (do before TransitionCompleted, in case a new transition gets set there)
	  			currentLayer.TransitionCompleted( id )
	  		End
		End
		
		Return 0
	End
	
	#Rem monkeydoc
	Overrides mojo App OnRender() method.

	There is a section of code you can enable to measure framerate performance.
	#End
	Method OnRender:Int()

		UpdateVirtualDisplay() ' Autofit (using default args). Do this first.
	    	PushMatrix()
		
		Cls( clsColor[0], clsColor[1], clsColor[2] )	
		
		If transition Then
			transition.Draw( currentLayer )
		Else
			currentLayer.Draw()
		End

		#Rem		
		' Framerate counter. Enable this section for testing (note, render-time. Monkey may slow Render to do Update loop).	
		renderframes += 1
		Local wait:Int = Millisecs() - rendertimer
		If wait >= 1000 Then
			renderfps = renderframes
			renderframes = 0
			rendertimer += wait
		End
		DrawText( "rFPS: " + renderfps, 5, 5, 0, 0 )
		#End
			
		PopMatrix()	
		
		Return 0
	End
	
	#Rem monkeydoc
	Overrides mojo App OnSuspend() method.
	#End
	Method OnSuspend:Int()
	
		Super.OnSuspend()
		CongoLog( "OnSuspend" )
		
		Return 0
	End
	
	#Rem monkeydoc
	Overrides mojo App OnResume() method.
	#End
	Method OnResume:Int()
	
		Super.OnResume()
		CongoLog( "OnResume" )
		
		Return 0
	End

End
