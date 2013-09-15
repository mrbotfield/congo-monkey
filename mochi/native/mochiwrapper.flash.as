// Native code for mochi.
//
// Thanks to forum user JD0 for useful post:
//    http://www.monkeycoder.co.nz/Community/posts.php?topic=2264
//
// (note, you wont see trace output in the browser without using the debug Flash player, and/or via a browser extension).

import mochi.as3.*;
import flash.display.*;

// Mochi id is required:
// Either, uncomment this line and use you unique mochi game_id authentication string.
//	var _mochiads_game_id:String = "xxxxxxxxxxxxxxxx";
//
// OR manually add to the MonkeyGame() function in the generated source code, e.g.
//	public class MonkeyGame extends Sprite{
//		public var _mochiads_game_id:String = "xxxxxxxxxxxxxxxx"; [YOUR CODE HERE]


// Dev notes - Use of Generated class/function names
// =================================================
// This code relies on Monkey generated class/fn names, which occassionally change.
// Earler versions of Monkey (prior to v72) used name style bb_congoapp_CongoApp.g_Function, 
// this is now c_CongoApp.m_SetPaused.
// Also, access to the stage has changed. Previously we could use game.stage, but now we use
// BBFlashGame.FlashGame().GetDisplayObjectContainer().stage  (is there a cleaner version?).

// URLs, maybe relevant
// http://www.monkeycoder.co.nz/Community/posts.php?topic=4792

class MochiWrapper
{

	 static public function ConnectToMochi( mochi_game_id:String):void {
	
		MochiServices.connect( mochi_game_id, BBFlashGame.FlashGame().GetDisplayObjectContainer().stage, onConnectError);
		trace("Connecting to Mochi.");
	}

	static public function SubmitScore(playerscore:int, boardIDArray:Array ):void {
		
		trace ( "In MochiWrapper submitscore" )
		MochiScores.showLeaderboard({boardID: boardIDHex(boardIDArray), score: playerscore});

	}
	
	static public function ShowInterLevelAd( mochi_game_id:String, resString:String ):void {

		trace ( "In MochiWrapper ShowInterLevelAd" )
		
		// mochi requires a movieclip container. we make a re-useable one and add it to the stage.
		var mochiAdClip:MovieClip = BBFlashGame.FlashGame().GetDisplayObjectContainer().stage.getChildByName( "mochiAdClip" ) as MovieClip;
		if ( mochiAdClip == null ) {
			 mochiAdClip = new MovieClip();
			 mochiAdClip.name = "mochiAdClip";
			 BBFlashGame.FlashGame().GetDisplayObjectContainer().stage.addChild(mochiAdClip);
			 trace( "created new mochiAdClip container clip to hold ad." );
		}
	
		MochiAd.showInterLevelAd({ clip:mochiAdClip, id:mochi_game_id, res:resString, 
				ad_started:AdStartedCallback, ad_loaded:AdLoadedCallback,
				ad_finished:AdFinishedCallback, ad_skipped:AdSkippedCallback, ad_failed:AdFailedCallback });
		
	}

	// Helper fn. this is the current suggested mochi leaderboard hex id converter code.
	static private function boardIDHex( boardIDArray:Array ):String
	{	
		var o:Object = { n: boardIDArray, f: function (i:Number,s:String):String { if (s.length == 16) return s; return this.f(i+1,s + this.n[i].toString(16));}};
		var boardID:String = o.f(0,"");
		return boardID
	}
	
	// callbacks from mochi ad code. We implement these to pause the game behind the ad, or to catch errors.
	// Dev note- we rely on the c_CongoApp.m_Function generated class name here (and its function names) -
	// but if Monkey translation code/naming changes, these lines will need to be fixed.
	// Earler versions of Monkey (prior to v72) used name style bb_congoapp_CongoApp.g_Function
	
	// called when ad starts. (may not get called if network down)
	static private function AdStartedCallback():void{
		trace(" - AdStartedCallback callback.");
		// (no pause here, we do it in AdLoadedCallback)
	}
	
	// called when ad is loaded and about to show. Called after ad_started (its most useful for pausing game
	// right before ad starts).
	static private function AdLoadedCallback( width:Number, height:Number ):void{
		trace(" - AdLoadedCallback callback.");
		c_CongoApp.m_SetPaused( true );
	}
	
	// called when ad finishes.
	 static private function AdFinishedCallback():void{
		trace(" - AdFinishedCallback callback.");
		c_CongoApp.m_SetPaused( false );
	}
	
	// ad skipped. (this can regularly happen if too many ads requested).
	 static private function AdSkippedCallback():void{
		trace(" - AdSkippedCallback callback.");
		c_CongoApp.m_SetPaused( false );
	}
	
	// ad fail (can happen if network down or ads blocked. gets called before ad_finished).
	 static private function AdFailedCallback():void{
		trace(" - AdFailedCallback callback.");
		c_CongoApp.m_SetPaused( false );
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
