/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XPlayersDB extends Info Config(UT3XPlayersDB);



var config array<UT3XPlayerInfo> PlayersLogs;

// USE TO MERGE PLAYERS DB
// E.G: Integrate Suspense PlayersDb to this one.
// Need to get the UTUT3XPlayersDB.ini file from suspense server
// then modifiy lines which begin with "PlayerLogs"
// and change them from "PlayerLogs" to "PlayerLogs_Merge"
// then add these line to this UTUT3XPlayersDB.ini
// 
var config array<UT3XPlayerInfo> PlayersLogs_Merge;

var config bool IsMergeActive;

var UT3XCountries uc;

var array<UT3XPlayerInfo> ipr_players;
var config int ipr_current_player;
var config int ipr_current_iplvl;
var config int ipr_players_size;
var config float merge_timer;

function merge(){
	//local array<UT3XPlayerInfo> emptyArray;
	
	if(!IsMergeActive){
		LogInternal("Merge of players has been disabled. Use command set UT3X.UT3XPlayersDB IsMergeActive true to reactivate");
		return;
	}
	

	PlayersLogs = MergePlayerDb(PlayersLogs_Merge, PlayersLogs);
	PlayersLogs_Merge.length = 0; 
	
	SaveConfig();
}

function fixPlayerLogs(optional bool removeNoPlayerLogin){
	local int i, j;
	local int playersDeleted;
	
	LogInternal("*** PLAYERS'BD MAINTENANCE START ***");

	
	// removes duplicate player
	for(i=0; i< PlayersLogs.length; i++){
		if(PlayersLogs.Find('UNID', PlayersLogs[i].UNID) != i){
			PlayersLogs.removeItem(PlayersLogs[i]);
			playersDeleted ++;
		}
		
		// remove player that never suceeded to login 
		if(removeNoPlayerLogin && PlayersLogs[i].LL == ""){
			PlayersLogs.removeItem(PlayersLogs[i]);
			playersDeleted ++;
		}
	}
	
	for(i=0; i< PlayersLogs.length; i++){
		
		for(j=0; j<PlayersLogs[i].CNS.length; j++){
			PlayersLogs[i].CNS[j] = CAPS(PlayersLogs[i].CNS[j]);
			
			// removes duplicate of computer names
			if(PlayersLogs[i].CNS.Find(PlayersLogs[i].CNS[j]) != j){
				PlayersLogs[i].CNS.removeItem(PlayersLogs[i].CNS[j]);
			}
		}
		for(j=0; j<PlayersLogs[i].CNS.length; j++){
			if(Len(PlayersLogs[i].CNS[j]) == 32){
				PlayersLogs[i].CNS.removeItem(PlayersLogs[i].CNS[j]);
			}
		}
		// removes "0" hashes
		for(j=0; j< PlayersLogs[i].HASHES.length; j++){
			if(PlayersLogs[i].HASHES[j]=="0"){
				PlayersLogs[i].HASHES.removeItem(PlayersLogs[i].HASHES[j]);
			}
		}
		
		// removes duplicate of friends
		for(j=0; j< PlayersLogs[i].FDS.length; j++){
			if(PlayersLogs[i].FDS.Find(PlayersLogs[i].FDS[j]) != j){
				PlayersLogs[i].FDS.removeItem(PlayersLogs[i].FDS[j]);
			}
		}
		
		// removes duplicate of clantags
		for(j=0; j< PlayersLogs[i].CTS.length; j++){
			if(PlayersLogs[i].CTS.Find(PlayersLogs[i].CTS[j]) != j){
				PlayersLogs[i].CTS.removeItem(PlayersLogs[i].CTS[j]);
			}
		}
	}
	
	LogInternal("*** PLAYERS'BD MAINTENANCE END ***");
	SaveConfig();
}

function Array<UT3XPlayerInfo> getPlayerClonesFromUNID(string UNID){
	
	local int i;
	local  Array<UT3XPlayerInfo> clonePlayers;
	
	i = PlayersLogs.find('UNID', UNID);
	
	if(i != -1){
		return getPlayerClones(PlayersLogs[i]);
	}

	return clonePlayers;
}

