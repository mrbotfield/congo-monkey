#Rem monkeydoc Module congo.mochi
Mochi media wrapper (flash only). Requires mochi sdk, and path update so  
mxmlc compiler can find it (e.g. edit source-path in flex-config.xml).

** THIS Class IS UNDER DEVELOPMENT ** - it is useable but has limited functionality (the full Mochi api is quite large).
Currently does connection and leaderboard score submit.
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

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
	Function ConnectToMochi:Void( mochi_game_id:String ) = "MochiWrapper.ConnectToMochi"
	
	#Rem monkeydoc
	Submit score. The Mochi dialog/leaderboard widget is shown. The board id Array is as described in the Mochi sample code.
	#End	
	Function SubmitScore:Void( playerscore:Int, boardIDArray:Int[] ) = "MochiWrapper.SubmitScore"
	
	' Shows an ad. resString has format "600x400".
	Function ShowInterLevelAd:Void( mochi_game_id:String, resString:String ) = "MochiWrapper.ShowInterLevelAd"
	
	#Rem monkeydoc
	General Error.
	#End
	Function MochiError:Void() = "MochiWrapper::MochiError"
	
End ' (class)

	
#End ' (#If TARGET="flash")
