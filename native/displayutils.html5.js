
// Native code for display utils.

// see http://stackoverflow.com/questions/13325421/hide-idle-cursor-on-web-page-in-chrome
HideMouseCursor=function()
{
	document.getElementById("GameCanvas").style.cursor="url(data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==), pointer";
}
	
RestoreMouseCursor=function()
{
	document.getElementById("GameCanvas").style.cursor="default";
}

	