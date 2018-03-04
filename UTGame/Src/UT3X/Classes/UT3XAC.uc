/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XAC extends AccessControl Config(UT3X);


var UT3X mut; // link to mut ..
var string GamePassword2;
var config string kickTitle;
var config string banTitle;
var config string kickbanextramsg;

// maximum time a fake player can play before being kicked
var config bool kickFakePlayers;
var config int minSecondsFakePlayerBeforeKick;
var int maxDaysBanDuration; // todo del no longer used
var config bool bHashedCompName;

// If true then don't tell to player who banned him.
var config bool bAnonymousAdmin;
var config string anonymousAdminName;

var bool configSaved;
var UT3XLog log;
var UT3XLanguageChecker lc;
var UT3XPlayersDB pdb; // Global Players Database
var UT3XPlayerSettings ps; // player settings

var config bool sqlLink_enabled;
var config String sqlLink_host;
var config int sqlLink_port;
var config String sqlLink_phpfilepath;
var config String sqlLink_password;

var config bool sqlLink_ip2c_enabled;
var config bool sqlLink_exportPlayerData;
var config bool sqlLink_exportLogs;

// TCP Link
struct IPTOCITY
{
	var String ip;
	var String countrycode;
	var String region;
	var String city;
};

// IP + Country Info
struct IPC
{
	var String IP; // iP (e.g: 10.5.4.2)
	var String FTS; // first time the ip was used (TimeStamp)
	var String LTS; // last time this ip was used
	// IP Ranges are calculated from UTUT3XCountries.ini file
	// Byte type goes from 0 to 255 which is perfect for ipv4 ip!
	var byte A, B, C, D; // Start of IP Range. e.g: 128.64.0.0 A=128, B=64, ...
	var byte E, F, G, H; // End of ip range
	var String CC3; // Code Country 3 (Ex: FRA (France))
};



var enum BanType
{
	BT_UT3XBAN, // PlayerName (ut3x ban/multi ban ip,hash, ...)
	BT_UT3XBANMUTE, // UT3X MUTE BAN
	BT_UID, // UT3 CORE BAN BY UNIQUE ID
	BT_HASH, // UT3 CORE BAN BY CD KEY HASH
	BT_IP // UT3 CORE BAN BY IP
} BT;

var enum KickAction
{
	KA_NONE, // DISABLED
	KA_WARNING, // WARNS PLAYER
	KA_KICK, // KICK
	KA_KICKBAN, // BAN
	KA_KICKPERMBAN, // PERM BAN
	KA_MUTE, // MUTE
	KA_BANMUTE, // BAN MUTE
	KA_PERMBANMUTE // PERMANENT BAN MUTE
} KA;

// UNDER CONSTRUCTION
struct KickRule
{
	var String label; // SPAWNKILLING (example)
	var KickAction KA;
	var String banDuration; // Only apply if kick action is a ban (always in days)
	var bool bNoLog; // action will not be logged (in ut3x -> Logs menu)
	
	var KickAction KARepeat; // Action to do if players still spawnkilling 
	var String banDurationRepeat; // 
	var bool bNoLogRepeat;
	
	var String maxTimeForRepeat; // KARepeat will be called if [todayTime]-[lastKickTimeForSameReason or endBanTimeForSameReason] < maxTimeForRepeat
	
};

// BAN ACTIVE IF END TIME NOT REACHED YED
// AND IF SOME ADMIN DID NOT MANUALLY DESACTIVATE IT
struct UT3XBan
{
	var BanType BT;
	var string playerBanned; // Player Banned -TODO DON'T USE THIS
	var string uniqueIdBanned; // Unique ID - USE THIS Now
	var String compNameBanned; // DEPRECATED will use compsNameBanned
	var array<String> compsNameBanned; // Multiple
	var String hashBanned; // Banned Hash
	var array<String> IPSBanned; // IPS banned (coming from IP database)
	var string bannedBy; // who banned the player
	var int startSec; // Start time in seconds (since 2011-01-01)
	var string startTS; // TimeStamp
	var int endSec; // When it ends - if 0 then permanent ban
	var string endTS; // TimeStamp
	
	var string hashWhenBanned;
	var string ipWhenBanned;
	var string compNameWhenBanned;
	
	var string reason; // reason why the player was banned
	
	var bool isManuallyDesactivated;
	var string desactivatedBy; // who desactivated this ban / if not null, desactivate the ban regardless of ban duration if still active
	var string desactivatedTS; // When it was desactivated
	var bool bPermanent; // Permanent or not (overrides endSec)
	
	structdefaultproperties
	{
		bPermanent = false;
		BT = BT_UT3XBAN;
	}
};


// BIG LOG INFO
struct UT3XPlayerInfo
{
	//var int ID;
	
	var string	PName; //Player Name
	
	var array<IPC>	IPCS; //(IP used + country)

	// Unique Net ID
	var string  UNID;

	var array<string> HASHES; // MULTIPLE CD-KEY SUPPORTED
	
	var array<string> CTS; // Clan Tags
	
	var array<string> FDS; // Friends(array of UniqueIDs)
	
	var array<string> CNS; // CNS
	
	// First Time Player connect to server (doesn't mean has suceeded to login ...)
	var string  FPL;
	
	// Last Time player join the game
	var string LPL;
	
	// First Time Player Login to Player
	var string FL; //First Login
	
	// Last Time player Login to Player
	var string LL; //Last Login
	
	var string LLO; //Last Logout
	
	var int DT;
	
	var array<String> ALS;
	
};

var array<IPTOCITY> iptocitycache;
var array<UT3XPlayerInfo> TempPlayersLogs;
var config array<UT3XBan> PlayersBan;
var config array<KickRule> KickRules;
var array<String> anonymouses;

event PostBeginPlay(){
	super.PostBeginPlay();
	configSaved = false;
}

function String UT3XBanToString(UT3XBan ub){
	return "[Banned]"$ub.playerBanned$" on "$ub.startTS$" until "$ub.endTS$" .Reason:"$ub.reason;
}

function String UT3XMuteBanToString(UT3XBan ubm){
	return "[MUTED]"$ubm.playerBanned$" from "$ubm.startTS$" until "$ubm.endTS$". Reason:"$ubm.reason;
}

function getKickAction(String kickActionString){
	
}

function addKickRule(String label, String kickActionN, String banDuration, bool bNoLog, String kickActionRepeat, String banDurationRepeat, bool bNoLogRepeat, String maxTimeForRepeat){

	local KickRule KR;
	
	if(label != ""){
		KR.label = CAPS(label);
		if(kickActionN == "KA_KICK"){
			KR.KA = KA_KICK;
		} else if(kickActionN == "KA_KICKBAN"){
			KR.KA = KA_KICKBAN;
		} else if(kickActionN == "KA_KICKPERMBAN"){
			KR.KA = KA_KICKPERMBAN;
		} else if(kickActionN == "KA_MUTE"){
			KR.KA = KA_MUTE;
		} else if(kickActionN == "KA_BANMUTE"){
			KR.KA = KA_BANMUTE;
		} else if(kickActionN == "KA_WARNING"){
			KR.KA = KA_WARNING;
		}
		
		if(kickActionRepeat == "KA_KICK"){
			KR.KARepeat = KA_KICK;
		} else if(kickActionRepeat == "KA_KICKBAN"){
			KR.KARepeat = KA_KICKBAN;
		} else if(kickActionRepeat == "KA_KICKPERMBAN"){
			KR.KARepeat = KA_KICKPERMBAN;
		} else if(kickActionRepeat == "KA_MUTE"){
			KR.KARepeat = KA_MUTE;
		} else if(kickActionRepeat == "KA_BANMUTE"){
			KR.KARepeat = KA_BANMUTE;
		} else if(kickActionRepeat == "KA_WARNING"){
			KR.KA = KA_WARNING;
		}
		
		KR.banDuration = banDuration;
		KR.banDurationRepeat = banDurationRepeat;
		KR.maxTimeForRepeat = maxTimeForRepeat;
		KR.bNoLog = bNoLog;
		KR.bNoLogRepeat = bNoLogRepeat;
		
		KickRules.addItem(KR);
		SaveConfig();
	}
	
}



