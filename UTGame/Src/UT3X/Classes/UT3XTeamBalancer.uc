/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XTeamBalancer extends Info config(UT3XConfig);

/*
var enum NumPlayersType
{	
	NPT_PERCENTAGE, // PERCENTAGE
	NPT_NUMBER, // NUMBER
} NPT;
*/

var enum BalanceAction
{
	BA_GIVE_FULLHP, // Give Extra HP (199)
	BA_GIVE_FULLHPANDARMOR, // Give Extra HP + armor
	BA_GIVE_BOOTS, // Give Boots
	BA_GIVE_BERSERK, // Berserk
	BA_GIVE_UDAMAGE, // UDamage
	BA_GIVE_VH_RAPTOR, // Give Raptor
	BA_GIVE_VH_VIPER, // Give Viper
	BA_GIVE_INVISIBILITY, // Invisibility
	BA_GIVE_WP_DEEMER, // Give Deemer Weapon
	BA_GIVE_VH_TANK, // Give Tank
	BA_GIVE_VH_LEVIATHAN, // Give Leviathan
	BA_GIVE_INVULNERABILITY, // Invulnerability
	BA_GIVE_WP_INSTAGIB, // Give Weapon Instagib
	BA_MAKETITAN, // Make Player Titan
	BA_MAKESUPERTITAN // Make Player Super Titan
} BA;

struct ScoreDiffAction
{
	var int minScoreDiff; // Min Score Difference
	var int maxScoreDiff;
	var int minTotalPlayers; // Optional, apply the actions if at least X players in server
	var int maxTotalPlayers;
	//var NumPlayersType numPlayersBoostedType;
	var int numPlayersBoosted; // How many players should get the extra boost
	
	var array<BalanceAction> balanceActions; // Which actions to do if MinScoreDiff <= ScoreDiff <= MaxScoreDiff
	
	structdefaultproperties
	{
		minScoreDiff = 1; // >= 1
		maxScoreDiff = 999;
		numPlayersBoosted= 1;
		maxTotalPlayers = 64;
	}
};


// Defaut 1 (means if red=2 and blue=3, red player can't switch to blue)
var config int maxScoreDiffToSwitchToWinningTeam;
var config bool allowSwitchToWinningTeam;
var config array<ScoreDiffAction> scoreDiffActions;

var int timerCount;

function String addScoreDiffAction(int minScoreDiff, int maxScoreDiff, int minTotalPlayers, int maxTotalPlayers, int numPlayersBoosted, array<String> balanceActionsStr){

	local ScoreDiffAction SDA;
	local String t;
	
	SDA.minScoreDiff = minScoreDiff;
	SDA.maxScoreDiff = maxScoreDiff;
	SDA.minTotalPlayers = minTotalPlayers;
	SDA.maxTotalPlayers = maxTotalPlayers;
	SDA.numPlayersBoosted = numPlayersBoosted;
	SDA.BalanceActions = toBalanceAction(balanceActionsStr);
	
	t = isValidScoreDiffAction(SDA);
	
	if(t == ""){
		ScoreDiffActions.addItem(SDA);
		SaveConfig();
	}
	
	return t;
}

function array<BalanceAction> toBalanceAction(array<String> balanceActionsStr){
	local array<BalanceAction> balanceActions;
	local int i;
	
	for(i=0; i<balanceActionsStr.length; i++){
		if(balanceActionsStr[i] == "BA_GIVE_WP_INSTAGIB") balanceActions.addItem(BA_GIVE_WP_INSTAGIB);
		if(balanceActionsStr[i] == "BA_GIVE_WP_DEEMER") balanceActions.addItem(BA_GIVE_WP_DEEMER);
		if(balanceActionsStr[i] == "BA_GIVE_BOOTS") balanceActions.addItem(BA_GIVE_BOOTS);
		if(balanceActionsStr[i] == "BA_GIVE_FULLHP") balanceActions.addItem(BA_GIVE_FULLHP);
		if(balanceActionsStr[i] == "BA_GIVE_FULLHPANDARMOR") balanceActions.addItem(BA_GIVE_FULLHPANDARMOR);
		//if(balanceActionsStr[i] == "BA_MAKETITAN") balanceActions.addItem(BA_MAKETITAN);
		//if(balanceActionsStr[i] == "BA_MAKESUPERTITAN") balanceActions.addItem(BA_MAKESUPERTITAN);
		if(balanceActionsStr[i] == "BA_GIVE_VH_LEVIATHAN") balanceActions.addItem(BA_GIVE_VH_LEVIATHAN);
		if(balanceActionsStr[i] == "BA_GIVE_VH_RAPTOR") balanceActions.addItem(BA_GIVE_VH_RAPTOR);
		if(balanceActionsStr[i] == "BA_GIVE_VH_VIPER") balanceActions.addItem(BA_GIVE_VH_VIPER);
		if(balanceActionsStr[i] == "BA_GIVE_BERSERK") balanceActions.addItem(BA_GIVE_BERSERK);
		if(balanceActionsStr[i] == "BA_GIVE_UDAMAGE") balanceActions.addItem(BA_GIVE_UDAMAGE);
		if(balanceActionsStr[i] == "BA_GIVE_INVISIBILITY") balanceActions.addItem(BA_GIVE_INVISIBILITY);
		if(balanceActionsStr[i] == "BA_GIVE_VH_TANK") balanceActions.addItem(BA_GIVE_VH_TANK);
		if(balanceActionsStr[i] == "BA_GIVE_INVULNERABILITY") balanceActions.addItem(BA_GIVE_INVULNERABILITY);
	}
	
	return balanceActions;
}