// get players which are identical matching ip and some other parameters
function Array<UT3XPlayerInfo> getPlayerClones(UT3XPlayerInfo pi2, optional bool stop){

	local  Array<UT3XPlayerInfo> clonePlayers, newClones;
	local Array<UT3XPlayerInfo> playerss;
	local int i, j;
	local bool add;
	local bool hasSameIp, hasSameHash, hasSameComputerName, hasSameIpRange;


	//playerss = PlayerLogs;
	
	for(i=0; i< PlayersLogs.length; i++){
		add = false;
		hasSameIp = false;
		hasSameHash = false; 
		hasSameComputerName = false;
		hasSameIpRange = false;
		
		for(j=0; j<PlayersLogs[i].IPCS.length; j++){
			if(pi2.IPCS.find('IP', PlayersLogs[i].IPCS[j].IP) != -1){
				hasSameIp = true;
			}
			
			// Ip Range check
			
			if(PlayersLogs[i].IPCS[j].A != 0 // prevent doing test on ip ranges that has not been computed (default = 0.0.0.0)
				&& (pi2.IPCS.find('A', PlayersLogs[i].IPCS[j].A) != -1 
				&& pi2.IPCS.find('B', PlayersLogs[i].IPCS[j].B) != -1 
					&& pi2.IPCS.find('C', PlayersLogs[i].IPCS[j].C) != -1 
						 && pi2.IPCS.find('D', PlayersLogs[i].IPCS[j].D) != -1) ){
						 
				hasSameIpRange = true;
			}
			
			if(hasSameIpRange || hasSameIp){
				break;
			}
		}
		
		for(j=0; j<PlayersLogs[i].HASHES.length; j++){
			if(PlayersLogs[i].HASHES[j] != "" && pi2.HASHES.find(PlayersLogs[i].HASHES[j]) != -1){
				hasSameHash = true;
			}
			
			if(hasSameHash){
				break;
			}
		}
		
		for(j=0; j<PlayersLogs[i].CNS.length; j++){
			if(PlayersLogs[i].CNS[j] != "" && pi2.CNS.find(CAPS(PlayersLogs[i].CNS[j])) != -1){
				hasSameComputerName = true;
			}
			
			if(hasSameComputerName){
				break;
			}
		}
		
		// same ip = clearly same player
		// but still cannot be 100% sure since player X can play at home of player Y (so same ip shared between players ...)
		if(hasSameIp){
			add = true;
		} else {
			// Same Comp Name and Ip Range - Same players!
			if(hasSameIpRange && hasSameComputerName){
				add = true;
			}
		}
		
		// avoid adding same player (same playername)
		if(pi2.PName == PlayersLogs[i].PName){
			//add = false;
		}
		
		if(add){
			clonePlayers.addItem(PlayersLogs[i]);
		}
	}
	
	// recursive, we get the clones of clone players
	// does not work .. too many loops for ut3 .... so ut3 just stops ... :/
	/*
	if(!stop){
		// clonePlayersOfClones
		for(i=0; i< clonePlayers.length; i++){
			clonePlayersOfClones = getPlayerClones(clonePlayers[i], true);
			
			for( j=0; j< clonePlayersOfClones.length ; j++){
				if(clonePlayers.find('PName', clonePlayersOfClones[j].PName) == -1){
					newClones.addItem(clonePlayersOfClones[j]);
				}
			}
		}
		
		for(i=0; i< newClones.length; i++){
			clonePlayers.addItem(newClones[i]);
		}
		
	}*/
	
	
	return clonePlayers;
}

// ipr_players