// USE IN ORDER NOT TO STORE THOUSANDS OF IPS IN LOG FOR SAME PLAYER
// TODO WE SHOULD KEEP ONLY IP WITH DIFFERENT RANGE
function array<IPC> limitNumIpsStored(array<IPC> ips, int maxIps){
	local int Idx;
	
	if(maxIps<=0){
		maxIps = 7;
	}
	
	if(ips.length >0 ){
		if(ips.length > maxIps){
			for(Idx = 0; Idx < (ips.length-maxIps); Idx ++){
				ips.removeItem(ips[Idx]);
			}
		}
	}
	
	return ips;
}
// WRITES TO LOG WHEN PLAYER EXITS
reliable server function NotifyLogoutToLog(Controller C){

	local int Idx;
	local PlayerController P;
	local String tmp;
	
	if(C == None){
		return;
	}
	
	P = PlayerController(C);
	if(P == None){
		return;
	}
	
	if(UT3XPC(P) != None && UT3XPC(P).computerNamee != ""){
		tmp $= "CN:"$UT3XPC(P).computerNamee$" CTRY:"$UT3XPlayerReplicationInfo(UT3XPC(C).PlayerReplicationInfo).countryInfo.CC3;
	}
	
	if(isAWebAdmin(P.PlayerReplicationInfo.PlayerName)){
		//class'UT3XLib'.static.modifyServerSlots(WorldInfo, -1, P.PlayerReplicationInfo.bIsSpectator);
	}
	
	if(DemoRecSpectator(C) == None){
		log.addLog(LT_ACCESS, P.PlayerReplicationInfo.PlayerName, , "LOGOUT"@tmp);
	}
	
	for(Idx=0; Idx<TempPlayersLogs.Length; Idx++){
		if(TempPlayersLogs[Idx].PName == class'UT3XLib'.static.FilterChars(P.PlayerReplicationInfo.PlayerName)){
			TempPlayersLogs[Idx].LLO = TimeStamp();
			TempPlayersLogs[Idx] = updateUT3XPlayerInfo(TempPlayersLogs[Idx], P);
			break;
		}
	}
}

reliable server function NotifyLogin(Controller C){

	local int i;
	local UT3XBan ubm;
	local UTPlayerController PCC;
	local UT3XPC PC;
	local int idx;
	local string loginMessage, ip;
	local IPTOCITY ip2city;
	
	NotifyLoginToLog(C);
	
	PCC = UTPlayerController(C);
	
	if(DemoRecSpectator(C) == None){
		log.addLog(LT_ACCESS, PCC.PlayerReplicationInfo.PlayerName, , "LOGIN");
	}

	// CHECKS IF PLAYER EVER BAN-MUTED
	for(i=0;i<PlayersBan.length;i++){
		if( (PlayersBan[i].BT == BT_UT3XBANMUTE) && CAPS(PlayersBan[i].playerBanned) == CAPS(class'UT3XLib'.static.FilterChars(PCC.PlayerReplicationInfo.PlayerName))){
			ubm = PlayersBan[i];
			
			// PLAYER MUST BE MUTED
			if( (!ubm.isManuallyDesactivated) && (ubm.endSec > class'HttpUtil'.static.utimestamp3())){ //class'UT3XLib'.static.getGlobalSecondsFromTimeStamp(TimeStamp())) ){
				PCC.ClientMessage("Mute Ban Detected - You have been automatically muted. Ends on:"$ubm.endTS);
				foreach WorldInfo.AllControllers(class'UT3XPC', PC){
					PC.UT3XMessage("[BAN MUTE ACTIVE]-"$PCC.PlayerReplicationInfo.PlayerName$" Ends on:"$ubm.endTS, class'UT3XMsgOrange');
					PC.ServerMutePlayer(PCC.PlayerReplicationInfo.UniqueId);
					PCC.bServerMutedText = true;
				}
				//log.addLog(LT_MUTEBAN, ubm.bannedBy, PCC.PlayerReplicationInfo.PlayerName , "ACTIVE MUTE BAN");
				return;
			} else { // Remove inactive bans
				//PlayersBanMute.RemoveItem(ubm);
			}
		}
	}
	
	// Disabled for "privacy", other players do no need to know the city 
	// even if it's not "accurate"
	/*
	ip = Left(PCC.GetPlayerNetworkAddress(), InStr(PCC.GetPlayerNetworkAddress(), ":"));
	idx = iptocitycache.find('ip', 	ip);
	

	if(idx != -1){
		loginMessage = PCC.PlayerReplicationInfo.PlayerName;
		ip2city = iptocitycache[idx];
		loginMessage $= " near "$ip2city.city$" ("$ip2city.region$","$ip2city.countrycode$")";
		loginMessage $= " entered the server.";
		WorldInfo.Game.Broadcast(self, loginMessage);
	}
	*/
}

// ADDS GUID TODO
reliable server function bool NotifyLoginToLog(Controller C){

	local int Idx;
	local PlayerController P;
	
	if(C == None){
		return false;
	}
	
	P = PlayerController(C);
	if(P == None){
		return false;
	}
	
	
	for(Idx=0; Idx<TempPlayersLogs.Length; Idx++){
	
		if(TempPlayersLogs[Idx].PName == class'UT3XLib'.static.FilterChars(P.PlayerReplicationInfo.PlayerName)){
			
			if(TempPlayersLogs[Idx].FL == ""){
				TempPlayersLogs[Idx].FL = TimeStamp();
			}
			TempPlayersLogs[Idx].LL = TimeStamp();
			
			TempPlayersLogs[Idx] = updateUT3XPlayerInfo(TempPlayersLogs[Idx], P);
			//SaveConfig();
			return true;
		}
	}
	
	return false;
}

// UPDATE PLAYER LOG INFO (IP, ...)
// USED WHEN CONNECTING TO SERVER
function UT3XPlayerInfo updateUT3XPlayerInfo(UT3XPlayerInfo pinfo, PlayerController PC){
	
	local string hash;
	local int Idx;
	local PlayerReplicationInfo pri;
	local bool hashinlist;
	local string uniqueid;
	
	// *** LOGS HASHKEYS (CD KEYS ENCRYPTED) ***
	hash = PC.HashResponseCache;
	pri = PC.PlayerReplicationInfo;
	hashinlist = false;

	
	if(hash != ""){
		for(Idx=0; Idx<pinfo.HASHES.Length;Idx++){
			if(pinfo.HASHES[Idx] == hash){
				hashinlist = true;
				break;
			}
		}
		
		if(!hashinlist){
			pinfo.HASHES.addItem(hash);
		}
	}
	
	uniqueid = class'OnlineSubsystem'.static.UniqueNetIdToString(pri.UniqueId);
	
	if((pinfo.UNID == "" || pinfo.UNID == "0") && uniqueid != "0" && uniqueid != ""){
		pinfo.UNID = class'OnlineSubsystem'.static.UniqueNetIdToString(pri.UniqueId);
	}
	
	return pinfo;
}

// REMOVES BAN FROM PLAYER
function String RemoveBan(String playername, String desactivatedBy, optional String desactivatedReason, optional int startSec, optional bool isDelete){
	
	local int i;
	local string error;
	
	
	error = "No ban found for player"@playername;
	
	for(i=0;i<PlayersBan.length;i++){
		if( ((CAPS(PlayersBan[i].playerBanned) == CAPS(class'UT3XLib'.static.FilterChars(playername))) && playername != "") || PlayersBan[i].startSec == startSec){
			if(isDelete){
				PlayersBan.removeItem(PlayersBan[i]);
				SaveConfig();
				UT3XAC(WorldInfo.Game.AccessControl).log.addLog(LT_OTHER, desactivatedBy, playername, "Ban Removal");
				return "";
			}
			if(!PlayersBan[i].isManuallyDesactivated && class'UT3XLib'.static.isDateAfterNow(PlayersBan[i].endSec) )
			{
				PlayersBan[i].desactivatedBy = desactivatedBy;
				PlayersBan[i].desactivatedTS = TimeStamp();
				PlayersBan[i].isManuallyDesactivated = true;
				SaveConfig();
				return "";
			} else { // Old Ban Inactive (EndDateBan<Today) - nothing to do ...
				error = "Ban is ever inactive. End date passed. ("$PlayersBan[i].endTS$")";
			}
			
		}
	}
	
	return error;
}



reliable server function DisplayPlayerInfo(string playername, PlayerController admin){
	
	local UT3XPlayerInfo upi;
	
	getPlayerInfoFromLog(playername, upi);
	if(Len(upi.PName) == 0){
		admin.ClientMessage("Not data found for this player");
	} else {
		admin.ClientMessage("Country;"$upi.IPCS[0].CC3); //TODO $ "IPs:"$class'UT3XUtils'.static.arrayToString(upi.IPCS));
	}

}

function bool getPlayerInfoFromLog(string playername, out UT3XPlayerInfo upi, optional bool tempPlayersLogsOnly){

	local int i;
	
	if(!tempPlayersLogsOnly){
		i = pdb.PlayersLogs.Find('PName', playername);
		
		if(i != -1){
			upi = pdb.PlayersLogs[i];
			return true;
		}
	}
	i = TempPlayersLogs.Find('PName', playername);
	
	if(i != -1){
		upi = TempPlayersLogs[i];
		return true;
	}
	
	return false;
}


