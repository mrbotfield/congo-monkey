#Rem monkeydoc Module congo.sprite
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
Import mojo

Import congo.displayitem
Import congo.point
Import congo.rect
Import congo.congosettings
Import congo.action
Import congo.displayutils
Import congo.textutils

#Rem monkeydoc
Main sprite class. Can load atlas/spritesheets, import from TexturePacker.
Since it is derived from DisplayItem, it can own child items and run actions.

Uses TextureCache to store it's Images.

See also AnimatedSprite, for frame-based animation.

Todo: remove child fns?
#End
Class Sprite Extends DisplayItem
	
Private

	Field image:Image = Null

	Field bBoxHeightScale:Float = 1.0 	' Can use this to reduce the collision box rect.
	Field bBoxWidthScale:Float = 1.0 	' as above.

	Field disableCollisions:Bool = False ' used by CollisionLayer to disable collisions for this Sprite.

Public

	#Rem monkeydoc
	Default constr. No images are added, but can be added later using SetMainImage.
	#End
	Method New()		
		' (nothing to do here)
	End
	
	#Rem monkeydoc
	Creates a Sprite with a single image. See also CongoResourceLoader (in DisplayUtils) to load an Image.
	You can set Image.MidHandle on the image as required.
	#End
	Method New( myImg:Image )
		
		SetMainImage( myImg )

	End
	
	#Rem monkeydoc
	Creates a Sprite from a Texturepacker file. See LoadFromTP for more information.
	#End
	Method New( tpimg:Image, dataName:String, imageName:String )
	
		Local valid:Bool = Self.LoadFromTP( tpimg, dataName, imageName )

	End
	
	#Rem monkeydoc
	Manually change the Image associated with the Sprite.
	#End
	Method SetMainImage:Void( img:Image )
	
		image = img
		InitResScaler()
		
	End
	
	#Rem monkeydoc
	Returns the current main Image (could be Null if not set).
	#End
	Method GetCurrentImage:Image()

		Return image
	End
	
	#Rem monkeydoc
	Internal. Sets res scale factor based on display settings. i.e. if the display is set-up for
	hd images then the res scale will be set to 2.0 to double the base size.
	This is called automatically from the constr, or when the main image is changed, you don't usually
	need to do this manually.
	#End
	Method InitResScaler:Void( autoDetect:Bool = True, scale:Float = 1.0 )
		
		If autoDetect Then
			If IsUsingXHDResources() Then
				Self.ResScaler = 4.0
			Else If IsUsingHDResources() Then
			 	Self.ResScaler = 2.0
			Else
				Self.ResScaler = 1.0
			End
		
		Else
			Self.ResScaler = scale
		End
		
	End

	#Rem monkeydoc
	Returns the current Image width (original, non-scaled), or 0 if no current image.
	#End
	Method ImageWidth:Float() Property
	
		If image = Null Return 0.0
		Return image.Width()
	
	End
	
	#Rem monkeydoc
	Returns the current Image height (original, non-scaled), or 0 if no current image.
	#End	
	Method ImageHeight:Float() Property
	
		If image = Null Return 0.0
		Return image.Height()
	
	End
	
	#Rem monkeydoc
	Returns the Bounding box height scale factor, default 1.0. Used by CollisionLayer.
	#End
	Method BoundingBoxHeightScale:Float() Property
		Return bBoxHeightScale
	End
	
	#Rem monkeydoc
	Sets the Bounding box height scale factor, default 1.0. Used by CollisionLayer.
	#End
	Method BoundingBoxHeightScale:Void( scale:Float ) Property
		bBoxHeightScale = scale
	End
	
	#Rem monkeydoc
	Returns the Bounding box width scale factor, default 1.0. Used by CollisionLayer.
	#End
	Method BoundingBoxWidthScale:Float() Property
		Return bBoxWidthScale
	End
	
	#Rem monkeydoc
	Sets the Bounding box width scale factor, default 1.0. Used by CollisionLayer.
	#End
	Method BoundingBoxWidthScale:Void( scale:Float ) Property
		bBoxWidthScale = scale
	End

	#Rem monkeydoc
	Returns the bounding box height. Used by CollisionLayer.
	By default this is the same as the current ImageHeight (adjusted for sd/hd/xhd res scalefactor), 
	and also scaled by the user-defined boundingBoxHeightScale. Local, not global coords.
	#End
	Method BoundingBoxHeight:Float()
		' could cache this?
		Return bBoxHeightScale*ImageHeight() / ResScaler
		
	End
	
	#Rem monkeydoc
	Returns the bounding box width. Used by CollisionLayer.
	By default this is the same as the current ImageHeight (adjusted for sd/hd/xhd res scalefactor), 
	and also scaled by the user-defined boundingBoxHeightScale. Local, not global coords.
	#End
	' Returns the bounding box height.
	' By default this is the same as the current ImageWidth (unadjusted for sd/hd scalefactor), 
	' scaled by the user-defined setting boundingBoxWidthScale. Local, not global coords.
	Method BoundingBoxWidth:Float()
		' could cache this?
		Return bBoxWidthScale*ImageWidth() / ResScaler
		
	End

	#Rem monkeydoc
	Returns the bounding rect in local coordinates. Used by CollisionLayer hit detection. 
	The box size can be customised (e.g. reduced or expanded beyond usual Image size) by overriding
	BoundingBoxHeight or BoundingBoxWidth.
	
	Known issues: doesn't deal with non-centre rotation handles.
	#End
	Method GetBoundingRect:Rect()
		
		' if no image, just a point really.
		If GetCurrentImage() = Null Return New Rect( Position.x, Position.y, 0.0, 0.0 )

		Local colboxw:Float = BoundingBoxWidth()
		Local colboxh:Float = BoundingBoxHeight()

		' Rotate the bounding rect if its worth it... (optimised a bit for small rotation or almost square aabb)
		' Ref http://willperone.net/Code/coderr.php
		If Abs(Angle) > 10.0 And Max(colboxw,colboxh)/Min(colboxw,colboxh) > 1.2 Then
		
			Local sn:Float = Abs( Sin( Angle ) )
			Local cs:Float = Abs( Cos( Angle ) )
			Local neww:Float = YScale*colboxh*sn + XScale*colboxw*cs
			Local newh:Float = YScale*colboxh*cs + XScale*colboxw*sn
			colboxw = neww/XScale
			colboxh = newh/YScale
		
		End

		' re-centre for reduced collision box
		Local boxdisplx:Float = ( ImageWidth()/ResScaler - colboxw ) * 0.5 *Abs(XScale)
		Local boxdisply:Float = ( ImageHeight()/ResScaler - colboxh ) * 0.5 *Abs(YScale)
		
		' Rect is a bit complex, we must deal with handles, scaling, flip.
		Local rec:Rect = New Rect( Position.x +Handle.x+ boxdisplx - Abs(XScale)*(Handle.x + GetCurrentImage().HandleX() /ResScaler ),
				  			Position.y +Handle.y+ boxdisply - Abs(YScale)*(Handle.y + GetCurrentImage().HandleY() /ResScaler ),
				 			colboxw*Abs(XScale), colboxh*Abs(YScale) )
	
		Return rec
	
	End

	#Rem monkeydoc
	Loads Image from Texturepacker file (Generic xml format). Can be called on a current Sprite,
	or more usually, called from the constructor on creation of the Sprite.

	Will throw exception if image atlas is invalid. 
	This method uses TextureCache for future requests for the same image resource.

	Important! Do *NOT* use Image.MidHandle on the sprite sheet, the frames will be centered automatically.

	Note, don't supply 'hd' or other extension names for the xml *or* the image names, this routine will add them.
	All names are case-sensitive.
	#End
	Method LoadFromTP:Bool( tpimg:Image, dataName:String, imageName:String )

		Local valid:Bool = False 
		If ( tpimg = Null ) Error( CONGO_ERROR_STRING + "Supplied Texturepacker image appears to be null" )
		
		' need to deal with hd versions:
		InitResScaler()

		image = ImageFromTP( tpimg, dataName, imageName )
		Return image <> Null
	
	End

	#Rem monkeydoc
	Main Update. Derived classes can override this, remember to call Super.Update()!
	#End
	Method Update:Void( dT:Int )
	
		Super.Update( dT )

	End	
	
	#Rem monkeydoc
	All DisplayItems must implement the base class PaintItem method.
	#End
	Method PaintItem:Void()

		If image Then 
			SetAlpha( Self.Opacity )
			DrawImage ( image, 0, 0 )
			mojo.SetAlpha( 1.0 )
		End

	End
	
	#Rem monkeydoc
	For debugging purposes, draws the bounding rect (local coords). Color is based on bounding rect size.
	#End
	Method DrawBoundingRect:Void()
	
		If Not Hidden()
			Local crect:Rect = GetBoundingRect()
		 	SetColor( 255, 0, 0 )
		 	If crect.Width > 50 SetColor( 0, 0, 255 )
		 	If crect.Width > 100 SetColor( 0, 255, 0 )
		 	If crect.Width > 150 SetColor( 255, 255, 0 )
		 	If crect.Width > 200 SetColor( 0, 255, 255 )
		 	DrawBox( crect )
		 	SetColor( 255, 255, 255 ) ' important!
		End
		
	End
	
	#Rem monkeydoc
	Returns the status of the collision detection flag for this Sprite. Used in CollisionLayer (or use for your own
	purposes).
	#End
	Method CollisionsDisabled:Bool() Property
		Return disableCollisions
	End

	#Rem monkeydoc
	Set this flag to remove the Sprite from any collision detection performed in a CollisionLayer (or use for your own
	purposes).
	#End
	Method DisableCollisions:Void( state:Bool = True ) Property
		disableCollisions = state
	End