function setIpRange(){
	local int i, j;
	local bool computeIprange;
	
	
	
	// remove duplicates and fix (so less ip ranges to compute ...)
	fixPlayerLogs();

	// we only get players who have at least one ip range not set
	for(i=0; i< PlayersLogs.length; i++){
		computeIprange = false;
	

		for(j=0; j< PlayersLogs[i].IPCS.length ; j ++){
			if(PlayersLogs[i].IPCS[j].A == 0){
				computeIpRange = true;
			}
		}
		
		if(computeIprange){
			ipr_players.addItem(PlayersLogs[i]);
		}
	}
	
	// trick ... we need to set a timer
	// or else UT3 detects too much iterations and will close (so the server will close ....)
	// don't set timer under 0.1 or else server will crash (not enough time to get data)
	LogInternal("*** COMPUTING IP RANGES *** REMAINING TIME: "$getRemainingTimeMerge()$" s");
	setTimer(merge_timer, true, 'setIpRangeForPlayer');
}

function int getRemainingTimeMerge(){

	local float x;
	
	x = (7 - 1 - ipr_current_iplvl)*ipr_players.length*merge_timer;
	
	x += (ipr_players.length-ipr_current_player)*merge_timer;
	
	return x;
}

function setIpRangeForPlayer(){
	local int i;
	local int j;
	local array<byte> xx;

	i = ipr_current_player;
	j = ipr_current_iplvl;
	
	//LogInternal("Getting ip range for player: "$ipr_players[i].PName);
	
	
	if(i == ipr_players.length){
		ClearTimer('setIpRangeForPlayer');
		ipr_current_player = 0;
		SaveConfig();
		LogInternal("********** IP RANGES ALL SAVED FOR LEVEL "$ipr_current_iplvl$"! **************");
		ipr_current_iplvl ++;
		
		if(ipr_current_iplvl == 7){
			ClearTimer('setIpRangeForPlayer');
			LogInternal("********** IP RANGES COMPUTE FINISHED !! **************");
			ipr_current_iplvl = 0;
			SaveConfig();
		} else {
			// TODO FILTER AGAIN THE ipr_players array to get players that have at least X (ipr_current_iplvl) IPS ...
		
			setTimer(merge_timer, true, 'setIpRangeForPlayer');
		}
		return;
	}
	
	//for(j = 0; j < 1  ; j++){ //ipr_players[i].IPCS.length 
		
		if(ipr_players[i].IPCS.length > j && ipr_players[i].IPCS[j].A == 0 && ipr_players[i].IPCS[j].B == 0){
			// 159.224.0.0.159.224.255.255:UA:UKR
			xx = uc.getIpRangeBytesFromIP(ipr_players[i].IPCS[j].ip);
			//s = uc.getCountryDataSplitFromIP(ipr_players[i].IPCS[j].ip);
			
			//LogInternal(s);
			
			//class'UT3XLib'.static.Split2(s, ".", xx);
			
			
			ipr_players[i].IPCS[j].A = xx[0];
			ipr_players[i].IPCS[j].B = xx[1];
			ipr_players[i].IPCS[j].C = xx[2];
			ipr_players[i].IPCS[j].D = xx[3];
							
			ipr_players[i].IPCS[j].E = xx[4];
			ipr_players[i].IPCS[j].F = xx[5];
			ipr_players[i].IPCS[j].G = xx[6];
			ipr_players[i].IPCS[j].H = xx[7];
			
			//ipr_players[i].IPCS[j].CC3 = xx[7];
			
			if(ipr_players[i].IPCS[j].A > 0){
				//LogInternal(xx[0]$"."$xx[1]$"."$xx[2]$"."$xx[3]$" - ("$ipr_players[i].IPCS[j].ip$") -> "$xx[4]$"."$xx[5]$"."$xx[6]$"."$xx[7]);
			}
		}
	//}
	if(ipr_current_player % 100 == 0){
		LogInternal("Level ["$ipr_current_iplvl$"/6] - Computing ip range .... "$float(ipr_current_player*100)/float(ipr_players.length)$"%");
	}
	

	ipr_current_player ++;
	
	
	if(ipr_current_player % 1000 == 0){
		ClearTimer('setIpRangeForPlayer'); // we let UT3 save the file ..
		SaveConfig();
		LogInternal("Level ["$ipr_current_iplvl$"/6] - Intermediate File Saving ... REMAINING TIME: "$getRemainingTimeMerge()$" s");
		setTimer(merge_timer, true, 'setIpRangeForPlayer');
	}
}