function bool isActiveBan(UT3XBan ub){
	
	local float currentSeconds;

	currentSeconds = class'HttpUtil'.static.utimestamp3(); //class'UT3XLib'.static.getGlobalSecondsFromTimeStamp(TimeStamp());
	
	if((currentSeconds > ub.endSec) && !ub.isManuallyDesactivated){
		return true;
	} else {
		return false;
	}
}

function UT3XBan initBanInfo(
	bool isMuteBan,
	bool bPermanent,
	String adminName, 
	String bannedPlayerName,
	optional string banDuration, 
	optional string reason,
	optional string bannedUniqueId,
	optional string bannedHash,
	optional array<string> bannedCNS){

	local UTPlayerController PCBanned;
	local String IP;
	local UT3XBan ub;
	local int banDurationSec;
	local int maxBanDurationSec;
	
	

	
	ub.playerBanned = class'UT3XLib'.static.FilterChars(bannedPlayerName);
	ub.bannedBy = class'UT3XLib'.static.FilterChars(adminName);
	ub.reason = class'UT3XLib'.static.FilterChars(reason);
	ub.startSec = class'HttpUtil'.static.utimestamp3();
	ub.startTS = class'HttpUtil'.static.timestampToString(ub.startSec, mut.timeZone);
	ub.bPermanent = bPermanent;
	
	if(banDuration == "" || int(banDuration) <=0){
		banDuration = "20m"; // 20 minutes
	}
	
	maxBanDurationSec = maxDaysBanDuration*3600*24;
	
	banDurationSec = class'UT3XLib'.static.parseTimeLenghtToSeconds(banDuration);
	
	if(banDurationSec > maxBanDurationSec){
		banDurationSec = maxBanDurationSec;
	}

	ub.endSec = banDurationSec+ub.startSec;

	ub.endTS = class'HttpUtil'.static.timestampToString(ub.endSec, mut.timeZone);
	
	ub.BT = isMuteBan?BT_UT3XBANMUTE:BT_UT3XBAN;
	
	//class'UT3XLib'.static.getPCFromPlayerName(WorldInfo, bannedPlayerName, PCBanned, adminName);
	
	class'UT3XLib'.static.getPlayerController(WorldInfo, PCBanned, bannedPlayerName, bannedUniqueId, "", bannedHash, bannedCNS[0]);
	

	if(PCBanned != None){
	
		IP = PCBanned.GetPlayerNetworkAddress();
		IP = Left(IP, InStr(IP, ":"));
		ub.IPSBanned.addItem(IP);// = listIps;
		ub.ipWhenBanned = IP;
		ub.uniqueIdBanned = class'OnlineSubsystem'.static.UniqueNetIdToString(PCBanned.PlayerReplicationInfo.UniqueId);
		ub.compNameWhenBanned = UT3XPC(PCBanned).computerNamee;
		ub.hashWhenBanned = PCBanned.HashResponseCache;
		
		if(!isMuteBan){
			UTPKick((bAnonymousAdmin?anonymousAdminName:ub.bannedBy), PCBanned, , "BAN:"$reason$" ENDS:"$ub.endTS, false);
		}
	} 
	
	ub.uniqueIdBanned = bannedUniqueId;
	ub.compsNameBanned = bannedCNS;
	//ub.compNameBanned = bannedCompName;
	ub.hashBanned = bannedHash;
	
	
	return ub;
}


// PlayerName
// isBan: is permanent ban (not mute match) or not
// isMute: if false then unmute
// advertiseAll: if true the broadcast message
// adminName: name of player (generally admin) muting the other player
// return empty string if sucessfull else errormsg
unreliable server function String UTPMutePlayer(string bannedPlayerName, bool mutePlayer, bool isBan, bool isPermanent, optional string adminName, optional string banDuration, optional string reason){

	local int i, durationSec;
	local UT3XBan ubm;
	local bool everBannedMutedPlayer;
	local UTPlayerController PCMuted;
	local String msg, prefixMsg;
	local UT3XPC PC;

	class'UT3XLib'.static.getPCFromPlayerName(WorldInfo, bannedPlayerName, PCMuted, adminName);
	
	bannedPlayerName = class'UT3XLib'.static.FilterChars(bannedPlayerName); // removed bad chars for ini save good encoding
	
	if(PCMuted == None){ // Player Not In Server
		// WE try to find him from global player database
		/*
		if(!getPlayerInfoFromLog(bannedPlayerName, pinfo)){
			return "Player "$bannedPlayerName$" not found!";
		}*/
	}
	
	bannedPlayerName = PCMuted != None?PCMuted.PlayerReplicationInfo.PlayerName:bannedPlayerName;
	
	if(true){
		
		if(isBan){
			if(!isPermanent){
				prefixMsg = "[BAN MUTED]";
			} else {
				prefixMsg = "[PERMANENTLY BAN MUTED]";
			}
		} else {
			prefixMsg = "[MUTED]";
		}
		if(!mutePlayer){
			prefixMsg = "[UNMUTED]";
		}
		
		if(banDuration != ""){
			durationSec = class'UT3XLib'.static.parseTimeLenghtToSeconds(banDuration);
			if(!isValidBanDuration(durationSec)){
				return "Duration of mute ban must be lower than "$maxDaysBanDuration$" days";
			}
			if(durationSec < 60 && mutePlayer){
					return "Duration of mute ban must be greater then 60s";
			}
		}
		
		// CHECKS IF PLAYER EVER BAN-MUTED
		for(i=0;i<PlayersBan.length;i++){
			if(!isBan && PlayersBan[i].BT != BT_UT3XBANMUTE){
				continue;
			}
			if(CAPS(PlayersBan[i].playerBanned) == CAPS(bannedPlayerName)){
				ubm = PlayersBan[i];
				
				if(!mutePlayer){
					PlayersBan.removeItem(PlayersBan[i]);
					/*
					PlayersBan[i].desactivatedBy = adminName;
					PlayersBan[i].isManuallyDesactivated = true;
					PlayersBan[i].desactivatedTS = TimeStamp();
					*/
					everBannedMutedPlayer = true;
				} else {
					if(!PlayersBan[i].isManuallyDesactivated && class'UT3XLib'.static.isDateAfterNow(PlayersBan[i].endSec) ){
						everBannedMutedPlayer = true;
					}
				}
			}
		}
		
		if(mutePlayer){ // MUTE PLAYER
			if(isBan){ // BAN MUTE
				if(everBannedMutedPlayer){
					return bannedPlayerName$" has ever an active mute ban (ends:"$ubm.endTS$")";
				} else {
					log.addLog(LT_MUTEBAN, ubm.bannedBy, ubm.playerBanned , reason);
					PlayersBan.addItem(initBanInfo(true, isPermanent, adminName, bannedPlayerName, banDuration, reason));
				}
			} else {
				if(PCMuted.bServerMutedText){
					return "Player is ever muted!";
				} else {
					log.addLog(LT_MUTE, adminName, bannedPlayerName , reason);
				}
			}
		} else { // UN-MUTE
			if(isBan){
				if(!everBannedMutedPlayer){
					return "Player is ever not muted!";
				}
			} else {
				if(!PCMuted.bServerMutedText){
					return "Player is ever not muted!";
				}
			}
		}
		
		if(PCMuted != None){
			PCMuted.bServerMutedText = mutePlayer;
		}
		
		if(!mutePlayer) {
			msg = prefixMsg$"-"$bannedPlayerName$" by "$adminName$".";
			msg $= " Reason:"$reason;
		} else {
			msg = prefixMsg$"-"$bannedPlayerName$"  by "$adminName$".";
			if(isBan){
				msg $= " Ends: "$ubm.endTS;
			} else {
			
			}
			msg $= " Reason:"$reason;
		}
		
		if(PCMuted != None){
			foreach WorldInfo.AllControllers(class'UT3XPC', PC){
				PC.UT3XMessage(msg, class'UT3XMsgRed');
				if(mutePlayer){
					PC.ServerMutePlayer(PCMuted.PlayerReplicationInfo.UniqueId);
				} else {
					PC.ServerUnMutePlayer(PCMuted.PlayerReplicationInfo.UniqueId);
				}
			}
		}
		
		SaveConfig();
		return "";
	}
	return "PlayerName"@bannedPlayerName@"not found";
}


