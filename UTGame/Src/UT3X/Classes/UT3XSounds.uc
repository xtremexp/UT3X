/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XSounds extends Info config(UT3XConfig);

struct USound
{
	var String soundMsg;
	var String soundClassName;
	var bool bOnlyAdminUsage; // if true only logged admins can play this sound
	
	structdefaultproperties
	{
		bOnlyAdminUsage=true;
	}
};

var config array<USound> soundsList;


// @TODO DONT PLAY SOUND IF IT IS EVER BEING PLAYED
public function bool PlaySoundMsg(String msg, PlayerController P, optional bool playAllControllers, optional out string soundClassName){

	local SoundCue sc;
	local USound us;
	local PlayerController PC;
	
	if(msg == ""){
		return false;
	}
	
	getUSound(msg, us);
	if(us.soundMsg == ""){
		return false;
	}
	
	if(us.bOnlyAdminUsage && !P.PlayerReplicationInfo.bAdmin){
		return false;
	}
	
	soundClassName =  us.soundClassName;
	
	sc = SoundCue(DynamicLoadObject(us.soundClassName, class'SoundCue'));
	//if (SoundCueClass != None)
	//{
		if(sc == None){
			LogInternal("Could not load sound "$us.soundClassName);
			return false;
		}
		//sc = new(Self) SoundCueClass;
		if(sc != None){
			if(!playAllControllers){
				P.ClientPlaySound(sc, true);
			} else {
				foreach WorldInfo.AllControllers(class'PlayerController', PC){
					PC.ClientPlaySound(sc, true);
				}
			}
			return true;
		}
	//}
	
	return false;
}

private function getUSound(String msg, out USound us){

	local int i;
	
	for(i=0; i<soundsList.length; i++){
		if(CAPS(soundsList[i].soundMsg) == CAPS(msg)){
			us = soundsList[i];
		}
	}
}


function String addSound(String soundMsg, String soundMsgClass, optional bool bOnlyAdminUsage){

	local USound us;
	
	if( (soundMsg == "") || (soundMsgClass == "") ){
		return "Sound Msg or Sound Msg Class not specified";
	}
	
	getUSound(soundMsg, us);
	if(us.soundMsg != ""){
		return "SoundCue class ever set to this message. SoundCueClassName:"$us.soundClassName;
	}
	
	us.soundMsg = soundMsg;
	us.soundClassName = soundMsgClass;
	us.bOnlyAdminUsage = bOnlyAdminUsage;
	
	soundsList.addItem(us);
	SaveConfig();
	
	return "";
}
