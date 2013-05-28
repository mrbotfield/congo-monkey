#Rem monkeydoc Module congo.texturecache
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
Import mojo

Import congo.congosettings
Import congo.displayutils

#Rem monkeydoc
Helper class (for a custom map type in Monkey we must extend Map and implement 'Compare' for our key)
#End
Class ImageMap <V> Extends Map<V, Image>
	Method Compare:Int( l:String,r:String )
		If l = r Then Return 0
		If l < r Then Return -1
		Return 1
	End
End

#Rem monkeydoc
A texture cache/resource manager' singleton.

A handy way to store all your textures, and re-use them once loaded.

Notes:

The filenames and paths are case sensitive, but it is recommended you use lower case to avoid any confusion.
See the log output for warnings about resources not being found.

You cant add the same image path twice.

If you have a large number of images you nay want to preload them all in your constructor to avoid any glitches
during gameplay.

The cache can be cleared using RemoveAll, but make sure textures are not in use by other code. Hence,
it makes most sense to empty the cache between game layers, when all new Sprites are re-created.
The cache does not store a use-count for each resource.

 	See http://www.monkeycoder.co.nz/Community/posts.php?topic=1934 for Singlton sample,
 	and http://www.monkeycoder.co.nz/Community/posts.php?topic=755 for map image cache sample.
#End
Class TextureCache

	Private
	
	Field m_cache:ImageMap<String> = Null
	
	' Singleton code
	Global m_tcache_instance:TextureCache ' shared instance.
	
	#Rem monkeydoc
	Private constr.
	#End
	Method New()
		'Print "[ TextureCache ] New cache."
		If m_tcache_instance Then Error(" Error - cannot create new instance of TextureCache singleton")
		m_tcache_instance = self
		m_tcache_instance.init()
	End
	
	#Rem monkeydoc
	Internal. Called from constr.
	#End
	Method init:Void()
		CongoLog( "[ TextureCache ] init" )
		m_cache = New ImageMap<String>		
	End
	
	Public
	
	#Rem monkeydoc
	Use this to access the shared instance.
	#End
	Function getInstance:TextureCache()
		'Print "[ TextureCache ] in getInstance"
		If Not m_tcache_instance Then
			m_tcache_instance = New TextureCache()
		End
		
		Return m_tcache_instance
	End
	
	#Rem monkeydoc
	Creates an Image from the specified resource and adds it to the cache. Returns the Image. If the cache
	already contains the Image, that copy will be returned instead.
	If the source file does not exist, the log will show an error, and your Image will be null/blank.
	#End
	Method AddResource:Image( imagepath:String, flags:Int = Image.DefaultFlags ) 

		'Print "[ TextureCache ] in AddResource, path is " + imagepath
		Local img:Image = Null
		
		If m_cache = Null Then 
			Error( CONGO_ERROR_STRING + "Error -- m_cache is null in TextureCache ") 
			Return Null
		End
		
		If m_cache.Contains( imagepath )

			Return m_cache.Get( imagepath ) 

		Else
			img = LoadImage( imagepath, 1, flags )
			If img = Null Then
				CongoLog( "TextureCache. Warning! Image res with path " + imagepath + " appears To be Null" )
			Else
				CongoLog( "TextureCache. Image res " + imagepath + " loaded. Dimensions " + img.Width() + " x " + img.Height() )
				m_cache.Set( imagepath, img )
			End
		End
		
		CongoLog( "TextureCache size is now " + m_cache.Count() )
	
		Return img
	End
	
	#Rem monkeydoc
	Adds a pre-existing Image directly.
	#End
	Method AddImage:Void( image:Image, imagepath:String )
	
		If m_cache = Null Then 
			Error( CONGO_ERROR_STRING + "Error -- m_cache is null in TextureCache ") 
			Return
		End
		
		m_cache.Set( imagepath, image )
		
	End
	
	Method Contains:Bool( imagepath:String )
	
		If m_cache = Null Then 
			Error( CONGO_ERROR_STRING + "Error -- m_cache is null in TextureCache ") 
			Return False
		End
		
		Return m_cache.Contains( imagepath )
	
	End
	
	#Rem monkeydoc
	Returns True if the caches contains an Image with the specified name.
	#End
	Method GetImage:Image( imagepath:String )
	
		If m_cache = Null Then 
			Error( CONGO_ERROR_STRING + "Error -- m_cache is null in TextureCache ") 
			Return Null
		End
		
		If m_cache.Contains( imagepath ) Return m_cache.Get( imagepath )
		Return Null
	
	End
	
	#Rem monkeydoc
	Removes the relevant Image from the cache.
	#End
	Method Remove:Void( imagepath:String )

		If m_cache.Get( imagepath )

			m_cache.Remove( imagepath )
			' note - could force an Image.Discard here? (or option in RemoveAll?)
			CongoLog( "TextureCache removed image res with path " + imagepath  + "  - total now " + m_cache.Count() )

		End

	End

	#Rem monkeydoc
	Removes all Images from the cache.
	#End
	Method RemoveAll:Void()

		m_cache.Clear()
		CongoLog( "TextureCache cleared. Size is " + m_cache.Count() )
		' todo - do proper discard of each? or g.c. enough?
	End

End
