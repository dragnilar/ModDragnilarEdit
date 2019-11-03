class W3Effect_WhiteWolfBuff extends CBaseGameplayEffect
{
	default effectType = EET_WhiteWolfBuff;
	default isPositive = true;

	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		var durationBonus : float;
		super.CalculateDuration( setInitialDuration );
		durationBonus = ((float)thePlayer.GetSkillLevel(S_Sword_s19) * 10) - 10;
		initialDuration = duration + durationBonus;
	}

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{	
		super.OnEffectAdded( customParams );	
		target.SetImmortalityMode( AIM_Immortal, AIC_WhiteWolf );
		target.PlayEffect('mutation_7_baff');
	}

	public function IncreaseDuration(durationBoost : float)
	{
		var whiteWolfDuration : float;
		whiteWolfDuration = GetTimeLeft();
		if (whiteWolfDuration > 0)
		{	
			LogChannel('modDragnilarEdit', "White Wolf current duration: " + FloatToString(whiteWolfDuration));
			durationBoost = durationBoost * = GetWitcherPlayer().GetSetPartsEquipped(EIST_Wolf);
			LogChannel('modDragnilarEdit', "Duration boost for White Wolf is: " + FloatToString(durationBoost));
			whiteWolfDuration += durationBoost;
			SetTimeLeft(whiteWolfDuration);
			LogChannel('modDragnilarEdit', "White Wolf duration increased to: " + FloatToString(whiteWolfDuration));
		}
	}

	event OnEffectRemoved()
	{
			
		target.SetImmortalityMode( AIM_None, AIC_WhiteWolf );
        target.RemoveAbilityAll(abilityName);
		target.StopEffect( 'mutation_7_baff' );
		super.OnEffectRemoved();
		thePlayer.AddEffectDefault( EET_WhiteWolfDebuff, NULL, "White Wolf Debuff", false );
	}
	
}