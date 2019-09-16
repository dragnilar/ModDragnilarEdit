class W3Effect_WhiteWolfDebuff extends CBaseGameplayEffect
{
	default effectType = EET_WhiteWolfDebuff;
	default isNeutral = true;
	
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		super.CalculateDuration( setInitialDuration );

		
		if( FactsQuerySum( "debug_whitewolf_no_cooldown" ) )
		{
			duration = 0.00001f;
			initialDuration = duration;
		}
	}
	
	event OnEffectRemoved()
	{
		theGame.MutationHUDFeedback( MFT_PlayHide );
		super.OnEffectRemoved();
	}
}	