/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XSmileyReplicationInfo extends ReplicationInfo dependson(UT3X);

var array<USmileyss> mySmileys;
var repnotify UT3XSmileys SmileyClass;
var int i;

Replication
{
    //if(bNetDirty && (Role == ROLE_Authority))
	//if(bNetDirty) // && (Role == ROLE_Authority))
		//SmileyClass;
}

simulated event ReplicatedEvent(name VarName)
{
	if(VarName == 'SmileyClass'){
		//LogInternal("SmileyClass is replicated!!-XXXXXXXXXXXXXXXXXX");
	}else
    {
        super.ReplicatedEvent(VarName);
    }
}

/*
function Tick(float dt)
{
	if(Owner == none)
	{
		Destroy();
	}
	super(Actor).Tick(dt);

	if(i == SmileyClass.smileysList.Length)
	{
		return;
	}
	ClientAddEmoticon(SmileyClass.smileysList[i].smileyText, SmileyClass.smileysList[i].smileyTexture);
	
	++ i;
}*/



unreliable client function ClientAddEmoticon(string S, Texture2D ico){
	local int N;
	
	/*
	if(mySmileys.Find('smileyText', S) == -1){	
		LogInternal(Owner$"-"$WorldInfo.NetMode$"-"$"ADD EMOTICON:"$S$"-"$ico);
		N = mySmileys.Length;
		mySmileys.Length = N + 1;
		mySmileys[N].smileyText = S;
		mySmileys[N].smileyTexture = ico;
	}*/
}

unreliable server function ServerAddEmoticon(string S, Texture2D ico){
	local int N;
	local int i;
	
	/*
	for(i=0; i<mySmileys.length; i++){
		if(mySmileys[i].Find('smileyText', S) == -1){
			LogInternal(Owner$"-"$WorldInfo.NetMode$"-"$"ADD EMOTICON:"$S$"-"$ico);
			N = mySmileys.Length;
			mySmileys.Length = N + 1;
			mySmileys[N].smileyText = S;
			mySmileys[N].smileyTexture = ico;
		}
	}*/
	// TODO FIX/CHANGE

}


defaultproperties
{
	bAlwaysRelevant=true
	bSkipActorPropertyReplication=true
	RemoteRole=2;
	//mySmileys(0)=(smileyText="lol",smileyTexture=Texture2D'UT3XContentV2.Smileys.smiley-twist',bOnlyAdminUsage=false)
}
