class W3Effect_WhiteWolfBuff extends CBaseGameplayEffect
{
	default effectType = EET_WhiteWolfBuff;
	default isPositive = true;

	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		
		super.CalculateDuration( setInitialDuration );
		
		initialDuration = duration;
	}

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{	
		super.OnEffectAdded( customParams );	
		target.SetImmortalityMode( AIM_Immortal, AIC_WhiteWolf );
	}

	public function IncreaseDuration(durationBoost : float)
	{
		var whiteWolfDuration : float;
		whiteWolfDuration = GetTimeLeft();
		if (whiteWolfDuration > 0)
		{
			whiteWolfDuration += durationBoost;
			SetTimeLeft(whiteWolfDuration);
			LogChannel('modDragnilarEdit', "White Wolf duration increased to: " + FloatToString(whiteWolfDuration));
		}
	}

	event OnEffectRemoved()
	{
			
		target.SetImmortalityMode( AIM_None, AIC_WhiteWolf );
        target.RemoveAbilityAll(abilityName);
		super.OnEffectRemoved();
		thePlayer.AddEffectDefault( EET_WhiteWolfDebuff, NULL, "White Wolf Debuff", false );
	}
	
}