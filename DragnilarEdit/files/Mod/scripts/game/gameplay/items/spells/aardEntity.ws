/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



struct SAardEffects
{
	editable var baseCommonThrowEffect 				: name;
	editable var baseCommonThrowEffectUpgrade1		: name;
	editable var baseCommonThrowEffectUpgrade2		: name;
	editable var baseCommonThrowEffectUpgrade3		: name;

	editable var throwEffectSoil					: name;
	editable var throwEffectSoilUpgrade1			: name;
	editable var throwEffectSoilUpgrade2			: name;
	editable var throwEffectSoilUpgrade3			: name;
	
	editable var throwEffectSPNoUpgrade				: name;
	editable var throwEffectSPUpgrade1				: name;
	editable var throwEffectSPUpgrade2				: name;
	editable var throwEffectSPUpgrade3				: name;
	
	editable var throwEffectDmgNoUpgrade			: name;
	editable var throwEffectDmgUpgrade1				: name;
	editable var throwEffectDmgUpgrade2				: name;
	editable var throwEffectDmgUpgrade3				: name;
	
	editable var throwEffectWater 					: name;
	editable var throwEffectWaterUpgrade1			: name;
	editable var throwEffectWaterUpgrade2			: name;
	editable var throwEffectWaterUpgrade3			: name;
	
	editable var cameraShakeStrength				: float;
}

struct SAardAspect
{
	editable var projTemplate		: CEntityTemplate;
	editable var cone				: float;
	editable var distance			: float;
	editable var distanceUpgrade1	: float;
	editable var distanceUpgrade2	: float;
	editable var distanceUpgrade3	: float;
}

