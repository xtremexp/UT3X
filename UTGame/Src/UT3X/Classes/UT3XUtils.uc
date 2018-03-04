/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XUtils extends Object;

static function string getPlayerKey(PlayerReplicationInfo pri)
{
	return class'OnlineSubsystem'.static.UniqueNetIdToString(pri.UniqueId);
}



static function BroadcastMsg(WorldInfo wi, string msg, optional class<LocalMessage> lm, optional PlayerController  C){
	local UT3XPC PC;

	if(wi == None){
		return;
	}
	
	foreach wi.AllControllers(class'UT3XPC', PC){
		if(C == None ||(C != None && (PC.PlayerReplicationInfo.PlayerID != C.PlayerReplicationInfo.PlayerID))){
			PC.UT3XMessage(msg, lm);
		}
	}
}

// SENDS A MESSAGE TO WEBADMIN ONLY
static function WebAdminMessage(WorldInfo wi, String message, optional bool showTimeStamp){
	local PlayerController PC;
	
	if(showTimeStamp){
		message $= "-"$TimeStamp();
	}
	foreach wi.AllControllers(class'PlayerController', PC){
		if(PC.PlayerReplicationInfo.PlayerName == "<<TeamChatProxy>>"){
			PC.TeamMessage( None, message, 'TeamSay');
			return;
		}
	}
}

static function array<PlayerController> getPlayers(String target, WorldInfo wi, optional Controller caller){

	local PlayerController PC;
	local array<PlayerController> pcArray;
	
	if(target == "all"){
		foreach wi.AllControllers(class'PlayerController', PC){
			pcArray.addItem(PC);
		}
		return pcArray;
	} else if(target == "reds"){
		foreach wi.AllControllers(class'PlayerController', PC){
			if(PC.PlayerReplicationInfo.Team.TeamIndex == 0){
				pcArray.addItem(PC);
			}
		}
		return pcArray;
	} else if(target == "blues"){
		foreach wi.AllControllers(class'PlayerController', PC){
			if(PC.PlayerReplicationInfo.Team.TeamIndex == 1){
				pcArray.addItem(PC);
			}
		}
		return pcArray;
	} else if(target == "" && caller != None){
		PC = PlayerController(caller);
		pcArray.addItem(PC);
		return pcArray;
	}
	
	PC = PlayerController(wi.Game.AccessControl.GetControllerFromString(target));
	
	if(PC != None){
		pcArray.addItem(PC);
	} else if(caller != None){
		PlayerController(caller).ClientMessage("PlayerName/ID '"$target$"' invalid");
	}
	
	return pcArray;
}


static function String arrayToString(array<String> a){
	local String s;
	local int i;
	
	for(i=0; i<a.length; i++){
		s $= a[i]$",";
	}
	return s;
}