reliable server function bool modifyPlayerEntryLog(
	string playername,
	optional string LastPreLogin,
	optional string LastLogin,
	optional string IP,
	optional string country,
	optional string clanTag,
	optional string uniqueId,
	optional string hash,
	optional string cn,
	optional string friendUniqueId,
	optional int dt,
	optional string ip_start,
	optional string ip_end	){
	
	local int Idx;
	local int ipnum, ctnum;
	local bool ipinlist, clanTagInList;
	local bool playerfound;
	local int records;
	local IPC ipcc;
	local array<byte> ip_start_b, ip_end_b;
	
	playerfound = false;
	
	if(playername ==""){
		return false;
	}

	playername = class'UT3XLib'.static.FilterChars(playername);
	
	records = TempPlayersLogs.Length;
	
	for(Idx=0; Idx<records; Idx++){
	
		if(TempPlayersLogs[Idx].PName == playername){
			playerfound = true;
			
			if(friendUniqueId != "" && TempPlayersLogs[Idx].FDS.Find(friendUniqueId) == -1){
				TempPlayersLogs[Idx].FDS.addItem(friendUniqueId);
			}
			
			if(uniqueId != "" && uniqueId != "0"){
				TempPlayersLogs[Idx].UNID = uniqueId;
			}
			
			if(LastPreLogin != ""){
				TempPlayersLogs[Idx].LPL = LastPreLogin;
			}
			
			if(LastLogin != ""){
				TempPlayersLogs[Idx].LL = LastLogin;
				
				if(TempPlayersLogs[Idx].FL ==""){
					TempPlayersLogs[Idx].FL = LastLogin;
				}
			}
			
			if(cn != "" && TempPlayersLogs[Idx].hashes.find(cn) == -1){
				TempPlayersLogs[Idx].cns.addItem(cn);
			}
			
			if(hash != "" && TempPlayersLogs[Idx].hashes.find(hash) == -1){
				TempPlayersLogs[Idx].hashes.addItem(hash);
			}
			
			if(dt > 0){
				TempPlayersLogs[Idx].dt = dt;
			}
			
			if(clanTag != ""){
				for(ctnum=0;ctnum<TempPlayersLogs[Idx].CTS.length;ctnum++){
					if(CAPS(TempPlayersLogs[Idx].CTS[ctnum]) == CAPS(clanTag)){
						clanTagInList = true;
						break;
					}					
				}
				
				if(!clanTagInList && TempPlayersLogs[Idx].CTS.length <= 3){
					TempPlayersLogs[Idx].CTS.addItem(clanTag);
				}
				
			}
			
			if(IP != ""){
				for(ipnum=0;ipnum<TempPlayersLogs[Idx].IPCS.length;ipnum++){
					if(TempPlayersLogs[Idx].IPCS[ipnum].IP == IP){
						TempPlayersLogs[Idx].IPCS[ipnum].LTS = TimeStamp();
						ipinlist = true;
						break;
					}					
				}
				
				if(!ipinlist){
					ipcc.IP = IP;
					ipcc.FTS = TimeStamp();
					ipcc.LTS = TimeStamp();
					
					if(ip_start != ""){
						ip_start_b = class'UT3XCountries'.static.ipToBytes(ip_start);
						
						ipcc.A = ip_start_b[0];
						ipcc.B = ip_start_b[1];
						ipcc.C = ip_start_b[2];
						ipcc.D = ip_start_b[3];
					}
					
					if(ip_end != ""){
						ip_end_b = class'UT3XCountries'.static.ipToBytes(ip_end);
						
						ipcc.E = ip_end_b[0];
						ipcc.F = ip_end_b[1];
						ipcc.G = ip_end_b[2];
						ipcc.H = ip_end_b[3];
					}
					
					ipcc.CC3 = country;
					TempPlayersLogs[Idx].IPCS.addItem(ipcc);
				}
				
				// Limit num of IPs stored to 7
				//@TODO FIX
				TempPlayersLogs[Idx].IPCS = limitNumIpsStored(TempPlayersLogs[Idx].IPCS, 7);
			}
			Idx = records;
			return true;
		}
	}
	
	if(playerfound){
		//SaveConfig();
	}
	
	return playerfound;
}


// WHEN NEW PLAYER CONNECT TO SERVER ADD ITS INFO TO LOG
reliable server function int addPlayerEntryLog(string playername, optional string IP, optional string countryCode3, optional string friendUniqueId, optional string ip_start, optional string ip_end){
	local UT3XPlayerInfo upi;
	local IPC ipcc;
	local array<string> friendsUID;
	local array<byte> ip_start_b, ip_end_b;
	
	LogInternal(getFuncName()$"-"$playername);
	
	if(playername != ""){
		upi.PName = class'UT3XLib'.static.FilterChars(playername); //playername;
		//upi.ID = TempPlayersLogs.length;
		upi.FPL = TimeStamp();
		upi.LPL = TimeStamp();
		
		if(friendUniqueId != ""){
			friendsUID.addItem(friendUniqueId);
			upi.FDS = friendsUID;
		}
		
		if(IP != ""){
			if(ip_start != ""){
				ip_start_b= class'UT3XCountries'.static.ipToBytes(ip_start);
				ipcc.A = ip_start_b[0];
				ipcc.B = ip_start_b[1];
				ipcc.C = ip_start_b[2];
				ipcc.D = ip_start_b[3];
			}
			
			if(ip_end != ""){
				ip_end_b= class'UT3XCountries'.static.ipToBytes(ip_end);
				ipcc.E = ip_end_b[0];
				ipcc.F = ip_end_b[1];
				ipcc.G = ip_end_b[2];
				ipcc.H = ip_end_b[3];
			}
			ipcc.CC3 = countryCode3;
			
			
			
			
			
			ipcc.IP = IP;
			ipcc.FTS = TimeStamp();
			ipcc.LTS = TimeStamp();
			upi.IPCS.addItem(ipcc);
		}
		//LogInternal(TimeStamp()$": "$"PlayersDB - NEW Player -("$playername$","$IP$","$countryCode3$")");
		TempPlayersLogs.addItem(upi);
		//SaveConfig();
		return TempPlayersLogs.length;
	} else {
		return -1;
	}
}

// CHECK IF PLAYER BANNED IF SO THEN KICK THE PLAYER
function checkIsBannedPlayer(PlayerController PC, optional String IP, optional String uniqueId, optional String computerName){

	local UT3XBan ub;
	local bool isBanned;
	local String reason;
	local int secondsRemaining;
	local int secondsNow;
	local String remainingTime;
	
	isBanned = isUT3XBanned(PC.PlayerReplicationInfo.PlayerName, IP, uniqueid, computerName, ub);

	if(isBanned){
		if(ub.endSec == 0 || ub.bPermanent){
			reason = "Permanent ban";
		} else {
			reason = "Temporary ban";
		}
		reason = "Active ban by "$(bAnonymousAdmin?anonymousAdminName:ub.bannedBy)$".";
		if(ub.reason != ""){
			reason @= "(Reason:"$ub.reason$").";
		}
		
		if(ub.endSec != 0){
			secondsNow = class'HttpUtil'.static.utimestamp3(); //class'UT3XLib'.static.getGlobalSecondsFromTimeStamp(TimeStamp());
			secondsRemaining = ub.endSec - secondsNow;
			remainingTime = class'UT3XLib'.static.secondsToDateLength(secondsRemaining);
			if(!ub.bPermanent){
				reason @= "Remaining time:"$remainingTime;
			} else {
				reason @= "PERMANENT BAN";
			}
		}
		
		log.addLog(LT_KICK, "UT3X-BOT", PC.PlayerReplicationInfo.PlayerName, BanToString(ub));
		UTPKick("UT3X-BOT", PC, , reason, true);
	}
}

	
function String BanToString(UT3XBan ub){
	local String t;
	local String remainingTime;
	
	remainingTime = class'UT3XLib'.static.secondsToDateLength(ub.endSec - class'HttpUtil'.static.utimestamp3());
			
	t $= "Active Ban:";
	t @= ub.compNameBanned!=""?"CompNameBan:"$ub.compNameBanned:"";
	t @= ub.hashBanned!=""?"HashBan:"$ub.hashBanned:"";
	t @= ub.uniqueIdBanned!=""?"UIDBan:"$ub.uniqueIdBanned:"";
	
	if(ub.endSec > 0 && !ub.bPermanent){
		t @= "Remaining Time:"$remainingTime;
	} else if (ub.bPermanent){
		t @= "Permanent Ban.";
	}
	
	return t;
}

