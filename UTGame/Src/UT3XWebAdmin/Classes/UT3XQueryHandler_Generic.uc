/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
/**
* Inspired FROM Epic WebAdmin code And TitanTeamFix WebAdmin Code
*/
Class UT3XQueryHandler_Generic extends UT3XQueryHandler
	implements(IQueryHandler);

var WebAdmin				WebAdmin;		// Cached instance of the webadmin object

//var UT3XSettings			TTFSettingsObj;		// An instance of the class which handles TTF's main settings

//var UT3XSettingsRenderer		TTFSettingsRenderer;	// A settings renderer specifically for TTF config profiles

var deprecated bool			bTODO;

const UT3XWebAdminVersion="170";
const UT3XWebAdminDate="10/12/2013";




/**
 * Will hold a sorted player replication info list. Ripped from original WebAdmin code ...
 */
var array<PlayerReplicationInfo> sortedPRI;

function Init(WebAdmin WebApp)
{
	WebAdmin = WebApp;

	//TTFSettingsObj = new Class'UT3XSettings';
	//TTFSettingsObj.SetSpecialValue('WebAdmin_Init', "");

}

// Clean up any actor and other references etc. here
function Cleanup()
{
	WebAdmin = none;
	//TTFSettingsObj = none;
	//TTFSettingsRenderer = none;
}

// TELLS IF YOU ARE HEAD ADMIN
function bool isHeadAdmin(WebAdminQuery Q){
	//LogInternal("XXX: "$WebAdmin.getAuthURL(Q.Request.URI$"/UT3XHeadAdmin"));
	return Q.user.canPerform(WebAdmin.getAuthURL(Q.Request.URI$"/UT3XHeadAdmin")); // user IWebAdminUser
}

function bool HandleQuery(WebAdminQuery Q)
{
	switch (Q.Request.URI)
	{
		case "/UT3X":
			UT3XConfigQuery(Q);
			return True;
		
		case "/UT3X/UT3XPlayers":
			UT3XPlayersQuery(Q);
			return True;
		
		case "/UT3X/UT3XAFKChecker":
			UT3XAFKCheckerQuery(Q);
			return True;
			
		// DISPLAY ALL BANS HASHBAN, IPBAN, UT3XBANS(by playername)
		case "/UT3X/UT3XBans":
			UT3XBansQuery(Q);
			return True;
			
		// DISPLAY ALL BANS HASHBAN, IPBAN, UT3XBANS(by playername)
		case "/UT3X/UT3XAdverts":
			UT3XAdvertsQuery(Q);
			return True;
			
		// DISPLAY ALL BANS HASHBAN, IPBAN, UT3XBANS(by playername)
		case "/current/UT3XCurrentPlayers":
			UT3XCurrentplayersQuery(Q);
			return True;
		
		// TELL IF ADMIN IS HEADADMIN
		case "/UT3X/UT3XHeadAdmin":
			UT3XHeadAdminQuery(Q);
			return True;
			
		case "/UT3X/UT3XSounds":
			UT3XSoundsQuery(Q);
			return True;
			
		case "/UT3X/UT3XSmileys":
			UT3XSmileysQuery(Q);
			return True;
			
		case "/UT3X/UT3XLogs":
			UT3XLogsQuery(Q);
			return True;
			
		case "/UT3X/UT3XLangChecker":
			UT3XLangCheckerQuery(Q);
			return True;
			
		case "/UT3X/UT3XBalancer":
			UT3XBalancerQuery(Q);
			return True;
			
		case "/UT3X/UT3XHeadAdmin/SQLLink":
			UT3XSQLLinkQuery(Q);
			return True;
	}

	return False;
}

// @TODO MERGE SOME MENUS
function RegisterMenuItems(WebAdminMenu Menu)
{
	Menu.AddMenu("/UT3X", "UT3X", Self, "UT3X Settings", 1);
	Menu.AddMenu("/UT3X/UT3XPlayers?noautosearch=1", "Players Database", Self, "Players Database", 1);
	Menu.AddMenu("/UT3X/UT3XBans", "Bans", Self, "UT3X Bans", 1);
	Menu.AddMenu("/UT3X/UT3XAdverts", "Adverts", Self, "Adverts", 1);
	Menu.AddMenu("/current/UT3XCurrentPlayers", "Players (ut3x)", Self, "Players", 1);
	Menu.AddMenu("/UT3X/UT3XAFKChecker", "AFK Settings", Self, "AFK Settings", 1);
	Menu.AddMenu("/UT3X/UT3XHeadAdmin", "Head Admin", Self, "You are headadmin!", 1);
	menu.addMenu("/UT3X/UT3XHeadAdmin/SQLLink", "SQL Link", Self, "SQL Link", 1);
	//Menu.AddMenu("/UT3X/UT3XSmileys", "Smileys", Self, "Smileys", 1); // DISABLE NEED TO FIX
	Menu.AddMenu("/UT3X/UT3XSounds", "Zounds", Self, "Sound Text", 1);
	Menu.AddMenu("/UT3X/UT3XLogs", "Logs", Self, "Server Logs", 1);
	Menu.AddMenu("/UT3X/UT3XLangChecker", "Language Checker", Self, "Language Checker", 1);
	Menu.AddMenu("/UT3X/UT3XBalancer", "Balancer", Self, "Team Balancer", 1);
}

function UT3XBalancerQuery(WebAdminQuery q)
{
	local string CurAction, msg, tmp, t, tt;
	local int i, j, tmpInt;
	local UT3XTeamBalancer tb;
	local String minScoreDiff, maxScoreDiff, minTotalPlayers, maxTotalPlayers, numPlayersBoosted, numScoreDiff;
	local array<String> BalanceActions;
	local ScoreDiffAction SDA;
	
	tb = ut3xmut.tb;
	
	if(tb == None){
		webadmin.addMessage(Q, "Team Balancer module is not active. Activate it.", MT_Warning);
		WebAdmin.SendPage(Q, "blank.html");
		return;
	}
	CurAction = Q.Request.GetVariable("action");

	minScoreDiff = Q.Request.GetVariable("minScoreDiff");
	maxScoreDiff = Q.Request.GetVariable("maxScoreDiff");
	minTotalPlayers = Q.Request.GetVariable("minTotalPlayers");
	maxTotalPlayers = Q.Request.GetVariable("maxTotalPlayers");
	numPlayersBoosted = Q.Request.GetVariable("numPlayersBoosted");
	tmpInt = Q.Request.GetVariableCount("BalanceActionn");
	numScoreDiff = Q.Request.GetVariable("numScoreDiff");
		
	for(i=tmpInt-1; i>=0; i--){
		tmp = Q.Request.GetVariableNumber("BalanceActionn", i);
		//LogInternal(Q.Request.GetVariableNumber("BalanceActionn", i));
		BalanceActions.addItem(tmp);
	}
		
	if (CurAction ~= "ADD"){
		msg = tb.addScoreDiffAction(int(minScoreDiff), int(maxScoreDiff), int(minTotalPlayers), int(maxTotalPlayers), int(numPlayersBoosted), BalanceActions);
		
		if(msg ==""){
			webadmin.addMessage(Q, "Balancer option have been added");
		} else {
			webadmin.addMessage(Q, "Could not add balancer option. Reason:"$msg, MT_Warning);
		}
	} else if (CurAction ~= "save"){
		SDA = tb.scoreDiffActions[int(numScoreDiff)];
		SDA.minScoreDiff = int(minScoreDiff);
		SDA.maxScoreDiff = int(maxScoreDiff);
		SDA.minTotalPlayers = int(minTotalPlayers);
		SDA.maxTotalPlayers = int(maxTotalPlayers);
		SDA.numPlayersBoosted = int(numPlayersBoosted);
		SDA.balanceActions = tb.toBalanceAction(BalanceActions);
		
		tt = tb.isValidScoreDiffAction(SDA); 
		
		if(tt == ""){
			tb.scoreDiffActions[int(numScoreDiff)] = SDA;
			tb.SaveConfig();
			webadmin.addMessage(Q, "Balancer option have been saved");
		} else {
			webadmin.addMessage(Q, "Could not save balancer option. Reason:"$tt, MT_Warning);
		}
	} else if (CurAction ~= "delete"){
		tb.scoreDiffActions.removeItem(tb.scoreDiffActions[int(numScoreDiff)]);
		tb.SaveConfig();
	} else if(CurAction ~= "save_global"){
		tb.allowSwitchToWinningTeam = ("on" == Q.Request.GetVariable("allowSwitchToWinningTeam"));
		tb.maxScoreDiffToSwitchToWinningTeam = int( Q.Request.GetVariable("maxScoreDiffToSwitchToWinningTeam"));
		tb.SaveConfig();
	}
	
	for(i=0; i < tb.scoreDiffActions.length; i++){
		if ( (i % 2) == 0) q.response.subst("evenodd", "even");
		else q.response.subst("evenodd", "odd");
		tmp = "";
		q.response.subst("balancer.minScoreDiff", tb.scoreDiffActions[i].minScoreDiff);
		q.response.subst("balancer.maxScoreDiff", tb.scoreDiffActions[i].maxScoreDiff);
		q.response.subst("balancer.minTotalPlayers", tb.scoreDiffActions[i].minTotalPlayers);
		q.response.subst("balancer.maxTotalPlayers", tb.scoreDiffActions[i].maxTotalPlayers);
		q.response.subst("balancer.numPlayersBoosted", tb.scoreDiffActions[i].numPlayersBoosted);
		
		for(j=0; j< tb.scoreDiffActions[i].BalanceActions.length; j ++){
			tmp $= tb.scoreDiffActions[i].BalanceActions[j]$",";
		}
		q.response.subst("balancer.balanceactions", tmp);
		q.response.subst("balancer.numScoreDiff", i);
		t $= WebAdmin.include(q, "UT3X_Balancer_Row.inc");
	}
	
	q.response.subst("balancer.allowSwitchToWinningTeam", (tb.allowSwitchToWinningTeam?"checked='checked'":""));
	q.response.subst("balancer.maxScoreDiffToSwitchToWinningTeam", tb.maxScoreDiffToSwitchToWinningTeam);
	q.response.subst("balancer.scorediffactions", t);
	WebAdmin.SendPage(Q, "UT3X_Balancer.html");
}

function UT3XLangCheckerQuery(WebAdminQuery q)
{
	local UT3XLanguageChecker lc;
	local string CurAction, word,  weight, t, result;
	local int i, numBadWord;
	
	lc = ut3xmut.acc.lc;
	
	if(lc == None){
		webadmin.addMessage(Q, "Language checker module is not active. Activate it.", MT_Warning);
		WebAdmin.SendPage(Q, "blank.html");
		return;
	}
	
	CurAction = Q.Request.GetVariable("action");

	if (CurAction ~= "save"){
		numBadWord = int(Q.Request.GetVariable("numBadWord"));
		word = Q.Request.GetVariable("word");
		weight = Q.Request.GetVariable("weight");
		
		if(numBadWord > lc.badWords.length){
			webadmin.addMessage(Q, "Num BadWord index invalid", MT_Error);
		} else {
			lc.badWords[numBadWord].word = word;
			lc.badWords[numBadWord].weight = int(weight);
			
			if(lc.badWords[numBadWord].weight <= 0){
				lc.badWords[numBadWord].weight = 1;
			}
			lc.SaveConfig();
			webadmin.addMessage(Q, "BadWord have been saved!");
		}
	} else if (CurAction ~= "ADD"){
		numBadWord = int(Q.Request.GetVariable("numBadWord"));
		word = Q.Request.GetVariable("word");
		weight = Q.Request.GetVariable("weight");
		
		result = lc.addBadWord(word, int(weight));
		if(result == ""){
			webadmin.addMessage(Q, "BadWord have been successfully added");
		} else {
			webadmin.addMessage(Q, "Could not add bad word: "$result, MT_Error );
		}
	} else if (CurAction ~= "delete") {
		numBadWord = int(Q.Request.GetVariable("numBadWord"));
		lc.badWords.RemoveItem(lc.badWords[numBadWord]);
		ut3xMut.us.SaveConfig();
		webadmin.addMessage(Q, "Bad word successfully deleted!");
	} 
	
	for(i=0; i < lc.badWords.length; i++){
		if ( (i % 2) == 0) q.response.subst("evenodd", "even");
		else q.response.subst("evenodd", "odd");
		
		q.response.subst("word", lc.badWords[i].word);
		q.response.subst("weight", lc.badWords[i].weight);
		q.response.subst("LG", lc.badWords[i].LG);
		q.response.subst("numBadWord", i);
		t $= WebAdmin.include(q, "UT3X_LangChecker_Row.inc");
	}
	
	q.response.subst("badwords.list", t);
	q.response.subst("minWeightToWarn", lc.minWeightToWarn);
	q.response.subst("minWeightToKick", lc.minWeightToKick);
	
	WebAdmin.SendPage(Q, "UT3X_LangChecker.html");
}

