/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
// Changes automatically to default map if server is empty
class UT3XDefaultMap extends Info config(UT3XConfig);

var config string defaultMap; 
var config int secondsBeforeSwitch;
var config bool noSwitchIfServerPassworded;
var int lastCheck;
var int lastCheckPlayers;


event PostBeginPlay(){
	super.PostBeginPlay();
	lastCheck = int(WorldInfo.TimeSeconds);
	lastCheckPlayers = int(WorldInfo.TimeSeconds);
	
	// Every 10s checks that server is not empty if:
	// - current map is NOT the default map
	// - default map is a valid map (exists)
	if(Len(defaultMap) > 0 && WorldInfo.MapExists(defaultMap)){
		setTimer(10.0, true, 'CheckPlayers');
	} else {
		LogInternal("Default map "$defaultMap$" is not valid. Destroying DefaultMap actor ...");
		clearTimer('CheckPlayers');
		Destroy();
	}
}

reliable server function CheckPlayers(){
	lastCheck = int(WorldInfo.TimeSeconds);
	
	if(WorldInfo.Game.bGameEnded ){
		lastCheckPlayers = int(WorldInfo.TimeSeconds);
		return;
	}
	
	// Players on server or server is private (passworded)
	if(!NoPlayers() || (noSwitchIfServerPassworded && ("" != WorldInfo.Game.ConsoleCommand("get engine.accesscontrol gamepassword", false)))){
		lastCheckPlayers = int(WorldInfo.TimeSeconds);
		return;
	}

	
	if(((lastCheck - lastCheckPlayers)>secondsBeforeSwitch) && (CAPS(defaultMap) != CAPS(WorldInfo.GetMapName(true)))){
		lastCheck = 0;
		lastCheckPlayers = 0;
		
		
		UT3XAC(WorldInfo.Game.AccessControl).log.addLog(LT_MAPCHANGE, , , "No players, default map autoswitch: "$defaultMap);
		LogInternal("No players, default map autoswitch: "$defaultMap);
		UT3XAC(WorldInfo.Game.AccessControl).SaveConfigs();
		
		WorldInfo.ServerTravel(defaultMap$WorldInfo.Game.ServerOptions, true);
		clearTimer('CheckPlayers');
		
		/*
		UT3XAC(WorldInfo.Game.AccessControl).log.addLog(LT_MAPCHANGE, , , "No players. Default map AUTO-Switch: "$WorldInfo.getMapName(true));
		LogInternal("No Players. Travelling:"$defaultMap$WorldInfo.Game.ServerOptions);
		WorldInfo.ServerTravel(defaultMap$WorldInfo.Game.ServerOptions, true);
		*/
	}
}


function bool NoPlayers(){

	local UT3XPC PC;
	
	foreach WorldInfo.AllControllers(class'UT3XPC', PC){
		if(!PC.PlayerReplicationInfo.bBot){
			return false;
		}
	}
	
	return true;
}


event Tick( float DeltaTime )
{
	if (WorldInfo.NextURL != "" || WorldInfo.IsInSeamlessTravel())
	{
		Destroy();
	}
}

defaultproperties
{
	bUseAutoMapVoteList = false;
	noSwitchIfServerPassworded = true;
	lastCheck = 0;
	lastCheckPlayers = 0;
	secondsBeforeSwitch=300;
	defaultMap="VCTF-Suspense";
}
