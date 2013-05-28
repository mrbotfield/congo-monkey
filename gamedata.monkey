#Rem monkeydoc Module congo.gamedata
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
Import mojo
Import congo.textutils
Import congo.congosettings

#Rem monkeydoc
Singleton class to store game data and settings, with functions to save/load state. Internally,
uses Monkey's SaveState feature.

Currently, the data is stored as a simple string of key/value data pairs, with a pre-defined separator character. 

Note - Monkey SaveState can store about 1MB of data, but the precise details depend on platform.

Note - on mobile, the state data will likely persist unless the user does a full delete of the application.

Dev note - Todo: array/lists of each type. e.g. for highscores etc.
#End
Class GameData

Private

	Field m_cache:StringMap<String> = Null
	Field dataSeparator:String = "::" 	' separator between data entries
	Field kvSeparator:String = "=" 	' key/value separator
	
	' Singleton code
	Global m_instance:GameData ' global/shared
	
	#Rem monkeydoc
	Private Constr. Creates instance of singleton as required.
	#End
	Method New()
		'Print "[ GameData ] New cache."
		If m_instance Then Error(" Error - cannot create new instance of sound cache singleton")
		m_instance = Self
		m_instance.init()
	End
	
	#Rem monkeydoc
	Internal. Called from constr.
	#End
	Method init:Void()
		CongoLog ( "GameData init" )
		m_cache = New StringMap<String>		
	End
	
Public

	#Rem monkeydoc
	Use this to access the shared instance.
	#End
	Function getInstance:GameData()
		If Not m_instance Then
			m_instance = New GameData()
		End
		
		Return m_instance
	End
	
	#Rem monkeydoc
	Use this to check whether an entry exists.
	#End
	Method Exists:Bool( keyword:String )
	
		Return m_cache.Contains( keyword )
		
	End
	
	' ==== Store functions

	#Rem monkeydoc
	Stores a string entry (will replace previous value if key already exists).
	#End
	Method StoreString:Void( keyword:String, value:String )
		' TODO check for seperator string match..
		m_cache.Set( keyword, value )
	
	End
	
	#Rem monkeydoc
	Stores an integer entry (will replace previous value if key already exists).
	#End
	Method StoreInt:Void( keyword:String, value:Int )
	
		m_cache.Set( keyword, String(value) )
	
	End
	
	#Rem monkeydoc
	Stores a float entry (will replace previous value if key already exists).
	#End
	Method StoreFloat:Void( keyword:String, value:Float )
	
		m_cache.Set( keyword, String(value) )
	
	End
	
	#Rem monkeydoc
	Stores a boolean entry (will replace previous value if key already exists).
	#End
	Method StoreBool:Void( keyword:String, value:Bool )
	
		Local str:String = "0" ' (Monkey wont convert Bool to string itself)
		If value = True str = "1"
		m_cache.Set( keyword, str )
	
	End
	
	' ==== Retrieve functions

	' Use Exists() to confirm an entry exists, else a default value will be returned.
	
	#Rem monkeydoc
	Returns the requested string entry (if no key exists, will retrun a default value. See Exists() ).
	#End
	Method RetrieveString:String( keyword:String )
	
		Local value:String = "" ' default
		If Exists( keyword ) value = m_cache.Get( keyword )
		Return value
		
	End
	
	#Rem monkeydoc
	Returns the requested integer entry (if no key exists, will retrun a default value. See Exists() ).
	#End
	Method RetrieveInt:Int( keyword:String )
	
		Local value:Int = 0 ' default
		If Exists( keyword ) value = Int(m_cache.Get( keyword ))
		Return value
		
	End
	
	#Rem monkeydoc
	Returns the requested float entry (if no key exists, will retrun a default value. See Exists() ).
	#End
	Method RetrieveFloat:Float( keyword:String )
	
		Local value:Float = 0.0 ' default
		If Exists( keyword ) value = Float(m_cache.Get( keyword ))
		Return value
		
	End
	
	#Rem monkeydoc
	Returns the requested boolean entry (if no key exists, will retrun a default value. See Exists() ).
	#End
	Method RetrieveBool:Bool( keyword:String )
	
		Local value:Bool = False ' default
		Local str:String
		If Exists( keyword ) Then
			str = m_cache.Get( keyword )
			If str = "1" value = True
		End
		Return value
		
	End
		
	#Rem monkeydoc
	Persists all current data to disk (via Monkey's SaveState). Will overwrite all previous data.
	Returns an Int but this is likely to be 0 regardless of success (see Monkey internals).

	You should call this at reasonable times, e.g. when settings are changed, or at the end of a level.
	#End
	Method SaveAll:Int()
		
		Local value:String
		Local tosave:String
		For Local key:String = Eachin m_cache.Keys()
			value = ""
			value = m_cache.Get( key )
			tosave += key + kvSeparator + value + dataSeparator
		End
		
		Local result:Int = SaveState( tosave ) 
		CongoLog( "Gamedata savestate returned " + result + " Map contains " + m_cache.Count() + " entries." )
		CongoLog( "Gamedata state: " + tosave )
		
		Return result
	End
	
	#Rem monkeydoc
	Load all data from disk, overwriting local data unless specified by 'overwrite' flag.
	Returns the number of data values that were loaded.
	#End
	Method LoadAll:Int( overwrite:Bool = True )
	
		Local loadStr:String = LoadState()
		If loadStr.Length() = 0 Then
			CongoLog( CONGO_WARNING_STRING + "No Gamedata session to load (will happen on first run)" )
			Return 0
		End
		Local data:String[] = loadStr.Split( dataSeparator )
		Local count:Int = 0
		For Local pair:String = Eachin data
			If pair.Length() > 0 Then
				Local splPair:String[] = pair.Split( kvSeparator )
				If  splPair.Length() <> 2 Then
					CongoLog( CONGO_ERROR_STRING + "Gamedata incorrect data pair for: " + pair )
				Else
					' Note, we dont trim any whitespace here (could be String entry)
					Local keyword:String = splPair[0]
					Local value:String = splPair[1]
					m_cache.Set( keyword, value )
					count += 1
					CongoLog( "Gamedata loaded pair: " + keyword + " = " + value )
				End
			End
		Next
		
		CongoLog( "Gamedata finished, loaded " + count + " entries." )
		Return count

	End

End