function UT3XSmileysQuery(WebAdminQuery q)
{
	local string CurAction, smileyText, smileyTexture, result, t, bOnlyAdminUsage;
	local int i, numSmiley;
	
	
	if(ut3xMut.usm == None){
		webadmin.addMessage(Q, "Smiley module is not active. Activate it.", MT_Warning);
		WebAdmin.SendPage(Q, "blank.html");
		return;
	}
	
	CurAction = Q.Request.GetVariable("action");

	
	if (CurAction ~= "save"){
		numSmiley = int(Q.Request.GetVariable("numsmiley"));
		smileyText = Q.Request.GetVariable("smileyText");
		smileyTexture = Q.Request.GetVariable("smileyTexture");
		bOnlyAdminUsage  = Q.Request.GetVariable("bonlyadminusage");
		
		if(numSmiley > ut3xMut.usm.smileysList.length){
			webadmin.addMessage(Q, "Num Smiley index invalid", MT_Error);
		} else {
			ut3xMut.usm.smileysList[numSmiley].smileyText = smileyText;
			ut3xMut.usm.smileysList[numSmiley].smileyTexture = Texture2D(DynamicLoadObject(smileyTexture, class'Texture2D'));
			ut3xMut.usm.smileysList[numSmiley].bOnlyAdminUsage = (bOnlyAdminUsage=="0"?false:true);
			ut3xMut.usm.SaveConfig();
			webadmin.addMessage(Q, "Smileys have been saved!");
		}
	} else if (CurAction ~= "ADD"){
		smileyText = Q.Request.GetVariable("smileyText");
		smileyTexture = Q.Request.GetVariable("smileyTexture");
		bOnlyAdminUsage = Q.Request.GetVariable("bonlyadminusage");
		
		result = ut3xMut.usm.addSmiley(smileyText, smileyTexture, (bOnlyAdminUsage=="0"?false:true));
		if(result == ""){
			webadmin.addMessage(Q, "Smiley have been successfully added");
		} else {
			webadmin.addMessage(Q, "Could not add smiley: "$result, MT_Error );
		}
	} else if (CurAction ~= "delete") {
		numSmiley = int(Q.Request.GetVariable("numSmiley"));
		ut3xMut.usm.smileysList.RemoveItem(ut3xMut.usm.smileysList[numSmiley]);
		ut3xMut.usm.SaveConfig();
		webadmin.addMessage(Q, "Smiley successfully deleted!");
	} 
	
	for(i=0; i < ut3xMut.usm.smileysList.length; i++){
		q.response.subst("ut3x.smileys.smileyText", ut3xMut.usm.smileysList[i].smileyText);
		q.response.subst("ut3x.smileys.smileyTexture", ut3xMut.usm.smileysList[i].smileyTexture);
		q.response.subst("ut3x.smileys.bonlyadminusage", (ut3xMut.usm.smileysList[i].bonlyadminusage?"1":"0") );
		q.response.subst("ut3x.smileys.numSmiley", i);
		t $= WebAdmin.include(q, "UT3X_Smileys_Row.inc");
	}
	
	q.response.subst("ut3x.smileys.list", t);
	WebAdmin.SendPage(Q, "UT3X_Smileys.html");
}


function UT3XSoundsQuery(WebAdminQuery q)
{
	local string CurAction, soundMsg, soundClassName, result, t, bOnlyAdminUsage;
	local int i, numSound;
	
	if(ut3xMut.us == None){
		webadmin.addMessage(Q, "Zounds module is not active. Activate it.", MT_Warning);
		WebAdmin.SendPage(Q, "blank.html");
		return;
	}
	
	CurAction = Q.Request.GetVariable("action");

	
	if (CurAction ~= "save"){
		numSound = int(Q.Request.GetVariable("numsound"));
		soundMsg = Q.Request.GetVariable("soundMsg");
		soundClassName = Q.Request.GetVariable("soundclassname");
		bOnlyAdminUsage  = Q.Request.GetVariable("bonlyadminusage");
		
		if(numSound > ut3xMut.us.soundsList.length){
			webadmin.addMessage(Q, "Num Sound index invalid", MT_Error);
		} else {
			ut3xMut.us.soundsList[numSound].soundMsg = soundMsg;
			ut3xMut.us.soundsList[numSound].soundClassName = soundClassName;
			ut3xMut.us.soundsList[numSound].bOnlyAdminUsage = (bOnlyAdminUsage=="0"?false:true);
			ut3xMut.us.SaveConfig();
			webadmin.addMessage(Q, "Sounds have been saved!");
		}
	} else if (CurAction ~= "ADD"){
		soundMsg = Q.Request.GetVariable("soundMsg");
		soundClassName = Q.Request.GetVariable("soundclassname");
		bOnlyAdminUsage = Q.Request.GetVariable("bonlyadminusage");
		
		result = ut3xMut.us.addSound(soundMsg, soundClassName, (bOnlyAdminUsage=="0"?false:true));
		if(result == ""){
			webadmin.addMessage(Q, "Sound have been successfully added");
		} else {
			webadmin.addMessage(Q, "Could not add sound: "$result, MT_Error );
		}
	} else if (CurAction ~= "delete") {
		numSound = int(Q.Request.GetVariable("numsound"));
		ut3xMut.us.soundsList.RemoveItem(ut3xMut.us.soundsList[numSound]);
		ut3xMut.us.SaveConfig();
		webadmin.addMessage(Q, "Sound successfully deleted!");
	} 
	
	for(i=0; i < ut3xMut.us.soundsList.length; i++){
		q.response.subst("ut3x.sounds.soundmsg", ut3xMut.us.soundsList[i].soundMsg);
		q.response.subst("ut3x.sounds.soundclassname", ut3xMut.us.soundsList[i].soundClassName);
		q.response.subst("ut3x.sounds.bonlyadminusage", (ut3xMut.us.soundsList[i].bonlyadminusage?"1":"0") );
		q.response.subst("ut3x.sounds.numsound", i);
		t $= WebAdmin.include(q, "UT3X_Sounds_Row.inc");
	}
	
	q.response.subst("ut3x.sounds.list", t);
	WebAdmin.SendPage(Q, "UT3X_Sounds.html");
}