function String isValidScoreDiffAction(ScoreDiffAction SDA){

	if(SDA.minScoreDiff <= 0){
		return "Min Score Diff must be greater than 0";
	}
	
	if(SDA.maxScoreDiff <= 0){
		return "Max Score Diff must be greater than 0";
	}
	
	if(SDA.maxScoreDiff < SDA.minScoreDiff){
		return 	"Min Score Diff must be lower than Max Score Diff";
	}
	
	if(SDA.minTotalPlayers < 1){
		return 	"minTotalPlayers must be greater than 0";
	}
	
	if(SDA.minTotalPlayers > SDA.maxTotalPlayers){
		return 	"maxTotalPlayers must be lower than minTotalPlayers";
	}
	
	if(SDA.numPlayersBoosted <= 0){
		return "Num players boosted must be greater than 0";
	}
	
	if(SDA.balanceActions.length == 0){
		return "You must select a balance action!";
	}
	
	return "";
}

unreliable server function String ExecuteBalanceAction(BalanceAction baa, array<UTPlayerController> playersBoosted){
	
	local int i;
	local UT3XPlayerReplicationInfo PRI;
	local String t;
	local Inventory inv;
	local bool playerBoosted;
	local bool hasGivenVehicle;
	
	

	
	if(playersBoosted.length == 0){
		return "";
	}
	

	
	for(i=0; i<playersBoosted.length; i++){
		playerBoosted = false;
		inv = None;
		if(baa == BA_GIVE_WP_INSTAGIB){
			inv = ServerGivePickup(playersBoosted[i], "UTGame.UTWeap_InstagibRifle");
		} 
		else if(baa == BA_GIVE_WP_DEEMER){
			inv = ServerGivePickup(playersBoosted[i], "UTGameContent.UTWeap_Redeemer_Content");
		} 
		else if(baa == BA_GIVE_BOOTS){
			inv = ServerGivePickup(playersBoosted[i], "UTGameContent.UTJumpBoots");
		}
		else if(baa == BA_GIVE_BERSERK){
			inv = ServerGivePickup(playersBoosted[i], "UTGameContent.UTBerserk");
		}
		else if(baa == BA_GIVE_UDAMAGE){
			inv = ServerGivePickup(playersBoosted[i], "UTGameContent.UTUDamage");
		}
		else if(baa == BA_GIVE_INVISIBILITY){
			inv = ServerGivePickup(playersBoosted[i], "UTGameContent.UTInvisibility");
		}
		else if(baa == BA_GIVE_INVULNERABILITY){
			inv = ServerGivePickup(playersBoosted[i], "UTGameContent.UTInvulnerability");
		}
		else if(baa == BA_GIVE_FULLHP){
			playerBoosted = ( playerBoosted || MakeSuperPlayer(playersBoosted[i], false));
		} 
		else if(baa == BA_GIVE_FULLHPANDARMOR){
			playerBoosted = ( playerBoosted || MakeSuperPlayer(playersBoosted[i], true));
		} 
		else if(baa == BA_GIVE_VH_LEVIATHAN && !hasGivenVehicle){
			//TODO
		} 
		else if(baa == BA_GIVE_VH_RAPTOR && !hasGivenVehicle){
			//TODO
		} 
		else if(baa == BA_GIVE_VH_VIPER){
			//TODO
		}
		else if(baa == BA_GIVE_VH_TANK && !hasGivenVehicle){
			//TODO
			hasGivenVehicle = true;
		}

		if(inv != None){
			playerBoosted = true;
		}
		
		if(playerBoosted){
			if(inv != None){
				t $= inv.ItemName$",";
			}
		}
	}
	
	return t;
}