' ==== Experimental functions ====

	#Rem monkeydoc
	Experimental, not for use yet. 
	Draws the bounding rect using the cached global transform. Color is based on bounding rect size.
	#End
	Method DrawGlobalBoundingRect:Void()
	
		' Set identity matrix since coords are global
		PushMatrix()
		Local mat:Float[6]
		mat[0] = 1; mat[1] = 0; mat[2] = 0; mat[3] = 1; mat[4] = 0; mat[5] = 0;
		SetMatrix( mat )
	
		If Not Hidden() And Not disableCollisions Then  '''And Not IsLayer()
			Local crect:Rect = GlobalCollisionRect()
		 	SetColor( 255, 0, 0 )
		 	If crect.Width > 50 SetColor( 0, 0, 255 )
		 	If crect.Width > 100 SetColor( 0, 255, 0 )
		 	If crect.Width > 150 SetColor( 255, 255, 0 )
		 	If crect.Width > 200 SetColor( 0, 255, 255 )
		 	DrawBox( crect )
		 	SetColor( 255, 255, 255 ) ' important!
		End
		
		PopMatrix()
		
	End


#rem
	#Rem monkeydoc
	For advanced use. Returns the Sprite's current transform matrix (6 float array). 
	You may need this for custom Draw code. Note, this data only gets set in the Draw step.
	#End
	Method TransformationMatrix:Float[]() Property
		Return trMatrix
	End	
#End	

End