function UT3XHeadAdminQuery(WebAdminQuery q)
{
	local array<SocketDataPacketType> socketsInfo;
	local array<TcpLink> tcpLinks;
	local array<TcpipConnection> ncs;
	local UT3XAC ac;
	local UT3XDefaultMap udm;
	local int i, numKickRule;
	local string t, action;
	local string label, ka, banDuration, kaRepeat, banDurationRepeat, maxTimeForRepeat, bNoLog, bNoLogRepeat;
	local string objectname, objectclass;
	local Object obj;
	local class<object> NewClass;
	local UTMapListManager uml;
	local array<string> mapLists;
	
	uml = UTGame(webadmin.WorldInfo.Game).MapListManager;

	
	action = Q.Request.GetVariable("action");
	
	ac = ut3xMut.acc;
	udm = ut3xMut.udm;
	
	if (action ~= "add"){
		label = Q.Request.GetVariable("label");
		ka = Q.Request.GetVariable("kickAction");
		banDuration = Q.Request.GetVariable("banDuration");
		bNoLog  = Q.Request.GetVariable("bNoLog");
		
		karepeat = Q.Request.GetVariable("kickActionRepeat");
		banDurationRepeat = Q.Request.GetVariable("banDurationRepeat");
		bNoLogRepeat  = Q.Request.GetVariable("bNoLogRepeat");
		
		maxTimeForRepeat = Q.Request.GetVariable("maxTimeForRepeat");
		
		ac.addKickRule(label, ka, banDuration, (bNoLog=="on"?true:false), kaRepeat, banDurationRepeat, (bNoLogRepeat=="on"?true:false), maxTimeForRepeat);
	} else if (action ~= "delete"){
		numKickRule = int(Q.Request.GetVariable("numKickRule"));
		ac.kickrules.removeItem(ac.kickrules[numKickRule]);
		ac.SaveConfig();
	} else if(action ~= "findobject"){
		objectname = Q.Request.GetVariable("objectname");
		objectclass = Q.Request.GetVariable("objectclass");
		NewClass = class<object>( DynamicLoadObject( objectclass, class'Class' ) );
		
		q.response.subst("objectname", objectname);
		q.response.subst("objectclass", objectclass);
		
		obj = FindObject( objectname, NewClass  ); //class'TcpipConnection'
		
		if(NewClass != None){
			webadmin.addMessage(Q, "Class"@objectclass@"found.");
		} else {
			webadmin.addMessage(Q, "Class"@objectclass@"not found.", MT_Error );
		}
		
		if(obj != None){
			webadmin.addMessage(Q, "Object '"$obj$"' "$PathName(obj)$" found.");
		} else {
			webadmin.addMessage(Q, "Object "$objectname$" not found.", MT_Error );
		}
	} else if(action ~= "createobject"){
	
		objectclass = Q.Request.GetVariable("objectclass");
		NewClass = class<object>( DynamicLoadObject( objectclass, class'Class' ) );
		q.response.subst("objectclass", objectclass);
		
		NewClass = class<object>( DynamicLoadObject( objectclass, class'Class' ) );
		obj = FindObject( objectname, NewClass  ); //class'TcpipConnection'
		
		if(NewClass == None){
			webadmin.addMessage(Q, "Class"@objectclass@"not found.", MT_Error );
		} else {
			if(class<actor>(NewClass) != None){
				obj = WebAdmin.WorldInfo.spawn(class<actor>(NewClass));
			} else {
				obj = new(self) NewClass;
			}
			
			
			if(obj == None){
				webadmin.addMessage(Q, "Could not create object", MT_Error );
			} else {
				webadmin.addMessage(Q, "Object '"$obj$"' "$PathName(obj)$" can be created.");
				LogInternal("Path="$class'Object'.static.PathName(obj));
				if(Actor(obj) != None){
					Actor(obj).Destroy();
				}
				obj = None; // DESTROYING OK??
			}
		}
				
	} else if(action ~= "saveMapListConfig"){
	
		if(udm !=None){
			if(WebAdmin.WorldInfo.MapExists(Q.Request.GetVariable("defaultMap"))){
				udm.defaultMap = Q.Request.GetVariable("defaultMap");
			} else {
				webadmin.addMessage(Q, "Default map "$Q.Request.GetVariable("defaultMap")$" is not valid", MT_Error );
			}
			
			udm.secondsBeforeSwitch = int(Q.Request.GetVariable("secondsBeforeSwitch"));
			udm.noSwitchIfServerPassworded = ("on" == Q.Request.GetVariable("noSwitchIfServerPassworded"));
			udm.SaveConfig();
		} else {
			webadmin.addMessage(Q, "Default Map module is not activated in global settings.", MT_Error );
		}
		if(UT3XMapListManager(uml) != None){
			if(UT3XMapListManager(uml).existsMapListByName2(Q.Request.GetVariable("mapListName_0_12"))){
				UT3XMapListManager(uml).mapListName_0_12 = Name(Q.Request.GetVariable("mapListName_0_12"));
			} else {
				webadmin.addMessage(Q, Q.Request.GetVariable("mapListName_0_12")$" maplist does not exist", MT_Error );
			}
			
			if(UT3XMapListManager(uml).existsMapListByName2(Q.Request.GetVariable("mapListName_13_20"))){
				UT3XMapListManager(uml).mapListName_13_20 = Name(Q.Request.GetVariable("mapListName_13_20"));
			} else {
				webadmin.addMessage(Q, Q.Request.GetVariable("mapListName_13_20")$" maplist does not exist", MT_Error );
			}
			
			if(UT3XMapListManager(uml).existsMapListByName2(Q.Request.GetVariable("mapListName_21_64"))){
				UT3XMapListManager(uml).mapListName_21_64 = Name(Q.Request.GetVariable("mapListName_21_64"));
			} else {
				webadmin.addMessage(Q, Q.Request.GetVariable("mapListName_21_64")$" maplist does not exist", MT_Error );
			}
			
			uml.SaveConfig();
		}
	}
	
	for(i=0; i < ac.kickRules.length; i++){
		q.response.subst("kickrule.label", ac.kickRules[i].label);
		
		q.response.subst("kickrule.kickaction", ac.kickRules[i].ka);
		q.response.subst("kickrule.banduration", ac.kickRules[i].banduration);
		q.response.subst("kickrule.bnolog", ac.kickRules[i].bnolog?"checked='checked'":"");
		
		q.response.subst("kickrule.kickactionrepeat", ac.kickRules[i].karepeat);
		q.response.subst("kickrule.bandurationrepeat", ac.kickRules[i].bandurationrepeat);
		q.response.subst("kickrule.bnologrepeat", ac.kickRules[i].bnologrepeat?"checked='checked'":"");
		
		q.response.subst("kickrule.maxTimeForRepeat", ac.kickRules[i].maxTimeForRepeat);
		
		q.response.subst("kickrule.numKickRule", i);
		
		t $= WebAdmin.include(q, "UT3X_HeadAdmin_KickRules_row.inc");
	}
	
	q.response.subst("ut3x.kickrules.list", t);
	
	t = "";
	class'UT3XWALib'.static.getTcpLinks(WebAdmin.WorldInfo, tcpLinks);
	class'UT3XWALib'.static.getNetConnections(ncs);
	
	for(i=0; i<tcpLinks.length; i++){
		q.response.subst("tcpLinks.LinkState", tcpLinks[i].LinkState);
		q.response.subst("tcpLinks.LinkMode", tcpLinks[i].LinkMode);
		q.response.subst("tcpLinks.InLineMode", tcpLinks[i].InLineMode);
		q.response.subst("tcpLinks.OutLineMode", tcpLinks[i].OutLineMode);
		q.response.subst("tcpLinks.ReceiveMode", tcpLinks[i].ReceiveMode);
		q.response.subst("tcpLinks.RemoteAddr", webadmin.WebServer.IpAddrToString(tcpLinks[i].RemoteAddr));
		q.response.subst("tcpLinks.AcceptClass", tcpLinks[i].AcceptClass);
		q.response.subst("tcpLinks.SendFIFO", tcpLinks[i].SendFIFO.length);
		q.response.subst("tcpLinks.RecvBuf", tcpLinks[i].RecvBuf);

		t $= WebAdmin.include(q, "UT3X_TCPLinks_row.inc");
	}
	Q.Response.Subst("tcplinks.list", t);
	
	t = "";
	
	/*
	for(i=0; i<ncs.length; i++){
		if(ncs.actor != None){
			q.response.subst("sockets.PlayerName", ncs[i].PlayerController.PlayerReplicationInfo.PlayerName);
		} else {
			q.response.subst("sockets.PlayerName", "?");
		}
		q.response.subst("sockets.PlayerIP", "?");
		q.response.subst("sockets.PlayerPort", "?");
		
		q.response.subst("sockets.ConnectionState", socketsInfo[i].ConnectionState);
		q.response.subst("sockets.DLFile", socketsInfo[i].DLFile);
		q.response.subst("sockets.TextChannels", socketsInfo[i].TextChannels);
		q.response.subst("sockets.ActorChannels", socketsInfo[i].ActorChannels);
		q.response.subst("sockets.FileChannels", socketsInfo[i].FileChannels);
		q.response.subst("sockets.OtherChannels", socketsInfo[i].OtherChannels);
		t $= WebAdmin.include(q, "UT3X_Sockets_row.inc");
	}*/
	Q.Response.Subst("sockets.list", t);
	
	
	if(udm != None){
		Q.Response.Subst("defaultmap", udm.defaultMap);
		Q.Response.Subst("secondsBeforeSwitch", udm.secondsBeforeSwitch);
		Q.Response.Subst("noSwitchIfServerPassworded", (udm.noSwitchIfServerPassworded?"checked='checked'":""));
	}
	
	
	for(i=0; i<uml.GameProfiles.length ; i++){
		if(uml.GameProfiles[i].GameClass == "UTGameContent.UTVehicleCTFGame_Content"){
			Q.Response.Subst("ActiveMapList", uml.GameProfiles[i].MapListName);
		}
	}
	
	if(UT3XMapListManager(uml) != None){
		mapLists = UT3XMapListManager(uml).getMapLists();
		Q.Response.Subst("mapListName_0_12", UT3XMapListManager(uml).mapListName_0_12);
		Q.Response.Subst("mapListName_13_20", UT3XMapListManager(uml).mapListName_13_20);
		Q.Response.Subst("mapListName_21_64", UT3XMapListManager(uml).mapListName_21_64);
	}
	
	t = "";
	
	for(i=0; i< mapLists.length; i++){
		q.response.subst("mapListName", mapLists[i]);
		t $= WebAdmin.include(q, "UT3X_MapListName_row.inc");
	}
	

	Q.Response.Subst("ut3x.mapLists", t);

	
	WebAdmin.SendPage(Q, "UT3X_HeadAdmin.html");
}

function UT3XAFKCheckerQuery(WebAdminQuery q)
{
	local string CurAction;
	local string AFKWarningSeconds,AFKForceSpecSeconds,AFKMinPlayers,AFKKickSeconds,AFKMsgPrefix,minFreeSpecSlotAFKCheck;
	
	if(ut3xMut.afkc == None){
		webadmin.addMessage(Q, "AFK Checker module is not active. Activate it.", MT_Warning);
		WebAdmin.SendPage(Q, "blank.html");
		return;
	}
	
	CurAction = Q.Request.GetVariable("action");
	

	if (CurAction ~= "save"){
		AFKWarningSeconds = Q.Request.GetVariable("AFKWarningSeconds");
		AFKForceSpecSeconds = Q.Request.GetVariable("AFKForceSpecSeconds");
		AFKMinPlayers = Q.Request.GetVariable("AFKMinPlayers");
		AFKKickSeconds = Q.Request.GetVariable("AFKKickSeconds");
		AFKMsgPrefix = Q.Request.GetVariable("AFKMsgPrefix");
		minFreeSpecSlotAFKCheck = Q.Request.GetVariable("minFreeSpecSlotAFKCheck");
	
		ut3xMut.afkc.noAFKKickIfOnWinningTeam = ("on" == Q.Request.GetVariable("noAFKKickIfOnWinningTeam"));
		ut3xMut.afkc.AFKMsgPrefix = AFKMsgPrefix;
		ut3xMut.afkc.AFKForceSpecSeconds = int(AFKForceSpecSeconds);
		ut3xMut.afkc.AFKWarningSeconds = int(AFKWarningSeconds);
		ut3xMut.afkc.AFKMinPlayers = int(AFKMinPlayers);
		ut3xMut.afkc.AFKKickSeconds = int(AFKKickSeconds);
		ut3xMut.afkc.minFreeSpecSlotAFKCheck = int(minFreeSpecSlotAFKCheck);
		ut3xMut.afkc.SaveConfig();
		webadmin.addMessage(Q, "AFK settings have been saved!");
	}
	
	q.response.subst("ut3x.afk.msgprefix", ut3xMut.afkc.AFKMsgPrefix);
	q.response.subst("ut3x.afk.forcespecseconds", ut3xMut.afkc.AFKForceSpecSeconds);
	q.response.subst("ut3x.afk.warningseconds", ut3xMut.afkc.AFKWarningSeconds);
	q.response.subst("ut3x.afk.minplayers", ut3xMut.afkc.AFKMinPlayers);
	q.response.subst("ut3x.afk.kickseconds", ut3xMut.afkc.AFKKickSeconds);
	q.response.subst("ut3x.afk.minFreeSpecSlotAFKCheck", ut3xMut.afkc.minFreeSpecSlotAFKCheck);
	q.response.subst("ut3x.afk.noAFKKickIfOnWinningTeam", (ut3xMut.afkc.noAFKKickIfOnWinningTeam?"checked='checked'":""));
	
	WebAdmin.SendPage(Q, "UT3X_AFK.html");
}

function UT3XCurrentPlayersQuery(WebAdminQuery q)
{
	local Controller P;
	local PlayerController PC, PC2;
	local UT3XPCABS UT3XPCC;
	local UT3XPlayerReplicationInfo UPRI;
	local int i, numKickRule;
	local KickRule KR;
	local string msg, tmp;

	local string t, IP, CurAction, secondsNum, secondsType, PlayerID, error;

	CurAction = Q.Request.GetVariable("action");
	PlayerID = Q.Request.GetVariable("PlayerID");
	secondsNum = Q.Request.GetVariable("secondsNum");
	secondsType = Q.Request.GetVariable("secondsType");
	
	if(CurAction != ""){
		PC2 = PlayerController(WebAdmin.WorldInfo.Game.AccessControl.GetControllerFromString(PlayerID));
		
		numKickRule = ut3xMut.acc.kickrules.find('label', CurAction);
		
		
		if(numKickRule != -1){
			KR = ut3xMut.acc.kickrules[numKickRule];
			ut3xMut.acc.applyKickAction(Q.user.getUserid(), PC2, CurAction);
			msg = "Action was applied to player"$ PC2.PlayerReplicationInfo.PlayerName$":"$ut3xMut.acc.KickRuleToString(KR);

			webadmin.addMessage(Q, msg);
		} else {
			webadmin.addMessage(Q, "No action applied");
		}
	}
	
	secondsNum $= secondsType;

	
	foreach WebAdmin.WorldInfo.AllControllers(class'Controller', P)
	{
		tmp = "";
		if (!P.bDeleteMe && P.PlayerReplicationInfo != None && P.bIsPlayer)
		{
			if ( P.PlayerReplicationInfo.bBot)
			{
				continue;
			}
			if (DemoRecSpectator(P) != none)
			{
				// never mess with this one
				continue;
			}
			if(PlayerController(P) != None){
				PC = PlayerController(P);
			}
			IP = PC.GetPlayerNetworkAddress();
			IP = Left(IP, InStr(IP, ":"));
			
			q.response.subst("ut3x.currentplayer.name", class'WebAdminUtils'.static.HTMLEscape(P.PlayerReplicationInfo.PlayerName));
			q.response.subst("ut3x.currentplayer.ping", P.PlayerReplicationInfo.ping * 4);
			q.response.subst("ut3x.currentplayer.packetloss", P.PlayerReplicationInfo.packetloss);
			if(P.PlayerReplicationInfo.packetloss >= 0){
				q.response.subst("cssclasspacketloss", "yellow");
			}
			q.response.subst("ut3x.currentplayer.clantag", UTPlayerReplicationInfo(P.PlayerReplicationInfo).clanTag);
			q.response.subst("ut3x.currentplayer.ip", IP);
			q.response.subst("ut3x.currentplayer.playerid", P.PlayerReplicationInfo.PlayerID);
			q.response.subst("ut3x.currentplayer.uniqueid", class'OnlineSubsystem'.static.UniqueNetIdToString(P.PlayerReplicationInfo.UniqueId));
			
			if(PC != None){
				q.response.subst("ut3x.currentplayer.hash", PC.HashResponseCache);
			}
			if(P.PlayerReplicationInfo.Team != None){
				q.response.subst("player.teamcolor", class'WebAdminUtils'.static.ColorToHTMLColor(P.PlayerReplicationInfo.Team.GetHUDColor()));
			} else {
				q.response.subst("player.teamcolor", "transparent");
			}
			
			if(UT3XPlayerReplicationInfo(P.PlayerReplicationInfo) != None){
				UPRI = UT3XPlayerReplicationInfo(P.PlayerReplicationInfo);
				q.response.subst("ut3x.currentplayer.country", UPRI.countryInfo.CC3);
				q.response.subst("ut3x.currentplayer.countryname", UPRI.countryInfo.CN);
				q.response.subst("ut3x.currentplayer.isafk", (UPRI.isAfk?"X":""));
				q.response.subst("ut3x.currentplayer.computerNameMD5", UT3XPC(P).computerNamee);
				//q.response.subst("ut3x.currentplayer.computerTime", UT3XPC(P).getLocalTime()); // disabled for perf / lag issues
				q.response.subst("ut3x.currentplayer.serverTime", TimeStamp());
			}

			
			q.response.subst("ut3x.currentplayer.isadmin", (P.PlayerReplicationInfo.bAdmin?"X":""));
			q.response.subst("ut3x.currentplayer.isspec", (P.PlayerReplicationInfo.bIsSpectator?"X":""));
			
			
			for(i=0; i< ut3xMut.acc.KickRules.length ;i++){
				q.response.subst("ut3x.bantype.label", ut3xMut.acc.KickRules[i].label);
				q.response.subst("ut3x.bantype.extrainfo", " - "$ut3xMut.acc.KickRules[i].ka);
				
				tmp $= WebAdmin.include(q, "UT3X_BansReasons_Option.inc");
			}
			q.response.subst("ut3x.banreasons", tmp);
			t $= WebAdmin.include(q, "UT3X_CurrentPlayers_Row.inc");
		}
	}
	
	q.response.subst("ut3x.currentplayers.list", t);
	WebAdmin.SendPage(Q, "UT3X_CurrentPlayers.html");
}

