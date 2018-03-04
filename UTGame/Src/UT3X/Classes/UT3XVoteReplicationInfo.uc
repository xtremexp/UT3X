/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XVoteReplicationInfo extends UTVoteReplicationInfo;

// IDEA: SetDesiredTransferTime reduce time to get maplist
// Reset mapvotelist:

reliable server function ServerRecordKickVote(int PlayerID, bool bAddVote)
{
	local PlayerReplicationInfo PRI;
	local bool bValid;

	// If voting is not allowed, or if you already added (or removed) the vote from the list, return
	if (!bVotingAllowed || VoteRepeatCounter() || (bAddVote ^^ CurKickVoteIDs.Find(PlayerID) == INDEX_None))
		return;


	// Check that the vote is valid
	foreach WorldInfo.GRI.PRIArray(PRI)
	{
		if (PRI.PlayerID == PlayerID)
		{
			if (PRI != UTPlayerController(Owner).PlayerReplicationInfo)
				bValid = True;

			break;
		}
	}

	bValid = True; // CAN KICKVOTE YOURSELF
	
	// Invalid vote, count it as vote spam and return
	if (!bValid)
	{
		if (KickVoteSpamCounter(INDEX_None))
			Collector.HandleKickVoteSpam(Self);

		return;
	}


	if (bAddVote)
	{
		if (KickVoteSpamCounter(PlayerID)){
			Collector.HandleKickVoteSpam(Self);
		}
		else
			Collector.AddKickVote(Self, PlayerID);
	}
	else
	{
		Collector.RemoveKickVote(Self, PlayerID);
	}
}

