/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XAFKChecker extends Info config(UT3XConfig);


// If true then if player on winning team, then player won't be kicked for idling
var config int AFKWarningSeconds;
var config int AFKForceSpecSeconds;
var config int AFKMinPlayers; //If number of current players is above this value then allows AFK check
var config int AFKKickSeconds;
var config int maxAFKTimeLoginSeconds;
// if enough free spec slots then don't do afk kick
var config int minFreeSpecSlotAFKCheck;
//var config int maxAfkTotalTime; 
var config string AFKMsgPrefix;
var config bool noAFKKickIfOnWinningTeam;

defaultproperties
{
	noAFKKickIfOnWinningTeam = false;
	minFreeSpecSlotAFKCheck = 1; //
	AFKMsgPrefix="[UT3X-AFKChecker]";
	AFKWarningSeconds=60; //1 Minute
	AFKForceSpecSeconds=240; //4 Minute
	AFKKickSeconds=240; //10 Minutes
	AFKMinPlayers=10;
	maxAFKTimeLoginSeconds = 60; // 60 seconds
}
