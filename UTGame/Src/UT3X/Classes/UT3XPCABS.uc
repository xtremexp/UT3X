/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XPCABS extends UTPlayerController;

var array<USmileyss> smileysList;


var IP2C countryInfo; // UT3XCountries
var float deltaTime; // Time in seconds between server time and client time
var float enteredGameTime;
// PlayerController.LastActiveTime doesn't work ...
var float LastActiveTime2, inactiveTime, loginTime;
var vector LastSpecLocation; // for checking afks

var bool isAnonymous;
var bool noLog;
var bool isAFK; // useful?? duplicate data in UT3XPlayerReplicationInfo TODO remove?
var bool AFKForceSpecChecked;
var bool AFKKickChecked;
var bool AFKLoginChecked;
var string ASayPrefix;
var UT3XLink mytcplink;
var bool isSpeedHackKicked;
var UT3XAFKChecker afkc;
var String computerNamee;
var UT3XAdvertsReplication advertRI;

var bool allowSwitchToWinningTeam;
var bool wasAutoTeamSwitched; // avoid switching same player multiple time by auto team-balancer

var float LastPostRenderTraceTime;
var bool bPostRenderTraceSucceeded;
var String viewMode;

var String playerip;





// @overidde
reliable server function ServerSetClanTag(string InClanTag)
{
	local String badClanTag;
	
	if ( Len(InClanTag) > 16 )
	{
		InClanTag = Left(InClanTag, 16);
	}
	InClanTag = class'UT3XLib'.static.FilterChars(InClanTag);
	
	UTPlayerReplicationInfo(PlayerReplicationInfo).ClanTag = InClanTag;
	UT3XAC(WorldInfo.Game.AccessControl).modifyPlayerEntryLog(
		PlayerReplicationInfo.PlayerName,,,,,
		InClanTag);
		
	// Check player name, if not corrected then kick
	if(UT3XAC(WorldInfo.Game.AccessControl).lc != None && !UT3XAC(WorldInfo.Game.AccessControl).lc.CheckMessage(self, InClanTag, badClanTag, true)){
		UT3XAC(WorldInfo.Game.AccessControl).UTPKick("UT3X-BOT", self,, "Bad clantag");
	}
}

simulated event PostBeginPlay(){

	super.PostBeginPlay();

	afkc = UT3XAC(WorldInfo.Game.AccessControl).mut.afkc;

	enteredGameTime = WorldInfo.TimeSeconds;
	LastActiveTime2 = WorldInfo.TimeSeconds;
	
	advertRI = Spawn( Class'UT3XAdvertsReplication', self );
	advertRI.PC = self;

	setTimer(2.0, true, 'CheckAfkAndFakePlayers'); 

}



// TRYING TO SET COUNTRY WHEN PLAYER ENTER GAME
// Called from UT3X.NotifyLogin
reliable server function InitCountry(){

	local String ip;
	local IP2C ip2c;
	local int i;
	
	for (i=0;i<WorldInfo.GRI.PRIArray.Length;i++)
	{
		if(WorldInfo.GRI.PRIArray[i].PlayerID == PlayerReplicationInfo.PlayerID){
			ip = PlayerController(WorldInfo.GRI.PRIArray[i].owner).GetPlayerNetworkAddress();
			ip2c = UT3XAC(WorldInfo.Game.AccessControl).mut.uc.getCountryDataFromIP(ip);
			
			countryInfo = ip2c;
			UT3XPlayerReplicationInfo(WorldInfo.GRI.PRIArray[i]).countryInfo = ip2c;
		}
	}
}


exec function Summon( string ClassName )
{
	if(class'UT3XLib'.static.checkIsAdmin(self)){
		ServerSummon(ClassName);
	}
}

reliable server function ServerSummon(string ClassName){

	local class<actor> NewClass;
	local vector SpawnLoc;
	local Actor newActor;
	
	NewClass = class<actor>( DynamicLoadObject( ClassName, class'Class' ) );
	if( NewClass!=None )
	{
		if ( Pawn != None )
			SpawnLoc = Pawn.Location;
		else
			SpawnLoc = Location;
			
		newActor = Spawn( NewClass,,,SpawnLoc + 72 * Vector(Rotation) + vect(0,0,1) * 15, Rotation, , true );
		
		if(newActor == None){
			ClientMessage("Could not spawn "$ClassName,'CriticalEvent');
		} else {
			if (Pawn(newActor) != None) {
				Pawn(newActor).DropToGround();
			}
	
			if (UTVehicleFactory(newActor) != None) {
				UTVehicleFactory(newActor).bStartNeutral = true;
				UTVehicleFactory(newActor).TeamNum = 255;
				UTVehicleFactory(newActor).bKeyVehicle = true;
			}

			if (UTVehicle(newActor) != None) {
				UTVehicle(newActor).bTeamLocked = false;
				UTVehicle(newActor).Team = 255;
			}
			
			ClientMessage(ClassName$" spawned!",'CriticalEvent');
		}
	} else {
		ClientMessage("Class "$ClassName$" not found.",'CriticalEvent');
	}
}


reliable client function ClientDisplayMessage2(String Msg, float Position, float LifeTime, int FontSize, Color DrawColor){
	if(myHud == None){
		return;
	}
	
	LocalPlayer(Player).ViewportClient.ViewportConsole.OutputText(Msg);
	
	myHud.LocalizedMessage(
		class'UTLocalMessage',
		RealViewTarget,
		Msg, // Message
		1, // switch - always one?
		Position, // Position
		LifeTime, // sLifetime
		FontSize, // fontsize
		DrawColor
	);
}

reliable client function ClientDisplayMessage(UT3XMessage msg){

	
	if(myHud == None){
		return;
	}
	

	myHud.LocalizedMessage(
		class'UTLocalMessage',
		RealViewTarget,
		Msg.Msg, // Message
		1, // switch - always one?
		Msg.Position, // Position
		Msg.LifeTime, // sLifetime
		Msg.FontSize, // fontsize
		Msg.DrawColor
	);
}

reliable client function getCN(){
	// hash computername for privacy ...
	serverSetCN(class'HttpUtil'.static.MD5String(WorldInfo.ComputerName), TimeStamp());
}


reliable server function serverSetCN(String CN, String t){

	local float dt;
	local String encodedCN;


	computerNamee = CN;
	// once server got hashed computer name, check if players is banned by computer name
	dt = class'HttpUtil'.static.stringToTimestamp(TimeStamp()) - class'HttpUtil'.static.stringToTimestamp(t);
	deltaTime = dt;
	UT3XAC(WorldInfo.Game.AccessControl).checkIsBannedPlayer(self, "", "", CN);
	
	UT3XAC(WorldInfo.Game.AccessControl).modifyPlayerEntryLog(
	PlayerReplicationInfo.PlayerName, // PlayerName
	, // Last Prelogin
	, // Last Login
	, // IP
	, // Country
	, // clantag
	, // Unique ID
	, // CD-KEY hash
	CN,
	,
	dt);
}





function bool isFakePlayer(optional bool noUniqueIdCheck){
	local UniqueNetID NullID;

	return (!noUniqueIdCheck && PlayerReplicationInfo.UniqueID == NullID) || HashResponseCache == "" || HashResponseCache == "0"; 
}