function int GetHexDigit(string D)
{
	switch(caps(D))
	{
	case "0": return 0;
	case "1": return 1;
	case "2": return 2;
	case "3": return 3;
	case "4": return 4;
	case "5": return 5;
	case "6": return 6;
	case "7": return 7;
	case "8": return 8;
	case "9": return 9;
	case "A": return 10;
	case "B": return 11;
	case "C": return 12;
	case "D": return 13;
	case "E": return 14;
	case "F": return 15;
	}

	return -1;
}

// DRAWCOLOR = "#XXYYZZ"
function Color HTMLColorToColor(string HtmlColor){

	local String Rs,Gs,Bs;
	local int R,G,B;

	HtmlColor = Right(HtmlColor, Len(HtmlColor) -1); // removes '#'
	
	Rs = Left(HtmlColor,2);
	HtmlColor = Right(HtmlColor, Len(HtmlColor) -2);
	
	Gs = Left(HtmlColor,2);
	HtmlColor = Right(HtmlColor, Len(HtmlColor) -2);
	
	Bs = Left(HtmlColor,2);

	R = GetHexDigit(Left(Rs, 1))*16 + GetHexDigit(Right(Rs, 1));
	G = GetHexDigit(Left(Gs, 1))*16 + GetHexDigit(Right(Gs, 1));
	B = GetHexDigit(Left(Bs, 1))*16 + GetHexDigit(Right(Bs, 1));

	return MakeColor(R, G, B, 255);
}


function UT3XAdvertsQuery(WebAdminQuery Q){

	local int i, tmpInt;
	local float tmpFloat;
	local string t, CurAction, currentIdMessage;
	local string newMessage, DrawColor,LifeTime, FontSize, Position;
	
	CurAction = Q.Request.GetVariable("action");
	newMessage = Q.Request.GetVariable("newMessage");
	DrawColor = Q.Request.GetVariable("DrawColor");
	LifeTime = Q.Request.GetVariable("LifeTime");
	FontSize = Q.Request.GetVariable("FontSize");
	Position = Q.Request.GetVariable("Position");
	
	
	if(ut3xMut.ad == None){
		webadmin.addMessage(Q, "The adverts module is not activated. Please activate it though webadmin.", MT_Warning);
		WebAdmin.SendPage(Q, "blank.html");
		return;
	}
	
	// addMessage(String MsgStr, string adminName, float Position, float LifeTime, float FontSize, Color DrawColor){
	
	if (CurAction ~= "ADD"){ // CREATE ADVERT
		if(newMessage != ""){
			if(Len(newMessage) < 255){
				// String MsgStr, string adminName, float Position, float LifeTime, float FontSize, Color DrawColor
				tmpFloat = float(LifeTime);
				if(tmpFloat <= 0){
					tmpFloat = 4;
				}
				ut3xMut.ad.addMessage(newMessage, Q.user.getUserid(), float(Position), tmpFloat, int(FontSize), HTMLColorToColor(DrawColor));
				ut3xMut.ad.SaveConfig();
				webadmin.addMessage(Q, "Advert sucessfully added!");
			} else {
				webadmin.addMessage(Q, "Message length must not be above 255 chars!", MT_Error);
			}
		} else {
			webadmin.addMessage(Q, "Message must not be empty!", MT_Error);
		}
	} else if (CurAction ~= "delete"){ // DELETE ADVERT
		currentIdMessage = Q.Request.GetVariable("IDMsg");
		ut3xMut.ad.Messages.RemoveItem(ut3xMut.ad.Messages[int(currentIdMessage)]);
		ut3xMut.ad.SaveConfig();
		webadmin.addMessage(Q, "Message successfully deleted!");
	} else if (CurAction ~= "save"){
		currentIdMessage = Q.Request.GetVariable("IDMsg");
		
		for(i=0; i < ut3xMut.ad.Messages.length; i++){
			if(i == int(currentIdMessage)){
				ut3xMut.ad.Messages[i].Msg = Q.Request.GetVariable("message");
				ut3xMut.ad.Messages[i].DrawColor = HTMLColorToColor(DrawColor);
				ut3xMut.ad.Messages[i].Position = float(Position);
				if(float(LifeTime)>0){
					ut3xMut.ad.Messages[i].LifeTime = float(LifeTime);
				}
				ut3xMut.ad.Messages[i].FontSize = float(FontSize);
				ut3xMut.ad.Messages[i].lastmodified = TimeStamp();
				ut3xMut.ad.Messages[i].modifiedby = Q.user.getUserid();
				ut3xMut.ad.SaveConfig();
				webadmin.addMessage(Q, "Message successfully saved!");
			}
		}
	} else if (CurAction ~= "saveGlobal"){ // GLOBAL SETTING
		tmpInt = int(Q.Request.GetVariable("displayDelay"));
		if(tmpInt < 10){
			tmpInt = 10;
		}
		ut3xMut.ad.displayDelay = tmpInt;
		ut3xMut.ad.bBasicDisplay = ("on"==Q.Request.GetVariable("bBasicDisplay"));
		ut3xMut.ad.SaveConfig();
		webadmin.addMessage(Q, "Settings successfully saved!");
	}
	
	
	for(i=0; i < ut3xMut.ad.Messages.length; i++){
		q.response.subst("ut3x.adverts.message", ut3xMut.ad.Messages[i].Msg);
		q.response.subst("ut3x.adverts.addedon", ut3xMut.ad.Messages[i].StartDate);
		q.response.subst("ut3x.adverts.admin", ut3xMut.ad.Messages[i].admin);
		q.response.subst("ut3x.adverts.LifeTime", ut3xMut.ad.Messages[i].LifeTime);
		q.response.subst("ut3x.adverts.FontSize", ut3xMut.ad.Messages[i].FontSize);
		q.response.subst("ut3x.adverts.Position", ut3xMut.ad.Messages[i].Position);
		q.response.subst("ut3x.adverts.idMsg", i);
		q.response.subst("ut3x.adverts.drawcolor", class'WebAdminUtils'.static.ColorToHTMLColor(ut3xMut.ad.Messages[i].DrawColor));
		q.response.subst("ut3x.adverts.lastmodified", ut3xMut.ad.Messages[i].lastmodified);
		q.response.subst("ut3x.adverts.modifiedby", ut3xMut.ad.Messages[i].modifiedby);
		t $= WebAdmin.include(q, "UT3X_Adverts_Row.inc");
	}
	

	q.response.subst("ut3x.adverts.displayDelay", ut3xMut.ad.displayDelay);
	q.response.subst("ut3x.adverts.bBasicDisplay", (ut3xMut.ad.bBasicDisplay?"checked='checked'":""));

	q.response.subst("ut3x.adverts.list", t);
	WebAdmin.SendPage(Q, "UT3X_Adverts.html");
}

