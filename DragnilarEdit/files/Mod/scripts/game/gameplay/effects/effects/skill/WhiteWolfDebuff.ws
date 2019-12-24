class W3Effect_WhiteWolfDebuff extends CBaseGameplayEffect
{
	default effectType = EET_WhiteWolfDebuff;
	default isNeutral = true;
	
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		var min, max : SAbilityAttributeValue;

		super.CalculateDuration( setInitialDuration );

		
		if( FactsQuerySum( "debug_whitewolf_no_cooldown" ) )
		{
			duration = 0.00001f;
		}
		else 
		{
			duration = initialDuration;
			if (GetWitcherPlayer().IsSetBonusActive( EISB_Wolf_2 ))
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('SetBonusAbilityWolf_2', 'duration', min, max);
				duration = duration - min.valueAdditive;
			}

			if(GetWitcherPlayer().IsMutationActive(EPMT_Mutation11))
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('WhiteWolfMutation', 'debuff_reduce', min, max);
				duration = duration - min.valueAdditive;
			}

		}
	}
	
	event OnEffectRemoved()
	{
		theGame.MutationHUDFeedback( MFT_PlayHide );
		super.OnEffectRemoved();
	}
}	