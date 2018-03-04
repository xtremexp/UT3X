/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XUTCTFHUD extends UTVehicleCTFHUD;



var bool bNeedLoading;
var config bool bFirstRun;

var UT3XSmileyReplicationInfo SmileyReplication;
var int Attempts;


/*
function SetupSmileyReplication()
{
	local UT3XSmileyReplicationInfo Emo;
	local int i;

	return;
	
	
	for(i=0; i<=Attempts; i++){
		foreach DynamicActors(class'UT3XSmileyReplicationInfo', Emo)
		{
			if(Emo.Owner == PlayerOwner)
			{
				SmileyReplication = Emo;
				break;
				return;
			}
		}
	}
}*/

/*
function DrawHud()
{
	if(bNeedLoading){
		if(PlayerOwner != None)
		{
			(UTPlayerController(PlayerOwner)).LoadSettingsFromProfile(True);
			bNeedLoading = false;
		}
	}
	Super.DrawHud();
}*/


static function string StripColorForTTS(string S)
{
	local int P;

	P = InStr(S, Chr(27));
	J0x11:

	// End:0x54 Loop:True
	if(P >= 0)
	{
		S = Left(S, P) $ Mid(S, P + 4);
		P = InStr(S, Chr(27));
		// This is an implied JumpToken; Continue!
		goto J0x11;
	}
	return S;
}

function DrawsmileysText(string S, Canvas C, optional out float XXL, optional out float XYL)
{
	/*
	local int i, N;
	local float PX, PY, XL, YL, CurX, CurY,
		SScale, Sca, AdditionalY, NewAY;

	local string D;
	local Color OrgC;
	local Texture2D EIcon;

	// End:0x11 Loop:False
	//if(SmileyReplication == none)
	//{
		//SetupSmileyReplication();
	//}
	C.StrLen("T", XL, YL);
	SScale = YL;
	PX = C.CurX;
	PY = C.CurY;
	CurX = PX;
	CurY = PY;
	OrgC = C.DrawColor;
	i = FindNextSmile(S, N);
	J0x9d:

	// End:0x367 Loop:True
	if(i != -1) // && (SmileyReplication != none))
	{
		D = Left(S, i);
		S = Mid(S, i + Len(SmileyReplication.mySmileys[N].smileysText));
		C.SetPos(CurX, CurY);
		C.DrawText(D);
		C.StrLen(StripColorForTTS(D), XL, YL);
		CurX += XL;
		J0x151:

		// End:0x1b2 Loop:True
		if(CurX > C.ClipX)
		{
			CurY += YL + AdditionalY;
			XYL += YL + AdditionalY;
			AdditionalY = 0.00;
			CurX -= C.ClipX;
			// This is an implied JumpToken; Continue!
			goto J0x151;
		}
		C.DrawColor = default.WhiteColor;
		C.SetPos(CurX, CurY);
		EIcon = SmileyReplication.mySmileys[N].smileysTexture;
		// End:0x221 Loop:False
		if(EIcon.SizeX == 16)
		{
			Sca = SScale;
		}
		// End:0x242
		else
		{
			Sca = float(EIcon.SizeX / 32) * SScale;
		}
		C.DrawTile(EIcon, Sca, Sca, 0.00, 0.00, float(EIcon.SizeX), float(EIcon.SizeY));
		// End:0x2cd Loop:False
		if(Sca > SScale)
		{
			NewAY = Sca - SScale;
			// End:0x2c2 Loop:False
			if(NewAY > AdditionalY)
			{
				AdditionalY = NewAY;
			}
			NewAY = 0.00;
		}
		CurX += Sca;
		J0x2d9:

		// End:0x33a Loop:True
		if(CurX > C.ClipX)
		{
			CurY += YL + AdditionalY;
			XYL += YL + AdditionalY;
			AdditionalY = 0.00;
			CurX -= C.ClipX;
			// This is an implied JumpToken; Continue!
			goto J0x2d9;
		}
		C.DrawColor = OrgC;
		i = FindNextSmile(S, N);
		// This is an implied JumpToken; Continue!
		goto J0x9d;
	}
	C.SetPos(CurX, CurY);
	C.StrLen(StripColorForTTS(S), XL, YL);
	C.DrawText(S);
	CurX += XL;
	J0x3be:

	// End:0x41f Loop:True
	if(CurX > C.ClipX)
	{
		CurY += YL + AdditionalY;
		XYL += YL + AdditionalY;
		AdditionalY = 0.00;
		CurX -= C.ClipX;
		// This is an implied JumpToken; Continue!
		goto J0x3be;
	}
	XYL += AdditionalY;
	AdditionalY = 0.00;
	XXL = CurX;
	C.SetPos(PX, PY);
	*/
}

