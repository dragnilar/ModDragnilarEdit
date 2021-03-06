/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/





class W3DamageManagerProcessor extends CObject 
{
	
	private var playerAttacker				: CR4Player;				
	private var playerVictim				: CR4Player;				
	private var action						: W3DamageAction;
	private var attackAction				: W3Action_Attack;			
	private var weaponId					: SItemUniqueId;			
	private var actorVictim 				: CActor;					
	private var actorAttacker				: CActor;					
	private var dm 							: CDefinitionsManagerAccessor;
	private var attackerMonsterCategory		: EMonsterCategory;
	private var victimMonsterCategory		: EMonsterCategory;
	private var victimCanBeHitByFists		: bool;
	
	
	public function ProcessAction(act : W3DamageAction)
	{
		var wasAlive, validDamage, isFrozen, autoFinishersEnabled : bool;
		var focusDrain : float;
		var npc : CNewNPC;
		var buffs : array<EEffectType>;
		var arrStr : array<string>;
		var critArrStr : array<string>;
		var aerondight	: W3Effect_Aerondight;
		var trailFxName : name;
		var critDamage, fatalDamage, maxDamage : float; //Dragnilar
			
		wasAlive = act.victim.IsAlive();		
		npc = (CNewNPC)act.victim;
		
		
 		InitializeActionVars(act);
 		
 		
		
 		if(playerVictim && attackAction && attackAction.IsActionMelee() && !attackAction.CanBeParried() && attackAction.IsParried())
 		{
			action.GetEffectTypes(buffs);
			
			if(!buffs.Contains(EET_Knockdown) && !buffs.Contains(EET_HeavyKnockdown))
			{
				
				action.SetParryStagger();
				
				
				action.SetProcessBuffsIfNoDamage(true);
				
				
				action.AddEffectInfo(EET_LongStagger);
				
				
				action.SetHitAnimationPlayType(EAHA_ForceNo);
				action.SetCanPlayHitParticle(false);
				
				
				action.RemoveBuffsByType(EET_Bleeding);
			}
 		}
 		
 		
 		if(actorAttacker && playerVictim && ((W3PlayerWitcher)playerVictim) && GetWitcherPlayer().IsAnyQuenActive())
			FactsAdd("player_had_quen");
		
		
		ProcessPreHitModifications();

		
		ProcessActionQuest(act);
		
		
		isFrozen = (actorVictim && actorVictim.HasBuff(EET_Frozen));
		
		
		validDamage = ProcessActionDamage();
		
		//Dragnilar - Moved critical hit here; it bothers me that you do not see the damage in the action log.
		//Dragnilar - Use integers instead of floats for damage since the floats show notation after they go over 999,999
		if(action.IsCriticalHit())
		{
			critDamage = MaxF( action.processedDmg.vitalityDamage, action.processedDmg.essenceDamage );
			critArrStr.PushBack(action.attacker.GetDisplayName());
			critArrStr.PushBack((string)RoundMath(critDamage));
			theGame.witcherLog.AddCombatMessage(theGame.witcherLog.COLOR_GOLD_BEGIN + GetLocStringByKeyExtWithParams("hud_combat_log_critical_hit",,,critArrStr) + theGame.witcherLog.COLOR_GOLD_END, action.attacker, NULL);

		}

		if(wasAlive && !action.victim.IsAlive())
		{
			arrStr.PushBack(action.victim.GetDisplayName());
			if(npc && npc.WillBeUnconscious())
			{
				theGame.witcherLog.AddCombatMessage(GetLocStringByKeyExtWithParams("hud_combat_log_unconscious", , , arrStr), NULL, action.victim);
			}
			else if(action.attacker && action.attacker.GetDisplayName() != "")
			{
				//Dragnilar - Show killing blow damage
				//Dragnilar - Use integers instead of floats for damage since the floats show notation after they go over 999,999
				arrStr.PushBack(action.attacker.GetDisplayName());
				fatalDamage = MaxF( action.processedDmg.vitalityDamage, action.processedDmg.essenceDamage );
				arrStr.PushBack((string)RoundMath(fatalDamage));
				theGame.witcherLog.AddCombatMessage(GetLocStringByKeyExtWithParams("hud_combat_log_killed", , , arrStr), action.attacker, action.victim);
			}
			else
			{
				theGame.witcherLog.AddCombatMessage(GetLocStringByKeyExtWithParams("hud_combat_log_dies", , , arrStr), NULL, action.victim);
			}
		}
		
		if( wasAlive && action.DealsAnyDamage() )
		{
			//Dragnilar - Use integers instead of floats for damage since the floats show notation after they go over 999,999
			maxDamage = MaxF( action.processedDmg.vitalityDamage, action.processedDmg.essenceDamage );
			((CActor) action.attacker).SignalGameplayEventParamInt(  'CausesDamage', RoundMath(maxDamage) );
		}
		
		
		ProcessActionReaction(isFrozen, wasAlive);
		
		
		if(action.DealsAnyDamage() || action.ProcessBuffsIfNoDamage())
			ProcessActionBuffs();
		
		
		if(theGame.CanLog() && !validDamage && action.GetEffectsCount() == 0)
		{
			LogAssert(false, "W3DamageManagerProcessor.ProcessAction: action deals no damage and gives no buffs - investigate!");
			if ( theGame.CanLog() )
			{
				LogDMHits("*** Action has no valid damage and no valid buffs - investigate!", action);
			}
		}
		
		
		if( actorAttacker && wasAlive )
			actorAttacker.OnProcessActionPost(action);

		
		//Dragnilar - Poison Yrden Proc is based off of the poisoned blades chance.
		if(actorAttacker == thePlayer && attackAction && attackAction.IsActionMelee() && actorVictim)
		{
			if(GetWitcherPlayer().IsSkillSlotted(S_Alchemy_s12))
			{
				if(RandF() < GetPoisonedBladesChance(true))
				{
					GetWitcherPlayer().CastPoisonYrden();
				}
			}
		}

		
		if(actorVictim == GetWitcherPlayer() && action.DealsAnyDamage() && !action.IsDoTDamage())
		{
			if(actorAttacker && attackAction)
			{
				if(actorAttacker.IsHeavyAttack( attackAction.GetAttackName() ))
					focusDrain = CalculateAttributeValue(thePlayer.GetAttributeValue('heavy_attack_focus_drain'));
				else if(actorAttacker.IsSuperHeavyAttack( attackAction.GetAttackName() ))
					focusDrain = CalculateAttributeValue(thePlayer.GetAttributeValue('super_heavy_attack_focus_drain'));
				else 
					focusDrain = CalculateAttributeValue(thePlayer.GetAttributeValue('light_attack_focus_drain')); 
			}
			else
			{
				
				focusDrain = CalculateAttributeValue(thePlayer.GetAttributeValue('light_attack_focus_drain')); 
			}
			
			//Dragnilar - If White Wolf is slotted and active, Geralt doesn't lose any Adrenaline
			if(!thePlayer.HasBuff(EET_WhiteWolfBuff) && !thePlayer.IsSkillSlotted(S_Sword_s19))
			{
				if ( GetWitcherPlayer().CanUseSkill(S_Sword_s16) )
					focusDrain *= 1 - (CalculateAttributeValue( thePlayer.GetSkillAttributeValue(S_Sword_s16, 'focus_drain_reduction', false, true) ) * thePlayer.GetSkillLevel(S_Sword_s16));

				thePlayer.DrainFocus(focusDrain);
			}
		}
		
		
		if(actorAttacker == GetWitcherPlayer() && actorVictim && !actorVictim.IsAlive() && (action.IsActionMelee() || action.GetBuffSourceName() == "Kill"))
		{
			autoFinishersEnabled = theGame.GetInGameConfigWrapper().GetVarValue('Gameplay', 'AutomaticFinishersEnabled');
			
			
			
			if(!autoFinishersEnabled || !thePlayer.GetFinisherVictim())
			{
				if(thePlayer.HasAbility('Runeword 10 _Stats', true))
					GetWitcherPlayer().Runeword10Triggerred();
				if(thePlayer.HasAbility('Runeword 12 _Stats', true))
					GetWitcherPlayer().Runeword12Triggerred();
			}
		}
		
		
		if(action.EndsQuen() && actorVictim)
		{
			actorVictim.FinishQuen(false);			
		}

		
		if(actorVictim == thePlayer && attackAction && attackAction.IsActionMelee() && (ShouldProcessTutorial('TutorialDodge') || ShouldProcessTutorial('TutorialCounter') || ShouldProcessTutorial('TutorialParry')) )
		{
			if(attackAction.IsCountered())
			{
				theGame.GetTutorialSystem().IncreaseCounters();
			}
			else if(attackAction.IsParried())
			{
				theGame.GetTutorialSystem().IncreaseParries();
			}
			
			if(attackAction.CanBeDodged() && !attackAction.WasDodged())
			{
				GameplayFactsAdd("tut_failed_dodge", 1, 1);
				GameplayFactsAdd("tut_failed_roll", 1, 1);
			}
		}
		
		if( playerAttacker && npc && action.IsActionMelee() && action.DealtDamage() && IsRequiredAttitudeBetween( playerAttacker, npc, true ) && !npc.HasTag( 'AerondightIgnore' ) )
		{			
			if( playerAttacker.inv.ItemHasTag( attackAction.GetWeaponId(), 'Aerondight' ))
			{
				
				aerondight = (W3Effect_Aerondight)playerAttacker.GetBuff( EET_Aerondight );
				aerondight.IncreaseAerondightCharges( attackAction.GetAttackName() );
				
				
				if( aerondight.GetCurrentCount() == aerondight.GetMaxCount() )
				{
					switch( npc.GetBloodType() )
					{
						case BT_Red : 
							trailFxName = 'aerondight_blood_red';
							break;
							
						case BT_Yellow :
							trailFxName = 'aerondight_blood_yellow';
							break;
						
						case BT_Black : 
							trailFxName = 'aerondight_blood_black';
							break;
						
						case BT_Green :
							trailFxName = 'aerondight_blood_green';
							break;
					}
					
					playerAttacker.inv.GetItemEntityUnsafe( attackAction.GetWeaponId() ).PlayEffect( trailFxName );
				}
			}
		}
	}
	
	
	private final function InitializeActionVars(act : W3DamageAction)
	{
		var tmpName : name;
		var tmpBool	: bool;
	
		action 				= act;
		playerAttacker 		= (CR4Player)action.attacker;
		playerVictim		= (CR4Player)action.victim;
		attackAction 		= (W3Action_Attack)action;		
		actorVictim 		= (CActor)action.victim;
		actorAttacker		= (CActor)action.attacker;
		dm 					= theGame.GetDefinitionsManager();
		
		if(attackAction)
			weaponId 		= attackAction.GetWeaponId();
			
		theGame.GetMonsterParamsForActor(actorVictim, victimMonsterCategory, tmpName, tmpBool, tmpBool, victimCanBeHitByFists);
		
		if(actorAttacker)
			theGame.GetMonsterParamsForActor(actorAttacker, attackerMonsterCategory, tmpName, tmpBool, tmpBool, tmpBool);
	}
	
	
	
	
	
	
	private function ProcessActionQuest(act : W3DamageAction)
	{
		var victimTags, attackerTags : array<name>;
		
		victimTags = action.victim.GetTags();
		
		if(action.attacker)
			attackerTags = action.attacker.GetTags();
		
		AddHitFacts( victimTags, attackerTags, "_weapon_hit" );
		
		
		if ((CGameplayEntity) action.victim) action.victim.OnWeaponHit(act);
	}
	
	
	
	
	