function bool isComputerBanned(array<String> computersNameBanned, String computerName){

	local int i;
	local String tmp;
	local bool bStartsWithAst;
	local bool bEndsWithAst;
	
	computerName = CAPS(computerName);
	
	for(i=0; i<computersNameBanned.length; i++){
		bEndsWithAst = false;
		bStartsWithAst = false;
		
		if(CAPS(computersNameBanned[i]) == computerName){
			return true;
		} else {
			// badWord = "*fuck*": motherfucker, fucking, fuckers ...
			// badWord = "ass*": ass, asshole, ...
			
			// Ends with *
			if(InStr(computersNameBanned[i], "*") != -1){
				// STARTS with *
				if(Left(computersNameBanned[i], 1) == "*"){
					bStartsWithAst = true;
				}
				// ENDS WITH *
				if(Right(computersNameBanned[i], 1) == "*"){
					bEndsWithAst = true;
				}
				
				tmp = CAPS(computersNameBanned[i]);
				
				// *fuck* (fuckers, motherfucker, ...)
				if(bStartsWithAst && bEndsWithAst){
					// *fuck* -> fuck ...
					tmp = Mid(tmp, 1);
					tmp = Left(tmp, Len(tmp) -1);
					if (InStr(computerName, tmp) != -1){
						return true;
					}
				} 
				// dick* (dickhead, ...)
				else if(bEndsWithAst){
					// dick* -> dick
					tmp = Left(tmp, Len(tmp) -1);
					
					if(InStr(computerName, tmp) == 0){
						return true;
					}
				} 
				// *hole (asshole)
				else if(bStartsWithAst){
					tmp = Mid(tmp, 1);
					
					// InStr(asshole, hole)=  3
					if(InStr(computerName, tmp) > 0){
						return true;
					}
				}
			
			}
			
			
		}
	}
	
	return false;
}

// TODO ADD SUPPORT FOR IP RANGE (E.G: 10.2.X.X)
function bool isUT3XBanned(string playername, string IP, string uniqueId, string CN, out UT3XBan ub){
	
	local bool isBanned;
	local bool save;
	local int i, j;
	local Array<String> IPS;
	
	playername = class'UT3XLib'.static.FilterChars(playername);
	
	//LogInternal("PlayerName:"$playername$" IP:"$IP$" UID:"$uniqueId$" CompName:"$CN);
	
	for(i=0;i<PlayersBan.length;i++){
		//LogInternal("***** BAN "$i$" CompName:"$CN);
		isBanned = false;
		
		if(PlayersBan[i].BT == BT_UT3XBAN){

			// UniqueID ban
			if(uniqueId != "" && uniqueId != "0" && PlayersBan[i].uniqueIdBanned == uniqueId){
				isBanned = true;
			} 
			
			// PlayerName Ban
			if( (CAPS(PlayersBan[i].playerBanned) == CAPS(playername)) || (IP != "" && (PlayersBan[i].IPSBanned.Find(IP) != -1) ) ) {
				isBanned = true;
			} 
			
			// CN Multiple Ban
			if( CN != ""){
				if(CAPS(PlayersBan[i].compNameBanned) == CAPS(CN) || isComputerBanned(PlayersBan[i].compsNameBanned, CN)){
					isBanned = true;
				}
			}
			
			// IP BAN
			if(IP != ""){ // Player banned may have changed his name but still his ip is banned ...
				IPS = PlayersBan[i].IPSBanned;
				for(j =0; j < IPS.length; j ++){
					if(IPS[j] == IP){
						isBanned = true;
					}				
				}
			}
			
			// PERMANENT BAN OR END BAN DATE AFTER TODAY (not finished) AND BAN NOT MANUALLY DESACTIVATED
			//LogInternal(isBanned$" UBEndSec:"$ub.endSec$" UBPerm:"$ub.bPermanent$" DateAfter:"$class'UT3XLib'.static.isDateAfterNow(ub.endSec)$" UBDesac!"$!ub.isManuallyDesactivated);
			//LogInternal("isBanned:"$isBanned$" ub.endSec:"$ub.endSec$" ub.bPermanent:"$ub.bPermanent$"  class'UT3XLib'.static.isDateAfterNow(ub.endSec):"$class'UT3XLib'.static.isDateAfterNow(ub.endSec));
			//LogInternal("!ub.isManuallyDesactivated:"$!ub.isManuallyDesactivated);
			

			if((PlayersBan[i].endSec == 0 || PlayersBan[i].bPermanent || class'UT3XLib'.static.isDateAfterNow(PlayersBan[i].endSec)) && (!PlayersBan[i].isManuallyDesactivated)){
				if(save){
					SaveConfig();
				}
				if(isBanned){
					ub = PlayersBan[i];
					return true;
				}
			} else { // Automatically remove obsolete ut3x bans
				PlayersBan.removeItem(PlayersBan[i]);
				save = true;
				isBanned = false;
			}
			
		}
	}
	
	if(save){
		SaveConfig();
	}
	return isBanned;
}


function SetGamePassword2(string P, optional PlayerController C)
{
	GamePassword2 = P;
	WorldInfo.Game.UpdateGameSettings();
	SaveConfig();
	
	if(C != None){
		if(P != ""){
			C.ClientMessage("Password has been changed.");
		} else {
			C.ClientMessage("No password set.");
		}
	}
}

// TODO - DOESN'T WORK YET
// UT3XLink class TEST (do not work properly on linux server)
function string getCountryFromIPOLD(string IP){
	//local UT3XLink Link;
	//local string IPData;
	
	//Link = Spawn(class'UT3XLink');
	//Link.ObjectOwner = self;
	//Link.ChangePropertyName = 'IPData';
	//Link.TargetFile = "http://www.ut3x.com/ip2c/iptocountry16.php?ip=90.27.127.230";
	//http://iptocountry.ut-files.com/iptocountry16.php
	//"http://88.191.94.197/ip2c/iptocountry16.php?
	//Link.Resolve("88.191.94.197");
	return "";
}

function bool isAnonymouss(String anonymousPassword){

	if(anonymousPassword == ""){
		return false;
	}

	if(InStr(anonymousPassword, "*") == -1 || InStr(anonymousPassword, "$") == -1){
		return false;
	}

	return class'HttpUtil'.static.MD5String("anonymous"$anonymousPassword) == "21976b7b8315e6aa6be72f32e8948381"; // salted hash
}


