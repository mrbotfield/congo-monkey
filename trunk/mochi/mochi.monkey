#Rem monkeydoc Module congo.mochi
Mochi media wrapper (flash only). Requires mochi sdk, and path update so  
mxmlc compiler can find it (e.g. edit source-path in flex-config.xml).

** THIS CLASS IS UNDER DEVELOPMENT ** - it is useable but has limited functionality.
Currently does connection and leaderboard score submit.
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict

' (all code skipped if not flash target)
#If TARGET="flash" 

	Import "native/mochiwrapper.flash.as"
	Extern

Class MochiWrapper = "MochiWrapper"

	#Rem monkeydoc
	Connect. Call this early on, e.g. at startup/splashscreen. Use the game id provided To you by Mochi.
	#End
	Method ConnectToMochi:Void( mochi_game_id:String )
	
	#Rem monkeydoc
	Submit score. The Mochi dialog/leaderboard widget is shown. The board id Array is as described in the Mochi sample code.
	#End	
	Method SubmitScore:Void( playerscore:Int, boardIDArray:Int[] )
	
	#Rem monkeydoc
	Error callback.
	#End
	Method Error:Void()
	
End

Public
	
#End
