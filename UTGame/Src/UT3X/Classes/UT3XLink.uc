/*
 * An example usage of the TcpLink class
 *
 * By Michiel 'elmuerte' Hendriks for Epic Games, Inc.
 *
 * You are free to use this example as you see fit, as long as you
 * properly attribute the origin.
 * TEST CLASS FOR GETTING/SENDING DATA FROM/TO WEBSITE
 * XtremeXp note: does NOT work on linux (can't open connection)
 */
 
class UT3XLink extends TcpLink;
 
var PlayerController PC; //reference to our player controller
var string TargetHost; //URL or P address of web server
var int TargetPort; //port you want to use for the link
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
	//TargetHost = getLocalIp2();
	//TargetPort = 7777;
	PC.ClientMessage("TESTTCP ... will auto-close connection in 10s");
	PC.ClientMessage("Resolving ..."@TargetHost);
    Resolve(TargetHost);
	//Resolve(TargetHost);
	// After 10s force the connection to close
	// Because for buggy ut3 linux spams:
	// "Connection attempt has not yet completed."
	setTimer(10, false, 'CloseTcp'); //@see TcpLink UT3 core class
}
 
 function CloseTcp(){
	PC.ClientMessage("Closing connection ...");
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
	PC.ClientMessage("[TcpLinkClient] "$TargetHost$" resolved to "$ IpAddrToString(Addr));
	
    //dont comment out this log because it rungs the function bindport
	PC.ClientMessage("[TcpLinkClient] Server source port: "$ BindPort());

	
	PC.ClientMessage("[TcpLinkClient] Opening connection ...");
	
	// Opening connection (will call event Opened)
    if (!Open(Addr))
    {	
		PC.ClientMessage("[TcpLinkClient] Open failed");
    }
}
 
event ResolveFailed()
{
    // You could retry resolving here if you have an alternative
    // remote host.
 
    //send failed message to scaleform UI
	PC.ClientMessage("[TcpLinkClient] Unable to resolve "$TargetHost);
}
 
// Linux ut3 version buggy at this point
// Seems not to trigger "Opened"
event Opened()
{
    // A connection was established
	PC.ClientMessage("[TcpLinkClient] event opened");
	PC.ClientMessage("Sending message ... "@msg);
}
 
event Closed()
{
    // In this case the remote client should have automatically closed
    // the connection, because we requested it in the HTTP request.
    `Log("[TcpLinkClient] event closed");
	PC.ClientMessage("[TcpLinkClient] event closed");
}
 
event ReceivedText( string Text )
{
	if(Len(Text) > 0){
		PC.ClientMessage("[TcpLinkClient] ReceivedText:: "$Text);
	}

    //First we will recieve data from the server via GET
    if (send == false)
    {
        send = true; //next time we resolve, we will send player score
    }
}

event ReceivedLine( string Line ){
	if(Len(Line) > 0){
		PC.ClientMessage("[TcpLinkClient] ReceivedLine:: "$Line);
	}
}
 
event ReceivedBinary( int Count, byte B[255] ){
	if(Count > 0){
		PC.ClientMessage("[TcpLinkClient] ReceivedBinary:: "$Count);
	}
} 


defaultproperties
{
    TargetHost="www.google.fr"
    TargetPort=80 //default for HTTP
    path = "jun/index.php"
    score = 0;
    send = false;
	msg = "test";
}
