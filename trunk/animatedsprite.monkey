#Rem monkeydoc Module congo.animatedsprite
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
Import mojo

Import congo.sprite
Import congo.timer

#Rem monkeydoc
Extension of Sprite which supports frame-based animation. Frames are loaded from an image atlas or via Texture Packer.

Todo - properties etc.
#End
Class AnimatedSprite Extends Sprite	
	
Private 
	
	Field images:Image[1] ' set of image frames which form the animation.
	Field curImageNum:Int = -1 
	Field totFrames:Int = 0
	
	Field animTimer:Timer = New Timer()	' frame timer. Duraction set in constr.
	Field animNumLoopsLeft:Int = -1	' loop counter. -1 is loop forever.
	Field animCurDir:Int = 1 		' direction of anim - used for bounce anim	
	Field animIsBounce:Bool = False 	' defaults to loop, not bounce
	Field animHideOnComplete:Bool = False ' defaults to retaining the final frame image.
	Field animPaused:Bool = True			' start paused

	#Rem monkeydoc
	Default constr. No images are added, see SetupImageSheet(), or use the other constr. 
	#End
	Method New()
		'(nothing to do here)
	End

Public	
	#Rem monkeydoc
	Main constr. Sets up array of images from the provided atlas. Use StartAnim() afterwards to begin the animation.
	If you don't provide frame sizes or initial offset it will simply divide up the atlas evenly based on number of rows and columns.
	
	Do not use Image.MidHandle on the sprite sheet, the frames are centered automatically.
	#End
	Method New(	myImg:Image, numFrames:Int, numCols:Int, numRows:Int, frameWidth:Int = -1, frameHeight:Int = -1, offsetX:Int = 0, offsetY:Int = 0)
	
		SetupImageSheet( myImg, numFrames, numCols, numRows, frameWidth, frameHeight, offsetX, offsetY )
		InitResScaler()

	End 
	
	#Rem monkeydoc
	Starts an animation with the specified properties. Set numLoops to -1 to loop forever.
	Fps is frames-per-second, defaults to 60.
	Use isBounce to make the animation reverse when reaching the final frame, and so on.
	Set hideOnComplete to prevent the final frame staying visible forever at end.
	#End
	Method StartAnim:Void( fps:Float = 60.0, numLoops:Int = -1, isReversed:Bool = False, isBounce:Bool = False, hideOnComplete:Bool = False )
	
		If images.Length() <= 1 Error ( CONGO_ERROR_STRING + "StartAnim, image does not have any animation frames loaded" )
		
		animPaused = False
		animTimer.SetDuration( 1.0/fps * 1000.0 )
		animTimer.Reset() ' (could be running already)
		animNumLoopsLeft = numLoops
		animIsBounce = isBounce
		animHideOnComplete = hideOnComplete
		curImageNum = 0
		
		animCurDir = 1
		If isReversed Then
			animCurDir = -1
			curImageNum = images.Length() -1
		End
		
	End
	
	#Rem monkeydoc
	Stops the animation.
	#End
	Method StopAnim:Void()
		animTimer.CurrentTime = animTimer.Duration
		animNumLoopsLeft = 0
	End
	
	#Rem monkeydoc
	Pauses the animation.
	#End
	Method PauseAnim:Void()
		animPaused = True
	End
	
	Method AnimPaused:Bool()
		Return animPaused
	End
	
	#Rem monkeydoc
	Resumes the animation.
	#End
	Method ResumeAnim:Void()
		animPaused = False
	End
	
	#Rem monkeydoc
	Jumps to the specified frame. Throws an error if the frame is out of range.
	#End
	Method GoToFrame:Void( fnum:Int )
	
		If fnum < 0 Or fnum >= images.Length() Or images.Length() = 0 Then
			Error( CONGO_ERROR_STRING + "GoToFrame - frame out of range" )
		End
		
		curImageNum = fnum
	
	End
	
	#Rem monkeydoc
	Jumps to the final frame.
	#End
	Method GoToFinalFrame:Void()
	
		If images.Length() = 0 Then
			Error( CONGO_ERROR_STRING + "GoToFinalFrame - image has no frames" )
		End
		
		curImageNum = images.Length() - 1
	
	End
	
	#Rem monkeydoc
	Overrides the Sprite class method - sets the image at position 0 of our image array.
	Hence, it can behave like a regular single frame sprite, if required.
	#End
	Method SetMainImage:Void( img:Image )
	
		images[0] = img
		curImageNum = 0
		InitResScaler()
		
	End
	
	#Rem monkeydoc
	Returns the currently showing image frame number
	#End
	Method CurImageNumber:Int() Property
		Return curImageNum
	End
	
	#Rem monkeydoc
	Overrides the Sprite class method to return the current image frame.
	#End
	Method GetCurrentImage:Image()
		If curImageNum < 0 Return Null
		Return images[curImageNum]
	End
	
	#Rem monkeydoc
	Overrides the Sprite class method to return the width of the current image.
	#End
	' returns current image width (original, non-scaled), or 0 if no current image
	Method ImageWidth:Float() Property
	
		If curImageNum < 0 Return 0.0
		Return images[curImageNum].Width()
	
	End
	
	#Rem monkeydoc
	Overrides the Sprite class method to return the height of the current image.
	#End
	' returns current image height (original, non-scaled), or 0 if no currentimage
	Method ImageHeight:Float() Property
	
		If curImageNum < 0 Return 0.0
		Return images[curImageNum].Height()
	
	End
	
	#Rem monkeydoc
	(Advanced use). Directly sets the image at the chosen frame position in our array (will expand array automatically if required).
	#End
	Method SetImage:Void( myImg:Image, frameNum:Int )
		If frameNum < 0  Error( CONGO_ERROR_STRING + "AnimatedSprite SetImage arg out of range" )
		If images.Length() <= frameNum Then
			images = images.Resize( frameNum + 1 )
		End 
		images[frameNum] = myImg
	End
	
	#Rem monkeydoc
	Sets up array of images from the provided sheet. Called from main constr, see notes there.
	#End
	Method SetupImageSheet:Void(	myImg:Image, numFrames:Int, numCols:Int, numRows:Int, frameWidth:Int = -1, frameHeight:Int = -1, offsetX:Int = 0, offsetY:Int = 0)

		If ( myImg = Null ) Error( CONGO_ERROR_STRING + "Supplied image for animations appears to be null" )
		
		images = images.Resize( numFrames )
		curImageNum = 0

		InitResScaler() ' repeated, just in case not set via constr
		
		Local frWidth:Float
		Local frHeight:Float
		
		If frameWidth = -1 Then
			frWidth = Float(myImg.Width()) / Float(numCols)  ' work in floats. Ideally these are whole numbers, of course...
			frHeight = Float(myImg.Height()) / Float(numRows)
		Else ' user supplied them
			frWidth = frameWidth
			frHeight = frameHeight
		End
		
		CongoLog( CONGO_NAME_STRING + ": Image size " + myImg.Width() + " x " + myImg.Height() + " - frames will be " + frWidth + " x " + frHeight )
		
		Local row:Int = 0
		Local col:Int = 0
		For Local i:Int = 0 To numFrames-1
			images[i] = myImg.GrabImage( offsetX+ col*frWidth, offsetY + row*frHeight, frWidth, frHeight, 1, Image.MidHandle )
			'Print "Grabbed anim frame " + i + " at " + col*frWidth + ", " + row*frHeight
			col += 1
			If col >= numCols Then
				col = 0
				row += 1
			End
			If row > numRows Error( CONGO_ERROR_STRING + "Row greater than numRows in anim loader" )

		Next
	
	End 
	
	#Rem monkeydoc
	Clears the array of image frames, replacing it with default empty frame. Resets curent image number to 0.
	You might need this if re-using an AnimatedSprite and need to replace the previous set of frames.	
	#End
	Method ClearImageSheet:Void()
		'images = images.Resize( 1 )
		images = New Image[1]
		curImageNum = 0
		totFrames = 1
		
	End
	
	#Rem monkeydoc
	Overrides the base method to paint the current frame.
	#End
	Method PaintItem:Void()

		If curImageNum >= 0 Then 
			SetAlpha( Self.Opacity )
			DrawImage ( images[curImageNum], 0, 0 )
			mojo.SetAlpha( 1.0 )
		End

	End

	#Rem monkeydoc
	Overrides the Sprite method to deal with pausing the animation.
	#End

	Method Update:Void( dT:Int )
	
		If Not CongoApp.IsPaused() UpdateAnim( dT )
		
		Super.Update( dT )
		
	End