//
// Accept or reject a player on the server.
// Fails login if you set the OutError to a non-empty string.
//
// AFTER PRELOGIN, SEE
// event PlayerController Login IN GameInfo
// SEE: UTPlayerController event NotifyLoadedWorld, GetSeamlessTravelActorList
event PreLogin(string Options, string Address, out string OutError, bool bSpectator){

	local UT3XPC PC;
	local String playername, countryName, CC3, IP, info, OutErrorHR, InPassword, playerInfo, friend;
	//local String p;
	local string ip_start, ip_end; // IP range of player ip (numeric)
	// Don't show all IP for non-admin
	local Array<String> IPInfo;
	local UT3XPlayerInfo pinfo;
	local bool isNewPlayer, isAdmin, isAnonymous;
	local UT3XCountries ipcc;
	local UT3XTcpLink tl;
	
	playername = WorldInfo.Game.ParseOption( Options, "name" );
	InPassword = WorldInfo.Game.ParseOption( Options, "Password" );
	friend = WorldInfo.Game.ParseOption( Options, "Friend" );
	
	isAnonymous = false; //disabled for perf issues isAnonymouss(WorldInfo.Game.ParseOption( Options, "Hash" ));
	if(isAnonymous){
		anonymouses.addItem(CAPS(playername));
	}
	
	isAdmin = isAWebAdmin(playername);
	
	isNewPlayer = !getPlayerInfoFromLog(playername, pinfo, true);

	IP = Left(Address, InStr(Address, ":")); //80.80.80.80
	
	
	if(bSpectator){
		info = "Spectator ";
	} else {
		info = "Player ";
	}
	info $= playername;

	ipcc = mut.uc;
	if(ipcc != None){
		// return getIpStartString(ipcc)$"."$getIpEndString(ipcc)$"."$ipcc.cc2$"."$ipcc.cc3;
		class'UT3XLib'.static.Split2(ipcc.getCountryDataSplitFromIP(IP), ".", IPInfo);
		CC3 = IPInfo[9]; //ipcc.getCC3FromIP(IP); // Country Code 3 (e.g: "FRA")
		ip_start = IPInfo[0]$"."$IPInfo[1]$"."$IPInfo[2]$"."$IPInfo[3];
		ip_end = IPInfo[4]$"."$IPInfo[5]$"."$IPInfo[6]$"."$IPInfo[7];

		countryName = ipcc.getCountryNameFromIP(IP); // Country Name
		//countryInfo = ipcc.getCountryInfosFromIP(IP); // Country Info extra data (capital, population, ...)
	}
	
	// getting city info (will be displayed when player LOGIN)
	if(sqlLink_ip2c_enabled){
		if(iptocitycache.find('ip', IP) == -1){ 
			tl = Spawn(class'UT3XTcpLink'); //spawn the class
			tl.getCityFromIp(playername, IP);
		}
	}
	
	
	playerInfo = info;
	
	if(!isAnonymous){
		LogInternal(TimeStamp()@"-[PRELOGIN]-"$playername@"("@Address@") - Options:"@Options$" ADMIN:"$isAdmin);
	}
	
	if(OutError != ""){
	
	} else {
		if(!isAnonymous){
			if(isNewPlayer){
				addPlayerEntryLog(playername, IP, CC3, friend, ip_start, ip_end); // CC3 = Country Code 3
			} else {
				modifyPlayerEntryLog(playername, TimeStamp(),,IP, CC3, , , , , friend, , ip_start, ip_end); // Update 
			}
		}
		info $= " is connecting to the server ... ";
	}

	
	//class'UT3XLib'.static.Split2(IP, ".", IPDetail);
	OutError="";
	InPassword = WorldInfo.Game.ParseOption( Options, "Password" );
	
	// can't access GamePassword in superclass AccessControl since it's private
	// so needs to be tricky to get it
	GamePassword2 = WorldInfo.Game.ConsoleCommand("get engine.accesscontrol GamePassword", false);
	LogInternal("GamePassword2:"@GamePassword2);
	
	if( WorldInfo.Game.AtCapacity(bSpectator) )
	//if( WorldInfo.Game.AtCapacity(bSpectator) )
	{
		// OPENS SLOT FOR ADMIN IF SERVER FULL
		if(!isAdmin){
			OutError = "Engine.GameMessage.MaxedOutMessage";
			OutErrorHR = "Server Full";
			if(bSpectator){
				OutErrorHR $= "("$WorldInfo.Game.MaxSpectators$" spec slots)";
			} else {
				OutErrorHR $= "("$WorldInfo.Game.MaxPlayers$")";
			}
		}
	} else if ( GamePassword2 != "" && (InPassword != GamePassword2) ){
		OutError = (InPassword == "") ? "Engine.AccessControl.NeedPassword" : "Engine.AccessControl.WrongPassword";
		if(InPassword == ""){
			OutErrorHR = "No password specified.";
		} else {
			OutErrorHR = "Wrong password.";
		}
	}
	
	if (!CheckIPPolicy(Address))
	{
		OutError = "Engine.AccessControl.IPBanned";
		OutErrorHR = "IP Banned";
	}
	
	// CHECK DONE WHEN UNIQUEID GET
	/*
	if(isUT3XBanned(playername, IP, ub)){
		OutError = "Engine.AccessControl.IPBanned";
		OutErrorHR = "BANNED by "$(bAnonymousAdmin?anonymousAdminName:ub.bannedBy)$"/"$ub.reason;
		if(ub.endTS == ""){
			OutErrorHR $= "/ PERMANENT BAN";
		} else {
			OutErrorHR $= "/ ENDS:"$ub.endTS;
		}
	}*/
	

	if(!isAnonymous){
	log.addLog(LT_ACCESS, playername, , "PRELOGIN "$Address$Options$(OutError != ""?(" DENIED "$OutErrorHR):""));
	//LogInternal(info);
	//ServerASay
	foreach WorldInfo.AllControllers(class'UT3XPC', PC){
	
		if(OutError != ""){	
			if(OutError == "Engine.GameMessage.MaxedOutMessage" || OutError == "Engine.AccessControl.NeedPassword" || OutError == "Engine.AccessControl.WrongPassword"){
				PC.UT3XMessage(playerInfo$"  couldn't connect. ("$OutErrorHR$")", class'UT3XMsgOrange');
			} else {
				PC.UT3XMessage(info$"  couldn't connect. ("$OutErrorHR$")", class'UT3XMsgRed');
			}
		} else {
			if(!isAdmin){ // don't tell normal players admins are connecting to server ...
				
				PC.UT3XMessage(info, class'UT3XAdminMsg');
			}
		}
	}
	}
}

reliable server function CloseServer(string serverPassword, optional string reason){
	//Set GamePassword
	WorldInfo.Game.ConsoleCommand("set engine.accesscontrol "$serverPassword, false);
	
	// Kicks everybody but admins
	WorldInfo.Game.KillBots();
	
	if(reason ==""){
		reason = "Server Maintenance.";
	}
	
	UTPKickAll(None, reason);
}

// KICKS EVERYBODY BUT ADMINS
reliable server function bool UTPKickAll(PlayerController CAdmin, optional string reason){

	local PlayerController PC;
	
	foreach WorldInfo.AllControllers(class'PlayerController', PC){
		if(DemoRecSpectator(PC) == None && !PC.PlayerReplicationInfo.bAdmin){
			UTPKick("", PC, CAdmin, reason);
		}
	}
	return true;
}

// USED FOR ANY KICK THAT COMES FROM ADMIN
reliable server function bool UTPKick2(PlayerController CAdmin, PlayerController kickedPlayer, string reason){

	
	return UTPKick("", kickedPlayer, CAdmin, reason);
}


function String getAvailableKickReasons(){
	local String t;
	local int i;
	
	t = "Kick reasons available:";
	
	for(i=0; i<kickrules.length;i++){
		t $= kickrules[i].label$",";
	}
	
	return t;
}
function String KickRuleToString(KickRule kr){
	if(KR.ka == KA_NONE){
		return "No action.";
	} else if(KR.ka == KA_KICK){
		return "Player Kicked";
	} else if(KR.Ka == KA_KICKBAN){
		return "Player Banned";
	} else if(KR.Ka == KA_KICKPERMBAN){
		return "Player Banned Permanently.";
	} else if(KR.ka == KA_MUTE){
		return "Player muted";
	} else if(KR.ka == KA_BANMUTE){
		return "Player ban muted";
	}
	return "No action.";
}

// APPLY ACTION IF PLAYER BREAK SOME SERVER RULE
function bool applyKickAction(String adminName, PlayerController kickedPlayer, String reason){
	
	local KickRule kr;
	local KickAction kaa;
	local int numKickAction, lastTimeKick;
	local UT3XPC CAdmin;
	local bool bNoLog;
	local String banDuration;
	local int todaySec;
	local int maxTimeForRepeatSec;
	
	numKickAction = kickrules.find('label', reason);

	if(numKickAction == -1){
		CAdmin = class'UT3XLib'.static.getUT3XPC(WorldInfo, adminName);
		if(CAdmin != None){
			CAdmin.ClientMessage("Kick Reason '"$reason$"' does not exists ");
			CAdmin.ClientMessage(getAvailableKickReasons());
		}
		return false;
	} else {
		kr = kickrules[numKickAction];
		
		if(kr.ka == KA_NONE){
			if(CAdmin != None){
				CAdmin.ClientMessage("No Kick Action found!");
			}
			return false;
		}
		
		kaa = kr.ka;
		banDuration = kr.banDuration;
		bNoLog = kr.bnolog;	
		
		
		

		if(kr.karepeat != KA_NONE && kr.maxTimeForRepeat != ""){
			lastTimeKick = 0 ; // TODO REMOVE FOR PERF
			
			if(lastTimeKick > 0){
				todaySec = class'HttpUtil'.static.utimestamp3();
				
				maxTimeForRepeatSec = lastTimeKick+class'UT3XLib'.static.parseTimeLenghtToSeconds(kr.maxTimeForRepeat);
				
				if(todaySec < maxTimeForRepeatSec){
					kaa = kr.karepeat;
					banDuration = kr.bandurationrepeat;
					bnolog = kr.bnologrepeat;
				}
			}
		} 

		
		if(kaa == KA_KICK){
			UTPKick(adminName,  kickedPlayer, , reason, bNoLog);
			return true;
		} else if(kaa == KA_KICKBAN){
			UTPKickBan(adminName, kickedPlayer, banDuration, reason, bNoLog);
			return true;
		} else if(kaa == KA_KICKPERMBAN){
			UTPKickBan(adminName, kickedPlayer, banDuration, reason, bNoLog, true);
			return true;
		} else if(kaa == KA_MUTE){
			UTPMutePlayer(kickedPlayer.PlayerReplicationInfo.PlayerName, true, false, false, adminName, , reason);
			return true;
		} else if (kaa == KA_BANMUTE){
			UTPMutePlayer(kickedPlayer.PlayerReplicationInfo.PlayerName, true, true, false, adminName, banDuration, reason);
			return true;
		} else if(kaa == KA_WARNING){
			ServerUTPWarn(adminName, kickedPlayer.PlayerReplicationInfo.PlayerName, reason, bNoLog);
			return true;
		} else if(kaa == KA_PERMBANMUTE){
			UTPMutePlayer(kickedPlayer.PlayerReplicationInfo.PlayerName, true, true, true, adminName, banDuration, reason);
			return true;
		}		
		
	}
	
	return false;
}

