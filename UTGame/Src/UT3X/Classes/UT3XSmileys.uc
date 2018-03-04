/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XSmileys extends Info config(UT3XConfig);


struct USmiley
{
	var String smileyText;
	var Texture2D smileyTexture;
	var bool bOnlyAdminUsage; // if true only logged admins can use this smiley
	
	structdefaultproperties
	{
		bOnlyAdminUsage=true;
	}
};

var config array<USmiley> smileysList;

/*
event PostBeginPlay(){
	super.PostBeginPlay();

	// CHECKS EVERY 30S IF TEAMS ARE UNBALANCED
	setTimer(5.0, true, 'addSmileys');
}*/

function addSmileys(){

	local int i;
	local UT3XSmileyReplicationInfo usmri;
	

	foreach DynamicActors(class'UT3XSmileyReplicationInfo', usmri){
		for(i=0; i<smileysList.length; i++){
			usmri.ClientAddEmoticon(smileysList[i].smileyText, smileysList[i].smileyTexture);
			usmri.ServerAddEmoticon(smileysList[i].smileyText, smileysList[i].smileyTexture);
		}
	}
}

function getUSmiley(String msgPart, out USmiley usm){

	local int i;
	
	i = smileysList.find('smileyText', CAPS(msgPart));
	
	if(i != -1){
		usm = smileysList[i];
	}
}


function String addSmiley(String smileyText, String smileyTexture, optional bool bOnlyAdminUsage){

	local USmiley usm;
	
	if( (smileyText == "") || (smileyTexture == "") ){
		return "Smiley text or Sound Texture not specified";
	}
	
	getUSmiley(smileyText, usm);
	if(usm.smileyText != ""){
		return "Smiley texture ever set for this message. Texture Name:"$usm.smileyTexture;
	}
	
	usm.smileyText = CAPS(smileyText);
	usm.smileyTexture = Texture2D(DynamicLoadObject(smileyTexture, class'Texture2D'));
	usm.bOnlyAdminUsage = bOnlyAdminUsage;
	
	smileysList.addItem(usm);
	SaveConfig();
	
	return "";
}

