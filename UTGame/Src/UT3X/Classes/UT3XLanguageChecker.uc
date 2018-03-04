/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XLanguageChecker extends Info config(UT3XConfig);





struct BadWord
{
	var String word; // e.g : dick, asshole, ...
	var String LG; // Language - ISO 639-1 Code - NOT USED YET
	var int Weight; // how bad the word is (e.g.: motherfucker, dick, ...)
	
	structdefaultproperties
	{
		LG = "en";
		Weight = 1;
	}
};

struct PlayerSwearing
{
	var String playerName;
	var bool bWarned;
	var int currentWeight; // When starting, equals 0
};

struct SpamInfo
{
	var String id; // playername+message
	var int count;
	var int weight; // number of letters
	var float firstTime;
	var float lastTime;
};

var config bool isActive;

var config int minWeightToWarn; // If player reach this weight then he will have a warning
var config int minWeightToKick; // If player reach this weight then he will be kicked
var config String badWordReplacement;

var array<SpamInfo> spams;
var array<PlayerSwearing> PlayersSwearing;
var config array<BadWord> badWords;


// Check if player is spamming, if true then player should be kicked
function bool CheckSpamming(PlayerController PC, String message){

	local SpamInfo si;
	local String id;
	local int idx;
	
	id = PC.playerReplicationInfo.PlayerName$"-"$message;
	idx = spams.find('id', id);
	
	// first time message
	if(idx != -1){
		si.id = id;
		si.count = 1;
		si.firsttime = WorldInfo.GRI.ElapsedTime;
		si.lasttime = WorldInfo.GRI.ElapsedTime;
		return false;
	} else {
		si = spams[idx];
		si.count ++;
		// TODO
	}
	return false;
}

// If False then player will be kicked
function bool CheckMessage(PlayerController PC, String message, out String MessageFiltered, optional bool isNameOrClanTagCheck){
	
	local Array<String> SplitedMsg;
	local int i;
	local PlayerSwearing ps;
	local BadWord bw;
	local UT3XPC PCC;
	local String msg;
	local bool dontKickPlayer;
	local UT3XMessage msgg;
	
	// TODO REPLACE BAD WORDS
	MessageFiltered = message;
	
	message = repl(message, ".", " ");
	message = repl(message, "?", " ");
	message = repl(message, ",", " ");
	message = repl(message, "!", " ");
	message = repl(message, ":", " ");
	message = repl(message, ")", " ");
	message = repl(message, "(", " ");
	message = repl(message, ";", " ");
	
	class'UT3XLib'.static.Split2(message, " ", SplitedMsg);
	
	
	for(i=0; i<SplitedMsg.length; i++){
		if(isBadWord(SplitedMsg[i], bw)){
			ps = getPlayerSwearing(PC.PlayerReplicationInfo.PlayerName, bw.weight);
			//MessageFiltered $= badWordReplacement$" ";
		} else {
			//MessageFiltered $= SplitedMsg[i]$" ";
		}
	}
	
	if(ps.currentWeight >= minWeightToKick){
		return false; // WILL DIRECTLY KICK PLAYER WITHOUT WARNING
	} 
	else if(ps.currentWeight >= minWeightToWarn && !ps.bWarned){
	
		if(!isNameOrClanTagCheck){
			msg = "[WARNED]"$PC.PlayerReplicationInfo.PlayerName$" by UT3X-BOT Reason: SWEARING";
			ps.bWarned = true;
			
			if(UT3XPC(PC) == None || UT3XPC(PC).isAnonymous){
				UT3XAC(WorldInfo.Game.AccessControl).log.AddLog(LT_WARN, "UT3X-BOT", PC.PlayerReplicationInfo.PlayerName, "swearing");
			}
			
			class'UT3XUtils'.static.WebAdminMessage(WorldInfo, msg);

			msgg.msg = msg;
			msgg.Position = 0.85;
			msgg.LifeTime = 8;
			msgg.FontSize = 2;
			msgg.DrawColor = class'UT3XMsgOrange'.default.DrawColor;
			
			foreach WorldInfo.AllControllers(class'UT3XPC', PCC){
				PCC.ClientDisplayMessage(msgg);
				//PCC.UT3XMessage(msg, class'UT3XMsgOrange');
			}
			PC.ClientPlaySound(SoundCue'A_Gameplay.CTF.Cue.A_Gameplay_CTF_FlagAlarm_Cue', true);
			
			dontKickPlayer = true;
		} else {
			dontKickPlayer = false;
		}
	} else {
		dontKickPlayer = true;
	}
	
	return dontKickPlayer;
}

