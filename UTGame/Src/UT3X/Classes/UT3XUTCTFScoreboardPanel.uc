// How to make custom scoreboard
// http://forums.epicgames.com/threads/588948-TUTORIAL-How-to-change-the-scoreboard
/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XUTCTFScoreboardPanel extends UTCTFScoreboardPanel;

struct countryFlag
{
	var string country;
	var Texture2D texture;
};

var color purpleColor;
var const String countryTextureBasePath;
var string defaultCountryFlagPath;
var Texture2D defaultCountryFlagTexture;
var string ut3xContentPackage;


var array<String> countriesWithNoFlags;
var array<countryFlag> cachedCountryFlags;

/**
 * @Overrided / Added PacketLoss in clan tag
 * Get the Right Misc string
 */
function string GetRightMisc(UTPlayerReplicationInfo PRI)
{
	local int TotalSeconds, Hours, Minutes, Seconds;
	local string TimeString;
	local bool bHasHours;

	if ( (PRI.WorldInfo.NetMode != NM_Standalone) && !PRI.bBot )
	{
		TotalSeconds = PRI.WorldInfo.GRI.ElapsedTime - PRI.StartTime;
		hours = TotalSeconds/3600;
		if ( hours > 0 )
		{
			TimeString = Hours$":";
			TotalSeconds -= 3600*Hours;
			bHasHours = true;
		}
		minutes = TotalSeconds/60;
		if ( bHasHours && (minutes < 10) )
		{
			TimeString = TimeString$"0";
		}
		TimeString = TimeString$minutes$":";

		seconds = TotalSeconds - 60*minutes;
		if ( seconds < 10 )
		{
			TimeString = TimeString$"0";
		}
		TimeString = TimeString$seconds;
		return TimeString$" PL"@PRI.PacketLoss$"  "$PingString@(4*PRI.Ping);
	}
	return "";
}

/**
 * @Overrided / Added Country (full name) in clan tag
 * Draw the player's clan tag.
 */
function DrawClanTag(UTPlayerReplicationInfo PRI, float X, out float YPos, int FontIndex, float FontScale)
{
	local UT3XPlayerReplicationInfo ut3xPri;
	local String str;
	
	if ( FontIndex < 0 )
	{
		return;
	}
	
	str = GetClanTagStr(PRI);
	
	if(UT3XPlayerReplicationInfo(PRI) != None){
		ut3xPri = UT3XPlayerReplicationInfo(PRI);

		// only display country name if not anonymous country mode or current player logged as admin
		if(!ut3xPri.bAnonymousCountry || (PlayerOwner != None && PlayerOwner.PlayerReplicationInfo.bAdmin)){
			if(Len(str) > 0){
				str $= "-"$ut3xPRI.countryInfo.CN;
			} else {
				str = ut3xPRI.countryInfo.CN;
			}
		}
	}
	
	
	
	// Draw the clan tag
	DrawString(str, X, YPos, FontIndex, FontScale);
	YPos += Fonts[FontIndex].CharHeight * FontScale + (PlayerNamePad*ResolutionScale) - ClanPosAdjust;
}

/**
 * Draw the Player's Name
 */