// CHECK IF TEAM HAS A TITAN OR SUPERTITAN ACTIVE
function bool bTeamHasTitanPlayer(int numTeam){

	local array<UTPlayerController> redPlayers;
	local array<UTPlayerController> bluePlayers;
	local int i;
	
	getPlayersCounts(RedPlayers, BluePlayers);
	if(numTeam == 0){
		for(i=0; i<redPlayers.length; i++){
			if(redPlayers[i].Pawn == None){
				continue;
			}
			if(UTHeroPawn(redPlayers[i].Pawn) != None && (UTHeroPawn(redPlayers[i].Pawn).bIsHero || UTHeroPawn(redPlayers[i].Pawn).bIsHero)){
				return true;
			}
		}
	} else if(numTeam == 0){
		for(i=0; i<bluePlayers.length; i++){
			if(bluePlayers[i].Pawn == None){
				continue;
			}
			if(UTHeroPawn(bluePlayers[i].Pawn) != None && (UTHeroPawn(bluePlayers[i].Pawn).bIsHero || UTHeroPawn(bluePlayers[i].Pawn).bIsHero)){
				return true;
			}
		}
	}
	return false;
}

unreliable server function ExecuteScoreDiffAction(ScoreDiffAction SDA, array<UTPlayerController> RedPlayers, array<UTPlayerController> BluePlayers, int numTeamLosing){

	local int numBA;
	local array<UTPlayerController> losingPlayers;
	local array<UTPlayerController> boostedPlayers;
	local UT3XPC PC;
	local String t;
	
	
	if(numTeamLosing == -1 || SDA.numPlayersBoosted <= 0){
		return;
	}
	
	if(numTeamLosing == 0){
		losingPlayers = redPlayers;
	} else {
		losingPlayers = bluePlayers;
	}
	
	if(losingPlayers.length == 0){
		return;
	}

	boostedPlayers = getRandomPlayers(losingPlayers,  Min(losingPlayers.length, SDA.numPlayersBoosted));
	
	for(numBA = 0; numBA < SDA.balanceActions.length; numBA ++){
		t $= ExecuteBalanceAction(SDA.balanceActions[numBA], boostedPlayers);
	}
	
	if(t != ""){
		foreach WorldInfo.AllControllers(class'UT3XPC', PC)
		{
			PC.UT3XMessage("[Balancer Boost]-"$t, class'UT3XMsgOcean');
		}
	}
}

function MatchStarting()
{
	if(UTTeamGame(WorldInfo.Game) != None){
		RandomizeTeams();
	}
}

event PostBeginPlay(){
	super.PostBeginPlay();

	// CHECKS EVERY 30S IF TEAMS ARE UNBALANCED
	if(UTTeamGame(WorldInfo.Game) != None){
		setTimer(30.0, true, 'BalanceTeams');
	}
}

reliable server function RandomizeTeams(){

	local UTPlayerController PC;
	local int numPlayers, numRedPlayers, numBluePlayers, i;
	local array<UTPlayerController> playersList;
	local UTPlayerController UPC;
	local bool hasRandomized;
	
	foreach WorldInfo.AllControllers(class'UTPlayerController', PC)
	{
		if(DemoRecSpectator(PC) == None && PC.PlayerReplicationInfo != none && !PC.PlayerReplicationInfo.bOnlySpectator){
			playersList.addItem(PC);
			numPlayers ++;
		}
	}

	if(numPlayers == 0 ){
		return;
	}
	
	// IF ONLY 1 PLAYER numRed = 1/2 = 0.5 Rounded to 1 = NumRedPlayers
	numRedPlayers = numPlayers/2;
	numBluePlayers = Max((numPlayers - numRedPlayers), 0);
	
	//LogInternal("RANDOMIZER NumBlue:"@numBluePlayers$" NumRed:"$numRedPlayers$" Total:"$playersList.length);
	
	// BUILDING RED TEAM
	for(i = 0; i < numRedPlayers; i++){
		UPC = getRandomPlayer(playersList, false, false);
		TTFChangeTeam(UPC, 0);
		hasRandomized = true;
		playersList.removeItem(UPC);
	}
	
	// BUILDING BLUE TEAM
	for(i = 0; i < numBluePlayers; i++){
		UPC = getRandomPlayer(playersList, false, false);
		TTFChangeTeam(UPC, 1);
		hasRandomized = true;
		playersList.removeItem(UPC);
	}
	
	if(hasRandomized){
		foreach WorldInfo.AllControllers(class'UTPlayerController', PC){
			PC.ClientMessage(tag$"- The teams have been RANDOMIZED.");
		}
	}
}

function NotifyPlayerCountChange(){
	
	// If players want to take screenshot of scoreboard
	// then do not switch players at the end of game ..
	if(WorldInfo.Game.bGameEnded ||  !UTTeamGame(WorldInfo.Game).bPlayersBalanceTeams){
		return;
	}
}