// CHECK AFK PLAYERS
// IF AFK THEN FORCE PLAYER TO SPECTATOR
// ELSE KICK
unreliable server function CheckAfkAndFakePlayers(){

	local Vehicle V;
	local String oldInactiveTimeStr;
	local float currentTime, oldInactiveTime;
	local bool isKickSpecActive;
	
	currentTime = WorldInfo.TimeSeconds;

	if(WorldInfo.Game.AccessControl == None){ // sometimes some "None" warning in logs ... weird
		return;
	}
	
	if(afkc == None){
		afkc = UT3XAC(WorldInfo.Game.AccessControl).mut.afkc;
	}
	

	// afkc == NOne <-> AFK CHECKER DISABLED (WITH WEBADMIN)
	if(afkc == None || Player.IsDownloading() || WorldInfo.Game.bWaitingToStartMatch || WorldInfo.Game.bGameEnded || afkc.AFKKickSeconds <= 0){
		LastActiveTime2 = currentTime;
		isAFK = false;
		return;
	}
	
	// Check Fake players and kick if needed ...
	UT3XAC(WorldInfo.Game.AccessControl).CheckFakePlayer(self);

	// We do not check afks if not enough players on server ...
	if(!IsSpectating() && WorldInfo.Game.NumPlayers <= afkc.AFKMinPlayers){
		LastActiveTime2 = currentTime;
		isAFK = false;
		return;
	}
	
	// CHECKS AFKS
	// Player -(Force Spec)-> Spectator -(kick)-> Logout
	if(IsSpectating()){
		if(Location != LastSpecLocation){
			LastSpecLocation = Location;
			LastActiveTime2 = currentTime;
		}
	} else {
		if(Pawn != None){ // PLAYER ALIVE

			if(Vehicle(Pawn) != None){ // PLAYER IN A VEHICLE 
				V = Vehicle(Pawn);
				// IsFiring for spma vehicle(not moving so much ...)
				if(int(V.Velocity.X) != 0 || int(V.Velocity.Y) != 0 || int(V.Velocity.Z) != 0 || V.IsFiring()) 
				{
					LastActiveTime2 = currentTime;
				}
				
			} else {
				if(Pawn.Acceleration.X != 0 || Pawn.Acceleration.Y != 0 || Pawn.Acceleration.Z != 0)
				{
					LastActiveTime2 = currentTime;
				}
			}
		}
	}
	
	
	oldInactiveTime = inactiveTime;
	oldInactiveTimeStr = class'UT3XLib'.static.secondsToDateLength(oldInactiveTime);
	inactiveTime = currentTime-LastActiveTime2;
	
	// We do no check afks spectators if there are enough free spec slots (minFreeSpecSlotAFKCheck parameter config)
	if(IsSpectating() && (WorldInfo.Game.MaxSpectators - WorldInfo.Game.NumSpectators) >= afkc.minFreeSpecSlotAFKCheck ){
		//LastActiveTime2 = currentTime; // we do that to display afk spectators ...
		isKickSpecActive = false; // we won't kick afk spectators if not many free spec slots ..
		//return;
	} else {
		isKickSpecActive = true;
	}
	
	
	if(LastActiveTime2 != currentTime){
	
		//LogInternal(AFKLoginChecked$"Inactive Time:"$inactiveTime$" maxAFKTimeLoginSeconds:"$afkc.maxAFKTimeLoginSeconds);
	
		// TODO - TODO - TODO
		if(!AFKLoginChecked && inactiveTime >= afkc.maxAFKTimeLoginSeconds){
			//LogInternal("TODO KICK");
		}
		// SPECTATOR WITH AFK KICK WARNING
		// afkc.AFKWarningSeconds (60s) < afkc.AFKKickSeconds (4 min) < inactiveTime 
		if( afkc.AFKKickSeconds  < inactiveTime 
			&& !AFKKickChecked 
			&& IsSpectating() 
			&& !UT3XAC(WorldInfo.Game.AccessControl).isAWebAdmin(PlayerReplicationInfo.PlayerName)) { // DOES NOT KICK ADMINS/WEBADMINS
			
			if(isKickSpecActive){
				UT3XAC(WorldInfo.Game.AccessControl).UTPKick(afkc.AFKMsgPrefix, self, , "AFK (>"@class'UT3XLib'.static.secondsToDateLength(afkc.AFKKickSeconds)@")", true);		
			}
			
			AFKKickChecked = true;
		}
		
		// PLAYER WITH AFK KICK WARNING
		// afkc.AFKWarningSeconds (60s) < afkc.AFKForceSpecSeconds (4 min) < inactiveTime
		// do not kick afk player if in winning team
		else if( afkc.AFKForceSpecSeconds < inactiveTime && !AFKForceSpecChecked && !IsSpectating()){
		
			if(afkc.noAFKKickIfOnWinningTeam && isInWinningTeamAndPlayerCountBalanced()){
			
			} else {
		
				// IF CAN'T find a spectator slot then kick player
				// ADMINS ALWAYS GET A SPECTATOR SLOT even if no slots
				if(!ServerForceSpec(PlayerReplicationInfo.PlayerName, true)){
					UT3XAC(WorldInfo.Game.AccessControl).UTPKick(afkc.AFKMsgPrefix, self, , "AFK Player Duration >"@class'UT3XLib'.static.secondsToDateLength(afkc.AFKForceSpecSeconds)@" + no free spec slot.", true);		
				} else {
					class'UT3XUtils'.static.BroadcastMsg(WorldInfo, afkc.AFKMsgPrefix@PlayerReplicationInfo.PlayerName@" was switched to spectator mode. Reason: AFK", class'UT3XMsgOrange', self);
					
					if(isKickSpecActive){
						UT3XMessage(afkc.AFKMsgPrefix@"You have been switched to spectator mode. - If still afk, you will be kicked in "@class'UT3XLib'.static.secondsToDateLength(afkc.AFKKickSeconds), class'UT3XMsgOrange');
					}
					
					AFKForceSpecChecked = true;
					LastActiveTime2 = currentTime; // WE RESET THE COUNTDOWN
					LastSpecLocation = Location;
					isAFK = false; // Need to be false or else after being forced-spec will say player is back
				}
			}
		} 
		// PLAYER WITHOUT AFK KICK WARNING
		// afkc.AFKWarningSeconds (60s) < inactiveTime < afkc.AFKForceSpecSeconds (4 min)
		else if( (afkc.AFKWarningSeconds < inactiveTime) && ( inactiveTime < afkc.AFKForceSpecSeconds) && !isAFK && !IsSpectating()){
			class'UT3XUtils'.static.BroadcastMsg(WorldInfo, afkc.AFKMsgPrefix@PlayerReplicationInfo.PlayerName@" is now AFK", class'UT3XMsgOrange', self);
			UT3XMessage(afkc.AFKMsgPrefix@"You are AFK - If still afk, you will be switched to spectator mode in "@class'UT3XLib'.static.secondsToDateLength(afkc.AFKForceSpecSeconds-afkc.AFKWarningSeconds), class'UT3XMsgOrange');
			isAFK = true;
		} 
		
		// SPECTATOR WITHOUT AFK KICK WARNING
		// afkc.AFKWarningSeconds (60s) < inactiveTime < afkc.AFKKickSeconds (4 min)
		else if( (afkc.AFKWarningSeconds < inactiveTime) &&( inactiveTime < afkc.AFKKickSeconds) && !isAFK && IsSpectating()){
		
			if(isKickSpecActive){ 
				UT3XMessage(afkc.AFKMsgPrefix@"You are AFK - If still afk, you will be kicked in "@class'UT3XLib'.static.secondsToDateLength(afkc.AFKKickSeconds-afkc.AFKWarningSeconds), class'UT3XMsgOrange');
			}
			
			isAFK = true;
		}
	} else {
		if(isAFK){
			UT3XMessage(afkc.AFKMsgPrefix@"Welcome back to the unreal world after idling "$oldInactiveTimeStr$" into the matrix!", class'UT3XMsgGreen');
			
			// Not Important to see that afk spectator is back ..
			if(!IsSpectating()){
				class'UT3XUtils'.static.BroadcastMsg(WorldInfo, afkc.AFKMsgPrefix@PlayerReplicationInfo.PlayerName@" is back after idling "$oldInactiveTimeStr, class'UT3XMsgGreen', self);
			}
		}
		isAFK = false;
		AFKForceSpecChecked = false;
		AFKKickChecked = false;
		AFKLoginChecked = true;
	}
	
	if(UT3XPlayerReplicationInfo(PlayerReplicationInfo) != None){
		UT3XPlayerReplicationInfo(PlayerReplicationInfo).isAfk = isAFK;
	}
}


reliable server function ServerALogin(String password)
{

	local UTPlayerController PCAdmin;
	
	if(PlayerReplicationInfo.bAdmin){
		ClientMessage("You are ever logged in as an admin!");
		return;
	}
	

	if ( AdminCmdOk() )
	{
		if ( UT3XAC(WorldInfo.Game.AccessControl).ALogin(self, password) )
		{
			
			class'UT3XUtils'.static.WebAdminMessage(WorldInfo, PlayerReplicationInfo.PlayerName$" logged in as an administrator");
			if(!isAnonymous){
				//UT3XAC(WorldInfo.Game.AccessControl).log.addLog(LT_ADMINLOGIN, self.PlayerReplicationInfo.PlayerName, "", "Login-IP: "$GetPlayerNetworkAddress());
			}
			
			foreach WorldInfo.AllControllers(class'UTPlayerController', PCAdmin){
				if(PCAdmin.PlayerReplicationInfo.bAdmin){
					PCAdmin.ClientMessage(PlayerReplicationInfo.PlayerName$" logged in as an administrator");
				}
			}
			
			ClientMessage( "You logged in SILENTLY as an admin.", 'CriticalEvent' );
		} else {
			foreach WorldInfo.AllControllers(class'UTPlayerController', PCAdmin){
				if(PCAdmin.PlayerReplicationInfo.bAdmin){
					PCAdmin.ClientMessage(PlayerReplicationInfo.PlayerName$" tried to login as an admin."); // with password:"$Password);
				}
			}
		}
	}
	
}

exec function AdminLogin(String password)
{
	ServerALogin(password); // always silently :)
}

exec function ALogin(String password)
{

	ServerALogin(password); // always silently :)
}