// SHOW ALL BANNED PLAYERS
function UT3XBansQuery(WebAdminQuery Q){

	local int i;
	local int j, numKickAction;
	local int secondsBanRemaining;
	local string t, CurAction, bannedPlayer, banType, desactivatedReason, error;
	local String newbanplayername, newbanip, newbanuniqueid, newbancdkeyhash, newbanreason, newbantype;
	local String newbancompname, newbancompname2, newbancompname3;
	local String tmp;
	local array<string> newCompsNameBanned;
	local UT3XBan ub;
	local UT3XPC PC;
	local UniqueNetID uid;
	local BannedHashInfo bHashInfo;
	local BannedInfo bInfo;
	local KickRule kr;
	local bool isPermanentBan;
	local String computersBanned;
	
	CurAction = Q.Request.GetVariable("action");
	bannedPlayer = Q.Request.GetVariable("bannedPlayer");
	banType = Q.Request.GetVariable("banType");
	desactivatedReason = Q.Request.GetVariable("desactivatedReason");

	if(CurAction ~= "addban"){
		newbanplayername  = Q.Request.GetVariable("newbanplayername");
		newbanip  = Q.Request.GetVariable("newbanip");
		newbanuniqueid  = Q.Request.GetVariable("newbanuniqueid");
		newbancdkeyhash  = Q.Request.GetVariable("newbancdkeyhash");
		
		tmp = Q.Request.GetVariable("newbancompname");
		newCompsNameBanned.addItem(tmp);
		
		tmp = Q.Request.GetVariable("newbancompname2");
		newCompsNameBanned.addItem(tmp);
		
		tmp = Q.Request.GetVariable("newbancompname3");
		newCompsNameBanned.addItem(tmp);


		newbanreason = Q.Request.GetVariable("newbanreason");
		newbantype = Q.Request.GetVariable("newbantype");
		numKickAction = ut3xMut.acc.kickrules.find('label', newbanreason);
		if(numKickAction != -1){
			kr = ut3xMut.acc.kickrules[numKickAction];
			webadmin.addMessage(Q, "Default action "$kr.ka$" has been applied to player");
		}
		
		
		//if(newbantype == "BT_UT3XBANMUTE" || newbantype == "BT_UT3XBAN" ){
		if(kr.ka != KA_NONE){
		
			PC = class'UT3XLib'.static.getUT3XPC(webadmin.worldinfo, newbanplayername, newbanuniqueid, newbancdkeyhash, newbancompname, newbanip);
			
			if(kr.ka  == KA_KICKBAN || kr.ka == KA_BANMUTE || kr.ka == KA_KICKPERMBAN  || kr.ka == KA_PERMBANMUTE){
			
				if(kr.ka == KA_KICKPERMBAN  || kr.ka == KA_PERMBANMUTE){
					isPermanentBan = true;
				}

				// ACTIVE BAN - WE NEED TO UPDATE IT
				if(ut3xMut.acc.isUT3XBanned(newbanplayername, newbanip, newbanuniqueid, newbancompname, ub)){
					webadmin.addMessage(Q, "There is ever an active ban for this player:"$ut3xMut.acc.BanToString(ub), MT_Error);
				} 
				// CREATE NEW BAN
				else {
					ut3xMut.acc.PlayersBan.addItem(ut3xMut.acc.initBanInfo(kr.ka== KA_BANMUTE?true:false, isPermanentBan, Q.user.getUserid(), newbanplayername, kr.banduration, newbanreason, newbanuniqueid, newbancdkeyhash, newCompsNameBanned));
					ut3xMut.acc.SaveConfig(); 
					webadmin.addMessage(Q, "New ban was sucessfully added!"$(isPermanentBan?"Permanent ban":"Ban end:"$ut3xMut.acc.PlayersBan[ut3xMut.acc.PlayersBan.length-1].endTS));
				}
			} else if(kr.ka == KA_KICK) {
				if(PC!= None){
					ut3xMut.acc.UTPKick(Q.user.getUserid(),  PC, , kr.label, kr.bNoLog);
				} else {
					webadmin.addMessage(Q, "Player not founds. Default action: KICK", MT_Error);
				}
				//UTPKick("",  kickedPlayer, , newbanreason, kr.bNoLog);
			} else if(kr.ka == KA_MUTE){
				if(PC!= None){
					ut3xMut.acc.UTPMutePlayer(PC.PlayerReplicationInfo.PlayerName, true, false, false, Q.user.getUserid(), , newbanreason);
				} else {
					webadmin.addMessage(Q, "Player not founds. Default action: MUTE", MT_Error);
				}
			}
		} else {
			webadmin.addMessage(Q, "Default action "$kr.ka$" has been applied to player");
		}
	}
	else if(CurAction ~= "saveBanSettings"){
		if(isHeadAdmin(Q)){
			ut3xMut.acc.maxDaysBanDuration = int(Q.Request.GetVariable("maxDaysBanDuration"));
			ut3xMut.acc.kickbanextramsg = Q.Request.GetVariable("kickbanextramsg");
			ut3xMut.acc.minSecondsFakePlayerBeforeKick = int(Q.Request.GetVariable("minSecondsFakePlayerBeforeKick"));
			ut3xMut.acc.bAnonymousAdmin = ("on" == Q.Request.GetVariable("bAnonymousAdmin"));
			ut3xMut.acc.kickFakePlayers = ("on" == Q.Request.GetVariable("kickFakePlayers"));
			ut3xMut.acc.anonymousAdminName = Q.Request.GetVariable("anonymousAdminName");
			ut3xMut.acc.SaveConfig();
			webadmin.addMessage(Q, "Settings saved!");
		}else {
			webadmin.addMessage(Q, "Only head administrators can changed these settings!", MT_Error);
		}
	} else if (CurAction ~= "delete" && banType != "" ){
		if(banType == "BT_UT3XBAN"){
			error = ut3xMut.acc.RemoveBan("", Q.user.getUserid(), desactivatedReason, int(q.request.getVariable("banid")), true);
			if(error == ""){
				webadmin.addMessage(Q, "The ban was sucessfully removed!");
			} else {
				webadmin.addMessage(Q, "Could not delete the ban. Reason:"$error, MT_Error);
			}
		} else if(banType == "BT_UID"){
			i = int(q.request.getVariable("banid"));
			webadmin.addMessage(Q, "UID ban was sucessfully removed");
			webadmin.worldinfo.game.accesscontrol.BannedPlayerInfo.RemoveItem(webadmin.worldinfo.game.accesscontrol.BannedPlayerInfo[i]);
		} else if(banType == "BT_UT3XBANMUTE"){
			error = ut3xMut.acc.UTPMutePlayer(bannedPlayer, false, true, false, Q.user.getUserid());
			if(error == ""){
				webadmin.addMessage(Q, bannedPlayer@"was sucessfully unmuted!");
			} else {
				webadmin.addMessage(Q, "Could not unmute"@bannedPlayer@"Reason:"@error, MT_Error);
			}
		} 
		else if(banType == "BT_HASH"){
			i = int(q.request.getVariable("banid"));
			webadmin.addMessage(Q, "Hash ban "$webadmin.worldinfo.game.accesscontrol.BannedHashes[i].BannedHash$" was sucessfully removed");
			webadmin.worldinfo.game.accesscontrol.BannedHashes.RemoveItem(webadmin.worldinfo.game.accesscontrol.BannedHashes[i]);
		} 
		else if(banType == "BT_IP"){
			i = int(q.request.getVariable("banid"));
			webadmin.addMessage(Q, "IP ban "$webadmin.worldinfo.game.accesscontrol.IPPolicies[i]$" was sucessfully removed");
			webadmin.worldinfo.game.accesscontrol.IPPolicies.RemoveItem(webadmin.worldinfo.game.accesscontrol.IPPolicies[i]);
		}
		webadmin.worldinfo.game.accesscontrol.SaveConfig();
	}
	
	q.response.subst("ut3x.maxDaysBanDuration", ut3xMut.acc.maxDaysBanDuration);
	q.response.subst("ut3x.kickbanextramsg", ut3xMut.acc.kickbanextramsg);
	q.response.subst("ut3x.anonymousAdminName", ut3xMut.acc.anonymousAdminName);
	q.response.subst("ut3x.bAnonymousAdmin", (ut3xMut.acc.bAnonymousAdmin?"checked='checked'":""));
	q.response.subst("ut3x.kickFakePlayers", (ut3xMut.acc.kickFakePlayers?"checked='checked'":""));

	
	q.response.subst("ut3x.minSecondsFakePlayerBeforeKick", (ut3xMut.acc.minSecondsFakePlayerBeforeKick));
	q.response.subst("ut3x.tabSelected", int(Q.Request.GetVariable("tabSelected")));
	
	// UT3X BAN (and mute bans)
	for(i=0; i < ut3xMut.acc.PlayersBan.length; i++){

		computersBanned = "";
		
		if ( (j % 2) == 0) q.response.subst("evenodd", "even");
		else q.response.subst("evenodd", "odd");
		
		q.response.subst("ut3x.ban.playerBanned", ut3xMut.acc.PlayersBan[i].playerBanned);
		q.response.subst("ut3x.ban.admin", ut3xMut.acc.PlayersBan[i].bannedBy);
		q.response.subst("ut3x.ban.startTS", ut3xMut.acc.PlayersBan[i].startTS);
		if(!ut3xMut.acc.PlayersBan[i].bPermanent){
			q.response.subst("ut3x.ban.endTS", ut3xMut.acc.PlayersBan[i].endTS);
		} else {
			q.response.subst("ut3x.ban.endTS", "None. (Perm ban)");
		}
		q.response.subst("ut3x.ban.banType", ut3xMut.acc.PlayersBan[i].BT);
		q.response.subst("ut3x.ban.reason", ut3xMut.acc.PlayersBan[i].reason);
		q.response.subst("ut3x.ban.banId", ut3xMut.acc.PlayersBan[i].startSec);
		
		secondsBanRemaining = ut3xMut.acc.PlayersBan[i].endSec - class'HttpUtil'.static.utimestamp3();

		if(!ut3xMut.acc.PlayersBan[i].bPermanent){
			q.response.subst("ut3x.ban.duration", class'UT3XLib'.static.secondsToDateLength(ut3xMut.acc.PlayersBan[i].endSec - ut3xMut.acc.PlayersBan[i].startSec));
		} else {
			q.response.subst("ut3x.ban.duration", "&infin;");
		}
		
		if(ut3xMut.acc.PlayersBan[i].bPermanent){
			q.response.subst("ut3x.ban.remainingTime", "&infin;");
		} else {
			if(secondsBanRemaining <= 0){
				q.response.subst("ut3x.ban.remainingTime", "0s");
			} else {
				q.response.subst("ut3x.ban.remainingTime", class'UT3XLib'.static.secondsToDateLength(secondsBanRemaining));
			}
		}
		

		q.response.subst("ut3x.ban.uniqueIdBanned", ut3xMut.acc.PlayersBan[i].uniqueIdBanned);
		
		// Computer Name Hashes
		for(j=0; j < ut3xMut.acc.PlayersBan[i].compsNameBanned.length; j++){
			q.response.subst("ut3xplayer.comphash", class'WebAdminUtils'.static.HTMLEscape(ut3xMut.acc.PlayersBan[i].compsNameBanned[j]));
			computersBanned $= WebAdmin.include(q, "UT3X_row_computer.inc");
		}
		
		// Deprecated now use multi comp name ban
		/*
		if(ut3xMut.acc.PlayersBan[i].compNameBanned != ""){
			q.response.subst("ut3xplayer.comphash", class'WebAdminUtils'.static.HTMLEscape(ut3xMut.acc.PlayersBan[i].compNameBanned));
			computersBanned $= WebAdmin.include(q, "UT3X_row_computer.inc");
		}*/
		
		q.response.subst("ut3x.computersBanned", computersBanned);
		q.response.subst("ut3x.ban.hashBanned", ut3xMut.acc.PlayersBan[i].hashBanned);
		
		/*
		for(k=0; k < ut3xMut.acc.PlayersBan[i].IPSBanned.length; k++){
			if(ut3xMut.acc.PlayersBan[i].IPSBanned[k] != ""){
				q.response.subst("ut3xplayer.ip", ut3xMut.acc.PlayersBan[i].IPSBanned[k]);
				ips $= WebAdmin.include(q, "UT3X_playersdb_row_ip.inc");
			}
		}*/
		
		q.response.subst("ut3x.ban.hashWhenBanned", ut3xMut.acc.PlayersBan[i].hashWhenBanned);
		q.response.subst("ut3x.ban.ipWhenBanned", ut3xMut.acc.PlayersBan[i].ipWhenBanned);
		q.response.subst("ut3x.ban.compNameWhenBanned", ut3xMut.acc.PlayersBan[i].compNameWhenBanned);
		
		if(class'UT3XLib'.static.isDateAfterNow(ut3xMut.acc.PlayersBan[i].endSec) && !ut3xMut.acc.PlayersBan[i].isManuallyDesactivated){
			q.response.subst("ut3x.ban.isActive", "X");
		} else {
			if(ut3xMut.acc.PlayersBan[i].isManuallyDesactivated){
				q.response.subst("ut3x.ban.isActive", "Desactivated by:"$ut3xMut.acc.PlayersBan[i].desactivatedBy@"on"@ut3xMut.acc.PlayersBan[i].desactivatedTS);
			} else {
				q.response.subst("ut3x.ban.isActive", "");
			}
		}
		
		t $= WebAdmin.include(q, "UT3X_Bans_Row.inc");
		j++;
	}

	// HASH BAN (always active)
	for(i=0; i < ut3xMut.acc.BannedHashes.length; i++){
		if ( (j % 2) == 0) q.response.subst("evenodd", "even");
		else q.response.subst("evenodd", "odd");
		
		q.response.subst("ut3x.ban.playerBanned", ut3xMut.acc.BannedHashes[i].playerName);
		q.response.subst("ut3x.ban.admin", "");
		q.response.subst("ut3x.ban.startTS", "");
		q.response.subst("ut3x.ban.banType", "BT_HASH");
		q.response.subst("ut3x.ban.hashBanned", ut3xMut.acc.BannedHashes[i].BannedHash);
		q.response.subst("ut3x.ban.reason", "");
		q.response.subst("ut3x.ban.endTS", "");
		q.response.subst("ut3x.ban.isActive", "X");
		q.response.subst("ut3x.ban.banId", i);
		
		q.response.subst("ut3xplayer.ip", "");
		q.response.subst("ut3x.ban.uniqueIdBanned", "");
		q.response.subst("ut3x.ban.compNameBanned", "");
		q.response.subst("ut3x.ban.compNameWhenBanned", "");
		q.response.subst("ut3x.ban.hashWhenBanned", "");
		q.response.subst("ut3x.ban.ipWhenBanned", "");
		
		q.response.subst("ut3x.ban.remainingTime", "PERM BAN");
		q.response.subst("ut3x.ban.duration", "Permanent");
		t $= WebAdmin.include(q, "UT3X_Bans_Row.inc");
		j++;
	}
	
	// UID BAN (always active)
	for(i=0; i < ut3xMut.acc.BannedPlayerInfo.length; i++){
		if ( (j % 2) == 0) q.response.subst("evenodd", "even");
		else q.response.subst("evenodd", "odd");
		
		q.response.subst("ut3x.ban.playerBanned", ut3xMut.acc.BannedPlayerInfo[i].playerName);
		q.response.subst("ut3x.ban.admin", "");
		q.response.subst("ut3x.ban.startTS", ut3xMut.acc.BannedPlayerInfo[i].TimeStamp);
		q.response.subst("ut3x.ban.banType", "BT_UID");
		uid = ut3xMut.acc.BannedPlayerInfo[i].BannedID;
		q.response.subst("ut3x.ban.uniqueIdBanned", class'OnlineSubsystem'.static.UniqueNetIdToString(uid));
		q.response.subst("ut3x.ban.reason", "");
		q.response.subst("ut3x.ban.endTS", "");
		q.response.subst("ut3x.ban.isActive", "X");
		q.response.subst("ut3x.ban.banId", i);
		q.response.subst("ut3x.ban.compNameBanned", "");
		q.response.subst("ut3x.ban.hashBanned", "");
		q.response.subst("ut3x.ban.compNameWhenBanned", "");
		q.response.subst("ut3x.ban.hashWhenBanned", "");
		q.response.subst("ut3xplayer.ip", "");
		q.response.subst("ut3x.ban.ipWhenBanned", "");
		
		q.response.subst("ut3x.ban.remainingTime", "PERM BAN");
		q.response.subst("ut3x.ban.duration", "Permanent");
		t $= WebAdmin.include(q, "UT3X_Bans_Row.inc");
		j++;
	}
	
	for(i=0; i < ut3xMut.acc.IPPolicies.length; i++){
		if(InStr(ut3xMut.acc.IPPolicies[i], "DENY") != -1){
			if ( (j % 2) == 0) q.response.subst("evenodd", "even");
			else q.response.subst("evenodd", "odd");
			
			q.response.subst("ut3x.ban.playerBanned", "");
			q.response.subst("ut3x.ban.admin", "");
			q.response.subst("ut3x.ban.startTS", "");
			q.response.subst("ut3x.ban.banType", "BT_IP");
			q.response.subst("ut3x.ban.uniqueIdBanned", "");
			q.response.subst("ut3x.ban.reason", "");
			q.response.subst("ut3x.ban.endTS", "");
			q.response.subst("ut3x.ban.isActive", "X");
			q.response.subst("ut3x.ban.banId", i);
			q.response.subst("ut3x.ban.compNameBanned", "");
			q.response.subst("ut3x.ban.hashBanned", "");
			q.response.subst("ut3x.ban.compNameWhenBanned", "");
			q.response.subst("ut3x.ban.hashWhenBanned", "");
			q.response.subst("ut3x.ban.ipWhenBanned", "");
			q.response.subst("ut3xplayer.ip", ut3xMut.acc.IPPolicies[i]);
			q.response.subst("ut3x.ban.remainingTime", "PERM BAN");
			q.response.subst("ut3x.ban.duration", "Permanent");
			
			t $= WebAdmin.include(q, "UT3X_Bans_Row.inc");
			j++;
		}
	}
	
	q.response.subst("ut3x.bans.list", t);
	
	t = "";
	for(i=0; i< ut3xMut.acc.KickRules.length ;i++){
		q.response.subst("ut3x.bantype.label", ut3xMut.acc.KickRules[i].label);
		q.response.subst("ut3x.bantype.extrainfo", " - "$ut3xMut.acc.KickRules[i].ka);
		t $= WebAdmin.include(q, "UT3X_BansReasons_Option.inc");
	}
	q.response.subst("ut3x.banreasons", t);
	WebAdmin.SendPage(Q, "UT3X_Bans.html");
}


