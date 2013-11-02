#Rem monkeydoc Module congo.revmob
RevMob ad wrapper (iOS and Android only). Requires RevMob sdk to be setup correctly.

** THIS Class IS UNDER DEVELOPMENT ** - it is useable but has limited functionality 
(the full api is not implemented). Currently does connection and some of the ad banner units.
Link ads not supported (req delegate code change?). Callbacks/listeners not implemented.

iOS: 
Open the generated Xcode project and drag the Revmob.framework to the
'Frameworks' section. Also, go to Build Phases section and add the AdSupport,
SystemConfiguration and StoreKit frameworks.

Android:
See the Revmob help pages for the required additions to AndroidManifest.xml, e.g.
the <application> and <uses-permission> sections. Note, the copy of androidmanifest.xml
in the build foler can get overwritten, better to change the main template version.
Also, copy the revmob.x.x.x.jar lib to your ./build/android/libs folder. 

#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict

#If TARGET="ios" 

	Import "native/revmobwrapper.ios.cpp"
	Extern

	#Rem monkeydoc
	Wrapper Class.
	#End
	Class RevMobWrapper = "RevMobWrapper"

		#Rem monkeydoc
		Connect. Session must be started before any ad can be shown.
		Call this early on, e.g. at startup/splashscreen. 
		Use the app id provided To you by RevMob when registering an app.
		See also: Testing modes.
		#End
		Function StartSessionWithAppID:Void( revmob_app_id:String ) = "StartSessionWithAppID"
	
		#Rem monkeydoc
		Show full screen ad. 
		#End	
		Function ShowFullscreen:Void() = "ShowFullscreen"
		
		#Rem monkeydoc
		Show banner ad. This is a thin banner across bottom of screen.
		See also: HideBanner.
		#End	
		Function ShowBanner:Void() = "ShowBanner"
		
		#Rem monkeydoc
		Hides a banner ad.
		#End	
		Function HideBanner:Void() = "HideBanner"
		
		' (cant implement this without adding RevMobAdsDelegate protocol to viewcontroller?)	
		' Function OpenAdLink:Void() = "OpenAdLink"
		
		#Rem monkeydoc
		Enables Revmob's test mode. Ads and clicks can be tested using this.
		Be sure to disable testing mode before submitting to the store.
		#End
		Function TestingWithAds:Void() = "TestingWithAds"
		
		#Rem monkeydoc
		Enables test mode, with ads disabled.
		Be sure to disable testing mode before submitting to the store.
		#End
		Function TestingWithoutAds:Void() = "TestingWithoutAds"
		
		#Rem monkeydoc
		Disables test mode.
		#End
		Function DisableTestMode:Void() = "DisableTestMode"

	End ' (class)

	
#End ' (#If TARGET="ios")

#If TARGET="android" 

	Import "native/revmobwrapper.android.java"
	Extern
	
	#Rem monkeydoc
	Wrapper Class.
	#End
	Class RevMobWrapper = "RevMobWrapper"
	
		#Rem monkeydoc
		Connect. Session must be started before any ad can be shown.
		Call this early on, e.g. at startup/splashscreen. 
		Use the app id provided To you by RevMob when registering an app.
		See also: Testing modes.
		#End
		Function StartSessionWithAppID:Void( revmob_app_id:String ) = "StartSessionWithAppID"
		
		#Rem monkeydoc
		Show full screen ad. 
		#End	
		Function ShowFullscreen:Void() = "ShowFullscreen"
		
		#Rem monkeydoc
		Enables Revmob's test mode. Ads and clicks can be tested using this.
		Be sure to disable testing mode before submitting to the store.
		#End
		Function TestingWithAds:Void() = "TestingWithAds"
		
		#Rem monkeydoc
		Enables test mode, with ads disabled.
		Be sure to disable testing mode before submitting to the store.
		#End
		Function TestingWithoutAds:Void() = "TestingWithoutAds"
		
		#Rem monkeydoc
		Disables test mode.
		#End
		Function DisableTestMode:Void() = "DisableTestMode"
	
	End ' (class)

#End ' (#If TARGET="android")
