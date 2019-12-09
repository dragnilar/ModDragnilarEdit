class W3Effect_QuenFireShield extends CBaseGameplayEffect
{	var fire,fire2: CEntity;
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	default effectType = EET_QuenFireShield;
	default attributeName = 'QuenFireShield';
		
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);	
		FactsAdd("QuenFireShield");
		fire = theGame.CreateEntity( (CEntityTemplate)LoadResource("dlc\adtomes\poisonyrden\energyfire.w2ent",true), target.GetWorldPosition() );
		fire2 = theGame.CreateEntity( (CEntityTemplate)LoadResource("dlc\adtomes\poisonyrden\energyfire.w2ent",true), target.GetWorldPosition() );
		fire.PlayEffect('yrden_slowdown');
		fire.PlayEffect('yrden_slowdown');
		fire.CreateAttachment( target, 'quen_sphere' );
		fire2.PlayEffect('yrden_slowdown');
		fire2.CreateAttachment( target );
		target.PlayEffect('critical_burning_cs');
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		FactsRemove("QuenFireShield");
		fire.StopAllEffects();
		fire.DestroyAfter(3);
		fire2.StopAllEffects();
		fire2.DestroyAfter(3);
		target.StopEffect( 'critical_burning_cs' );
	}
}