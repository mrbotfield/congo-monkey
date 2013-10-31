#Rem monkeydoc Module congo.revmob
RevMob ad wrapper (iOS and Android only). Requires RevMob sdk to be setup correctly.

Mac notes: open the generated Xcode project and drag the Revmob.framework to the
'Frameworks' section. Also, go to Build Phases section and add the AdSupport,
SystemConfiguration and StoreKit frameworks.

** THIS Class IS UNDER DEVELOPMENT ** - it is useable but has limited functionality 
(the full api is not implemented). Currently does connection and some of the ad banner units.
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict

' (all code skipped if not ios target)
#If TARGET="ios" 

	Import "native/revmobwrapper.ios.cpp"
	Extern

	#Rem monkeydoc
	Wrapper Class.
	#End
	Class RevMobWrapper = "RevMobWrapper"

		#Rem monkeydoc
		Connect. Call this early on, e.g. at startup/splashscreen. 
		Use the app id provided To you by RevMob when registering an app.
		#End
		Function StartSessionWithAppID:Void( revmob_app_id:String ) = "StartSessionWithAppID"
	
		#Rem monkeydoc
		Show full screen ad. Session must be started first.
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

	
#End ' (#If TARGET="ios")
