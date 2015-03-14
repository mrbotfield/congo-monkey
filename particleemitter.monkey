#Rem monkeydoc Module congo.particleemitter
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
Import mojo

Import congo.sprite
Import congo.congoapp

#Rem monkeydoc 
Simple data structure to hold particle state (all fields are public for simplicity).
#End
Class Particle
Public 

	#Rem monkeydoc
	X position.
	#End
	Field posX:Float = 0.0
	#Rem monkeydoc
	Y position.
	#End
	Field posY:Float = 0.0
	#Rem monkeydoc
	X velocity.
	#End
	Field velX:Float = 0.0
	#Rem monkeydoc
	Y velocity.
	#End
	Field velY:Float = 0.0
	#Rem monkeydoc
	Rotation.
	#End
	Field rotation:Float = 0.0
	#Rem monkeydoc
	Alpha (opacity). Default 1.0.
	#End
	Field alpha:Float = 1.0
	#Rem monkeydoc
	Scale. Default 1.0. Individual particle scales will combine with this overall scale.
	#End
	Field scale:Float = 1.0
	#Rem monkeydoc
	Lifetime of particle remaining, in ms units. Default 5000.
	#End
	Field life:Int = 5000 ' in ms.
	
End

#Rem monkeydoc
A particle emitter system. Derives from Sprite, can be treated as such, added as a child to another sprite or layer.
(main data is public for simplicity).

If you use the built-in particle texture sheet, remember to copy congoparticles.png into your data folder.
#End
Class ParticleEmitter Extends Sprite

Public

	#Rem monkeydoc
	Start X position variance.
	#End
	Field startPosXVariance:Float = 10.0
	#Rem monkeydoc
	Start Y position variance.
	#End
	Field startPosYVariance:Float = 10.0

	#Rem monkeydoc
	Start X velocity.
	#End
	Field startVelX:Float = 0.0
	#Rem monkeydoc
	Start Y velocity.
	#End
	Field startVelY:Float = 0.0
	#Rem monkeydoc
	Start X velocity variance.
	#End
	Field startVelXVariance:Float = 0.02
	#Rem monkeydoc
	Start Y velocity variance.
	#End
	Field startVelYVariance:Float = 0.02

	#Rem monkeydoc
	Starting size (scale).
	#End
	Field startSize:Float = 0.5 ' 1.0
	#Rem monkeydoc
	Starting size variance.
	#End
	Field startSizeVariance:Float = 0.1
	#Rem monkeydoc
	Shink rate. Can be negative to grow in size.
	#End
	Field shrinkRate:Float = 0.1 / 1000.0 
	
	#Rem monkeydoc
	Start alpha (opacity). Default 1.0
	#End
	Field startAlpha:Float = 1.0
	#Rem monkeydoc
	Alpha variance.
	#End
	Field startAlphaVariance:Float = 0.1
	#Rem monkeydoc
	Fade rate.
	#End
	Field fadeRate:Float = 0.2 / 1000.0

	#Rem monkeydoc
	Start rotation angle.
	#End
	Field startAngle:Float = 0.0
	#Rem monkeydoc
	Start angle variance.
	#End
	Field startAngleVariance:Float = 0.0
	#Rem monkeydoc
	Spin rate of particles. Will spin in direction of initial rotation. Hence, must have a non-zero start angle for this to work.
	#End
	Field spinRate:Float = 0.0 / 1000.0 '
	
	#Rem monkeydoc
	Particle lifetime in ms. Default 5000 ms.
	#End
	Field lifeTime:Int = 5000 ' in ms
	#Rem monkeydoc
	Particle lifetime variance. Default 1000 ms.
	#End
	Field lifeVariance:Int = 1000 ' in ms
	
	#Rem monkeydoc
	Set to True to keep emitting until emitter lifetime elapsed.
	#End
	Field continuous:Bool = False

	#Rem monkeydoc
	Defines the delay between each particle being emitted, in ms. Default 100 ms. Only applies if continuous emitter.
	#End
	Field emitRate:Float = 100 

	#Rem monkeydoc
	Gravity vector. Default to slow y fall.
	#End
	Field gravity:Point = New Point( 0.0 /1000.0, +0.05 /1000.0 )
	#Rem monkeydoc
	Radial acceleration, default 0.0. Note - gravity and radialAccel dont really work together, use one or the other. 
	Radial accel is more cpu intensive (has to normalise a direction vector)
	#End
	Field radialAccel:Float = 0.0 / 1000.0

	#Rem monkeydoc
	Standard Monkey blend mode, currently AdditiveBlend or AlphaBlend but also depends on target.
	#End
	Field blendMode:Int = AdditiveBlend

	' (in development)
	'Field bounceFloor:Bool = False ' TODO not impl yet (see Update() )
	'Field floorBounceY:Float = 300.0
	'Field bounciness:Float = 0.3
	
	' 2015! made public
	Field timer:Timer = New Timer( 5 * 1000 ) ' emitter duration in ms

