// Native code for chartboost wrapper.
// See https://help.chartboost.com/documentation/ios

#import "Chartboost.h" // (chartboost folder must be added to Xcode project).

#define CONGO_CHARTBOOST_IOS_APPID "527552c816ba47fc3b000017" // set to YOUR iOS app id
#define CONGO_CHARTBOOST_IOS_APPSIG "7c4dd4840b077c6217c138074f71810e3c112797" // set to YOUR iOS app sig

class ChartboostWrapper
{

public:

	static void StartSession()
	{
		//NSLog( @"In chartboost iOS StartSession" );
		Chartboost *cb = [ Chartboost sharedChartboost ];
		
		if ( cb == nil )
		{	NSLog( @"Chartboost pointer is null in StartSession" );
			return;
		}
		
	 	cb.appId = @CONGO_CHARTBOOST_IOS_APPID;
	 	cb.appSignature = @CONGO_CHARTBOOST_IOS_APPSIG;
    	
   		[ cb startSession ];
   		// optional: [ cb showInterstitial ];
	}
	
	static void ShowInterstitial( String location )
	{
		//NSLog( @"In chartboost iOS ShowInterstitial" );
		Chartboost *cb = [Chartboost sharedChartboost];
		if ( cb == nil ) 
			NSLog( @"Chartboost pointer is null in ShowInterstitial" );
		if ( cb ) [ cb showInterstitial:location.ToNSString() ];
	}
	
	static void CacheInterstitial( String location )
	{
		//NSLog( @"In chartboost iOS CacheInterstitial" );
		Chartboost *cb = [Chartboost sharedChartboost];
		if ( cb == nil ) 
			NSLog( @"Chartboost pointer is null in CacheInterstitial" );
		if ( cb ) [ cb cacheInterstitial:location.ToNSString() ];
	}
	
	static bool HasCachedInterstitial( String location )
	{
		//NSLog( @"In chartboost iOS HasCachedInterstitial" );
		Chartboost *cb = [Chartboost sharedChartboost];
		if ( cb == nil ) 
			NSLog( @"Chartboost pointer is null in HasCachedInterstitial" );
		if ( cb ) return [ cb hasCachedInterstitial:location.ToNSString() ];
		return false;
	}
	
	static String GetAppID()
	{
		Chartboost *cb = [Chartboost sharedChartboost];
		if ( cb == nil )
		{	NSLog( @"Chartboost pointer is null in GetAppID" );
			return @"failed";
		}
		NSString *appid = @"";
		appid = [ cb appId ];
		return [ appid UTF8String];
	}
	
	static void ShowMoreApps()
	{
		//NSLog( @"In chartboost iOS ShowMoreApps" );
		Chartboost *cb = [Chartboost sharedChartboost];
		if ( cb ) [ cb showMoreApps ];
	}
	
	static void CacheMoreApps()
	{
		//NSLog( @"In chartboost iOS CacheMoreApps" );
		Chartboost *cb = [Chartboost sharedChartboost];
		if ( cb ) [ cb cacheMoreApps ];
	}
	
	static bool HasCachedMoreApps()
	{
		//NSLog( @"In chartboost iOS HasCachedInterstitial" );
		Chartboost *cb = [Chartboost sharedChartboost];
		if ( cb == nil ) 
			NSLog( @"Chartboost pointer is null in HasCachedMoreApps" );
		if ( cb ) return [ cb hasCachedMoreApps ];
		return false;
	}
	
	/*
	static void DismissChartboostView()
	{
		//NSLog( @"In chartboost iOS DismissChartboostView" );
		Chartboost *cb = [Chartboost sharedChartboost];
		if ( cb ) [ cb dismissChartboostView ];
	}
	*/
};
