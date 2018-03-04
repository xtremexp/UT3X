/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XVoteCollector extends UTVoteCollector;


// @override UTVoteCollector function
// If at least 51% of players have voted and at least 3 players
// do as if the vote were finished (all voted)
function bool CheckTotalMapVoteCount()
{
	local int i, VoteCount;

	for (i=0; i<GameVotes.Length; ++i){
		VoteCount += GameVotes[i].NumVotes;
	}
	if( GameInfoRef.GetNumPlayers() > 0 && (((VoteCount/GameInfoRef.GetNumPlayers())*100) > MidGameVotePercentage) && (VoteCount > MinMidGameVotes) ){
		return true;
	} else {
		return (VoteCount >= GameInfoRef.GetNumPlayers()); // original behaviour (all players voted)
	}
}

// @ override: logs who kick voted + shows remaining vote until kick
function AddKickVote(UTVoteReplicationInfo VRI, int KickID)
{
	local int i;
	local Controller C;
	local String msg;
	


	if (!bKickVotingActive)
		return;

	i = KickVotes.Find('PlayerID', KickID);

	if (i == INDEX_None)
	{
		// Verify that the ID is valid
		foreach WorldInfo.AllControllers(Class'Controller', C)
		{
			if (PlayerController(C) != none && C.PlayerReplicationInfo != none && C.PlayerReplicationInfo.PlayerID == KickID)
			{
				// Add a new entry
				i = KickVotes.Length;
				KickVotes.Length = i+1;
				KickVotes[i].PlayerID = KickID;

				break;
			}
		}


		if (i == INDEX_None)
			return;
	}


	// Kickvote notification messages
	foreach WorldInfo.AllControllers(Class'Controller', C)
		if (PlayerController(C) != none && C.PlayerReplicationInfo.PlayerID == KickID)
			break;

	if (bAnonymousKickVoting)
		BroadcastVoteMessage(20, PlayerController(VRI.Owner).PlayerReplicationInfo, C.PlayerReplicationInfo, 19);
	else
		BroadcastVoteMessage(19, PlayerController(VRI.Owner).PlayerReplicationInfo, C.PlayerReplicationInfo);

	
	
	++KickVotes[i].NumVotes;
	UpdateKickVoteStatus(i);
	VRI.CurKickVoteIDs.AddItem(KickID);
	VRI.ClientKickVoteConfirmed(KickID, True);

	UT3XAC(WorldInfo.Game.AccessControl).log.addLog(LT_KICKVOTE, PlayerController(VRI.Owner).PlayerReplicationInfo.PlayerName, C.PlayerReplicationInfo.PlayerName);
	msg = PlayerController(VRI.Owner).PlayerReplicationInfo.PlayerName@" voted to kick "$C.PlayerReplicationInfo.PlayerName$" (!kickvote). ";
	msg $= getKickVotesNeeded(i)$" votes to go!";
	
	class'UT3XUtils'.static.BroadcastMsg(WorldInfo, msg, class'UT3XMsgOrange');
	
	if (CheckKickVoteCount(i) || (VRI.Owner != none && UTPlayerController(VRI.Owner).PlayerReplicationInfo.bAdmin))
		KickVotePassed(i);
}


function int getKickVotesNeeded(int Idx)
{
	local float ReqVotes;

	if (Idx < 0 || Idx > KickVotes.Length)
		return 0;

	ReqVotes = Max(Max(1.0, MinKickVotes) * 1000.0, float(GameInfoRef.GetNumPlayers()) * float(KickVotePercentage) * 10.0);

	return  int(ReqVotes/1000) -int(float(KickVotes[Idx].NumVotes)) ;
}


defaultproperties
{
	VRIClass=class'UT3XVoteReplicationInfo';
	InitialVoteTransferTime=6; // reduced from 12 to 6 (might increase lag??)
}