exec function spec()
{
	ServerSpec();
}


exec function SwitchPlayer(string tar, optional string tar2){
	if(class'UT3XLib'.static.checkIsAdmin(self)){
		ServerSwitchPlayer(tar, tar2);
	}
}


reliable server function ServerSwitchPlayer(string tar, optional string tar2){

	local PlayerController switchedPlayer1, switchedPlayer2;
	
	if(WorldInfo.Game != None){
		if(UTTeamGame(WorldInfo.Game) != None){
			switchedPlayer1 =  PlayerController(WorldInfo.Game.AccessControl.GetControllerFromString(tar));

			if(!isAnonymous){
			UT3XAC(WorldInfo.Game.AccessControl).log.addLog(LT_OTHER, self.PlayerReplicationInfo.PlayerName, "", "SwitchPlayer"@tar@tar2);
			}
			
			if(switchedPlayer1 == None){
				ClientMessage( "Player/ID "$tar$" not found", 'CriticalEvent' );
				return;
			}
			SwitchSinglePlayer(switchedPlayer1, self);
			
			if(tar2 != "" && tar != tar2){
				switchedPlayer2 =  PlayerController(WorldInfo.Game.AccessControl.GetControllerFromString(tar2));
				if(switchedPlayer2 == None){
					ClientMessage( "Player/ID "$tar2$" not found", 'CriticalEvent' );
					return;
				}
				SwitchSinglePlayer(switchedPlayer2, self);
			}
		} else {
			ClientMessage( "Not a team-based gametype", 'CriticalEvent' );
		}
	}
}

function SwitchSinglePlayer(PlayerController switchedPC, optional PlayerController switchedByPC){

	local UT3XPC C;
	local String msg;
	local int newTeam, team;

	
	if(UTTeamGame(WorldInfo.Game) == None){
		return;
	}
	
	team = switchedPC.PlayerReplicationInfo.Team.TeamIndex;
	if(team == 0){
		newteam = 1;
	} else {
		newteam = 0;
	}
	
	UTTeamGame(WorldInfo.Game).SetTeam(switchedPC, UTTeamGame(WorldInfo.Game).Teams[newTeam], true);
	
	msg = switchedPC.PlayerReplicationInfo.PlayerName;
	msg @= "has/have been switched";
	
	if(switchedByPC != None){
		msg @= " by "$switchedByPC.PlayerReplicationInfo.PlayerName;
	}
	
	foreach WorldInfo.AllControllers(class'UT3XPC', C){
		if(newTeam == 0){
			C.UT3XMessage("<- "$msg, class'UT3XMsgOcean');
		} else {
			C.UT3XMessage("-> "$msg, class'UT3XMsgOcean');
		}
	}

}

exec function PM(string playername, string message){
	if(AllowTextMessage(message)){
		ServerPM(playername, message); 
	}
}

//unreliable server function ServerPM(string playername, string message, class<UTLocalMessage> msgclass)
unreliable server function ServerPM(string playername, string message)
{
	local PlayerController P;
 
	P =  PlayerController(WorldInfo.Game.AccessControl.GetControllerFromString(playername) );
	
	if(P == None){
		ClientMessage( "No match found for playername/id "$playername$" use getPlayersList for list", 'CriticalEvent' );
	} else {
		if(!isAnonymous){
		UT3XAC(WorldInfo.Game.AccessControl).log.addLog(LT_PMCHAT, PlayerReplicationInfo.PlayerName, P.PlayerReplicationInfo.PlayerName, message);
		}
		message = "PM from "$PlayerReplicationInfo.PlayerName$" (ID: "$PlayerReplicationInfo.PlayerID$" ): "$message;
		self.ClientMessage("PM sent to "$P.PlayerReplicationInfo.PlayerName$" (ID: "$P.PlayerReplicationInfo.PlayerID$" )");
		P.ClientMessage( message, 'CriticalEvent' );
	}
}

// FORCES SPECTATOR TO BECOME A PLAYER
exec function ForceJoin(string target2){
	ServerForceJoin(target2);
}

// FORCES SPECTATOR TO BECOME A PLAYER
reliable server function ServerForceJoin(string target2){
	local PlayerController P;
	local UTPlayerController PC;
	
	if(class'UT3XLib'.static.checkIsAdmin(self)){
		if(WorldInfo.Game.NumPlayers < WorldInfo.Game.MaxPlayers){
			P =  PlayerController(WorldInfo.Game.AccessControl.GetControllerFromString(target2) );
			PC = UTPlayerController(P);
			if(!isAnonymous){
			UT3XAC(WorldInfo.Game.AccessControl).log.addLog(LT_OTHER, self.PlayerReplicationInfo.PlayerName, "", "ForceJoin"@target2);
			}
			PC.ServerBecomeActivePlayer();
		} else {
			ClientMessage("Not enough player slots to force spectator to join");
		}
	}
}

exec function ForceSpec(string target2){
	ServerForceSpec(target2);
}

// @param target2
reliable server function bool ServerForceSpec(string target2, optional bool noadmincheck, optional String reason){
	local UTPlayerController PC;
	local String msg;
	
	// ALL SPEC SLOTS TAKEN
	if(WorldInfo.Game.NumSpectators == WorldInfo.Game.MaxSpectators){
		ClientMessage("Cannot force spec since there are no spectator slots free! ("$WorldInfo.Game.MaxSpectators$"/"$WorldInfo.Game.MaxSpectators$")");
		return false;
	} else {
		PC =  UTPlayerController(WorldInfo.Game.AccessControl.GetControllerFromString(target2) );
		if(PC == None){
			ClientMessage("Player/ID not found");
			return false;
		}
		msg = PC.PlayerReplicationInfo.playername$" was switched to spectator mode.";
		
		//if(Len(Reason) > 0){
			//msg $= "Reason:"$reason;
		//}
		
		return ServerSpec(PC, msg);
	}
	
	return false;
}

// can be used too to force player to spectate (if afk for example)
// @param upc If NULL then make spectator the current player (that used the command)
// @param onSpecMsg Not used yet, will be used for AFKChecker (force player to spectator)
reliable server function bool ServerSpec(optional UTPlayerController upc, optional string onspecmsg)
{
	local UTPlayerController PC;
	
	if(upc == None){
		PC = self;
	} else {
		PC = upc;
	}
	
	// ADMINS CAN ALWAYS SPEC EVEN IF SERVER FULL
    if ( (!WorldInfo.Game.AtCapacity(true) || UT3XAC(WorldInfo.Game.AccessControl).isAWebAdmin(PC.PlayerReplicationInfo.PlayerName))
		&& !PC.PlayerReplicationInfo.bOnlySpectator
        && !WorldInfo.Game.bGameEnded 
		&& WorldInfo.Game.NumSpectators < WorldInfo.Game.MaxSpectators
        && WorldInfo.Game.GameReplicationInfo.bMatchHasBegun )
    {
       PC.PlayerReplicationInfo.bIsSpectator = true;
       PC.PlayerReplicationInfo.bOnlySpectator = true;
	   if (PC.PlayerReplicationInfo.Team != none)
	   {
			PC.PlayerReplicationInfo.Team.RemoveFromTeam(PC);
			PC.PlayerReplicationInfo.Team = none;
	   }

       if ( PC.Pawn != None )
          PC.Pawn.Died( PC, class'DmgType_Suicided', vect(0,0,0) );

       ++WorldInfo.Game.NumSpectators;
	   --WorldInfo.Game.NumPlayers;

	   PC.GotoState('Spectating');
       PC.ClientGotoState('Spectating', 'Begin');
	   
	   PC.ClientMessage( "You are now in spectator mode.", 'CriticalEvent' );
       PC.Reset();

        if ( !WorldInfo.Game.AccessControl.IsAdmin(PC) ){ // Silent spectator join for admins
			WorldInfo.Game.BroadcastLocalizedMessage( WorldInfo.Game.GameMessageClass, 16, PC.PlayerReplicationInfo );
			
			if(Len(onspecmsg)>0){
				WorldInfo.Game.Broadcast( PC, onspecmsg);
			} else {
				WorldInfo.Game.Broadcast( PC, PC.PlayerReplicationInfo.GetPlayerAlias()$" switched to spectator mode. (!spec)" );
			}
		}
		WorldInfo.Game.UpdateGameSettings();
		ClientBecameInactivePlayer(PC);
		
		if(!isAnonymous){
		UT3XAC(WorldInfo.Game.AccessControl).log.addLog(LT_OTHER, self.PlayerReplicationInfo.PlayerName, "", "Player->Spec");
		}
		
		return true;
    }
    else if ( WorldInfo.Game.AtCapacity(true) )
    {
       PC.ClientMessage( "No spectator slots are currently available.", 'CriticalEvent' );
	   return false;
    }
    else
    {
       //PC.ReceiveLocalizedMessage( WorldInfo.Game.GameMessageClass, 12 );
       PC.ClientMessage( "You are ever a spectator!", 'CriticalEvent' );
	   return false;
    }
}

