/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XLagDetector extends Info config(UT3XConfig);

enum ERestartMode
{
	RM_None, // No Restart
	RM_LogFile, // Creates a log file
	RM_ServerLog // Append string in Server.log file
};

var config ERestartMode restartMode;
var config bool bAutoRestart, bAdvertisePlayersLag, bAdvertiseWebAdminLag, bAdvertisePlayersOnce;
var config int minPacketLoss, minPlayerRatioLagging, minNumLagsBeforeRestart, minNumLagsBeforeAdvertisePlayers;

var int numBadLagsCount;
var bool displayLag, hasAdvertisedPlayersLag;
var FileLog writer;
var float lagStartTime;
var float lagStopTime;
var String lagDurationStr;
var bool isLagging;
var int playerRatioLagging; // % of players lagging
var string prefix;

event PostBeginPlay(){
	super.PostBeginPlay();
	// CHECKS EVERY 15S IF THERE IS LAG
	setTimer(15.0, true, 'checkLag');
}


reliable server function checkLag(){
	local UT3XPC PC;
	local int numPlayers;
	local int numPlayersLagging;
	local int totalPacketLoss;
	local int meanPacketLoss;
	local string tmp;
	
	if (WorldInfo.Game.bGameEnded ){
		return;
	}
	
	
	foreach WorldInfo.AllControllers(class'UT3XPC', PC){
		if(PC.PlayerReplicationInfo != None && !PC.PlayerReplicationInfo.bOnlySpectator){
			numPlayers ++;
			
			if(PC.PlayerReplicationInfo.PacketLoss >= minPacketLoss){ // > 20 = some significant lag
				totalPacketLoss += PC.PlayerReplicationInfo.PacketLoss;
				numPlayersLagging ++;
			}
		}
	}
	

	
	if(numPlayersLagging > 0){
		meanPacketLoss = totalPacketLoss/numPlayersLagging;
	} else {
		meanPacketLoss = 0;
	}
	
	
	
	if(numPlayers == 0){
		playerRatioLagging = 0;
	} else {
		playerRatioLagging = int(100*(float(numPlayersLagging)/float(numPlayers)));
	}
	
	if(playerRatioLagging >= minPlayerRatioLagging){
	
		if(!isLagging){
			lagStartTime = WorldInfo.TimeSeconds;
			tmp = "STARTED";
		} else {
			tmp = "";
		}
		lagDurationStr = class'UT3XLib'.static.secondsToDateLength(int(WorldInfo.TimeSeconds-lagStartTime));
		
		
		WebAdminServerMessage("[LAG"@tmp@"]-PL:"$meanPacketLoss$", LaggingRatio:"$playerRatioLagging$"% ("$numPlayersLagging$"/"$numPlayers$") - LagDuration:"$lagDurationStr);
		
		numBadLagsCount ++;
		/*
		if(meanPacketLoss >= 100){ // VERY BAD LAG PROB CANT MOVE
			numBadLagsCount += 3;
		} else if(meanPacketLoss >= 40){ // CAN MOVE A BIT
			numBadLagsCount += 2;
		} else { // SOMETIMES CANT SHOOT
			numBadLagsCount ++;
		}*/
		
		// Advertise Players
		if(bAdvertisePlayersLag && (numBadLagsCount > minNumLagsBeforeAdvertisePlayers) ){
			//class'UT3XUtils'.static.BroadcastMsg(WorldInfo, "Server is lagging / being attacked by fake-hackers.", class'UT3XMsgOrange');
			hasAdvertisedPlayersLag = true;
		}
		
		// WE HAVE REACHED THE LIMIT OF BAD LAGS NEED TO RESTART
		if(numBadLagsCount > minNumLagsBeforeRestart){
			//WebAdminServerMessage("[Maybe server should be restarted]");
		} //else if(numBadLagsCount >0){
			//foreach WorldInfo.AllControllers(class'UT3XPC', PC){
				//PC.UT3XMessage(prefix$"Server is lagging (Mean PL:"$meanPacketLoss$", NumPlLagging:"$numPlayersLagging$"/"$numPlayers, class'UT3XMsgRed');
			//}
		//}
		isLagging = true;
	} else {
		if(isLagging){
			WebAdminServerMessage("[LAG STOPPED] after "$lagDurationStr);
			if(bAdvertisePlayersLag && numbadLagsCount == 0){
				//class'UT3XUtils'.static.BroadcastMsg(WorldInfo, "Server is NO LONGER LAGGING", class'UT3XMsgGreen');
			}
		}
		isLagging = false;
		lagStartTime = 0;
		lagDurationStr = "";
		// IF EVERYTHING OK 
		if(numbadLagsCount >=1) {numBadLagsCount --;}
	}
}

