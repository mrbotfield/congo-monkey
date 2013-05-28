
// Native code for display utils.

float GetContentScaleFactor()
{
	//NSLog( @"In iOS GetContentScaleFactor" );
	// return [[UIScreen mainScreen] scale];
	
	MonkeyAppDelegate *appDelegate = (MonkeyAppDelegate *)[[UIApplication sharedApplication] delegate];
		
	// MonkeyView* mv = app->appDelegate->view;
	MonkeyView* mv = appDelegate->view;
	
	if( [mv respondsToSelector:@selector(contentScaleFactor)] )
		return [ mv contentScaleFactor ];
	else
		NSLog( @"(contentScaleFactor not supported on device)" );
		
	return 1.0f;
}
	
	