reliable client function ClientBecameInactivePlayer(UTPlayerController PC)
{
	PC.UpdateURL("SpectatorOnly", "1", false);
}


//@override
exec function AdminLogout(){
	if ( AdminCmdOk() )
	{
		ServerALogout();
	}
}

exec function ALogout()
{
	if ( AdminCmdOk() )
	{
		ServerALogout();
	}
}

reliable server function ServerALogout()
{
	if ( WorldInfo.Game.AccessControl != none )
	{
		if ( UT3XAC(WorldInfo.Game.AccessControl).AdminLogOut(self) )
		{
			if(!isAnonymous){
			UT3XAC(WorldInfo.Game.AccessControl).log.addLog(LT_ADMINLOGIN, self.PlayerReplicationInfo.PlayerName, "", "Logout-IP: "$GetPlayerNetworkAddress());
			}
			self.ClientMessage( "You are no longer an administrator.", 'CriticalEvent' );
		}
	}
}

// DISPLAY A WHITE MESSAGE
exec function ASay(string msg){
	if(class'UT3XLib'.static.checkIsAdmin(self)){
		ServerASay(msg);
	}
}

reliable server function ServerASay(string msg){
	local UT3XPC PC;

	msg = UT3XAC(WorldInfo.Game.AccessControl).anonymousAdminName$":"@msg;
	foreach WorldInfo.AllControllers(class'UT3XPC', PC){
		PC.UT3XMessage(msg, class'UT3XAdminMsg');
	}
}


//@TODO RENAME (<ut3x> <kick> <playername> <reason>
exec function UTPKick(string playerKicked, optional string reason){
	ServerUTPKick(self.PlayerReplicationInfo.PlayerName, playerKicked, reason);
}


reliable server function ServerUTPKick(String KickerName, string playerKicked, optional string reason){

	local PlayerController kickedPlayer;
	
	if(class'UT3XLib'.static.checkIsAdmin(self)){
	
		if(reason == ""){
			ClientMessage("You must provide reason to kick player (e.g: 'kick sacha spawnkilling')");
			ClientMessage("Reasons available: "$UT3XAC(WorldInfo.Game.AccessControl).getAvailableKickReasons());
			return;
		}
		
		kickedPlayer = PlayerController(WorldInfo.Game.AccessControl.GetControllerFromString(playerKicked));
		
		if(kickedPlayer == None){
			ClientMessage("Player Not Found ", 'CriticalEvent' );
			return;
		}

		UT3XAC(WorldInfo.Game.AccessControl).applyKickAction(self.PlayerReplicationInfo.PlayerName, kickedPlayer, reason); //UTPKick2(self, P, reason);
	}
}



exec function UTPKickBan(string playername, optional string seconds, optional string reason){
	self.ClientMessage("This command is no longer available. Type 'UTPKICK playername reason'");
	return;
}

// BANS PERMANENTLY
exec function UTPKickBanPermanently(string bannedPlayer, optional string reason){
	self.ClientMessage("This command is no longer available. Type 'UTPKICK playername reason'");
		return;
}

reliable server function ServerUTPKickBanPermanently(string bannedPlayer, optional string reason){

	local PlayerController P;
	
	if(class'UT3XLib'.static.checkIsAdmin(self)){
		P = PlayerController(WorldInfo.Game.AccessControl.GetControllerFromString(bannedPlayer));

		if(P != None){
			UT3XAC(WorldInfo.Game.AccessControl).UTPKickBan(self.PlayerReplicationInfo.PlayerName, P, reason, , true);
		} else { // IF PLAYER IS NOT IN SERVER WE BAN HIM USING THE GLOBALPLAYERSLIST
			UT3XAC(WorldInfo.Game.AccessControl).UTPKickBanFromPlayerName(self, bannedPlayer, reason, , true);
		}		
	}
}

reliable server function ServerUTPKickBan(string bannedPlayer, optional string seconds, optional string reason){

	local PlayerController P;
	
	if(class'UT3XLib'.static.checkIsAdmin(self)){
		P = PlayerController(WorldInfo.Game.AccessControl.GetControllerFromString(bannedPlayer));
	
		if(P != None){
			UT3XAC(WorldInfo.Game.AccessControl).UTPKickBan(self.PlayerReplicationInfo.PlayerName, P, reason, seconds);
		} else { // IF PLAYER IS NOT IN SERVER WE BAN HIM USING THE GLOBALPLAYERSLIST
			UT3XAC(WorldInfo.Game.AccessControl).UTPKickBanFromPlayerName(self, bannedPlayer, reason, seconds);
		}
	}
}



exec function UTPWarn(string playername, optional string reason){ // WARNS A PLAYER (just an orange message broadcasted)
	if(class'UT3XLib'.static.checkIsAdmin(self)){
		ServerUTPWarn(self.PlayerReplicationInfo.playername, playername, reason);
	}
}

reliable server function ServerUTPWarn(String adminName, string playername, optional string reason){
	UT3XAC(WorldInfo.Game.AccessControl).ServerUTPWarn(adminName, playername, reason);
}

// @TODO FIX OR DEL
/*
exec function ChangeName(string playername){ 
	if(PlayerReplicationInfo.bAdmin){
		ClientMessage("You changed your name.", 'CriticalEvent' );
		ServerChangeName(playername);
	} else {
		ClientMessage("Only admins can change their name", 'CriticalEvent' );
	}
}*/

unreliable server function ServerTeamSay( string Msg )
{
	local bool bKickPlayer;
	
	LastActiveTime2 = WorldInfo.TimeSeconds;
	if(!ParseCmdMsg( Msg ) || !AllowTextMessage(Msg)){
		return;
	}
	if(bServerMutedText){
		UT3XMessage("YOU HAVE BEEN TEXT/VOICE MUTED", class'UT3XMsgRed');
	}
	ParseChatPercVar(Msg); // For %rank, ...
	
	// BAD LANGUAGE CHECK -> KICK
	if(UT3XAC(WorldInfo.Game.AccessControl) != None && UT3XAC(WorldInfo.Game.AccessControl).lc != None){
		bKickPlayer = !UT3XAC(WorldInfo.Game.AccessControl).lc.CheckMessage(self, Msg, Msg);
	}
	
	super.ServerTeamSay(Msg);
	
	
	if(bKickPlayer){
		// (String KickerName, PlayerController CPlayer, optional PlayerController CAdmin, optional string reason)
		
		// FIND DEFAULT ACTION FOR SWEARING, IF NO ACTION FOUND THEN KICK PLAYER (default behaviour)
		if(!UT3XAC(WorldInfo.Game.AccessControl).applyKickAction("UT3X-BOT", self, "SWEARING")){
			UT3XAC(WorldInfo.Game.AccessControl).UtpKick("UT3X-BOT", self, , "SWEARING"); 
		}
	}
}


unreliable server function ServerSay( string Msg )
{
	local bool bKickPlayer;
	
	
	LastActiveTime2 = WorldInfo.TimeSeconds;

	if(!ParseCmdMsg( Msg ) || !AllowTextMessage(Msg)){
		return;
	}
	if(bServerMutedText){
		UT3XMessage("YOU HAVE BEEN TEXT/VOICE MUTED", class'UT3XMsgRed');
	}
	ParseChatPercVar(Msg);
	
	// BAD LANGUAGE CHECK -> KICK
	if(UT3XAC(WorldInfo.Game.AccessControl) != None && UT3XAC(WorldInfo.Game.AccessControl).lc != None){
		bKickPlayer = !UT3XAC(WorldInfo.Game.AccessControl).lc.CheckMessage(self, Msg, Msg);
	}
	
	super.ServerSay(Msg);
	
	if(bKickPlayer){
		// (String KickerName, PlayerController CPlayer, optional PlayerController CAdmin, optional string reason)
		if(!UT3XAC(WorldInfo.Game.AccessControl).applyKickAction("UT3X-BOT", self, "SWEARING")){
			UT3XAC(WorldInfo.Game.AccessControl).UtpKick("UT3X-BOT", self, , "SWEARING"); 
		}
	}
}

function ParseChatPercVar(out string Msg){

	local int armor;
	
	Msg = REPL(Msg, "%RANK", PlayerReplicationInfo.PlayerRanking);
	Msg = REPL(Msg, "%PLOSS", PlayerReplicationInfo.PacketLoss);
	Msg = REPL(Msg, "%IP", getPlayerNetworkAddress());
	
	if(Pawn != None){
		Msg = REPL(Msg, "%HP", Pawn.Health);
		if(UTPawn(Pawn) != None){
			armor = int(UTPawn(Pawn).ShieldBeltArmor)+int(UTPawn(Pawn).VestArmor)+int(UTPawn(Pawn).ThighpadArmor)+int(UTPawn(Pawn).HelmetArmor);
			Msg = REPL(Msg, "%ARMOR", armor);
			Msg = REPL(Msg, "%HEALTH", Pawn.Health$"HP and "$armor$" armor");
		}
	} else {
		Msg = REPL(Msg, "%HP", "0/100");
	}
}

