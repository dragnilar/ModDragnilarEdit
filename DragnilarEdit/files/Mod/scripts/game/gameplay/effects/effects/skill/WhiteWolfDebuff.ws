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
			initialDuration = duration;
		}
		else if (GetWitcherPlayer().IsSetBonusActive( EISB_Wolf_2 ))
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('SetBonusAbilityWolf_2', 'duration', min, max);
			duration = initialDuration - min.valueAdditive;
		}
	}
	
	event OnEffectRemoved()
	{
		theGame.MutationHUDFeedback( MFT_PlayHide );
		super.OnEffectRemoved();
	}
}	