function int FindNextSmile(string S, out int SmileNr)
{
	local int bp;

	bp = -1;
	/*
	// End:0x1c Loop:False
	
	//if(SmileyReplication == none)
	//{
		//return bp;
	//}
	j = SmileyReplication.mySmileys.Length;
	i = 0;
	J0x38:

	
	// End:0xbe Loop:True
	if(i < j)
	{
		P = InStr(S, SmileyReplication.mySmileys[i].smileysText);
		// End:0xb4 Loop:False
		if(P != -1 && (P < bp || (bp == -1)))
		{
			bp = P;
			SmileNr = i;
		}
		++ i;
		// This is an implied JumpToken; Continue!
		goto J0x38;
	}
	*/
	return bp;
}

// @override
// @TESTING (DISABLED)
function DisplayConsoleMessages()
{
	local Texture2D smileysTexture;
    local int Idx, XPos, YPos;
    local float XL, YL;
	local float textSizeX, textSizeY;
	local String tmp;
	local TextureFlipBook animatedTexture;

	if ( ConsoleMessages.Length == 0 )
		return;

    for (Idx = 0; Idx < ConsoleMessages.Length; Idx++)
    {
		if ( ConsoleMessages[Idx].Text == "" || ConsoleMessages[Idx].MessageLife < WorldInfo.TimeSeconds )
		{
			ConsoleMessages.Remove(Idx--,1);
		}
    }

    XPos = (ConsoleMessagePosX * HudCanvasScale * Canvas.SizeX) + (((1.0 - HudCanvasScale) / 2.0) * Canvas.SizeX);
    YPos = (ConsoleMessagePosY * HudCanvasScale * Canvas.SizeY) + (((1.0 - HudCanvasScale) / 2.0) * Canvas.SizeY);

    Canvas.Font = GetFontSizeIndex(0); //class'Engine'.Static.GetSmallFont();
	//Canvas.Font = class'Engine'.Static.GetTinyFont();
    Canvas.DrawColor = ConsoleColor;

    Canvas.TextSize ("A", XL, YL);


	//if(SmileyReplication == none || SmileyReplication.Owner == None)
	//{
		//SetupSmileyReplication();
	//}

    YPos -= YL * ConsoleMessages.Length; // DP_LowerLeft
    YPos -= YL; // Room for typing prompt

    for (Idx = 0; Idx < ConsoleMessages.Length; Idx++)
    {
		if (ConsoleMessages[Idx].Text == "")
		{
			continue;
		}
		
		Canvas.StrLen( ConsoleMessages[Idx].Text, XL, YL );
		Canvas.SetPos( XPos, YPos );
		Canvas.DrawColor = ConsoleMessages[Idx].TextColor;
		
		smileysTexture = None;
		smileysTexture = getsmileysTexture(ConsoleMessages[Idx].Text, tmp);
		
		
		if(smileysTexture != None){
			Canvas.DrawText(tmp, false ); // UT3X RESTORE
			Canvas.SetDrawColor(255, 255, 255, 255);
			Canvas.TextSize(tmp, textSizeX, textSizeY); // UT3X
			Canvas.SetPos( XPos+ textSizeX, YPos );
			if(TextureFlipBook(smileysTexture) == None){
				Canvas.DrawTile(smileysTexture, 
				Min(smileysTexture.SizeX, 128), Min(smileysTexture.SizeY, 128), // DIMENSION (maybe still 128x128 max is too big ...)
				smileysTexture.SizeX, smileysTexture.SizeY, //U,V (TEXTURE CENTERING)
				smileysTexture.SizeX, smileysTexture.SizeY); //UL, VL (TEXTURE ROTATION)
			} else {
				animatedTexture = TextureFlipBook(smileysTexture);
				Canvas.DrawTile(animatedTexture, 
				Min(animatedTexture.SizeX/animatedTexture.HorizontalImages, 64), Min(animatedTexture.SizeY/animatedTexture.VerticalImages, 128), // DIMENSION (maybe still 32x64 max is too big ...)
				animatedTexture.SizeX/animatedTexture.HorizontalImages, animatedTexture.SizeY/animatedTexture.VerticalImages, //U,V (TEXTURE CENTERING)
				animatedTexture.SizeX/animatedTexture.HorizontalImages, animatedTexture.SizeY/animatedTexture.VerticalImages); //UL, VL (TEXTURE ROTATION)
			}
			
			YPos += Max(YL, Min(smileysTexture.SizeY, 64)); // UT3X RESTORE
		} else {
			Canvas.DrawText( ConsoleMessages[Idx].Text, false );
			YPos += YL; // UT3X RESTORE
		}
		
		
    }
}



