// TODO REMOVE ALL FIELD THAT SHOULD NOT BE SEND TO OTHER PLAYERS !
/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XPlayerReplicationInfo extends UTHeroPRI;//UTPlayerReplicationInfo;

var IP2C countryInfo; // ONLY CONTAINS IP RANGE
var bool isAfk;
var bool isAnonymous;
var bool bAnonymousCountry;
var bool isRequestingAdmin; //TODO

var int playerRanking2; // duplicate of playerRanking variable but made i replicable to other clients !!

replication
{
	if (bNetDirty)
		countryInfo, isAfk, isRequestingAdmin,  playerRanking2, isAnonymous;
}


simulated event ReplicatedEvent(name VarName)
{

	if ( VarName == 'isAfk' )
	{
		//LogInternal("IS NOW AFK!!"); 
	} 
	else if (VarName == 'countryInfo'){
		//LogInternal("Country !!");
	}
	else {
		Super.ReplicatedEvent(VarName);
	}
}