function bool bTeamsAreNotBalanced(){
	local array<UTPlayerController> RedPlayers, BluePlayers;
	
	getPlayersCounts(RedPlayers, BluePlayers);
	return (Abs(RedPlayers.length - BluePlayers.length)) > 1;
}

reliable server function BalanceTeams(){
	
	local array<UTPlayerController> RedPlayers, BluePlayers;
	local UTTeamGame uttg;
	local int ScoreDiff, RedScore, BlueScore, numTeamLosing;
	

	// If players want to take screenshot of scoreboard
	// then do not switch players at the end of game ..
	if(WorldInfo.Game.bGameEnded ||  !UTTeamGame(WorldInfo.Game).bPlayersBalanceTeams){
		return;
	}
	
	uttg = UTTeamGame(WorldInfo.Game);
	
	if(uttg == None){
		return;
	}
	
	RedScore = uttg.Teams[0].score;
	BlueScore = uttg.Teams[1].score;
	
	if(BlueScore < RedScore){
		numTeamLosing = 1;
	} else if(RedScore < BlueScore){
		numTeamLosing = 0;
	} else {
		numTeamLosing = -1;
	}
	getPlayersCounts(RedPlayers, BluePlayers);
	
	if(RedPlayers.length == 0 && BluePlayers.length == 0){
		return;
	}

	ScoreDiff = Abs(RedScore-BlueScore);
	
	// Player Count Balance
	// @TODO TeamSizeDiff = 1
	if(Abs(RedPlayers.length - BluePlayers.length) > 1 ){
		PlayerCountBalance(RedPlayers, BluePlayers);
	} 
	
	// Score Count Balance every 30 * 4 = 2 minutes
	if(timerCount % 4 == 0){ 
		ScoreDiffBalance(ScoreDiff, RedPlayers, BluePlayers, numTeamLosing);
	}
	
	timerCount ++;
}


// GIVE EXTRA BOOST IF TEAMS BY COUNT ARE BALANCED BUT NOT BY SCORE
reliable server function ScoreDiffBalance(int ScoreDiff, array<UTPlayerController> RedPlayers, array<UTPlayerController> BluePlayers, int numTeamLosing){

	local int i, numTotalPlayers;
	local ScoreDiffAction SDA;
	
	numTotalPlayers = RedPlayers.length + BluePlayers.length;
	
	
	for(i=0; i<scoreDiffActions.length; i++){
		SDA = scoreDiffActions[i];
		
		// CHECK IF THE SCOREDIFF ACTION CAN BE APPLIED
		if(SDA.minScoreDiff <= scoreDiff 
			&& scoreDiff <= SDA.maxScoreDiff 
			&& numTotalPlayers >= SDA.minTotalPlayers 
			&& numTotalPlayers <= SDA.maxTotalPlayers 
			&& 0 < SDA.numPlayersBoosted){
			ExecuteScoreDiffAction(SDA, RedPlayers, BluePlayers, numTeamLosing);
		}
	}
}




// SET HEALTH TO 199 + FULL ARMOR
reliable server function bool MakeSuperPlayer(PlayerController PC, bool bFullArmor){

	local Vehicle V;
	local UTPawn UTP;
	
	if(PC == None || PC.Pawn == None){
		return false;
	}
	
	if(Vehicle(PC.Pawn) == None){ // PLAYER NOT IN A VEHICLE
		PC.Pawn.Health = 199;
		
		if(UTPawn(PC.Pawn) != None){ 
			UTP = UTPawn(PC.Pawn);
		}
	} else { // PLAYER IN A VEHICLE
		V = Vehicle(PC.Pawn);
		V.Driver.Health = 199;
		
		if(UTPawn(V.Driver) != None){
			UTP = UTPawn(V.Driver);
		}
	}
	
	// FULL ARMOR
	if(UTP != None && bFullArmor){
		UTP.ShieldBeltArmor = 100;
		UTP.HelmetArmor = 20;
		UTP.VestArmor = 50;
		UTP.ThighpadArmor = 30;
		if (UTP.GetOverlayMaterial() == None) // ADDS SHIELDBELT EFFECT MATERIAL
		{
			UTP.SetOverlayMaterial(UTP.GetShieldMaterialInstance(WorldInfo.Game.bTeamGame));
		}
	}
	return true;
}


