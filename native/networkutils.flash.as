
// Native code for network utils.

// as3 docs: http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/net/package.html
//
// Note, embed param requires allowScriptAccess=always, else you may get SecurityError: Error #2137.
// 	(see http://www.actionscript.org/forums/showthread.php3?t=244086 )

import flash.net.navigateToURL;
import flash.net.URLRequest;

function OpenBrowserURL( url:String, windowName:String ):void
{
	navigateToURL(new URLRequest(url), windowName );
}

