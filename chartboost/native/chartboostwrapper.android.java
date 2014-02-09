// Native code for chartboost wrapper.
// See sample code at https://help.chartboost.com/documentation/android

import com.chartboost.sdk.*; // (chartboost libs must be added to android/libs in build folder).

class ChartboostWrapper
{
	public static String CONGO_CHARTBOOST_ANDROID_APPID  = "YOUR-APP-ID"; // set to YOUR Android app id
	public static String CONGO_CHARTBOOST_ANDROID_APPSIG = "YOUR-APP-SIG"; // set to YOUR Android app sig

	public static void StartSession()
	{
		// (nothing here - the modified androidgame.java template manages the session itself).
	}
	
	public static void ShowInterstitial( String location )
	{
		AndroidGame ag = (AndroidGame)BBAndroidGame.AndroidGame().GetActivity();
		ag.showInterstitial( location );
	} 
	
	public static void CacheInterstitial( String location )
	{
		AndroidGame ag = (AndroidGame)BBAndroidGame.AndroidGame().GetActivity();
		ag.cacheInterstitial( location );
	} 
	
	public static boolean HasCachedInterstitial( String location )
	{
		AndroidGame ag = (AndroidGame)BBAndroidGame.AndroidGame().GetActivity();
		return ag.hasCachedInterstitial( location );
	} 
	
	public static String GetAppID()
	{
		AndroidGame ag = (AndroidGame)BBAndroidGame.AndroidGame().GetActivity();
		return ag.getChartboostAppID();
	}	
	
	public static void ShowMoreApps()
	{
		AndroidGame ag = (AndroidGame)BBAndroidGame.AndroidGame().GetActivity();
		ag.showMoreApps();
	} 

	public static void CacheMoreApps()
	{
		AndroidGame ag = (AndroidGame)BBAndroidGame.AndroidGame().GetActivity();
		ag.cacheMoreApps();
	} 
	
	public static boolean HasCachedMoreApps()
	{
		AndroidGame ag = (AndroidGame)BBAndroidGame.AndroidGame().GetActivity();
		return ag.hasCachedMoreApps();
	} 
	
	/*
	public static void DismissChartboostView()
	{
		AndroidGame ag = (AndroidGame)BBAndroidGame.AndroidGame().GetActivity();
		ag.dismissChartboostView();
	}
	*/ 
}