function DrawPlayerName(UTPlayerReplicationInfo PRI, float NameOfst, float NameClipX, out float YPos, int FontIndex, float FontScale, bool bIncludeClan)
{
	local UT3XPlayerReplicationInfo ut3xPri;
	local float XL, YL, TMP;
	local float tmpX;
	local string Spot, ut3x, country;
	local float textSizeX, textSizeY;
	local Color c ; 
	local countryFlag cf;
	local Texture2D countryTexture;
	local int idxCountry;
	c = Canvas.DrawColor;
	
	if(defaultCountryFlagTexture == None){
		defaultCountryFlagTexture = Texture2D(DynamicLoadObject(ut3xContentPackage$defaultCountryFlagPath, class'Texture2D')); // TODO USE WORLDWIDE TEXTURE ??
	}
	
	Canvas.Font =  Font'UI_Fonts_Final.HUD.F_GlowSecondary' ;// GlowFonts[0];
	if(UT3XPlayerReplicationInfo(PRI) != None){
		
		ut3xPri = UT3XPlayerReplicationInfo(PRI);
		country = Locs(ut3xPri.countryInfo.CC2);
		
		// TRY TO GET THE FLAG TEXTURE
		// AND CACHE THE TEXTURE
		if(country != "" && countriesWithNoFlags.find(country) == -1){
			// bAnonymousCountry
			idxCountry = cachedCountryFlags.find('country', country);
		
			if(idxCountry != -1){
				countryTexture = cachedCountryFlags[idxCountry].texture;
			} else {
				countryTexture = Texture2D(DynamicLoadObject(ut3xContentPackage$countryTextureBasePath$country, class'Texture2D'));
			}
			
			if(countryTexture == None){
				countriesWithNoFlags.addItem(country);
			} else {
				if(idxCountry == -1){
					cf.country = country;
					cf.texture = countryTexture;
					cachedCountryFlags.addItem(cf);
				}
			}
		} else {
			countryTexture = defaultCountryFlagTexture;
		}
		
		// DOES NOT DISPLAY FLAG for people that want to anonymize
		// unless logged admin
		if(!ut3xPri.bAnonymousCountry || (PlayerOwner != None && PlayerOwner.PlayerReplicationInfo.bAdmin)){
			
		} else {
			countryTexture = defaultCountryFlagTexture;
		}
	}
	
	if(PRI.bAdmin){
		// disabling red color
		//Canvas.DrawColor = class'UTHUD'.default.RedColor;
	}
	
	
		
	Spot = bIncludeClan ? GetPlayerNameStr(PRI) : GetClanTagStr(PRI)$GetPlayerNameStr(PRI);
	
	StrLen(Spot, XL, YL, FontIndex, FontScale * MainPerc);
	YL = Fonts[FontIndex].CharHeight * FontScale * MainPerc;

	if ( XL > (NameClipX - NameOfst) && !bIncludeClan )
	{
		Spot = GetPlayerNameStr(PRI);
	}

	
	if(!PRI.bBot){
		ut3x = "(ID:"$PRI.PlayerId;
		
		if(!ut3xPri.isAfk && !PRI.bBot){
			ut3x $= ")";
		} else {
			ut3x $= ", AFK)";
		}
	}
	
	// DRAWS THE FLAG IF PLAYER HAS NOT FLAG
	if(countryTexture != None && !PRI.bHasFlag){
		Canvas.SetDrawColor(255, 255, 255, 255); // WHITE
		Canvas.TextSize(" ", textSizeX, textSizeY); // UT3X
		Canvas.setPos(NameOfst-countryTexture.SizeX - textSizeX, Canvas.CurY);
		Canvas.DrawTile(countryTexture, 
				Min(countryTexture.SizeX, 32), Min(countryTexture.SizeY, 32), // DIMENSION
				countryTexture.SizeX, countryTexture.SizeY, //U,V (TEXTURE CENTERING)
				countryTexture.SizeX, countryTexture.SizeY); //UL, VL (TEXTURE ROTATION)
		Canvas.DrawColor = c;
	}
	
	if(ut3xPri != None && ut3xPri.isAfk){
		Canvas.DrawColor = purpleColor;
	}
	DrawString( Spot, NameOfst, YPos, FontIndex, FontScale * MainPerc); // DRAW PlayerName
	//FontScale = 0.5f;
	TMP = Fonts[FontIndex].CharHeight * FontScale * MainPerc;
	
	Canvas.TextSize(" "$Spot, textSizeX, textSizeY); // UT3X
	// function float DrawString(String Text, float XPos, float YPos, int FontIdx, float FontScale)
	DrawString( ut3x, (NameOfst + textSizeX) * MainPerc * FontScale, YPos, FontIndex, 0.5f * MainPerc);
	
	YPos += YL;
	Canvas.DrawColor = c;
	Canvas.SetDrawColor(255, 255, 255, 255); // WHITE
	
}

defaultproperties
{
	defaultCountryFlagPath=".SmileysV3.Linux";
	ut3xContentPackage="UT3XContentV3";
	countryTextureBasePath=".Flags.flag-";
	purpleColor=(B=238,G=104,R=123,A=255); // AFK Playername color
}
