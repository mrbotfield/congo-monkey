#Rem monkeydoc Module congo
Main import file for Congo. Use 'Import congo' to include all files in your project, Monkey will only compile the ones you use. 

To test, try running the applications in the Examples folder. 
#End

Strict
Import mojo

Import congo.congosettings
Import congo.congoapp
Import congo.point
Import congo.rect
Import congo.displayitem
Import congo.sprite
Import congo.animatedsprite
Import congo.layer
Import congo.applayer
Import congo.collisionlayer
Import congo.scrolllayer
Import congo.texturecache
Import congo.soundcache
Import congo.action
Import congo.easefunction
Import congo.timer
Import congo.button
'Import congo.menu ' WIP
Import congo.displayutils
Import congo.networkutils
Import congo.audioutils
Import congo.soundplayer
Import congo.textutils
Import congo.touchmanager
Import congo.transition
Import congo.particleemitter
Import congo.textlabel ' wraps angelfont into our display class.
Import congo.gamedata

Import congo.autofit ' uses a slightly modified version of autofit2

Import congo.angelfont ' snapshot of angelfont classes, minor tweaks
Import congo.angelfont.simpletextbox ' 

' physics - these require box2d module to be installed
Import congo.physicssprite
Import congo.physicsworld
Import congo.animatedphysicssprite  ' dec2013. need better fix...
 
' mochi media (flash only). Requires mochi sdk, and path update so  
' mxmlc can find it (e.g. edit source-path in flex-config.xml).
Import congo.mochi

' Enable for RevMob (iOS and android only). Requires RevMob setup, see docs.
' Import congo.revmob ' WIP

' enable for Chartboost (iOS and android only). Requires Chartboost setup, see docs.
'Import congo.chartboost  ' WIP
