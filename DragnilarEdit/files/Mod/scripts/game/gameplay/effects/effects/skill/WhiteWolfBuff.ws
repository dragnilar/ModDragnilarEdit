class W3Effect_WhiteWolfBuff extends CBaseGameplayEffect
{
	default effectType = EET_WhiteWolfBuff;
	default isPositive = true;

	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		var min, max : SAbilityAttributeValue;

		super.CalculateDuration( setInitialDuration );

		if (GetWitcherPlayer().IsSetBonusActive( EISB_Wolf_2 ))
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('SetBonusAbilityWolf_2', 'duration', min, max);
			duration = initialDuration * min.valueMultiplicative;
		}
		
		initialDuration = duration;
	}

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{	
		super.OnEffectAdded( customParams );	
		target.SetImmortalityMode( AIM_Immortal, AIC_WhiteWolf );
	}

	event OnEffectRemoved()
	{
			
		target.SetImmortalityMode( AIM_Immortal, AIC_WhiteWolf );
        target.RemoveAbilityAll(abilityName);
		super.OnEffectRemoved();
		thePlayer.AddEffectDefault( EET_WhiteWolfDebuff, NULL, "White Wolf Debuff", false );
	}
	
}