function array<UTPlayerController> getRandomPlayers(array<UTPlayerController> Players,  int numPlayers){

	local UTPlayerController player, playerWithoutFlag;
	local array<UTPlayerController> randomPlayers;
	local int i, maxTries;
	local bool add;
	
	maxTries = 64;
	
	if(Players.length == 0){
		return randomPlayers;
	}
	if(numPlayers > Players.length){
		numPlayers = Players.length;
	}

	for(i=0; i<numPlayers; i++){
		add = false;
		player = Players[Rand(Players.length)];
		
		// player not carrying flag ok for switch
		if(!player.PlayerReplicationInfo.bHasFlag){
			playerWithoutFlag = player;
			add = true;
		}
		
		// if player has never been switched automatically then we can switch it
		if(UT3XPC(player) != None && UT3XPC(player).wasAutoTeamSwitched){
			add = false;
		}
		
		if(add){
			randomPlayers.addItem(player);
			Players.removeItem(player);
		} else {
			numPlayers ++;
		}
		
		if(i>maxTries){ // avoid a loop
			return randomPlayers;
		}
	}
	
	// in case we found nobody  we take the one who was ever switched ...
	if(numPlayers > 0 && randomPlayers.length == 0 && playerWithoutFlag != None){
		randomPlayers.addItem(playerWithoutFlag);
	}
	return randomPlayers;
}

reliable server function UTPlayerController getRandomPlayer(array<UTPlayerController> Players, bool bNotCarryingFlag, bool bNotAfk){
	
	local UTPlayerController player;
	local UT3XPC ut3xpc;
	local int i;
	
	if(Players.length == 0){
		return None;
	}
	
	if(bNotCarryingFlag || bNotAfk){
		for(i=0; i<16; i++){
			player = Players[Rand(Players.length)];
			if(bNotAfk){
				ut3xpc = UT3XPC(player);
				if(!ut3xpc.PlayerReplicationInfo.bHasFlag  // no switch of flag carriers
					&& (!UT3XPlayerReplicationInfo(ut3xpc.PlayerReplicationInfo).isAfk || i == 15) // no switch of afk players unless no other choice
						&& (!ut3xpc.wasAutoTeamSwitched || i == 15)){ // no switch of player ever switched unless no other choice
					return ut3xpc;
				}
			} else {
				if(!player.PlayerReplicationInfo.bHasFlag){
					return player;
				}
			}
		}
	} else {
		return Players[Rand(Players.length)];
	}
	
	return None;
}

reliable server function Inventory ServerGivePickup(UTPlayerController PC, String PickupClassStr){

	local Inventory Pickup;
	local class<Inventory> PickupClass;

	PickupClass = class<Inventory>(DynamicLoadObject(PickupClassStr, class'Class'));
	if(Vehicle(PC.Pawn) != None){
		Pickup = Vehicle(PC.Pawn).Driver.FindInventoryType(PickupClass);
	} else {
		Pickup = PC.Pawn.FindInventoryType(PickupClass);
	}
	
	if( Pickup != None )
	{
		return Pickup;
	}
	return PC.Pawn.CreateInventory(PickupClass);
}


// GET BEST PLAYER  (WITH BEST SCORE)
function UTPlayerController getBestPlayer(array<UTPlayerController> Players){

	local int bestScore;
	local int Idx;
	local UTPlayerController bestPlayer;
	
	bestScore = -99999999;
	
	for(Idx=0; Idx < Players.length; Idx ++){
		if(!Players[Idx].PlayerReplicationInfo.bHasFlag &&  Players[Idx].PlayerReplicationInfo.score > bestScore){
			bestPlayer = Players[Idx];
			bestScore = Players[Idx].PlayerReplicationInfo.score;
		}
	}
	
	return bestPlayer;
}


// GET WORST PLAYER  (WITH LOWEST SCORE)
function UTPlayerController getWorstPlayer(array<UTPlayerController> Players){

	local int worstScorePerHour;
	local int scorePerHour;
	local int Idx;
	local UTPlayerController WorstPlayer;
	
	worstScorePerHour = 99999999;
	
	for(Idx=0; Idx < Players.length; Idx ++){
	
		scorePerHour = 3600 * (Players[Idx].PlayerReplicationInfo.score / (WorldInfo.GRI.ElapsedTime - Players[Idx].PlayerReplicationInfo.StartTime));
		
		if(!Players[Idx].PlayerReplicationInfo.bHasFlag &&  scorePerHour < worstScorePerHour){
			WorstPlayer = Players[Idx];
			worstScorePerHour = scorePerHour;
		}
	}
	
	return WorstPlayer;
}