Private 
	#Rem monkeydoc
	Particle texture. Currently, all particles share the same texture.
	#End
	Field texture:Image = Null

	#Rem monkeydoc
	Main timer for the particle system.
	#End
' 2015!!!!	Field timer:Timer = New Timer( 5 * 1000 ) ' emitter duration in ms
	Field timeSinceEmit:Int = 9999 ' used for contiunous emitter
	#Rem monkeydoc
	Stores all our particles.
	#End
	Field particles:List<Particle> = New List<Particle>
	
Public

	#Rem monkeydoc 
	Creates an emitter using a built-in texture, numbered 0 to 15. See the "data/congoparticles.png" texture sheet.
	Move the emitter using the standard Position parameters.  Use lifetime -1 for continuous emit.
	Set other parameters individually, or use one of the default sets.

	Tips: try using a small number of particles, e.g. 20-100. Additive blending can help with the effect.
	Note, black particles will not be visible if blend mode is AdditiveBlending.
	#End
	Method New( particleId:Int = 0, numParticles:Int = 20 )
		
		If particleId < 0 Or particleId > 15 Then
		Error( CONGO_ERROR_STRING + "particleId must be between 0 and 15." )
			Throw New Throwable()
		End
		
		Local col:Int = particleId Mod 4 ' its a 4x4 grid
		Local row:Int =  particleId/4 
		
		Local myImg:Image = CongoResourceLoader( "congoparticles.png" ) ' (no handle)
		Local frWidth:Float = Float(myImg.Width()) / 4.0
		Local frHeight:Float = Float(myImg.Height()) / 4.0	
			
		Self.texture = myImg.GrabImage( col*frWidth, row*frHeight, frWidth, frHeight, 1, Image.MidHandle )
		InitParticles( numParticles )

	End

	#Rem monkeydoc
	As above, but using a custom particle texture. See congoparticles for example texure size.
	#End
	Method New( texture:Image, numParticles:Int = 20 )

		Self.texture = texture
		InitParticles( numParticles )

	End

	#Rem monkeydoc
	Can be used to set the current texture.
	#End
	Method SetTexture:Void( img:Image )
	
		Self.texture = img
	
	End

	#Rem monkeydoc
	Internal, called from constr. In theory you could use it elsewhere to add more particles, 
	but it is intended that the emitter has a fixed number.
	#End
	Method InitParticles:Void( numParticles:Int = 20 )
	
		' create particles
		For Local i:Int = 0 Until numParticles
			Local p:Particle = New Particle()
			particles.AddLast( p )
		Next
		Self.ResetAll() ' inits the particles
		CongoLog( "Particle emitter added " + particles.Count() + " particles." ) 
	
	End

	#Rem monkeydoc
	Starts or resets the particles to their original parameters.
	#End
	Method ResetAll:Void()
	
		timer.Reset()
		timeSinceEmit = 9999
		For Local p:Particle = Eachin particles
			ResetParticle( p )
		Next
	
	End

	#Rem monkeydoc
	Internal. Resets a single particle.
	#End
	Method ResetParticle:Void( p:Particle )
	
		p.posX = Rnd( -startPosXVariance, startPosXVariance )
		p.posY = Rnd( -startPosYVariance, startPosYVariance )
		p.velX = startVelX + Rnd( -startVelXVariance, startVelXVariance )
		p.velY = startVelY + Rnd( -startVelYVariance, startVelYVariance )
		p.scale = startSize + Rnd( -startSizeVariance, startSizeVariance )
		p.alpha = startAlpha + Rnd( -startAlphaVariance, startAlphaVariance )
		p.rotation = startAngle + Rnd( -startAngleVariance, startAngleVariance )

		If continuous Then
			p.life = -1.0
		Else
			p.life = lifeTime + Rnd( -lifeVariance, lifeVariance )
		End
		
		If p.alpha < 0.0 p.alpha = 0.0
		If p.alpha > 1.0 p.alpha = 1.0
	
	End

	Method Update:Void( dT:Int )
		
		Super.Update( dT )
		If CongoApp.IsPaused() Return 
		
		' need to allow time for all particles to finish. Allow for continuous emitter too.
		If timer.Duration() >= 0 Then 
			If timer.CurrentTime() > timer.Duration() + lifeTime + lifeVariance Return
			timer.Update( dT )
		End
		timeSinceEmit += dT
		

		Local accelx:Float = gravity.X * dT
		Local accely:Float = gravity.Y * dT
		
		For Local p:Particle = Eachin particles
			p.posX += p.velX *dT
			p.posY += p.velY *dT
			p.velX += accelx
			p.velY += accely
			If radialAccel <> 0.0 And ( p.posX <> 0.0 Or p.posY <> 0.0 ) Then
				Local len:Float = Sqrt(p.posX*p.posX + p.posY*p.posY )
				p.velX += p.posX*radialAccel/len
				p.velY += p.posY*radialAccel/len
			End
	
			p.alpha -= fadeRate*dT
			p.scale -= shrinkRate*dT
			
			If spinRate <> 0.0 Then
				p.rotation += Sgn(p.rotation)*spinRate*dT
			End
			
			p.life -= dT
			
			' emit more if continuous and timer allows
			If Self.continuous And ( Not timer.Completed() Or timer.Duration() < 0 ) Then
				If p.life < 0.0 And timeSinceEmit > emitRate Then
					ResetParticle( p )
					p.life = lifeTime + Rnd( -lifeVariance, lifeVariance )
					timeSinceEmit = 0.0
				End
			End
						
			If p.alpha < 0.0 p.alpha = 0.0
			If p.alpha > 1.0 p.alpha = 1.0
			If p.scale < 0.0 p.scale = 0.0
			
			' todo bounce flag etc? prob not a common feature.
			' If p.velY > 0.0 And p.posY + position.Y > floorBounceY p.velY *= -bounciness
		Next
		
	End

	Method Draw:Void()
	
		' (note, particles are not child sprites. Need to deal with sd/hd scaling ourselves)
	
		Super.Draw()
			
		If Hidden() Return
		
		' need to allow time for all particles to finish
		If timer.CurrentTime() > timer.Duration() + lifeTime + lifeVariance Return
		
		Local bm:Int = GetBlend()
		SetBlend( blendMode )
		For Local p:Particle = Eachin particles
			If p.life > 0 Then
				SetAlpha( p.alpha)
				DrawImage ( texture, Position.X + p.posX, Position.Y + p.posY, 
							p.rotation, p.scale/CongoApp.imageResScaler, p.scale/CongoApp.imageResScaler )
			End
		Next
		SetAlpha( 1.0 )
		SetBlend( bm )
	
	End

	#Rem monkeydoc
	Built-in particle effect settings you can use. Try with ~20 white particles.
	#End
	
	Method InitSmallPuffExample:Void()
		
		timer.SetDuration( 5000 )
		timer.Reset()
		continuous = False
		emitRate = 0
		
		startPosXVariance = 5.0
	 	startPosYVariance = 5.0

	 	startVelX = 0.05
	 	startVelY = 0.0
	 	startVelXVariance = 0.03
	 	startVelYVariance = 0.02
	 	
	 	startSize = 0.25 ' was 0.2
	 	startSizeVariance = 0.05
	 	shrinkRate = 0.0
	
	 	startAlpha = 0.7
	 	startAlphaVariance = 0.1
	 	fadeRate = 0.25 / 1000.0
	
	 	startAngle = 0.0
	 	startAngleVariance = 0.0
		spinRate = 0.0
	
		lifeTime = 3000 ' in ms
		lifeVariance = 1000 ' in ms
		
	 	gravity.x = -0.1 / 1000.0
	 	gravity.y = +0.05 / 1000.0
	 	radialAccel = 0.0
	 	blendMode = AlphaBlend
	 	
	 	ResetAll() ' required to init the particles
	
	End

	#Rem monkeydoc
	Built-in particle effect settings you can use. Try with ~20 white particles.
	#End
	Method InitSuperNovaExample:Void()
		
		timer.SetDuration( 5000 )
		timer.Reset()
		continuous = False
		emitRate = 0
		
		startPosXVariance = 10.0
	 	startPosYVariance = 10.0

	 	startVelX = 0.0
	 	startVelY = 0.0
	 	startVelXVariance = 0.02
	 	startVelYVariance = 0.02
	 	
		startSize = 1.0
	 	startSizeVariance = 0.01
	 	shrinkRate = 0.2 / 1000.0
	
	 	startAlpha = 1.0
	 	startAlphaVariance = 0.1
	 	fadeRate = 0.2 / 1000.0
	
	 	startAngle = 0.0
	 	startAngleVariance = 0.0
		spinRate = 0.0
	
		lifeTime = 5000 ' in ms
		lifeVariance = 1000 ' in ms
	 	
	 	gravity.x = 0.0
	 	gravity.y = 0.0
	 	radialAccel = 0.75 /1000.0
	 	blendMode = AdditiveBlend
	 	
	 	ResetAll() ' required to init the particles
	
	End
	
	#Rem monkeydoc
	Built-in particle effect settings you can use. Continuous emitter example, try with ~100 white particles
	#End
	Method InitBurnDripExample:Void() 
		
		timer.SetDuration( 5000 )
		timer.Reset()
		continuous = True
		emitRate = 100
		
		startPosXVariance = 2.0
	 	startPosYVariance = 2.0

	 	startVelX = 0.0
	 	startVelY = 0.0
	 	startVelXVariance = 0.01
	 	startVelYVariance = 0.01
	 	
		startSize = 0.5
	 	startSizeVariance = 0.1
	 	shrinkRate = 0.2 / 1000.0
	
	 	startAlpha = 1.0
	 	startAlphaVariance = 0.1
	 	fadeRate = 0.2 / 1000.0
	
	 	startAngle = 0.0
	 	startAngleVariance = 0.0
		spinRate = 0.0
	
		lifeTime = 5000 ' in ms
		lifeVariance = 1000 ' in ms
	 	
	 	gravity.x = 0.0
	 	gravity.y = +0.05 / 1000.0
	 	radialAccel = 0.0
	 	blendMode = AdditiveBlend
	 	
	 	ResetAll() ' required to init the particles
	
	End

	#Rem monkeydoc
	Built-in particle effect settings you can use. Continuous emitter example, try with ~100 white particles (id 2 - solid sphere).
	#End
	Method InitSnowFallExample:Void() 
		
		timer.SetDuration( -1 )
		timer.Reset()
		continuous = True
		emitRate = 100
		
		startPosXVariance = 250.0
	 	startPosYVariance = 20.0

	 	startVelX = -0.015
	 	startVelY = 0.05
	 	startVelXVariance = 0.0015
	 	startVelYVariance = 0.0075
	 	
		startSize = 0.4
	 	startSizeVariance = 0.1
	 	shrinkRate = 0.02 / 1000.0
	
	 	startAlpha = 1.0
	 	startAlphaVariance = 0.3
	 	fadeRate = 0.0
	
	 	startAngle = 0.0
	 	startAngleVariance = 0.0
		spinRate = 0.0
	
		lifeTime = 6000 ' in ms
		lifeVariance = 1000 ' in ms
	 	
	 	gravity.x = 0.0
	 	gravity.y = +0.0
	 	radialAccel = 0.0
	 	blendMode = AlphaBlend
	 	
	 	ResetAll() ' required to init the particles
	
	End
		
