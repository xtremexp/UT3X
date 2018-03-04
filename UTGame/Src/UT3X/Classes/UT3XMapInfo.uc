/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XMapInfo extends Info;


event PostBeginPlay(){
	super.PostBeginPlay();
	if(WorldInfo.Title != "" && WorldInfo.Author!= ""){
		setTimer(300.0, true, 'BroadCastMapInfo');
	}
}


function BroadCastMapInfo(){

	local UT3XPC PC;
	local String msg;
	
	msg = "[MapInfo] Title: "$WorldInfo.Title$" Author: "$WorldInfo.Author;
	
	foreach WorldInfo.AllControllers(class'UT3XPC', PC){
		PC.UT3XMessage(msg, class'UT3XMsgPurple');
	}
}