function UTPlayerController getPlayerToBeSwitched(array<UTPlayerController> RedPlayers, array<UTPlayerController> BluePlayers, out String mode){
	
	local UTTeamGame uttg;
	local int redScore;
	local int blueScore;
	
	uttg = UTTeamGame(WorldInfo.Game);
	if(uttg == None){
		return None;
	}
	
	// SERVER EMPTY OR 1 PLAYER IN EACH TEAM OR ONLY 1 PLAYER IN SERVER
	// -> WE DON'T SWITCH
	//LogInternal("NumReds"@RedPlayers.length@"NumBlues:"@BluePlayers.length);
	if(Abs(RedPlayers.length - BluePlayers.length) <= 1){
		// NO SWITCH NUMPLAYERS: 0VS1 OR 1VS0 OR 2VS1 OR 1VS2 )
		if(RedPlayers.length == 0 || RedPlayers.length == 1 || BluePlayers.length == 0 || BluePlayers.length == 1){
			return None;
		}
	}
	
	redScore = uttg.Teams[0].score;
	blueScore = uttg.Teams[1].score;

	// One player of difference in team size
	if(Abs(RedPlayers.length-BluePlayers.length) == 1){
		// If score not so much different then no need to balance
		// E.g.: Score: 2-1(Red-Blue) and 6 Red vs 5 Blue
		if(Abs(redScore-blueScore) < 2){
			return None;
		} 
		// More players on losing team (no need to balance)
		else if((redScore > blueScore) && (BluePlayers.length > RedPlayers.length)) {
			return None;
		}
		else if((blueScore > redScore) && (RedPlayers.length > BluePlayers.length)) {
			return None;
		}
	}
	
	// MORE PLAYERS ON RED TEAM
	if(RedPlayers.length > BluePlayers.length){
		if(redScore > blueScore){
			mode = "[Random Player]";
			return getRandomPlayer(RedPlayers, true, false);
			//return getBestRandomTop3(RedPlayers); // @TODO RAMDOM TOP 3
		} else if (redScore < blueScore){
			mode = "[Worst Player]";
			return getWorstPlayer(RedPlayers);
		} else{ // EQUALS SCORES
			mode = "[Random Player]";
			return getRandomPlayer(RedPlayers, true, false);
		}
	// MORE BLUE
	} else {
		if(blueScore > redScore){
			mode = "[Random Player]";
			return getRandomPlayer(BluePlayers, true, false);
			//return getBestRandomTop3(BluePlayers); // @TODO RAMDOM TOP 3
		} else if(blueScore < redScore){
			mode = "[Worst Player]";
			return getWorstPlayer(BluePlayers);
		} else{ // EQUALS SCORES
			mode = "[Random Player]";
			return getRandomPlayer(BluePlayers, true, false);
		}
	}
}


function PlayerCountBalance(out array<UTPlayerController> RedPlayers, out array<UTPlayerController> BluePlayers){

	local PlayerController playerSwitched;
	local PlayerController PCBC;
	local String playerSwitchedMsg;
	local int newTeam;
	local String mode;
	
	
	playerSwitched = getPlayerToBeSwitched(RedPlayers, BluePlayers, mode);
	
	if(playerSwitched == None){
		return;
	}
	
	// a player that have been switched by balancer can switch to any team
	if(UT3XPC(playerSwitched) != None){
		UT3XPC(playerSwitched).allowSwitchToWinningTeam = true;
		UT3XPC(playerSwitched).wasAutoTeamSwitched = true;
	}
	
	playerSwitchedMsg = mode$" "$playerSwitched.PlayerReplicationInfo.PlayerName;
	
	if(playerSwitched.PlayerReplicationInfo.Team.TeamIndex == 0){
		newTeam = 1; // BLUE
		playerSwitchedMsg $= " was switched to BLUE";
	} else {
		newTeam = 0; // RED
		playerSwitchedMsg $= " was switched to RED";
	}
	TTFChangeTeam(playerSwitched, newTeam);
	playerSwitched.suicide();
	
	foreach WorldInfo.AllControllers(class'PlayerController', PCBC){
		PCBC.ClientMessage(tag$"-"$playerSwitchedMsg);
	}
}

// GET SMALLEST TEAM
// @return added +10 since default value of int is 0 (=red)
function int getSmallestTeam(){
	local array<UTPlayerController> blues;
	local array<UTPlayerController> reds;
	
	getPlayersCounts(reds, blues);
	
	if(blues.length < reds.length){
		return 11;
	} else if(reds.length < blues.length){
		return 10;
	} else {
		return 0;
	}
}

// @TODO CHECK NOT SURE IT WORKS GOODS WHEN MATCH HASN'T STARTED
function getPlayersCounts(out array<UTPlayerController> RedPlayers, out array<UTPlayerController> BluePlayers){

	local UTPlayerController PC;
	
	foreach WorldInfo.AllControllers(class'UTPlayerController', PC)
	{
		if ( (DemoRecSpectator(PC) == None) && (PC.PlayerReplicationInfo != None) && (PC.PlayerReplicationInfo.Team != None) )
		{
			if ( PC.PlayerReplicationInfo.Team.TeamIndex == 0 )
				RedPlayers[RedPlayers.Length] = PC;
			else if ( PC.PlayerReplicationInfo.Team.TeamIndex == 1 )
				BluePlayers[BluePlayers.Length] = PC;
		}
	}
}

