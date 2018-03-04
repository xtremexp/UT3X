/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XLib extends Object;


struct UT3XDateTime
{
	var string timestamp; // same as TimeStamp()
	var int year;
	var int month;
	var int day;
	var int hour;
	var int minute;
	var int second;
	var int globalseconds;
	
	structdefaultproperties
	{
		globalseconds=0;
	}
};

public static function bool isDateAfterNow(int dateSeconds){	

	return (dateSeconds > class'HttpUtil'.static.utimestamp3()); //getGlobalSecondsFromTimeStamp(TimeStamp()));
}

public static function int CompareTS(string ts1, string ts2){
	local float seconds1;
	local float seconds2;
	
	seconds1 = class'HttpUtil'.static.stringToTimestamp(ts1); //getGlobalSecondsFromTimeStamp(ts1);
	seconds2 = class'HttpUtil'.static.stringToTimestamp(ts2);
	
	if(seconds1 == seconds2){
		return 0;
	} else if(seconds1>seconds2){
		return 1;
	} else {
		return -1;
	}
}

public static function bool checkIsUT3XServer(PlayerController P){
	if(P.PlayerReplicationInfo.bAdmin){
		return true;
	} else {
		P.ClientMessage("You are not logged in as admin.");
		return false;
	}
}


public static function bool checkIsAdmin(PlayerController P, optional bool deprecatedParam, optional string masterPassword){

	if(P.PlayerReplicationInfo.bAdmin){
		return true;
	} else {
		P.ClientMessage("You are not logged in as admin.");
		return false;
	}
}

public static function int getGlobalSecondsFromTimeStamp(string timestamp){

	local UT3XDateTime dt;
	
	dt = getDateTimeFromTimeStamp(timestamp);
	return class'HttpUtil'.static.utimestamp(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);
}

//Parse
// If TimeLenght=3D-> 3 days -> 3 * 24 * 3600 seconds
public static function int parseTimeLenghtToSeconds(string tl){
	
	local string lengthtype;
	local int lengthvalue;
	
	if(tl == ""){
		return 0;
	}
	
	tl = CAPS(tl);

	lengthvalue = int(Left(tl, Len(tl) -1));
	lengthtype = Right(tl, 1);
	
	if(lengthtype == "S"){
		return lengthvalue;
	} else if(lengthtype == "M"){
		return lengthvalue*60;
	} else if(lengthtype == "H"){
		return lengthvalue*3600;
	} else if(lengthtype == "D"){
		return lengthvalue*3600*24;
	} else if(lengthtype == "W"){
		return lengthvalue*3600*24*7;
	} else if(lengthtype == "Y"){
		return lengthvalue*3600*24*365.25;
	}
	
	return 0;
}