reliable server function bool UTPKick(String KickerName, PlayerController CPlayer, optional PlayerController CAdmin, optional string reason, optional bool bNoLog){
	
	local string kickreason;
	local string msg;
	local UT3XPC C;
	local string messagetokicked;
	
	if(reason != ""){
		kickreason = reason;
	} else {
		kickreason = DefaultKickReason;
	}

	if(CAdmin != None){
		KickerName = CAdmin.PlayerReplicationInfo.PlayerName;
	}
	
	messagetokicked = "You have been kicked by"@(bAnonymousAdmin?anonymousAdminName:KickerName)$".";
	messagetokicked @= "Reason:"@reason$".";
	messagetokicked @= kickbanextramsg;
	
	if(CPlayer != None && DemoRecSpectator(CPlayer) == None){
		if(KickPlayer2(CPlayer, messagetokicked, class'HttpUtil'.static.timestampNow(WorldInfo)$"-"$WorldInfo.GRI.ServerName@"-"@kickTitle)){
			msg = "[KICKED]-"$CPlayer.PlayerReplicationInfo.playername$" by "$(bAnonymousAdmin?anonymousAdminName:KickerName)$" Reason: "$kickreason;
			
			class'UT3XUtils'.static.WebAdminMessage(WorldInfo, msg);

		
			foreach WorldInfo.AllControllers(class'UT3XPC', C){
				//C.UT3XMessage(msg, class'UT3XMsgRed');
				C.ClientDisplayMessage2(msg, 0.85, 8, 1, class'UT3XMsgRed'.default.DrawColor);
				C.ClientPlaySound(SoundCue'A_Gameplay.ONS.A_Gameplay_ONS_ConduitLockBroken', true);
			}
			
			if(!bNoLog){ // USED FOR AUTO-AFK KICK
				log.addLog(LT_KICK, KickerName, CPlayer.PlayerReplicationInfo.playername, kickreason);
			}
			return true;
		} else {
			if(CAdmin != None){
				CAdmin.ClientMessage("Administrators ("$CPlayer.PlayerReplicationInfo.playername$") can't be kicked",'CriticalEvent');
			}
			return false;
		}
	}
	
	return false;
}


// USED TO BAN PLAYER NOT ON SERVER BUT LISTED IN GLOBAL PLAYERLIST
reliable server function bool UTPKickBanFromPlayerName(PlayerController CAdmin, String playername, optional string seconds, optional string reason, optional bool bBanPermanently){
	
	local int secondsBanned;
	local UT3XPlayerInfo info;
	local UT3XBan ub;
	local string msg;
	local string kickreason;
	local UT3XPC C;
	
	playername = class'UT3XLib'.static.FilterChars(playername);
	
	if(!getPlayerInfoFromLog(playername, info)){
		CAdmin.ClientMessage("Player/ID '"$playername$"' not found from global players list.", 'CriticalEvent' );
		return false;
	}
	
	if(seconds == ""){
		secondsBanned = 1200;
	} else {
		secondsBanned = class'UT3XLib'.static.parseTimeLenghtToSeconds(seconds);
	}
	
	if(secondsBanned == 0){
		secondsBanned = 1200;
	}
	
	if(!isValidBanDuration(secondsBanned, CAdmin)){
		return false;
	}
	ub.playerBanned = class'UT3XLib'.static.FilterChars(playername);//playername;
	
	ub.startSec = class'HttpUtil'.static.utimestamp3(); //class'UT3XLib'.static.getGlobalSecondsFromTimeStamp(TimeStamp());
	ub.startTS = TimeStamp();
	
	if(!bBanPermanently){
		ub.endSec = ub.startSec+secondsBanned;
		ub.endTS = class'HttpUtil'.static.timestampToString(ub.endSec, mut.timeZone); //class'UT3XLib'.static.getTimeStampFromSeconds(ub.endSec);
	}
	ub.bannedBy = CAdmin.PlayerReplicationInfo.PlayerName;
	// can't get IP & COUNTRY (since offline player ban)
	
	if(reason != ""){
		kickreason = reason;
	} else {
		kickreason = DefaultKickReason;
	}
	
	ub.reason = kickreason;
	ub.IPSBanned = getIPsFromPlayerName(ub.playerBanned);
	ub.uniqueIdBanned = info.UNID;
	
	log.addLog(LT_KICKBAN, ub.bannedBy, ub.playerBanned, kickreason);
	PlayersBan.addItem(ub);
	
	msg = playername$" was added to ban list by "$CAdmin.PlayerReplicationInfo.PlayerName;
	if(!bBanPermanently){
		msg $=" until "$ub.endTS;
	} else {
		msg $=" PERMANENTLY"; 
	}
	
	msg @= "Reason: "$kickreason;
	class'UT3XUtils'.static.WebAdminMessage(WorldInfo, msg);
	
	foreach WorldInfo.AllControllers(class'UT3XPC', C){
		C.UT3XMessage(msg, class'UT3XMsgRed');
	}
	SaveConfig();

	return true;
}


// GET ALLS IP SAVED IN DB FOR A PLAYER
reliable server function Array<String> getIPsFromPlayerName(String playername){

	local UT3XPlayerInfo upi;
	local Array<String> IPS;
	local int i;
	
	i = TempPlayersLogs.Find('PName', playername);
	if( i != -1){
		upi = TempPlayersLogs[i];
		for(i=0; i< upi.IPCS.length; i++){
			if(IPS.Find(upi.IPCS[i].IP) != -1){
				IPS.addItem(upi.IPCS[i].IP);
			}
		}
	}

	i = pdb.PlayersLogs.Find('PName', playername);
	if( i != -1){
		upi = pdb.PlayersLogs[i];
		for(i=0; i< upi.IPCS.length; i++){
			if(IPS.Find(upi.IPCS[i].IP) != -1){
				IPS.addItem(upi.IPCS[i].IP);
			}
		}
	}

	return IPS;
}

// BAN Players for some seconds
// seconds: how many seconds the player should be banned (1s,2w,3d)
// E.G.: "utpkick player 3d swearing" (ban player 3 days)
reliable server function bool UTPKickBan(string adminname,
	PlayerController CPlayer,
	optional string seconds,
	optional string reason,
	optional bool bNoLog, 
	optional bool bPermanent){
	
	local string kickreason;
	local string msg;
	local UT3XPC C;
	local UT3XBan ub;
	local string messagetobanned, duration;
	
	
	
	ub = initBanInfo(false, bPermanent, adminname, CPlayer.PlayerReplicationInfo.PlayerName, seconds, reason);
	ub.IPSBanned = getIPsFromPlayerName(ub.playerBanned);

	if(reason != ""){
		kickreason = reason;
	} else {
		kickreason = DefaultKickReason;
	}
	
	ub.reason = kickreason;

	messagetobanned = "You have been banned by"@(bAnonymousAdmin?anonymousAdminName:adminname);
	
	if(bPermanent){
		duration @="PERMANENTLY. ";
	} else {
		duration @= "until "$ub.endTS$".";
	}
	
	duration @= "Reason:"@reason;
	
	messagetobanned @= duration@kickbanextramsg;
	
	if(CPlayer != None){
		if(KickPlayer2(CPlayer, messagetobanned, class'HttpUtil'.static.timestampNow(WorldInfo)$"-"$WorldInfo.GRI.ServerName@"-"@banTitle)){
			LogInternal("[BAN]-"$TimeStamp()$": "$CPlayer.PlayerReplicationInfo.playername$" banned by "$adminname$" "$duration);
			msg = "[BANNED]-"$CPlayer.PlayerReplicationInfo.playername$" by "$(bAnonymousAdmin?anonymousAdminName:adminname)$" "$duration;
			
			class'UT3XUtils'.static.WebAdminMessage(WorldInfo, msg);
			
			foreach WorldInfo.AllControllers(class'UT3XPC', C){
				//C.UT3XMessage(msg, class'UT3XMsgRed');
				C.ClientDisplayMessage2(msg, 0.85, 8, 1, class'UT3XMsgRed'.default.DrawColor);
				C.ClientPlaySound(SoundCue'A_Gameplay.ONS.A_Gameplay_ONS_ConduitLockBroken', true);
			}
			log.addLog(LT_KICKBAN, ub.bannedBy, ub.playerBanned, ub.reason);
			PlayersBan.addItem(ub);
			SaveConfig();
			
			return true;
		} else {
			//CAdmin.ClientMessage("Administrators ("$CPlayer.PlayerReplicationInfo.playername$") can't be banned",'CriticalEvent');
			return false;
		}
	}
	
	return false;
}