// Code Taken/Modified from TitanTeamFix Mutator
// by John "Shambler" Barrett (http://ut2004.titaninternet.co.uk/)
// Adjusts incoming players preferred team = losing team
function PlayerJoiningGame(out string Portal, out string Options)
{
	local int ScoreDiff, newTeam, i, j, smallestTeam;
	local string NewOpt;
	local GameReplicationInfo GRI;
	
	smallestTeam = getSmallestTeam();
	// Adjust the players preferred team, if appropriate
	if (GRI == none)
		GRI = WorldInfo.Game.GameReplicationInfo;

	// First determine the losing team
	ScoreDiff = GRI.Teams[0].Score - GRI.Teams[1].Score; // (RedScore - BlueScore)

	if (ScoreDiff < 0){ // RED LOSING - RedScore < BlueScore
		newTeam = 0;
	} else if (ScoreDiff > 0) { // BLUE LOSING
		newTeam = 1;
	} else { // TIED
		if(smallestTeam == 0){ // SAME SIZE OF TEAMS
			//ScoreDiff = getWeakestTeam(); // Disabled might be laggy
			newTeam = getWeakestTeamByRank(); // join team with lowest rank
		}
		// Join the team with the least players 
		else if(smallestTeam == 10){
			newTeam = 0;
		} else if(smallestTeam == 11){
			newTeam = 1; // New Team = Blue
		}
	}
	
	// Apply the selected team to the preffered team parameter
	i = InStr(Caps(Options), "?TEAM=");
	//LogInternal("Old Team:"@i@" New Team:"@newTeam);
	NewOpt = Mid(Options, i+1);
	j = InStr(NewOpt, "?");

	if (j != -1)
		NewOpt = Left(Options, i)$"?Team="$newTeam$Mid(NewOpt, j);
	else
		NewOpt = Left(Options, i)$"?Team="$newTeam;

	Options = NewOpt;
}

function int getWeakestTeamByRank(){

	local int i;
	local int totalRankBlue, totalRankRed;
	local array<UTPlayerController> blues;
	local array<UTPlayerController> reds;
	
	
	getPlayersCounts(reds, blues);
	
	for(i=0; i<reds.length; i++){
		totalRankRed += reds[i].PlayerReplicationInfo.PlayerRanking;
	}
	
	for(i=0; i<blues.length; i++){
		totalRankBlue += blues[i].PlayerReplicationInfo.PlayerRanking;
	}

	if(totalRankRed > totalRankBlue){
		return 1;
	} else {
		return 0;
	}
}

// Code Taken/Modified from TitanTeamFix Mutator
// by John "Shambler" Barrett (http://ut2004.titaninternet.co.uk/)
// ===== Cannibalized versions of team-changing functions defined in gameinfo and its subclasses
function TTFChangeTeam(Controller Other, int num)
{
	local PlayerController PC;
	local UTOnslaughtGame OG;
	local UTOnslaughtPRI PRI;
	local UTPlayerReplicationInfo DefPRI;
	local int i, OldScore, OldDeaths, OldLives, OldSpree;
	local bool bOldOutOfLives;

	TTFSetTeam(Other, UTTeamGame(WorldInfo.Game).Teams[num]);

	OG = UTOnslaughtGame(WorldInfo.Game);

	if (OG != none)
	{
		foreach LocalPlayerControllers(Class'PlayerController', PC)
		{
			if (Other == PC)
				for (i=0; i<OG.PowerNodes.Length; ++i)
					OG.PowerNodes[i].UpdateEffects(False);

			break;
		}


		PRI = UTOnslaughtPRI(Other.PlayerReplicationInfo);

		if (PRI != none)
		{
			PRI.StartObjective = None;
			PRI.TemporaryStartObjective = None;
		}
	}


	if (Other.Pawn != none)
	{
		DefPRI = UTPlayerReplicationInfo(Other.PlayerReplicationInfo);

		OldScore =		DefPRI.Score;
		OldDeaths =		DefPRI.Deaths;
		OldLives =		DefPRI.NumLives;	// dunno if this might cause bugs...but it's no worse than leaving it out altogether
		bOldOutOfLives =	DefPRI.bOutOfLives;	// ^^
		OldSpree =		DefPRI.Spree;

		Other.Pawn.PlayerChangedTeam();

		DefPRI.Score =		OldScore;
		DefPRI.Deaths =		OldDeaths;
		DefPRI.NumLives =	OldLives;
		DefPRI.bOutOfLives =	bOldOutOfLives;
		DefPRI.Spree =		OldSpree;	
	}
}

