/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3Effect_KnockdownTypeApplicator extends W3ApplicatorEffect
{
	private saved var customEffectValue : SAbilityAttributeValue;		
	private saved var customDuration : float;							
	private saved var customAbilityName : name;							

	default effectType = EET_KnockdownTypeApplicator;
	default isNegative = true;
	default isPositive = false;
	

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var aardPower	: float;
		var tags : array<name>;
		var i : int;
		var appliedType : EEffectType;
		var null : SAbilityAttributeValue;
		var npc : CNewNPC;
		var params : SCustomEffectParams;
		var min, max : SAbilityAttributeValue;
		var aardSweepIsSlotted : bool; //Dragnilar - Check for aard sweep being slotted
		
		if(isOnPlayer)
		{
			thePlayer.OnRangedForceHolster( true, true, false );
		}
		
		
		if(effectValue.valueMultiplicative + effectValue.valueAdditive > 0)		
			aardPower = effectValue.valueMultiplicative * ( 1 - resistance ) / (1 + effectValue.valueAdditive/100);
		else
			aardPower = creatorPowerStat.valueMultiplicative * ( 1 - resistance ) / (1 + creatorPowerStat.valueAdditive/100);
		
		
		npc = (CNewNPC)target;
		//Dragnilar - If Aard Sweep is slotted and its skill level is 3 (max), then always apply Heavy Knockdown. Otherwise maximizes the benefit of Aard Sweep.
		aardSweepIsSlotted = thePlayer.IsSkillSlotted(S_Magic_s01);

		if(aardSweepIsSlotted && thePlayer.GetSkillLevel(S_Magic_s01) > 2)
			appliedType = EET_HeavyKnockdown;
		else
		{
			if(npc && npc.HasShieldedAbility() )
			{
				if ( npc.IsShielded(GetCreator()) )
				{
					if (aardSweepIsSlotted || aardPower >= 1.2 )
						appliedType = EET_LongStagger;
					else
						appliedType = EET_Stagger;
				}
				else
				{
					appliedType = CalculateKnockDownEffect(aardPower, aardSweepIsSlotted);
				}
			}
			else if ( target.HasAbility( 'mon_type_huge' ) )
			{
				if (aardSweepIsSlotted || aardPower >= 1.2 )
					appliedType = EET_LongStagger;
				else
					appliedType = EET_Stagger;
			}
			else if ( target.HasAbility( 'WeakToAard' ) )
			{
				if (aardSweepIsSlotted || aardPower >= 1.2)
				{
					appliedType = EET_HeavyKnockdown;
				}
				else
				{
					appliedType = EET_Knockdown;
				}
			}
			else
			{
				appliedType = CalculateKnockDownEffect(aardPower, aardSweepIsSlotted);
			}
		}


		appliedType = ModifyHitSeverityBuff(target, appliedType);
		
		
		params.effectType = appliedType;
		params.creator = GetCreator();
		params.sourceName = sourceName;
		params.isSignEffect = isSignEffect;
		params.customPowerStatValue = creatorPowerStat;
		params.customAbilityName = customAbilityName;
		params.duration = customDuration;
		params.effectValue = customEffectValue;	
		
		target.AddEffectCustom(params);
		
		
		
		isActive = true;
		duration = 0;
	}

	protected function CalculateKnockDownEffect(aardPower : float, optional aardSweepIsSlotted : bool) : EEffectType
	{
		if( aardPower >= 1.2 )
		{
			return EET_HeavyKnockdown;
		}
		else if(aardSweepIsSlotted || aardPower >= 0.95 )
		{
			return EET_Knockdown;
		}
		else if( aardPower >= 0.75 )
		{
			return EET_LongStagger;
		}
		else
		{
			return EET_Knockdown;
		}
	}
			
	public function Init(params : SEffectInitInfo)
	{
		customDuration = params.duration;
		customEffectValue = params.customEffectValue;
		customAbilityName = params.customAbilityName;
		
		super.Init(params);
	}
}