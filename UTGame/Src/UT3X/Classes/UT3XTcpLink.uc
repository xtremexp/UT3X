/*
 * An example usage of the TcpLink class
 *
 * By Michiel 'elmuerte' Hendriks for Epic Games, Inc.
 *
 * You are free to use this example as you see fit, as long as you
 * properly attribute the origin.
 *
 * TEST CLASS FOR GETTING/SENDING DATA FROM/TO WEBSITE
 * XtremeXp note: does NOT work on linux (can't open connection-- blame EPIC!!!!)
 */
class UT3XTcpLink extends TcpLink;
 
 
var enum UT3XLinkMode
{
	ULM_NONE,
	ULM_EXPORTLOGS,
	ULM_EXPORTPLAYERS,
	ULM_IMPORTBANS,
	ULM_IPTOCITY
} ULM;




var PlayerController PC; //reference to our player controller


var string requesttext; //data we will send
var bool send; //to switch between sending and getting requests
var string msg; //Message to be sent
var bool enabled; // must be disabled if running on linux
var int TargetPort; //port you want to use for the link
var string TargetHost; //URL or P address of web server
var string path; //path to file you want to request
var string password;
var int autoCloseTime;


var array<UT3XPlayerInfo> players;
var array<LogData> logs;

// for ip to city
var string playername;
var string playerip;

var UT3XLinkMode ULMM;

 
event PostBeginPlay()
{
    super.PostBeginPlay();
	init();
}

function init(){
	local UT3XAC ac;
	
	ac = UT3XAC(WorldInfo.Game.AccessControl);
	
	enabled = ac.sqlLink_enabled;
	TargetPort = ac.sqlLink_port;
	TargetHost = ac.sqlLink_host;
	path = ac.sqlLink_phpfilepath;
	password = ac.sqlLink_password;
}

