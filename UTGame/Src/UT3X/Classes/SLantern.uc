/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class SLantern extends S placeable; //Spawnable


DefaultProperties 
{ 
	Begin Object Name=StaticMeshComponent0 
		StaticMesh=StaticMesh'HU_Deco.SM.Mesh.S_HU_Deco_SM_ChineseLanterns'
		ScriptRigidBodyCollisionThreshold = 1
		bNotifyRigidBodyCollision = true
		HiddenGame=FALSE 
		CollideActors=True
		BlockActors=True
		BlockRigidBody=True
		LightingChannels=(Dynamic=TRUE)
		Translation=(X=0.000000,Y=0.000000,Z=-60.000000)
		RBChannel= RBCC_GameplayPhysics
        RBCollideWithChannels=(Default=True,GameplayPhysics=True,EffectPhysics=True, Vehicle=True, Pawn=True)
	End Object 
	Components.Add(StaticMeshComponent0)
	ReplicatedMesh = StaticMesh'HU_Deco.SM.Mesh.S_HU_Deco_SM_ChineseLanterns1';
}
