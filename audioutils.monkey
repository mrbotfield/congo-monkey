#Rem monkeydoc Module congo.audioutils
Various standalone functions relating to audio.
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
Import mojo

Import congo.congosettings
Import congo.textutils
Import congo.soundcache

#Rem monkeydoc
Main sound loading function. Loads a sound via the SoundCache and returns it; will use the cached version if already loaded. Uses GetSoundResourceName to select the correct filename for the current target.
#End
Function CongoSoundLoader:Sound( filename:String, cache:Bool = True )

	filename = GetSoundResourceName( filename )
	
	' MOVED to other fn If CONGO_AUDIO_FOLDER <> "" filename = CONGO_AUDIO_FOLDER.Replace("/", "" ) + "/" + filename
	
	Local snd:Sound = Null
	If cache Then
		snd = SoundCache.getInstance().AddResource( filename )
	Else
		snd = LoadSound( filename )
	End
	
	If snd = Null Then
		Error( CONGO_ERROR_STRING + "Sound is Null for file: " + filename )
	End
	Return snd

End

#Rem monkeydoc
Strips off the sound filename extension and replace with the appropriate one for the current target. Used by the SoundPlayer
class, or can be used standalone. Use GetSoundResourceName for music files, the formats are different.
#End
Function GetSoundResourceName:String( filename:String )

	Local spl:String[] = filename.Split( "." )
	If spl.Length() < 2 Or spl[spl.Length()-1].Length() = 0
		CongoLog( CONGO_WARNING_STRING + "GetSoundResourceName - filename has no dot or no extension, returning original." )
		Return filename
	End

	Local fret:String
	For Local i:Int=0 Until spl.Length()-1 ' deal with multiple dots in name
		fret = fret + spl[i]
		If i < spl.Length() -2
			fret = fret + "."
		End
	End
	
	Local extn:String = ""
	
	' choose the format:
	#If TARGET = "html5"
		extn = "wav"
	#Elseif TARGET = "glfw"
		extn = "wav"
	#Elseif TARGET = "flash"
		extn = "mp3"
	#Elseif TARGET = "android"
		extn = "wav"
	#Elseif TARGET = "xna"
		extn = "wav"
	#Elseif TARGET = "ios"
		extn = "wav"
	#Else
		extn = "wav"
	#End 
	
	fret = fret + "." + extn
	
	' add optional folder name
	If CONGO_AUDIO_FOLDER <> "" fret = CONGO_AUDIO_FOLDER.Replace("/", "" ) + "/" + fret
	
	' (only works on some targets)
	'If FileType( fret ) = 0 CongoLog( CONGO_WARNING_STRING + " file not found: " + fret ) 
	
	CongoLog( "GetSoundResourceName returning value " + fret )
	
	Return fret

End

#Rem monkeydoc
Will strip off the music filename extension and replace with the appropriate one for the current target.
#End
Function GetMusicResourceName:String( filename:String, isMusicFile:Bool = False )

	Local spl:String[] = filename.Split( "." )
	If spl.Length() < 2 Or spl[spl.Length()-1].Length() = 0
		CongoLog( CONGO_WARNING_STRING + "GetMusicResourceName - filename has no dot or no extension, returning original." )
		Return filename
	End

	Local fret:String
	For Local i:Int=0 Until spl.Length()-1 ' deal with multiple dots in name
		fret = fret + spl[i]
		If i < spl.Length() -2
			fret = fret + "."
		End
	End
	
	Local extn:String = ""
	
	' choose the format:
	#If TARGET = "html5"
		extn = "ogg"
	#Elseif TARGET = "glfw"
		extn = "ogg"
	#Elseif TARGET = "flash"
		extn = "mp3"
	#Elseif TARGET = "android"
		extn = "ogg"
	#Elseif TARGET = "xna"
		extn = "wma"
	#Elseif TARGET = "ios"
		extn = "mp3" ' (or m4a...)
	#Else
		extn = "ogg"
	#End 
	
	fret = fret + "." + extn
	
	' add optional folder name
	If CONGO_AUDIO_FOLDER <> "" fret = CONGO_AUDIO_FOLDER.Replace("/", "" ) + "/" + fret
	
	' (only works on some targets)
	'If FileType( fret ) = 0 CongoLog( CONGO_WARNING_STRING + " file not found: " + fret ) 
	
	CongoLog( "GetMusicResourceName returning value " + fret )
	Return fret

End