function static String playersToHtmlRequest(array<UT3XPlayerInfo> players){
	
	local string s;
	local int i;
	
	
	for(i=0; i < players.length; i++){
		s $= playerToHtmlRequest(players[i], true, i);
		//LogInternal(i$"-"$s);
		if(i < (players.length -1)){
			s $= "&";
		}
	}
	
	s $= "&ismulti=1";

	return s;
}

// pn_name=4x4x&pn_uniqueid=01231354313&pn_lastprelogin=1359053891
function static String playerToHtmlRequest(UT3XPlayerInfo pif, bool useArray, int numPlayer){

	local string s;
	local string x;
	local int i;
	
	if(useArray) x = "["$numPlayer$"]";
	
	s =  "pn_name"$x$"="$class'HttpUtil'.static.RawUrlEncode(pif.PName)$"&pn_uniqueid"$x$"="$pif.UNID;
	s $= "&pn_firstprelogin"$x$"="$(pif.FPL!="")?string(class'UT3XLib'.static.getGlobalSecondsFromTimeStamp(pif.FPL)):"";
	s $= "&pn_lastprelogin"$x$"="$(pif.LPL!="")?string(class'UT3XLib'.static.getGlobalSecondsFromTimeStamp(pif.LPL)):"";
	s $= "&pn_firstlogin"$x$"="$(pif.FL!="")?string(class'UT3XLib'.static.getGlobalSecondsFromTimeStamp(pif.FL)):"";
	s $= "&pn_lastlogin"$x$"="$(pif.LL!="")?string(class'UT3XLib'.static.getGlobalSecondsFromTimeStamp(pif.LL)):"";
	s $= "&pn_lastlogout"$x$"="$(pif.LLO!="")?string(class'UT3XLib'.static.getGlobalSecondsFromTimeStamp(pif.LLO)):"";
	s $= "&pn_deltatime"$x$"="$(pif.DT>0)?string(pif.DT):"";
	
	// Ips
	for(i = 0; i < pif.IPCS.length; i++){
		s $= "&pi_ip"$x$"["$i$"]="$(pif.IPCS[i].ip!=""?pif.IPCS[i].ip:"");
	}
	
	// Hashes
	for(i = 0; i < pif.hashes.length; i++){
		s $= "&ph_hash"$x$"["$i$"]="$(pif.hashes[i]!=""?pif.hashes[i]:"");
	}
	
	// Clan Tags
	for(i = 0; i < pif.cts.length; i++){
		s $= "&pct_name"$x$"["$i$"]="$(pif.cts[i]!=""?pif.cts[i]:"");
	}
	
	// CNS
	for(i = 0; i < pif.cns.length; i++){
		s $= "&pc_name"$x$"["$i$"]="$(pif.cns[i]!=""?class'HttpUtil'.static.RawUrlEncode(pif.cns[i]):"");
	}
	
	// FDS
	for(i = 0; i < pif.fds.length; i++){
		s $= "&pf_name"$x$"["$i$"]="$(pif.fds[i]!=""?class'HttpUtil'.static.RawUrlEncode(pif.fds[i]):"");
	}
	
	return s;
}






