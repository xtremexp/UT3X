/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class UT3XWALib extends Object;

static function getNetConnections(out array<TcpipConnection> nc){
	local int i;
	local object obj;
	
	for(i=0; i<=2024; i++){
		obj = FindObject( "Transient.TcpipConnection_"$i, class'IpDrv.TcpipConnection'  );
		if(obj != None){
			nc.addItem(TcpipConnection(obj));
		}
	}
}

static function getTcpLinks(WorldInfo wi,out array<TcpLink> tcp){
	local int i;
	local object obj;
	local TcpLink tcpp;
	
	foreach wi.AllActors(class'TcpLink', tcpp){
		tcp.addItem(tcpp);
	}
}