// A way to save config file after end of game
// but not clean code/optimal ...
event Tick( float DeltaTime ){
	
	if(WorldInfo.Game.bGameEnded && !configSaved){ 
		setTimer(6, false, 'SaveConfigs'); // TODO MOVE SAVE JUST AFTER MAP VOTE ENDED?
		configSaved = true;
	}
	
	super.Tick(DeltaTime);
}

function SaveConfigs(){
	LogInternal(TimeStamp()$"-Saving Players Database and logs to file ...");
	SaveConfig();
	
	// only integrate db if server empty so lag-free at end of map for players ...
	// Also if there is quite many lines of players logs pending to be merged
	if(WorldInfo.Game.NumPlayers == 0 || pdb.PlayersLogs_Merge.length >= 200){
		LogInternal("Map End - Merging "$TempPlayersLogs.length$" temp player info global player Db ...");
		pdb.merge();
	} 
	// else we need to save current player db ...
	// that will be merged when server empty or after some amount of time
	else {
		LogInternal("Map End - Saving "$TempPlayersLogs.length$" player info temp Db ...");
		pdb.PlayersLogs_Merge = pdb.MergePlayerDb(TempPlayersLogs, pdb.PlayersLogs_Merge);
		pdb.SaveConfig();
	}
	
	// SAVES LOGS
	log.GlobalSave();
}

// Better kick command than the default one by Epic
// Display to kicked player the reason and who kicked him
function bool KickPlayer2(PlayerController C, string KickReason, optional string KickTitleMessage)
{
	//local string KickString;

	if (C != None && true && NetConnection(C.Player)!=None )
	{
		if (C.Pawn != None)
		{
			C.Pawn.Suicide();
		}

		C.ClientSetProgressMessage(PMT_ConnectionFailure, KickReason, KickTitleMessage);

		if (C != None)
		{
			C.Destroy();
		}
		LogInternal(TimeStamp()@"-[KICK]-"@C.PlayerReplicationInfo.PlayerName@"-"@KickReason);
		return true;
	}
	return false;
}


function array<String> getAdminsNameList(){

	local int i, idx;
	local array<string> names;
	local array<string> admins;
	local string adminName;
	GetPerObjectConfigSections(class'MultiAdminData', names); // USING WEBADMIN AUTHENTICATION
	
	for (i = 0; i < names.length; i++)
	{
		idx = InStr(names[i], " ");
		if (idx == INDEX_NONE) continue;
		adminName = Left(names[i], idx);
		admins.addItem(adminName);
	}
	
	return admins;
}

function bool isAWebAdmin(string playername){
	
	local array<string> names;
	local int i;
	local int idx;
	local string adminName;
	
	if(playername ==""){
		return false;
	}
	
	GetPerObjectConfigSections(class'MultiAdminData', names); // USING WEBADMIN AUTHENTICATION
	for (i = 0; i < names.length; i++)
	{
		idx = InStr(names[i], " ");
		if (idx == INDEX_NONE) continue;
		adminName = Left(names[i], idx);
		if( (CAPS(adminName)) == CAPS(playername)){
			return true;
		}
	}
	return false;
}

function bool isLoggedPlayer(PlayerController PC){

	local String uniqueId;
	local bool isLogged;
	
	uniqueId = class'OnlineSubsystem'.static.UniqueNetIdToString(PC.PlayerReplicationInfo.UniqueId);

	isLogged = uniqueId != "" && uniqueId != "0" && PC.HashResponseCache != "" && PC.HashResponseCache != "0";
	
	if(!isLogged){
		PC.ClientMessage("Please retry in a couple of seconds. User info not retrieved yet");
	}
	
	return isLogged;
}

function bool ALogin( PlayerController P, String password)
{
	local bool isAdmin, isWebAdmin;
	
	
	isWebAdmin = isAWebAdmin(P.PlayerReplicationInfo.playername);
	isAdmin = isWebAdmin;
	
	
	if(!isWebAdmin){
		P.ClientMessage("Access unauthorized - Not in admin list");
		return isAdmin;
	}
	
	isAdmin = isAdmin && isLoggedPlayer(P);
	
	isAdmin = isAdmin && isCorrectAdminPassword(P, password);
	
	P.PlayerReplicationInfo.bAdmin = isAdmin;
	return isAdmin;
}

function bool isCorrectAdminPassword(PlayerController P, String password){

	local String CurrentAdminPassword;
	
	// have to do this since AccessControl.AdminPassword is private ...
	CurrentAdminPassword = 	worldinfo.game.consolecommand("get engine.accesscontrol adminpassword", false);

	if(CurrentAdminPassword == ""){
		P.ClientMessage("Admin password must be set in WebAdmin");
		return false;
	}
	

	if(password == CurrentAdminPassword){
		return true;
	} else if(password == ""){
		P.ClientMessage("Access unauthorized - No admin password provided (eg: 'adminlogin thepassword')");
	} else {
		P.ClientMessage("Wrong admin password");
		return false;
	}
}


function bool AdminLogout(PlayerController P)
{
	if (P.PlayerReplicationInfo.bAdmin)
	{
		P.PlayerReplicationInfo.bAdmin = false;
		P.bGodMode = false;
		//P.Suicide(); why suicide?

		return true;
	}

	return false;
}




// CHECK IF BAN DURATION IS LOWER THAN maxDaysBanDuration
function bool isValidBanDuration(int banDurationInSeconds, optional PlayerController PC){
	local bool isValid;
	isValid = (banDurationInSeconds/(3600*24)) <= maxDaysBanDuration;
	
	if(PC != None && !isValid){
		PC.ClientMessage("Ban duration must be lower than "$maxDaysBanDuration$" days.");
	}
	return isValid;
}

// WARNS A PLAYER (DISPLAY ORANGE MESSAGE)
reliable server function ServerUTPWarn(string adminname, string playernamewarned, optional string reason, optional bool bNoLog){

	local PlayerController P, PCAdmin;
	local UT3XPC PC;
	local String msg;

	P = PlayerController(WorldInfo.Game.AccessControl.GetControllerFromString(playernamewarned));
	PCAdmin = PlayerController(WorldInfo.Game.AccessControl.GetControllerFromString(adminname));
	
	if(P != None){
		msg = "[WARNED]-"$P.PlayerReplicationInfo.playername$" by "$PCAdmin==None?adminname:PCAdmin.PlayerReplicationInfo.PlayerName$". Reason: "$reason;
		if(!bNoLog){
			log.AddLog(LT_WARN, PCAdmin==None?adminname:PCAdmin.PlayerReplicationInfo.PlayerName, P.PlayerReplicationInfo.PlayerName, "Reason:"$reason);
		}
		class'UT3XUtils'.static.WebAdminMessage(WorldInfo, msg);
		
		foreach WorldInfo.AllControllers(class'UT3XPC', PC){
			PC.ClientDisplayMessage2(msg, 0.85, 8, 1, class'UT3XMsgOrange'.default.DrawColor);
		}
		P.ClientPlaySound(SoundCue'A_Gameplay.CTF.Cue.A_Gameplay_CTF_FlagAlarm_Cue', true);
	} else {
		if(PCAdmin != None){
			PCAdmin.ClientMessage("Player/ID unknown", 'CriticalEvent' );
		}
	}
}



// Check if player is fake then if he is in-game after some amount of time
// then kick
function CheckFakePlayer(UT3XPCABS PC){

	if(!kickFakePlayers){
		return;
	}

	if(PC.isFakePlayer() && (( WorldInfo.TimeSeconds - PC.enteredGameTime) > minSecondsFakePlayerBeforeKick)){
		UTPKick(kickTitle, PC, , "Bad Player");
	}

}

static function String getPlayerIpRangeStart(IPC x){
	return x.A$"."$x.B$"."$x.C$"."$x.D;
}

static function String getPlayerIpRangeEnd(IPC x){
	return x.E$"."$x.F$"."$x.G$"."$x.H;
}


defaultproperties
{
	kickFakePlayers = true;
	anonymousAdminName = "an administrator";
	kickTitle="UT3X Protector";
	banTitle="UT3X Protector";
	kickbanextramsg="For complaints, ask the server administrator.";
	maxDaysBanDuration = 9999;
	DefaultKickReason="NOT SPECIFIED";
	minSecondsFakePlayerBeforeKick = 70; // 70 seconds
}
