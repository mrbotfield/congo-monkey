
// Native code for revmob wrapper.
// See sample code at http://sdk.revmobmobileadnetwork.com/android.html

import android.os.Bundle;
import android.app.Activity;
import android.view.View;

import com.revmob.RevMob;
import com.revmob.ads.fullscreen.RevMobFullscreen;
import com.revmob.ads.banner.RevMobBanner;
import com.revmob.RevMobTestingMode;
import com.revmob.ads.link.RevMobLink;
import com.revmob.ads.popup.RevMobPopup;
import com.revmob.ads.banner.RevMobBanner;

class RevMobWrapper
{

	static RevMob revmob;
	
	public static void StartSessionWithAppID( String revmob_app_id ) 
	{
		revmob = RevMob.start( BBAndroidGame.AndroidGame()._activity, revmob_app_id ); 
	}

	public static void ShowFullscreen()
	{
		if ( revmob != null )
			revmob.showFullscreen( BBAndroidGame.AndroidGame()._activity);
		
	} 
	
	public static void TestingWithAds()
	{
		if ( revmob != null )
			revmob.setTestingMode( RevMobTestingMode.WITH_ADS ); 
	}
	
	public static void TestingWithoutAds()
	{
		if ( revmob != null )
			revmob.setTestingMode( RevMobTestingMode.WITHOUT_ADS ); 
	}
	
	public static void DisableTestMode()
	{
		if ( revmob != null )
			revmob.setTestingMode( RevMobTestingMode.DISABLED ); 
	}
}

