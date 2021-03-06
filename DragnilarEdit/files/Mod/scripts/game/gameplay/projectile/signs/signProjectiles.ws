/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/

class W3AardProjectile extends W3SignProjectile
{
	protected var staminaDrainPerc : float;
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var projectileVictim : CProjectileTrajectory;
		
		projectileVictim = (CProjectileTrajectory)collidingComponent.GetEntity();
		
		if( projectileVictim )
		{
			projectileVictim.OnAardHit( this );
		}
		
		super.OnProjectileCollision( pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex );
	}
	
	protected function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
	{
		var dmgVal : float;
		var sp, ability : SAbilityAttributeValue;
		var freezingCold : bool;
		var victimNPC : CNewNPC;
		var yrdenNovaAction : W3DamageAction; //Dragnilar - For Yrden Nova
		var slow : SCustomEffectParams; //Dragnilar - For Yrden Nova
		var isYrdenNova : bool; //Dragnilar - For Yrden Nova (obviously)
		//var isIgniNova : bool; //Dragnilar - Not implemented
		var whiteWolfMultiplier : float; //Dragnilar - For Yrden Nova

		if(FactsQuerySum("YrdenNova"))
		{
			FactsRemove("YrdenNova");
			isYrdenNova = true;
		}

		//Dragnilar - TODO - Implement this
		// if(FactsQuerySum("IgniNova"))
		// {
		// 	FactsRemove("IgniNova")
		// 	isIgniNova = true;
		// }
	
		
		if ( hitEntities.FindFirst( collider ) != -1 )
		{
			return;
		}
		
		
		hitEntities.PushBack( collider );
	
		super.ProcessCollision( collider, pos, normal );
		
		victimNPC = (CNewNPC) collider;
		
		//Dragnilar - This is based on what was used in the magic spells mod. It is somewhat nasty IMO...
		if(isYrdenNova)
		{
			//Dragnilar - Moved all this nasty code into its own function; this is still not ideal since it is repeating a lot of stuff. I also do not
			//know if it is necessary to be creating anohter damage action in the function since we could just reuse the one for Aard Sweep itself. 
			ProcessYrdenNova(victimNPC, collider);
		}
		//Dragnilar - TODO - Not implemented
		// else if(isIgniNova)
		// {
		// 	ProcessIgniNova(victimNPC, collider);
		// }
		else
		{
			//Regular Aard Sweep
			if( IsRequiredAttitudeBetween(victimNPC, caster, true ) )
			{
				freezingCold = thePlayer.CanUseSkill(S_Magic_s06);
				if ( freezingCold )
				{
					action.SetBuffSourceName( "FreezingCold" );
				}		
				else if ( owner.CanUseSkill(S_Magic_s12) )		
				{			
					//Dragnilar - Aard damage increased by spell power and player level by a factor of 10 
					sp = signEntity.GetOwner().GetTotalSignSpellPower(signEntity.GetSkill());
					dmgVal = CalculateAttributeValue( owner.GetSkillAttributeValue( S_Magic_s12, theGame.params.DAMAGE_NAME_FORCE, false, true ) );
					dmgVal *= thePlayer.GetLevel() * 25;
					if(thePlayer.IsSkillSlotted(S_Magic_s12))
						dmgVal *= 2;
					dmgVal *= sp.valueMultiplicative;
					action.AddDamage( theGame.params.DAMAGE_NAME_FORCE, dmgVal );
					if (GetWitcherPlayer().GetSkillLevel(S_Magic_s12) > 2)
					{
						dmgVal = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s12, theGame.params.DAMAGE_NAME_FROST, false, true));
						dmgVal *= thePlayer.GetLevel() * 10;
						if(thePlayer.IsSkillSlotted(S_Magic_s12))
							dmgVal *= 2;
						dmgVal * sp.valueMultiplicative;
						action.AddDamage(theGame.params.DAMAGE_NAME_FROST, dmgVal);
					}
				}
			}
			else
			{
				freezingCold = false;
			}

			action.SetHitAnimationPlayType(EAHA_ForceNo);
			action.SetProcessBuffsIfNoDamage(true);
			
			if ( !owner.IsPlayer() )
			{
				action.AddEffectInfo( EET_KnockdownTypeApplicator );
			}
			theGame.damageMgr.ProcessAction( action );

			collider.OnAardHit( this );

			if( freezingCold && victimNPC && victimNPC.IsAlive() )
			{
				ProcessFreezingCold( victimNPC ); // Dragnilar - Mutation 6 no longer is the source of this; it is now S_Magic_s06
			}
		}
	}

	private function ProcessYrdenNova(victimNPC : CNewNPC, collider : CGameplayEntity)
	{
		//Dragnilar - This is a little nasty since it uses its own W3DamageAction variable and has to calculate its damage seperately from Aard Sweep. 
		var dmgVal : float;
		var sp, ability : SAbilityAttributeValue;
		var yrdenNovaAction : W3DamageAction;
		var slow : SCustomEffectParams;

		if( IsRequiredAttitudeBetween(victimNPC, caster, true ))
		{
			//Yrden Nova / Yrden Shockwave
			yrdenNovaAction =  new W3DamageAction in this;
			yrdenNovaAction.Initialize(GetWitcherPlayer(),victimNPC,this,GetWitcherPlayer().GetName()+"_sign",EHRT_Heavy,CPS_SpellPower,false, false, true, false );
			sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3); //Need to use Yrden spell power for this
			dmgVal = thePlayer.GetLevel() * 100 * thePlayer.GetSkillLevel(S_Magic_s11);
			dmgVal *= sp.valueMultiplicative;
			if(thePlayer.CanUseSkill(S_Magic_s16))
			{
				ability = GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s16, 'yrden_damage_multiplier', false, false) * (thePlayer.GetSkillLevel(S_Magic_s16) + thePlayer.AddSlotBonusForSkillInt(S_Magic_s16, 1));
				dmgVal *= ability.valueMultiplicative;
			}
			yrdenNovaAction.AddDamage( theGame.params.DAMAGE_NAME_SHOCK, dmgVal );
			yrdenNovaAction.SetForceExplosionDismemberment();
			yrdenNovaAction.SetHitReactionType(EHRT_Heavy);
			yrdenNovaAction.SetCannotReturnDamage(true);
			yrdenNovaAction.SetProcessBuffsIfNoDamage(true);
			yrdenNovaAction.SetIgnoreArmor(true);
			yrdenNovaAction.SetHitAnimationPlayType(EAHA_ForceYes);
			yrdenNovaAction.AddEffectInfo( EET_HeavyKnockdown  );
			theGame.damageMgr.ProcessAction( yrdenNovaAction );
			delete yrdenNovaAction;
			collider.OnAardHit( this );
			slow.effectType = EET_Slowdown;
			slow.creator = thePlayer;
			slow.sourceName = thePlayer.GetName();
			slow.duration = CalculateAttributeValue((sp), 2)*0.4;
			slow.customPowerStatValue = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
			slow.effectValue.valueAdditive = 0.01 + (0.99 - 0.01) * slow.customPowerStatValue.valueMultiplicative / 5;
			slow.effectValue.valueAdditive = ClampF( slow.effectValue.valueAdditive, 0.01, 0.99 );				
			victimNPC.AddEffectCustom(slow);

			if(dmgVal>0)
			{	
				victim.PlayEffect('yrden_shock');  
			}
		}
	}

	private function ProcessIgniNova(victimNPC : CNewNPC, collider : CGameplayEntity)
	{

	}
	
	private final function ProcessFreezingCold( victimNPC : CNewNPC )
	{
		var result : EEffectInteract;
		var freezingColdAction : W3DamageAction;
		var ability : SAbilityAttributeValue;
		var sp : SAbilityAttributeValue;
		var dmgVal : float;
		var instaKill, hasKnockdown, applySlowdown : bool;
				
		instaKill = false;
		hasKnockdown = victimNPC.HasBuff( EET_Knockdown ) || victimNPC.HasBuff( EET_HeavyKnockdown ) || victimNPC.GetIsRecoveringFromKnockdown();
		GetWitcherPlayer().GetSkillAttributeValue(S_Sword_5, PowerStatEnumToName(CPS_AttackPower), false, true);
		ability = GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s06, 'full_freeze_chance', false, false);

		if( RandF() >= ability.valueMultiplicative)
		{
			
			applySlowdown = true;			
			instaKill = false;
		}
		else
		{
			
			if( victimNPC.IsImmuneToInstantKill() )
			{
				result = EI_Deny;
			}
			else
			{
				result = victimNPC.AddEffectDefault( EET_Frozen, this, "FreezingCold", true );
			}
			
			//Dragnilar - Freezing Cold is now a skill instead of a mutation; the freeze kill effect is used IF Geralt has it slotted.
			if( EffectInteractionSuccessfull( result ) && hasKnockdown && thePlayer.IsSkillSlotted(S_Magic_s06) )				
			{
				
				freezingColdAction = new W3DamageAction in theGame.damageMgr;
				freezingColdAction.Initialize( action.attacker, victimNPC, this, "FreezingCold", EHRT_None, CPS_Undefined, false, false, true, false );
				freezingColdAction.SetInstantKill();
				freezingColdAction.SetForceExplosionDismemberment();
				freezingColdAction.SetIgnoreInstantKillCooldown();
				theGame.damageMgr.ProcessAction( freezingColdAction );
				delete freezingColdAction;
				instaKill = true;
			}
		}
		
		if( applySlowdown && !hasKnockdown )
		{
			victimNPC.AddEffectDefault( EET_SlowdownFrost, this, "FreezingCold", true );
		}
		
		
		if( !instaKill && !victimNPC.HasBuff( EET_Frozen ) )
		{	
			sp = signEntity.GetOwner().GetTotalSignSpellPower(signEntity.GetSkill());
			if ( owner.CanUseSkill(S_Magic_s12) )
			{
				//Dragnilar - Aard damage increased by spell power and player level
				dmgVal = CalculateAttributeValue( owner.GetSkillAttributeValue( S_Magic_s12, theGame.params.DAMAGE_NAME_FORCE, false, true ) );
				dmgVal *= thePlayer.GetLevel() * 25;
				if(thePlayer.IsSkillSlotted(S_Magic_s12))
					dmgVal *= 2;
				dmgVal *= sp.valueMultiplicative;
				action.AddDamage( theGame.params.DAMAGE_NAME_FORCE, dmgVal );

				if (GetWitcherPlayer().GetSkillLevel(S_Magic_s12) > 2)
				{
					dmgVal = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s12, theGame.params.DAMAGE_NAME_FROST, false, true));
					dmgVal *= thePlayer.GetLevel() * 10;
					if(thePlayer.IsSkillSlotted(S_Magic_s12))
						dmgVal *= 2;					
					dmgVal * sp.valueMultiplicative;
					action.AddDamage(theGame.params.DAMAGE_NAME_FROST, dmgVal);
				}
			}

			ability = GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s06, 'ForceDamage', false, false) * thePlayer.GetSkillLevel(S_Magic_s06);
			dmgVal = CalculateAttributeValue( ability ) * sp.valueMultiplicative;
			action.AddDamage( theGame.params.DAMAGE_NAME_FORCE, dmgVal );
			
			action.ClearEffects();
			action.SetProcessBuffsIfNoDamage( false );
			action.SetForceExplosionDismemberment();
			action.SetIgnoreInstantKillCooldown();
			action.SetBuffSourceName( "FreezingCold" );
			theGame.damageMgr.ProcessAction( action );
		}
	}
	
	event OnAttackRangeHit( entity : CGameplayEntity )
	{
		entity.OnAardHit( this );
	}
	
	public final function GetStaminaDrainPerc() : float
	{
		return staminaDrainPerc;
	}
	
	public final function SetStaminaDrainPerc(p : float)
	{
		staminaDrainPerc = p;
	}
}