statemachine class W3AardEntity extends W3SignEntity
{
	editable var aspects		: array< SAardAspect >;
	editable var effects		: array< SAardEffects >;
	editable var waterTestOffsetZ : float;
	editable var waterTestDistancePerc : float;
	//Dragnilar variables for Electric Aard for White Wolf
	var position : Vector;
	var rotation : EulerAngles;
	var rAndRoll, electricDamage : float;
	var hitTest : CEntity;
	var rootVictim : array<CActor>;
	var spellPower :  SAbilityAttributeValue;
	var electricAardAction: W3DamageAction;
	var aardVictim : CNewNPC;
	var r : int;

	var projectileCollision 		: array< name >;
	
	default skillEnum = S_Magic_1;
	default waterTestOffsetZ = -2;
	default waterTestDistancePerc = 0.5;
	
		hint waterTestOffsetZ = "Z offset added to Aard Entity when testing for water level";
		hint waterTestDistancePerc = "Percentage of sign distance to use along heading for water test";		
		
	public function GetSignType() : ESignType
	{
		return ST_Aard;
	}
		
	event OnStarted()
	{

		if(IsAlternateCast())
		{
			
			
			if((CPlayer)owner.GetActor())
				GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
		}
		else
		{
			super.OnStarted();
		}
		
		projectileCollision.Clear();
		projectileCollision.PushBack( 'Projectile' );
		projectileCollision.PushBack( 'Door' );
		projectileCollision.PushBack( 'Static' );		
		projectileCollision.PushBack( 'Character' );
		projectileCollision.PushBack( 'ParticleCollider' ); 
		
		if ( owner.ChangeAspect( this, S_Magic_s01 ) )
		{
			CacheActionBuffsFromSkill();
			GotoState( 'AardCircleCast' );
		}
		else
		{
			GotoState( 'AardConeCast' );
		}
	}

	
	event OnAardHit( sign : W3AardProjectile ) {}

	
	
	
	var processThrow_alternateCast : bool;
	
	protected function ProcessThrow( alternateCast : bool )
	{
		if ( owner.IsPlayer() )
		{
			
			ProcessThrow_MainTick( alternateCast );
		}
		else
		{
			processThrow_alternateCast = alternateCast;
			AddTimer( 'ProcessThrowTimer', 0.00000001f, , , TICK_Main );
		}
	}
	
	timer function ProcessThrowTimer( dt : float, id : int )
	{
		ProcessThrow_MainTick( processThrow_alternateCast );
	}
	
	
	
	public final function GetDistance() : float
	{
		if ( owner.CanUseSkill( S_Magic_s20 ) )
		{
			switch( owner.GetSkillLevel( S_Magic_s20 ) )
			{
				case 1 : return aspects[ fireMode ].distanceUpgrade1;
				case 2 : return aspects[ fireMode ].distanceUpgrade2;
				case 3 : return aspects[ fireMode ].distanceUpgrade3;
			}
		}
		
		return aspects[ fireMode ].distance;
	}
	
	protected function ProcessThrow_MainTick( alternateCast : bool )
	{
		var projectile	: W3AardProjectile;
		var spawnPos, collisionPos, collisionNormal, waterCollTestPos : Vector;
		var spawnRot : EulerAngles;
		var heading : Vector;
		var distance, waterZ, staminaDrain : float;
		var ownerActor : CActor;
		var dispersionLevel : int;
		var attackRange : CAIAttackRange;
		var movingAgent : CMovingPhysicalAgentComponent;
		var hitsWater : bool;
		var collisionGroupNames : array<name>;
		var isYrdenNova : bool; //Dragnilar

		//Dragnilar - Check if Yrden Nova is queued up
		if(FactsQuerySum("YrdenNova"))
		{
			isYrdenNova = true;
		}
		
		
		ownerActor = owner.GetActor();
		
		if ( owner.IsPlayer() )
		{
			GCameraShake(effects[fireMode].cameraShakeStrength, true, this.GetWorldPosition(), 30.0f);
		}
		
		
		if(!isYrdenNova)
		{
			distance = GetDistance();
			if ( owner.HasCustomAttackRange() )
			{
				attackRange = theGame.GetAttackRangeForEntity( this, owner.GetCustomAttackRange() );
			}
			else if( owner.CanUseSkill( S_Magic_s20 ) )
			{
				dispersionLevel = owner.GetSkillLevel(S_Magic_s20);
				
				if(dispersionLevel == 1)
				{
					if ( !alternateCast )
						attackRange = theGame.GetAttackRangeForEntity( this, 'cone_upgrade1' );
					else
						attackRange = theGame.GetAttackRangeForEntity( this, 'blast_upgrade1' );
				}
				else if(dispersionLevel == 2)
				{
					if ( !alternateCast )
						attackRange = theGame.GetAttackRangeForEntity( this, 'cone_upgrade2' );
					else
						attackRange = theGame.GetAttackRangeForEntity( this, 'blast_upgrade2' );
				}
				else if(dispersionLevel == 3)
				{
					if ( !alternateCast )
						attackRange = theGame.GetAttackRangeForEntity( this, 'cone_upgrade3' );
					else
						attackRange = theGame.GetAttackRangeForEntity( this, 'blast_upgrade3' );
				}
			}
			else
			{
				if ( !alternateCast )
					attackRange = theGame.GetAttackRangeForEntity( this, 'cone' );
				else
					attackRange = theGame.GetAttackRangeForEntity( this, 'blast' );
			}
		}
		else
		{
			//Dragnilar - Yrden Nova uses this instead of the logic above
			attackRange = theGame.GetAttackRangeForEntity( this, 'blast_upgrade1' );
			distance = 9;
		}

		

		
		
		spawnPos = GetWorldPosition();
		spawnRot = GetWorldRotation();
		heading = this.GetHeadingVector();
		
		
		
		
		if ( alternateCast )
		{
			spawnPos.Z -= 0.5;
			
			projectile = (W3AardProjectile)theGame.CreateEntity( aspects[fireMode].projTemplate, spawnPos - heading * 0.7, spawnRot );				
			projectile.ExtInit( owner, skillEnum, this );	
			projectile.SetAttackRange( attackRange );
			projectile.SphereOverlapTest( distance, projectileCollision );	
		}
		else
		{			
			spawnPos -= 0.7 * heading;
			
			projectile = (W3AardProjectile)theGame.CreateEntity( aspects[fireMode].projTemplate, spawnPos, spawnRot );				
			projectile.ExtInit( owner, skillEnum, this );							
			projectile.SetAttackRange( attackRange );
			
			projectile.ShootCakeProjectileAtPosition( aspects[fireMode].cone, 3.5f, 0.0f, 30.0f, spawnPos + heading * distance, distance, projectileCollision );			
		}
		
		if(ownerActor.HasAbility('Glyphword 6 _Stats', true))
		{
			staminaDrain = CalculateAttributeValue(ownerActor.GetAttributeValue('glyphword6_stamina_drain_perc'));
			projectile.SetStaminaDrainPerc(staminaDrain);			
		}
		
		if(alternateCast)
		{
			movingAgent = (CMovingPhysicalAgentComponent)ownerActor.GetMovingAgentComponent();
			hitsWater = movingAgent.GetSubmergeDepth() < 0;
		}
		else
		{
			waterCollTestPos = GetWorldPosition() + heading * distance * waterTestDistancePerc;			
			waterCollTestPos.Z += waterTestOffsetZ;
			collisionGroupNames.PushBack('Terrain');
			
			
			waterZ = theGame.GetWorld().GetWaterLevel(waterCollTestPos, true);
			
			
			if(theGame.GetWorld().StaticTrace(GetWorldPosition(), waterCollTestPos, collisionPos, collisionNormal, collisionGroupNames))
			{
				
				if(waterZ > collisionPos.Z && waterZ > waterCollTestPos.Z)
					hitsWater = true;
				else
					hitsWater = false;
			}
			else
			{
				
				hitsWater = (waterCollTestPos.Z <= waterZ);
			}
		}
		
		//Dragnilar - If running Yrden Nova, do not do this since it causes Geralt to start having Aard Sweep queued up with Yrden Nova which causes problems.
		if(!isYrdenNova)
		{
			PlayAardFX(hitsWater);
			ownerActor.OnSignCastPerformed(ST_Aard, alternateCast);
			AddTimer('DelayedDestroyTimer', 0.1, true, , , true);
		}
	}
	
	
	public final function PlayAardFX(hitsWater : bool)
	{
		var dispersionLevel : int;
		var hasFreezingCold : bool;
		
		hasFreezingCold = thePlayer.CanUseSkill(S_Magic_s06);
		
		if ( owner.CanUseSkill( S_Magic_s20 ) )
		{
			dispersionLevel = owner.GetSkillLevel(S_Magic_s20);
			
			if(dispersionLevel == 1)
			{			
				
				PlayEffect( effects[fireMode].baseCommonThrowEffectUpgrade1 );
			
				
				if(!hasFreezingCold)
				{
					if(hitsWater)
						PlayEffect( effects[fireMode].throwEffectWaterUpgrade1 );
					else
						PlayEffect( effects[fireMode].throwEffectSoilUpgrade1 );
				}
			}
			else if(dispersionLevel == 2)
			{			
				
				PlayEffect( effects[fireMode].baseCommonThrowEffectUpgrade2 );
			
				
				if(!hasFreezingCold)
				{
					if(hitsWater)
						PlayEffect( effects[fireMode].throwEffectWaterUpgrade2 );
					else
						PlayEffect( effects[fireMode].throwEffectSoilUpgrade2 );
				}
			}
			else if(dispersionLevel == 3)
			{			
				
				PlayEffect( effects[fireMode].baseCommonThrowEffectUpgrade3 );
			
				
				if(!hasFreezingCold)
				{
					if(hitsWater)
						PlayEffect( effects[fireMode].throwEffectWaterUpgrade3 );
					else
						PlayEffect( effects[fireMode].throwEffectSoilUpgrade3 );
				}
			}
		}
		else
		{
			
			PlayEffect( effects[fireMode].baseCommonThrowEffect );
		
			
			if(!hasFreezingCold)
			{
				if(hitsWater)
					PlayEffect( effects[fireMode].throwEffectWater );
				else
					PlayEffect( effects[fireMode].throwEffectSoil );
			}
		}
		
		
		//Dragnilar - Consolodated old Shockwave with Aard Mastery
		if(owner.CanUseSkill(S_Magic_s12))
		{
			
			switch(dispersionLevel)
			{
				case 0:
					PlayEffect( effects[fireMode].throwEffectSPNoUpgrade );
					PlayEffect( effects[fireMode].throwEffectDmgNoUpgrade );
					break;
				case 1:
					PlayEffect( effects[fireMode].throwEffectSPUpgrade1 );
					PlayEffect( effects[fireMode].throwEffectDmgUpgrade1 );
					break;
				case 2:
					PlayEffect( effects[fireMode].throwEffectSPUpgrade2 );
					PlayEffect( effects[fireMode].throwEffectDmgUpgrade2 );
					break;
				case 3:
					PlayEffect( effects[fireMode].throwEffectSPUpgrade3 );
					PlayEffect( effects[fireMode].throwEffectDmgUpgrade3 );
					break;
			}
		}
			
		if( hasFreezingCold )
		{
			thePlayer.PlayEffect( 'mutation_6_power' );
			
			if( fireMode == 0 )
			{
				PlayEffect( 'cone_ground_mutation_6' );
			}
			else
			{
				PlayEffect( 'blast_ground_mutation_6' );
				
				theGame.GetSurfacePostFX().AddSurfacePostFXGroup(GetWorldPosition(), 0.3f, 3.f, 2.f, GetDistance(), 0 );
			}
		}
	}
	
	timer function DelayedDestroyTimer(dt : float, id : int)
	{
		var active : bool;
		
		if(owner.CanUseSkill(S_Magic_s20))
		{
			switch(owner.GetSkillLevel(S_Magic_s20))
			{
				case 1 :
					active = IsEffectActive( effects[fireMode].baseCommonThrowEffectUpgrade1 );
					break;
				case 2 :
					active = IsEffectActive( effects[fireMode].baseCommonThrowEffectUpgrade2 );
					break;
				case 3 :
					active = IsEffectActive( effects[fireMode].baseCommonThrowEffectUpgrade3 );
					break;
				default :
					LogAssert(false, "W3AardEntity.DelayedDestroyTimer: S_Magic_s20 skill level out of bounds!");
			}
		}
		else
		{
			active = IsEffectActive( effects[fireMode].baseCommonThrowEffect );
		}
		
		if(!active)
			Destroy();
	}
}