// Code Taken/Modified from TitanTeamFix Mutator
// by John "Shambler" Barrett (http://ut2004.titaninternet.co.uk/)
function TTFSetTeam(Controller Other, UTTeamInfo NewTeam)
{
	local UTPlayerReplicationInfo PRI;
	local actor A;

	if (Other.PlayerReplicationInfo == none)
		return;

	if (Other.PlayerReplicationInfo.Team != none || !WorldInfo.Game.ShouldSpawnAtStartSpot(Other))
		Other.StartSpot = None;


	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		PRI = UTPlayerReplicationInfo(Other.PlayerReplicationInfo);

		if (PRI != none && !PRI.IsLocalPlayerPRI())
			PRI.SetCharacterMesh(None);
	}

	if (Other.PlayerReplicationInfo.Team != none)
	{
		Other.PlayerReplicationInfo.Team.RemoveFromTeam(Other);
		Other.PlayerReplicationInfo.Team = none;
	}

	if (NewTeam != none)
		NewTeam.AddToTeam(Other);


	if (PlayerController(Other) != none && LocalPlayer(PlayerController(Other).Player) != none)
		foreach AllActors(Class'Actor', A)
			A.NotifyLocalPlayerTeamReceived();

	if (WorldInfo.NetMode != NM_DedicatedServer && PRI != none && UTGameReplicationInfo(WorldInfo.GRI) != none)
		UTGameReplicationInfo(WorldInfo.GRI).ProcessCharacterData(PRI, True);
}

function int getWeakestTeam(){
	local array<UTPlayerController> blues;
	local array<UTPlayerController> reds;
	
	local int redForceScore;
	local int blueForceScore;
	
	getPlayersCounts(reds, blues);
	
	redForceScore = getTeamForceScore(reds);
	blueForceScore = getTeamForceScore(blues);
	
	if(redForceScore > blueForceScore){
		return 1;
	} else {
		return 0;
	}
}

function int getRedTeamForceScore(){

	local array<UTPlayerController> blues;
	local array<UTPlayerController> reds;
	

	getPlayersCounts(reds, blues);
	
	return getTeamForceScore(reds);
}

function int getTeamForceScore(array<UTPlayerController> players){

	local int i;
	local int totalScore;
	
	for(i=0; i<players.length; i++){
		totalScore += getPlayerForceScore(players[i]);
	}
	
	return totalScore;
}


// Depends on rank, ping and packet loss
// A player with high rank (good) might not be good if high ping
// Formula
// Player Skill Score = 
function int getPlayerForceScore(UTPlayerController PC){

	local int plScore;
	local int rankScore;
	local int pingScore;
	local int killScore;

	// AFK Player is useless so gets a score of zero
	if(UT3XPlayerReplicationInfo(PC.PlayerReplicationInfo) != None && UT3XPlayerReplicationInfo(PC.PlayerReplicationInfo).isAFK){
		return 0;
	}
	
	pingScore = getPingScore(4*PC.PlayerReplicationInfo.PlayerRanking); // Above 250ms ping get 0 points
	rankScore = getRankScore(PC.PlayerReplicationInfo.PlayerRanking); // With rank 3800 get 1 point
	plScore	= getPacketLossScore(PC.PlayerReplicationInfo.PacketLoss); // Above 60 gets 0 score, 0 packet loss give 1 point
	killScore = getKillsScore(getKillsPerHour(PC)); // Above 200 KPH get 1 point
	
	// Max Score 100%
	return (pingScore*plScore)*((2*rankScore + killScore)/3); // rank score is more relevent than killScore
}

function int getKillsPerHour(PlayerController PC){
	return 3600 * (PC.PlayerReplicationInfo.score / (WorldInfo.GRI.ElapsedTime - PC.PlayerReplicationInfo.StartTime));
}

// around 200 kills per hour = very good
function int getKillsScore(int killsPerHour){
	return Min(200, killsPerHour) / 200;
}

// max rank around 3800
function int getRankScore(int rank){
	return (Min(3800,rank) / 3800);
}

// PL Above 80 nearly unplayable
function int getPacketLossScore(int packetLoss){
	return (1 - Min(80, packetLoss) / 60);
}

// Ping above 250 nearly unplayable
function int getPingScore(int ping){
	return  (1 - Min(250, ping) / 250);
}

defaultproperties
{
	maxScoreDiffToSwitchToWinningTeam = 1;
	allowSwitchToWinningTeam = true;
	tag="[UT3XBalancer]";
}
