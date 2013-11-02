
// Native code for revmob wrapper.

#import <RevMobAds/RevMobAds.h> // (Framework must be setup in xcode project).

class RevMobWrapper
{

public:

	static void StartSessionWithAppID( String revmob_app_id )
	{
		//NSLog( @"In revmob iOS StartSessionWithAppID" );
		[ RevMobAds startSessionWithAppID:revmob_app_id.ToNSString() ];
	}
	
	static void ShowFullscreen()
	{
		//NSLog( @"In revmob iOS ShowFullscreen" );
		[[RevMobAds session] showFullscreen];
	}
	
	static void ShowBanner()
	{
		//NSLog( @"In revmob iOS ShowBanner" );
		[[RevMobAds session] showBanner];
	}
	
	static void HideBanner()
	{
		//NSLog( @"In revmob iOS HideBanner" );
		[[RevMobAds session] hideBanner];
	}
	
	/*
	static void OpenAdLink()
	{
		//NSLog( @"In revmob iOS OpenAdLink" );
		MonkeyAppDelegate *appDelegate = (MonkeyAppDelegate *)[[UIApplication sharedApplication] delegate];
		[[RevMobAds session] openAdLinkWithDelegate:appDelegate];
	}
	*/
	
	static void TestingWithAds()
	{
		//NSLog( @"In revmob iOS TestingWithAds" );
		[RevMobAds session].testingMode = RevMobAdsTestingModeWithAds;
	}
	
	static void TestingWithoutAds()
	{
		//NSLog( @"In revmob iOS TestingWithoutAds" );
		[RevMobAds session].testingMode = RevMobAdsTestingModeWithoutAds;
	}
	
	static void DisableTestMode()
	{
		//NSLog( @"In revmob iOS DisableTestMode" );
		[RevMobAds session].testingMode = RevMobAdsTestingModeOff;
	}
};
