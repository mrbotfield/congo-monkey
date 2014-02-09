#Rem monkeydoc Module congo.chartboost
Chartboost wrapper (iOS and Android only). 

** THIS CLASS IS UNDER DEVELOPMENT ** - it is useable but has limited functionality 
(the full api is implementd but not the callbacks/listeners).

Requires Chartboost SDK to be setup correctly.
See the accompanying congo-chartboost-guide.txt file for further setup instructions.
(Android requires editing of template Monkey files, and manifest).

#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2014. This code is released under the MIT License - see LICENSE.txt.

Strict

#If TARGET="ios"

	Import "native/chartboostwrapper.ios.cpp"
	Extern
#End
#If TARGET="android" 

	Import "native/chartboostwrapper.android.java"
	Extern
#end

#If TARGET="ios" Or TARGET="android"

	#Rem monkeydoc
	Wrapper Class.
	#End
	Class ChartboostWrapper = "ChartboostWrapper"
	
		#Rem monkeydoc
		Connect, using the predefined app id and app signature. Must call before any ad is shown. 
		Chartboost docs mention this should be called *every time your app becomes active*.
		This function will not show an add, see ShowInterstitial.
		#End
		Function StartSession:Void() = "StartSession"
	
		#Rem monkeydoc
		Show a full screen interstitial ad. Location is optional, e.g. for tracking different ad placement.
		#End	
		Function ShowInterstitial:Void( location:String = "Default" ) = "ShowInterstitial"
		
		#Rem monkeydoc
		Caches an interstitial ad ahead of use. Location is optional.
		#End	
		Function CacheInterstitial:Void( location:String = "Default" ) = "CacheInterstitial"
		
		#Rem monkeydoc
		Returns true if has cached an interstitial ad. Location is optional.
		#End	
		Function HasCachedInterstitial:Bool( location:String = "Default" ) = "HasCachedInterstitial"
		
		#Rem monkeydoc
		Returns the current app id. This can be used as a 'sanity check', it confirms that Chartboost
		has at least been initialised with the app id.
		#End
		Function GetAppID:String() = "GetAppID"
		
		#Rem monkeydoc
		Show the "More apps" page. Requires campaign setup in dashboard, see docs. 
		It is recommended to cache this first to avoid any delays.
		(these don't support 'locations').
		#End	
		Function ShowMoreApps:Void() = "ShowMoreApps"
		
		#Rem monkeydoc
		Caches the "More apps" page.
		#End	
		Function CacheMoreApps:Void() = "CacheMoreApps"
		
		#Rem monkeydoc
		Returns true if has cached the "More apps" page.
		#End	
		Function HasCachedMoreApps:Bool() = "HasCachedMoreApps"
		
		#Rem monkeydoc
		Can be used to dismiss any Chartboost view programatically.
		#End
		' Function DismissChartboostView:Void() = "DismissChartboostView"

	End ' (class)

	
#End 