function PlayerSwearing getPlayerSwearing(String playerName, int extraWeight){

	local int i;
	local PlayerSwearing ps;
	
	for(i=0; i<PlayersSwearing.length; i++){
		if(CAPS(playerName) == CAPS(PlayersSwearing[i].PlayerName)){
			PlayersSwearing[i].currentWeight += extraWeight;
			return PlayersSwearing[i];
		}
	}
	
	ps.PlayerName = PlayerName;
	ps.currentWeight = extraWeight;
	
	PlayersSwearing.addItem(ps);
	return ps;
}

function bool isBadWord(String word, out BadWord bw){

	local int i;
	local String tmp;
	local bool bStartsWithAst;
	local bool bEndsWithAst;
	
	word = CAPS(word);
	
	for(i=0; i<badWords.length; i++){
		bEndsWithAst = false;
		bStartsWithAst = false;
		
		if(CAPS(badWords[i].word) == word){
			bw = badWords[i];
			return true;
		} else {
			// badWord = "*fuck*": motherfucker, fucking, fuckers ...
			// badWord = "ass*": ass, asshole, ...
			
			// Ends with *
			if(InStr(badWords[i].word, "*") != -1){
				// STARTS with *
				if(Left(badWords[i].word, 1) == "*"){
					bStartsWithAst = true;
				}
				// ENDS WITH *
				if(Right(badWords[i].word, 1) == "*"){
					bEndsWithAst = true;
				}
				
				tmp = CAPS(badWords[i].word);
				
				// *fuck* (fuckers, motherfucker, ...)
				if(bStartsWithAst && bEndsWithAst){
					// *fuck* -> fuck ...
					tmp = Mid(tmp, 1);
					tmp = Left(tmp, Len(tmp) -1);
					if (InStr(word, tmp) != -1){
						bw = badWords[i];
						return true;
					}
				} 
				// dick* (dickhead, ...)
				else if(bEndsWithAst){
					// dick* -> dick
					tmp = Left(tmp, Len(tmp) -1);
					
					if(InStr(word, tmp) == 0){
						bw = badWords[i];
						return true;
					}
				} 
				// *hole (asshole)
				else if(bStartsWithAst){
					tmp = Mid(tmp, 1);
					
					// InStr(asshole, hole)=  3
					if(InStr(word, tmp) > 0){
						bw = badWords[i];
						return true;
					}
				}
			
			}
			
			
		}
	}
	
	return false;
}

function String AddBadWord(String word, int weight, optional String language){
	
	local BadWord bw;
	
	if(Len(word) < 2){
		return "Word too short (need at least 2 chars)";
	}
	
	if( (InStr(word, "*") != -1) && Len(word) < 4){
		return "Word too short (need at least 4 chars)";
	}
	
	// WORD EVER STORED
	if(isBadWord(word, bw)){
		return "The bad word "$word$" ever exists! ("$bw.word$")";
	}
	if(weight <= 0){
		weight = 1;
	}
	
	bw.word = word;
	bw.weight = weight;
	if(language == ""){
		bw.LG = "en";
	}
	BadWords.addItem(bw);
	SaveConfig();
	return "";
}

defaultproperties
{
	isActive = true;
	minWeightToWarn = 50;
	minWeightToKick = 100;
	badWordReplacement = "***";
}
