// Native code for mochi.
//
// Thanks to forum user JD0 for useful post:
//    http://www.monkeycoder.co.nz/Community/posts.php?topic=2264
//
// (note, you wont see trace output in the browser without using the debug Flash player, and/or via a browser extension).

import mochi.as3.*;

class MochiWrapper 
{

	public function ConnectToMochi( mochi_game_id:String):void {
		MochiServices.connect( mochi_game_id, game.stage, onConnectError);
		trace("Connecting to Mochi.");
	}

	public function SubmitScore(playerscore:int, boardIDArray:Array ):void {
		
		trace ( "In MochiWrapper submitscore" )
		MochiScores.showLeaderboard({boardID: boardIDHex(boardIDArray), score: playerscore});

	}

	// this is the current suggested mochi leaderboard hex id converter code.
	private function boardIDHex( boardIDArray:Array ):String
	{	
		var o:Object = { n: boardIDArray, f: function (i:Number,s:String):String { if (s.length == 16) return s; return this.f(i+1,s + this.n[i].toString(16));}};
		var boardID:String = o.f(0,"");
		return boardID
	}

	public function Error():void
	{
		trace("Mochi error.");
    	}

	public function onConnectError(status:String):void 
	{
		Error();
		trace(" - onConnectError received.");
	}
}
