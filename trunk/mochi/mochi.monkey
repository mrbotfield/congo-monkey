#Rem monkeydoc Module congo.mochi
Mochi media wrapper (flash only). Requires mochi sdk, and path update so  
mxmlc compiler can find it (e.g. edit source-path in flex-config.xml).

You must replace the _mochiads_game_id String in mochiwrapper.flash.as with your unique game id.

** THIS Class IS UNDER DEVELOPMENT ** - it is useable but has limited functionality (the full Mochi api is quite large).
Currently does connection, leaderboards, and some of the ad banner units.
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

' Dev note- previously (prior to v72) these static functions were defined using "MochiWrapper.Name",
' but this creates as code MochiWrapper.MochiWrapper.Name, which fails. Now, removed the MochiWrapper part.

Strict

' (all code skipped if not flash target)
#If TARGET="flash" 

	Import "native/mochiwrapper.flash.as"
	Extern

	#Rem monkeydoc
	Wrapper Class. Most functions are static (currently doesnt store the game id).
	#End
	Class MochiWrapper = "MochiWrapper"

	#Rem monkeydoc
	Connect. Call this early on, e.g. at startup/splashscreen. Use the game id provided To you by Mochi.
	#End
	Function ConnectToMochi:Void( mochi_game_id:String ) = "ConnectToMochi"
	
	#Rem monkeydoc
	Submit score. The Mochi dialog/leaderboard widget is shown. The board id Array is as described in the Mochi sample code.
	#End	
	Function SubmitScore:Void( playerscore:Int, boardIDArray:Int[] ) = "SubmitScore"
	
	' Shows an ad. resString has format "600x400".
	Function ShowInterLevelAd:Void( mochi_game_id:String, resString:String ) = "ShowInterLevelAd"
	
	' Shows the Showcase widget.
	Function LoadShowcase:Void( mochi_game_id:String, posString:String ) = "LoadShowcase"
	
	' Close the current Showcase widget (NB only supports 1 widget)
	Function CloseShowcase:Void() = "CloseShowcase"
	
	' Re-open the current Showcase widget (NB only supports 1 widget)
	Function OpenShowcase:Void() = "OpenShowcase"
	
	#Rem monkeydoc
	General Error.
	#End
	Function MochiError:Void() = "MochiError"
	
End ' (class)

	
#End ' (#If TARGET="flash")
