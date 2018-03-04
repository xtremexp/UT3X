/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XAdverts extends Info config (UT3XConfig);

struct UT3XMessage
{
	var String Msg;
	var float Position;
	var float LifeTime;
	var int FontSize;
	var color DrawColor;
	
	var string admin; // Who Added the Msg
	var string StartDate; //TimeStamp - Not working
	var string lastmodified; //When this message was last modified
	var string modifiedby; // Who Modified the Msg
	var String EndDate; //The advert should not be displayed after this date
	
	structdefaultproperties
	{
		LifeTime=6
		DrawColor=(R=0,G=0,B=0)
		FontSize=1
	}
};

var config array<UT3XMessage> messages;
var config array<UT3XMessage> messagesPoll;
var config int displayDelay;
var config bool bBasicDisplay; // USE BASIC DISPLAY instead of using color, position, ...
var int minDisplayDelay;

var float LastCheckPost;

function Tick( float dt )
{

	local UT3XPC PC;
	local UT3XMessage msg;
	
    // Cache the time since the last post check
    LastCheckPost += dt;
	if (LastCheckPost < displayDelay)
    	return;
		
	if (messages.length < 1)
	{
		LastCheckPost = 0;
		return;
	}
	
	msg = messages[Rand(messages.length)];
	
	if(bBasicDisplay){
		WorldInfo.Game.Broadcast(self, msg.Msg);
	} else {
		foreach WorldInfo.AllControllers(class'UT3XPC', PC){
			if(PC.advertRI != None){
			PC.advertRI.sPosy = msg.Position;
			PC.advertRI.sLifetime = msg.LifeTime;
			PC.advertRI.sFontSize = msg.FontSize;
			PC.advertRI.sDrawColor = msg.DrawColor;
			PC.advertRI.sMessage = msg.Msg; // Trigger
			}
		}
	}
	// Clear out our cached post check
	LastCheckPost = 0;
}


function modifyMessage(int IDMsg, String newMsg, String adminName){

	if( (IDMsg+1) > messages.length){
		return;
	}
	
	messages[IDMsg].Msg = newMsg;
	messages[IDMsg].lastmodified = TimeStamp();
	messages[IDMsg].modifiedby = adminName;
	SaveConfig();
	return;
}


	
function addMessage(String MsgStr, string adminName, float Position, float LifeTime, float FontSize, Color DrawColor){

	local PlayerController PC;
	local UT3XMessage Msg;
	
	Msg.Msg = MsgStr;
	Msg.StartDate = TimeStamp();
	Msg.Admin = adminName;
	Msg.Position = Position;
	Msg.LifeTime = LifeTime;
	Msg.DrawColor = DrawColor;

	messages.addItem(Msg);
	SaveConfig();
	
	foreach WorldInfo.AllControllers(class'PlayerController', PC){
		PC.ClientMessage("News Added by "$adminName$" :"$Msg.Msg);
	}
}

defaultproperties
{
	minDisplayDelay = 10; // Min of seconds between each message
	displayDelay = 120; // 120 seconds between each message
	bBasicDisplay = false;
}
