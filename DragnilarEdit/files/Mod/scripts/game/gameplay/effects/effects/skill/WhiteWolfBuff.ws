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
		if (duration > 0)
		{
			duration += durationBoost;
			LogChannel('modDragnilarEdit', "White Wolf duration increased to: " + FloatToString(duration));
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