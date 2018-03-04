/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
Class UT3XWebAdminHook_Base extends UT3XWebAdminHook;

var Class<UT3XQueryHandler> QueryHandlerClass;

static function InitializeWebAdminHook(UT3X ut3xMut, object WebServerObj)
{
	local WebServer WS;
	local int i;
	local WebAdmin WA;
	local UT3XQueryHandler QH;

	
	if (default.QueryHandlerClass == none)
		return;


	WS = WebServer(WebServerObj);
	if (WS != none)
	{
		for (i=0; i<ArrayCount(WS.ApplicationObjects); ++i)
		{
			if (WebAdmin(WS.ApplicationObjects[i]) != none)
			{
				WA = WebAdmin(WS.ApplicationObjects[i]);
				break;
			}
		}

		// Add the query handler
		if (WA != none)
		{
			QH = new(WA) default.QueryHandlerClass;
			QH.ut3xMut = ut3xMut;
			WA.AddQueryHandler(QH);
		} else {
			LogInternal("UT3XWebAdmin-Could not start WebAdmin");
		}
	}
}