// integrates the playerdb of current match to global player database
function array<UT3XPlayerInfo> MergePlayerDb(array<UT3XPlayerInfo> PlayerDbFrom, array<UT3XPlayerInfo> PlayerDbInto){



	local int i, j, k, l, idx;
	local bool sameIpRangeFound;
	local UT3XPlayerInfo friendInfo;
	local UT3XTcpLink tl;
	
	if(PlayerDbFrom.length == 0){
		LogInternal("No Player Db Merge / Input PlayerDb is empty");
		return PlayerDbInto;
	}
	
	LogInternal("**** MERGING PLAYER DB ****");
	LogInternal("-> INPUT DB SIZE:"$PlayerDbFrom.length);
	LogInternal("-> CURRENT DB SIZE:"$PlayerDbInto.length);
	
	if(PlayerDbInto.length == 0){
		PlayerDbInto = PlayerDbFrom;
	}
	
	j = -1;
	
	if(UT3XAC(WorldInfo.Game.AccessControl).sqlLink_exportPlayerData){
		LogInternal("Exporting playerdata to SQL of "$PlayerDbFrom.length$" players ...");
		tl = Spawn(class'UT3XTcpLink'); //spawn the class
		tl.exportPlayerData(PlayerDbFrom);
	}
	
	// remove all this once tcp link is fully operational ...
	for(i=0; i<PlayerDbFrom.length;i++){
		//LogInternal(getFuncName()$"-"$PlayerDbFrom[i].PName);
		
		j = PlayerDbInto.Find('PName', PlayerDbFrom[i].PName);

		// Player ever exists in the global database
		// need to update data
		if(j != -1){ 
			// TODO FPL 
		
			PlayerDbInto[j].LPL = PlayerDbFrom[i].LPL; //TODO ONLY OVERWRITE IS MORE RECENT
			PlayerDbInto[j].LL = PlayerDbFrom[i].LL; // TODO CHANGE THIS
			
			if(PlayerDbFrom[i].LLO == "" && PlayerDbFrom[i].LL != ""){
				PlayerDbFrom[i].LLO = TimeStamp(); //TODO FIX
			}
			
			PlayerDbInto[j].LLO = PlayerDbFrom[i].LLO; //TODO ONLY OVERWRITE IS MORE RECENT
			PlayerDbInto[j].DT = PlayerDbFrom[i].DT;
			
			if(PlayerDbFrom[i].UNID != ""){
				PlayerDbInto[j].UNID = PlayerDbFrom[i].UNID;
			}
			// CLAN TAGS
			for(k=0; k<PlayerDbFrom[i].CTS.length; k++){
				if(PlayerDbInto[j].CTS.Find(PlayerDbFrom[i].CTS[k]) == -1 && PlayerDbInto[j].CTS.length <= 3){
					PlayerDbInto[j].CTS.addItem(PlayerDbFrom[i].CTS[k]);
				}
			}
			// HASHES
			for(k=0; k<PlayerDbFrom[i].hashes.length; k++){
				if(PlayerDbInto[j].hashes.Find(PlayerDbFrom[i].hashes[k]) == -1){
					PlayerDbInto[j].hashes.addItem(PlayerDbFrom[i].hashes[k]);
				}
			}
			// COMPUTER NAMES HASHES
			for(k=0; k<PlayerDbFrom[i].cns.length; k++){
				if(PlayerDbInto[j].cns.Find(PlayerDbFrom[i].cns[k]) == -1){
					PlayerDbInto[j].cns.insertItem(0, PlayerDbFrom[i].cns[k]);
					if(PlayerDbInto[j].cns.length > 7){
						PlayerDbInto[j].cns.removeItem(PlayerDbInto[j].cns[6]);
					}
				}
			}
			
			// FRIENDS (UID->PlayerName)
			for(k=0; k<PlayerDbFrom[i].fds.length; k++){
				l = -1;
				l = PlayerDbInto.Find('UNID', PlayerDbFrom[i].fds[k]); //friendInfo
				
				
					
				if(l != -1){
					friendInfo = PlayerDbInto[l];
					
					if(PlayerDbInto[j].fds.Find(friendInfo.PName) == -1){
						PlayerDbInto[j].fds.insertItem(0, friendInfo.PName);
						if(PlayerDbInto[j].fds.length > 20){
							PlayerDbInto[j].fds.removeItem(PlayerDbInto[j].fds[19]);
						}
					}
				
					if(PlayerDbInto[l].fds.Find(PlayerDbFrom[i].PName) == -1){
						PlayerDbInto[l].fds.insertItem(0, PlayerDbFrom[i].PName);
						if(PlayerDbInto[l].fds.length > 20){
							PlayerDbInto[l].fds.removeItem(PlayerDbFrom[i].fds[19]);
						}
					}
				}
			}
			
			// IP / IP RANGE / COUNTRY
			for(k=0; k<PlayerDbFrom[i].IPCS.length; k++){
				l = PlayerDbInto[j].IPCS.Find('IP', PlayerDbFrom[i].IPCS[k].IP);
			
				// NEW IP
				if(l == -1){
					// First IP is always the latest new IP
					//PlayerDbInto[j].IPCS.insertItem(0, PlayerDbFrom[i].IPCS[k]);
					PlayerDbInto[j].IPCS.addItem(PlayerDbFrom[i].IPCS[k]); // adds at the end of list
					
					
					if(PlayerDbInto[j].IPCS.length > 7){
					
						sameIpRangeFound = false;
					
						for(idx=0; idx < PlayerDbInto[j].IPCS.length; idx ++){
							if(PlayerDbFrom[i].IPCS[k].A != 0 &&PlayerDbInto[j].IPCS[idx].A != 0){
							
								if(	PlayerDbFrom[i].IPCS[k].A == PlayerDbInto[j].IPCS[idx].A
									&& PlayerDbFrom[i].IPCS[k].B == PlayerDbInto[j].IPCS[idx].B
									&& PlayerDbFrom[i].IPCS[k].C == PlayerDbInto[j].IPCS[idx].C
									&& PlayerDbFrom[i].IPCS[k].D == PlayerDbInto[j].IPCS[idx].D){
									
										PlayerDbInto[j].IPCS.removeItem(PlayerDbInto[j].IPCS[idx]);
										sameIpRangeFound = true;
										break;
									}
							
							}
						}
						
						if(!sameIpRangeFound){
							PlayerDbInto[j].IPCS.removeItem(PlayerDbFrom[i].IPCS[0]); // remove first IP in list
						}
					}
				} 
				// IP EVER EXISTS IN DATABASE
				else {
					if(PlayerDbInto[j].IPCS[l].FTS == ""){
						PlayerDbInto[j].IPCS[l].LTS = PlayerDbFrom[i].IPCS[k].FTS;
					}
				
					// update of last time seen of IP
					PlayerDbInto[j].IPCS[l].LTS = PlayerDbFrom[i].IPCS[k].LTS;
					
					// Previously was unknown ip range
					// We need to set it now
					if(PlayerDbInto[j].IPCS[l].A == 0){
						PlayerDbInto[j].IPCS[l].A = PlayerDbFrom[i].IPCS[k].A;
						PlayerDbInto[j].IPCS[l].B = PlayerDbFrom[i].IPCS[k].B;
						PlayerDbInto[j].IPCS[l].C = PlayerDbFrom[i].IPCS[k].C;
						PlayerDbInto[j].IPCS[l].D = PlayerDbFrom[i].IPCS[k].D;
					}
				}
			}
			
		} else { // NEW - need to add to database
			if(PlayerDbFrom[i].FDS.length > 0){
				for(k=0; k< PlayerDbFrom[i].FDS.length; i++){
					l = PlayerDbInto.Find('UNID', PlayerDbFrom[i].fds[k]); //friendInfo
					
					if(l != -1){
						friendInfo = PlayerDbInto[l];
						
						PlayerDbFrom[i].FDS.addItem(friendInfo.PName);
						PlayerDbInto[l].FDS.addItem(PlayerDbFrom[i].PName);
					}
				}
			}
			PlayerDbInto.addItem(PlayerDbFrom[i]);
		}
	}
	
	// we auto fix duplicates, ...
	//fixPlayerLogs();
	
	LogInternal("**** MERGE FINISHED! ****");
	LogInternal("-> NEW DB SIZE:"$PlayerDbInto.length);
	
	return PlayerDbInto;
}	


defaultproperties
{
	merge_timer = 0.11;
	IsMergeActive= true;
}