// SEND MESSAGE ONLY TO WEBADMIN SPECTATOR
reliable server function WebAdminServerMessage(String message){
	local PlayerController PC;
	
	foreach WorldInfo.AllControllers(class'PlayerController', PC){
		if(PC.PlayerReplicationInfo.PlayerName == "<<TeamChatProxy>>"){
			UT3XAC(WorldInfo.Game.AccessControl).log.addLog(LT_LAGDETECTOR, "LAG DETECTOR", , message);
			PC.TeamMessage( None, TimeStamp()$"-"$message, 'TeamSay');
			return;
		}
	}
}

reliable server function TellServerToRestart(optional PlayerController PCAdmin){
	local UT3XPC PC;
	local String msg;
	
	if(PCAdmin == None){
		msg = prefix$"Server is going to be restarted quickly due to lag issues.";
	} else {
		msg = PCAdmin.PlayerReplicationInfo.playername$" requested a SERVER RESTART.";
	}
	
	
	foreach WorldInfo.AllControllers(class'UT3XPC', PC){
		PC.UT3XMessage(msg, class'UT3XMsgRed');
	}

	// WRITES lag.txt file
	WriteLagTxtFile();
}

// RestartMode == RM_LogFile
function WriteLagTxtFile(){
	if(writer == None){
		writer = spawn(class'FileLog');
	}
	
	writer.OpenLog("lag", "txt", false);
	writer.Logf(TimeStamp()$"- Server is lagging plz restart :)");
}

reliable server function RestartServerManually(PlayerController PCAdmin){
	TellServerToRestart(PCAdmin);
}


reliable server function getLagStatus(PlayerController caller){

	local UT3XPC PC;
	local String msg;
	local int count;
	
	caller.ClientMessage("Player(Packet Loss/Ping)");
	
	foreach WorldInfo.AllControllers(class'UT3XPC', PC){
		
		if(PC.PlayerReplicationInfo != None && !PC.PlayerReplicationInfo.bBot){
			count ++;
			
			if(PC.PlayerReplicationInfo.PacketLoss >= 0){
				msg $= PC.PlayerReplicationInfo.PlayerName$"("$PC.PlayerReplicationInfo.PacketLoss$"/"$PC.PlayerReplicationInfo.Ping$"), "; 
			}
			
			if(count % 5 == 0){
				caller.ClientMessage(msg);
				msg = "";
			}
		}
	}
	
	if(count % 5 != 0){
		caller.ClientMessage(msg);
	}
}

defaultproperties
{
	restartMode = RM_None; // No Restart
	bAdvertisePlayersLag = true;
	bAdvertisePlayersOnce = true; // if false if still lagging will display the server is lagging message each 15s..
	minNumLagsBeforeAdvertisePlayers = 5;
	minNumLagsBeforeRestart = 10; // Starts at 0 then every 15s +1 or +2 o +3 depending on lag power
	minPlayerRatioLagging = 30;
	minPacketLoss = 60;
	prefix="[UT3XLagDetector]";
	netpriority=4;
}
