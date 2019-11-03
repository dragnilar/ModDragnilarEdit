class W3Effect_WhiteWolfBuff extends CBaseGameplayEffect
{
	default effectType = EET_WhiteWolfBuff;
	default isPositive = true;

	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		var durationBonus : float;
		var min, max : SAbilityAttributeValue;
		
		super.CalculateDuration( setInitialDuration );
		
		if (thePlayer.GetSkillLevel(S_Sword_s19) > 1)
		{
			durationBonus = (float)(thePlayer.GetSkillLevel(S_Sword_s19) * 10);
		}

		LogChannel('modDragnilarEdit',"White wolf Duration Bonus: " + FloatToString(durationBonus));

		if(GetWitcherPlayer().IsSetBonusActive(EISB_Wolf_1))
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('SetBonusAbilityWolf_1', 'white_wolf_duration_increase', min, max);
			durationBonus += min.valueAdditive * GetWitcherPlayer().GetSetPartsEquipped( EIST_Wolf );
			LogChannel('modDragnilarEdit',"White wolf Duration Bonus After Wolf Set: " + FloatToString(durationBonus));

		}

		initialDuration = duration + durationBonus;
	}

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{	
		super.OnEffectAdded( customParams );	
		target.SetImmortalityMode( AIM_Immortal, AIC_WhiteWolf );
		target.PlayEffect('mutation_7_baff');
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