class W3AxiiProjectile extends W3SignProjectile
{
	protected function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
	{
		DestroyAfter( 3.f );
		
		collider.OnAxiiHit( this );	
		
	}
	
	protected function ShouldCheckAttitude() : bool
	{
		return false;
	}
}

class W3IgniProjectile extends W3SignProjectile
{
	private var channelCollided : bool;
	private var dt : float;	
	private var isUsed : bool;
	
	default channelCollided = false;
	default isUsed = false;
	
	public function SetDT(d : float)
	{
		dt = d;
	}

	public function IsUsed() : bool
	{
		return isUsed;
	}

	public function SetIsUsed( used : bool )
	{
		isUsed = used;
	}

	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var rot, rotImp : EulerAngles;
		var v, posF, pos2, n : Vector;
		var igniEntity : W3IgniEntity;
		var ent, colEnt : CEntity;
		var template : CEntityTemplate;
		var f : float;
		var test : bool;
		var postEffect : CGameplayFXSurfacePost;
		
		channelCollided = true;
		
		
		igniEntity = (W3IgniEntity)signEntity;
		
		if(signEntity.IsAlternateCast())
		{			
			
			test = (!collidingComponent && hitCollisionsGroups.Contains( 'Terrain' ) ) || (collidingComponent && !((CActor)collidingComponent.GetEntity()));
			
			colEnt = collidingComponent.GetEntity();
			if( (W3BoltProjectile)colEnt || (W3SignEntity)colEnt || (W3SignProjectile)colEnt )
				test = false;
			
			if(test)
			{
				f = theGame.GetEngineTimeAsSeconds();
				
				if(f - igniEntity.lastFxSpawnTime >= 1)
				{
					igniEntity.lastFxSpawnTime = f;
					
					template = (CEntityTemplate)LoadResource( "igni_object_fx" );
					
					
					rot.Pitch	= AcosF( VecDot( Vector( 0, 0, 0 ), normal ) );
					rot.Yaw		= this.GetHeading();
					rot.Roll	= 0.0f;
					
					
					posF = pos + VecNormalize(pos - signEntity.GetWorldPosition());
					if(theGame.GetWorld().StaticTrace(pos, posF, pos2, n, igniEntity.projectileCollision))
					{					
						ent = theGame.CreateEntity(template, pos2, rot );
						ent.AddTimer('TimerStopVisualFX', 5, , , , true);
						
						postEffect = theGame.GetSurfacePostFX();
						postEffect.AddSurfacePostFXGroup( pos2, 0.5f, 8.0f, 10.0f, 0.3f, 1 );
					}
				}				
			}
			
			
			if ( !hitCollisionsGroups.Contains( 'Water' ) )
			{
				
				v = GetWorldPosition() - signEntity.GetWorldPosition();
				rot = MatrixGetRotation(MatrixBuildFromDirectionVector(-v));
				
				igniEntity.ShowChannelingCollisionFx(GetWorldPosition(), rot, -v);
			}
		}
		
