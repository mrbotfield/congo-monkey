#Rem monkeydoc Module congo.networkutils
Various standalone network/browser functions. Some have platform-specific native code.
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
Import mojo
Import congo.congosettings

' (Dev note - make sure imports are before other variables, and Extern is before Public functions etc)


#If TARGET="glfw"
	Import "native/networkutils.${TARGET}.cpp"
	Extern
	#Rem monkeydoc
	DEPRECATED - use mojo OpenUrl instead.
	[GLFW] Opens a browser page with the given URL. Exact behaviour depends on target platform.
	Windowname is usually one of _blank, _self, _parent, _top.
	#End
	Function OpenBrowserURL:Void( url:String, windowName:String = "_blank" ) = "OpenBrowserURL"
#End

#If TARGET="html5"
	Import "native/networkutils.${TARGET}.js"
	Extern
	#Rem monkeydoc
	DEPRECATED - use mojo OpenUrl instead.
	[HTML5] Opens a browser page with the given URL. Exact behaviour depends on target platform.
	Windowname is usually one of _blank, _self, _parent, _top.
	#End
	Function OpenBrowserURL:Void( url:String, windowName:String = "_blank" ) = "OpenBrowserURL"
#End

#If TARGET="flash"
	Import "native/networkutils.${TARGET}.as"
	Extern
	#Rem monkeydoc
	DEPRECATED - use mojo OpenUrl instead.
	[Flash] Opens a browser page with the given URL. Exact behaviour depends on target platform.
	Windowname is usually one of _blank, _self, _parent, _top.
	#End
	Function OpenBrowserURL:Void( url:String, windowName:String = "_blank" ) = "OpenBrowserURL"
#End

