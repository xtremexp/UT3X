/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
Class UT3XAdvertsReplication Extends ReplicationInfo;


var repnotify string sMessage;
var PlayerController PC;   

var float sPosy;
var int sLifetime;
var int sFontSize;
var color sDrawColor;



Replication
{
    if(bNetDirty && (Role == ROLE_Authority))
    	sMessage, sPosy, sLifetime, sFontSize, sDrawColor, PC;
}



simulated event ReplicatedEvent(name VarName)
{
	
	// We have a variable. Should be our variable, lets check
	if (Varname == 'sMessage' && PC != None && WorldInfo.NetMode == NM_Client)
	{
		LocalPlayer(PC.Player).ViewportClient.ViewportConsole.OutputText(sMessage);
		
		PC.myHud.LocalizedMessage(
			class'UTLocalMessage',
			PC.RealViewTarget,
			sMessage,
			1,
			sPosy,
			sLifetime,
			sFontSize,
			sDrawColor
		);
	}
	Super.ReplicatedEvent(VarName);
}
