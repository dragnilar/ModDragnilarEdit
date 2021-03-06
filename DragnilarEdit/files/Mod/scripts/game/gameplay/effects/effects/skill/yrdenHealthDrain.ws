/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Effect_YrdenHealthDrain extends W3DamageOverTimeEffect
{
	private var hitFxDelay : float;
	
	default effectType = EET_YrdenHealthDrain;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		hitFxDelay = 0.9 + RandF() / 5;	
		
		
		SetEffectValue();
	}
	
	
	protected function SetEffectValue()
	{
		var sp : SAbilityAttributeValue;
		var damageMultiplier : SAbilityAttributeValue;
		var spellBonus : float;
		
		
		
		if(thePlayer.CanUseSkill(S_Magic_s10))
		{
			//Dragnilar - Increased by player level and spell power
			sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
			effectValue = (thePlayer.GetSkillAttributeValue(S_Magic_s10, 'direct_damage_per_sec', false, true) * thePlayer.GetSkillLevel(S_Magic_s10));
			effectValue.valueAdditive *= thePlayer.GetLevel();
			effectValue.valueMultiplicative = sp.valueMultiplicative;
		}
		if(thePlayer.CanUseSkill(S_Magic_s16))
		{
			damageMultiplier = (thePlayer.GetSkillAttributeValue(S_Magic_s16, 'yrden_damage_multiplier', false, true) *
			 (thePlayer.GetSkillLevel(S_Magic_s16) + thePlayer.AddSlotBonusForSkillInt(S_Magic_s16, 1)));
			effectValue.valueMultiplicative += damageMultiplier.valueMultiplicative;
		}
	}
	
	event OnUpdate(dt : float)
	{
		super.OnUpdate(dt);
		
		hitFxDelay -= dt;
		if(hitFxDelay <= 0)
		{
			hitFxDelay = 0.9 + RandF() / 5;	
			target.PlayEffect('yrden_shock');
		}
	}
}