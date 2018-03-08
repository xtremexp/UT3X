/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*
* IDEAS for UT3X future versions:
* - display name above players when spectating (flyby) - find "bShouldPostRenderEnemyPawns", "simulated event PostRenderFor" in UTPawn.uc
* - make smileys configurable
* - add more smileys
* - improved map vote (render + features)
* - add boolean for isHeadAdmin in UT3 webadmin core code
* - Improve the givepickup command
*/
 
class UT3X extends UTMutator config(UT3XConfig);

//SHOUD BE INCREMENTED WITH EVERY CHANGES DEPENDING ON FIX, MINOR/MAJOR CHANGES
const UT3XVersion="1.7.6"; 
const UT3XDate="08/03/2018";
const UT3XAuthors="XtremeXp";
var bool isUT3XServer;
var bool onlyUT3XServersVersion;
var bool isNotServerStart;

struct USmileyss
{
	
	var Texture2D smileysTexture;
	var array<String> smileysText;
	var bool bOnlyAdminUsage; // if true only logged admins can use this smiley
	
	structdefaultproperties
	{
		bOnlyAdminUsage=true;
	}
};

struct ClientListType
{
	var string IP,Name;
	var TcpipConnection conn;
};

struct SocketDataPacketType
{
	var TcpipConnection conn;
	var String PlayerIP;
	var String PlayerName;
	var String PlayerPort;
	var String ConnectionState;
	var String DLFile;
	var int TextChannels;
	var int ActorChannels;
	var int FileChannels;
	var int OtherChannels;
};




var UT3XAC acc;

// override pawn thing
var config bool bShouldPostRenderEnemyPawns;

var config String timeZone;
var config float timeZoneOffset;

var UT3XLagDetector uld; // Lag Detection
var config bool bLagDetectorActive;

var UT3XMapInfo umi; // Display Map Author and title
var config bool bMapInfoActive;

var config bool bLangCheckerActive;

var UT3XDemoRec udr; // Auto record demo files
var config bool bDemoRecActive;

var UT3XCountries uc; // IP2Country Database

var UT3XTeamBalancer tb; // Auto-balances teams
var config bool bTeamBalancerActive;

var UT3XAdverts ad; // Display adverts
var config bool bAdvertsActive;

var UT3XAFKChecker afkc;
var config bool bAFKCheckerActive;

var UT3XSmileys usm;
var config bool bSmileysActive;

var UT3XSounds us;
var config bool bZoundsActive;

var UT3XLog ul; 
var UT3XDefaultMap udm; // Switches to default map if server empty
var config bool bDefaultMapActive;

var config bool bUT3XMapListManagerActive;

var config bool bUseUT3XHud; // Use UT3X HUD

var array<UTPlayerController> UTPCs;

// if true then will get/send data to external server with php
var config bool bUseUT3XTcpLink;

var Class<UT3XWebAdminHook>		WebAdminHookClass;
//var Class<Object>		WebAdminHookClass;

function String getLocalIP(){
	local IpAddr Addr;
	local string ipAdrStr;
	local TcpLink tcp;

	tcp = spawn(class'TcpLink');
	tcp.GetLocalIP(Addr);
	ipAdrStr = tcp.IpAddrToString(Addr);
	tcp.Destroy();

	return ipAdrStr;
}

function InitMutator(string Options, out string ErrorMessage)
{
	
	
	LogInternal( "UT3X - Server Mutator V"$UT3XVersion$"("$UT3XDate$" by UT3X-XtremeXp)" );
	
	LogInternal("Starting UT3X ...");
	InitUT3X();
	
	if (NextMutator != None)
	{
		NextMutator.InitMutator(Options, ErrorMessage);
	}
}