function bool ParseCmdMsg( string Msg){

	local Array<String> SplitedMsg;
	local string m;
	local string tmp;
	local int i;
	local PlayerController PC;
	
	m = Caps(Msg);

	LastActiveTime2 = WorldInfo.TimeSeconds; // FOR AFK CHECKER
	class'UT3XLib'.static.Split2(Msg, " ", SplitedMsg);
	
	// @TODO OPTIMIZE
	if(UT3XAC(WorldInfo.Game.AccessControl).mut.us != None){
		UT3XAC(WorldInfo.Game.AccessControl).mut.us.PlaySoundMsg(m, self, true);
	}

	
	// SPECTATES
	if(m == "!SPEC" || m == "SPEC"){
		ServerSpec();
		return false;
	} 
	// ALERT ADMINS
	else if(m == "!ADMIN"){
		class'UT3XUtils'.static.BroadcastMsg(WorldInfo, PlayerReplicationInfo.PlayerName@" is requesting an admin (!admin)", class'UT3XMsgYellow');
		WebAdminServerMessage(PlayerReplicationInfo.PlayerName@" is requesting an admin (!admin)");
		if(!isAnonymous){
		UT3XAC(WorldInfo.Game.AccessControl).log.addLog(LT_REQUEST, PlayerReplicationInfo.PlayerName, , "ADMIN REQUEST (!admin)");
		}
		return false;
	} else if(m == "!JOIN" || m == "JOIN"){
		BecomeActive();
		return false;
	} else if(m == "!SETNAME"){
		ClientMessage( "This command is not yet available", 'CriticalEvent' );
		return false;
	} else if(m == "!RED"){
		ClientMessage( "This command is not yet available", 'CriticalEvent' );
		return false;
	} else if(m == "!BLUE"){
		ClientMessage( "This command is not yet available", 'CriticalEvent' );
		return false;
	}
	else if(CAPS(SplitedMsg[0]) == "!PM" || CAPS(SplitedMsg[0]) == "PM"){
		if(bServerMutedText){
			ClientMessage("You cannot use private messages because you are muted");
			return false;
		}
	
		if(SplitedMsg.length < 3 ){
			ClientMessage( "Usage: !pm playername/id message", 'CriticalEvent' );
			return false;
		}
		for( i=2; i<SplitedMsg.length;i++){
			tmp $= SplitedMsg[i]$" ";
		}
		
		ServerPM(SplitedMsg[1], tmp);
		return false;
	} else if(CAPS(SplitedMsg[0]) == "!KICKVOTE"){
		if(SplitedMsg.length >= 2){
			ServerKickVoteSay(SplitedMsg[1]);
		} else {
			ClientMessage( "Usage: !kickvote playername/id  (e.g: !kickvote TheGirl)", 'CriticalEvent' );
		}
		return false;
	} else if(CAPS(SplitedMsg[0]) == "!REPORT"){
	
		ClientMessage("!report command is now disabled for undertermined time");
		return false;
			
		if(bServerMutedText){
			ClientMessage("You cannot use the report commmande because you are muted");
			return false;
		}
		if(SplitedMsg.length < 3){
			ClientMessage( "Usage: !report playername/id reason (e.g: !report TheGirl speedhacking)", 'CriticalEvent' );
			ClientMessage( "This command is not yet available", 'CriticalEvent' );
		} else {
			PC = PlayerController(WorldInfo.Game.AccessControl.GetControllerFromString(SplitedMsg[1]));
			if(PC == None){
				ClientMessage("No player found with name "$SplitedMsg[1]);
				return false;
			}
			tmp = PC.PlayerReplicationInfo.PlayerName;
			class'UT3XUtils'.static.BroadcastMsg(WorldInfo, PlayerReplicationInfo.PlayerName@" is reporting "$tmp$". Reason:"$SplitedMsg[2]$" (!report)", class'UT3XMsgYellow');
			WebAdminServerMessage(PlayerReplicationInfo.PlayerName@" is reporting "$tmp$". Reason:"$SplitedMsg[2]);
			if(!isAnonymous){
			UT3XAC(WorldInfo.Game.AccessControl).log.addLog(LT_REPORT, PlayerReplicationInfo.PlayerName, tmp, "Reason:"$SplitedMsg[2]);
			}
		}
		return false;
	} 
	// PREVENT ADMIN TO ACCIDENTALY SHOW ADMIN PASSWORD USING TEAMSAY INSTEAD OF CONSOLE ...
	else if( ((CAPS(SplitedMsg[0]) == "ALOGIN")||(CAPS(SplitedMsg[0]) == "ADMINLOGIN"))){
		ClientMessage("Use admin login command outside chat window (F10)");
		return false;
	}
	
	if(!bServerMutedText){
		if(!isAnonymous){
		UT3XAC(WorldInfo.Game.AccessControl).log.addLog(LT_CHATLOG, PlayerReplicationInfo.PlayerName, , class'UT3XLib'.static.FilterChars(Msg));
		}
	}
	return true; // DISPLAY THE MESSAGE
}

// @TODO TEST
reliable server function ServerKickVoteSay(String TargetPlayer, optional String reason){

	local UTPLayerController PCTarget;
	
	PCTarget = UTPlayerController(WorldInfo.Game.AccessControl.GetControllerFromString(TargetPlayer));
	
	if(PCTarget == None){
		ClientMessage("PlayerName/ID not found");
		return;
	} else {
		self.VoteRI.ServerRecordKickVote(PCTarget.PlayerReplicationInfo.PlayerID, true);
	}

}



reliable client event UT3XMessage( coerce string S, optional class<LocalMessage> lm, optional float MsgLifeTime, optional Name Type )
{
	if ( WorldInfo.NetMode == NM_DedicatedServer )
		return;

	if (Type == '')
		Type = 'Event';

	UT3XMessageA(PlayerReplicationInfo, S, lm, MsgLifeTime);
}



reliable client event UT3XMessageA( PlayerReplicationInfo PRI, coerce string S, optional class<LocalMessage> lm, optional float MsgLifeTime, optional Name Type  )
{
	local bool bIsUserCreated;

	if ( myHUD != None )
	{
	/*	function LocalizedMessage
(
	class<LocalMessage>		InMessageClass,
	PlayerReplicationInfo	RelatedPRI_1,
	string					CriticalString,
	int						Switch,
	float					Position,
	float					LifeTime,
	int						FontSize,
	color					DrawColor,
	optional object			OptionalObject
)*/
		myHud.LocalizedMessage(class'LocalMessage', PRI, S, 1, 0.5, 5, 2, MakeColor(128,160,80));
		if(lm == None){
			myHUD.AddConsoleMessage(S, class'LocalMessage', PRI, MsgLifeTime);
		} else {
			myHUD.AddConsoleMessage(S, lm, PRI, MsgLifeTime);
		}
	}

	if ( ((Type == 'Say') || (Type == 'TeamSay')) && (PRI != None) )
	{
		S = PRI.PlayerName$": "$S;
		// This came from a user so flag as user created
		bIsUserCreated = true;
	}

	// since this is on the client, we can assume that if Player exists, it is a LocalPlayer
	if (Player != None)
	{
		if (!bIsUserCreated ||
			// Don't allow this if the parental controls block it
			(bIsUserCreated && CanViewUserCreatedContent()))
		{
			LocalPlayer(Player).ViewportClient.ViewportConsole.OutputText(S);
		}
	}
}

//WebAdmin Message
exec function wamsg(String msg){
	WebAdminServerMessage(msg);
}

// SEND MESSAGE ONLY TO WEBADMIN SPECTATOR
reliable server function WebAdminServerMessage(String message){

	
	class'UT3XUtils'.static.WebAdminMessage(WorldInfo, message);
}


// @TODO
// TELLS IP, COUNTRY and other things ..
exec function getPlayerInfo(String playername){
	return;
}

exec function getIpInfo(String ip){
	ServerGetIPInfo(ip);
} 

reliable server function ServerGetIPInfo(String ip){
	local String country2;
	
	country2 = UT3XAC(WorldInfo.Game.AccessControl).mut.uc.getCountryNameFromIP(ip);
	
	
	if(country2 == ""){
		ClientMessage("No data found for this ip");
	} else {
		ClientMessage(country2);
	}
	
}

exec function ChangeTeam( optional string TeamName ){
	
	super.ChangeTeam(TeamName);
}