		return super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
	}

	protected function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
	{
		var signPower, channelDmg, min, max : SAbilityAttributeValue;
		var burnChance : float;					
		var maxArmorReduction : float;	
		var dmgVal : float;		
		var applyNbr : int;						
		var i : int;
		var npc : CNewNPC;
		var armorRedAblName : name;
		var currentReduction : int;
		var actorVictim : CActor;
		var ownerActor : CActor;
		var dmg : float;
		var performBurningTest : bool;
		var igniEntity : W3IgniEntity;
		var postEffect : CGameplayFXSurfacePost;
		
		//Dragnilar - Readability
		postEffect = theGame.GetSurfacePostFX();
		
		postEffect.AddSurfacePostFXGroup( pos, 0.5f, 8.0f, 10.0f, 2.5f, 1 );
		
		
		if ( hitEntities.Contains( collider ) )
		{
			return;
		}
		hitEntities.PushBack( collider );		
		
		super.ProcessCollision( collider, pos, normal );	
			
		ownerActor = owner.GetActor();
		actorVictim = ( CActor ) action.victim;
		npc = (CNewNPC)collider;
		
		//Dragnilar - Moved this up here to use Spell Power earlier.
		signPower = signEntity.GetOwner().GetTotalSignSpellPower(signEntity.GetSkill());
		if(signEntity.IsAlternateCast())		
		{
			igniEntity = (W3IgniEntity)signEntity;
			performBurningTest = igniEntity.UpdateBurningChance(actorVictim, dt);
			
			
			
			if( igniEntity.hitEntities.Contains( collider ) )
			{
				channelCollided = true;
				action.SetHitEffect('');
				action.SetHitEffect('', true );
				action.SetHitEffect('', false, true);
				action.SetHitEffect('', true, true);
				action.ClearDamage();
				
				
				channelDmg = owner.GetSkillAttributeValue(signSkill, 'channeling_damage', false, true);
				if (!owner.IsPlayer())
					dmg = channelDmg.valueAdditive + channelDmg.valueMultiplicative * actorVictim.GetMaxHealth();
				else
				{
					//Dragnilar - Added Geralt's Sign Intensity to the damage
					dmg = channelDmg.valueAdditive + 6.0f * owner.GetPlayer().GetLevel();
					//Dragnilar - Igni Fire Beam Adds skill level multiplier.
					if(thePlayer.IsSkillSlotted(S_Magic_s02))
					{
						dmg *= (thePlayer.GetSkillLevel(S_Magic_s02) * 1.5);
					}
					dmg *= signPower.valueMultiplicative;
					if(GetWitcherPlayer().IsMutationActive(EPMT_Mutation6))
					{
						theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation6', 'FireDamage', min, max );
						dmgVal += min.valueAdditive * signPower.valueMultiplicative;
					}
				}
				//Dragnilar - Note to self here - dt is most likely delta time for the DOT Base Effect damage formula; TODO - verify this
				dmg *= dt;
				action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, dmg);
				action.SetIsDoTDamage(dt);

				//Dragnilar - Blessing of Fire adds 5% life leech to Igni
				if(thePlayer.IsSkillSlotted(S_Magic_s09))
				{
					GetWitcherPlayer().Heal(dmgVal * 0.05);
				}

				if(!collider)	
					return;
			}
			else
			{
				igniEntity.hitEntities.PushBack( collider );
			}
			
			if(!performBurningTest)
			{
				action.ClearEffects();
			}
		}
		else if (owner.IsPlayer())
		{	
			//Dragnilar - Added spell power to Igni Damage.
			dmgVal = 10.0f * owner.GetPlayer().GetLevel();
			dmgVal *= signPower.valueMultiplicative;
			if(GetWitcherPlayer().IsMutationActive(EPMT_Mutation6))
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation6', 'FireDamage', min, max );
				dmgVal += min.valueAdditive * signPower.valueMultiplicative;
			}
			action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, dmgVal);
			//Dragnilar - Blessing of Fire adds 5% life leech to Igni
			if(thePlayer.IsSkillSlotted(S_Magic_s09))
			{
				LogChannel('modDragnilarEdit', "Geralt gets life back for using Igni - " + FloatToString(dmgVal * 0.05));
				GetWitcherPlayer().Heal(dmgVal * 0.05);
			}
		}
		
		
		if ( npc && npc.IsShielded( ownerActor ) )
		{
			collider.OnIgniHit( this );	
			return;
		}

		
		if ( !owner.IsPlayer() )
		{
			
			burnChance = signPower.valueMultiplicative;
			if ( RandF() < burnChance )
			{
				action.AddEffectInfo(EET_Burning);
			}
			
			dmg = CalculateAttributeValue(signPower);
			if ( dmg <= 0 )
			{
				dmg = 20;
			}		
			action.AddDamage( theGame.params.DAMAGE_NAME_FIRE, dmg);
		}
		
		if(signEntity.IsAlternateCast())
		{
			action.SetHitAnimationPlayType(EAHA_ForceNo);
		}
		else		
		{
			action.SetHitEffect('igni_cone_hit', false, false);
			action.SetHitEffect('igni_cone_hit', true, false);
			action.SetHitReactionType(EHRT_Igni, false);
		}
		
		theGame.damageMgr.ProcessAction( action );	
		
		
		if ( owner.CanUseSkill(S_Magic_s08) && (CActor)collider)
		{	
			maxArmorReduction = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s08, 'max_armor_reduction', false, true)) * (GetWitcherPlayer().GetSkillLevel(S_Magic_s08) + GetWitcherPlayer().AddSlotBonusForSkillInt(S_Magic_s08, 1));
			applyNbr = RoundMath( 100 * maxArmorReduction * ( signPower.valueMultiplicative / theGame.params.MAX_SPELLPOWER_ASSUMED ) );
			
			armorRedAblName = SkillEnumToName(S_Magic_s08);
			currentReduction = ((CActor)collider).GetAbilityCount(armorRedAblName);
			
			applyNbr -= currentReduction;
			
			for ( i = 0; i < applyNbr; i += 1 )
				action.victim.AddAbility(armorRedAblName, true);
		}	
		collider.OnIgniHit( this );		
	}	

	event OnAttackRangeHit( entity : CGameplayEntity )
	{
		entity.OnIgniHit( this );
	}

	
	event OnRangeReached()
	{
		var v : Vector;
		var rot : EulerAngles;
				
		
		if(!channelCollided)
		{			
			
			v = GetWorldPosition() - signEntity.GetWorldPosition();
			rot = MatrixGetRotation(MatrixBuildFromDirectionVector(-v));
			((W3IgniEntity)signEntity).ShowChannelingRangeFx(GetWorldPosition(), rot);
		}
		
		isUsed = false;
		
		super.OnRangeReached();
	}
	
	public function IsProjectileFromChannelMode() : bool
	{
		return signSkill == S_Magic_s02;
	}
}