function bool UnhandledQuery(WebAdminQuery Q)
{
	return False;
}


function UT3XPlayersQuery(WebAdminQuery Q){

	local int i, j, k;
	local string players, hashes, compHashes, ip2c, ips, ipranges, clantags, curAction, playerName, friends;
	local string playerNameFilter, uniqueIdFilter, hashFilter, countryFilter, ipFilter, friendFilter, clanTagFilter, maxResultsFilter, computerNameMD5Filter, ipRange, unidClone;
	local int numPage, numPageDisplayed;
	local array<UT3XPlayerInfo> pDBList;
	local int linesPerPage, minLine, maxLine, totalNumPages;
	linesPerPage = 25;
	
	
	numPageDisplayed = int(Q.Request.GetVariable("numPageDisplayed"));
	playerNameFilter = Q.Request.GetVariable("playerNameFilter");
	friendFilter = Q.Request.GetVariable("friendFilter");
	uniqueIdFilter = Q.Request.GetVariable("uniqueIdFilter");
	hashFilter = Q.Request.GetVariable("hashFilter");
	countryFilter = Q.Request.GetVariable("countryFilter");
	clanTagFilter = Q.Request.GetVariable("clanTagFilter");
	ipFilter = Q.Request.GetVariable("ipFilter");
	maxResultsFilter = Q.Request.GetVariable("maxResultsFilter");
	computerNameMD5Filter = Q.Request.GetVariable("computerNameMD5Filter");
	ipRange = Q.Request.GetVariable("ipRange");
	unidClone = Q.Request.GetVariable("findClones");
	
	// avoid when accessing ut3x players page for first time
	// to search for many players (so would lag ...)
	if("1" == Q.Request.GetVariable("noautosearch")){
		WebAdmin.AddMessage(Q, "Use the find button to find player!");
		WebAdmin.SendPage(Q, "UT3X_Players.html");
		return;
	}
	
	if(int(maxResultsFilter) == 0){
		maxResultsFilter = "10000";
	}
	if(numPageDisplayed == 0){
		numPageDisplayed = 1;
	}
	numPage = numPageDisplayed-1;
	
	if(unidClone != ""){
		pDBList = ut3xMut.acc.pdb.getPlayerClonesFromUNID(unidClone);
	} else {
		pDBList = filterPlayerDb(playerNameFilter, uniqueIdFilter, hashFilter, countryFilter, ipFilter, clanTagFilter, computerNameMD5Filter, friendFilter, int(maxResultsFilter), "", ipRange);
	}
	
	if(pDBList.length == 0){
		WebAdmin.AddMessage(Q, "No results found!");
		WebAdmin.SendPage(Q, "UT3X_Players.html");
		return;
	}
	
	CurAction = Q.Request.GetVariable("action");

	if (CurAction ~= "managePlayer"){
		playerName = Q.Request.GetVariable("playerName");
		
		if(playerName == ""){
			webadmin.addMessage(Q, "Select a player!");
		}
		// ut3xBan
		webadmin.addMessage(Q, "Feature not operational yet");
	}
	
	totalNumPages = pDBList.length/linesPerPage;
	minLine = numPage*linesPerPage;
	maxLine = (numPage+1)*linesPerPage;
	
	for(i=0; i < pDBList.length ; i++){
	
		if(i<minLine || i >= maxLine){
			continue;
		}
		
		q.response.subst("numLine", i);
		if ( (i % 2) == 0) q.response.subst("evenodd", "even");
		else q.response.subst("evenodd", "odd");
		
		friends = "";
		hashes = "";
		clantags = "";
		ip2c = "";
		ips = "";
		ipranges = "";
		compHashes = "";
		
		q.response.subst("ut3xplayer.name", pDBList[i].PName);
		q.response.subst("ut3xplayer.uniqueid", pDBList[i].UNID);
		
		for(j=0; j < pDBList[i].HASHES.length; j++){
			q.response.subst("ut3xplayer.hash", pDBList[i].HASHES[j]);
			hashes $= WebAdmin.include(q, "UT3X_playersdb_row_hash.inc");
		}
		
		for(j=0; j < pDBList[i].CTS.length; j++){
			q.response.subst("ut3xplayer.clantag", class'WebAdminUtils'.static.HTMLEscape(pDBList[i].CTS[j]));
			clantags $= WebAdmin.include(q, "UT3X_playersdb_row_clantag.inc");
		}
		
		// Computer Name Hashes
		for(j=0; j < pDBList[i].CNS.length; j++){
			q.response.subst("ut3xplayer.comphash", class'WebAdminUtils'.static.HTMLEscape(pDBList[i].CNS[j]));
			compHashes $= WebAdmin.include(q, "UT3X_row_computer.inc");
		}
		
		// Friends
		for(j=0; j < pDBList[i].FDS.length; j++){
			q.response.subst("ut3xplayer.friend", class'WebAdminUtils'.static.HTMLEscape(pDBList[i].FDS[j]));
			friends $= WebAdmin.include(q, "UT3X_playersdb_row_friend.inc");
		}
		
		for(k=0; k < pDBList[i].IPCS.length; k++){
			if(pDBList[i].IPCS[k].IP != ""){
				q.response.subst("ut3xplayer.ip", pDBList[i].IPCS[k].IP);
				q.response.subst("ut3xplayer.fts", pDBList[i].IPCS[k].FTS);
				q.response.subst("ut3xplayer.lts", pDBList[i].IPCS[k].LTS);
				
				ips $= WebAdmin.include(q, "UT3X_playersdb_row_ip.inc");
				
				q.response.subst("ipstart", class'UT3XAC'.static.getPlayerIpRangeStart(pDBList[i].IPCS[k]));
				q.response.subst("ipend", class'UT3XAC'.static.getPlayerIpRangeEnd(pDBList[i].IPCS[k]));
				ipranges $= WebAdmin.include(q, "UT3X_playersdb_row_iprange.inc");
				
				q.response.subst("ut3xplayer.country", pDBList[i].IPCS[k].CC3);
				//q.response.subst("ut3xplayer.countryname", pDBList[i].IPCS[k].CN); //TODO
				ip2c $= WebAdmin.include(q, "UT3X_playersdb_row_country.inc");

			}
		}
		

		q.response.subst("ut3xplayer.hashes", hashes);
		q.response.subst("ut3xplayer.friends", friends);
		q.response.subst("ut3xplayer.comphashes", compHashes);
		q.response.subst("ut3xplayer.deltatime", pDBList[i].DT);
		q.response.subst("ut3xplayer.clantags", clantags);
		q.response.subst("ut3xplayer.ips", ips);
		q.response.subst("ut3xplayer.ipranges", ipranges);
		q.response.subst("ut3xplayer.ip2c", ip2c);
		q.response.subst("ut3xplayer.firstprelogin", pDBList[i].FPL);
		q.response.subst("ut3xplayer.lastprelogin", pDBList[i].LPL);
		q.response.subst("ut3xplayer.firstlogin", pDBList[i].FL);
		q.response.subst("ut3xplayer.lastlogin", pDBList[i].LL);
		q.response.subst("ut3xplayer.lastlogout", pDBList[i].LLO);
		players $= WebAdmin.include(q, "UT3X_playersdb_row.inc");
	}
	

	q.response.subst("ut3x.dbplayers.list", players);
	
	q.response.subst("computerNameMD5Filter", computerNameMD5Filter);
	q.response.subst("playerNameFilter", playerNameFilter);
	q.response.subst("uniqueIdFilter", uniqueIdFilter);
	q.response.subst("hashFilter", hashFilter);
	q.response.subst("countryFilter", countryFilter);
	q.response.subst("clanTagFilter", clanTagFilter);
	q.response.subst("ipFilter", ipFilter);
	q.response.subst("numPageDisplayed", numPageDisplayed);
	q.response.subst("totalNumPages", (totalNumPages+1));
	q.response.subst("linesPerPage", linesPerPage);
	q.response.subst("numResults", pDBList.length);
	q.response.subst("numPlayers", ut3xMut.acc.pdb.PlayersLogs.length);
	q.response.subst("maxResultsFilter", maxResultsFilter);
	q.response.subst("ut3x.dbplayers.numresults", pDBList.length);
	
	WebAdmin.SendPage(Q, "UT3X_Players.html");
}