function InitUT3X(){

	WorldInfo.Game.PlayerReplicationInfoClass = class'UT3XPlayerReplicationInfo';
	WorldInfo.Game.PlayerControllerClass = class'UT3XPC';
	
	WorldInfo.Game.AccessControlClass = class'UT3XAC';
	WorldInfo.Game.AccessControl = Spawn(class'UT3XAC');
	

	`Log("Starting UT3X Vote Collector ...",,'UT3X');
	
	UTGame(WorldInfo.Game).VoteCollectorClassName = "UT3X.UT3XVoteCollector";
	UTGame(WorldInfo.Game).InitializeVoteCollector();
	
	
	acc = UT3XAC(WorldInfo.Game.AccessControl);
	acc.log = Spawn(class'UT3XLog');
	acc.pdb = Spawn(class'UT3XPlayersDB');
	acc.ps = Spawn(class'UT3XPlayerSettings');
	acc.mut = self;
	
	if(bLangCheckerActive){
		acc.lc = Spawn(class'UT3XLanguageChecker');
	}
	
	acc.log.addLog(LT_MAPCHANGE, , , WorldInfo.getMapName(true));
	
	
	if(udr == None && bDemoRecActive){
		`Log("Starting DemoRec ...",,'UT3X');
		udr = spawn(class'UT3XDemoRec');
	}


	if(ad == None && bAdvertsActive){
		`Log("Starting Adverts ...",,'UT3X');
		ad = spawn(class'UT3XAdverts');
	}

	if(udm == None && bDefaultMapActive){
		`Log("Starting Default Map Manager ...",,'UT3X');
		udm = spawn(class'UT3XDefaultMap');
	}

	if(bUT3XMapListManagerActive){
		`Log("Starting UT3X Map List Manager ...",,'UT3X');
		UTGame(WorldInfo.Game).MapListManagerClassName = "UT3X.UT3XMapListManager";
	} else {
		UTGame(WorldInfo.Game).MapListManagerClassName = "UTGame.UTMapListManager";
	}
	
	if(uc == None){
		`Log("Loading IP2C database ...",,'UT3X');
		uc = spawn(class'UT3XCountries');
		acc.pdb.uc = uc;
		
		if(acc.pdb.PlayersLogs_Merge.length > 0){
			acc.pdb.merge();
		}
	}

	if(tb == None && bTeamBalancerActive){
		`Log("Starting TeamBalancer ...",,'UT3X');
		tb = spawn(class'UT3XTeamBalancer');
		//UTGame(WorldInfo.Game).DefaultPawnClass = class'UTHeroPawn'; // For player boost if teams not balanced
	}

	if(uld == None && bLagDetectorActive){
		`Log("Starting LagDetector ...",,'UT3X');
		uld = spawn(class'UT3XLagDetector');
	}
	
	if(afkc == None && bAFKCheckerActive){
		`Log("Starting AfkChecker ...",,'UT3X');
		afkc = spawn(class'UT3XAFKChecker');
	} else {
		`Log("AFKChecker desactivated",,'UT3X');
	}
	
	if(us == None && bZoundsActive){
		`Log("Starting UT3XSounds ...",,'UT3X');
		us = spawn(class'UT3XSounds');
	}	
	
	if(usm == None && bSmileysActive){
		`Log("Starting UT3XSmileys ...",,'UT3X');
		usm = spawn(class'UT3XSmileys', self);
		LogInternal(usm);
	}
	
	if(umi == None && bMapInfoActive){
		`Log("Starting MapInfo ...",,'UT3X');
		umi = spawn(class'UT3XMapInfo');
	}
	
	if(UTVehicleCTFGame_Content(WorldInfo.Game) != none && bUseUT3XHud)
	{
		UTCTFGame_Content(WorldInfo.Game).HUDType = Class'UT3XUTCTFHUD';
		UTVehicleCTFGame_Content(WorldInfo.Game).HUDType = Class'UT3XUTCTFHUD';
	}
	
	`Log("Starting UT3XWebAdmin ...",,'UT3X');
	SetTimer(-1.0, False, 'InitializeWebAdminHook');
	
}

