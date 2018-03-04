/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XCountries extends Info config (UT3XCountries);
/*
	Retrieve latest IP database here: http://software77.net/geo-ip/
	
*/
struct IP2C
{
	var byte A, B, C, D ; //IP_FROM e.g.: 128.45.123.42
	var byte E, F, G, H; //IP_TO
	var String CC2; //Country Code 2 - FR
	var String CC3; //Country Code 3 - FRA
	var String CN; //Country Name -Always Empty in ini file (got it from CC2CN)
	//var int ASN; // Autonomous System Number
};

// GET COUNTRY NAME FROM COUNTRY CODE
// M=(CC=ITA,CC2="IT",CN="Italy", CP="Rome", POP=60340328, CCY="Euro")
struct CC2CN
{
	var String CC; // E.G (FRA for France)
	var String CC2; // E.G. (FR for France) (for country textures ...)
	var String CN;
};

// Auton
struct ASD
{
	var int num; // Number (ex: AS8073 -> 8073)
	var String name;
};




// @TODO CACHING DOESN'T WORK
// When PreLogin (AccessControl.PreLogin -> UT3X.PreLogin)
// Server ever retrieved the country of player (looking into thousands of lines of UT3XCountries.ini)
// Then it's better to cache ip
// IP;"ip2.IP1$":"$ip2.IP2$":"$ip2.CC2$":"$ip2.CC3$":"$ip2.CN"$$":"$ip2.LG
var array<String> ipToCountryCache;
var config array<IP2C> L;
var config array<CC2CN> M;
var config array<ASD> A;

// separator is same so avoid doing multiple split (performance)
// 128.128.0.0.128.128.255.255.FR.FRA.France:French
function String IP2CToString(IP2C ip2){
	local String str;
	
	str = getIpStartString(ip2)$"."$getIpEndString(ip2)$"."$ip2.CC2$"."$ip2.CC3$"."$ip2.CN;
	
	return str;
}


function IP2C StringToIP2C(String ip2cStr){

	local IP2C ip2cc;
	local array<String> s;
	
	// 128.128.0.0.128.128.255.255.FR.FRA.France:French
	class'UT3XLib'.static.Split2(ip2cStr, ".", s);

	ip2cc.A = byte(s[0]);
	ip2cc.B = byte(s[1]);
	ip2cc.C = byte(s[2]);
	ip2cc.D = byte(s[3]);
	
	ip2cc.E = byte(s[4]);
	ip2cc.F = byte(s[5]);
	ip2cc.G = byte(s[6]);
	ip2cc.H = byte(s[7]);
	
	ip2cc.CC2 = s[8];
	ip2cc.CC3 = s[9];
	ip2cc.CN = s[10];
	
	return ip2cc;
}



static final function array<byte> ipToBytes(String ipAddr){
	
	local array<String> s;
	local array<byte> x;
	
	
	//local array<string> data, datePart, timePart;
    //local int i;
    //local float tzoff;
    //datestring = trim(datestring);
	ParseStringIntoArray(ipAddr, s, ".", false);
    //split(ipAddr, ".", s);
	
	//class'UT3XLib'.static.Split2(ipAddr, ".", s);
	x[0] = byte(s[0]);
	x[1] = byte(s[1]);
	x[2] = byte(s[2]);
	x[3] = byte(s[3]);
	
	return x;
}

function bool isInIPNumberRange(array<byte> s, IP2C ipc){
	
	
	return s[0] >= ipc.A && s[1] >= ipc.B && s[2] >= ipc.C && s[3] >= ipc.D 
		&& s[0] <= ipc.E && s[1] <= ipc.F && s[2] <= ipc.G && s[3] <= ipc.H;
}

// returns IP;"ip2.IP1$":"$ip2.IP2$":"$ip2.CC2$":"$ip2.CC3$":"$ip2.CN"$$":"$ip2.LG
function String getCountryStrDataFromIP(String ipAddr){
	local IP2C ipc;
	local int x;
	ipc = getCountryDataFromIP(ipAddr);
	
	x = M.Find('CC', ipc.CC3);
	if(x != -1){
		ipc.CN = M[x].CN;
		ipc.CC2 = M[x].CC2;
	}
	
	return IP2CToString(ipc);
}

function CC2CN getCountryInfoFromIP(String ipAddr){

	local int x;
	local IP2C ipc;
	local CC2CN ccc;
	
	ipc = getCountryDataFromIP(ipAddr);
	x = M.Find('CC', ipc.CC3);
	
	if(x != -1){
		return M[x];
	}
	
	return ccc;
}

// random for anonymouzz
function IP2C getCountryDataFromIP(String ipAddr, optional bool randomCountry){
	local int x;
	local int Idx;
	local IP2C ipc;
	local array<byte> ipAddrBytes;
	//local String str;
	
	//ipNumber = IPToIPNumber(ipAddr);
	

	// Prevents reading again the thousands of lines of UTUT3XCountries.ini file ...
	if(hasIpInCountryCache(ipAddr, ipc)){
		return ipc;
	}
	
	ipAddrBytes = ipToBytes(ipAddr);
	
	
	for(Idx=0; Idx < L.length; Idx ++){
		ipc = L[Idx];
		
		if(isInIPNumberRange(ipAddrBytes, ipc)){
			x = M.Find('CC', ipc.CC3);

			if(x != -1){
				ipc.CN = M[x].CN;
				ipc.CC2 = M[x].CC2;
			}
			addCountryInCache(ipAddr, ipc);
			return ipc;
		}
	}
	
	return ipc;

}

function addCountryInCache(String ipNumber, IP2C ip2cc){
	local String str;

	str = ipNumber$";"$IP2CToString(ip2cc);
	ipToCountryCache.addItem(str);
}

function bool hasIpInCountryCache(string ipNumber, out IP2C ip2cc){
	
	local int i;
	local array<String> split;
	

	for(i=0; i<ipToCountryCache.length; i++){
		class'UT3XLib'.static.Split2(ipToCountryCache[i], ";", split);
		
		if(split[0] == ipNumber){
			ip2cc = StringToIP2C(split[1]);
			return true;
		}
	}
	return false;
}


function String getCountryNameFromIP(String ipAddr){
	return getCountryDataFromIP(ipAddr).CN;
}




function array<byte> getIpRangeBytesFromIP(String ipAddr){
	local IP2C ipcc;
	local array<byte> x;

	ipcc = getCountryDataFromIP(ipAddr);
	x[0] = ipcc.A;
	x[1] = ipcc.B;
	x[2] = ipcc.C;
	x[3] = ipcc.D;
	
	x[4] = ipcc.E;
	x[5] = ipcc.F;
	x[6] = ipcc.G;
	x[7] = ipcc.H;
	
	return x;
}

// have to do that
// because can't access IP2C struct from UT3XAC ...
// for optimization
function String getCountryDataSplitFromIP(String ipAddr){
	local IP2C ipcc;

	ipcc = getCountryDataFromIP(ipAddr);
	
	return getIpStartString(ipcc)$"."$getIpEndString(ipcc)$"."$ipcc.cc2$"."$ipcc.cc3;
}

static function String getIpStartString(IP2C x){
	return x.A$"."$x.B$"."$x.C$"."$x.D;
}

static function String getIpEndString(IP2C x){
	return x.E$"."$x.F$"."$x.G$"."$x.H;
}

function String getCC3FromIP(String ipAddr){
	return getCountryDataFromIP(ipAddr).CC3;
}