function DisplayClock()
{
	local string Time;
	local vector2D POS;

	if (UTGRI != None)
	{
		POS = ResolveHudPosition(ClockPosition,183,44);
		Time = FormatTime(UTGRI.TimeLimit != 0 ? (UTGRI.RemainingTime>0?UTGRI.RemainingTime:(UTGRI.ElapsedTime-(UTGRI.TimeLimit*60))) : UTGRI.ElapsedTime);

		Canvas.SetPos(POS.X, POS.Y);
		Canvas.DrawColorizedTile(AltHudTexture, 183 * ResolutionScale,44 * ResolutionScale,490,395,181,44,TeamHudColor);

		
		if(UTGRI.TimeLimit != 0 && UTGRI.RemainingTime > 0){
			if(UTGRI.RemainingTime < 60){ // 1 minute remaining
				Canvas.DrawColor = RedColor;
			} else if(UTGRI.RemainingTime < 180){ // < 3 minutes remaining
				Canvas.setDrawColor(255,165,0,255); // Orange
			} else if(UTGRI.RemainingTime < 300){ // < 5 minutes remaining
				Canvas.DrawColor = class'UTCTFHUDMessage'.default.YellowColor;
			} else {
				Canvas.DrawColor = WhiteColor;
			}
		} else {
			Canvas.DrawColor = WhiteColor;
		}
		DrawGlowText(Time, POS.X + (28 * ResolutionScale), POS.Y, 39 * ResolutionScale);
	}
}

function Texture2D getsmileysTexture(String S, out String tmp){

	local array<string> split;
	local String a;
	local int i;
	
	if(PlayerOwner != None && UT3XPC(PlayerOwner) != None){
		class'UT3X.UT3XLib'.static.Split2(S, ": ", split);
		
		if(split.length == 2){
			a = split[1];
			tmp = split[0]$":";
			
			a = CAPS(a);
			
			for(i=0; i< UT3XPC(PlayerOwner).smileysList.length; i++){
				if(UT3XPC(PlayerOwner).smileysList[i].smileysText.find(a) != -1){
					return UT3XPC(PlayerOwner).smileysList[i].smileysTexture;
				}
			}
		}
	
	}
	return None;
}

defaultproperties
{
	ScoreboardSceneTemplate=Scoreboard_CTF'UT3XContentV3.Scenes.sbCTF';
	//Name= "Default__UT3XUTCTFHUD"
	bNeedLoading = true;
	bFirstRun = true;
	Attempts = 10;
	
	
	//MaxHUDAreaMessageCount=20;
	//ConsoleMessageCount=20;
}
