/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XDemoRec extends Info;

var bool bRecording;
var bool bDemoRecActive;
var bool advertised;
var String demoFileName;

event PreBeginPlay(){
	bRecording = false;
	bDemoRecActive = true;
}

event PostBeginPlay(){
	if(WorldInfo.Game.getNumPlayers()>0){
		checkDemoRecActive();
	}
}

function checkDemoRecActive(){
	if(!bRecording && bDemoRecActive){
		bRecording = true;
		LogInternal(TimeStamp()$"-STARTING DEMOREC: "$getDemoFileName());
		demoFileName = getDemoFileName2();
		ConsoleCommand("demorec" @ getDemoFileName());
		UT3XAC(WorldInfo.Game.AccessControl).log.addLog(LT_DEMOREC, , , demoFileName);
	}
}

function String getDemoFileName(){
	return WorldInfo.GRI.ShortName$"-"$WorldInfo.GetMapName(true)$"-%td";
}

static function String getDemoFileNameStatic(WorldInfo wi){
	return wi.GRI.ShortName$"-"$wi.GetMapName(true)$"-"$TimeStamp();
}

function String getDemoFileName2(){
	return (demoFileName != "")?demoFileName:getDemoFileNameStatic(WorldInfo);
}

event Tick( float DeltaTime ){
	
	if(WorldInfo.Game.bGameEnded && !advertised){

		advertised = true;
		
		//@TODO MOVE THIS CODE
		if(bDemoRecActive){
			setTimer(5.0, false, 'BroadcastHasDemoRec');
		}
	}
	
	super.Tick(DeltaTime);
}

function BroadcastHasDemoRec(){
	local UT3XPC C;
	
	foreach WorldInfo.AllControllers(class'UT3XPC', C){
		C.UT3XMessage("[DemoRec]-"$demoFileName$".demo file has been saved", class'UT3XMsgPurple');
	}
}



defaultproperties
{
	advertised = false;
	bDemoRecActive = true;
}


