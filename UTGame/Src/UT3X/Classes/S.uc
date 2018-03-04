/**
* UT3X Mutator
* Copyright 2010-2018 by Thomas 'XtremeXp/Winter' P.
* See license.txt for license
*/
class S extends KActor abstract; //Spawnable

var const editconst DynamicLightEnvironmentComponent aLightEnvironment;

function ApplyImpulse( Vector ImpulseDir, float ImpulseMag, Vector HitLocation, optional TraceHitInfo HitInfo )
{

}

simulated event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent,const out CollisionImpactData RigidCollisionData, int ContactIndex ) {

}

event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{

}



DefaultProperties 
{ 
	Begin Object Name=MyLightEnvironment
        bEnabled=TRUE
    End Object
    aLightEnvironment=MyLightEnvironment
    Components.Add(MyLightEnvironment)

	bCollideActors = true
	bSafeBaseIfAsleep = false;
	bNoDelete = false
	bStatic = false
	bAlwaysRelevant=True
	CollisionType=COLLIDE_BlockAll;
	bMovable=False
	bPawnCanBaseOn=True
	Physics=PHYS_None
	bNoEncroachCheck=False
	bIgnoreEncroachers=False
}