//seconds since 2011-1-1
public static function float getGlobalSecondsFromDateTime(UT3XDateTime dt){
	
	local float seconds;
	local int y;
	local int m;
	local int d;
	local int h;
	local int mn;
	
	
	if(dt.timestamp==""){
		return 0;
	} else {
		seconds = 0;
		
		for(y=2011;y<=dt.year;y++){
			if(y != dt.year){
				if(isLeapYear(y)){
					seconds += 366*24*3600;
				} else {
					seconds += 365*24*3600;
				}
			} else {
				for(m=1;m<=dt.month;m++){
					if(m != dt.month){
						seconds += getNumDaysForMonth(dt.year, m)*24*3600;
					} else {
						for(d=1;d<=dt.day;d++){
							if(d != dt.day){
								seconds += 24*3600;
							} else {
								for(h=0;h<=dt.hour;h++){
									if(h != dt.hour){
										seconds += 3600;
									} else {
										for(mn=0;mn<=dt.minute;mn++){
											if(mn != dt.minute){
												seconds += 60;
											} else {
												seconds += dt.second;
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	
	return seconds;
}

private static function int getNumDaysForMonth(int year, int month){
	if(month ==2){
		if(isLeapYear(year)){
			return 29;
		} else {
			return 28;
		}
	} else {
		if(month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12){
			return 31;
		} else {
			return 30;
		}
	}
}

private static function bool isLeapYear(int year){
	if(year%4 ==0){
		return true;
	}
	
	return false;
}

public static function float getSecondsBetweenTimeStamps(string timestamp1, string timestamp2){
	local UT3XDateTime dt1;
	local UT3XDateTime dt2;
	
	dt1 = getDateTimeFromTimeStamp(timestamp1);
	dt2 = getDateTimeFromTimeStamp(timestamp2);
	
	return getGlobalSecondsFromDateTime(dt2) - getGlobalSecondsFromDateTime(dt1);
}

public static function String secondsToDateLength(int secondss){
	local float globalseconds;
	local string result;
	//local int years;
	//local int months;
	//local int weeks;
	local int days;
	local int hours;
	local int minutes;
	local int seconds;
	
	globalseconds = float(secondss);
	
	days = int(globalseconds/(24*3600));
	hours = int((globalseconds-(days*24*3600))/3600);
	minutes = int((globalseconds-(days*24*3600)-(hours*3600))/60);
	seconds = globalseconds-(days*24*3600)-(hours*3600)-(minutes*60);
	
	//if(days >= 7){
	//	weeks = int(days/7);
	//	days = days-(weeks*7);
	//	result = weeks$"w ";
	//}
	
	if(days >= 1){
		result = days$"d ";
	}
	
	if(hours >= 1){
		result $= hours$"h ";
	}
	
	if(minutes >= 1){
		result $= minutes$"mn ";
	}
	
	if(seconds >= 1){
		result $= seconds$"s ";
	}
	
	return result;
}

public static function String compareTimeStamps(string timestamp1, string timestamp2){
	return secondsToDateLength(getSecondsBetweenTimeStamps(timestamp1,timestamp2));
}

// 3 -> 03 
// USED for formatting date (months, days, hours, minutes, seconds)
public static function String parseNum2Digits(int num){
	
	if(num>=0 && num < 10){
		return "0"$String(num);
	}
	
	return String(num);
}


// 2011/07/29 - 22:15:20
public static function String getTimeStampFromDateTime(UT3XDateTime udt){
	local string timestamp;
	
	if(udt.globalseconds > 0){
		timestamp = udt.year$"/"$parseNum2Digits(udt.month);
		timestamp $= "/"$parseNum2Digits(udt.day);
		timestamp $= " - "$parseNum2Digits(udt.hour);
		timestamp $= ":"$parseNum2Digits(udt.minute);
		timestamp $= ":"$parseNum2Digits(udt.second);
		
		udt.timestamp = timestamp;
		return timestamp;
	} else {
		return "";
	}
}

//seconds since 2011-1-1
public static function string getTimeStampFromSeconds(float seconds){

	local int year, month, day, hour, minute, second;
	local int totalDays, secondsA, secondsB;
	
	year = 2011;
	month = 1;
	day = 1;
	hour = 0;
	minute = 0;
	second = 0;
	// 46000800
	totalDays = seconds/(24*3600); // 532.41
	secondsB = totalDays;

	
	while(totalDays > getNumDaysForYear(year)){
		year += 1;
		totalDays -= getNumDaysForYear(year);
	}

	
	while(totalDays > getNumDaysForMonth(year, month)){
		month += 1;
		totalDays -= getNumDaysForMonth(year, month);
	}
	
	day = totalDays+1;
	
	secondsA = ((seconds/(24*3600)) - secondsB)*24*3600; // (532.41 - 532)*24*3600
	hour =  secondsA/3600; //  532.41 - 532  12777
	
	secondsA -= hour*3600;
	minute = secondsA/60;
	
	secondsA -= minute*60;
	second = secondsA;
	
	//YY/MM/DD - hh:mm:ss
	return year$"/"$month$"/"$day$" - "$hour$":"$minute$":"$second;
}

private static function int getNumDaysForYear(int year){
	if(isLeapYear(year)){
		return 366;
	} else {
		return 365;
	}
}

// TIMESTAMP:  MM/DD/YY-hh:mm:ss
public static function UT3XDateTime getDateTimeFromTimeStamp(string timestamp){
	
	local array<string> a;
	local array<string> b;
	local array<string> c;
	local string datestr;
	local string timestr;
	local UT3XDateTime dt;
	
	if(timestamp != ""){
		dt.timestamp = timestamp;
		Split2(timestamp, "-", a);
		datestr = a[0]; //  MM/DD/YY
		timestr = a[1]; // hh:mm
		Split2(datestr, "/", b);
		Split2(timestr, ":", c);
		
		dt.year = int(b[0]);
		dt.month = int(b[1]);
		dt.day = int(b[2]);
		
		dt.hour = int(c[0]);
		dt.minute = int(c[1]);
		dt.second = int(c[2]);
		
		//dt.globalseconds = getGlobalSecondsFromDateTime(dt);
		return dt;
	}
	
	return dt;
}

public static function BroadcastMessageToAll(string message, optional string messageadmin)
{
	local WorldInfo wi;
	local int i;
	local PlayerReplicationInfo PRI;
	local UT3XPC PC;
	
	wi = GetWorldInfo();
	
	for (i=0;i<wi.GRI.PRIArray.Length;i++)
	{
		PRI = wi.GRI.PRIArray[i];
		
		PC = UT3XPC(PRI.owner);
		if (PC != none)
		{	
			PC.ClientMessage(message, 'CriticalEvent' );
		}
	}
}

public static function string getTimeStamp(){
	return TimeStamp();
}

public static function WorldInfo GetWorldInfo()
{
    return WorldInfo(FindObject("WorldInfo_0", class'WorldInfo'));
}

public static function UT3XAC GetUT3XAC()
{
    return UT3XAC(FindObject("UT3XAC", class'UT3XAC'));
}

static final function int Split2(coerce string src, string delim, out array<string> parts, optional bool ignoreEmpty, optional string quotechar)
{
	ParseStringIntoArray(src, parts, delim, false);
/*
  local string temp;
  Parts.Remove(0, Parts.Length);
  if (delim == "" || Src == "" ) return 0;
  while (src != "")
  {
    temp = StrShift(src, delim, quotechar);
    if (temp == "")
    {
      if (!ignoreEmpty)
      {
        parts.length = parts.length+1;
        parts[parts.length-1] = temp;
      }
    }
    else {
      parts.length = parts.length+1;
      parts[parts.length-1] = temp;
    }
  }*/
  return parts.length;
}

/** Shifts an element off a string                              <br />
    example (delim = ' '): 'this is a string' -> 'is a string'  <br />
    if quotechar = " : '"this is" a string' -> 'a string'       */
static final function string StrShift(out string line, string delim, optional string quotechar)
{
    local int delimpos, quotepos;
    local string result;

    if ( quotechar != "" && Left(line, Len(quotechar)) == quotechar ) {
        do {
            quotepos = InstrFrom(line, quotechar, quotepos + 1);
        } until (quotepos == -1 || quotepos + Len(quotechar) == Len(line)
                || Mid(line, quotepos + len(quotechar), len(delim)) == delim);
    }
    if ( quotepos != -1 ) {
        delimpos = InstrFrom(line, delim, quotepos);
    }
    else {
        delimpos = Instr(line, delim);
    }

    if (delimpos == -1)
    {
        result = line;
        line = "";
    }
    else {
        result = Left(line,delimpos);
        line = Mid(line,delimpos+len(delim));
    }
    if ( quotechar != "" && Left(result, Len(quotechar)) == quotechar ) {
      result = Mid(result, Len(quotechar), Len(result)-(Len(quotechar)*2));
    }
    return result;
}

/** InStr starting from an offset */
static final function int InStrFrom(coerce string StrText, coerce string StrPart, optional int OffsetStart)
{
  local int OffsetPart;

  OffsetPart = InStr(Mid(StrText, OffsetStart), StrPart);
  if (OffsetPart >= 0)
    OffsetPart += OffsetStart;
  return OffsetPart;
}

static function array<int> StrArrayToIntArray(array<String> a){

	local array<int> b;
	local int Idx;
	
	for(Idx = 0; Idx < a.length; Idx ++){
		b[Idx] = Int(a[Idx]);
	}
	
	return b;
}

// GETS CONTROLLER FROM playername or ip or uniqueid or hash or computername
static function bool getPlayerController(WorldInfo wi,
	out UTPlayerController CPlayer,
	optional string playername,
	optional string uniqueId,
	optional string ip,
	optional string hash,
	optional string computerName
	){

	local UTPlayerController PC;

	// Controller by playername search
	if(playername != ""  && getPCFromPlayerName(wi, playername, CPlayer)){
		return true;
	}
	
	
	
	foreach wi.AllControllers(class'UTPlayerController', PC){
		// Controller by computerName search
		if(UT3XPlayerReplicationInfo(PC.playerReplicationInfo) != None && computerName !=  "" && CAPS(UT3XPC(PC).computerNamee) == CAPS(computerName)){
			CPlayer = PC;
			return true;
		}
		
		// IP search
		if(ip != "" && PC.getPlayerNetworkAddress() == ip){
			CPlayer = PC;
			return true;
		}
		
		// Hash search
		if(hash != "" && PC.HashResponseCache == hash){
			CPlayer = PC;
			return true;
		}
		
		if(PC.PlayerReplicationInfo != None){
			// Unique Id
			if(uniqueId != "" && uniqueId != "0" && class'OnlineSubsystem'.static.UniqueNetIdToString(PC.PlayerReplicationInfo.UniqueId) == uniqueId){
				CPlayer = PC;
				return true;
			}
		}
	}

	return false;
}

static function UT3XPC getUT3XPC(WorldInfo wi, optional string playername, optional string uniqueid, optional string hashkey, optional string computername, optional string ip){

	local Controller C;
	local UT3XPC PC;

	if(playername != ""){
		C = wi.Game.AccessControl.GetControllerFromString(playername);
		if(C!= None){
			return UT3XPC(C);
		}
	}
	if(uniqueid != "" || computername != "" || ip != ""){
		foreach wi.AllControllers(class'UT3XPC', PC){
			if(uniqueid != "" && class'OnlineSubsystem'.static.UniqueNetIdToString(PC.PlayerReplicationInfo.uniqueid) == uniqueid){
				return PC;
			}
			if(computername != "" && CAPS(PC.computerNamee) == CAPS(computername)){
				return PC;
			}
			if(ip != "" && PC.GetPlayerNetworkAddress() == ip){
				return PC;
			}
			if(hashkey != "" && CAPS(PC.HashResponseCache) == CAPS(hashkey)){
				return PC;
			}
		}
	}
	
	return None;
}

// caller PlayerName who called this function
static function bool getPCFromPlayerName(WorldInfo wi, string playername, out UTPlayerController CPlayer, optional string callername){
	
	local PlayerController PCaller;
	
	CPlayer = UTPlayerController(wi.Game.AccessControl.GetControllerFromString(playername));
	if(CPlayer == None){
		if(callername != ""){
			PCaller = PlayerController(wi.Game.AccessControl.GetControllerFromString(callername));
			if(PCaller != None){
				PCaller.ClientMessage("Player '"$playername$"' not found");
			}
		}
		return false;
	} 
	return true;
}

// ADDS OR REMOVE SLOTS TO SERVER
static function modifyServerSlots(WorldInfo wi, int numSlotToModify, bool isSpecSlot){

	if(isSpecSlot && ((wi.Game.MaxSpectators + numSlotToModify) <0)){
		return;
	}
	
	if(!isSpecSlot && ((wi.Game.MaxPlayers + numSlotToModify) <0)){
		return;
	}
	if(isSpecSlot){
		wi.Game.MaxSpectators += numSlotToModify;
		//wi.Game.NumSpectators += numSlotToModify;
	} else {
		wi.Game.MaxPlayers += numSlotToModify;
		//wi.Game.NumPlayers += numSlotToModify;
	}
}

static function bool AtCapacity(WorldInfo wi, bool bSpectator){

	local bool b;
	
	if ( bSpectator ){
		b = ( (wi.Game.NumSpectators >= wi.Game.MaxSpectators)
			&& ((true) || (wi.Game.NumPlayers > 0)) );
	} else {
		b = ( (wi.Game.GetNumPlayers() >= wi.Game.MaxPlayers) );
	}

	return b;
}

// Inspired from code in Console.uc
// Filters input String so won't save config file in a special encoding that ut3 wont be able to read later (ut3 crash)
// Only keeps char value between 32 (0x20 SPACE) and 168
// http://www.table-ascii.com/
static function String FilterChars(string Text)
{
	local int Character;
	local String s;
	local String stringFiltered;

	while (Len(Text) > 0)
	{
		s = Left(Text, 1);
		Character = Asc(s);
		Text = Mid(Text, 1);

		// Space < char < 0x100 && char != " (doublequote) && char != ' (singlequote) && comma && verticalbar && delete && backslash && forwardslash
		// 32(SPACE) --> 168(inverted question mark)
		if (Character >= 0x20 && Character < 0xA9 &&  Character != 0x22 &&  Character != 0x27 &&  Character != 0x7C &&  Character != 0x5C && Character != 0x2F)
		{
			stringFiltered $= Chr(Character);
		}
	};
	
	return stringFiltered;
}

static function bool isAllowedCmd(){
	return false;
}


