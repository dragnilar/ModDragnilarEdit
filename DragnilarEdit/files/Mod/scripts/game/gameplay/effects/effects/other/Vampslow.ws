class W3Effect_Vampslow extends CBaseGameplayEffect
{
	//Dragnilar - Taken from the mod Magic Spells, all credit goes to menschfeind13 
	private saved var slowdown : int;
	var slowfact: float;
	var axiiSP : SAbilityAttributeValue;
	
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	default effectType = EET_Vampslow;
	default attributeName = 'Vampslow';
		
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);	
		
		if(FactsQuerySum( "aardslow" ) > 0)
		{
			slowdown = target.SetAnimationSpeedMultiplier( 0.05 );
			target.PlayEffect('axii_slowdown');
		}
		else
		{
			axiiSP=GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_5);
			slowfact = 0.70-((axiiSP.valueMultiplicative*0.1));
			slowfact = ClampF(slowfact, 0.1, 0.8);
			slowdown = target.SetAnimationSpeedMultiplier( slowfact );	
		}
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		target.ResetAnimationSpeedMultiplier(slowdown);
		target.StopEffect('axii_slowdown');
	}
}