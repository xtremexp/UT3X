/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XPC extends UT3XPCABS;

exec function ListSmileys(){
	ServerListSmileys();
}

unreliable server function ServerListSmileys(){

	local int i;
	local String s;
	
	for(i=0; i<smileysList.length; i++){
		s $= "'"$smileysList[i].smileysText[0]$"',";
	}
	
	ClientMessage("Smiley List:"$s);
}

exec function Inventory GivePickupTo( String PickupClassStr, String target )
{
	if(class'UT3XLib'.static.checkIsAdmin(self)){
		return ServerGivePickup(PickupClassStr, target);
	}
}


exec function Inventory GivePickup( String PickupClassStr )
{
	if(class'UT3XLib'.static.checkIsAdmin(self)){
		return ServerGivePickup("", PickupClassStr);
	}
}

// get computer local time of player

reliable server function String getLocalTime(){

	local float computerTS;

	computerTS	= class'HttpUtil'.static.utimestamp3() + deltaTime;
	

	return class'HttpUtil'.static.timestampToClassicString(computerTS);
}

reliable server function Inventory ServerGivePickup(String target, String PickupClassStr){

	local Inventory Pickup;
	local class<Inventory> PickupClass;
	local array<PlayerController> PCS;
	local int i;

	if(target == ""){
		PCS.addItem(self);
	} else {
		PCS = class'UT3XUtils'.static.getPlayers(target, WorldInfo, self);
		if(PCS.length == 0){
			return None;
		}
	}
	
	PickupClass = class<Inventory>(DynamicLoadObject(PickupClassStr, class'Class'));
	
	if(PickupClass == None){
		ClientMessage("Pickup "$PickupClassStr$" does not exists.");
		return None;
	}
	
	
	for(i=0; i<PCS.length; i++){
		Pickup = PCS[i].Pawn.FindInventoryType(PickupClass);
		if( Pickup != None )
		{
			continue;
		}
		PCS[i].Pawn.CreateInventory(PickupClass);
	}
	return Pickup;
}

// tells who this player is spectating
exec function WhoSpec(String playername){
	if(class'UT3XLib'.static.checkIsAdmin(self, false)){
		ServerWhoSpec(playername);
	}
}

unreliable server function ServerWhoSpec(String playername){

	local PlayerController P;
	local Actor A;
	local String pname;
	
	P = PlayerController(WorldInfo.Game.AccessControl.GetControllerFromString(playername));
	
	if(P == None){
		ClientMessage("Player "$playername$" not found");
		return;
	}
	
	pname = P.PlayerReplicationInfo.PlayerName;
	
	A = P.getViewTarget();
	
	if(A == None){
		ClientMessage("Player "$pname$" is spectating nothing");
		return;
	}
	
	// Player Walking
	if(UTPawn(A) != None && PlayerController(UTPawn(A).Controller) != None){
		ClientMessage(pname$" is spectating "$PlayerController(UTPawn(A).Controller).PlayerReplicationInfo.PlayerName);
		return;
	} 
	// Player in vehicle or hoverboard
	else if(UTVehicle(A) != None && PlayerController(UTVehicle(A).Controller) != None){
		ClientMessage(pname$" is spectating "$PlayerController(UTVehicle(A).Controller).PlayerReplicationInfo.PlayerName);
		return;
	}
	// no pawn attached 
	else if(PlayerController(A) != None){
		ClientMessage(pname$" is spectating "$PlayerController(A).PlayerReplicationInfo.PlayerName);
		return;
	}
	else {
		ClientMessage(pname$" is spectating "$A);
	}
}

exec function setAnonymous(String playerTarget, optional bool noSilent){
	ServerSetAnonymous(playerTarget, noSilent);
}

reliable server function ServerSetAnonymous(String playerTarget, optional bool noSilent){
	local PlayerController P;
	local Actor A;
	
	P = PlayerController(WorldInfo.Game.AccessControl.GetControllerFromString(playerTarget));

	
	if(P == None){
		ClientMessage("Player "$playerTarget$" not found");
		return;
	}
	
	if(UT3XPC(P) != None){
		UT3XPC(P).isAnonymous = true;
		UT3XPlayerReplicationInfo(P.PlayerReplicationInfo).isAnonymous = true;
		UT3XPC(P).noLog = true;
		ClientMessage("You have granted "$P.PlayerReplicationInfo.PlayerName$" anonymous mode!");
		
		if(noSilent){
			P.ClientMessage("Anonymous mode have been granted to you by "$PlayerReplicationInfo.PlayerName);
		}
	}
}

// clear data of player from log
exec function clearDataForPlayer(String playerName){

	if(class'UT3XLib'.static.checkIsAdmin(self, true)){
		ServerClearDataForPlayer(playerName);
	}
}

reliable server function ServerClearDataForPlayer(String playerName){
	
	local UT3XLog log;
	local UT3XPlayersDB db;
	local int x, y, lineLogsDeletedCount;
	local bool found;
	
	db = UT3XAC(WorldInfo.Game.AccessControl).pdb;
	log = UT3XAC(WorldInfo.Game.AccessControl).log;
	x = db.PlayersLogs.Find('PName', playerName);
	
	if(x != 0){
		db.PlayersLogs.removeItem(db.PlayersLogs[x]);
		found = true;
		
	}
	
	y = db.PlayersLogs_Merge.Find('PName', playerName);
	if(x != 0){
		db.PlayersLogs_Merge.removeItem(db.PlayersLogs_Merge[x]);
		found = true;
	}
	
	// remove info from logs
	for(x=0; x < log.Logs.Length; x++){
		
		if(CAPS(log.Logs[x].srcPN) == CAPS(playerName) || log.Logs[x].destPN == CAPS(playerName)){
			log.Logs.removeItem(log.Logs[x]);
			lineLogsDeletedCount ++;
		}
	}
	
	if(found){
		ClientMessage(playerName$" has been removed from database and logs");
	} else {
		ClientMessage(playerName$" not found!");
	}
}


// clear data of player from log
exec function clearDataForComputer(String computerName){

	if(class'UT3XLib'.static.checkIsAdmin(self, true)){
		ServerClearDataForComputer(computerName);
	}
}

// remove all logs from player with computer name "computerName"
reliable server function ServerClearDataForComputer(String computerName){
	
	local UT3XPlayersDB db;
	local UT3XLog log;
	local int x, y;
	local string playersDeleted;
	
	db = UT3XAC(WorldInfo.Game.AccessControl).pdb;
	log = UT3XAC(WorldInfo.Game.AccessControl).log;
	
	for(x =0; x < db.PlayersLogs.length; x++){
		y = db.PlayersLogs[x].CNS.Find(computerName);
		
		if(y != -1){
			playersDeleted $= db.PlayersLogs[x].PName$",";
			db.PlayersLogs.removeItem(db.PlayersLogs[x]);
		}
	}
	
	y = 0;
	
	for(x =0; x < db.PlayersLogs_Merge.length; x++){
		y = db.PlayersLogs_Merge[x].CNS.Find(computerName);
		
		if(y != -1){
			db.PlayersLogs_Merge.removeItem(db.PlayersLogs_Merge[x]);
		}
	}
	

	if(playersDeleted != ""){
		ClientMessage(playersDeleted$" have been removed from database");
	} else {
		ClientMessage("No players with computer name "$computerName$" have been deleted");
	}
}
