#Rem monkeydoc Module congo.textutils
Various standalone functions relating to text or strings.
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
Import mojo
Import congo.congosettings

#Rem monkeydoc
Main log function. Only writes in debug mode (edit this as required). 

Dev note - release mode function may still be generated, i.e. it is not 'compiled-out'. 
#End

' note- switched from DebugLog To Print - see http://monkeycoder.co.nz/Community/posts.php?topic=5764#65317
#If CONFIG="debug"
Function CongoLog:Void( str:String )
	Print( str )
End
#Else
Function CongoLog:Void( str:String )
	' (nothing to do - uncomment if release mode log required) 
	'Print( str )
End
#End