state AardConeCast in W3AardEntity extends NormalCast
{		
	event OnThrowing()
	{
		var player				: CR4Player;
		var ability : SAbilityAttributeValue;
		var bonusElectricDamage, frostBonusDamage : float;

		player = caster.GetPlayer();

		if( super.OnThrowing() )
		{
			//Dragnilar - White Wolf Electric Aard
			if(thePlayer.HasBuff(EET_WhiteWolfBuff) && thePlayer.IsSkillSlotted(S_Magic_s20))
			{
				parent.position = parent.GetWorldPosition();
				parent.rotation = parent.GetWorldRotation();
				parent.rAndRoll = RandRangeF( 180.0, -180.0 );
				parent.rotation.Roll = parent.rAndRoll;
				parent.hitTest = theGame.CreateEntity((CEntityTemplate)LoadResource("dlc\DragnilarEdit\poisonyrden\bruxa_electra.w2ent",true),
				parent.position,parent.rotation);
				parent.hitTest.CreateAttachment(thePlayer,'l_hand');
				parent.hitTest.PlayEffect( 'fx_push' );
				parent.hitTest.PlayEffect( 'fx_push0' );
				parent.hitTest.BreakAttachment();
				thePlayer.PlayEffect('mutation_1_yrden_power');
				thePlayer.SoundEvent("sign_yrden_shock_activate");
				
				thePlayer.SoundEvent("magic_sorceress_vfx_lightning_bolt");
				FactsAdd("aardelectra",,1);
				parent.hitTest.DestroyAfter(2);	
			
				parent.rootVictim = GetWitcherPlayer().GetNPCsAndPlayersInCone(13.5, VecHeading(caster.GetPlayer().GetHeadingVector()), 80, 200, , 
					FLAG_Attitude_Hostile + FLAG_OnlyAliveActors);
				parent.spellPower = GetWitcherPlayer().GetTotalSignSpellPower(parent.skillEnum);
				for( parent.r = 0; parent.r < parent.rootVictim.Size(); parent.r += 1 )   
				{
					parent.aardVictim = (CNewNPC)parent.rootVictim[parent.r]; 
					parent.electricAardAction =  new W3DamageAction in this;
					parent.electricAardAction.Initialize(thePlayer,parent.aardVictim,this,thePlayer.GetName()+"_sign",EHRT_Heavy,CPS_Undefined,false, false, true, false );
					parent.spellPower = thePlayer.GetTotalSignSpellPower(parent.skillEnum);
					parent.electricDamage += thePlayer.GetLevel() * 25;
					parent.electricDamage *= parent.spellPower.valueMultiplicative;
					//Dragnilar - TODO - Consider finding a way to centralize calculations like this; Aard's damage calculation logic shouldn't be repeated like this...
					if ( thePlayer.CanUseSkill(S_Magic_s12) )
					{
						//Dragnilar - Aard damage increased by spell power and player level
						bonusElectricDamage = CalculateAttributeValue( player.GetSkillAttributeValue( S_Magic_s12, theGame.params.DAMAGE_NAME_FORCE, false, true ) );
						bonusElectricDamage *= thePlayer.GetLevel() * 25;
						bonusElectricDamage *= parent.spellPower.valueMultiplicative;
						if (GetWitcherPlayer().GetSkillLevel(S_Magic_s12) > 2)
						{
							frostBonusDamage = CalculateAttributeValue(player.GetSkillAttributeValue(S_Magic_s12, theGame.params.DAMAGE_NAME_FROST, false, true));
							frostBonusDamage *= thePlayer.GetLevel() * 10;				
							frostBonusDamage *= parent.spellPower.valueMultiplicative;
						}
						bonusElectricDamage += frostBonusDamage;
					}
					if(thePlayer.CanUseSkill(S_Magic_s06))
					{
						ability = GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s06, 'ForceDamage', false, false) * thePlayer.GetSkillLevel(S_Magic_s06);
						bonusElectricDamage += CalculateAttributeValue( ability ) * parent.spellPower.valueMultiplicative;
					}
					if(thePlayer.IsSkillSlotted(S_Magic_s12))
						bonusElectricDamage *= 2;
					parent.electricDamage += bonusElectricDamage;
					parent.electricAardAction.AddDamage( theGame.params.DAMAGE_NAME_SHOCK, parent.electricDamage );
					parent.electricAardAction.AddEffectInfo( EET_KnockdownTypeApplicator );
					parent.electricAardAction.SetHitAnimationPlayType(EAHA_ForceYes);
					parent.electricAardAction.SetProcessBuffsIfNoDamage(true);
					parent.electricAardAction.SetForceExplosionDismemberment();
					theGame.damageMgr.ProcessAction( parent.electricAardAction );
					delete parent.electricAardAction;
					parent.aardVictim.PlayEffect('yrden_shock');
				}
			}
			else
			{
				parent.ProcessThrow( false );
			}

			
			
			if( player )
			{
				parent.ManagePlayerStamina();
				parent.ManageGryphonSetBonusBuff();
			}
			else
			{
				caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
			}
		}
	}
}

state AardCircleCast in W3AardEntity extends NormalCast
{
	event OnThrowing()
	{
		var player : CR4Player;
		var cost, stamina : float;
		
		if( super.OnThrowing() )
		{
			parent.ProcessThrow( true );
			
			player = caster.GetPlayer();
			if(player == caster.GetActor() && player && player.CanUseSkill(S_Perk_09))
			{
				cost = player.GetStaminaActionCost(ESAT_Ability, SkillEnumToName( parent.skillEnum ), 0);
				stamina = player.GetStat(BCS_Stamina, true);
				
				if(cost > stamina)
					player.DrainFocus(1);
				else
					caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
			}	
			else
				caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
		}
	}
}
