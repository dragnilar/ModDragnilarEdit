class W3Effect_WhiteWolfBuff extends CBaseGameplayEffect
{
	default effectType = EET_WhiteWolfBuff;
	default isPositive = true;
	var effectEntity : CEntity;
		
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
		target.AddAbilityMultiple(abilityName, RoundMath(GetWitcherPlayer().GetMaxHealth() * 0.05));
		FactsAdd("whitewolfactive");
		target.PlayEffect('yrden_slowdown');
		target.PlayEffect('yrden_slowdown');
		target.PlayEffect('ability_gryphon_active');
		target.PlayEffect('mutation_7_baff');
		effectEntity = theGame.CreateEntity((CEntityTemplate)LoadResource("dlc\dragnilaredit\poisonyrden\whitewolftrigger.w2ent", true), target.GetWorldPosition());
		effectEntity.PlayEffect('yrden_slowdown');
		effectEntity.CreateAttachment(target);
	}

	event OnEffectRemoved()
	{	
		super.OnEffectRemoved();
		FactsRemove("whitewolfactive");
		target.StopEffect('ability_gryphon_active');
		target.StopEffect('mutation_7_baff');
		target.StopEffect('yrden_slowdown');
		effectEntity.StopAllEffects();
		effectEntity.DestroyAfter(2);
		target.RemoveAbilityAll(abilityName);
		if (thePlayer.IsSkillSlotted(S_Sword_s19))
			thePlayer.DrainFocus(thePlayer.GetStat(BCS_Focus));
		thePlayer.AddEffectDefault( EET_WhiteWolfDebuff, NULL, "White Wolf Debuff", false );
	}
	
}