function InitializeWebAdminHook()
{
	local Actor WebServerObj;
	local String ut3xwa_class;
	
	ut3xwa_class = "UT3XWebAdmin.UT3XWebAdminHook_Generic";
	
	if (WebAdminHookClass != none)
		return;

	WebServerObj = UTGame(WorldInfo.Game).WebServerObject;

	if (WebServerObj != none)
	{
		WebAdminHookClass = Class<UT3XWebAdminHook>(DynamicLoadObject(ut3xwa_class, Class'Class'));

		if (WebAdminHookClass != none){
			`Log("UT3XWebAdmin class "$ut3xwa_class$" loaded. Initializing ..",,'UT3XWebAdmin');
			WebAdminHookClass.static.InitializeWebAdminHook(self, WebServerObj);
		} else {
			`Log("UT3XWebAdmin could not load "$ut3xwa_class,,'ERROR');
		}
	} else {
		`Log("UT3XWebAdmin could not start. Web server not found!",,'ERROR');;
	}
	
}

function NotifyLogout(Controller Exiting)
{

	if(!Exiting.PlayerReplicationInfo.bBot){
		LogInternal(TimeStamp()@"-[LOGOUT]-"@Exiting.PlayerReplicationInfo.PlayerName);
		
		// TEST START
		/*
		LogInternal("AAA: "$UT3XPC(Exiting).playerip);
		LogInternal("SNA: "$UT3XPC(Exiting).PlayerReplicationInfo.SavedNetworkAddress);
		LogInternal("SNA: "$UT3XPC(Exiting).getServerNetworkAddress());
		LogInternal("PNA: "$PlayerController(Exiting).GetPlayerNetworkAddress());
		*/
		// TEST END
		
		if(UT3XPC(Exiting) != None && UT3XPC(Exiting).isAnonymous){
			UT3XAC(WorldInfo.Game.AccessControl).anonymouses.removeItem(Exiting.PlayerReplicationInfo.PlayerName);
		} else {
			acc.NotifyLogoutToLog(Exiting);
		}
		
	}

	if ( NextMutator != None )
		NextMutator.NotifyLogout(Exiting);
}

function NotifyLogin(Controller NewPlayer)
{
	local UT3XPC PC;
	local String badName;

	if(!NewPlayer.PlayerReplicationInfo.bBot){
		LogInternal(TimeStamp()@"-[LOGIN]-"@NewPlayer.PlayerReplicationInfo.PlayerName);

		if(UT3XPC(NewPlayer) != None && !UT3XPC(NewPlayer).isAnonymous){
			acc.NotifyLogin(NewPlayer);
		}

		if(udr != None){
			udr.checkDemoRecActive();
		}
		
		if(UT3XPC(NewPlayer) != None){
			PC = UT3XPC(NewPlayer);
			
			
			PC.playerip = PlayerController(NewPlayer).GetPlayerNetworkAddress();
			PC.isAnonymous = (UT3XAC(WorldInfo.Game.AccessControl).anonymouses.Find(CAPS(NewPlayer.PlayerReplicationInfo.PlayerName)) != -1);

			PC.InitCountry(); // Set Country Info to Controller
			PC.getCN(); // GET Country Name extra data
			
			// Check player name, if not corrected then kick
			if(!acc.lc.CheckMessage(PC, NewPlayer.PlayerReplicationInfo.PlayerName, badName, true)){
				acc.UTPKick("UT3X-BOT", PC,, "Bad playername");
			}
		}
	}

	if ( NextMutator != None )
		NextMutator.NotifyLogin(NewPlayer);
}

static function String getAuthors(){
	return UT3XAuthors;
}

static function String getVersion(){
	return "v"$UT3XVersion; //$" ("$UT3XDate$")";
}

function ModifyLogin(out string Portal, out string Options)
{
	// Balancer - Make NEW Player join the losing team preferably ...
	// Wont work if player rejoin same match 
	// UT3 keeps in cache team of disconnected player  in GameInfo.InactivePRIArray / PlayerReplicationInfo.Team
	if (tb != none){
		tb.PlayerJoiningGame(Portal, Options);
	}
	Super.ModifyLogin(Portal, Options);
}




static function String getUT3XLogTag(){
	return "[UT3X]";
}

function bool CheckReplacement(Actor Other)
{
	local UT3XSmileyReplicationInfo RepInfo;

	if(bUseUT3XHud && usm != None && Other.IsA('PlayerController') && (!Other.IsA('DemoRecSpectator')) && (!Other.IsA('TeamChatProxy')))
	{
		//LogInternal(getFuncName()$"-"$Other$"-"$WorldInfo.NetMode$"-"$self.usm.smileysList.length);
		RepInfo = Spawn(class'UT3XSmileyReplicationInfo', Other);
		RepInfo.SmileyClass = usm;
		return true;
	}
	return super.CheckReplacement(Other);
}


function GetServerDetails( out GameInfo.ServerResponseLine ServerState )
{
	// append the mutator name.
	local int i;
	i = ServerState.ServerInfo.Length;
	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Mutator";
	ServerState.ServerInfo[i].Value = UT3XVersion;
}

defaultproperties
{
	//WebAdminHookClass="UT3XWebAdmin.UT3XWebAdminHook_Generic";
	bUseUT3XTcpLink = false;
	bUT3XMapListManagerActive = true;
	bUseUT3XHud = false; // Disabled for compatibility with some other mutator
	bLagDetectorActive = false;
	bMapInfoActive = true;
	bDemoRecActive = true;
	bZoundsActive = true;
	bTeamBalancerActive = true;
	bAdvertsActive = true;
	bAFKCheckerActive = true;
	bSmileysActive = false;
	bLangCheckerActive = true;
	bDefaultMapActive = false;
	timeZone = "CET"; // Central European Time
	timeZoneOffSet = 1.0000;
}