exec function UTPUnMute(string TargetPlayer){

	if(class'UT3XLib'.static.checkIsAdmin(self)){
		ServerUTPUnMute(TargetPlayer,self);
	}
}

unreliable server function ServerUTPUnMute(string TargetPlayer, optional PlayerController PCAdmin){
	local string error;
	
	if(class'UT3XLib'.static.checkIsAdmin(self)){
		error = UT3XAC(WorldInfo.Game.AccessControl).UTPMutePlayer(TargetPlayer, false, true, false, self.PlayerReplicationInfo.PlayerName);
	}
	
	if(error != ""){
		self.ClientMessage(error);
	}
}

function String getNewKickCmdMsg(){
	return "This command is no longer available. Type 'UTPKICK playername reason'";
}

// (string bannedPlayerName, bool isMuted, bool isBan, optional PlayerController PCAdmin, optional string banDuration, optional string reason){
unreliable server function ServerUTPMute(string TargetPlayer, bool mutePlayer, bool isBan, bool isPermanent, optional PlayerController PCAdmin, optional string duration, optional string reason){

	local string error;
	
	error = UT3XAC(WorldInfo.Game.AccessControl).UTPMutePlayer(TargetPlayer, mutePlayer, isBan, isPermanent, self.PlayerReplicationInfo.PlayerName, duration, reason);
	
	if(error != ""){
		self.ClientMessage(error);
	}
}


exec function SetGravity(float NewGravity)
{
	if(class'UT3XLib'.static.checkIsAdmin(self)){
		ServerSetGravity(NewGravity);
	}
}

exec function SetHeadSize(float HeadSize){
	if(class'UT3XLib'.static.checkIsAdmin(self)){
		ServerSetHeadSize(HeadSize);
	}
}

reliable server function ServerSetHeadSize(float HeadSize){
	local PlayerController PC;
	
	foreach WorldInfo.AllControllers(class'PlayerController', PC){
		UTPawn(PC.Pawn).SetHeadScale(HeadSize);
		PC.Pawn.PlayTeleportEffect(true, true);
	}
}

unreliable server function ServerSetGravity(float NewGravity){
	
	if(NewGravity == 0){
		NewGravity = class'WorldInfo'.default.DefaultGravityZ;
	}
	WorldInfo.WorldGravityZ=NewGravity;
	ClientMessage("New Gravity: "$NewGravity$"(Default:"$class'WorldInfo'.default.DefaultGravityZ$")");
}

exec function SetStallZ(float NewStallZ)
{
	if(class'UT3XLib'.static.checkIsAdmin(self)){
		ServerSetStallZ(NewStallZ);
	}
}

unreliable server function ServerSetStallZ(float NewStallZ){
	
	if(NewStallZ == 0){
		NewStallZ = 1000000;
	}
	WorldInfo.StallZ = NewStallZ;
	ClientMessage("New NewStallZ: "$NewStallZ$"(Default:1000000)");
}





// Executes a console command
// e.g: get engine.accesscontrol gamepassword

exec function CC(String cmd){
	if(class'UT3XLib'.static.checkIsAdmin(self)){
		ClientMessage("Command  no longer available");
	}
}

/*
unreliable server function ServerCC(String cmd){
	
	local String result;
	
	result = WorldInfo.Game.ConsoleCommand(cmd, false);
	if(Len(result)>0){
		ClientMessage("Console Command returns:"$result);
	} else {
		ClientMessage("No results from console command");
	}
}*/




// DETECTS SPEEDHACKS ...
// @TODO BAN INSTEAD OF KICK??
// NEEDS TO SET IN WEBADMIN OPTION:
// Maximum Time Margin = 7
// Minimum Time Margin = -1
// Time Margin Slack=1.35
unreliable server function ServerMove
(
	float	TimeStamp,
	vector	InAccel,
	vector	ClientLoc,
	byte	MoveFlags,
	byte	ClientRoll,
	int		View
)
{
	super.ServerMove(TimeStamp, InAccel, ClientLoc, MoveFlags, ClientRoll, View);
	
	if(LastSpeedHackLog > 0 && !isSpeedHackKicked){
		isSpeedHackKicked = true;
		SpeedHackKick();
	}
}

reliable server function SpeedHackKick(){
	// CHECK IF THERE IS DEFAULT ACTION FOR SPEEDHACKING
	// IF NOT THEN DO DEFAULT (KICK)
	if(!UT3XAC(WorldInfo.Game.AccessControl).applyKickAction("UT3X-BOT", self, "SPEEDHACKING")){
		UT3XAC(WorldInfo.Game.AccessControl).UTPKick("UT3X-BOT", self, , "SPEEDHACKING");	
	}
}




function DrawHUD( HUD H )
{
	local Canvas Canvas;
	
	super.DrawHud(H);
	Canvas = H.Canvas;
	if(Canvas == None){
		return;
	}
	DrawUT3XCreditsAndSpectators(H.Canvas);
	Canvas.Reset();
}


function Canvas DrawUT3XCreditsAndSpectators(Canvas Canvas){
	
	local int baseX;
	local int baseY;
	local string specsA, specsB, ctry;
	local int numSpec;
	local int i;
	local UTPlayerReplicationInfo PRI;


	if (WorldInfo.GRI != None)
	{
		for (i=0; i < WorldInfo.GRI.PRIArray.Length; i++)
		{
			PRI = UTPlayerReplicationInfo(WorldInfo.GRI.PRIArray[i]);
			if ( PRI != none && PRI.bOnlySpectator && (CAPS(PRI.playerName) != "DEMORECSPECTATOR") )
			{
				ctry = "";
				// country only displayed for logged admins
				if(UT3XPlayerReplicationInfo(PRI) != None && PlayerReplicationInfo.bAdmin){
					ctry = "-"$UT3XPlayerReplicationInfo(PRI).countryInfo.CC3;
				}
				
				// displays AFK status of spectators
				if(UT3XPlayerReplicationInfo(PRI) != None && UT3XPlayerReplicationInfo(PRI).isAfk){
					ctry $= "-AFK";
				}
				
				if(numSpec > 3){
					specsB $=PRI.PlayerName$"("$PRI.PlayerID$ctry$"), ";
				} else {
					specsA $=PRI.PlayerName$"("$PRI.PlayerID$ctry$"), ";
				}
				
				numSpec ++;
			}
		}
	}

	// TOP LEFT OF SCREEN
	baseX = 20; 
	baseY = int(Canvas.SizeY*0.86);
	Canvas.Font = class'Engine'.Static.GetTinyFont();
	
	if(UT3XPlayerReplicationInfo(PlayerReplicationInfo).isAnonymous){
		Canvas.SetDrawColor( 255, 0, 0, 255); // Red
		Canvas.SetPos(baseX, baseY);
		Canvas.DrawText("You are in anonymous mode", true);
		baseY += 15;
	}
	
	
	
	Canvas.SetDrawColor( 255, 255, 255, 255); // White
	Canvas.SetPos(baseX, baseY);
	// "by"@class'UT3X'.Static.getAuthors()@
	Canvas.DrawText("UT3X"@class'UT3X'.Static.getVersion(), true);
	baseY += 15;
	Canvas.SetPos(baseX, baseY);
	Canvas.DrawText("Spectators:", true);
	
	baseY += 15;
	Canvas.SetPos(baseX, baseY);
	Canvas.DrawText(specsA, true);
	
	baseY += 15;
	Canvas.SetPos(baseX, baseY);
	Canvas.DrawText(specsB, true);
	
	return Canvas;
}



exec function Walk()
{
	if(!class'UT3XLib'.static.checkIsAdmin(self)){return;}
	
	bCheatFlying = false;
	if (Pawn != None && Pawn.CheatWalk())
	{
		Restart(false);
	}
}

// For FUN :)
exec function Ghost()
{
	if(!class'UT3XLib'.static.checkIsAdmin(self)){return;}
	ServerGhost();
}

reliable server function ServerGhost(){
	
	if (Pawn != None) {
		DropFlag();
		Pawn.UnderWaterTime = -1.0;
		Pawn.SetCollision(False, False, False);
		Pawn.bCollideWorld = False;
		Pawn.SetPushesRigidBodies(false);
		GotoState('PlayerFlying');

		ClientMessage("You feel ethereal");
	}
}

exec function KillAll(class<actor> aClass){
	if(!class'UT3XLib'.static.checkIsAdmin(self)){return;}
	ServerKillAll(aClass);
}


