Strict

Import mojo
Import congo
Import congo.chartboost
'Import congo.revmob

Function Main:Int()

	New MyApp
	Return 0
	
End

Class MyApp Extends CongoApp  
	
	Method OnCreate:Int()
	
		CongoLog( "In MyApp OnCreate" )
		
		Super.OnCreate() ' *Required* for CongoApps.
	  	SetUpdateRate (60)
	 	SetVirtualDisplay ( 640, 480 )
	 	Local al:AppLayer = New SimpleLayer( VDeviceWidth(), VDeviceHeight() )
	 	CongoApp.SetCurrentLayer( al )

		' Ad connections
		AdConnect()
		
		Print "Touch to show ad"
	  	    
	    Return 0
	    
	End
	
	Method AdConnect:Void()
		
		Print "AdConnect..."
		#If TARGET="ios" Or TARGET="android"
			
			' Chartboost
			Print "StartSession..."
			ChartboostWrapper.StartSession()
			Local id:String = ChartboostWrapper.GetAppID()
			Print "chartboost app id = " + id
			' caching.
			Print "requesting caching ads..."
			ChartboostWrapper.CacheMoreApps()
			ChartboostWrapper.CacheInterstitial()
	
			' Revmob:
			'RevMobWrapper.StartSessionWithAppID( "YOUR-ID" ) 
			'RevMobWrapper.TestingWithAds() ' enables test mode
		#Else
			Print "Unsupported platform"		
		#End
		
	End
	
	Method OnResume:Int()
	
		Super.OnResume()
		Print "OnResume"
		' re-do ad connect.
		AdConnect()
		Return 0
	
	End
	
End
	
Class SimpleLayer Extends AppLayer
	
	Field touchhold:Bool = False 
	
	Method New( w:Int, h:Int)
		
		Super.New( w, h ) ' (call to Super.New must be before other code)
		Print "New SimpleLayer"
		CongoApp.SetScreenColor( 0, 0, 0 )
	
	End
	
	Method ChartboostAd:Void()
	
		Print "ChartboostAd!"		
		
		' Chartboost:
		Local appid:String = ChartboostWrapper.GetAppID()
		Print " *** get appid: " + appid 
		If ChartboostWrapper.HasCachedInterstitial() Then
			Print "HasCachedInterstitial = true!"
		Else
			Print " -- no cached ad -- "
		End
		
		ChartboostWrapper.ShowInterstitial()

	End 
	
	Method ChartboostMoreApps:Void()
	
		Print "ChartboostMoreApps!"
		
		' Chartboost:
		If ChartboostWrapper.HasCachedMoreApps() Then
			Print "HasCachedMoreApps = true!"
		Else
			Print " -- not cached more games -- "
		End		
		
		ChartboostWrapper.ShowMoreApps()
		 
	End
	
	Method Draw:Void()
	
		DrawText( "Press for ad", 320, 240, 0.5, 0.5 )
		DrawText( "Press for more apps", 320, 280, 0.5, 0.5 )

	End
	
	Method Update:Void( dT:Int )
	
	If touchhold = False And TouchDown(0) = 1 And Abs( VTouchY() - 240 ) < 20 Then
		Print "(text touched)"
		ChartboostAd()
		touchhold = True
	End
	If touchhold = False And TouchDown(0) = 1 And Abs( VTouchY() - 280 ) < 20 Then
		Print "(text touched)"
		ChartboostMoreApps()
		touchhold = True
	End
	
	If TouchDown(0) = 0 touchhold = false
		
	End
	
End
