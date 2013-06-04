// Native code for mochi.
//
// Thanks to forum user JD0 for useful post:
//    http://www.monkeycoder.co.nz/Community/posts.php?topic=2264
//
// (note, you wont see trace output in the browser without using the debug Flash player, and/or via a browser extension).

import mochi.as3.*;
import flash.display.*;

class MochiWrapper
{

	 static public function ConnectToMochi( mochi_game_id:String):void {
	
		MochiServices.connect( mochi_game_id, game.stage, onConnectError);
		trace("Connecting to Mochi.");
	}

	static public function SubmitScore(playerscore:int, boardIDArray:Array ):void {
		
		trace ( "In MochiWrapper submitscore" )
		MochiScores.showLeaderboard({boardID: boardIDHex(boardIDArray), score: playerscore});

	}
	
	static public function ShowInterLevelAd( mochi_game_id:String, resString:String ):void {

		trace ( "In MochiWrapper ShowInterLevelAd" )
		
		// mochi requires a movieclip container. we make a re-useable one and add it to the stage.
		var mochiAdClip:MovieClip = game.stage.getChildByName( "mochiAdClip" ) as MovieClip;
		if ( mochiAdClip == null ) {
			 mochiAdClip = new MovieClip();
			 mochiAdClip.name = "mochiAdClip";
			 game.stage.addChild(mochiAdClip);
			 trace( "created new mochiAdClip container clip to hold ad." );
		}
	
		MochiAd.showInterLevelAd({ clip:mochiAdClip, id:mochi_game_id, res:resString, ad_started:ad_started });
		
	}

	// Helper fn. this is the current suggested mochi leaderboard hex id converter code.
	static private function boardIDHex( boardIDArray:Array ):String
	{	
		var o:Object = { n: boardIDArray, f: function (i:Number,s:String):String { if (s.length == 16) return s; return this.f(i+1,s + this.n[i].toString(16));}};
		var boardID:String = o.f(0,"");
		return boardID
	}
	
	// callbacks from mochi ad code. We implement these to pause the game behind the ad, or to catch errors.
	// Dev note- we rely on the bb_congoapp_CongoApp class name here (and its static fns) - but if Monkey 
	// translation code/naming changes, these lines will need to be fixed.
	
	// called when ad starts. (may not get called if network down)
	static private function ad_started():void{
		trace(" - ad_started callback.");
		bb_congoapp_CongoApp.g_SetPaused( true );
	}
	
	// called when ad finishes.
	 static private function ad_finished():void{
		trace(" - ad_finished callback.");
		bb_congoapp_CongoApp.g_SetPaused( false );
	}
	
	// ad skipped. (this can regularly happen if too many ads requested).
	 static private function ad_skipped():void{
		trace(" - ad_skipped callback.");
		bb_congoapp_CongoApp.g_SetPaused( false );
	}
	
	// ad fail (can happen if network down or ads blocked. gets called before ad_finished).
	 static private function ad_failed():void{
		trace(" - ad_failed callback.");
		bb_congoapp_CongoApp.g_SetPaused( false );
	}

	static private function MochiError():void
	{
		trace("Mochi error.");
    }

	static private function onConnectError(status:String):void 
	{
		MochiError();
		trace(" - onConnectError received.");
	}

} // (class)
