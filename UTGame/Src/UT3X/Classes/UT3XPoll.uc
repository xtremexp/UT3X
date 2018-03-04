/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XPoll extends Info Config(UT3XPoll);



enum QuestionType
{
	QT_GENERAL,
	QT_MAP_RATING
};

enum AnswerType
{
	AT_YES_NO, 
	AT_YES_NO_VOID,
	AT_0_10
};

struct PlayerVote
{
	var String PlayerName; 
	var int VoteValue; // IF YES/NO QUESTION THE 0 = NO AND 1 = YES
};

struct Poll
{
	var int IDPoll;
	var String question;
	var String extraInfo; // For Map Rating
	var bool isActive; // Only one poll at a time must be active for QT_GENERAL!!
	var int LinkedIDMsg; //UT3XAdverts
	var QuestionType questionType;
	var AnswerType answerType;
	var array<PlayerVote> PlayerVotes;
	
	structdefaultproperties
	{
		questionType = QT_GENERAL;
		answerType = AT_YES_NO;
	}
};

var config int delayDisplay;
var config bool isActive;
var config array<poll> pools;

event PreBeginPlay(){
	//setTimer(delayDisplay, true, 'displayMapRatingInfo');
}

/*
function addMapRatingPoll(){

	local poll mapPool;
	
	mapPool.QuestionType = QT_MAP_RATING;
	mapPool.answerType = AT_YES_NO;
	mapPool.extraInfo =  WorldInfo.GetMapName(false); // MapName
	mapPool.question = " Do you like "$WorldInfo.GetMapName(false)$"?";
	mapPool.isActive = true;
}*/

private function String getAnswerTypeReadable(AnswerType at){
	if(at == AT_YES_NO){
		return "!yes(yes) / !no(no)";
	} else if(at == AT_YES_NO_VOID){
		return "!yes(yes) / !no(no)";
	} else {
		return "";
	}
}




defaultproperties
{
	isActive=true;
	delayDisplay=200;
}