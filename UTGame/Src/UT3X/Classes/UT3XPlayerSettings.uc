/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XPlayerSettings extends Info config (UT3XPlayerSettings);


struct PlayerSetting
{
	var String unid;
	var bool bAnonymousCountry;

};

var config array<PlayerSetting> playerSettings;


function loadPlayerSettings(UT3XPCABS PC){
	local PlayerSetting ps;
	local int idx;
	
	if(getPlayerSettings(PC, ps)){
		UT3XPlayerReplicationInfo(PC.PlayerReplicationInfo).bAnonymousCountry = ps.bAnonymousCountry;
		if(ps.bAnonymousCountry){
			PC.ClientMessage("You are in anonymous country mode");
		}
	}
	
}

function bool getPlayerSettings(UT3XPCABS PC, out PlayerSetting ps){

	local String unid;
	local int idx;

	if(PC == None){
		return false;
	}
	
	unid  = class'Engine.OnlineSubsystem'.static.UniqueNetIdToString(PC.PlayerReplicationInfo.UniqueId);
	
	if(unid == "" || unid == "0"){
		return false;
	}
	
	idx = playerSettings.find('unid', unid);
	
	if(idx == -1){
		return false;
	}
	
	ps = playerSettings[idx];
	return true;
	
}

function setAnonymousCountry(UT3XPCABS PC, bool bAnonymousCountry){

	local PlayerSetting ps;
	local String unid;
	local bool save;
	
	if(getPlayerSettings(PC, ps)){
		if(ps.bAnonymousCountry != bAnonymousCountry){
			ps.bAnonymousCountry = bAnonymousCountry;
			save = true;
		}
	} else {
		unid  = class'Engine.OnlineSubsystem'.static.UniqueNetIdToString(PC.PlayerReplicationInfo.UniqueId);
		if(unid == "0" || unid == ""){
			PC.ClientMessage("Impossible to set anonymous country mode. ID not set. (retry in 1 min)");
			return;
		}
		ps.unid = unid;
		ps.bAnonymousCountry = bAnonymousCountry;
		save = true;
	}
	
	if(bAnonymousCountry){
		PC.ClientMessage("You have anonymous country mode ON");
	} else {
		PC.ClientMessage("You have anonymous country mode OFF");
	}

	if(save){
		SaveConfig();
	}
}