reliable server function ServerKillAll(class<actor> aClass)
{
	local Actor A;
	local int numKilled;
	local int numFound;

	
	
	ForEach DynamicActors(class 'Actor', A){
		
		if ( ClassIsChildOf(A.class, aClass) ){
			numFound ++;
			if(A.Destroy()){
				numKilled ++;
			} else { // trying to force delete the actor ...
					
					// Shut down physics
					A.SetPhysics(PHYS_None);
					// shut down collision
					A.SetCollision(false, false);
					if (A.CollisionComponent != None)
					{
						A.CollisionComponent.SetBlockRigidBody(false);
					}

					// shut down rendering
					A.SetHidden(true);
					
					// ignore if in a non rendered zone
					A.bStasis = true;

					A.ForceNetRelevant();

					/*
					if (A.RemoteRole != ROLE_None)
					{
						// force replicate flags if necessary
						A.SetForcedInitialReplicatedProperty(Property'Engine.Actor.bCollideActors', false);
						A.SetForcedInitialReplicatedProperty(Property'Engine.Actor.bBlockActors', false);
						A.SetForcedInitialReplicatedProperty(Property'Engine.Actor.bHidden', true);
						A.SetForcedInitialReplicatedProperty(Property'Engine.Actor.Physics', true);
					}*/

					// we can't set bTearOff here as that will prevent newly joining clients from receiving the state changes
					// so we just set a really low NetUpdateFrequency
					A.NetUpdateFrequency = 0.1;
					// force immediate network update of these changes
					A.bForceNetUpdate = TRUE;
					
			}
		}
	}
	
	ClientMessage("Killed "$numkilled$"/"$numFound$" "$string(aClass));
}

exec function DebugPause(){if(class'UT3XLib'.static.checkIsAdmin(self)){super.DebugPause();}}
exec function UTrace(){if(class'UT3XLib'.static.checkIsAdmin(self)){super.UTrace();}}
exec function CE(Name EventName){if(class'UT3XLib'.static.checkIsAdmin(self)){super.CE(EventName);}}
exec function ListConsoleEvents(){if(class'UT3XLib'.static.checkIsAdmin(self)){super.ListConsoleEvents();}}
exec function ListCE(){if(class'UT3XLib'.static.checkIsAdmin(self)){super.ListCE();}}
//exec function SaveClassConfig(coerce string className){if(class'UT3XLib'.static.checkIsAdmin(self)){super.SaveClassConfig(className);}}

// Overrides default function  from UTPlayerController
exec function AdminKick(String playerKicked){
	self.ClientMessage(getNewKickCmdMsg());
}

// Overrides default function  from UTPlayerController
exec function AdminKickBan(String playerBanned){
	self.ClientMessage(getNewKickCmdMsg());
}

exec function AddTime(int seconds){
	ServerAddTime(seconds);
}

exec function PlayZound(string msg){
	if(class'UT3XLib'.static.checkIsAdmin(self)){
		ServerPlayZound(msg);
	}
}

reliable server function  ServerPlayZound(string msg){
	local String soundClassName;
	
	// @TODO OPTIMIZE
	if(UT3XAC(WorldInfo.Game.AccessControl).mut.us != None){
		if(UT3XAC(WorldInfo.Game.AccessControl).mut.us.PlaySoundMsg(msg, self, true, soundClassName)){
			ClientMessage("Now playing "$soundClassName);
		} else {
			if(soundClassName == ""){
				ClientMessage("Zound not found");
			} else {
				ClientMessage("Impossible to load zound "$soundClassName);
			}
		}
	}
}
	
reliable server function ServerAddTime(int seconds){
	if(class'UT3XLib'.static.checkIsAdmin(self)){
		class'UT3XUtils'.static.BroadcastMsg(WorldInfo, PlayerReplicationInfo.PlayerName@" have added "$seconds$"s", class'UT3XMsgOrange');
		WorldInfo.GRI.RemainingTime += seconds;
	}
}

exec function country(optional string cmd){

	if(cmd == "" || !(cmd == "off" || cmd == "on")){
		ClientMessage("USAGE: 'country off' for enabling anonymous country and 'country on' for enable");
		return;
	}

	ServerCountry(cmd);
}

unreliable server function ServerCountry(optional string cmd){
	UT3XAC(WorldInfo.Game.AccessControl).ps.setAnonymousCountry(self, "on" == cmd);
}

// ADDS UNIQUEID TO PLAYER INFO DATABASE
reliable server function ServerSetUniquePlayerId(UniqueNetId UniqueId,bool bWasInvited)
{
	local String uniqueIdStr, playerNetworkAdress, IP;
	//LogInternal(TimeStamp()$"-"$getFuncName()$"-"$class'OnlineSubsystem'.static.UniqueNetIdToString(UniqueId));
	
	// ADDS UNIQUE ID TO LOG
	if(!bPendingDestroy && !bReceivedUniqueId){
		uniqueIdStr = class'OnlineSubsystem'.static.UniqueNetIdToString(UniqueId);
		UT3XAC(WorldInfo.Game.AccessControl).modifyPlayerEntryLog(
			PlayerReplicationInfo.PlayerName, // PlayerName
			, // Last Prelogin
			, // Last Login
			, // IP
			, // Country
			, // clantag
			uniqueIdStr);
			
		// AUTO KICK PLAYER IF ACTIVE BAN
		playerNetworkAdress = getPlayerNetworkAddress(); // IP+port: "124.222.30.4:4257"
		IP = Left(playerNetworkAdress, InStr(playerNetworkAdress, ":"));
		
		UT3XAC(WorldInfo.Game.AccessControl).checkIsBannedPlayer(self, IP, uniqueIdStr);
	}
	
	super.ServerSetUniquePlayerId(UniqueId, bWasInvited);
	
	UT3XAC(WorldInfo.Game.AccessControl).ps.loadPlayerSettings(self); // for anonymous country for example ...
}

// ADDS HASH INFO TO PLAYER DATABASE
event ProcessConvolveResponse(string hash)
{
	//LogInternal(TimeStamp()$"-"$getFuncName()$"-"$hash);
	
	UT3XAC(WorldInfo.Game.AccessControl).modifyPlayerEntryLog(
			PlayerReplicationInfo.PlayerName, // PlayerName
			, // Last Prelogin
			, // Last Login
			, // IP
			, // Country
			, // clantag
			, // Unique ID
			hash);
	Super.ProcessConvolveResponse(hash);
}


exec function SpecPlayer(String playerName){
	ServerSpecPlayer(playerName);
}

unreliable server function ServerSpecPlayer(String playerName)
{
	local Controller C;

	if(!IsSpectating()){
		ClientMessage("This command only works in spectator mode.");
		return;
	}
	
    C = WorldInfo.Game.AccessControl.GetControllerFromString(playername);
	
	if(C == None || C.PlayerReplicationInfo == None){
		ClientMessage("No player found by name/id "$playerName);
		return;
	} else if(!WorldInfo.Game.CanSpectate(self, C.PlayerReplicationInfo)){
		ClientMessage("Player cannot be spectated.");
		return;
	}

	SetViewTarget(C.PlayerReplicationInfo);
}

// overrides default suicide delay from 10 seconds to 4
reliable server function ServerSuicide()
{
	if ( (Pawn != None) && ((WorldInfo.TimeSeconds - Pawn.LastStartTime > 4) || (WorldInfo.NetMode == NM_Standalone)) )
	{
		Pawn.Suicide();
	}
}

//spectating player wants to become active and join the game
// override to fix reset score when joining
reliable server function ServerBecomeActivePlayer()
{
	local UTGame Game;

	Game = UTGame(WorldInfo.Game);
	if ( PlayerReplicationInfo.bOnlySpectator && !WorldInfo.IsInSeamlessTravel() && HasClientLoadedCurrentWorld()
		&& Game != None && Game.AllowBecomeActivePlayer(self) )
	{
		SetBehindView(false);
		FixFOV();
		ServerViewSelf();
		PlayerReplicationInfo.bOnlySpectator = false;
		Game.NumSpectators--;
		Game.NumPlayers++;
		
		//PlayerReplicationInfo.Reset(); // this function always reset score (what's the point of that)
		// only reset what we need to reset
		UTPlayerReplicationInfo(PlayerReplicationInfo).SetFlag(None);
		PlayerReplicationInfo.bReadyToPlay = false;
		PlayerReplicationInfo.NumLives = 0;
		PlayerReplicationInfo.bOutOfLives = false;
		PlayerReplicationInfo.bForceNetUpdate = TRUE;
		UTPlayerReplicationInfo(PlayerReplicationInfo).bHasBeenHero = false;
		
		BroadcastLocalizedMessage(Game.GameMessageClass, 1, PlayerReplicationInfo);
		if (Game.bTeamGame)
		{
			//@FIXME: get team preference!
			Game.ChangeTeam(self, Game.PickTeam(0, None), false);
		}
		if (!Game.bDelayedStart)
		{
			// start match, or let player enter, immediately
			Game.bRestartLevel = false;  // let player spawn once in levels that must be restarted after every death
			if (Game.bWaitingToStartMatch)
			{
				Game.StartMatch();
			}
			else
			{
				Game.RestartPlayer(self);
			}
			Game.bRestartLevel = Game.Default.bRestartLevel;
		}
		else
		{
			GotoState('PlayerWaiting');
			ClientGotoState('PlayerWaiting');
		}

		ClientBecameActivePlayer();
		
		
		if(!isAnonymous){
			UT3XAC(WorldInfo.Game.AccessControl).log.addLog(LT_OTHER, self.PlayerReplicationInfo.PlayerName, "", "Spec->Player");
		}
		
		if (WorldInfo.Game.BaseMutator != none)
			WorldInfo.Game.BaseMutator.NotifyBecomeActivePlayer(Self);

		if (UTGame(WorldInfo.Game).VoteCollector != none)
			UTGame(WorldInfo.Game).VoteCollector.NotifyBecomeActivePlayer(Self);
	}
}


