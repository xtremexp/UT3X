/*
 * An example usage of the TcpLink class
 *
 * By Michiel 'elmuerte' Hendriks for Epic Games, Inc.
 *
 * You are free to use this example as you see fit, as long as you
 * properly attribute the origin.
 *
 * TEST CLASS FOR GETTING/SENDING DATA FROM/TO WEBSITE
 * XtremeXp note: does NOT work on linux (can't open connection)
 */
class UT3XSALink extends TcpLink config(UT3XDB);
 
 
 //TODO WHEN SOME TIME
 /*
var config string TargetHost; //URL or P address of web server
var config int TargetPort; //port you want to use for the link
var string path; //path to file you want to request
var string requesttext; //data we will send
var int score; //score the player controller will send us
var bool send; //to switch between sending and getting requests
var string msg; //Message to be sent

 
event PostBeginPlay()
{
    super.PostBeginPlay();
}
 
function ResolveMe() //removes having to send a host
{
    Resolve(TargetHost);
	
	//Resolve(TargetHost);
	// After 10s force the connection to close
	// Because for buggy ut3 linux spams:
	// "Connection attempt has not yet completed."
	//setTimer(10, false, 'CloseTcp'); //@see TcpLink UT3 core class
}
 
 function CloseTcp(){
	LogInternal("Closing connection ...");
	Close();
 }
 
 function String getLocalIP2(){
	local IpAddr Addr;
	local string ipAdrStr;
	local TcpLink tcp;

	tcp = spawn(class'TcpLink');
	tcp.GetLocalIP(Addr);
	ipAdrStr = tcp.IpAddrToString(Addr);
	tcp.Destroy();

	return ipAdrStr;
}

event Resolved( IpAddr Addr )
{
    // Make sure the correct remote port is set, resolving doesn't set
    // the port value of the IpAddr structure
    Addr.Port = TargetPort;
	
	// The hostname was resolved succefully
	LogInternal("[TcpLinkClient] "$TargetHost$" resolved to "$ IpAddrToString(Addr));
	
    //dont comment out this log because it rungs the function bindport
	LogInternal("[TcpLinkClient] Server source port: "$ BindPort());

	
	LogInternal("[TcpLinkClient] Opening connection ...");
	
	// Opening connection (will call event Opened)
    if (!Open(Addr))
    {	
		LogInternal("[TcpLinkClient] Open failed");
    }
}
 
event ResolveFailed()
{
    // You could retry resolving here if you have an alternative
    // remote host.
 
    //send failed message to scaleform UI
	LogInternal(getFuncName());
}
 
// Linux ut3 version buggy at this point
// Seems not to trigger "Opened"
event Opened()
{
    // A connection was established
    //`Log("[TcpLinkClient] event opened");
    //`Log("[TcpLinkClient] Sending simple HTTP query");
     
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
    else if(true)
    {      
        requesttext = "value="$score$"&submit=10987";
 
        SendText("POST /"$path$" HTTP/1.0"$chr(13)$chr(10));
        SendText("Host: "$TargetHost$chr(13)$chr(10));
        SendText("User-Agent: HTTPTool/1.0"$Chr(13)$Chr(10));
        SendText("Content-Type: application/x-www-form-urlencoded"$chr(13)$chr(10));
        //we use the length of our requesttext to tell the server
        //how long our content is
        SendText("Content-Length: "$len(requesttext)$Chr(13)$Chr(10));
        SendText(chr(13)$chr(10));
		
        SendText(requesttext);
        SendText(chr(13)$chr(10));
		
        SendText("Connection: Close");
        SendText(chr(13)$chr(10)$chr(13)$chr(10));
    }
         
    `Log("[TcpLinkClient] end HTTP query");
}
 
event Closed()
{
    // In this case the remote client should have automatically closed
    // the connection, because we requested it in the HTTP request.
    `Log("[TcpLinkClient] event closed");
}
 
event ReceivedText( string Text )
{
	if(Len(Text) > 0){
		LogInternal("[TcpLinkClient] ReceivedText:: "$Text);
	}

    //First we will recieve data from the server via GET
    if (send == false)
    {
        send = true; //next time we resolve, we will send player score
    }
}

event ReceivedLine( string Line ){
	if(Len(Line) > 0){
		LogInternal("[TcpLinkClient] ReceivedLine:: "$Line);
	}
}
 
event ReceivedBinary( int Count, byte B[255] ){
	if(Count > 0){
		LogInternal("[TcpLinkClient] ReceivedBinary:: "$Count);
	}
} 


defaultproperties
{
    TargetHost="localhost"
    TargetPort=80 //default for HTTP
    path = "UT3XPHP/ut3x.php"
    score = 0;
    send = false;
	msg = "test";
}
*/