function getCityFromIp(string pn, string pip){

	if(pn == "" || pip == ""){
		return;
	}
	
	playername = pn;
	playerip = pip;
	
	ULM = ULM_IPTOCITY;
	
	if(!isValid()){
		`Log("UT3X TCP Link bad config. Destroying link.", ,'UT3XTcpLink');
		self.Destroy();
	} else {
		ResolveMe();
	}
}

function exportLogs(array<LogData> logss){

	ULM = ULM_EXPORTLOGS;
	
	if(!isValid()){
		`Log("UT3X TCP Link bad config. Destroying link.", ,'UT3XTcpLink');
		self.Destroy();
	} else {
		if(logss.length > 0){
			logs = logss;
			ResolveMe();
		} else {
			`Log("Log list empty. No export.", ,'UT3XTcpLink');
		}
	}
}

function exportPlayerData(array<UT3XPlayerInfo> TempPlayersLogs){

	ULM = ULM_EXPORTPLAYERS;
	
	if(!isValid()){
		`Log("UT3X TCP Link bad config. Destroying link.", ,'UT3XTcpLink');
		self.Destroy();
	} else {
		if(TempPlayersLogs.length > 0){
			players = TempPlayersLogs;
			ResolveMe();
		} else {
			`Log("Player data list empty. No export.", ,'UT3XTcpLink');
		}
	}
}

function ResolveMe() //removes having to send a host
{
	// TODO IF TCP LINK NOT CLOSED AFTER AUTOCLOSETIME
	// THEN  TCPLINK USAGE in ut3xaccesscontrol class
	setTimer(autoCloseTime, false, 'checkIsClosed');
    Resolve(targethost);
}

function checkIsClosed(){

	if(LinkState == STATE_Connecting){
		`Log("Connection problem. LinkState:"$LinkState$" Disabling UT3XTcpLink module. Enable it back in WebAdmin.", ,'UT3XTcpLink');
		UT3XAC(WorldInfo.Game.AccessControl).sqlLink_enabled = false;
		UT3XAC(WorldInfo.Game.AccessControl).SaveConfig();
	}
	CloseTcp();
}

private function bool isValid(){
	
	local bool isOK;
	
	isOK = true;
	
	if(!enabled){
		`Log("TCP Link not enabled in webadmin.",,'UT3XTcpLink');
		isOK = false;
	}
	
	if(TargetHost == ""){
		`Log("Remote Host not defined",,'UT3XTcpLink');
		isOK = false;
	}
	
	
	if(TargetPort == 0){
		`Log("Remote Port not defined",, 'UT3XTcpLink');
		isOK = false;
	}
	
	if(path == ""){
		`Log("Remote path not defined (e.g: jun/index.php)",,'UT3XTcpLink');
		isOK = false;
	}
	
	if(ULM == ULM_NONE){
		`Log("Default link mode not set.", ,'UT3XTcpLink');
		isOK = false;
	}
	
	return isOK;
}
 
 
 function CloseTcp(){
	`Log("Closing connection ...",, 'UT3XTcpLink');
	Close();
 }


event Resolved( IpAddr Addr )
{
    // Make sure the correct remote port is set, resolving doesn't set
    // the port value of the IpAddr structure
    Addr.Port = TargetPort;
	
	// The hostname was resolved succefully
	`Log(TargetHost$" resolved to "$ IpAddrToString(Addr),, 'UT3XTcpLink');
	
    //dont comment out this log because it rungs the function bindport
	`Log("Server source port: "$ BindPort(), ,'UT3XTcpLink');

	
	`Log("Opening connection ...",, 'UT3XTcpLink');
	
	// Opening connection (will call event Opened)
    if (!Open(Addr))
    {	
		`Log("Open failed",, 'UT3XTcpLink');
    }
}
 
event ResolveFailed()
{
    // You could retry resolving here if you have an alternative
    // remote host.
	`Log("Unable to resolve "$TargetHost, ,'UT3XTcpLink');
	Close();
	self.Destroy();
}
 
// Linux ut3 version buggy at this point
// Seems not to trigger "Opened"
event Opened()
{
	local IpAddr localIpAddr;
	local int serverport;
	
    // A connection was established
	`Log("Event opened",, 'UT3XTcpLink');
	`Log("Sending simple HTTP query ... ",, 'UT3XTcpLink');
     
    //The HTTP GET request
    //char(13) and char(10) are carrage returns and new lines
	/*
    if(send == false)
    {
        SendText("GET /"$path$" HTTP/1.0");
        SendText(chr(13)$chr(10));
        SendText("Host: "$TargetHost);
        SendText(chr(13)$chr(10));
        SendText("Connection: Close");
        SendText(chr(13)$chr(10)$chr(13)$chr(10));
    }*/
	
    if(ULM == ULM_EXPORTPLAYERS)
    {      
		GetLocalIP(localIpAddr);
		requesttext = class'UT3XPlayersDB'.static.playersToHtmlRequest(players);
		requesttext $= "&gameserver="$IpAddrToString(localIpAddr); //$":"$WorldInfo.Game.GetServerPort(); serverport always return nothing???
		requesttext $= "&action=exportplayers";
		sendRequest(requesttext);
    } 
	else if(ULM == ULM_IPTOCITY){
		requesttext $= "&playername="$playername$"&playerip="$playerip;
		requesttext $= "&action=iptocity";
		sendRequest(requesttext);
	} 
	else if(ULM == ULM_EXPORTLOGS){
		GetLocalIP(localIpAddr);
		requesttext = class'UT3XLog'.static.logsToHtmlRequest(logs);
		requesttext $= "&gameserver="$IpAddrToString(localIpAddr);
		requesttext $= "&action=exportlogs";
		sendRequest(requesttext);
	}
         
    `Log("[TcpLinkClient] end HTTP query",, 'UT3XTcpLink');
}


// http://net.tutsplus.com/tutorials/other/http-headers-for-dummies/
function sendRequest(String requestText){
	
	`Log("*",, 'UT3XTcpLink');
	`Log("*",, 'UT3XTcpLink');
	`Log(TimeStamp()$"-HTTP Request POST: http://"$TargetHost$Path,, 'UT3XTcpLink');
	`Log(requesttext,, 'UT3XTcpLink');
	
	//requestText = class'HttpUtil'.static.RawUrlEncode(requestText);
	requestText $= "&password="$password;
	
	SendText("POST /"$path$" HTTP/1.0"$chr(13)$chr(10));
	SendText("Host: "$TargetHost$chr(13)$chr(10));
	SendText("User-Agent: HTTPTool/1.0"$Chr(13)$Chr(10));
	SendText("Content-Type: application/x-www-form-urlencoded"$chr(13)$chr(10));
	SendText("Content-Length: "$len(requesttext)$Chr(13)$Chr(10));
	SendText(chr(13)$chr(10));
	SendText(requesttext);
	SendText(chr(13)$chr(10));
	SendText("Connection: Close");
	SendText(chr(13)$chr(10)$chr(13)$chr(10));
}
 
event Closed()
{
    // In this case the remote client should have automatically closed
    // the connection, because we requested it in the HTTP request.
    `Log("Link closed",, 'UT3XTcpLink');
	self.Destroy();
}
 
event ReceivedText( string Text )
{
	local array<string> ip2citysplit;
	local IPTOCITY ip2city;
	local String loginMessage;
	
	if(Len(Text) > 0){
		Text = Split(Text, chr(13)$chr(10)$chr(13)$chr(10), true);
		
		`Log("*",, 'UT3XTcpLink');
		`Log("*",, 'UT3XTcpLink');
		`Log(TimeStamp()$"- "$ULM$" - HTTP Response:",, 'UT3XTcpLink');
		
		
		// SELECT           countrycode, region, city FROM iptocountry
		// return  $ip."|".$row[0]."|".$row[1]."|".$row[2]."|".$_POST['playername'];
		if(ULM == ULM_IPTOCITY && Len(Text) > 1){
			class'UT3XLib'.static.Split2(Text, "|", ip2citysplit);
			
			// if in list then location displayed in ut3xac.notifylogin
			if(UT3XAC(WorldInfo.Game.AccessControl).iptocitycache.find('ip', ip2citysplit[0]) == -1){
				ip2city.ip = ip2citysplit[0];
				ip2city.countrycode = ip2citysplit[1];
				ip2city.region = ip2citysplit[2];
				ip2city.city = ip2citysplit[3];
				
				UT3XAC(WorldInfo.Game.AccessControl).iptocitycache.addItem(ip2city);
				loginMessage $= ip2citysplit[4]$" near "$ip2city.city$" ("$ip2city.region$","$ip2city.countrycode$")";
				loginMessage $= " entered the server.";
				WorldInfo.Game.Broadcast(self, loginMessage);
			}
		}
		
		`Log(Text,, 'UT3XTcpLink');
	}

    //First we will recieve data from the server via GET
    if (send == false)
    {
        send = true; //next time we resolve, we will send player score
    }
}

event ReceivedLine( string Line ){
	if(Len(Line) > 0){
		`Log("ReceivedLine:"$Line,, 'UT3XTcpLink');
	}
}
 
event ReceivedBinary( int Count, byte B[255] ){
	if(Count > 0){
		`Log("[TcpLinkClient] ReceivedBinary:: ",, 'UT3XTcpLink');
	}
} 


defaultproperties
{
	autoCloseTime = 10:
	enabled = false;
	ULM = ULM_NONE;
    TargetHost="www.google.fr"
    TargetPort=80;; //default for HTTP
    path = "jun/index.php"
    send = false;
	msg = "test";
}