// override 
// do not allow players to switch to winning team unless
// they have ever been switched by the balancer
// or team size are not balanced
reliable server function ServerChangeTeam(int N)
{
	local UT3XTeamBalancer tb;
	local UTTeamGame uttg;
	local int redScore;
	local int blueScore;
	local bool canChangeTeam;
	
	canChangeTeam = true;
	
	if (WorldInfo.Game.bTeamGame){
		uttg = UTTeamGame(WorldInfo.Game);
		tb = UT3XAC(WorldInfo.Game.AccessControl).mut.tb;
		
		if(tb != None && !tb.allowSwitchToWinningTeam && uttg != None){
			redScore = uttg.Teams[0].score;
			blueScore = uttg.Teams[1].score;
			
			
			// Team sizes are not unbalanced - 1 player diff of difference max
			// and player have not bean balanced before
			
			if(Abs(uttg.Teams[0].size - uttg.Teams[1].size) < 2 && !allowSwitchToWinningTeam){
				if(PlayerReplicationInfo.Team.TeamIndex == 0 && (blueScore - redScore >= tb.maxScoreDiffToSwitchToWinningTeam)){
					canChangeTeam = false;
				}
				
				if(PlayerReplicationInfo.Team.TeamIndex == 1 && (redScore - blueScore >= tb.maxScoreDiffToSwitchToWinningTeam)){
					canChangeTeam = false;
				}
			}
			
			
			if(!canChangeTeam){
				ClientMessage("Switching disabled to winning team if score difference is >= "$tb.maxScoreDiffToSwitchToWinningTeam$" or if not auto-balanced");
				return;
			}
		}
		
	}
	super.ServerChangeTeam(N);
}

// if equals score then return false
// for afk checker (won't kick afk if this function return true)
private function bool isInWinningTeamAndPlayerCountBalanced(){

	local UTTeamGame uttg;
	if (WorldInfo.Game.bTeamGame){
		uttg = UTTeamGame(WorldInfo.Game);
		if(uttg != None){
			if(Abs(uttg.Teams[0].size - uttg.Teams[1].size) >= 2){
				return false;
			} else {
				if(PlayerReplicationInfo.Team.TeamIndex == 0  && (uttg.Teams[0].score > uttg.Teams[1].score)){
					return true;
				} else if(PlayerReplicationInfo.Team.TeamIndex == 1 && (uttg.Teams[1].score > uttg.Teams[0].score)){
					return true;
				}
			}
		}
		
	}
		
	return false;
}


reliable server function ServerRegisterPlayerRanking(int NewPlayerRanking)
{
	super.ServerRegisterPlayerRanking(NewPlayerRanking);
	
	UT3XPlayerReplicationInfo(PlayerReplicationInfo).PlayerRanking2 = NewPlayerRanking;
}

defaultproperties
{
	AFKForceSpecChecked=false;
	AFKKickChecked=false;
	isAFK=false;
	SpectatorCameraSpeed=1500; // FASTER THAN ORIGINAL (original: 600)
	ASayPrefix="Administrator";
	smileysList(0)=(smileysText=(":("),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.face-sad');
	smileysList(1)=(smileysText=(":)"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.emotion_smile');
	smileysList(2)=(smileysText=(":S"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.face-worried');
	smileysList(3)=(smileysText=("*B*"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.face-uncertain');
	smileysList(4)=(smileysText=(":D",":-D"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.face-smile-big');
	smileysList(5)=(smileysText=("LOL2"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.face-laugh');
	smileysList(6)=(smileysText=(":-O"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.face-supprised');
	smileysList(7)=(smileysText=("*WINK*"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.face-wink');
	smileysList(9)=(smileysText=(":-P",":P"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.emotion_tongue');
	smileysList(10)=(smileysText=("8-)"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.face-glasses');
	smileysList(11)=(smileysText=("*CRY*","cry"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.face-crying');
	smileysList(12)=(smileysText=("3:)"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.face-devilish');
	smileysList(13)=(smileysText=("*DEVIL*"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.face-devilish');
	smileysList(14)=(smileysText=("*SICK*","sick"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.face-sick');
	smileysList(15)=(smileysText=("*ANGEL*","angel"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.face-angel');
	smileysList(16)=(smileysText=(":@"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.face-angry');
	smileysList(17)=(smileysText=(":P"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.emotion_tongue');
	smileysList(18)=(smileysText=("*ANGRY*","angry"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.face-angry');
	smileysList(19)=(smileysText=("*FIRE*"),smileysTexture=Texture2D'UT3XContentV3.Smileys.smiley-32x32-fire');
	smileysList(20)=(smileysText=("ZZ"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.face-tired');
	smileysList(21)=(smileysText=("8)"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.face-cool');
	smileysList(22)=(smileysText=("LOL"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.lol2');
	smileysList(23)=(smileysText=("*GIRL*","girl"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.emotion_girl');
	smileysList(24)=(smileysText=("*LOVE*","love"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.emotion_love');
	smileysList(25)=(smileysText=("*PIZZA*"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.pizza');
	smileysList(26)=(smileysText=("*ILOVEU*","iloveu"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.iloveu');
	smileysList(27)=(smileysText=(":-*",":*","*KISS*"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.face-kiss');
	smileysList(28)=(smileysText=("*BANNED*"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.banned');
	smileysList(29)=(smileysText=("ban?"),smileysTexture=Texture2D'UT3XContentV3.banquestionmark');
	smileysList(30)=(smileysText=("*censored*"),smileysTexture=Texture2D'UT3XContentV3.SmileysNew.censored');
	
	smileysList(31)=(smileysText=("*blabla*"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.blabla');
	smileysList(32)=(smileysText=("bye","bb"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.bye');
	smileysList(33)=(smileysText=("*comehere*","comehere"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.comehereyou');
	smileysList(34)=(smileysText=("*comehere*","comehere"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.comehereyou');

	//smileysList(34)=(smileysText=("*dtc*","dtc"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.danstoncul');
	smileysList(35)=(smileysText=("..."),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.dots');
	smileysList(36)=(smileysText=("grrr"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.grrr');
	smileysList(37)=(smileysText=("hello","lo"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.hello');
	smileysList(38)=(smileysText=("help"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.help');
	smileysList(39)=(smileysText=("lame"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.lame');
	smileysList(40)=(smileysText=("*restorant*"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.restaurant');
	smileysList(41)=(smileysText=("plzdie"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.plzdie');
	smileysList(42)=(smileysText=("spam"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.spam');
	smileysList(43)=(smileysText=("*speakenglish*","speakenglish"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.speakenglish');
	smileysList(44)=(smileysText=("ty"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.thankyou');
	
	smileysList(45)=(smileysText=("emailme"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.emailme');
	smileysList(46)=(smileysText=("emosucks","emosux"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.emosucks');
	smileysList(47)=(smileysText=("*heartarrow*","heartarrow"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.heartarrow');
	smileysList(48)=(smileysText=("*heartarrow*","heartarrow"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.heartarrow');
	smileysList(49)=(smileysText=("*heartarrow*","heartarrow"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.heartarrow');
	//smileysList(48)=(smileysText=("imwithyourmom"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.imwithyourmom');
	//smileysList(49)=(smileysText=("jptg"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.jptg');
	smileysList(50)=(smileysText=("no!"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.No');
	smileysList(51)=(smileysText=("+1"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.plusone');
	smileysList(52)=(smileysText=("okjesors"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.okjesort');
	smileysList(53)=(smileysText=("oops","oops!"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.oops');
	smileysList(54)=(smileysText=("wc","toilet"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.wc');
	smileysList(55)=(smileysText=("bed","sleep"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.Sleep');
	smileysList(56)=(smileysText=("linux"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.Linux');
	
	//smileysList(57)=(smileysText=("cutegirl"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.headgirl');
	//smileysList(58)=(smileysText=("boobs"),smileysTexture=Texture2D'UT3XContentV3.SmileysV3.boobs');
	
}