End

#Rem monkeydoc
Defines a set of particle emitters, where the oldest one gets re-used on demand. 
Helps with controlling the number of particles on screen. 
It is recommended that you add a fixed number of emitters to the pool before using it.
#End
Class ParticleEmitterPool

Private
	
	Field m_emitters:List<ParticleEmitter> = New List<ParticleEmitter>
	
	' Store the enumerator 
	' (Dev note: I think this is 'legal' Monkey code! Enumerator docs vague. Else, we'll have to use an array).
	 Field m_objEnumerator:list.Enumerator<ParticleEmitter> = Null 

	
Public
	
	Method New() 
		
		m_objEnumerator = m_emitters.ObjectEnumerator()	
		
	End
	#Rem monkeydoc
	Adds an emitted to the pool.
	#End
	Method AddEmitter:Void( emitter:ParticleEmitter )
	
		m_emitters.AddLast( emitter )
		m_objEnumerator = m_emitters.ObjectEnumerator() ' reset since its invalidated.
	End

	#Rem monkeydoc
	Use this to retrieve the next available emitter. Simply call Reset() and SetPosition to the new location.
	#End
	Method NextEmitter:ParticleEmitter()
		
		If Not m_objEnumerator.HasNext() m_objEnumerator = m_emitters.ObjectEnumerator()		
		Return m_objEnumerator.NextObject()
	
	End
	
End

