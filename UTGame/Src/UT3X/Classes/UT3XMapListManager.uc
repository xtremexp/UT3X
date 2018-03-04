/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XMapListManager extends UTMapListManager;


// Default Map List when between 0 and 12 players
var config name mapListName_0_12;

// Default Map List when between 13 and 20 players
var config name mapListName_13_20;

// Default Map List when between 21 and 64 players
var config name mapListName_21_64;

// When map changes
// set default map list depending on number of players
function Initialize()
{

	local String currentMapListname;
	local String newMapListName;
	
	super.Initialize();
	
	currentMapListname = String(AvailableGameProfiles[ActiveGameProfile].MapListName);
	newMapListName = String(getMapListNameByNumPlayers(getNumPlayers()));

	if(newMapListName != currentMapListName && newMapListName != "" && newMapListName != "None"){
		LogInternal("[MapList auto change] - Changing maplist from "$currentMapListName$" to "$newMapListName);
		WorldInfo.Game.Broadcast(self, "MapList has been automatically changed to maplist "$newMapListName);
		AvailableGameProfiles[ActiveGameProfile].MapListName = Name(newMapListName);
		SaveConfig();
	}
}

function updateCurrentMapCountForList(name mapListName){
	local UTMapList mapList;
	local int CurMapIdx;
	
	mapList = GetMapListByName(mapListName);
	
	if(mapList == None){
		return;
	}
	
	CurMapIdx = mapList.GetMapIndex(WorldInfo.GetMapName(True),, WorldInfo.Game.ServerOptions);

	if (CurMapIdx != mapList.LastActiveMapIndex)
	{
		// Now update the maplist
		if (CurMapIdx != INDEX_None)
		{
			//LogInternal("Current map is not the maplist's active map, updating maplist");
			mapList.SetLastActiveIndex(CurMapIdx);
			UpdateMapHistory(mapList, CurMapIdx);
		}
	}
	
}

// Updates map count for other map lists (if map in >= 2 map lists)
function updateMapCountOtherLists(name currentMapListName){

	if(currentMapListName == mapListName_0_12){
		updateCurrentMapCountForList(mapListName_13_20);
		updateCurrentMapCountForList(mapListName_21_64);
	}
	else if(currentMapListName == mapListName_13_20){
		updateCurrentMapCountForList(mapListName_0_12);
		updateCurrentMapCountForList(mapListName_21_64);
	} 
	else if(currentMapListName == mapListName_21_64){
		updateCurrentMapCountForList(mapListName_0_12);
		updateCurrentMapCountForList(mapListName_13_20);
	}
	
}



// WorldInfo.Game.getNumPlayers() does not work???
// TODOCHECK mayeb count spectators as players ???
function int getNumPlayers(){

	//return WorldInfo.Game.getNumPlayers();
	
	
	local UT3XPC PC;
	local int count;
	
	foreach WorldInfo.AllControllers(Class'UT3XPC', PC){
		if(!PC.PlayerReplicationInfo.bOnlySpectator){
			count ++;
		}
	}
	
	return count;
	
}



private function name getMapListNameByNumPlayers(int numPlayers){

	if(numPlayers >=0 && numplayers <= 12 && existsMapListByName(mapListName_0_12)){
		return mapListName_0_12;
	} else 	if(numPlayers >=13 && numplayers <= 20 && existsMapListByName(mapListName_13_20)){
		return mapListName_13_20;
	} else 	if(existsMapListByName(mapListName_21_64)){
		return mapListName_21_64;
	}

	return AvailableGameProfiles[ActiveGameProfile].MapListName;
}

//TODO BAD CODE
function bool existsMapListByName2(String mapListName){

	local int i, idx;
	local array<string> names;
	local string mln;
	GetPerObjectConfigSections(class'UTMapList', names); 
	
	for (i = 0; i < names.length; i++)
	{
		idx = InStr(names[i], " ");
		if (idx == INDEX_NONE) continue;
		if(Left(names[i], idx) == mapListName){
			return true;
		}
	}
	
	return false;
}

function array<string> getMapLists(){
	local int i, idx;
	local array<string> names;
	local array<string> mapListss;
	local string mln;
	local string t;
	
	GetPerObjectConfigSections(class'UTMapList', names); 
	

	for (i = 0; i < names.length; i++)
	{
		idx = InStr(names[i], " ");
		if (idx == INDEX_NONE) continue;
		t = Left(names[i], idx);;
		mapListss.addItem(t);
	}
	
	return mapListss;
}

function bool existsMapListByName(name mapListName){

	local int i, idx;
	local array<string> names;
	local string mln;
	GetPerObjectConfigSections(class'UTMapList', names); 
	
	for (i = 0; i < names.length; i++)
	{
		idx = InStr(names[i], " ");
		if (idx == INDEX_NONE) continue;
		if(Left(names[i], idx) == String(mapListName)){
			return true;
		}
	}
	
	return false;
}