	private function ProcessActionDamage() : bool
	{
		var directDmgIndex, size, i : int;
		var dmgInfos : array< SRawDamage >;
		var immortalityMode : EActorImmortalityMode;
		var dmgValue, finalDamage, returnedDamage : float; //Dragnilar - Added returned damage for Quen Fire Shield
		var anyDamageProcessed, fallingRaffard : bool;
		var victimHealthPercBeforeHit, frozenAdditionalDamage : float;		
		var powerMod, sp : SAbilityAttributeValue; //Dragnilar - Added sp for Quen Fire Shield
		var witcher : W3PlayerWitcher;
		var canLog : bool;
		var immortalityChannels : array<EActorImmortalityChanel>;
		var returnFire : W3DamageAction; //Dragnilar -  For Quen Fire Shield
		var returnFireEnt : CEntity;
		
		canLog = theGame.CanLog();
		
		
		action.SetAllProcessedDamageAs(0);
		size = action.GetDTs( dmgInfos );
		action.SetDealtFireDamage(false);		
		
		
		if(!actorVictim || (!actorVictim.UsesVitality() && !actorVictim.UsesEssence()) )
		{
			
			for(i=0; i<size; i+=1)
			{
				if(dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_FIRE && dmgInfos[i].dmgVal > 0)
				{
					action.victim.OnFireHit( (CGameplayEntity)action.causer );
					break;
				}
			}
			
			if ( !actorVictim.abilityManager )
				actorVictim.OnDeath(action);
			
			return false;
		}
		
		
		if(actorVictim.UsesVitality())
			victimHealthPercBeforeHit = actorVictim.GetStatPercents(BCS_Vitality);
		else
			victimHealthPercBeforeHit = actorVictim.GetStatPercents(BCS_Essence);

		// Dragnilar - taken from FCR3 --
		if ( actorVictim && playerAttacker && victimMonsterCategory == MC_Specter && playerAttacker.HasBuff(EET_Mutagen28) )
		{
			actorVictim.BlockAbility('ShadowForm', true);
			actorVictim.BlockAbility('Flashstep', true);
			actorVictim.BlockAbility('EssenceRegen', true);
			actorVictim.BlockAbility('Teleport', true);
		}
		// -- Dragnilar - taken from FCR3		
		
		ProcessDamageIncrease( dmgInfos );
					
		
		if ( canLog )
		{
			LogBeginning();
		}
			
		
		ProcessCriticalHitCheck();
		
		
		ProcessOnBeforeHitChecks();
		
		
		powerMod = GetAttackersPowerMod();

		
		anyDamageProcessed = false;
		directDmgIndex = -1;
		witcher = GetWitcherPlayer();
		size = dmgInfos.Size();			
		for( i = 0; i < size; i += 1 )
		{
			
			if(dmgInfos[i].dmgVal == 0)
				continue;
			
			if(dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_DIRECT)
			{
				directDmgIndex = i;
				continue;
			}
			
			
			if(dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_POISON && witcher == actorVictim && witcher.HasBuff(EET_GoldenOriole) && witcher.GetPotionBuffLevel(EET_GoldenOriole) == 3)
			{
				
				witcher.GainStat(BCS_Vitality, dmgInfos[i].dmgVal);
				
				
				if ( canLog )
				{
					LogDMHits("", action);
					LogDMHits("*** Player absorbs poison damage from level 3 Golden Oriole potion: " + dmgInfos[i].dmgVal, action);
				}
				
				
				dmgInfos[i].dmgVal = 0;
				
				continue;
			}
			
			
			if ( canLog )
			{
				LogDMHits("", action);
				LogDMHits("*** Incoming " + NoTrailZeros(dmgInfos[i].dmgVal) + " " + dmgInfos[i].dmgType + " damage", action);
				if(action.IsDoTDamage())
					LogDMHits("DoT's current dt = " + NoTrailZeros(action.GetDoTdt()) + ", estimated dps = " + NoTrailZeros(dmgInfos[i].dmgVal / action.GetDoTdt()), action);
			}
			
			
			anyDamageProcessed = true;
				
			LogChannel('modDragnilarEdit', "Final power mod before damage: " + FloatToString(powerMod.valueMultiplicative) + " towards " + actorVictim.GetName());
			dmgValue = MaxF(0, CalculateDamage(dmgInfos[i], powerMod));

			//Dragnilar - If Geralt is using Aerondight and attacking an enemy, only add damage to the proper channel, 
			//otherwise the damage will get doubled.
			if(witcher.IsUsingAerondight() && actorVictim != witcher)
			{
				if (actorVictim.UsesEssence())
				{
					action.processedDmg.essenceDamage  += dmgValue;
					if( DamageHitsMorale(   dmgInfos[i].dmgType ) )		action.processedDmg.moraleDamage   += dmgValue;
					if( DamageHitsStamina(  dmgInfos[i].dmgType ) )		action.processedDmg.staminaDamage  += dmgValue;
				}
				else
				{
					action.processedDmg.vitalityDamage += dmgValue;
					if( DamageHitsMorale(   dmgInfos[i].dmgType ) )		action.processedDmg.moraleDamage   += dmgValue;
					if( DamageHitsStamina(  dmgInfos[i].dmgType ) )		action.processedDmg.staminaDamage  += dmgValue;
				}
			}
			else
			{   
				//Dragnilar - Aerondight isn't being used, it's business as usual.
				if( DamageHitsEssence(  dmgInfos[i].dmgType ) )		action.processedDmg.essenceDamage  += dmgValue;
				if( DamageHitsVitality( dmgInfos[i].dmgType ) )		action.processedDmg.vitalityDamage += dmgValue;
				if( DamageHitsMorale(   dmgInfos[i].dmgType ) )		action.processedDmg.moraleDamage   += dmgValue;
				if( DamageHitsStamina(  dmgInfos[i].dmgType ) )		action.processedDmg.staminaDamage  += dmgValue;
			}

			
		}
		
		if(size == 0 && canLog)
		{
			LogDMHits("*** There is no incoming damage set (probably only buffs).", action);
		}
		
		if ( canLog )
		{
			LogDMHits("", action);
			LogDMHits("Processing block, parry, immortality, signs and other GLOBAL damage reductions...", action);		
		}
				
		if(actorVictim)
			actorVictim.ReduceDamage(action);
				
		
		if(directDmgIndex != -1)
		{
			anyDamageProcessed = true;
			
			
			immortalityChannels = actorVictim.GetImmortalityModeChannels(AIM_Invulnerable);
			fallingRaffard = immortalityChannels.Size() == 1 && immortalityChannels.Contains(AIC_WhiteRaffardsPotion) && action.GetBuffSourceName() == "FallingDamage";
			
			if(action.GetIgnoreImmortalityMode() || (!actorVictim.IsImmortal() && !actorVictim.IsInvulnerable() && !actorVictim.IsKnockedUnconscious()) || fallingRaffard)
			{
				action.processedDmg.vitalityDamage += dmgInfos[directDmgIndex].dmgVal;
				action.processedDmg.essenceDamage  += dmgInfos[directDmgIndex].dmgVal;
			}
			else if( actorVictim.IsInvulnerable() )
			{
				
			}
			else if( actorVictim.IsImmortal() )
			{
				
				action.processedDmg.vitalityDamage += MinF(dmgInfos[directDmgIndex].dmgVal, actorVictim.GetStat(BCS_Vitality)-1 );
				action.processedDmg.essenceDamage  += MinF(dmgInfos[directDmgIndex].dmgVal, actorVictim.GetStat(BCS_Essence)-1 );
			}
		}
		
		
		if( actorVictim.HasAbility( 'OneShotImmune' ) )
		{
			if( action.processedDmg.vitalityDamage >= actorVictim.GetStatMax( BCS_Vitality ) )
			{
				action.processedDmg.vitalityDamage = actorVictim.GetStatMax( BCS_Vitality ) - 1;
			}
			else if( action.processedDmg.essenceDamage >= actorVictim.GetStatMax( BCS_Essence ) )
			{
				action.processedDmg.essenceDamage = actorVictim.GetStatMax( BCS_Essence ) - 1;
			}
		}
		//Dragnilar - Quen Fire Shield for Pyromaniac Mutation
		if(playerVictim && !playerAttacker && actorAttacker && attackAction && attackAction.IsActionMelee() && FactsQuerySum("QuenFireShield") > 0)
		{
			sp = witcher.GetTotalSignSpellPower(S_Magic_4);
			returnedDamage = action.processedDmg.vitalityDamage * sp.valueMultiplicative;
			returnFire =  new W3DamageAction in theGame.damageMgr;
			returnFire.Initialize( witcher, actorAttacker, this, witcher.GetName()+"_sign", EHRT_Heavy, CPS_Undefined, false, false, true, false);
			returnFire.AddDamage(theGame.params.DAMAGE_NAME_FIRE, returnedDamage);
			actorAttacker.PlayEffect('fire_hit');
			returnFire.SetProcessBuffsIfNoDamage(true);
			returnFire.SetCannotReturnDamage( true );		
			returnFire.SetHitAnimationPlayType(EAHA_ForceYes);
			returnFireEnt = actorAttacker.CreateFXEntityAtPelvis('mutation2_critical', true);
			returnFireEnt.PlayEffect('critical_igni');
			theGame.damageMgr.ProcessAction(returnFire);
			delete returnFire;
		}
		
		
		if(action.HasDealtFireDamage())
			action.victim.OnFireHit( (CGameplayEntity)action.causer );
		
		//Dragnilar - Instant kills can now only occur if the enemy has ForceInstantKill. The instant kill stat is replaced with Brutal Strike.
		ProcessInstantKill();
			
		
		ProcessActionDamage_DealDamage();
		
		
		if(playerAttacker && witcher)
			witcher.SetRecentlyCountered(false);
		
		
		if( attackAction && !attackAction.IsCountered() && playerVictim && attackAction.IsActionMelee())
			theGame.GetGamerProfile().ResetStat(ES_CounterattackChain);
		
		

		
		ProcessActionDamage_ReduceDurability();
		
		
		if(playerAttacker && actorVictim)
		{
			
			if(playerAttacker.inv.ItemHasAnyActiveOilApplied(weaponId) && (!playerAttacker.CanUseSkill(S_Alchemy_s06) || (playerAttacker.GetSkillLevel(S_Alchemy_s06) < 3)) )
			{			
				playerAttacker.ReduceAllOilsAmmo( weaponId );
				
				if(ShouldProcessTutorial('TutorialOilAmmo'))
				{
					FactsAdd("tut_used_oil_in_combat");
				}
			}
			
			
			playerAttacker.inv.ReduceItemRepairObjectBonusCharge(weaponId);
		}
		
		if(actorVictim && actorAttacker && !action.GetCannotReturnDamage())
		{
			ProcessActionReturnedDamage();
		}
		

		
		return anyDamageProcessed;
	}
	
	
	private function ProcessInstantKill()
	{
		var instantKill, focus : float;
		
		//Dragnilar - Instant kills can only occur now if an enemy has ForceInstantKill

		if( actorAttacker.HasAbility( 'ForceInstantKill' ) && actorVictim != thePlayer )
		{
			//Dragnilar  - Logging
			LogChannel('modDragnilarEdit', action.victim + " was forced to instant kill.");
			action.SetInstantKill();
		}

		if (action.GetInstantKill())
		{
			if( theGame.CanLog() )
			{
				if( action.GetInstantKill() )
				{
					instantKill = 1.f;
				}
				LogDMHits( "Instant kill!! (" + NoTrailZeros( instantKill * 100 ) + "% chance", action );
			}

			action.processedDmg.vitalityDamage += actorVictim.GetStat( BCS_Vitality );
			action.processedDmg.essenceDamage += actorVictim.GetStat( BCS_Essence );
			action.SetCriticalHit();	
			action.SetInstantKillFloater();	
			//Dragnilar  - Logging
			LogChannel('modDragnilarEdit', action.victim + " was was instantly killed with" + NoTrailZeros( instantKill * 100 ) + "% chance to kill." );	
			
			
			if( playerAttacker )
			{
				thePlayer.SetLastInstantKillTime( theGame.GetGameTime() );
				theSound.SoundEvent( 'cmb_play_deadly_hit' );
				theGame.SetTimeScale( 0.2, theGame.GetTimescaleSource( ETS_InstantKill ), theGame.GetTimescalePriority( ETS_InstantKill ), true, true );
				thePlayer.AddTimer( 'RemoveInstantKillSloMo', 0.2 );
			}			
		}
	}
	
	
	private function ProcessOnBeforeHitChecks()
	{
		//Dragnilar - Moved variables for poisoned blades to the GetPoisonedBladesChance() function.
		var effectAbilityName, monsterBonusType : name;
		var effectType : EEffectType;
		var null, monsterBonusVal, min, max : SAbilityAttributeValue;
		var i : int;
		var buffs : array<name>;
	
		
		if( playerAttacker && actorVictim && attackAction && attackAction.IsActionMelee() && playerAttacker.CanUseSkill(S_Alchemy_s12) && playerAttacker.inv.ItemHasActiveOilApplied( weaponId, victimMonsterCategory ) )
		{
			
			monsterBonusType = MonsterCategoryToAttackPowerBonus(victimMonsterCategory);
			monsterBonusVal = playerAttacker.inv.GetItemAttributeValue(weaponId, monsterBonusType);
		
			if(monsterBonusVal != null)
			{	
				if(RandF() < GetPoisonedBladesChance(false))
				{
					dm.GetContainedAbilities(playerAttacker.GetSkillAbilityName(S_Alchemy_s12), buffs);
					for(i=0; i<buffs.Size(); i+=1)
					{
						EffectNameToType(buffs[i], effectType, effectAbilityName);
						action.AddEffectInfo(effectType, , , effectAbilityName);
					}
				}
			}
		}

		//Dragnilar - Rogue mutagen adds chance to poison to all attacks
		if(playerAttacker && actorVictim && attackAction && GetWitcherPlayer().HasMutagenEquipped(M_Rogue))
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('rogue_mutagen_bonus', 'poison_chance', min, max);

			if(RandF() < min.valueAdditive)
			{
				action.AddEffectInfo(EET_Poison, , , 'PoisonEffect');
			}
		}
	}

	//Dragnilar - Moved Poisoned Blades roll to its own function so code can be reused.
	private function GetPoisonedBladesChance(useForPoisonYrden: bool) : float
	{
		var oilLevel, skillLevel : int;
		var baseChance, perOilLevelChance, chance : float;

		oilLevel = (int)CalculateAttributeValue(playerAttacker.inv.GetItemAttributeValue(weaponId, 'level')) - 1;				
		skillLevel = playerAttacker.GetSkillLevel(S_Alchemy_s12);
		baseChance = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Alchemy_s12, 'skill_chance', false, true));
		perOilLevelChance = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Alchemy_s12, 'oil_level_chance', false, true));						
		chance = baseChance * skillLevel + perOilLevelChance * oilLevel;

		//Dragnilar - Poison Yrden's chance cannot exceed 10%.
		if(useForPoisonYrden)
		{
			if(chance > 10.00)
				chance = 10.00;
		}

		return chance;
	}
	
	
	private function ProcessCriticalHitCheck()
	{
		var critChance, critDamageBonus : float;
		var	canLog, meleeOrRanged, redWolfSet, isLightAttack, isHeavyAttack, mutation2, whiteWolfMutation : bool;
		var arrStr : array<string>;
		var samum, sinister : CBaseGameplayEffect;
		var signPower, min, max : SAbilityAttributeValue;
		var aerondight : W3Effect_Aerondight;

		meleeOrRanged = playerAttacker && attackAction && ( attackAction.IsActionMelee() || attackAction.IsActionRanged() );
		redWolfSet = ( W3Petard )action.causer && ( W3PlayerWitcher )actorAttacker && GetWitcherPlayer().IsSetBonusActive( EISB_RedWolf_1 );
		mutation2 = ( W3PlayerWitcher )actorAttacker && GetWitcherPlayer().IsMutationActive(EPMT_Mutation2) && action.IsActionWitcherSign();
		whiteWolfMutation = (W3PlayerWitcher)actorAttacker && GetWitcherPlayer().IsMutationActive(EPMT_Mutation11) && thePlayer.HasBuff(EET_WhiteWolfBuff) && action.IsActionWitcherSign();
		
		if( meleeOrRanged || redWolfSet || mutation2 || whiteWolfMutation )
		{
			canLog = theGame.CanLog();
		
			
			if( mutation2 )
			{
				if( FactsQuerySum('debug_fact_critical_boy') > 0 )
				{
					critChance = 1.f;
				}
				else
				{
					signPower = action.GetPowerStatValue();
					theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation2', 'crit_chance_factor', min, max);
					critChance = min.valueAdditive + signPower.valueMultiplicative * min.valueMultiplicative;
				}
			} 			
			else
			{
				if( attackAction || whiteWolfMutation )
				{
					
					if( SkillEnumToName(S_Sword_s02) == attackAction.GetAttackTypeName() )
					{				
						critChance += CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s02, theGame.params.CRITICAL_HIT_CHANCE, false, true)) * playerAttacker.GetSkillLevel(S_Sword_s02);
					}
					
					
					if(GetWitcherPlayer() && GetWitcherPlayer().HasRecentlyCountered() && playerAttacker.CanUseSkill(S_Sword_s11) && playerAttacker.GetSkillLevel(S_Sword_s11) > 2)
					{
						critChance += CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s11, theGame.params.CRITICAL_HIT_CHANCE, false, true));
					}
					
					
					isLightAttack = playerAttacker.IsLightAttack( attackAction.GetAttackName() );
					isHeavyAttack = playerAttacker.IsHeavyAttack( attackAction.GetAttackName() );
					critChance += playerAttacker.GetCriticalHitChance(isLightAttack, isHeavyAttack, actorVictim, victimMonsterCategory, (W3BoltProjectile)action.causer );
					
					
					if(action.GetIsHeadShot())
					{
						critChance += theGame.params.HEAD_SHOT_CRIT_CHANCE_BONUS;
						actorVictim.SignalGameplayEvent( 'Headshot' );
					}
					
					
					if ( actorVictim && actorVictim.IsAttackerAtBack(playerAttacker) )
					{
						critChance += theGame.params.BACK_ATTACK_CRIT_CHANCE_BONUS;
					}

					//White wolf mutation's sign crit chance bonus
					if(whiteWolfMutation)
					{
						signPower = action.GetPowerStatValue();
						theGame.GetDefinitionsManager().GetAbilityAttributeValue('WhiteWolfMutation', 'crit_chance_factor', min, max);
						critChance+= min.valueAdditive + signPower.valueMultiplicative * min.valueMultiplicative;
					}
					
					if((action.IsActionMelee() || whiteWolfMutation) && playerAttacker.inv.ItemHasTag( attackAction.GetWeaponId(), 'Aerondight' ))
					{
						aerondight = (W3Effect_Aerondight)playerAttacker.GetBuff( EET_Aerondight );
						
						if( aerondight && aerondight.IsFullyCharged() )
						{
							//Dragnilar - Aerondight should always crit if it's fully charged, no point in grabbing the bonus from the item.
							critChance = 1.0f;
							//min = playerAttacker.GetAbilityAttributeValue( 'AerondightEffect', 'crit_chance_bonus' );
							//critChance += min.valueAdditive;
						}
					}
				}
				else
				{
					
					critChance += playerAttacker.GetCriticalHitChance(false, false, actorVictim, victimMonsterCategory, (W3BoltProjectile)action.causer );
				}
				
				
				samum = actorVictim.GetBuff(EET_Blindness, 'petard');
				if(samum && samum.GetBuffLevel() == 3)
				{
					critChance += 1.0f;
				}

				//Dragnilar - Enemies inflicted with Sinister's blindness debuff have 100% chance of being critically hit
				sinister = actorVictim.GetBuff(EET_Blindness, S_Sword_s17);
				if(sinister)
				{
					critChance += 1.0f;
				}


			}
			
			
			if ( canLog )
			{
				
				critDamageBonus = 1 + CalculateAttributeValue(actorAttacker.GetCriticalHitDamageBonus(weaponId, victimMonsterCategory, actorVictim.IsAttackerAtBack(playerAttacker)));
				critDamageBonus += CalculateAttributeValue(actorAttacker.GetAttributeValue('critical_hit_chance_fast_style'));
				critDamageBonus = 100 * critDamageBonus;
				
				
				LogDMHits("", action);				
				LogDMHits("Trying critical hit (" + NoTrailZeros(critChance*100) + "% chance, dealing " + NoTrailZeros(critDamageBonus) + "% damage)...", action);
			}
			
			
			if(RandF() < critChance)
			{
				
				action.SetCriticalHit();
								
				if ( canLog )
				{
					LogDMHits("********************", action);
					LogDMHits("*** CRITICAL HIT ***", action);
					LogDMHits("********************", action);				
				}
				
			}
			else if ( canLog )
			{
				LogDMHits("... nope", action);
			}
		}	
	}
	
	
	private function LogBeginning()
	{
		var logStr : string;
		
		if ( !theGame.CanLog() )
		{
			return;
		}
		
		LogDMHits("-----------------------------------------------------------------------------------", action);		
		logStr = "Beginning hit processing from <<" + action.attacker + ">> to <<" + action.victim + ">> via <<" + action.causer + ">>";
		if(attackAction)
		{
			logStr += " using AttackType <<" + attackAction.GetAttackTypeName() + ">>";		
		}
		logStr += ":";
		LogDMHits(logStr, action);
		LogDMHits("", action);
		LogDMHits("Target stats before damage dealt are:", action);
		if(actorVictim)
		{
			if( actorVictim.UsesVitality() )
				LogDMHits("Vitality = " + NoTrailZeros(actorVictim.GetStat(BCS_Vitality)), action);
			if( actorVictim.UsesEssence() )
				LogDMHits("Essence = " + NoTrailZeros(actorVictim.GetStat(BCS_Essence)), action);
			if( actorVictim.GetStatMax(BCS_Stamina) > 0)
				LogDMHits("Stamina = " + NoTrailZeros(actorVictim.GetStat(BCS_Stamina, true)), action);
			if( actorVictim.GetStatMax(BCS_Morale) > 0)
				LogDMHits("Morale = " + NoTrailZeros(actorVictim.GetStat(BCS_Morale)), action);
		}
		else
		{
			LogDMHits("Undefined - victim is not a CActor and therefore has no stats", action);
		}
	}
	
	
	private function ProcessDamageIncrease(out dmgInfos : array< SRawDamage >)
	{
		var difficultyDamageMultiplier, rendLoad, rendBonus, overheal, rendRatio, focusCost, frostDamage : float;
		var i, bonusCount : int;
		var frozenBuff : W3Effect_Frozen;
		var frozenDmgInfo : SRawDamage;
		var hadFrostDamage : bool;
		var mpac : CMovingPhysicalAgentComponent;
		var rendBonusPerPoint, staminaRendBonus, perk20Bonus : SAbilityAttributeValue;
		var witcherAttacker : W3PlayerWitcher;
		var damageVal, damageBonus, min, max			: SAbilityAttributeValue;		
		var npcVictim : CNewNPC;
		var sword : SItemUniqueId;
		var actionFreeze : W3DamageAction;
		var aerondight	: W3Effect_Aerondight;
		var whiteWolfMult : float; //Dragnilar - For White Wolf
		var whirlDamagePenalty : float; //Dragnilar - Whirl damage penalty
		var aerondightLevel : int;
		
		
		
		if(actorAttacker && !actorAttacker.IgnoresDifficultySettings() && !action.IsDoTDamage())
		{
			difficultyDamageMultiplier = CalculateAttributeValue(actorAttacker.GetAttributeValue(theGame.params.DIFFICULTY_DMG_MULTIPLIER));
			for(i=0; i<dmgInfos.Size(); i+=1)
			{
				dmgInfos[i].dmgVal = dmgInfos[i].dmgVal * difficultyDamageMultiplier;
			}
		}

		//Dragnilar - Whirl now has a damage penalty
		if (playerAttacker && attackAction && (thePlayer.IsDoingSpecialAttack(false) || SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s01))
		{
			whirlDamagePenalty = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s01, 'damage_penalty', false, true));
			if(thePlayer.GetSkillLevel(S_Sword_s01) == 1)
				whirlDamagePenalty = whirlDamagePenalty * 3;
			else if(thePlayer.GetSkillLevel(S_Sword_s01) == 2)
				whirlDamagePenalty = whirlDamagePenalty * 2;
			for(i=0; i<dmgInfos.Size(); i+=1)
			{
				dmgInfos[i].dmgVal = dmgInfos[i].dmgVal * (1 - whirlDamagePenalty);
			}

		}		


		//Dragnilar - White Wolf damage multiplier
		if(playerAttacker && playerAttacker.HasBuff(EET_WhiteWolfBuff) && attackAction && !attackAction.WasDodged() && !action.IsDoTDamage())
		{
			whiteWolfMult = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue( S_Sword_s19, 'damage_multiplier', false, true ));
			if(GetWitcherPlayer().IsSetBonusActive(EISB_Wolf_2))
			{
				dm.GetAbilityAttributeValue('SetBonusAbilityWolf_2', 'damage_multiplier_boost', min, max);
				whiteWolfMult += min.valueAdditive;
			}
			if(GetWitcherPlayer().IsMutationActive(EPMT_Mutation11))
			{
				dm.GetAbilityAttributeValue('WhiteWolfMutation', 'damage_multiplier_boost', min, max);
				whiteWolfMult += min.valueAdditive;
			}
			for(i=0; i<dmgInfos.Size(); i+=1)
			{
				dmgInfos[i].dmgVal = dmgInfos[i].dmgVal * whiteWolfMult;
			}
		}
			
		
		
		
		if(actorVictim && playerAttacker && !action.IsDoTDamage() && actorVictim.HasBuff(EET_Frozen) && ( (W3AardProjectile)action.causer || (W3AardEntity)action.causer || action.DealsPhysicalOrSilverDamage()) )
		{
			
			action.SetWasFrozen();
			
			
			if( !( ( W3WhiteFrost )action.causer ) )
			{				
				frozenBuff = (W3Effect_Frozen)actorVictim.GetBuff(EET_Frozen);			
				frozenDmgInfo.dmgVal = frozenBuff.GetAdditionalDamagePercents() * actorVictim.GetHealth();
			}
			
			
			actorVictim.RemoveAllBuffsOfType(EET_Frozen);
			action.AddEffectInfo(EET_KnockdownTypeApplicator);
			
			
			if( !( ( W3WhiteFrost )action.causer ) )
			{
				actionFreeze = new W3DamageAction in theGame;
				actionFreeze.Initialize( actorAttacker, actorVictim, action.causer, action.GetBuffSourceName(), EHRT_None, CPS_Undefined, action.IsActionMelee(), action.IsActionRanged(), action.IsActionWitcherSign(), action.IsActionEnvironment() );
				actionFreeze.SetCannotReturnDamage( true );
				actionFreeze.SetCanPlayHitParticle( false );
				actionFreeze.SetHitAnimationPlayType( EAHA_ForceNo );
				actionFreeze.SetWasFrozen();
				frostDamage = frozenDmgInfo.dmgVal; //Dragnilar - Readability		
				actionFreeze.AddDamage( theGame.params.DAMAGE_NAME_FROST, frostDamage );
				theGame.damageMgr.ProcessAction( actionFreeze );
				delete actionFreeze;
			}
		}
		
		
		if(actorVictim)
		{
			mpac = (CMovingPhysicalAgentComponent)actorVictim.GetMovingAgentComponent();
						
			if(mpac && mpac.IsDiving())
			{
				mpac = (CMovingPhysicalAgentComponent)actorAttacker.GetMovingAgentComponent();	
				
				if(mpac && mpac.IsDiving())
				{
					action.SetUnderwaterDisplayDamageHack();
				
					if(playerAttacker && attackAction && attackAction.IsActionRanged())
					{
						for(i=0; i<dmgInfos.Size(); i+=1)
						{
							if(FactsQuerySum("NewGamePlus"))
							{
								dmgInfos[i].dmgVal *= (1 + theGame.params.UNDERWATER_CROSSBOW_DAMAGE_BONUS_NGP);
							}
							else
							{
								dmgInfos[i].dmgVal *= (1 + theGame.params.UNDERWATER_CROSSBOW_DAMAGE_BONUS);
							}
						}
					}
				}
			}
		}
		
		
		if(playerAttacker && attackAction && SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02)
		{
			
			witcherAttacker = (W3PlayerWitcher)playerAttacker;
			
			
			rendRatio = witcherAttacker.GetSpecialAttackTimeRatio();
			
			
			rendLoad = MinF(rendRatio * playerAttacker.GetStatMax(BCS_Focus), playerAttacker.GetStat(BCS_Focus));
			
			
			if(rendLoad >= 1)
			{
				//Dragnilar - damage bonus now gets skill level multiplier
				rendBonusPerPoint = witcherAttacker.GetSkillAttributeValue(S_Sword_s02, 'adrenaline_final_damage_bonus', false, true) * playerAttacker.GetSkillLevel(S_Sword_s02);
				rendBonus = FloorF(rendLoad) * rendBonusPerPoint.valueMultiplicative;
				
				for(i=0; i<dmgInfos.Size(); i+=1)
				{
					dmgInfos[i].dmgVal *= (1 + rendBonus);
				}
			}
			
			
			staminaRendBonus = witcherAttacker.GetSkillAttributeValue(S_Sword_s02, 'stamina_max_dmg_bonus', false, true);
			
			for(i=0; i<dmgInfos.Size(); i+=1)
			{
				dmgInfos[i].dmgVal *= (1 + rendRatio * staminaRendBonus.valueMultiplicative);
			}
		}	
 
		
		if ( actorAttacker != thePlayer && action.IsActionRanged() && (int)CalculateAttributeValue(actorAttacker.GetAttributeValue('level',,true)) > 31)
		{
			damageVal = actorAttacker.GetAttributeValue('light_attack_damage_vitality',,true);
			for(i=0; i<dmgInfos.Size(); i+=1)
			{
				dmgInfos[i].dmgVal = dmgInfos[i].dmgVal + CalculateAttributeValue(damageVal) / 2;
			}
		}
		
		
		if ( actorVictim && playerAttacker && attackAction && action.IsActionMelee() && thePlayer.HasAbility('Runeword 4 _Stats', true) && !attackAction.WasDodged() )
		{
			overheal = thePlayer.abilityManager.GetOverhealBonus() / thePlayer.GetStatMax(BCS_Vitality);
		
			if(overheal > 0.005f)
			{
				for(i=0; i<dmgInfos.Size(); i+=1)
				{
					dmgInfos[i].dmgVal *= 1.0f + overheal;
				}
			
				thePlayer.abilityManager.ResetOverhealBonus();
				
				
				actorVictim.CreateFXEntityAtPelvis( 'runeword_4', true );				
			}
		}
		
		
		if( playerAttacker && playerAttacker.IsLightAttack( attackAction.GetAttackName() ) && playerAttacker.HasBuff( EET_LynxSetBonus ) && !attackAction.WasDodged() ) 
		{
			if( !attackAction.IsParried() && !attackAction.IsCountered() )
			{
				
				damageBonus = playerAttacker.GetAttributeValue( 'lynx_dmg_boost' );
				
				damageBonus.valueAdditive *= ((W3PlayerWitcher)playerAttacker).GetSetPartsEquipped( EIST_Lynx );
				
				for( i=0 ; i<dmgInfos.Size() ; i += 1 )
				{
					dmgInfos[i].dmgVal *= 1 + damageBonus.valueAdditive;
				}
			}
		}
				
		if( playerAttacker && attackAction.IsActionMelee() && actorVictim.IsAttackerAtBack( playerAttacker ) && !actorVictim.HasAbility( 'CannotBeAttackedFromBehind' ) && ((W3PlayerWitcher)playerAttacker).IsSetBonusActive( EISB_Lynx_2 ) && !attackAction.WasDodged() && ( playerAttacker.inv.IsItemSteelSwordUsableByPlayer( attackAction.GetWeaponId() ) || playerAttacker.inv.IsItemSilverSwordUsableByPlayer( attackAction.GetWeaponId() ) ) )
		{
			if( !attackAction.IsParried() && !attackAction.IsCountered() && playerAttacker.GetStat(BCS_Focus) >= 1.0f )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( GetSetBonusAbility( EISB_Lynx_2 ), 'lynx_2_dmg_boost', min, max );
				for( i=0; i<dmgInfos.Size() ; i+=1 )
				{
					dmgInfos[i].dmgVal *= 1 + min.valueAdditive;
				}
				
				if ( !( thePlayer.IsInCombatAction() && ( thePlayer.GetCombatAction() == EBAT_SpecialAttack_Light || thePlayer.GetCombatAction() == EBAT_SpecialAttack_Heavy ) ) )
				{
					theGame.GetDefinitionsManager().GetAbilityAttributeValue( GetSetBonusAbility( EISB_Lynx_2 ), 'lynx_2_adrenaline_cost', min, max );
					focusCost = min.valueAdditive;
					if( GetWitcherPlayer().GetStat( BCS_Focus ) >= focusCost )
					{				
						theGame.GetDefinitionsManager().GetAbilityAttributeValue( GetSetBonusAbility( EISB_Lynx_2 ), 'lynx_2_stun_duration', min, max );
						attackAction.AddEffectInfo( EET_Confusion, min.valueAdditive );
						playerAttacker.SoundEvent( "ep2_setskill_lynx_activate" );
						if(!thePlayer.HasBuff(EET_WhiteWolfBuff) && !thePlayer.IsSkillSlotted(S_Sword_s19))
							playerAttacker.DrainFocus( focusCost );
					}
				}
			}
		}

		
		if ( playerAttacker && action.IsActionRanged() && ((W3Petard)action.causer) && GetWitcherPlayer().CanUseSkill(S_Perk_20) )
		{
			perk20Bonus = GetWitcherPlayer().GetSkillAttributeValue( S_Perk_20, 'dmg_multiplier', false, false);
			for( i = 0 ; i < dmgInfos.Size() ; i+=1)
			{
				dmgInfos[i].dmgVal *= ( 1 + perk20Bonus.valueMultiplicative );
			}
		}
		
		
		if( playerAttacker && action.IsActionWitcherSign() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation1 ) )
		{
			sword = playerAttacker.inv.GetCurrentlyHeldSword();
			
			damageVal.valueBase = 0;
			damageVal.valueMultiplicative = 0;
			damageVal.valueAdditive = 0;
		
			if( playerAttacker.inv.GetItemCategory(sword) == 'steelsword' )
			{
				damageVal += playerAttacker.inv.GetItemAttributeValue(sword, theGame.params.DAMAGE_NAME_SLASHING);
			}
			else if( playerAttacker.inv.GetItemCategory(sword) == 'silversword' )
			{
				damageVal += playerAttacker.inv.GetItemAttributeValue(sword, theGame.params.DAMAGE_NAME_SILVER);
			}
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation1', 'dmg_bonus_factor', min, max);				
			
			damageVal.valueBase *= CalculateAttributeValue(min);
			
			if( action.IsDoTDamage() )
			{
				damageVal.valueBase *= action.GetDoTdt();
			}
			
			for( i = 0 ; i < dmgInfos.Size() ; i+=1)
			{
				dmgInfos[i].dmgVal += damageVal.valueBase;
			}
		}
		
		
		npcVictim = (CNewNPC) actorVictim;
		if( playerAttacker && npcVictim && attackAction && action.IsActionMelee() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation8 ) && ( victimMonsterCategory != MC_Human || npcVictim.IsImmuneToMutation8Finisher() ) && attackAction.GetWeaponId() == GetWitcherPlayer().GetHeldSword() )
		{
			dm.GetAbilityAttributeValue( 'Mutation8', 'dmg_bonus', min, max );
			
			for( i = 0 ; i < dmgInfos.Size() ; i+=1)
			{
				dmgInfos[i].dmgVal *= 1 + min.valueMultiplicative;
			}
		}
		
		if( playerAttacker && actorVictim && attackAction && action.IsActionMelee()
			&& playerAttacker.inv.ItemHasTag( attackAction.GetWeaponId(), 'Aerondight' ))
		{	
			aerondight = (W3Effect_Aerondight)playerAttacker.GetBuff( EET_Aerondight );	
			
			if( aerondight )
			{
				min = playerAttacker.GetAbilityAttributeValue( 'AerondightEffect', 'dmg_bonus' );
				bonusCount = aerondight.GetCurrentCount();
			
				if( bonusCount > 0 )
				{
					min.valueMultiplicative *= bonusCount;					
					for( i = 0 ; i < dmgInfos.Size() ; i += 1 )
					{
						//Dragnilar - Aerondight's level boosts the damage multiplier
						dmgInfos[i].dmgVal *= 1 + (min.valueMultiplicative * aerondight.GetAerondightLevel());
					}
				}				
			}
		}	
	}
	
	
	private function ProcessActionReturnedDamage()
	{
		var witcher 			: W3PlayerWitcher;
		var quen 				: W3QuenEntity;
		var params 				: SCustomEffectParams;
		var processFireShield, canBeParried, canBeDodged, wasParried, wasDodged, returned : bool;
		var g5Chance			: SAbilityAttributeValue;
		var dist, checkDist		: float;
		
		
		if((W3PlayerWitcher)playerVictim && !playerAttacker && actorAttacker && !action.IsDoTDamage() && action.IsActionMelee() && (attackerMonsterCategory == MC_Necrophage || attackerMonsterCategory == MC_Vampire) && actorVictim.HasBuff(EET_BlackBlood))
		{
			returned = ProcessActionBlackBloodReturnedDamage();		
		}
		
		
		if(action.IsActionMelee() && actorVictim.HasAbility( 'Thorns' ) )
		{
			returned = ProcessActionThornDamage() || returned;
		}
		
		if(actorVictim.HasAbility( 'Glyphword 5 _Stats', true))
		{			
			if( GetAttitudeBetween(actorAttacker, actorVictim) == AIA_Hostile)
			{
				if( !action.IsDoTDamage() )
				{
					g5Chance = actorVictim.GetAttributeValue('glyphword5_chance');
					
					if(RandF() < g5Chance.valueAdditive)
					{
						canBeParried = attackAction.CanBeParried();
						canBeDodged = attackAction.CanBeDodged();
						wasParried = attackAction.IsParried() || attackAction.IsCountered();
						wasDodged = attackAction.WasDodged();
				
						if(!action.IsActionMelee() || (!canBeParried && canBeDodged && !wasDodged) || (canBeParried && !wasParried && !canBeDodged) || (canBeParried && canBeDodged && !wasDodged && !wasParried))
						{
							returned = ProcessActionReflectDamage() || returned;
						}
					}	
				}
			}			
			
		}
		
		
		if(playerVictim && !playerAttacker && actorAttacker && attackAction && attackAction.IsActionMelee() && thePlayer.HasBuff(EET_Mutagen26))
		{
			returned = ProcessActionLeshenMutagenDamage() || returned;
		}
		
		
		if(action.IsActionMelee() && actorVictim.HasAbility( 'FireShield' ) )
		{
			witcher = GetWitcherPlayer();			
			processFireShield = true;			
			if(playerAttacker == witcher)
			{
				quen = (W3QuenEntity)witcher.GetSignEntity(ST_Quen);
				if(quen && quen.IsAnyQuenActive())
				{
					processFireShield = false;
				}
			}
			
			if(processFireShield)
			{
				params.effectType = EET_Burning;
				params.creator = actorVictim;
				params.sourceName = actorVictim.GetName();
				
				params.effectValue.valueMultiplicative = 0.01;
				actorAttacker.AddEffectCustom(params);
				returned = true;
			}
		}
		
		
		if(actorAttacker.UsesEssence())
		{
			returned = ProcessSilverStudsReturnedDamage() || returned;
		}
			
		
		if( (W3PlayerWitcher)playerVictim && !playerAttacker && actorAttacker && !playerAttacker.IsInFistFightMiniGame() && !action.IsDoTDamage() && action.IsActionMelee() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation4 ) )
		{
			
			dist = VecDistance( actorAttacker.GetWorldPosition(), actorVictim.GetWorldPosition() );
			checkDist = 3.f;
			if( actorAttacker.IsHuge() )
			{
				checkDist += 3.f;
			}
 
			if( dist <= checkDist )
			{
				returned = GetWitcherPlayer().ProcessActionMutation4ReturnedDamage( action.processedDmg.vitalityDamage, actorAttacker, EAHA_ForceYes, action ) || returned;
			}
		}
		
		action.SetWasDamageReturnedToAttacker( returned );
	}
	
	
	private function ProcessActionLeshenMutagenDamage() : bool
	{
		var damageAction : W3DamageAction;
		var returnedDamage, pts, perc : float;
		var mutagen : W3Mutagen26_Effect;
		
		mutagen = (W3Mutagen26_Effect)playerVictim.GetBuff(EET_Mutagen26);
		mutagen.GetReturnedDamage(pts, perc);
		
		if(pts <= 0 && perc <= 0)
			return false;
			
		returnedDamage = pts + perc * action.GetDamageValueTotal();
		
		
		damageAction = new W3DamageAction in this;		
		damageAction.Initialize( action.victim, action.attacker, NULL, "Mutagen26", EHRT_None, CPS_AttackPower, true, false, false, false );		
		damageAction.SetCannotReturnDamage( true );		
		damageAction.SetHitAnimationPlayType( EAHA_ForceNo );
		damageAction.AddDamage(theGame.params.DAMAGE_NAME_SILVER, returnedDamage);
		damageAction.AddDamage(theGame.params.DAMAGE_NAME_PHYSICAL, returnedDamage);
		
		theGame.damageMgr.ProcessAction(damageAction);
		delete damageAction;
		
		return true;
	}
	
	
	private function ProcessSilverStudsReturnedDamage() : bool
	{
		var damageAction : W3DamageAction;
		var returnedDamage : float;
		
		returnedDamage = CalculateAttributeValue(actorVictim.GetAttributeValue('returned_silver_damage'));
		
		if(returnedDamage <= 0)
			return false;
		
		damageAction = new W3DamageAction in this;
		damageAction.Initialize( action.victim, action.attacker, NULL, "SilverStuds", EHRT_None, CPS_AttackPower, true, false, false, false );
		damageAction.SetCannotReturnDamage( true );		
		damageAction.SetHitAnimationPlayType( EAHA_ForceNo );		
		damageAction.AddDamage(theGame.params.DAMAGE_NAME_SILVER, returnedDamage);
		
		theGame.damageMgr.ProcessAction(damageAction);
		delete damageAction;
		
		return true;
	}
	
	
	private function ProcessActionBlackBloodReturnedDamage() : bool
	{
		var returnedAction : W3DamageAction;
		var returnVal : SAbilityAttributeValue;
		var bb : W3Potion_BlackBlood;
		var potionLevel : int;
		var returnedDamage : float;
	
		if(action.processedDmg.vitalityDamage <= 0)
			return false;
		
		bb = (W3Potion_BlackBlood)actorVictim.GetBuff(EET_BlackBlood);
		potionLevel = bb.GetBuffLevel();
		
		
		returnedAction = new W3DamageAction in this;	
		returnedAction.Initialize( action.victim, action.attacker, bb, "BlackBlood", EHRT_None, CPS_AttackPower, true, false, false, false );
		returnedAction.SetCannotReturnDamage( true );		
		
		returnVal = bb.GetReturnDamageValue();
		
		if(potionLevel == 1)
		{
			returnedAction.SetHitAnimationPlayType(EAHA_ForceNo);
		}
		else
		{
			returnedAction.SetHitAnimationPlayType(EAHA_ForceYes);
			returnedAction.SetHitReactionType(EHRT_Reflect);
		}
		
		returnedDamage = (returnVal.valueBase + action.processedDmg.vitalityDamage) * returnVal.valueMultiplicative + returnVal.valueAdditive;
		returnedAction.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, returnedDamage);
		
		theGame.damageMgr.ProcessAction(returnedAction);
		delete returnedAction;
		return true;
	}
	
	
	private function ProcessActionReflectDamage() : bool
	{
		var returnedAction : W3DamageAction;
		var returnVal, min, max : SAbilityAttributeValue;
		var potionLevel : int;
		var attackerDamage, returnedDamage : float;
		var template : CEntityTemplate;
		var fxEnt : CEntity;
		var boneIndex: int;
		var b : bool;
		var component : CComponent;
		
		//Dragnilar get the damage the attacker deals
		attackerDamage = action.GetDamageDealt(); 
		
		if(attackerDamage <= 0)
			return false;
		
		//Dragnilar - Armor was being used instead of the attacker damage, which didn't make any sense. Instead use the glyphword power * damage dealt.
		//returnedDamage = CalculateAttributeValue(actorVictim.GetTotalArmor());
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 5 _Stats', 'damage_mult', min, max);
		returnedDamage = attackerDamage * min.valueMultiplicative; 
		if (returnedDamage <= 0)  //Dragnilar - This could still be zero, so don't bother continuing...
			return false;
		returnedAction = new W3DamageAction in this;	
		returnedAction.Initialize( action.victim, action.attacker, NULL, "Glyphword5", EHRT_None, CPS_AttackPower, true, false, false, false );	
		returnedAction.SetCannotReturnDamage( true );		
		returnedAction.SetHitAnimationPlayType(EAHA_ForceYes);
		returnedAction.SetHitReactionType(EHRT_Heavy);
		returnedDamage = returnedDamage * min.valueMultiplicative;
		//returnedAction.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, returnedDamage * min.valueMultiplicative); //Dragnilar - Already did this up above
		returnedAction.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, returnedDamage);
		
		
		
		theGame.damageMgr.ProcessAction(returnedAction);
		delete returnedAction;
		
		template = (CEntityTemplate)LoadResource('glyphword_5');
		
		
		
		
		
		
		component = action.attacker.GetComponent('torso3effect');
		if(component)
			thePlayer.PlayEffect('reflection_damge', component);
		else
			thePlayer.PlayEffect('reflection_damge', action.attacker);
		action.attacker.PlayEffect('yrden_shock');
		
		return true;
	}
	
	
	private function ProcessActionThornDamage() : bool
	{
		var damageAction 		: W3DamageAction;
		var damageVal 			: SAbilityAttributeValue;
		var damage				: float;
		var inv					: CInventoryComponent;
		var damageNames			: array < CName >;
		
		damageAction	= new W3DamageAction in this;
		
		damageAction.Initialize( action.victim, action.attacker, NULL, "Thorns", EHRT_Light, CPS_AttackPower, true, false, false, false );
		
		damageAction.SetCannotReturnDamage( true );		
		
		damageVal 				=  actorVictim.GetAttributeValue( 'light_attack_damage_vitality' );
		
		
		
		
		
		inv = actorAttacker.GetInventory();		
		inv.GetWeaponDTNames(weaponId, damageNames );
		damageVal.valueBase  = actorAttacker.GetTotalWeaponDamage(weaponId, damageNames[0], GetInvalidUniqueId() );
		
		damageVal.valueBase *= 0.10f;
		
		if( damageVal.valueBase == 0 )
		{
			damageVal.valueBase = 10;
		}
				
		damage = (damageVal.valueBase + action.processedDmg.vitalityDamage) * damageVal.valueMultiplicative + damageVal.valueAdditive;
		damageAction.AddDamage(  theGame.params.DAMAGE_NAME_PIERCING, damage );
		
		damageAction.SetHitAnimationPlayType( EAHA_ForceYes );
		theGame.damageMgr.ProcessAction(damageAction);
		delete damageAction;
		
		return true;
	}
		
	
	private function GetAttackersPowerMod() : SAbilityAttributeValue
	{		
		var powerMod, criticalDamageBonus, min, max, critReduction, sp, monsterSlayer, coldBlood : SAbilityAttributeValue; 
		var mutagen : CBaseGameplayEffect;
		var totalBonus : float;
		var focus : float;
		var brutalStrikeChance : float;
		var checkForBrutalStrike : bool;
		var skillLevel : int;
		var geralt : W3PlayerWitcher;
		var whiteWolfEffect : W3Effect_WhiteWolfBuff;
		var whiteWolfTimeLeft : float; 
			
		geralt = GetWitcherPlayer();
		powerMod = action.GetPowerStatValue();
		if ( powerMod.valueAdditive == 0 && powerMod.valueBase == 0 && powerMod.valueMultiplicative == 0 && theGame.CanLog() )
			LogDMHits("Attacker has power stat of 0!", action);
		
		if(playerAttacker && attackAction && geralt.IsHeavyAttack(attackAction.GetAttackName()))
			powerMod.valueMultiplicative -= 0.833;
		
		
		if ( playerAttacker && (W3IgniProjectile)action.causer )
			powerMod.valueMultiplicative = 1 + (powerMod.valueMultiplicative - 1) * theGame.params.IGNI_SPELL_POWER_MILT;
		
		
		if ( playerAttacker && (W3AardProjectile)action.causer )
			powerMod.valueMultiplicative = 1;

		//Dragnilar - ...Silver For Monsters increases attack power mod by a percentage against monsters
		if(playerAttacker && geralt.CanUseSkill(S_Sword_s12) && actorVictim.UsesEssence())
		{
			monsterSlayer = (geralt.GetSkillAttributeValue(S_Sword_s12, PowerStatEnumToName(CPS_AttackPower), false, true) * 
				(geralt.GetSkillLevel(S_Sword_s12) + geralt.AddSlotBonusForSkillInt(S_Sword_s12, 1)));
			LogChannel('modDragnilarEdit', "DamageManagerProcessor: Geralt gains multiplier from ...Silver For Monsters - " + NoTrailZeros(monsterSlayer.valueMultiplicative));
			powerMod.valueBase *= 1.0f + monsterSlayer.valueMultiplicative;
		}
		//Dragnilar - Steel For Humans... increases attack mod power by a percentage against non-monsters
		if(playerAttacker && geralt.CanUseSkill(S_Sword_s15) && actorVictim.UsesVitality())
		{
			coldBlood = (geralt.GetSkillAttributeValue(S_Sword_s15, PowerStatEnumToName(CPS_AttackPower), false, true) * 
				(geralt.GetSkillLevel(S_Sword_s15) + geralt.AddSlotBonusForSkillInt(S_Sword_s15, 1)));
			LogChannel('modDragnilarEdit', "DamageManagerProcessor: Geralt gains multiplier from Steel For Humans...- " + NoTrailZeros(coldBlood.valueMultiplicative));
			powerMod.valueBase *= 1.0f + coldBlood.valueMultiplicative;
		}

		if(action.IsCriticalHit())
		{
			checkForBrutalStrike = true;

			if( playerAttacker && action.IsActionWitcherSign() && geralt.IsMutationActive(EPMT_Mutation2) )
			{
				sp = action.GetPowerStatValue();
				
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation2', 'crit_damage_factor', min, max);				
				criticalDamageBonus.valueAdditive = sp.valueMultiplicative * min.valueMultiplicative;
			}
			else 
			{
				criticalDamageBonus = actorAttacker.GetCriticalHitDamageBonus(weaponId, victimMonsterCategory, actorVictim.IsAttackerAtBack(playerAttacker));
				
				criticalDamageBonus += actorAttacker.GetAttributeValue('critical_hit_chance_fast_style');
				
				if(attackAction && playerAttacker)
				{
					//Dragnilar - Firey Dancer Expertiese 
					if(geralt.IsHeavyAttack(attackAction.GetAttackName()) && geralt.CanUseSkill(S_Sword_s08))
						criticalDamageBonus += geralt.GetSkillAttributeValue(S_Sword_s08, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * 
						(geralt.GetSkillLevel(S_Sword_s08) + geralt.AddSlotBonusForSkillInt(S_Sword_s08, 1));
					else if (!playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && playerAttacker.CanUseSkill(S_Sword_s21))
					{
						criticalDamageBonus += geralt.GetSkillAttributeValue(S_Sword_s21, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * 
							(geralt.GetSkillLevel(S_Sword_s21) + geralt.AddSlotBonusForSkillInt(S_Sword_s21, 1));
					}

				}
			}
			
			//Wolven Crossbow Mastery increases crossbow critical hit damage 
			if (playerAttacker && (W3BoltProjectile)action.causer && geralt.CanUseSkill(S_Sword_s13))
				criticalDamageBonus += geralt.GetSkillAttributeValue(S_Sword_s21, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * 
							(geralt.GetSkillLevel(S_Sword_s13) + geralt.AddSlotBonusForSkillInt(S_Sword_s13, 1));

			//Dragnilar - Deadly precision adds passive critical hit damage bonus
			if(playerAttacker && playerAttacker.CanUseSkill(S_Sword_s03))
			{
				skillLevel = geralt.GetSkillLevel(S_Sword_s03) + playerAttacker.AddSlotBonusForSkillInt(S_Sword_s03, 1);
				criticalDamageBonus += geralt.GetSkillAttributeValue(S_Sword_s03, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * skillLevel;
			}
			
			//Dragnilar - Razor Focus adds critical damage bonus for each adrenaline/focus point
			if(playerAttacker && geralt.CanUseSkill(S_Sword_s20))
			{
				focus = geralt.GetStat (BCS_Focus); 
				if (focus >= 1)
				{
					criticalDamageBonus += ((geralt.GetSkillAttributeValue(S_Sword_s20, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true)) * focus);
				}
			}

			//Dragnilar Violence adds critical damage bonus
			if(playerAttacker && geralt.CanUseSkill(S_Sword_s06))
			{
				skillLevel = geralt.GetSkillLevel(S_Sword_s06) + geralt.AddSlotBonusForSkillInt(S_Sword_s06, 2);
				criticalDamageBonus += geralt.GetSkillAttributeValue(S_Sword_s06, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * skillLevel;
			}

			//Blessing Of Earth adds critical damage bonus
			if(playerAttacker && geralt.CanUseSkill(S_Magic_s14))
			{
				criticalDamageBonus += geralt.GetSkillAttributeValue(S_Magic_s14, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * geralt.GetSkillLevel(S_Magic_s14);
			}

			//Blessing Of Fire adds critical damage bonus
			if(playerAttacker && geralt.CanUseSkill(S_Magic_s09))
			{
				criticalDamageBonus += geralt.GetSkillAttributeValue(S_Magic_s09, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * geralt.GetSkillLevel(S_Magic_s09);
			}

			//Steel For Humans... adds critical damage bonus
			if(playerAttacker && geralt.CanUseSkill(S_Sword_s15))
			{
				criticalDamageBonus += geralt.GetSkillAttributeValue(S_Sword_s15, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * geralt.GetSkillLevel(S_Sword_s15);
			}

			//Sinister adds critical damage bonus
			if(playerAttacker && geralt.CanUseSkill(S_Sword_s17))
			{
				criticalDamageBonus += geralt.GetSkillAttributeValue(S_Sword_s17, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * geralt.GetSkillLevel(S_Sword_s17);
			}
	        			
			totalBonus = CalculateAttributeValue(criticalDamageBonus);

			critReduction = actorVictim.GetAttributeValue(theGame.params.CRITICAL_HIT_REDUCTION);
			totalBonus = totalBonus * ClampF(1 - critReduction.valueMultiplicative, 0.f, 1.f);
			powerMod.valueMultiplicative += totalBonus;
		}
		
		if (actorVictim && playerAttacker)
		{
			if ( playerAttacker.HasBuff(EET_Mutagen05) && (geralt.GetStat(BCS_Vitality) == geralt.GetStatMax(BCS_Vitality)) )
			{
				mutagen = geralt.GetBuff(EET_Mutagen05);
				dm.GetAbilityAttributeValue(mutagen.GetAbilityName(), 'damageIncrease', min, max);
				powerMod += GetAttributeRandomizedValue(min, max);
			}
		}

		if (checkForBrutalStrike)
		{
			//Dragnilar - Instant kill chance has been changed to brutal strike. To avoid causing havoc with the rest of the game's engine and scripts
			//the internal variable is still called the same thing. The external tool tip has been renamed.
			brutalStrikeChance = CalculateAttributeValue( actorAttacker.GetInventory().GetItemAttributeValue( weaponId, 'instant_kill_chance' ) );
			if(playerAttacker)
			{
				if (geralt.CanUseSkill( S_Sword_s03 ))
				{
					focus = geralt.GetStat (BCS_Focus); 
					if( focus >= 1 )
					{
						brutalStrikeChance += focus * (CalculateAttributeValue( geralt.GetSkillAttributeValue( S_Sword_s03, 'instant_kill_chance', false, true ) ) * geralt.GetSkillLevel( S_Sword_s03 ));
						if (geralt.IsSkillSlotted(S_Sword_s03))
						{
							brutalStrikeChance *= 1.5;
						}
					}
				}
				//Dragnilar - strength training increases brutal strike chance
				if (geralt.CanUseSkill(S_Sword_s04) && geralt.GetSkillLevel(S_Sword_s04) > 2)
				{
					brutalStrikeChance += CalculateAttributeValue(geralt.GetSkillAttributeValue(S_Sword_s04, 'instant_kill_chance', false, false)) * 
						(geralt.GetSkillLevel(S_Sword_s04) + geralt.AddSlotBonusForSkillInt(S_Sword_s04, 1));
				}
				//Dragnilar - Temerian Devil Expertiese increases brutal strike chance, does not scale with skill level
				if (geralt.CanUseSkill(S_Sword_s08) && geralt.GetSkillLevel(S_Sword_s08) > 2)
				{
					brutalStrikeChance += CalculateAttributeValue(geralt.GetSkillAttributeValue(S_Sword_s08, 'instant_kill_chance', false, false));
					brutalStrikeChance += geralt.AddSlotBonusForSkillInt(S_Sword_s08, 2);
				}
				//Dragnilar - Frenzy adds brutal strike chance if Geralt's toxicity is above 0
				if(geralt.CanUseSkill(S_Alchemy_s16) && geralt.GetStat(BCS_Toxicity) > 0)
				{
					brutalStrikeChance += CalculateAttributeValue(geralt.GetSkillAttributeValue(S_Alchemy_s16, 'instant_kill_chance', false, false)) *
					 (geralt.GetSkillLevel(S_Alchemy_s16) + geralt.AddSlotBonusForSkillInt(S_Alchemy_s16, 1));
				}
			}


			if (RandF() < brutalStrikeChance)
			{
				//Dragnilar - Brutal strikes increase critical damage bonus (default is 1.25 / 25%, can be changed in gameParams.ws)				
				powerMod.valueMultiplicative = powerMod.valueMultiplicative * theGame.params.BRUTAL_STRIKE_MULTIPLIER;

				if(geralt.IsMutationActive(EPMT_Mutation11) && geralt.HasBuff(EET_WhiteWolfBuff))
				{
					whiteWolfEffect = geralt.GetWhiteWolfEffect();
					dm.GetAbilityAttributeValue('WhiteWolfMutation', 'duration_boost_per_brutal', min, max);
					whiteWolfTimeLeft = whiteWolfEffect.GetTimeLeft();
					whiteWolfEffect.SetTimeLeft(whiteWolfTimeLeft + min.valueAdditive);
					LogChannel('modDragnilarEdit', "White Wolf Mutation and brutal strike triggers white wolf duration increase - " + 
					FloatToString(whiteWolfTimeLeft + min.valueAdditive));
				}

				LogChannel('modDragnilarEdit',"Geralt deals a brutal strike. Power mod bonus is now: " + FloatToString(powerMod.valueMultiplicative));
			}
		}
		
		return powerMod;
	}
	
	
	private function GetDamageResists(dmgType : name, out resistPts : float, out resistPerc : float)
	{
		var armorReduction, armorReductionPerc, skillArmorReduction : SAbilityAttributeValue;
		var bonusReduct, bonusResist : float;
		var mutagenBuff : W3Mutagen28_Effect;
		var appliedOilName, vsMonsterResistReduction : name;
		var oils : array< W3Effect_Oil >;
		var i : int;
		var aerondight		: W3Effect_Aerondight; //Dragnilar - for Aerondight 
		var resistReduction : SAbilityAttributeValue; //Dragnilar - for Blessing Of Earth
		var isGeralt : bool; //Dragnilar - Damage adjustments
		
		
		if(attackAction && attackAction.IsActionMelee() && actorAttacker.GetInventory().IsItemFists(weaponId) && !actorVictim.UsesEssence())
			return;

		//Dragnilar - Aerondight penetrates all resistances if it is fully charged
		if(playerAttacker && actorVictim && attackAction && action.IsActionMelee() && playerAttacker.inv.UsingAerondight())
		{	
			aerondight = (W3Effect_Aerondight)playerAttacker.GetBuff(EET_Aerondight);
			if(aerondight && aerondight.IsFullyCharged())
			{
				resistPts = 0;
				resistPerc = 0;
				return;
			}
		}
		
		if(actorVictim)
		{
			if(playerVictim)
			{
				LogChannel('modDragnilarEdit', "playerVictim is hit, using Geralt resist value switch instead of normal ones.");
				isGeralt = true;
			}

			actorVictim.GetResistValue( GetResistForDamage(dmgType, action.IsDoTDamage(), isGeralt), resistPts, resistPerc );
			
			
			//Dragnilar - Protective coating increases armor instead of resist pts now
			if(playerVictim && actorAttacker && playerVictim.CanUseSkill(S_Alchemy_s05))
			{
				GetOilProtectionAgainstMonster(dmgType, bonusResist, bonusReduct);
				
				resistPts += bonusResist * (playerVictim.GetSkillLevel(S_Alchemy_s05) + playerVictim.AddSlotBonusForSkillInt(S_Alchemy_s05, 2)) *
				 playerVictim.GetLevel();
				
			}
			
			
			if(playerVictim && actorAttacker && playerVictim.HasBuff(EET_Mutagen28))
			{
				mutagenBuff = (W3Mutagen28_Effect)playerVictim.GetBuff(EET_Mutagen28);
				mutagenBuff.GetProtection(attackerMonsterCategory, dmgType, action.IsDoTDamage(), bonusResist, bonusReduct);
				resistPts += bonusReduct;
				resistPerc += bonusResist;
			}

			if(actorAttacker)
			{
				
				armorReduction = actorAttacker.GetAttributeValue('armor_reduction');
				armorReductionPerc = actorAttacker.GetAttributeValue('armor_reduction_perc');
				
				
				if(playerAttacker)
				{
					vsMonsterResistReduction = MonsterCategoryToResistReduction(victimMonsterCategory);
					oils = playerAttacker.inv.GetOilsAppliedOnItem( weaponId );
					
					if( oils.Size() > 0 )
					{
						for( i=0; i<oils.Size(); i+=1 )
						{
							appliedOilName = oils[ i ].GetOilItemName();
							
							
							if( oils[ i ].GetAmmoCurrentCount() > 0 && dm.ItemHasAttribute( appliedOilName, true, vsMonsterResistReduction ) )
							{
								armorReductionPerc.valueMultiplicative += oils[ i ].GetAmmoPercentage();
							}
						}
					}
				}
				
				
				if(playerAttacker && action.IsActionMelee() && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && playerAttacker.CanUseSkill(S_Sword_2))
					armorReduction += playerAttacker.GetSkillAttributeValue(S_Sword_2, 'armor_reduction', false, true);
				
				
				if ( playerAttacker && 
					 action.IsActionMelee() && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && 
					 ( dmgType == theGame.params.DAMAGE_NAME_PHYSICAL || 
					   dmgType == theGame.params.DAMAGE_NAME_SLASHING || 
				       dmgType == theGame.params.DAMAGE_NAME_PIERCING || 
					   dmgType == theGame.params.DAMAGE_NAME_BLUDGEONING || 
					   dmgType == theGame.params.DAMAGE_NAME_RENDING || 
					   dmgType == theGame.params.DAMAGE_NAME_SILVER
					 ) && 
					 playerAttacker.CanUseSkill(S_Sword_s08)
				   ) 
				{
					
					skillArmorReduction = playerAttacker.GetSkillAttributeValue(S_Sword_s08, 'armor_reduction_perc', false, true);
					armorReductionPerc += skillArmorReduction * playerAttacker.GetSkillLevel(S_Sword_s08);				
				}
				//Dragnilar  - Blessing Of Earth reduces enemy resistances regardless of damage type
				if(playerAttacker && playerAttacker.CanUseSkill(S_Magic_s14))
				{
						resistReduction = playerAttacker.GetSkillAttributeValue(S_Magic_s14, 'enemy_resist_reduce', false, false);
						armorReductionPerc += resistReduction * (playerAttacker.GetSkillLevel(S_Magic_s14) + 
							playerAttacker.AddSlotBonusForSkillInt(S_Magic_s14,1));
				}
				//Dragnilar  - Blessing Of Fire reduces enemy resistances regardless of damage type
				if(playerAttacker && playerAttacker.CanUseSkill(S_Magic_s09))
				{
						resistReduction = playerAttacker.GetSkillAttributeValue(S_Magic_s09, 'enemy_resist_reduce', false, false);
						armorReductionPerc += resistReduction * playerAttacker.GetSkillLevel(S_Magic_s09);
				}
				//Dragnilar  - Blessing Of Water reduces enemy resistances regardless of damage type
				if(playerAttacker && playerAttacker.CanUseSkill(S_Magic_s19))
				{
						resistReduction = playerAttacker.GetSkillAttributeValue(S_Magic_s19, 'enemy_resist_reduce', false, false);
						armorReductionPerc += resistReduction * playerAttacker.GetSkillLevel(S_Magic_s19);
				}
				//Dragnilar - Control Over The Power reduces enemy resistances if slotted
				if(playerAttacker && playerAttacker.IsSkillSlotted(S_Magic_s11))
				{
						resistReduction = playerAttacker.GetSkillAttributeValue(S_Magic_s11, 'enemy_resist_reduce', false, false);
						armorReductionPerc += resistReduction * playerAttacker.GetSkillLevel(S_Magic_s11);
				}
			}
		}
		
		
		if(!action.GetIgnoreArmor())
			resistPts += CalculateAttributeValue( actorVictim.GetTotalArmor() );
		
		
		resistPts = MaxF(0, resistPts - CalculateAttributeValue(armorReduction) );


		resistPerc -= CalculateAttributeValue(armorReductionPerc);		
		resistPerc = MaxF(0, resistPerc);
	}
		
	
	private function CalculateDamage(dmgInfo : SRawDamage, powerMod : SAbilityAttributeValue) : float
	{
		var finalDamage, finalIncomingDamage : float;
		var resistPoints, resistPercents : float;
		var ptsString, percString : string;
		var mutagen : CBaseGameplayEffect;
		var min, max: SAbilityAttributeValue;
		var encumbranceBonus : float;
		var temp : bool;
		var fistfightDamageMult : float;
		var burning : W3Effect_Burning;
	
		
		GetDamageResists(dmgInfo.dmgType, resistPoints, resistPercents);
	
		
		if( thePlayer.IsFistFightMinigameEnabled() && actorAttacker == thePlayer )
		{
			finalDamage = MaxF(0, (dmgInfo.dmgVal));
		}
		else
		{
			
			burning = (W3Effect_Burning)action.causer;
			if( burning && burning.IsSignEffect() )
			{
				if ( powerMod.valueMultiplicative > 2.5f )
				{
					powerMod.valueMultiplicative = 2.5f + LogF( (powerMod.valueMultiplicative - 2.5f) + 1 );
				}
			}
			
			finalDamage = MaxF(0, (dmgInfo.dmgVal + powerMod.valueBase) * powerMod.valueMultiplicative + powerMod.valueAdditive);
		}
			
		finalIncomingDamage = finalDamage;
		
		if(finalDamage > 0.f)
		{
			
			if (playerVictim == GetWitcherPlayer() && playerVictim.HasBuff(EET_Mutagen02))
			{
				encumbranceBonus = 1 - (GetWitcherPlayer().GetEncumbrance() / GetWitcherPlayer().GetMaxRunEncumbrance(temp));
				if (encumbranceBonus < 0)
					encumbranceBonus = 0;
				mutagen = playerVictim.GetBuff(EET_Mutagen02);
				dm.GetAbilityAttributeValue(mutagen.GetAbilityName(), 'resistGainRate', min, max);
				encumbranceBonus *= CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
				resistPercents += encumbranceBonus;
			}
			finalDamage *= 1 - resistPercents;
		}
		//Dragnilar - Armor is subtracted from damage AFTER resistances are applied
		if(finalDamage > 0.f)
		{
			//Dragnilar - Geralt's armor is always used; shock damage shouldn't be effected by armor
			if(!playerVictim && !action.IsPointResistIgnored() && !(dmgInfo.dmgType == theGame.params.DAMAGE_NAME_ELEMENTAL || dmgInfo.dmgType == theGame.params.DAMAGE_NAME_FIRE || 
			dmgInfo.dmgType == theGame.params.DAMAGE_NAME_FROST || dmgInfo.dmgType == theGame.params.DAMAGE_NAME_SHOCK ))
			{
				finalDamage = MaxF(0, finalDamage - resistPoints);
				
				if(finalDamage == 0.f)
					action.SetArmorReducedDamageToZero();
			}
		}		
		
		if(dmgInfo.dmgType == theGame.params.DAMAGE_NAME_FIRE && finalDamage > 0)
			action.SetDealtFireDamage(true);
			
		if( playerAttacker && thePlayer.IsWeaponHeld('fist') && !thePlayer.IsInFistFightMiniGame() && action.IsActionMelee() )
		{
			if(FactsQuerySum("NewGamePlus") > 0)
			{fistfightDamageMult = thePlayer.GetLevel()* 0.1;}
			else
			{fistfightDamageMult = thePlayer.GetLevel()* 0.05;}
			
			finalDamage *= ( 1+fistfightDamageMult );
		}
		
		if(playerAttacker && attackAction && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()))
			finalDamage *= 1.8333; 
			
		
		burning = (W3Effect_Burning)action.causer;
		if(actorVictim && (((W3IgniEntity)action.causer) || ((W3IgniProjectile)action.causer) || ( burning && burning.IsSignEffect())) )
		{
			min = actorVictim.GetAttributeValue('igni_damage_amplifier');
			finalDamage = finalDamage * (1 + min.valueMultiplicative) + min.valueAdditive;
		}

		//Dragnilar - Avoids weird negative damage numbers
		if(finalDamage <= 0.f)
			finalDamage = 0.f; 

		if ( theGame.CanLog() )
		{
			LogDMHits("Single hit damage: initial damage = " + NoTrailZeros(dmgInfo.dmgVal), action);
			LogDMHits("Single hit damage: attack_power = base: " + NoTrailZeros(powerMod.valueBase) + ", mult: " + NoTrailZeros(powerMod.valueMultiplicative) + ", add: " + NoTrailZeros(powerMod.valueAdditive), action );
			if(action.IsPointResistIgnored())
				LogDMHits("Single hit damage: resistance pts and armor = IGNORED", action);
			else
				LogDMHits("Single hit damage: resistance pts and armor = " + NoTrailZeros(resistPoints), action);			
			LogDMHits("Single hit damage: resistance perc = " + NoTrailZeros(resistPercents * 100), action);
			LogDMHits("Single hit damage: final damage to sustain = " + NoTrailZeros(finalDamage), action);
		}
		return finalDamage;
	}
	
	
	private function ProcessActionDamage_DealDamage()
	{
		var logStr : string;
		var hpPerc : float;
		var npcVictim : CNewNPC;
		
		logStr = "";
		if(action.processedDmg.vitalityDamage > 0)			logStr += NoTrailZeros(action.processedDmg.vitalityDamage) + " vitality, ";
		if(action.processedDmg.essenceDamage > 0)			logStr += NoTrailZeros(action.processedDmg.essenceDamage) + " essence, ";
		if(action.processedDmg.staminaDamage > 0)			logStr += NoTrailZeros(action.processedDmg.staminaDamage) + " stamina, ";
		if(action.processedDmg.moraleDamage > 0)			logStr += NoTrailZeros(action.processedDmg.moraleDamage) + " morale";
		if(logStr == "")
			logStr = "NONE";
		LogChannel('modDragnilarEdit', "Final damage to sustain is: " + logStr);
				
		
		if(actorVictim)
		{
			hpPerc = actorVictim.GetHealthPercents();
			
			
			if(actorVictim.IsAlive())
			{
				npcVictim = (CNewNPC)actorVictim;
				if(npcVictim && npcVictim.IsHorse())
				{
					npcVictim.GetHorseComponent().OnTakeDamage(action);
				}
				else
				{
					actorVictim.OnTakeDamage(action);
				}
			}
			
			if(!actorVictim.IsAlive() && hpPerc == 1)
				action.SetWasKilledBySingleHit();
		}
			
		if ( theGame.CanLog() )
		{
			LogDMHits("", action);
			LogDMHits("Target stats after damage dealt are:", action);
			if(actorVictim)
			{
				if( actorVictim.UsesVitality())						LogDMHits("Vitality = " + NoTrailZeros( actorVictim.GetStat(BCS_Vitality)), action);
				if( actorVictim.UsesEssence())						LogDMHits("Essence = "  + NoTrailZeros( actorVictim.GetStat(BCS_Essence)), action);
				if( actorVictim.GetStatMax(BCS_Stamina) > 0)		LogDMHits("Stamina = "  + NoTrailZeros( actorVictim.GetStat(BCS_Stamina, true)), action);
				if( actorVictim.GetStatMax(BCS_Morale) > 0)			LogDMHits("Morale = "   + NoTrailZeros( actorVictim.GetStat(BCS_Morale)), action);
			}
			else
			{
				LogDMHits("Undefined - victim is not a CActor and therefore has no stats", action);
			}
		}
	}
	
	
	private function ProcessActionDamage_ReduceDurability()
	{		
		var witcherPlayer : W3PlayerWitcher;
		var dbg_currDur, dbg_prevDur1, dbg_prevDur2, dbg_prevDur3, dbg_prevDur4, dbg_prevDur : float;
		var dbg_armor, dbg_pants, dbg_boots, dbg_gloves, reducedItemId, weapon : SItemUniqueId;
		var slot : EEquipmentSlots;
		var weapons : array<SItemUniqueId>;
		var armorStringName : string;
		var canLog, playerHasSword : bool;
		var i : int;
		
		canLog = theGame.CanLog();

		witcherPlayer = GetWitcherPlayer();
	
		
		if ( playerAttacker && playerAttacker.inv.IsIdValid( weaponId ) && playerAttacker.inv.HasItemDurability( weaponId ) )
		{		
			dbg_prevDur = playerAttacker.inv.GetItemDurability(weaponId);
						
			if ( playerAttacker.inv.ReduceItemDurability(weaponId) && canLog )
			{
				LogDMHits("", action);
				LogDMHits("Player's weapon durability changes from " + NoTrailZeros(dbg_prevDur) + " to " + NoTrailZeros(action.attacker.GetInventory().GetItemDurability(weaponId)), action );
			}
		}
		
		else if(playerVictim && attackAction && attackAction.IsActionMelee() && (attackAction.IsParried() || attackAction.IsCountered()) )
		{
			weapons = playerVictim.inv.GetHeldWeapons();
			playerHasSword = false;
			for(i=0; i<weapons.Size(); i+=1)
			{
				weapon = weapons[i];
				if(playerVictim.inv.IsIdValid(weapon) && (playerVictim.inv.IsItemSteelSwordUsableByPlayer(weapon) || playerVictim.inv.IsItemSilverSwordUsableByPlayer(weapon)) )
				{
					playerHasSword = true;
					break;
				}
			}
			
			if(playerHasSword)
			{
				playerVictim.inv.ReduceItemDurability(weapon);
			}
		}
		
		else if(action.victim == witcherPlayer && (action.IsActionMelee() || action.IsActionRanged()) && action.DealsAnyDamage())
		{
			
			if ( canLog )
			{
				if ( witcherPlayer.GetItemEquippedOnSlot(EES_Armor, dbg_armor) )
					dbg_prevDur1 = action.victim.GetInventory().GetItemDurability(dbg_armor);
				else
					dbg_prevDur1 = 0;
					
				if ( witcherPlayer.GetItemEquippedOnSlot(EES_Pants, dbg_pants) )
					dbg_prevDur2 = action.victim.GetInventory().GetItemDurability(dbg_pants);
				else
					dbg_prevDur2 = 0;
					
				if ( witcherPlayer.GetItemEquippedOnSlot(EES_Boots, dbg_boots) )
					dbg_prevDur3 = action.victim.GetInventory().GetItemDurability(dbg_boots);
				else
					dbg_prevDur3 = 0;
					
				if ( witcherPlayer.GetItemEquippedOnSlot(EES_Gloves, dbg_gloves) )
					dbg_prevDur4 = action.victim.GetInventory().GetItemDurability(dbg_gloves);
				else
					dbg_prevDur4 = 0;
			}
			
			slot = GetWitcherPlayer().ReduceArmorDurability();
			
			
			if( canLog )
			{
				LogDMHits("", action);
				if(slot != EES_InvalidSlot)
				{		
					switch(slot)
					{
						case EES_Armor : 
							armorStringName = "chest armor";
							reducedItemId = dbg_armor;
							dbg_prevDur = dbg_prevDur1;
							break;
						case EES_Pants : 
							armorStringName = "pants";
							reducedItemId = dbg_pants;
							dbg_prevDur = dbg_prevDur2;
							break;
						case EES_Boots :
							armorStringName = "boots";
							reducedItemId = dbg_boots;
							dbg_prevDur = dbg_prevDur3;
							break;
						case EES_Gloves :
							armorStringName = "gloves";
							reducedItemId = dbg_gloves;
							dbg_prevDur = dbg_prevDur4;
							break;
					}
					
					dbg_currDur = action.victim.GetInventory().GetItemDurability(reducedItemId);
					LogDMHits("", action);
					LogDMHits("Player's <<" + armorStringName + ">> durability changes from " + NoTrailZeros(dbg_prevDur) + " to " + NoTrailZeros(dbg_currDur), action );
				}
				else
				{
					LogDMHits("Tried to reduce player's armor durability but failed", action);
				}
			}
				
			
			if(slot != EES_InvalidSlot)
				thePlayer.inv.ReduceItemRepairObjectBonusCharge(reducedItemId);
		}
	}	
	
	
	
	
	
	
	private function ProcessActionReaction(wasFrozen : bool, wasAlive : bool)
	{
		var dismemberExplosion 			: bool;
		var damageName				 	: name;
		var damage 						: array<SRawDamage>;
		var points, percents, hp, dmg, blindChance 	: float; //Dragnilar - For Sinister
		var counterAction 				: W3DamageAction;		
		var moveTargets					: array<CActor>;
		var i 							: int;
		var canPerformFinisher			: bool;
		var weaponName					: name;
		var npcVictim					: CNewNPC;
		var toxicCloud					: W3ToxicCloud;
		var playsNonAdditiveAnim		: bool;
		var bleedCustomEffect 			: SCustomEffectParams;
		var blindCustomEffect			: SCustomEffectParams; //Dragnilar - For Sinister
		var slowCustomEffect			: SCustomEffectParams; //Dragnilar - For Sinister slot bonus
		
		if(!actorVictim)
			return;
		
		npcVictim = (CNewNPC)actorVictim;
		
		canPerformFinisher = CanPerformFinisher(actorVictim);
		
		if( actorVictim.IsAlive() && !canPerformFinisher )
		{
			
			if(!action.IsDoTDamage() && action.DealtDamage())
			{
				if ( actorAttacker && npcVictim)
				{
					npcVictim.NoticeActorInGuardArea( actorAttacker );
				}

				
				if ( !playerVictim )
					actorVictim.RemoveAllBuffsOfType(EET_Confusion);
				
				
				if(playerAttacker && action.IsActionMelee() && !playerAttacker.GetInventory().IsItemFists(weaponId) && 
					playerAttacker.IsLightAttack(attackAction.GetAttackName()) && playerAttacker.CanUseSkill(S_Sword_s05))
				{

					bleedCustomEffect.effectType = EET_Bleeding;
					bleedCustomEffect.creator = playerAttacker;
					bleedCustomEffect.sourceName = SkillEnumToName(S_Sword_s05);
					bleedCustomEffect.duration = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s05, 'duration', false, true));
					bleedCustomEffect.effectValue.valueAdditive = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s05, 'dmg_per_sec', false, true)) * playerAttacker.GetSkillLevel(S_Sword_s05);
					//Dragnilar - Razor focus now adds more bleed damage
					if(thePlayer.IsSkillSlotted(S_Sword_s20))
					{
						bleedCustomEffect.effectValue.valueAdditive += CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s20, 'dmg_per_sec', false, true)) * playerAttacker.GetSkillLevel(S_Sword_s20);
					}
					actorVictim.AddEffectCustom(bleedCustomEffect);
				}
				
				//Dragnilar - Sinister adds chance to cause blinding
				if(playerAttacker && action.IsActionMelee() && !playerAttacker.GetInventory().IsItemFists(weaponId) && 
					playerAttacker.IsLightAttack(attackAction.GetAttackName()) && playerAttacker.CanUseSkill(S_Sword_s17))
				{
					blindChance = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s17, 'blind_chance', false, true));
					if (RandF() < blindChance)
					{
						blindCustomEffect.effectType = EET_Blindness;
						blindCustomEffect.creator = playerAttacker;
						blindCustomEffect.sourceName = SkillEnumToName(S_Sword_s17);
						blindCustomEffect.duration = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s17, 'duration', false, true));
						actorVictim.AddEffectCustom(blindCustomEffect);
					}
				}

				if(playerAttacker && action.IsActionMelee() && playerAttacker.IsLightAttack(attackAction.GetAttackName()) &&
				 	playerAttacker.IsSkillSlotted(S_Sword_s17) && playerAttacker.HasBuff(EET_WhiteWolfBuff))
				{
					slowCustomEffect.effectType = EET_Slowdown;
					slowCustomEffect.creator = playerAttacker;
					slowCustomEffect.sourceName = SkillEnumToName(S_Sword_s17);
					slowCustomEffect.duration = 5;
					slowCustomEffect.effectValue.valueAdditive = 25.0f;
					actorVictim.AddEffectCustom(slowCustomEffect);
				}
			}
			
			
			if(actorVictim && wasAlive)
			{
				playsNonAdditiveAnim = actorVictim.ReactToBeingHit( action );
			}				
		}
		else
		{
			
			if( !canPerformFinisher && CanDismember( wasFrozen, dismemberExplosion, weaponName ) )
			{
				ProcessDismemberment(wasFrozen, dismemberExplosion);
				toxicCloud = (W3ToxicCloud)action.causer;
				
				if(toxicCloud && toxicCloud.HasExplodingTargetDamages())
					ProcessToxicCloudDismemberExplosion(toxicCloud.GetExplodingTargetDamages());
					
				
				if(IsRequiredAttitudeBetween(thePlayer, action.victim, true))
				{
					moveTargets = thePlayer.GetMoveTargets();
					for ( i = 0; i < moveTargets.Size(); i += 1 )
					{
						if ( moveTargets[i].IsHuman() )
							moveTargets[i].DrainMorale(20.f);
					}
				}
			}
			
			else if ( canPerformFinisher )
			{
				if ( actorVictim.IsAlive() )
					actorVictim.Kill( 'Finisher', false, thePlayer );
					
				thePlayer.AddTimer( 'DelayedFinisherInputTimer', 0.1f );
				thePlayer.SetFinisherVictim( actorVictim );
				thePlayer.CleanCombatActionBuffer();
				thePlayer.OnBlockAllCombatTickets( true );
				
				if( actorVictim.WillBeUnconscious() )
				{
					actorVictim.SetBehaviorVariable( 'prepareForUnconsciousFinisher', 1.0f );
					actorVictim.ActionRotateToAsync( thePlayer.GetWorldPosition() );
				}
				
				moveTargets = thePlayer.GetMoveTargets();
				
				for ( i = 0; i < moveTargets.Size(); i += 1 )
				{
					if ( actorVictim != moveTargets[i] )
						moveTargets[i].SignalGameplayEvent( 'InterruptChargeAttack' );
				}	
				
				if 	( 	theGame.GetInGameConfigWrapper().GetVarValue('Gameplay', 'AutomaticFinishersEnabled' ) == "true" 
					|| ( (W3PlayerWitcher)playerAttacker && GetWitcherPlayer().IsMutationActive( EPMT_Mutation3 ) ) 
					||	actorVictim.WillBeUnconscious()
					)
				{
					actorVictim.AddAbility( 'ForceFinisher', false );
				}
				
				if ( actorVictim.HasTag( 'ForceFinisher' ) )
					actorVictim.AddAbility( 'ForceFinisher', false );
				
				actorVictim.SignalGameplayEvent( 'ForceFinisher' );
			} 
			else if ( weaponName == 'fists' && npcVictim )
			{
				npcVictim.DisableAgony();	
			}
			
			thePlayer.FindMoveTarget();
		}
		
		if( attackAction.IsActionMelee() )
		{
			actorAttacker.SignalGameplayEventParamObject( 'HitActionReaction', actorVictim );
			actorVictim.OnHitActionReaction( actorAttacker, weaponName );
		}
		
		
		actorVictim.ProcessHitSound(action, playsNonAdditiveAnim || !actorVictim.IsAlive());
		
		
		
		if(action.IsCriticalHit() && action.DealtDamage() && !actorVictim.IsAlive() && actorAttacker == thePlayer )
			GCameraShake( 0.5, true, actorAttacker.GetWorldPosition(), 10 );
		
		
		if( attackAction && npcVictim && npcVictim.IsShielded( actorAttacker ) && attackAction.IsParried() && attackAction.GetAttackName() == 'attack_heavy' &&  npcVictim.GetStaminaPercents() <= 0.1 )
		{
			npcVictim.ProcessShieldDestruction();
		}
		
		if( actorVictim && action.CanPlayHitParticle() && ( action.DealsAnyDamage() || (attackAction && attackAction.IsParried()) ) )
			actorVictim.PlayHitEffect(action);
			

		if( action.victim.HasAbility('mon_nekker_base') && !actorVictim.CanPlayHitAnim() && !((CBaseGameplayEffect) action.causer) ) 
		{
			
			actorVictim.PlayEffect(theGame.params.LIGHT_HIT_FX);
			actorVictim.SoundEvent("cmb_play_hit_light");
		}
			
		
		if(actorVictim && playerAttacker && action.IsActionMelee() && thePlayer.inv.IsItemFists(weaponId) )
		{
			actorVictim.SignalGameplayEvent( 'wasHitByFists' );	
				
			if(MonsterCategoryIsMonster(victimMonsterCategory))
			{
				if(!victimCanBeHitByFists)
				{
					playerAttacker.ReactToReflectedAttack(actorVictim);
				}
				else
				{			
					actorVictim.GetResistValue(CDS_PhysicalRes, points, percents);
				
					if(percents >= theGame.params.MONSTER_RESIST_THRESHOLD_TO_REFLECT_FISTS)
						playerAttacker.ReactToReflectedAttack(actorVictim);
				}
			}			
		}
		
		
		ProcessSparksFromNoDamage();
		
		
		if(attackAction && attackAction.IsActionMelee() && actorAttacker && playerVictim && attackAction.IsCountered() && playerVictim == GetWitcherPlayer())
		{
			GetWitcherPlayer().SetRecentlyCountered(true);
		}
		
		
		
		
		if(attackAction && !action.IsDoTDamage() && (playerAttacker || playerVictim) && (attackAction.IsParried() || attackAction.IsCountered()) )
		{
			theGame.VibrateControllerLight();
		}
	}
	
	private function CanDismember( wasFrozen : bool, out dismemberExplosion : bool, out weaponName : name ) : bool
	{
		var dismember			: bool;
		var dismemberChance 	: int;
		var petard 				: W3Petard;
		var bolt 				: W3BoltProjectile;
		var arrow 				: W3ArrowProjectile;
		var inv					: CInventoryComponent;
		var toxicCloud			: W3ToxicCloud;
		var witcher				: W3PlayerWitcher;
		var i					: int;
		var secondaryWeapon		: bool;

		petard = (W3Petard)action.causer;
		bolt = (W3BoltProjectile)action.causer;
		arrow = (W3ArrowProjectile)action.causer;
		toxicCloud = (W3ToxicCloud)action.causer;
		
		dismemberExplosion = false;
		
		if(playerAttacker)
		{
			secondaryWeapon = playerAttacker.inv.ItemHasTag( weaponId, 'SecondaryWeapon' ) || playerAttacker.inv.ItemHasTag( weaponId, 'Wooden' );
		}
		
		if( actorVictim.HasAbility( 'DisableDismemberment' ) )
		{
			dismember = false;
		}
		else if( actorVictim.HasTag( 'DisableDismemberment' ) )
		{
			dismember = false;
		}
		else if (actorVictim.WillBeUnconscious())
		{
			dismember = false;		
		}
		else if (playerAttacker && secondaryWeapon )
		{
			dismember = false;
		}
		else if( arrow && !wasFrozen )
		{
			dismember = false;
		}		
		else if( actorAttacker.HasAbility( 'ForceDismemberment' ) )
		{
			dismember = true;
			dismemberExplosion = action.HasForceExplosionDismemberment();
		}
		else if(wasFrozen)
		{
			dismember = true;
			dismemberExplosion = action.HasForceExplosionDismemberment();
		}						
		else if( (petard && petard.DismembersOnKill()) || (bolt && bolt.DismembersOnKill()) )
		{
			dismember = true;
			dismemberExplosion = action.HasForceExplosionDismemberment();
		}
		else if( (W3Effect_YrdenHealthDrain)action.causer )
		{
			dismember = true;
			dismemberExplosion = true;
		}
		else if(toxicCloud && toxicCloud.HasExplodingTargetDamages())
		{
			dismember = true;
			dismemberExplosion = true;
		}
		else
		{
			inv = actorAttacker.GetInventory();
			weaponName = inv.GetItemName( weaponId );
			
			if( attackAction 
				&& !inv.IsItemSteelSwordUsableByPlayer(weaponId) 
				&& !inv.IsItemSilverSwordUsableByPlayer(weaponId) 
				&& weaponName != 'polearm'
				&& weaponName != 'fists_lightning' 
				&& weaponName != 'fists_fire' )
			{
				dismember = false;
			}			
			else if ( action.IsCriticalHit() )
			{
				dismember = true;
				dismemberExplosion = action.HasForceExplosionDismemberment();
			}
			else if ( action.HasForceExplosionDismemberment() )
			{
				dismember = true;
				dismemberExplosion = true;
			}
			else
			{
				
				dismemberChance = theGame.params.DISMEMBERMENT_ON_DEATH_CHANCE;
				
				
				if(playerAttacker && playerAttacker.forceDismember)
				{
					dismemberChance = thePlayer.forceDismemberChance;
					dismemberExplosion = thePlayer.forceDismemberExplosion;
				}
				
				
				if(attackAction)
				{
					dismemberChance += RoundMath(100 * CalculateAttributeValue(inv.GetItemAttributeValue(weaponId, 'dismember_chance')));
					dismemberExplosion = attackAction.HasForceExplosionDismemberment();
				}
					
				
				witcher = (W3PlayerWitcher)actorAttacker;
				if(witcher && witcher.CanUseSkill(S_Perk_03))
					dismemberChance += RoundMath(100 * CalculateAttributeValue(witcher.GetSkillAttributeValue(S_Perk_03, 'dismember_chance', false, true)));
				
				
				if( ( W3PlayerWitcher )playerAttacker && attackAction.IsActionMelee() && GetWitcherPlayer().IsMutationActive(EPMT_Mutation3) )	
				{
					if( thePlayer.inv.IsItemSteelSwordUsableByPlayer( weaponId ) || thePlayer.inv.IsItemSilverSwordUsableByPlayer( weaponId ) )
					{
						dismemberChance = 100;
					}
				}
				
				dismemberChance = Clamp(dismemberChance, 0, 100);
				
				if (RandRange(100) < dismemberChance)
					dismember = true;
				else
					dismember = false;
			}
		}		

		return dismember;
	}	
	
	private function CanPerformFinisher( actorVictim : CActor ) : bool
	{
		var finisherChance 			: int;
		var areEnemiesAttacking		: bool;
		var i						: int;
		var victimToPlayerVector, playerPos	: Vector;
		var item 					: SItemUniqueId;
		var moveTargets				: array<CActor>;
		var b						: bool;
		var size					: int;
		var npc						: CNewNPC;
		
		if ( (W3ReplacerCiri)thePlayer || playerVictim || thePlayer.isInFinisher )
			return false;
		
		if ( actorVictim.IsAlive() && !CanPerformFinisherOnAliveTarget(actorVictim) )
			return false;
		
		
		if ( actorVictim.WillBeUnconscious() && !theGame.GetDLCManager().IsEP2Available() )
			return false;
		
		moveTargets = thePlayer.GetMoveTargets();	
		size = moveTargets.Size();
		playerPos = thePlayer.GetWorldPosition();
	
		if ( size > 0 )
		{
			areEnemiesAttacking = false;			
			for(i=0; i<size; i+=1)
			{
				npc = (CNewNPC)moveTargets[i];
				if(npc && VecDistanceSquared(playerPos, moveTargets[i].GetWorldPosition()) < 7 && npc.IsAttacking() && npc != actorVictim )
				{
					areEnemiesAttacking = true;
					break;
				}
			}
		}
		
		victimToPlayerVector = actorVictim.GetWorldPosition() - playerPos;
		
		if ( actorVictim.IsHuman() )
		{
			npc = (CNewNPC)actorVictim;
			if ( ( size <= 1 && theGame.params.FINISHER_ON_DEATH_CHANCE > 0 ) || ( actorVictim.HasAbility('ForceFinisher') ) || ( GetWitcherPlayer().IsMutationActive(EPMT_Mutation3) ) )
			{
				finisherChance = 100;
			}
			else if ( ( actorVictim.HasBuff(EET_Confusion) || actorVictim.HasBuff(EET_AxiiGuardMe) ) )
			{
				finisherChance = 75 + ( - ( npc.currentLevel - thePlayer.GetLevel() ) );
			}
			else if ( npc.currentLevel - thePlayer.GetLevel() < -5 )
			{
				finisherChance = theGame.params.FINISHER_ON_DEATH_CHANCE + ( - ( npc.currentLevel - thePlayer.GetLevel() ) );
			}
			else
				finisherChance = theGame.params.FINISHER_ON_DEATH_CHANCE;
				
			finisherChance = Clamp(finisherChance, 0, 100);
		}
		else 
			finisherChance = 0;	
			
		if ( actorVictim.HasTag('ForceFinisher') )
		{
			finisherChance = 100;
			areEnemiesAttacking = false;
		}
			
		item = thePlayer.inv.GetItemFromSlot( 'l_weapon' );	
		
		if ( thePlayer.forceFinisher )
		{
			b = playerAttacker && attackAction && attackAction.IsActionMelee();
			b = b && ( actorVictim.IsHuman() && !actorVictim.IsWoman() );
			b =	b && !thePlayer.IsInAir();
			b =	b && ( thePlayer.IsWeaponHeld( 'steelsword') || thePlayer.IsWeaponHeld( 'silversword') );
			b = b && !thePlayer.IsSecondaryWeaponHeld();
			b =	b && !thePlayer.inv.IsIdValid( item );
			b =	b && !actorVictim.IsKnockedUnconscious();
			b =	b && !actorVictim.HasBuff( EET_Knockdown );
			b =	b && !actorVictim.HasBuff( EET_Ragdoll );
			b =	b && !actorVictim.HasBuff( EET_Frozen );
			b =	b && !actorVictim.HasAbility( 'DisableFinishers' );
			b =	b && !thePlayer.IsUsingVehicle();
			b =	b && thePlayer.IsAlive();
			b =	b && !thePlayer.IsCurrentSignChanneled();
		}
		else
		{
			b = playerAttacker && attackAction && attackAction.IsActionMelee();
			b = b && ( actorVictim.IsHuman() && !actorVictim.IsWoman() );
			b =	b && RandRange(100) < finisherChance;
			b =	b && !areEnemiesAttacking;
			b =	b && AbsF( victimToPlayerVector.Z ) < 0.4f;
			b =	b && !thePlayer.IsInAir();
			b =	b && ( thePlayer.IsWeaponHeld( 'steelsword') || thePlayer.IsWeaponHeld( 'silversword') );
			b = b && !thePlayer.IsSecondaryWeaponHeld();
			b =	b && !thePlayer.inv.IsIdValid( item );
			b =	b && !actorVictim.IsKnockedUnconscious();
			b =	b && !actorVictim.HasBuff( EET_Knockdown );
			b =	b && !actorVictim.HasBuff( EET_Ragdoll );
			b =	b && !actorVictim.HasBuff( EET_Frozen );
			b =	b && !actorVictim.HasAbility( 'DisableFinishers' );
			b =	b && actorVictim.GetAttitude( thePlayer ) == AIA_Hostile;
			b =	b && !thePlayer.IsUsingVehicle();
			b =	b && thePlayer.IsAlive();
			b =	b && !thePlayer.IsCurrentSignChanneled();
			b =	b && ( theGame.GetWorld().NavigationCircleTest( actorVictim.GetWorldPosition(), 2.f ) || actorVictim.HasTag('ForceFinisher') ) ;
			
		}

		if ( b  )
		{
			if ( !actorVictim.IsAlive() && !actorVictim.WillBeUnconscious() )
				actorVictim.AddAbility( 'DisableFinishers', false );
				
			return true;
		}
		
		return false;
	}
	
	private function CanPerformFinisherOnAliveTarget( actorVictim : CActor ) : bool
	{
		return actorVictim.IsHuman() 
		&& ( actorVictim.HasBuff(EET_Confusion) || actorVictim.HasBuff(EET_AxiiGuardMe) )
		&& actorVictim.IsVulnerable()
		&& !actorVictim.HasAbility('DisableFinisher')
		&& !actorVictim.HasAbility('InstantKillImmune');
	}
	
	
	
	
	
	
	private function ProcessActionBuffs() : bool
	{
		var inv : CInventoryComponent;
		var ret : bool;
	
		
		if(!action.victim.IsAlive() || action.WasDodged() || (attackAction && attackAction.IsActionMelee() && !attackAction.ApplyBuffsIfParried() && attackAction.CanBeParried() && attackAction.IsParried()) )
			return true;
			
		
		ApplyQuenBuffChanges();
	
		
		if( actorAttacker == thePlayer && action.IsActionWitcherSign() && action.IsCriticalHit() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation2 ) && action.HasBuff( EET_Burning ) )
		{
			action.SetBuffSourceName( 'Mutation2ExplosionValid' );
		}
	
		
		if(actorVictim && action.GetEffectsCount() > 0)
			ret = actorVictim.ApplyActionEffects(action);
		else
			ret = false;
			
		
		if(actorAttacker && actorVictim)
		{
			inv = actorAttacker.GetInventory();
			actorAttacker.ProcessOnHitEffects(actorVictim, inv.IsItemSilverSwordUsableByPlayer(weaponId), inv.IsItemSteelSwordUsableByPlayer(weaponId), action.IsActionWitcherSign() );
		}
		
		return ret;
	}
	
	
	private function ApplyQuenBuffChanges()
	{
		var npc : CNewNPC;
		var protection : bool;
		var witcher : W3PlayerWitcher;
		var quenEntity : W3QuenEntity;
		var i : int;
		var buffs : array<EEffectType>;
	
		if(!actorVictim || !actorVictim.HasAlternateQuen())
			return;
		
		npc = (CNewNPC)actorVictim;
		if(npc)
		{
			if(!action.DealsAnyDamage())
				protection = true;
		}
		else
		{
			witcher = (W3PlayerWitcher)actorVictim;
			if(witcher)
			{
				quenEntity = (W3QuenEntity)witcher.GetCurrentSignEntity();
				if(quenEntity.GetBlockedAllDamage())
				{
					protection = true;
				}
			}
		}
		
		if(!protection)
			return;
			
		action.GetEffectTypes(buffs);
		for(i=buffs.Size()-1; i>=0; i -=1)
		{
			if(buffs[i] == EET_KnockdownTypeApplicator || IsKnockdownEffectType(buffs[i]))
				continue;
				
			action.RemoveBuff(i);
		}
	}
	
	
	
	
	private function ProcessDismemberment(wasFrozen : bool, dismemberExplosion : bool )
	{
		var hitDirection		: Vector;
		var usedWound			: name;
		var npcVictim			: CNewNPC;
		var wounds				: array< name >;
		var i					: int;
		var petard 				: W3Petard;
		var bolt 				: W3BoltProjectile;		
		var forcedRagdoll		: bool;
		var isExplosion			: bool;
		var dismembermentComp 	: CDismembermentComponent;
		var specialWounds		: array< name >;
		var useHitDirection		: bool;
		var fxMask				: EDismembermentEffectTypeFlags;
		var template			: CEntityTemplate;
		var ent					: CEntity;
		var signType			: ESignType;
		
		if(!actorVictim)
			return;
			
		dismembermentComp = (CDismembermentComponent)(actorVictim.GetComponentByClassName( 'CDismembermentComponent' ));
		if(!dismembermentComp)
			return;
			
		if(wasFrozen)
		{
			ProcessFrostDismemberment();
			return;
		}
		
		forcedRagdoll = false;
		
		
		petard = (W3Petard)action.causer;
		bolt = (W3BoltProjectile)action.causer;
		
		if( dismemberExplosion || (attackAction && ( attackAction.GetAttackName() == 'attack_explosion' || attackAction.HasForceExplosionDismemberment() ))
			|| (petard && petard.DismembersOnKill()) || (bolt && bolt.DismembersOnKill()) )
		{
			isExplosion = true;
		}
		else
		{
			isExplosion = false;
		}
		
		
		if(playerAttacker && thePlayer.forceDismember && IsNameValid(thePlayer.forceDismemberName))
		{
			usedWound = thePlayer.forceDismemberName;
		}
		else
		{	
			
			if(isExplosion)
			{
				dismembermentComp.GetWoundsNames( wounds, WTF_Explosion );	

				
				if( action.IsMutation2PotentialKill() )
				{
					
					for( i=wounds.Size()-1; i>=0; i-=1 )
					{
						if( !StrContains( wounds[ i ], "_ep2" ) )
						{
							wounds.EraseFast( i );
						}
					}
					
					signType = action.GetSignType();
					if( signType == ST_Aard )
					{
						fxMask = DETF_Aaard;
					}
					else if( signType == ST_Igni )
					{
						fxMask = DETF_Igni;
					}
					else if( signType == ST_Yrden )
					{
						fxMask = DETF_Yrden;
					}
					else if( signType == ST_Quen )
					{
						fxMask = DETF_Quen;
					}
				}
				else
				{
					fxMask = 0;
				}
				
				if ( wounds.Size() > 0 )
					usedWound = wounds[ RandRange( wounds.Size() ) ];
					
				if ( usedWound )
					StopVO( actorVictim ); 
			}
			else if(attackAction || action.GetBuffSourceName() == "riderHit")
			{
				if  ( attackAction.GetAttackTypeName() == 'sword_s2' || thePlayer.isInFinisher )
					useHitDirection = true;
				
				if ( useHitDirection ) 
				{
					hitDirection = actorAttacker.GetSwordTipMovementFromAnimation( attackAction.GetAttackAnimName(), attackAction.GetHitTime(), 0.1, attackAction.GetWeaponEntity() );
					usedWound = actorVictim.GetNearestWoundForBone( attackAction.GetHitBoneIndex(), hitDirection, WTF_Cut );
				}
				else
				{			
					
					dismembermentComp.GetWoundsNames( wounds );
					
					
					if(wounds.Size() > 0)
					{
						dismembermentComp.GetWoundsNames( specialWounds, WTF_Explosion );
						for ( i = 0; i < specialWounds.Size(); i += 1 )
						{
							wounds.Remove( specialWounds[i] );
						}
						
						if(wounds.Size() > 0)
						{
							
							dismembermentComp.GetWoundsNames( specialWounds, WTF_Frost );
							for ( i = 0; i < specialWounds.Size(); i += 1 )
							{
								wounds.Remove( specialWounds[i] );
							}
							
							
							if ( wounds.Size() > 0 )
								usedWound = wounds[ RandRange( wounds.Size() ) ];
						}
					}
				}
			}
		}
		
		if ( usedWound )
		{
			npcVictim = (CNewNPC)action.victim;
			if(npcVictim)
				npcVictim.DisableAgony();			
			
			actorVictim.SetDismembermentInfo( usedWound, actorVictim.GetWorldPosition() - actorAttacker.GetWorldPosition(), forcedRagdoll, fxMask );
			actorVictim.AddTimer( 'DelayedDismemberTimer', 0.05f );
			actorVictim.SetBehaviorVariable( 'dismemberAnim', 1.0 );
			
			
			if ( usedWound == 'explode_02' || usedWound == 'explode2' || usedWound == 'explode_02_ep2' || usedWound == 'explode2_ep2')
			{
				ProcessDismembermentDeathAnim( usedWound, true, EFDT_LegLeft );
				actorVictim.SetKinematic( false );
				
			}
			else
			{
				ProcessDismembermentDeathAnim( usedWound, false );
			}
			
			
			if( usedWound == 'explode_01_ep2' || usedWound == 'explode1_ep2' || usedWound == 'explode_02_ep2' || usedWound == 'explode2_ep2' )
			{
				template = (CEntityTemplate) LoadResource( "explosion_dismember_force" );
				ent = theGame.CreateEntity( template, npcVictim.GetWorldPosition(), , , , true );
				ent.DestroyAfter( 5.f );
			}
			
			DropEquipmentFromDismember( usedWound, true, true );
			
			if( attackAction && actorAttacker == thePlayer )			
				GCameraShake( 0.5, true, actorAttacker.GetWorldPosition(), 10);
				
			if(playerAttacker)
				theGame.VibrateControllerHard();	
				
			
			if( dismemberExplosion && (W3AardProjectile)action.causer )
			{
				npcVictim.AddTimer( 'AardDismemberForce', 0.00001f );
			}
		}
		else
		{
			LogChannel( 'Dismemberment', "ERROR: No wound found to dismember on entity but entity supports dismemberment!!!" );
		}
	}
	
	function ApplyForce()
	{
		var size, i : int;
		var victim : CNewNPC;
		var fromPos, toPos : Vector;
		var comps : array<CComponent>;
		var impulse : Vector;
		
		victim = (CNewNPC)action.victim;
		toPos = victim.GetWorldPosition();
		toPos.Z += 1.0f;
		fromPos = toPos;
		fromPos.Z -= 2.0f;
		impulse = VecNormalize( toPos - fromPos.Z ) * 10;
		
		comps = victim.GetComponentsByClassName('CComponent');
		victim.GetVisualDebug().AddArrow( 'applyForce', fromPos, toPos, 1, 0.2f, 0.2f, true, Color( 0,0,255 ), true, 5.0f );
		size = comps.Size();
		for( i = 0; i < size; i += 1 )
		{
			comps[i].ApplyLocalImpulseToPhysicalObject( impulse );
		}
	}
	
	private function ProcessFrostDismemberment()
	{
		var dismembermentComp 	: CDismembermentComponent;
		var wounds				: array< name >;
		var wound				: name;
		var i, fxMask			: int;
		var npcVictim			: CNewNPC;
		
		dismembermentComp = (CDismembermentComponent)(actorVictim.GetComponentByClassName( 'CDismembermentComponent' ));
		if(!dismembermentComp)
			return;
		
		dismembermentComp.GetWoundsNames( wounds, WTF_Frost );
		
		
		
		if( theGame.GetDLCManager().IsEP2Enabled() )
		{
			//Dragnilar - All references to the old freezing cold have been changed except this one.
			fxMask = DETF_Mutation6; 
			
			
			for( i=wounds.Size()-1; i>=0; i-=1 )
			{
				if( !StrContains( wounds[ i ], "_ep2" ) )
				{
					wounds.EraseFast( i );
				}
			}
		}
		else
		{
			fxMask = 0;
		}
		
		if ( wounds.Size() > 0 )
		{
			wound = wounds[ RandRange( wounds.Size() ) ];
		}
		else
		{
			return;
		}
		
		npcVictim = (CNewNPC)action.victim;
		if(npcVictim)
		{
			npcVictim.DisableAgony();
			StopVO( npcVictim );
		}
		
		actorVictim.SetDismembermentInfo( wound, actorVictim.GetWorldPosition() - actorAttacker.GetWorldPosition(), true, fxMask );
		actorVictim.AddTimer( 'DelayedDismemberTimer', 0.05f );
		if( wound == 'explode_02' || wound == 'explode2' || wound == 'explode_02_ep2' || wound == 'explode2_ep2' )
		{
			ProcessDismembermentDeathAnim( wound, true, EFDT_LegLeft );
			npcVictim.SetKinematic(false);
		}
		else
		{
			ProcessDismembermentDeathAnim( wound, false );
		}
		DropEquipmentFromDismember( wound, true, true );
		
		if( attackAction )			
			GCameraShake( 0.5, true, actorAttacker.GetWorldPosition(), 10);
			
		if(playerAttacker)
			theGame.VibrateControllerHard();	
	}
	
	
	private function ProcessDismembermentDeathAnim( nearestWound : name, forceDeathType : bool, optional deathType : EFinisherDeathType )
	{
		var dropCurveName : name;
		
		if ( forceDeathType )
		{
			if ( deathType == EFDT_Head )
				StopVO( actorVictim );
				
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)deathType );
			
			return;
		}
		
		dropCurveName = ( (CDismembermentComponent)(actorVictim.GetComponentByClassName( 'CDismembermentComponent' )) ).GetMainCurveName( nearestWound );
		
		if ( dropCurveName == 'head' )
		{
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_Head );
			StopVO( actorVictim );
		}
		else if ( dropCurveName == 'torso_left' || dropCurveName == 'torso_right' || dropCurveName == 'torso' )
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_Torso );
		else if ( dropCurveName == 'arm_right' )
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_ArmRight );
		else if ( dropCurveName == 'arm_left' )
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_ArmLeft );
		else if ( dropCurveName == 'leg_left' )
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_LegLeft );
		else if ( dropCurveName == 'leg_right' )
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_LegRight );
		else 
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_None );
	}
	
	private function StopVO( actor : CActor )
	{
		actor.SoundEvent( "grunt_vo_death_stop", 'head' );
	}

	private function DropEquipmentFromDismember( nearestWound : name, optional dropLeft, dropRight : bool )
	{
		var dropCurveName : name;
		
		if( actorVictim.HasAbility( 'DontDropWeaponsOnDismemberment' ) )
		{
			return;
		}
		
		dropCurveName = ( (CDismembermentComponent)(actorVictim.GetComponentByClassName( 'CDismembermentComponent' )) ).GetMainCurveName( nearestWound );
		
		if ( ChangeHeldItemAppearance() )
		{
			actorVictim.SignalGameplayEvent('DropWeaponsInDeathTask');
			return;
		}
		
		if ( dropLeft || dropRight )
		{
			
			if ( dropLeft )
				actorVictim.DropItemFromSlot( 'l_weapon', true );
			
			if ( dropRight )
				actorVictim.DropItemFromSlot( 'r_weapon', true );			
			
			return;
		}
		
		if ( dropCurveName == 'arm_right' )
			actorVictim.DropItemFromSlot( 'r_weapon', true );
		else if ( dropCurveName == 'arm_left' )
			actorVictim.DropItemFromSlot( 'l_weapon', true );
		else if ( dropCurveName == 'torso_left' || dropCurveName == 'torso_right' || dropCurveName == 'torso' )
		{
			actorVictim.DropItemFromSlot( 'l_weapon', true );
			actorVictim.DropItemFromSlot( 'r_weapon', true );
		}			
		else if ( dropCurveName == 'head' || dropCurveName == 'leg_left' || dropCurveName == 'leg_right' )
		{
			if(  RandRange(100) < 50 )
				actorVictim.DropItemFromSlot( 'l_weapon', true );
			
			if(  RandRange(100) < 50 )
				actorVictim.DropItemFromSlot( 'r_weapon', true );
		} 
	}
	
	function ChangeHeldItemAppearance() : bool
	{
		var inv : CInventoryComponent;
		var weapon : SItemUniqueId;
		
		inv = actorVictim.GetInventory();
		
		weapon = inv.GetItemFromSlot('l_weapon');
		
		if ( inv.IsIdValid( weapon ) )
		{
			if ( inv.ItemHasTag(weapon,'bow') || inv.ItemHasTag(weapon,'crossbow') )
				inv.GetItemEntityUnsafe(weapon).ApplyAppearance("rigid");
			return true;
		}
		
		weapon = inv.GetItemFromSlot('r_weapon');
		
		if ( inv.IsIdValid( weapon ) )
		{
			if ( inv.ItemHasTag(weapon,'bow') || inv.ItemHasTag(weapon,'crossbow') )
				inv.GetItemEntityUnsafe(weapon).ApplyAppearance("rigid");
			return true;
		}
	
		return false;
	}
	
	
	private function GetOilProtectionAgainstMonster(dmgType : name, out resist : float, out reduct : float)
	{
		var i : int;
		var heldWeapons : array< SItemUniqueId >;
		var weapon : SItemUniqueId;
		
		resist = 0;
		reduct = 0;
		
		
		heldWeapons = thePlayer.inv.GetHeldWeapons();
		
		
		for( i=0; i<heldWeapons.Size(); i+=1 )
		{
			if( !thePlayer.inv.IsItemFists( heldWeapons[ i ] ) )
			{
				weapon = heldWeapons[ i ];
				break;
			}
		}
		
		
		if( !thePlayer.inv.IsIdValid( weapon ) )
		{
			return;
		}
	
		
		if( !thePlayer.inv.ItemHasActiveOilApplied( weapon, attackerMonsterCategory ) )
		{
			return;
		}
		
		resist = CalculateAttributeValue( thePlayer.GetSkillAttributeValue( S_Alchemy_s05, 'defence_bonus', false, true ) );		
	}
	
	
	private function ProcessToxicCloudDismemberExplosion(damages : array<SRawDamage>)
	{
		var act : W3DamageAction;
		var i, j : int;
		var ents : array<CGameplayEntity>;
		var damage : float; //Dragnilar
		
		
		if(damages.Size() == 0)
		{
			LogAssert(false, "W3DamageManagerProcessor.ProcessToxicCloudDismemberExplosion: trying to process but no damages are passed! Aborting!");
			return;
		}		
		
		
		FindGameplayEntitiesInSphere(ents, action.victim.GetWorldPosition(), 3, 1000, , FLAG_OnlyAliveActors);
		
		
		for(i=0; i<ents.Size(); i+=1)
		{
			act = new W3DamageAction in this;
			act.Initialize(action.attacker, ents[i], action.causer, 'Dragons_Dream_3', EHRT_Heavy, CPS_Undefined, false, false, false, true);
			
			for(j=0; j<damages.Size(); j+=1)
			{	//Dragnilar - Readability
				damage = damages[j].dmgVal;
				act.AddDamage(damages[j].dmgType, damage );
			}
			
			theGame.damageMgr.ProcessAction(act);
			delete act;
		}
	}
	
	
	private final function ProcessSparksFromNoDamage()
	{
		var sparksEntity, weaponEntity : CEntity;
		var weaponTipPosition : Vector;
		var weaponSlotMatrix : Matrix;
		
		
		if(!playerAttacker || !attackAction || !attackAction.IsActionMelee() || attackAction.DealsAnyDamage())
			return;
		
		
		if( ( !attackAction.DidArmorReduceDamageToZero() && !actorVictim.IsVampire() && ( attackAction.IsParried() || attackAction.IsCountered() ) ) 
			|| ( ( attackAction.IsParried() || attackAction.IsCountered() ) && !actorVictim.IsHuman() && !actorVictim.IsVampire() )
			|| actorVictim.IsCurrentlyDodging() )
			return;
		
		
		if(actorVictim.HasTag('NoSparksOnArmorDmgReduced'))
			return;
		
		
		if (!actorVictim.GetGameplayVisibility())
			return;
		
		
		weaponEntity = playerAttacker.inv.GetItemEntityUnsafe(weaponId);
		weaponEntity.CalcEntitySlotMatrix( 'blood_fx_point', weaponSlotMatrix );
		weaponTipPosition = MatrixGetTranslation( weaponSlotMatrix );
		
		
		sparksEntity = theGame.CreateEntity( (CEntityTemplate)LoadResource( 'sword_colision_fx' ), weaponTipPosition );
		sparksEntity.PlayEffect('sparks');
	}
	
	private function ProcessPreHitModifications()
	{
		var fireDamage, totalDmg, maxHealth, currHealth : float;
		var attribute, min, max : SAbilityAttributeValue;
		var infusion : ESignType;
		var hack : array< SIgniEffects >;
		var dmgValTemp : float;
		var igni : W3IgniEntity;
		var quen : W3QuenEntity;
		var fireBonus, forceBonus, shockBonus, frostBonus : float;

		if( actorVictim.HasAbility( 'HitWindowOpened' ) && !action.IsDoTDamage() )
		{
			if( actorVictim.HasTag( 'fairytale_witch' ) )
			{
				
				
				
				
				
				
					((CNewNPC)actorVictim).SetBehaviorVariable( 'shouldBreakFlightLoop', 1.0 );
				
			}
			else
			{
				quen = (W3QuenEntity)action.causer; 
			
				if( !quen )
				{
					if( actorVictim.HasTag( 'dettlaff_vampire' ) )
					{
						actorVictim.StopEffect( 'shadowdash' );
					}
					
					action.ClearDamage();
					if( action.IsActionMelee() )
					{
						actorVictim.PlayEffect( 'special_attack_break' );
					}
					actorVictim.SetBehaviorVariable( 'repelType', 0 );
					
					actorVictim.AddEffectDefault( EET_CounterStrikeHit, thePlayer ); 
					action.RemoveBuffsByType( EET_KnockdownTypeApplicator );
				}
			}
			
			((CNewNPC)actorVictim).SetHitWindowOpened( false );
		}
		
		//Igni Mastery adds fire damage per level
		if(playerAttacker && attackAction && GetWitcherPlayer().CanUseSkill(S_Magic_s07) && thePlayer.GetSkillLevel(S_Magic_s07) >= 3)
		{
			fireBonus = (CalculateAttributeValue( thePlayer.GetSkillAttributeValue(S_Magic_s07, 'fire_dmg_bonus_per_level', false, true) ) *
				thePlayer.GetLevel() * (thePlayer.GetSkillLevel(S_Magic_s07)) + thePlayer.AddSlotBonusForSkillInt(S_Magic_s07,1));
			action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, fireBonus);
		}
		//Aard Mastery adds force damage per level
		if(playerAttacker && attackAction && GetWitcherPlayer().CanUseSkill(S_Magic_s12) && thePlayer.GetSkillLevel(S_Magic_s12) >= 3)
		{
			forceBonus = (CalculateAttributeValue( thePlayer.GetSkillAttributeValue(S_Magic_s12, 'force_damage_bonus_per_level', false, true) ) * 
				thePlayer.GetLevel() * thePlayer.GetSkillLevel(S_Magic_s12) + thePlayer.AddSlotBonusForSkillInt(S_Magic_s12,1));
			action.AddDamage(theGame.params.DAMAGE_NAME_FORCE, forceBonus);
		}

		//Axii Mastery adds frost damage per level
		if(playerAttacker && attackAction && GetWitcherPlayer().CanUseSkill(S_Magic_s18))
		{
			frostBonus = (CalculateAttributeValue( thePlayer.GetSkillAttributeValue(S_Magic_s18, 'frost_damage_bonus_per_level', false, true) ) * 
				thePlayer.GetLevel() * thePlayer.GetSkillLevel(S_Magic_s18) + thePlayer.AddSlotBonusForSkillInt(S_Magic_s18,1));
			action.AddDamage(theGame.params.DAMAGE_NAME_FROST, frostBonus);
		}

		//Yrden Mastery adds shock damage per level
		if(playerAttacker && attackAction && GetWitcherPlayer().CanUseSkill(S_Magic_s16))
		{
			shockBonus = (CalculateAttributeValue( thePlayer.GetSkillAttributeValue(S_Magic_s16, 'shock_dmg_bonus_per_level', false, true) ) * 
				thePlayer.GetLevel() * thePlayer.GetSkillLevel(S_Magic_s16) + thePlayer.AddSlotBonusForSkillInt(S_Magic_s16,1));
			action.AddDamage(theGame.params.DAMAGE_NAME_SHOCK, shockBonus);
		}
		
		if(playerAttacker && attackAction && attackAction.IsActionMelee() && (W3PlayerWitcher)thePlayer && thePlayer.HasAbility('Runeword 1 _Stats', true))
		{
			infusion = GetWitcherPlayer().GetRunewordInfusionType();
			
			switch(infusion)
			{
				case ST_Aard:
					action.AddEffectInfo(EET_KnockdownTypeApplicator);
					action.SetProcessBuffsIfNoDamage(true);
					attackAction.SetApplyBuffsIfParried(true);
					actorVictim.CreateFXEntityAtPelvis( 'runeword_1_aard', false );
					break;
				case ST_Axii:
					action.AddEffectInfo(EET_Confusion);
					action.SetProcessBuffsIfNoDamage(true);
					attackAction.SetApplyBuffsIfParried(true);
					break;
				case ST_Igni:
					
					totalDmg = action.GetDamageValueTotal();
					attribute = thePlayer.GetAttributeValue('runeword1_fire_dmg');
					fireDamage = totalDmg * attribute.valueMultiplicative;
					action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, fireDamage);
					action.SetCanPlayHitParticle(false);					
					action.victim.AddTimer('Runeword1DisableFireFX', 1.f);
					action.SetHitReactionType(EHRT_Heavy);	
					action.victim.PlayEffect('critical_burning');
					break;
				case ST_Yrden:
					attribute = thePlayer.GetAttributeValue('runeword1_yrden_duration');
					action.AddEffectInfo(EET_Slowdown, attribute.valueAdditive);
					action.SetProcessBuffsIfNoDamage(true);
					attackAction.SetApplyBuffsIfParried(true);
					break;
				default:		
					break;
			}
		}

		if( playerAttacker && actorVictim && (W3PlayerWitcher)playerAttacker && GetWitcherPlayer().IsMutationActive( EPMT_Mutation9 ) && (W3BoltProjectile)action.causer )
		{
			maxHealth = actorVictim.GetMaxHealth();
			currHealth = actorVictim.GetHealth();
			
			
			if( AbsF( maxHealth - currHealth ) < 1.f )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation9', 'health_reduction', min, max);
				actorVictim.ForceSetStat( actorVictim.GetUsedHealthType(), maxHealth * ( 1 - min.valueMultiplicative ) );
			}
			
			
			action.AddEffectInfo( EET_KnockdownTypeApplicator, 0.1f, , , , 1.f );
		}
	}
}

exec function ForceDismember( b: bool, optional chance : int, optional n : name, optional e : bool )
{
	var temp : CR4Player;
	
	temp = thePlayer;
	temp.forceDismember = b;
	temp.forceDismemberName = n;
	temp.forceDismemberChance = chance;
	temp.forceDismemberExplosion = e;
} 

exec function ForceFinisher( b: bool, optional n : name, optional rightStance : bool )
{
	var temp : CR4Player;
	
	temp = thePlayer;
	temp.forcedStance = rightStance;
	temp.forceFinisher = b;
	temp.forceFinisherAnimName = n;
} 
