class W3Effect_WhiteWolfBuff extends CBaseGameplayEffect
{
	default effectType = EET_WhiteWolfBuff;
	default isPositive = true;

	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		var durationBonus : float;
		var min, max : SAbilityAttributeValue;
		var witcher : W3PlayerWitcher;
		
		super.CalculateDuration( setInitialDuration );
		
		if (thePlayer.GetSkillLevel(S_Sword_s19) > 1)
		{
			durationBonus = ((float)(thePlayer.GetSkillLevel(S_Sword_s19) * 5) - 5);
		}

		witcher = GetWitcherPlayer();
		if(witcher.IsSetBonusActive(EISB_Wolf_1))
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('SetBonusAbilityWolf_1', 'white_wolf_duration_increase', min, max);
			durationBonus += min.valueAdditive * witcher.GetSetPartsEquipped( EIST_Wolf );
		}

		if (durationBonus > 0)
			duration += durationBonus;
	}

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{	
		super.OnEffectAdded( customParams );
		FactsAdd("whitewolfactive");	
		target.PlayEffect('ability_gryphon_active');
		target.PlayEffect('yrden_slowdown');
		target.PlayEffect('yrden_slowdown');
		en = theGame.CreateEntity( (CEntityTemplate)LoadResource("dlc\adtomes\poisonyrden\energyorig.w2ent",true), target.GetWorldPosition() );
		en.PlayEffect('yrden_slowdown');
		en.CreateAttachment(  target );
	}

	event OnEffectRemoved()
	{	
		super.OnEffectRemoved();
		FactsRemove("whitewolfactive");
		target.StopEffect('ability_gryphon_active');
		target.StopEffect('yrden_slowdown');
		en.StopAllEffects();
		en.DestroyAfter(2);
		target.RemoveAbilityAll(abilityName);
		thePlayer.AddEffectDefault( EET_WhiteWolfDebuff, NULL, "White Wolf Debuff", false );
	}
	
}