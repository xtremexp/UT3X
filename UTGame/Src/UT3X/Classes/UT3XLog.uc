/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XLog extends Info config(UT3XLog);

/** How many days the logs should be kept */
var config int maxDaysLogRetentionTime;
var config int maxDaysLogKickRetentionTime;
var config int maxLogLines;


var enum LogType
{
	LT_CHATLOG, // Logging chat logs
	LT_PMCHAT, // Private Messaging Chat
	LT_DEMOREC, // DEMOREC start
	LT_WALOGIN, // WebAdmin Login/Logout
	LT_ADMINLOGIN, // AdminLogin/Logout
	LT_LAGDETECTOR,
	LT_KICK,
	LT_KICKBAN,
	LT_WARN, // PLayer get a warning from admin
	LT_KICKVOTE, // PLAYER KICK VOTING
	LT_MAPVOTE, // WHICH MAP HAS BEEN VOTED (@TODO)
	LT_MUTE,
	LT_MUTEBAN, // Admin ban muting
	LT_ACCESS, // Prelogin, login, logout ...
	LT_REPORT, // !report
	LT_REQUEST, // !admin
	LT_SERVERSTART, // When server start (when ut3x mutator first loaded generally) //@TODO
	LT_MAPCHANGE, //  (@TODO)
	LT_OTHER // other stuff that is not in the other sections
} LT;

struct LogData
{
	var String ts; // Time of log (timestamp)
	var int timeSec; // Time of log in seconds (since 2011-01-01)
	var LogType LT; // Log Type (ban, mute, ...)
	var String srcPN; // Admin, Player (chatlog)
	var String destPN; // Banned Player
	var String data; // for chat log or extra info for ban and kicks
	var String haData; // only data that should be only visible for head admins in ut3 webadmin ...
	var bool haOnly; // if not head admin then this log should not appear in webadmin
};

// Remove this once SQL export fully operational ...
var config array<LogData> Logs;

// Log that will be exported to SQL database ...
var array<LogData> SQLLogs;

function static String toCsv(LogData log){
	
	return log.ts$";"$log.timeSec$";"$log.LT$";"$log.srcPN$";"$log.destPN$";"$log.data$";"$log.haData;
}


// In order to avoid some lags, save the logfile every 2 minutes
// instead of saving at each new log entry
event PostBeginPlay(){
	super.PostBeginPlay();
	setTimer(120.0, true, 'saveLogs');
}

function saveLogs(){
	SaveConfig();
}


// TODO no char filter if export SQL
function addLog(LogType LTT, optional String srcPN, optional String destPN, optional String data, optional string haData, optional bool haOnly){

	local LogData LD;
	
	LD.LT = LTT;
	LD.ts = TimeStamp();
	LD.timeSec = class'HttpUtil'.static.utimestamp3(); //class'UT3XLib'.static.getGlobalSecondsFromTimeStamp(TimeStamp());
	LD.srcPN = class'UT3XLib'.static.FilterChars(srcPN);
	LD.destPN = class'UT3XLib'.static.FilterChars(destPN);
	LD.data = class'UT3XLib'.static.FilterChars(data);
	LD.haData = class'UT3XLib'.static.FilterChars(haData);
	LD.haOnly = haOnly;
	
	if(LTT == LT_MAPCHANGE){
		LD.data $= "- UT3X v"$UT3XAC(WorldInfo.Game.AccessControl).mut.UT3XVersion;
	}

	if(LTT == LT_PMCHAT){
		// do not log private messages for privacy reasons
		return;
	}
	Logs.addItem(LD);
	SQLLogs.addItem(LD);
}

function static String logsToHtmlRequest(array<LogData> logs){
	
	local string s;
	local int i;
	
	LogInternal(logs.length);
	
	for(i=0; i < logs.length; i++){
		s $= logToHtmlRequest(logs[i], i);

		if(i < (logs.length -1)){
			s $= "&";
		}
	}
	
	return s;
}

// pn_name=4x4x&pn_uniqueid=01231354313&pn_lastprelogin=1359053891
function static String logToHtmlRequest(LogData log, int numLog){

	local string s;
	local string x;
	
	x = "["$numLog$"]";

	s =  "log_time"$x$"="$log.timeSec;
	s $= "&log_type"$x$"="$log.LT;
	s $= "&log_srcpn"$x$"="$(log.srcPN!="")?class'HttpUtil'.static.RawUrlEncode(log.srcPN):"";
	s $= "&log_destpn"$x$"="$(log.destPN!="")?class'HttpUtil'.static.RawUrlEncode(log.destPN):"";
	s $= "&log_data"$x$"="$(log.data!="")?class'HttpUtil'.static.RawUrlEncode(log.data):"";
	s $= "&log_ha"$x$"="$(log.haData!="")?class'HttpUtil'.static.RawUrlEncode(log.haData):"";
	
	return s;
}

// Removes old logs and when too many lines
// then save the config file
// Called at End Game: AccessControl.Tick
function GlobalSave(){

	local int i, count;
	local UT3XTcpLink tl;
	local int todaySec, minTimeSec, minTimeSecKick;
	
	if(UT3XAC(WorldInfo.Game.AccessControl).sqlLink_exportLogs){
		LogInternal("Exporting logs to SQL of "$SQLLogs.length$" logs ...");
		tl = Spawn(class'UT3XTcpLink'); //spawn the class
		tl.exportLogs(SQLLogs);
	}
	
	if(maxDaysLogRetentionTime < 1){
		maxDaysLogRetentionTime = 1;
	}
	todaySec = class'HttpUtil'.static.utimestamp3();//class'UT3XLib'.static.getGlobalSecondsFromTimeStamp(TimeStamp());
	minTimeSec = todaySec - (maxDaysLogRetentionTime * 24 * 3600);
	minTimeSecKick = todaySec - (maxDaysLogKickRetentionTime * 24 * 3600);
	
	for(i=(Logs.length-1); i>=0; i--){
		
		
		// Log too old, need to delete it
		// Or too many lines
		if( (Logs[i].timeSec < minTimeSec) || (count>maxLogLines)){
			if(Logs[i].LT != LT_KICK && Logs[i].LT != LT_KICKBAN && Logs[i].LT != LT_MUTEBAN || Logs[i].srcPN == "UT3X-BOT"){ 
				Logs.removeItem(Logs[i]);
			}
			
			// REMOVES KICK LOGS
			if(Logs[i].LT == LT_KICK || Logs[i].LT == LT_KICKBAN || Logs[i].LT == LT_MUTEBAN){
				if(Logs[i].timeSec < minTimeSecKick){
					Logs.removeItem(Logs[i]);
				}
			}
		}
		count ++;
	}
	
	SaveConfig();
}

defaultproperties
{
	maxDaysLogRetentionTime=4; // 4 days
	maxDaysLogKickRetentionTime = 60; // 60 days
	maxLogLines=12000;
}