function UT3XConfigQuery(WebAdminQuery Q)
{
	
	local UT3XLagDetector uld;
	local UT3XSounds us;
	local UT3XDemoRec udr;
	local UT3XTeamBalancer tb;
	local UT3XAdverts ad;
	local UT3XMapInfo umi;
	local UT3XAFKChecker afkc;
	local UT3XLanguageChecker lc;
	local UT3XSmileys usm;
	local UT3XDefaultMap udm;
	local string  CurAction, t;
	local int i;
	local array<string> adminNames;

	CurAction = Q.Request.GetVariable("action");

	if (CurAction ~= "saveModulesActive"){
		if(isHeadAdmin(Q)){
			ut3xMut.bUseUT3XHud = (Q.Request.GetVariable("bUseUT3XHud") == "True");
			ut3xMut.bLagDetectorActive = (Q.Request.GetVariable("lagdetector") == "True");
			ut3xMut.bDemoRecActive = (Q.Request.GetVariable("demorec") == "True");
			ut3xMut.bTeamBalancerActive = (Q.Request.GetVariable("balancer") == "True");
			ut3xMut.bAdvertsActive = (Q.Request.GetVariable("adverts") == "True");
			ut3xMut.bMapInfoActive = (Q.Request.GetVariable("mapinfo") == "True");
			ut3xMut.bZoundsActive = (Q.Request.GetVariable("zounds") == "True");
			ut3xMut.bAFKCheckerActive = (Q.Request.GetVariable("afkchecker") == "True");
			ut3xMut.bDefaultMapActive = (Q.Request.GetVariable("defaultmap") == "True");
			ut3xMut.bLangCheckerActive = (Q.Request.GetVariable("langchecker") == "True");
			ut3xMut.bSmileysActive = (Q.Request.GetVariable("bSmileysActive") == "True");
			ut3xMut.timeZone = Q.Request.GetVariable("timeZone");
			ut3xMut.SaveConfig();
			
			// DYNAMIC ADD/DEL WITHOUT MAP CHANGE
			if(!ut3xMut.bSmileysActive){
				foreach webadmin.WorldInfo.AllActors(class'UT3XSmileys', usm){
					usm.Destroy();
				}
				ut3xMut.usm = None;
			} else {
				if(ut3xMut.usm == None){
					ut3xMut.usm = webadmin.WorldInfo.spawn(class'UT3XSmileys', ut3xMut);
				}
			}
			
			if(!ut3xMut.bLagDetectorActive){
				foreach webadmin.WorldInfo.AllActors(class'UT3XLagDetector', uld){
					uld.Destroy();
				}
				ut3xMut.uld = None;
			} else {
				if(ut3xMut.uld == None){
					ut3xMut.uld = webadmin.WorldInfo.spawn(class'UT3XLagDetector');
				}
			}
			
			if(!ut3xMut.bDemoRecActive){
				foreach webadmin.WorldInfo.AllActors(class'UT3XDemoRec', udr){
					udr.Destroy();
				}
				ut3xMut.udr = None;
			} else {
				
				if(ut3xMut.udr == None){
					ut3xMut.udr = webadmin.WorldInfo.spawn(class'UT3XDemoRec');
				}
			}
			
			if(!ut3xMut.bTeamBalancerActive){
				foreach webadmin.WorldInfo.AllActors(class'UT3XTeamBalancer', tb){
					tb.Destroy();
				}
				ut3xMut.tb = None;
			} else {
				
				if(ut3xMut.tb == None){
					ut3xMut.tb = webadmin.WorldInfo.spawn(class'UT3XTeamBalancer');
				}
			}
			
			if(!ut3xMut.bAdvertsActive){
				foreach webadmin.WorldInfo.AllActors(class'UT3XAdverts', ad){
					ad.Destroy();
				}
				ut3xMut.ad = None;
			} else {
				
				if(ut3xMut.ad == None){
					ut3xMut.ad = webadmin.WorldInfo.spawn(class'UT3XAdverts');
				}
			}
			
			if(!ut3xMut.bMapInfoActive){
				foreach webadmin.WorldInfo.AllActors(class'UT3XMapInfo', umi){
					umi.Destroy();
				}
				ut3xMut.umi = None;
			} else {
				
				if(ut3xMut.umi == None){
					ut3xMut.umi = webadmin.WorldInfo.spawn(class'UT3XMapInfo');
				}
			}
			
			if(!ut3xMut.bZoundsActive){
				foreach webadmin.WorldInfo.AllActors(class'UT3XSounds', us){
					us.Destroy();
				}
				ut3xMut.us = None;
			} else {
				if(ut3xMut.us == None){
					ut3xMut.us = webadmin.WorldInfo.spawn(class'UT3XSounds');
				}
			}
			
			if(!ut3xMut.bAFKCheckerActive){
				foreach webadmin.WorldInfo.AllActors(class'UT3XAFKChecker', afkc){
					afkc.Destroy();
				}
				ut3xMut.afkc = None;
			} else {
				if(ut3xMut.afkc == None){
					ut3xMut.afkc = webadmin.WorldInfo.spawn(class'UT3XAFKChecker');
				}
			}
			
			if(!ut3xMut.bLangCheckerActive){
				foreach webadmin.WorldInfo.AllActors(class'UT3XLanguageChecker', lc){
					lc.Destroy();
				}
				ut3xMut.acc.lc = None;
			} else {
				if(ut3xMut.acc.lc == None){
					ut3xMut.acc.lc = webadmin.WorldInfo.spawn(class'UT3XLanguageChecker');
				}
			}
			
			if(!ut3xMut.bDefaultMapActive){
				foreach webadmin.WorldInfo.AllActors(class'UT3XDefaultMap', udm){
					udm.Destroy();
				}
				ut3xMut.udm = None;
			} else {
				if(ut3xMut.udm == None){
					ut3xMut.udm = webadmin.WorldInfo.spawn(class'UT3XDefaultMap');
				}
			}
			
			webadmin.addMessage(Q, "Settings have been successfully applied!");
		} else {
			webadmin.addMessage(Q, "Only head administrators can change these settings!", MT_Error);
		}
	}
	
	Q.Response.Subst("ut3x.version", ut3xMut.UT3XVersion);
	Q.Response.Subst("ut3x.date", ut3xMut.UT3XDate);
	
	Q.Response.Subst("ut3x.waversion", UT3XWebAdminVersion);
	Q.Response.Subst("ut3x.wadate", UT3XWebAdminDate);
	
	Q.Response.Subst("ut3x.db.numplayers", ut3xMut.acc.pdb.PlayersLogs.length);
	
	Q.Response.Subst("ut3x.am.bUseUT3XHud", ut3xMut.bUseUT3XHud);
	Q.Response.Subst("ut3x.am.lagdetector", ut3xMut.bLagDetectorActive);
	Q.Response.Subst("ut3x.am.mapinfo", ut3xMut.bMapInfoActive);
	Q.Response.Subst("ut3x.am.demorec", ut3xMut.bDemoRecActive);
	Q.Response.Subst("ut3x.am.balancer", ut3xMut.bTeamBalancerActive);
	Q.Response.Subst("ut3x.am.adverts", ut3xMut.bAdvertsActive);
	Q.Response.Subst("ut3x.am.zounds", ut3xMut.bZoundsActive);
	Q.Response.Subst("ut3x.am.afkchecker", ut3xMut.bAFKCheckerActive);
	Q.Response.Subst("ut3x.am.defaultmap", ut3xMut.bDefaultMapActive);
	Q.Response.Subst("ut3x.am.langchecker", ut3xMut.bLangCheckerActive);
	Q.Response.Subst("bSmileysActive", ut3xMut.bSmileysActive);
	Q.Response.Subst("ut3x.am.timeZone", ut3xMut.timeZone);
	
	adminNames = ut3xmut.acc.getAdminsNameList();
	for(i=0; i< adminNames.length;i++){
		t $= adminNames[i]$"<br>";
	}
	
	if(isHeadAdmin(Q)){
		Q.Response.Subst("ut3x.adminlist", t);
	} else {
		Q.Response.Subst("ut3x.adminlist", "Not available for normal admins");
	}
	
	Q.Response.Subst("ut3x.am.headadmin", (isHeadAdmin(Q)?"You are an Head Administrator!":""));
	
	WebAdmin.SendPage(Q, "UT3X_Config.html");
}

function UT3XSQLLinkQuery(WebAdminQuery Q){

	local String CurAction;
	
	CurAction = Q.Request.GetVariable("action");

	if (CurAction ~= "save"){
		ut3xMut.acc.sqlLink_host = Q.Request.GetVariable("sqlLink_host");
		ut3xMut.acc.sqlLink_port = int(Q.Request.GetVariable("sqlLink_port"));
		ut3xMut.acc.sqlLink_phpfilepath = Q.Request.GetVariable("sqlLink_phpfilepath");
		ut3xMut.acc.sqlLink_password = Q.Request.GetVariable("sqlLink_password");
		ut3xMut.acc.sqlLink_enabled = ("on" == Q.Request.GetVariable("sqlLink_enabled"));
		ut3xMut.acc.sqlLink_ip2c_enabled = ("on" == Q.Request.GetVariable("sqlLink_ip2c_enabled"));
		ut3xMut.acc.sqlLink_exportPlayerData = ("on" == Q.Request.GetVariable("sqlLink_exportPlayerData"));
		ut3xMut.acc.sqlLink_exportLogs = ("on" == Q.Request.GetVariable("sqlLink_exportLogs"));
		ut3xMut.acc.SaveConfig();
	}

	Q.Response.Subst("sqlLink_host", ut3xMut.acc.sqlLink_host);
	Q.Response.Subst("sqlLink_port", ut3xMut.acc.sqlLink_port);
	Q.Response.Subst("sqlLink_phpfilepath", ut3xMut.acc.sqlLink_phpfilepath);
	Q.Response.Subst("sqlLink_password", ut3xMut.acc.sqlLink_password);
	Q.Response.Subst("sqlLink_enabled", ut3xMut.acc.sqlLink_enabled?"checked='checked'":"");
	Q.Response.Subst("sqlLink_ip2c_enabled", ut3xMut.acc.sqlLink_ip2c_enabled?"checked='checked'":"");
	Q.Response.Subst("sqlLink_exportPlayerData", ut3xMut.acc.sqlLink_exportPlayerData?"checked='checked'":"");
	Q.Response.Subst("sqlLink_exportLogs", ut3xMut.acc.sqlLink_exportLogs?"checked='checked'":"");
	
	WebAdmin.SendPage(Q, "UT3X_SQLLink.html");
}

