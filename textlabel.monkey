#Rem monkeydoc Module congo.textlabel
#End

' Part of the 'Congo' module for Monkey.
' (c) Barry R Smith 2012-2013. This code is released under the MIT License - see LICENSE.txt.

Strict
Import mojo

Import congo.sprite
Import congo.angelfont
Import congo.angelfont.simpletextbox

#Rem monkeydoc
A multi-line text label. It wraps angelfont classes to provide a Sprite interface.
Labels cannot have child sprites.
#End
Class TextLabel Extends Sprite

Private
	' (label position is just Sprite position)
	Field m_text:String = "Your text"
	Field m_align:Int = AngelFont.ALIGN_LEFT
	Field m_tb:SimpleTextBox = New SimpleTextBox() ' this class is from the angelfont code.
	Field m_boxwidth:Int = 1000
	Field m_font:AngelFont = Null

Public

	#Rem monkeydoc
	Creates a text label. Remember to create the font first (use CongoFontLoader) -- Labels can share fonts.
	Angelfont alignment options are ALIGN_LEFT, ALIGN_CENTER and ALIGN_RIGHT.
	
	Useful characters: ~n = newline, ~q = double quotation mark (see Monkey docs)
	#End
	Method New( text:String, font:AngelFont, xpos:Float = 0, ypos:Float = 0, align:Int = AngelFont.ALIGN_LEFT, boxWidth:Int = 1000 )

		m_text = text
		Self.SetPosition( xpos, ypos )
		m_align = align
		m_boxwidth = boxWidth
		m_font = font

		InitResScaler()
		
	End
	
	#Rem monkeydoc
	Sets the text to show.
	#End
	Method SetText:Void( text:String )
	
		m_text = text
		
	End
	
	#Rem monkeydoc
	Appends to the current text.
	#End
	Method AppendText:Void( text:String )
	
		m_text += text
	
	End
	
	#Rem monkeydoc
	Returns the currently displayed text.
	#End
	Method Text:String() Property
	
		Return m_text
		
	End
	
	Method Draw:Void()

		If Hidden Return
		
		PushMatrix()
		Translate( Position.x + Handle.x, Position.y + Handle.y )
		If Angle Rotate( Self.Angle)
		Scale( XScale/ResScaler(), YScale/ResScaler() )
		Translate( -Handle.x, -Handle.y )
		SetAlpha( Self.Opacity )
		
		m_font.Use() ' angelfont keeps a global 'current' font, this sets it to our font.
		m_tb.Draw( m_text, 0.0, 0.0, m_boxwidth, m_align )
		
		mojo.SetAlpha( 1.0 )
		
		PopMatrix()
	End
	
End
