/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class Test extends S placeable; //Spawnable


DefaultProperties 
{ 
	Begin Object Name=StaticMeshComponent0 
		StaticMesh=StaticMesh'HU_Floor2.SM.Mesh.S_HU_Floor_SM_WalkwaySetA_512'
		//StaticMesh=StaticMesh'UT3XContent2.Meshes.PF'
		ScriptRigidBodyCollisionThreshold = 1
		bNotifyRigidBodyCollision = true
		HiddenGame=FALSE 
		CollideActors=True
		BlockActors=True
		BlockRigidBody=True
		LightingChannels=(Dynamic=TRUE)
		Scale3D=(X=2,Y=2,Z=1)
		Translation=(X=0.000000,Y=0.000000,Z=-60.000000)
		RBChannel= RBCC_GameplayPhysics
        RBCollideWithChannels=(Default=True,GameplayPhysics=True,EffectPhysics=True, Vehicle=True, Pawn=True)
	End Object 
	Components.Add(StaticMeshComponent0)
	ReplicatedMesh = StaticMesh'HU_Floor2.SM.Mesh.S_HU_Floor_SM_WalkwaySetA_512';
}
