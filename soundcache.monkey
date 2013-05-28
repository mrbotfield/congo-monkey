#Rem monkeydoc Module congo.soundcache
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
Import mojo

Import congo.congosettings
Import congo.audioutils

#Rem monkeydoc
Helper class (for a custom map type in Monkey we must extend Map and implement 'Compare' for our key)
#End
Class SoundMap <V> Extends Map<V, Sound>
	Method Compare:Int( l:String,r:String )
		If l = r Then Return 0
		If l < r Then Return -1
		Return 1
	End
End

#Rem monkeydoc
A sound cache/resource manager singleton.

Essentially the same approach as Texturecache. However, this class will use CongoSoundLoader
to load the correct audio format depending on the target device. See the Monkey docs and config for
supported audio formats. Unless memory is very tight (e.g. you have a very large number of sounds
its unlikely you need to routinely empty the cache.


The PlaySound() function deals internally with choosing a free audio channel. This is fine in most
cases, but you are free to use Monkey's PlaySound directly for more control.
#End
Class SoundCache

	Private
	
	Field m_cache:SoundMap<String> = Null
	
	' Singleton code
	Global m_tcache_instance:SoundCache ' shared instance.
	
	#Rem monkeydoc
	Private constr.
	#End
	Method New() 
		If m_tcache_instance Then Error(" Error - cannot create new instance of SoundCache singleton")
		m_tcache_instance = self
		m_tcache_instance.init()
	End
	
	#Rem monkeydoc
	Internal. Called from constr.
	#End
	Method init:Void()
		CongoLog( "SoundCache - init" )
		m_cache = New SoundMap<String>		
	End
	
	Public
	
	#Rem monkeydoc
	Use this to access the shared instance.
	#End
	Function getInstance:SoundCache()
		If Not m_tcache_instance Then
			m_tcache_instance = New SoundCache()
		End
		
		Return m_tcache_instance
	End
	
	#Rem monkeydoc
	Creates a Sound from the specified resource name and adds it to the cache. Returns the Sound. If the cache
	already contains the Sound, that copy will be returned instead.
	If the file does not exist, an error will be thrown.
	#End
	Method AddResource:Sound( filepath:String )
	
		'Print "[ SoundCache ] in AddResource, path is " + filepath
		Local snd:Sound = Null
		
		If m_cache = Null Then 
			Error( CONGO_ERROR_STRING + "Error -- m_cache is null in SoundCache ") 
			Return Null
		End
		
		If m_cache.Contains( filepath )

			Return m_cache.Get( filepath ) 

		Else
			snd = LoadSound( filepath )
			If snd = Null Then
				CongoLog( "SoundCache. Warning! Sound res with path " + filepath + " appears To be Null" )
			Else
				CongoLog( "SoundCache. Sound res " + filepath )
				m_cache.Set( filepath, snd )
			End
		End
		
		CongoLog( "SoundCache size is now " + m_cache.Count() )
	
		Return snd
	End
	
	#Rem monkeydoc
	Adds a pre-existing Sound directly.
	#End
	Method AddSound:Void( sound:Sound, filepath:String )
	
		If m_cache = Null Then 
			Error( CONGO_ERROR_STRING + "Error -- m_cache is null in SoundCache ") 
			Return
		End
		
		m_cache.Set( sound, filepath )
		
	End

	#Rem monkeydoc
	Returns True if the caches contains a sound with the specified name.
	#End
	Method Contains:Bool( filepath:String )
	
		If m_cache = Null Then 
			Error( CONGO_ERROR_STRING + "Error -- m_cache is null in SoundCache ") 
			Return False
		End
		
		Return m_cache.Contains( filepath )
	
	End
	
	#Rem monkeydoc
	Returns a Sound from the cache, or Null if no such resource exists.	
	#End
	Method GetSound:Sound( filepath:Sound )
	
		If m_cache = Null Then 
			Error( CONGO_ERROR_STRING + "Error -- m_cache is null in SoundCache ") 
			Return Null
		End
		
		If m_cache.Contains( filepath ) Return m_cache.Get( filepath )
		Return Null
	
	End
	
	#Rem monkeydoc
	Removes a relevant Sound from the cache.
	#End
	Method Remove:Void( filepath:String )

		If m_cache.Get( filepath )

			m_cache.Remove( filepath )
			' note - could force an Discard here? (or option in RemoveAll?)
			CongoLog( "SoundCache removed sound res with path " + filepath  + "  - total now " + m_cache.Count() )

		End

	End
	
	#Rem monkeydoc
	Removes all Sounds from the cache.
	#End
	Method RemoveAll:Void()

		m_cache.Clear()
		CongoLog( "SoundCache cleared. Size is " + m_cache.Count() )
		' todo - discard resource or g.c. enough?
		
	End
	
End
