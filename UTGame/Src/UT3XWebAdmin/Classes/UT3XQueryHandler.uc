/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XQueryHandler extends Object;
	//implements(IQueryHandler);

var UT3X ut3xMut;


static final function bool IsAlphaNumeric(const out string S, optional string IgnoredChars)
{
	local int i, j, ChrLen;

	ChrLen = Len(S);

	for (i=0; i<ChrLen; ++i)
	{
		j = Asc(Mid(S, i, 1));

		if ((j < 48 || (j > 57 && j < 65) || (j > 90 && j < 97) || j > 122) && InStr(IgnoredChars, Chr(j)) == INDEX_None)
			return False;
	}


	return True;
}

function bool producesXhtml()
{
	return true;
}