Private
	
	#Rem monkeydoc
	Internal. Uses timer to update the frame animation. Called from Update(), you don't normally need to call this yourself.	
	#End
	Method UpdateAnim:Void( dT:Int )
	
		If animPaused Return
		
		animTimer.Update( dT )
		
		If animTimer.Completed() And animNumLoopsLeft <> 0 Then ' (endless anims go start below 0 )

			animTimer.Reset()
			curImageNum += animCurDir

			' check for reaching end of current loop
			If curImageNum >= images.Length() Then
	
				animNumLoopsLeft -= 1 ' weve done a loop
				If animIsBounce Then 
					curImageNum = images.Length() -1
					animCurDir = -1
				Else
					If animNumLoopsLeft <> 0  Then
						curImageNum = 0 ' back to start
					Else 
						If animHideOnComplete Then
							curImageNum = -1
						Else ' restore initial image
							curImageNum = images.Length() -1 ' stay on final frame
						End
					End
				End

			' check for reaching start again (reverse/bounce)
			Else If curImageNum < 0 Then
					
				animNumLoopsLeft -= 1 ' weve done a loop
				If animIsBounce Then 
					curImageNum = 0
					animCurDir = 1
				Else
						
					If animNumLoopsLeft <> 0 Then 
						curImageNum = images.Length() -1 ' back to final frame
					Else 
						If animHideOnComplete Then
							curImageNum = -1
						Else ' restore initial image
							curImageNum = 0 ' stay on first frame
						End
					End
				End
				
			End 	'(curImageNum)
		End 	 '(animInternalTimer)
		
	End

End
