#Rem monkeydoc Module congo.soundplayer
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
Import mojo

Import congo.audioutils

#Rem monkeydoc
A wrapper for playing sound, which deals with file formats, channels etc.

See CONGO_MAX_AUDIO_CHANNEL setting, and audioutils functions which load and store sounds.
This class is not for playing music -- use Monkey's PlayMusic function.

Note - if you loop a sound you will need to store the channel in order to stop it.
Note - For Flash, try 8- or 16-bit mp3s at sample rates of 11, 22, or 44 kHz.
#End
Class SoundPlayer

Private
	
	Global m_curChannel:Int = 0 ' channel is shared/global
	Global m_muted:Bool = False
	
Public
	
	'(Dev note -  most of its functions are in fact global, the class doesnt really store much).
	Method New()
		
	End

	#Rem monkeydoc
	Function which loads a sound resource from file, plays it, and also adds it to the cache if required.
	Won't play if Muted is set.

	See also the overloaded form, which takes a Sound directly (no cache lookup).
	If no channel is specified, the next available one is selected; You may wish to control the channels yourself
	to reserve certain channels for certain effects.
	#End
	Function LoadAndPlay:Sound( filename:String, channel:Int = -1, loop:Bool = False )
	
		Local snd:Sound = CongoSoundLoader( filename )
		If snd Play( snd, channel, loop )
		Return snd
	
	End
	
	#Rem monkeydoc
	Function which plays the specified Sound. If no channel is specified, the next available one is selected.
	Won't play if Muted is set.
	#End
	Function Play:Void( snd:Sound, channel:Int = -1, loop:Bool = False )

		If m_muted Return
		If channel < 0 channel = GetNextChannel()
		PlaySound( snd, channel, loop )
	
	End
	
	#Rem monkeydoc
	(Internal). Returns the next available sound channel. See CONGO_MAX_AUDIO_CHANNEL to change the number of available channels.
	#End
	Function GetNextChannel:Int()
	
		m_curChannel += 1
		If m_curChannel >= CONGO_MAX_AUDIO_CHANNEL m_curChannel = 0
		Return m_curChannel
	End

	#Rem monkeydoc
	Pause all channels.

	Dev note - possible issue in Flash? CongoApp did use this, but changed to StopAll to avoid problem.
	#End
	Function PauseAll:Void()

		For Local i:Int = 1 Until CONGO_MAX_AUDIO_CHANNEL
			PauseChannel( i )
		End

	End

	#Rem monkeydoc
	Resume all channels.
	#End
	Function ResumeAll:Void()

		For Local i:Int = 1 Until CONGO_MAX_AUDIO_CHANNEL
			ResumeChannel( i )
		End

	End

	#Rem monkeydoc
	Stop all channels. CongoApp calls this when the app is paused.
	#End
	Function StopAll:Void()

		For Local i:Int = 1 Until CONGO_MAX_AUDIO_CHANNEL
			StopChannel( i )
		End

	End

	#Rem monkeydoc
	Sets the volume for all channels.
	#End
	Function SetVolumeAll:Void( vol:Float )
	
		For Local i:Int = 1 Until CONGO_MAX_AUDIO_CHANNEL
			SetChannelVolume( i , vol )
		End
	
	End

	#Rem monkeydoc
	Mutes (or un-mutes) the sound player. Calls to Play will do nothing when mute is set.
	#End
	Function MuteAll:Void( state:Bool )
	
		m_muted = state

	End
	
	#Rem monkeydoc
	Toggles the mute state. Useful for sound on/off toggle buttons etc.
	#End
	Function ToggleMuteAll:Void()
	
		m_muted = Not m_muted
	
	End

	#Rem monkeydoc
	Returns the mute state.
	#End
	Function Muted:Bool()

		Return m_muted

	End
	
End

