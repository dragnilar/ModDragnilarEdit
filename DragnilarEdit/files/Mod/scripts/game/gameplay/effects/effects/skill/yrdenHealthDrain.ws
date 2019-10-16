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
		var spellFactor : SAbilityAttributeValue;
		var spellBonus : float;

		//Dragnilar - Added spell factor and moved to s10
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
		//Dragnilar - Spell factor provides a percentage of sign intensity as bonus damage (0.15 at level 3, so you would get 15 damage per every 100 sign intensity...
		spellFactor = (thePlayer.GetSkillAttributeValue(S_Magic_s10, 'spell_power_factor', false, true) * thePlayer.GetSkillLevel(S_Magic_s10)) * sp.valueMultiplicative;

		effectValue = (thePlayer.GetSkillAttributeValue(S_Magic_s10, 'direct_damage_per_sec', false, true) * thePlayer.GetSkillLevel(S_Magic_s10)) + spellFactor;

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