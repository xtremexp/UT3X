/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XGameViewportClient extends UTGameViewportClient;

var Texture2D smileyTexture;

function DrawTransition(Canvas Canvas)
{
	LogInternal(Outer.TransitionType);
	
	if (Outer.TransitionType == TT_Loading)
	{
			Canvas.Font = class'UTHUD'.static.GetFontSizeIndex(3);
			Canvas.SetPos(0, 0);
			Canvas.SetDrawColor(0, 0, 0, 255);
			Canvas.DrawRect(Canvas.SizeX, Canvas.SizeY);
			Canvas.SetDrawColor(255, 0, 0, 255);
			Canvas.SetPos(100,200);
			Canvas.DrawText("UT3X the best :D ...");
			
			Canvas.SetPos(0, 0);
			Canvas.SetDrawColor(0, 0, 0, 255);
			Canvas.DrawTile(smileyTexture, 
			Canvas.SizeX, Canvas.SizeY, // DIMENSION (maybe still 32x64 max is too big ...)
			smileyTexture.SizeX, smileyTexture.SizeY, //U,V (TEXTURE CENTERING)
			smileyTexture.SizeX, smileyTexture.SizeY); //UL, VL (TEXTURE ROTATION)
	}
}

DefaultProperties
{
	smileyTexture = Texture2D'UI_FrontEnd_Art.Credits.Credits_Port_01';
}

// UI_FrontEnd_Art.Credits.Credits_Port_01