function UT3XLogsQuery(WebAdminQuery Q)
{
	local String logTypeFilter, srcPN, destPN, data, maxResultsStr, t, CurAction, tmp;
	local array<LogData> logs;
	local int i, minTime, maxTime, numPage, numPageDisplayed, totalNumPages, maxDaysLogRetentionTime, maxLogLines;
	local int linesPerPage, minLine, maxLine;
	local String minDateTimeTSFilter, minDateTimeSecFilter, maxDateTimeSecFilter, maxDateTimeTSFilter;
	
	linesPerPage = 50;
	
	logTypeFilter = Q.Request.GetVariable("logTypeFilter");
	srcPN = Q.Request.GetVariable("srcPNFilter");
	destPN = Q.Request.GetVariable("destPNFilter");
	data = Q.Request.GetVariable("dataFilter");
	minDateTimeTSFilter = Q.Request.GetVariable("minDateTimeTSFilter");
	minDateTimeSecFilter = Q.Request.GetVariable("minDateTimeSecFilter");
	maxDateTimeTSFilter = Q.Request.GetVariable("maxDateTimeTSFilter");
	maxDateTimeSecFilter = Q.Request.GetVariable("maxDateTimeSecFilter");
	 
	maxResultsStr = Q.Request.GetVariable("maxResultsFilter");
	numPageDisplayed = int(Q.Request.GetVariable("numPageDisplayed"));
	
	
	CurAction = Q.Request.GetVariable("action");
	
	if (CurAction ~= "save"){
		if(isHeadAdmin(Q)){
			maxDaysLogRetentionTime = int(Q.Request.GetVariable("maxDaysLogRetentionTime"));
			maxLogLines = int(Q.Request.GetVariable("maxLogLines"));
			
			if(maxDaysLogRetentionTime == 0){
				maxDaysLogRetentionTime = 1;
			}
			
			if(maxLogLines == 0){
				maxLogLines = 500;
			}
			
			ut3xMut.acc.log.maxLogLines = maxLogLines;
			ut3xMut.acc.log.maxDaysLogRetentionTime = maxDaysLogRetentionTime;
			WebAdmin.AddMessage(Q, "Logs settings have been saved!");
		} else {
			webadmin.addMessage(Q, "Only Head Administrators can close the server", MT_Error);
		}
	}
	
	if(numPageDisplayed == 0){
		numPageDisplayed = 1;
	}
	numPage = numPageDisplayed-1;

	
	minTime = class'UT3XLib'.static.getGlobalSecondsFromTimeStamp(minDateTimeTSFilter);
	maxTime = class'UT3XLib'.static.getGlobalSecondsFromTimeStamp(maxDateTimeTSFilter);
	
	if(minDateTimeSecFilter != ""){
		minTime = int(minDateTimeSecFilter);
	}
	
	if(maxDateTimeSecFilter != ""){
		maxTime = int(maxDateTimeSecFilter);
	}
	
	logs = filterLogData(
	logTypeFilter,
	srcPN,
	destPN,
	data,
	minTime,
	maxTime,
	int(maxResultsStr));
	
	totalNumPages = logs.length/linesPerPage;
	
	minLine = numPage*linesPerPage;
	maxLine = (numPage+1)*linesPerPage;
	
	for(i=0; i<logs.length; i++){
	
		if(i<minLine || i >= maxLine){
			continue;
		}
		
		q.response.subst("numLine", i);
		q.response.subst("ut3x.logs.logtype", logs[i].LT);
		q.response.subst("ut3x.logs.srcPN", logs[i].srcPN);
		q.response.subst("ut3x.logs.destPN", logs[i].destPN);
		
		// DISPLAY PM ONLY FOR HEADADMINS
		if(logs[i].LT == LT_PMCHAT && !isHeadAdmin(Q)){
			q.response.subst("ut3x.logs.data", "PRIVATE MESSAGE");
		} else {
		if(Len(logs[i].data) > 70){
			tmp = Right(logs[i].data, Len(logs[i].data)-70);
			
			q.response.subst("ut3x.logs.data", Left(logs[i].data, 70)$"<br>"$tmp);
		} else {
			q.response.subst("ut3x.logs.data", logs[i].data);
		}
		}
		q.response.subst("ut3x.logs.ts", logs[i].ts);
		q.response.subst("ut3x.logs.minDateTimeSecFilter", (logs[i].timeSec-(60*30))); // Last 30 minutes by default
		q.response.subst("ut3x.logs.maxDateTimeSecFilter", (logs[i].timeSec+10) );
		q.response.subst("style", "");
		
		if(logs[i].LT == LT_KICK || logs[i].LT == LT_KICKBAN || logs[i].LT == LT_MUTE || logs[i].LT == LT_MUTEBAN){
			q.response.subst("style", "bgcolor='#F78181'");	 // LIGHT RED
		}
		else if(logs[i].LT == LT_REQUEST){
			q.response.subst("style", "bgcolor='#F2F5A9'");	 // LIGHT YELLOW
		} 
		else if(logs[i].LT == LT_REPORT || logs[i].LT == LT_KICKVOTE || logs[i].LT == LT_WARN || logs[i].LT == LT_LAGDETECTOR){
			q.response.subst("style", "bgcolor='#F7BE81'");	 // LIGHT ORANGE
		} 
		else if(logs[i].LT == LT_ADMINLOGIN){
			q.response.subst("style", "bgcolor='#3BC3E8'");	 // BLUE
		} 
		else if(logs[i].LT == LT_CHATLOG || logs[i].LT == LT_PMCHAT){
			q.response.subst("style", "bgcolor='#D8CEF6'");	 // LIGHT PURPLE
		}
		else if(logs[i].LT == LT_SERVERSTART || logs[i].LT == LT_MAPCHANGE){
			q.response.subst("style", "bgcolor='#A9F5BC'");	 // LIGHT GREEN
		}
		
		
		
		t $= WebAdmin.include(q, "UT3X_logs_row.inc");
	}
	
	
	
	
	q.response.subst("srcPNFilter", srcPN);
	q.response.subst("destPNFilter", destPN);
	q.response.subst("dataFilter", data);
	q.response.subst("minDateTimeTSFilter", minDateTimeTSFilter);
	q.response.subst("maxDateTimeTSFilter", maxDateTimeTSFilter);
	q.response.subst("logTypeFilter", logTypeFilter);
	q.response.subst("maxDaysLogRetentionTime", ut3xMut.acc.log.maxDaysLogRetentionTime);
	q.response.subst("numResults", logs.length);
	q.response.subst("maxLogLines", ut3xMut.acc.log.maxLogLines);
	
	q.response.subst("numPageDisplayed", numPageDisplayed);
	q.response.subst("totalNumPages", (totalNumPages+1));
	q.response.subst("linesPerPage", linesPerPage);
	
	q.response.subst("ut3x.logs.list", t);
	WebAdmin.SendPage(Q, "UT3X_Logs.html");
}

function array<LogData> filterLogData(
	String logTypeFilter,
	String srcPN,
	String destPN,
	String data,
	int minTimeSec,
	int maxTimeSec,
	int maxResults
	){

	local int i, count;
	local UT3XLog l;
	local bool add;
	local array<LogData> logsFiltered;
	
	if(maxResults == 0 || maxResults > ut3xMut.acc.log.maxLogLines){
		maxResults = ut3xMut.acc.log.maxLogLines;
	}
	add = true;
	l = ut3xMut.acc.log;
	if( l == None){
		return logsFiltered;
	}
	
	
	for(i=(l.logs.length-1); i>=0; i--){
		add = true;
		
		if(logTypeFilter != ""){
			if(l.Logs[i].LT != LT_KICK && logTypeFilter == "LT_KICK"){
				add = false;
			}
			if(l.Logs[i].LT != LT_KICKVOTE && logTypeFilter == "LT_KICKVOTE"){
				add = false;
			}
			if(l.Logs[i].LT != LT_KICKBAN && logTypeFilter == "LT_KICKBAN"){
				add = false;
			}
			if(l.Logs[i].LT != LT_MUTE && logTypeFilter == "LT_MUTE"){
				add = false;
			}
			if(l.Logs[i].LT != LT_MUTEBAN && logTypeFilter == "LT_MUTEBAN"){
				add = false;
			}
			if(l.Logs[i].LT != LT_ADMINLOGIN && logTypeFilter == "LT_ADMINLOGIN"){
				add = false;
			}
			if(l.Logs[i].LT != LT_REPORT && logTypeFilter == "LT_REPORT"){
				add = false;
			}
			if(l.Logs[i].LT != LT_REQUEST && logTypeFilter == "LT_REQUEST"){
				add = false;
			}
			if(l.Logs[i].LT != LT_ACCESS && logTypeFilter == "LT_ACCESS"){
				add = false;
			}
			if(l.Logs[i].LT != LT_LAGDETECTOR && logTypeFilter == "LT_LAGDETECTOR"){
				add = false;
			}
			if(l.Logs[i].LT != LT_DEMOREC && logTypeFilter == "LT_DEMOREC"){
				add = false;
			}
			if(l.Logs[i].LT != LT_CHATLOG && logTypeFilter == "LT_CHATLOG"){
				add = false;
			}
			if(l.Logs[i].LT != LT_PMCHAT && logTypeFilter == "LT_PMCHAT"){
				add = false;
			}
			if(l.Logs[i].LT != LT_WARN && logTypeFilter == "LT_WARN"){
				add = false;
			}
			
			if(l.Logs[i].LT != LT_MAPCHANGE && logTypeFilter == "LT_MAPCHANGE"){
				add = false;
			}
		}
		
		//console.log("srcPN:"$srcPN$" SRC:"$InStr(CAPS(l.Logs[i].srcPN), CAPS(srcPN))$" DST:"$InStr(CAPS(l.Logs[i].destPN), CAPS(destPN)));
		
		if(srcPN != ""  && ((InStr(CAPS(l.Logs[i].srcPN), CAPS(srcPN)) == -1) && (InStr(CAPS(l.Logs[i].destPN), CAPS(srcPN)) == -1) ) ){
			add = false;
		}
		
		/*
		if(destPN != ""  && (InStr( CAPS(l.Logs[i].destPN), CAPS(destPN)) == -1)){
			add = false;
		}*/
		
		
		if(data != "" && (InStr(CAPS(l.Logs[i].data), CAPS(data)) == -1) ){
			add = false;
		}
		
		if(minTimeSec > 0 && minTimeSec > l.Logs[i].timeSec){
			add = false;
		}
		
		if(maxTimeSec > 0 && maxTimeSec < l.Logs[i].timeSec){
			add = false;
		}
		
		if(add){
			count ++;
			if(maxResults > 0 && (maxResults < count)){
				return logsFiltered;
			}
			logsFiltered.addItem(l.Logs[i]);
		}
	}
	
	return logsFiltered;
}

// FILTERS PLAYER DATABASE
function array<UT3XPlayerInfo> filterPlayerDb(
	string playerName,
	string uniqueId,
	string hash,
	string country,
	string ip,
	string clanTag,
	string computerNameMD5,
	string friend,
	int maxResults,
	string lastLoginStartTS,
	string iprange){

	local array<UT3XPlayerInfo> playersFiltered;
	local array<string> split;
	local array<byte> ipr_start;
	local int i, j, count;
	local bool add, hasHash, hasClanTag, hasFriend;
	
	if(maxResults == 0){
		maxResults = 10000;
	}
	
	if(iprange != ""){
		ParseStringIntoArray(iprange, split, ".", false);
		
		for(i=0; i < split.length; i++){
			ipr_start[0] = byte(split[0]);
			ipr_start[1] = byte(split[1]);
			ipr_start[2] = byte(split[2]);
			ipr_start[3] = byte(split[3]);
		}
	}
	
	add = true;
	
	for(i=0; i < ut3xMut.acc.pdb.PlayersLogs.length; i++){
		add = true;
		hasHash = false;
		hasClanTag = false;
		hasFriend = false;
		
		if(playerName != ""){
		
			if(InStr(CAPS(ut3xMut.acc.pdb.PlayersLogs[i].PName), CAPS(playerName)) != -1){
				
			} else {
				add = false;
			}
			
			//if(CAPS(ut3xMut.acc.pdb.PlayersLogs[i].PName) != CAPS(playerName)){
				
			//}
		}
		
		if(uniqueId != ""){
			if(CAPS(ut3xMut.acc.pdb.PlayersLogs[i].UNID) != CAPS(uniqueId)){
				add = false;
			}
		}
		
		if(hash != ""){
			for(j=0; j < ut3xMut.acc.pdb.PlayersLogs[i].HASHES.length; j++){
				if(ut3xMut.acc.pdb.PlayersLogs[i].HASHES[j] == hash){
					hasHash = true;
				}
			}
			add = hasHash;
		}
		
		if(computerNameMD5 != ""){
			add = (ut3xMut.acc.pdb.PlayersLogs[i].cns.Find(computerNameMD5) != -1);
		}
		
		if(lastLoginStartTS != ""){
			
		}
		
		if(clanTag != ""){
			for(j=0; j < ut3xMut.acc.pdb.PlayersLogs[i].CTS.length; j++){
				if(InStr(CAPS(ut3xMut.acc.pdb.PlayersLogs[i].CTS[j]), CAPS(clanTag)) != -1 ){
					hasClanTag = true;
				}
			}
			add = hasClanTag;
		}
		
		if(friend != ""){
			for(j=0; j < ut3xMut.acc.pdb.PlayersLogs[i].FDS.length; j++){
				if(InStr(CAPS(ut3xMut.acc.pdb.PlayersLogs[i].FDS[j]), CAPS(friend)) != -1 ){
					hasFriend = true;
				}
			}
			add = hasFriend;
		}
		
		if(country != "" || ip != "" || iprange != ""){
			hasHash = false;
			
			for(j=0; j < ut3xMut.acc.pdb.PlayersLogs[i].IPCS.length; j++){
				if(country != ""){
					if(ut3xMut.acc.pdb.PlayersLogs[i].IPCS[j].CC3 == country){
						hasHash = true;
					}
				}
				
				if(ip != ""){
					if(InStr(ut3xMut.acc.pdb.PlayersLogs[i].IPCS[j].IP, ip) != -1){
						hasHash = true;
					}
				}
				
				if(iprange != ""){
					// IP RANGE START OK
					if(ipr_start[0] == ut3xMut.acc.pdb.PlayersLogs[i].IPCS[j].A && ipr_start[1] == ut3xMut.acc.pdb.PlayersLogs[i].IPCS[j].B
						&& ipr_start[2] == ut3xMut.acc.pdb.PlayersLogs[i].IPCS[j].C && ipr_start[3] == ut3xMut.acc.pdb.PlayersLogs[i].IPCS[j].D){
						
						hasHash = true;
					}
				}
			}
			add = hasHash;
		}
		
		if(add){
			count ++;
			playersFiltered.addItem(ut3xMut.acc.pdb.PlayersLogs[i]);
			
			if(count >= maxResults){
				return playersFiltered;
			}
		}
	}
	
	return playersFiltered;
}
