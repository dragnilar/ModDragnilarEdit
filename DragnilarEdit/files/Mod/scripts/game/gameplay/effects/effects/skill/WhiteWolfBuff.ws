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
			durationBonus = ((float)(thePlayer.GetSkillLevel(S_Sword_s19) * 5) - 5);
		}

		if(GetWitcherPlayer().IsSetBonusActive(EISB_Wolf_1))
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('SetBonusAbilityWolf_1', 'white_wolf_duration_increase', min, max);
			durationBonus += min.valueAdditive * GetWitcherPlayer().GetSetPartsEquipped( EIST_Wolf );
		}

		if (durationBonus > 0)
			duration += durationBonus;

		AddTimer('WhiteWolfImmortalTimer', 5.0, false);
		LogChannel('modDragnilarEdit', "White Wolf: Starting Immortal Effect for 5 seconds");
		target.SetImmortalityMode( AIM_Immortal, AIC_WhiteWolf );
	}

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{	
		super.OnEffectAdded( customParams );	
		target.PlayEffect('mutation_7_baff');
		//Dragnilar - TODO - Remove all debuffs (i.e. DOTs)
	}

	event OnEffectRemoved()
	{
		target.SetImmortalityMode( AIM_None, AIC_WhiteWolf );	
        target.RemoveAbilityAll(abilityName);
		target.StopEffect( 'mutation_7_baff' );
		super.OnEffectRemoved();
		thePlayer.AddEffectDefault( EET_WhiteWolfDebuff, NULL, "White Wolf Debuff", false );
	}

	timer function WhiteWolfImmortalTimer( deltaTime : float, id : int )
	{
		LogChannel('modDragnilarEdit', "White Wolf: Ending Immortal Effect");
		target.SetImmortalityMode( AIM_None, AIC_WhiteWolf );
		RemoveTimer('WhiteWolfImmortalTimer');
	}
	
}