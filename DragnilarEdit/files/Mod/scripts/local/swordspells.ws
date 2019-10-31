statemachine class Swordspells extends CR4Player
{
	var steelid,silverid, swordid												: SItemUniqueId;
	var effect,sword_for_effect, targettest, axii_wave,effect_entity 			: CEntity;
	var i,o																		: int; 
	var n, lenght 																: Float; 
	var weaponSlotMatrix 														: Matrix;
	var weaponTipPosition 														: Vector;
	var	sgntype 																: ESignType;
	var aard_wave,aard_wave2 													: W3TraceGroundProjectile;
	var actor 																	: CActor; 
	var shootposition 															: Vector;
	var entities 																: array<CGameplayEntity>;
	var entity 																	: CGameplayEntity;
	var victims 																: array<CActor>;
	var victim																	: CNewNPC;
	var damageaction 															: W3DamageAction;
	var spellpower 																: SAbilityAttributeValue;
	var damage 																	: Float;
	var fire_trail 																: W3FireballProjectile;
	var blowpos 																: Vector; 
	var rot 																	: EulerAngles; 
	var icefleff,burn,slow 														: SCustomEffectParams;
	var gheff																	: CEntity;
	var mutDmgMod, mutMin, mutMax 												: SAbilityAttributeValue;
	var movementAdjustor 														: CMovementAdjustor;
	var ticket 			 														: SMovementAdjustmentRequestTicket;	
	var targetent																	: CEntity;
	
	public function Rotatation()
	{
		if ( FactsQuerySum("rotate_fireball")<=0 )
		{
			movementAdjustor = thePlayer.GetMovingAgentComponent().GetMovementAdjustor();
			ticket = movementAdjustor.CreateNewRequest( 'vortex');
			movementAdjustor.MaxRotationAdjustmentSpeed( ticket, 500 );
			movementAdjustor.MaxLocationAdjustmentSpeed( ticket, 500 );
			movementAdjustor.RotateTo( ticket, VecHeading( theCamera.GetCameraDirection()));
		}
		else
		{
			actor = (CActor)thePlayer.slideTarget;	
			if(actor && actor.GetAttitude( thePlayer ) == AIA_Hostile)
			{		
				movementAdjustor = thePlayer.GetMovingAgentComponent().GetMovementAdjustor();
				ticket = movementAdjustor.CreateNewRequest( 'vortex');
				movementAdjustor.MaxRotationAdjustmentSpeed( ticket, 500 );
				movementAdjustor.MaxLocationAdjustmentSpeed( ticket, 500 );
				movementAdjustor.RotateTowards( ticket, actor );
			}
		}
	}
	
	public function Interrupt()
	{
		if(FactsQuerySum("swordspells")>0)
		{
			thePlayer.ActionPlaySlotAnimationAsync('PLAYER_SLOT', '');
			FactsAdd("Interrupt",,1);
			FactsRemove("swordspells");
			FactsRemove("rotate!");
		}
	}
	
	public function Unblock_hack()
	{
		thePlayer.UnblockAction(EIAB_SwordAttack,		'swordspells_hack');
		thePlayer.UnblockAction(EIAB_LightAttacks,		'swordspells_hack');
		thePlayer.UnblockAction(EIAB_HeavyAttacks,		'swordspells_hack');
		thePlayer.UnblockAction(EIAB_SpecialAttackLight,'swordspells_hack');
		thePlayer.UnblockAction(EIAB_SpecialAttackHeavy,'swordspells_hack');
	}
	
	public function Yrden_sword_sound_heavy()
	{	
		thePlayer.SoundEvent("magic_sorceress_vfx_lightning_bolt");
	}
	
	public function Yrden_sword_sound()
	{	
		if(FactsQuerySum("Interrupt")<=0)
		{
			thePlayer.SoundEvent("sign_yrden_warmup");
		}
	}
		
	public function Yrden_sword()
	{	
		FactsRemove("rotate!");
		if(FactsQuerySum("Interrupt")<=0)
		{
		
			if( GetWitcherPlayer().IsMutationActive( EPMT_Mutation1 ) )
			{
				swordid = thePlayer.inv.GetCurrentlyHeldSword();
					
				if( thePlayer.inv.GetItemCategory(swordid) == 'steelsword' )
				{
					mutDmgMod += thePlayer.inv.GetItemAttributeValue(swordid, theGame.params.DAMAGE_NAME_SLASHING);
				}
				else if( thePlayer.inv.GetItemCategory(swordid) == 'silversword' )
				{
					mutDmgMod += thePlayer.inv.GetItemAttributeValue(swordid, theGame.params.DAMAGE_NAME_SILVER);
				}
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation1', 'dmg_bonus_factor', mutMin, mutMax);
					
				mutDmgMod.valueBase *= CalculateAttributeValue(mutMin);
			}
		
			GetWitcherPlayer().DrainStamina( ESAT_FixedValue, 90 );
			
			shootposition = thePlayer.GetWorldPosition()+thePlayer.GetHeadingVector()*1.5;
			
			FindGameplayEntitiesInCone(entities, shootposition, VecHeading(thePlayer.GetHeadingVector()), 60, 11, 100);
			for( i = 0; i < entities.Size(); i += 1 )   
			{
				entity = entities[i]; 
				entity.OnAardHit( NULL );
			}	
				
			aard_wave = (W3TraceGroundProjectile)theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\giant_shockwave_proj.w2ent",true ), 
			shootposition, thePlayer.GetWorldRotation());
			aard_wave.PlayEffect('yrden');
			aard_wave.DestroyAfter(7);
			
			victims = thePlayer.GetNPCsAndPlayersInCone(11, VecHeading(thePlayer.GetHeadingVector()), 60, 20, , FLAG_Attitude_Hostile + FLAG_OnlyAliveActors);
			
			for( o = 0; o < victims.Size(); o += 1 )
			{
			
				spellpower = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
				spellpower += GetWitcherPlayer().GetSkillAttributeValue(S_Magic_3, 'trap_duration', false, true);
				spellpower.valueMultiplicative -= 1;
			
				victim = (CNewNPC)victims[o];
				slow.effectType = EET_Slowdown;
				slow.creator = thePlayer;
				slow.sourceName = thePlayer.GetName();
				slow.duration = CalculateAttributeValue((spellpower), 2)*0.4;
				
				slow.customPowerStatValue = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
				slow.effectValue.valueAdditive = 0.01 + (0.99 - 0.01) * slow.customPowerStatValue.valueMultiplicative / 5;
				slow.effectValue.valueAdditive = ClampF( slow.effectValue.valueAdditive, 0.01, 0.99 );				
				victim.AddEffectCustom(slow);
				
				damageaction =  new W3DamageAction in this;
				damageaction.Initialize(thePlayer,victim,this,thePlayer.GetName()+"_sign",EHRT_Light,CPS_Undefined,false, false, true, false );
				
				spellpower = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
				
				damage = CalculateAttributeValue( GetWitcherPlayer().GetSkillAttributeValue( S_Magic_s03, theGame.params.DAMAGE_NAME_SHOCK, false, true ) )
					* GetWitcherPlayer().GetSkillLevel(S_Magic_s03)*0.7;
				damage += mutDmgMod.valueBase;
				damage *= spellpower.valueMultiplicative;			
				
				if(	!victim.IsHuman() && !victim.IsAnimal()	)
					{	damage *= 2;	}
				damageaction.AddDamage( theGame.params.DAMAGE_NAME_DIRECT, damage);
				damageaction.SetHitReactionType(EHRT_Light);
				damageaction.SetHitAnimationPlayType(EAHA_ForceYes);
				damageaction.SetProcessBuffsIfNoDamage(true);
				theGame.damageMgr.ProcessAction( damageaction );
				delete damageaction;
				if(damage>0)
				{	victim.PlayEffect('yrden_shock');  }
			}
		}
	}
	
	public function Quen_sword()
	{	
		FactsRemove("rotate!");
		if(FactsQuerySum("Interrupt")<=0)
		{
		
			GetWitcherPlayer().DrainStamina( ESAT_FixedValue, 90 );
			
			shootposition = thePlayer.GetWorldPosition()+thePlayer.GetHeadingVector()*1.3;
			
			rot = thePlayer.GetWorldRotation();
			rot.Yaw += 90.f;
			blowpos = shootposition;
			blowpos.Z += 1.5;
			axii_wave = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource("dlc\adtomes\swordeffects\igni_blackaxii.w2ent" ,true ), blowpos, rot );
			axii_wave.PlayEffect('cone_poison');
			axii_wave.DestroyAfter(10);
			thePlayer.SoundEvent('sign_igni_charge_begin');
				
			victims = thePlayer.GetNPCsAndPlayersInCone(5, VecHeading(thePlayer.GetHeadingVector()), 80, 20, , FLAG_Attitude_Hostile + FLAG_OnlyAliveActors);
			
			for( o = 0; o < victims.Size(); o += 1 )
			{
				victim = (CNewNPC)victims[o];
				damageaction =  new W3DamageAction in this;
				damageaction.Initialize(thePlayer,victim,this,thePlayer.GetName()+"_sign",EHRT_Heavy,CPS_Undefined,false, false, true, false );
				spellpower = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_4);
				damage = thePlayer.GetLevel()*17;
				damage += damage*((spellpower.valueMultiplicative-1)*0.4);
				if(	!victim.IsHuman() && !victim.IsAnimal()	)
					{	damage *= 2;	}
				damageaction.AddDamage( theGame.params.DAMAGE_NAME_FIRE, damage*0.65);
				damageaction.AddDamage( theGame.params.DAMAGE_NAME_POISON, damage*0.65);
				damageaction.SetHitReactionType(EHRT_Heavy);
				damageaction.SetHitAnimationPlayType(EAHA_ForceYes);
				damageaction.SetProcessBuffsIfNoDamage(true);
				damageaction.AddEffectInfo( EET_Stagger );
				theGame.damageMgr.ProcessAction( damageaction );
				gheff = victim.CreateFXEntityAtPelvis( 'mutation2addtomes', true );
				gheff.PlayEffect( 'critical_quenaddtomes' );
				delete damageaction;
			
				if(RandF() <= (spellpower.valueMultiplicative)*0.2)
				{
					icefleff.effectType = EET_Poison;
					icefleff.creator = thePlayer;
					icefleff.sourceName = thePlayer.GetName();
					icefleff.duration = spellpower.valueMultiplicative*3;
					victim.AddEffectCustom(icefleff);
				}
			}
		}
	}
	
	public function Axii_sword()
	{	
		FactsRemove("rotate!");
		if(FactsQuerySum("Interrupt")<=0)
		{
		
			GetWitcherPlayer().DrainStamina( ESAT_FixedValue, 90 );
			
			shootposition = thePlayer.GetWorldPosition()+thePlayer.GetHeadingVector()*1.3;
			
			rot = thePlayer.GetWorldRotation();
			rot.Yaw += 90.f;
			blowpos = shootposition;
			blowpos.Z += 1.5;
			axii_wave = (CEntity)theGame.CreateEntity( (CEntityTemplate)LoadResource("dlc\adtomes\poisonyrden\igni_blackaxii.w2ent" ,true ), blowpos, rot );
			axii_wave.PlayEffect('cone_frost');
			axii_wave.DestroyAfter(10);
			thePlayer.SoundEvent('sign_igni_charge_begin');
			thePlayer.SoundEvent('ep2_mutations_06_frosty_aard');
			
			
			victims = thePlayer.GetNPCsAndPlayersInCone(5, VecHeading(thePlayer.GetHeadingVector()), 80, 20, , FLAG_Attitude_Hostile + FLAG_OnlyAliveActors);
			
			for( o = 0; o < victims.Size(); o += 1 )
			{
				victim = (CNewNPC)victims[o];
				damageaction =  new W3DamageAction in this;
				damageaction.Initialize(thePlayer,victim,this,thePlayer.GetName()+"_sign",EHRT_Heavy,CPS_Undefined,false, false, true, false );
				spellpower = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_5);
				damage = thePlayer.GetLevel()*17;
				damage += damage*((spellpower.valueMultiplicative-1)*0.4);
				if(	!victim.IsHuman() && !victim.IsAnimal()	)
					{	damage *= 2;	}
				damageaction.AddDamage( theGame.params.DAMAGE_NAME_FROST, damage);
				damageaction.SetHitReactionType(EHRT_Heavy);
				damageaction.SetHitAnimationPlayType(EAHA_ForceYes);
				damageaction.SetProcessBuffsIfNoDamage(true);
				damageaction.AddEffectInfo( EET_Stagger );
				theGame.damageMgr.ProcessAction( damageaction );
				gheff = victim.CreateFXEntityAtPelvis( 'mutation2addtomes', true );
				gheff.PlayEffect( 'critical_axiiaddtomes' );
				delete damageaction;
			
				if( RandF() <= (spellpower.valueMultiplicative-1)*0.2)
				{
					icefleff.effectType = EET_Frozen;
				}
				else
				{
					icefleff.effectType = EET_SlowdownFrost;
				}
				icefleff.creator = thePlayer;
				icefleff.sourceName = thePlayer.GetName();
				icefleff.duration = spellpower.valueMultiplicative*3;
				victim.AddEffectCustom(icefleff);
				
			}
			
			FindGameplayEntitiesInCone(entities, shootposition, VecHeading(thePlayer.GetHeadingVector()), 80, 5, 100);
			for( i = 0; i < entities.Size(); i += 1 )   
			{
				entity = entities[i]; 
				entity.OnAardHit( NULL );
			}	
			
		}
	}
	
	public function Igni_sword()
	{	
		FactsRemove("rotate!");
		if(FactsQuerySum("Interrupt")<=0)
		{
		
			GetWitcherPlayer().DrainStamina( ESAT_FixedValue, 90 );
			
			//actor = (CActor)thePlayer.slideTarget;	
			if(actor && actor.GetAttitude( thePlayer ) == AIA_Hostile)
			{
				thePlayer.SoundEvent("fx_fire_geralt_fire_hit");
			
				/*
				swordid = thePlayer.GetInventory().GetCurrentlyHeldSword();
				sword_for_effect = thePlayer.GetInventory().GetItemEntityUnsafe(swordid);
				sword_for_effect.CalcEntitySlotMatrix( 'blood_fx_point', weaponSlotMatrix );
				weaponTipPosition = MatrixGetTranslation( weaponSlotMatrix );
				
				shootposition = thePlayer.GetWorldPosition()+thePlayer.GetHeadingVector()*2.5;
				shootposition.Z+=0.8;
				shootposition = weaponTipPosition+thePlayer.GetHeadingVector()*1.5;
				*/
				
				shootposition = thePlayer.GetWorldPosition() - VecFromHeading( AngleNormalize180( actor.GetHeading()
														  - NodeToNodeAngleDistance( thePlayer, actor)))*2 ;
				shootposition.Z+=0.8;
				
				targettest = theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\effects_for_sword.w2ent",true ),
				shootposition );
				targettest.PlayEffect('burn_spot');
				targettest.DestroyAfter(2);

				fire_trail = (W3FireballProjectile)theGame.CreateEntity( (CEntityTemplate)LoadResource( 'sorceress_fireball' ), 
				shootposition);
				fire_trail.ShootProjectileAtNode(0, 15, actor);
				fire_trail.PlayEffect( fire_trail.initFxName );
				
				FactsAdd("fireball");
			}
		}
	}
	
	public function Aard_sword()
	{	
		FactsRemove("rotate!");
		if(FactsQuerySum("Interrupt")<=0)
		{
		
			if( GetWitcherPlayer().IsMutationActive( EPMT_Mutation1 ) )
			{
				swordid = thePlayer.inv.GetCurrentlyHeldSword();
					
				if( thePlayer.inv.GetItemCategory(swordid) == 'steelsword' )
				{
					mutDmgMod += thePlayer.inv.GetItemAttributeValue(swordid, theGame.params.DAMAGE_NAME_SLASHING);
				}
				else if( thePlayer.inv.GetItemCategory(swordid) == 'silversword' )
				{
					mutDmgMod += thePlayer.inv.GetItemAttributeValue(swordid, theGame.params.DAMAGE_NAME_SILVER);
				}
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation1', 'dmg_bonus_factor', mutMin, mutMax);
					
				mutDmgMod.valueBase *= CalculateAttributeValue(mutMin);
			}
		
			GetWitcherPlayer().DrainStamina( ESAT_FixedValue, 90 );
			
			victims = thePlayer.GetNPCsAndPlayersInCone(11, VecHeading(thePlayer.GetHeadingVector()), 60, 20, , FLAG_Attitude_Hostile + FLAG_OnlyAliveActors);
			
			for( o = 0; o < victims.Size(); o += 1 )
			{
				victim = (CNewNPC)victims[o];
				damageaction =  new W3DamageAction in this;
				damageaction.Initialize(thePlayer,victim,this,thePlayer.GetName()+"_sign",EHRT_Heavy,CPS_Undefined,false, false, true, false );
				
				spellpower = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_1);
				
				damage = GetWitcherPlayer().GetSkillLevel(S_Magic_s06) * 
				CalculateAttributeValue( GetWitcherPlayer().GetSkillAttributeValue( S_Magic_s06, theGame.params.DAMAGE_NAME_FORCE, false, true ) );
				damage += mutDmgMod.valueBase;
				damage *= spellpower.valueMultiplicative;
				
				if(	!victim.IsHuman() && !victim.IsAnimal()	)
					{	damage *= 2;	}
				damageaction.AddDamage( theGame.params.DAMAGE_NAME_FORCE, damage);
				damageaction.SetHitReactionType(EHRT_Heavy);
				damageaction.SetHitAnimationPlayType(EAHA_ForceYes);
				damageaction.SetProcessBuffsIfNoDamage(true);
				if( RandF() <= 0.15)
				{	damageaction.AddEffectInfo( EET_KnockdownTypeApplicator,1 );	}
				else
				{	damageaction.AddEffectInfo( EET_Stagger );	}
				theGame.damageMgr.ProcessAction( damageaction );
				delete damageaction;
			}
			
			shootposition = thePlayer.GetWorldPosition()+thePlayer.GetHeadingVector()*1.3;
			
			FindGameplayEntitiesInCone(entities, shootposition, VecHeading(thePlayer.GetHeadingVector()), 60, 11, 100);
			for( i = 0; i < entities.Size(); i += 1 )   
			{
				entity = entities[i]; 
				entity.OnAardHit( NULL );
			}	
				
			aard_wave = (W3TraceGroundProjectile)theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\giant_shockwave_proj.w2ent",true ), 
			shootposition, thePlayer.GetWorldRotation());
			aard_wave.PlayEffect('fire_line');
			aard_wave.DestroyAfter(7);
			thePlayer.SoundEvent("magic_man_push");
		}
	}
	
	public function Spells()
	{	
		
		FactsAdd("rotate!",,1);
		
		thePlayer.BlockAction(EIAB_SwordAttack,			'swordspells_hack');
		thePlayer.BlockAction(EIAB_LightAttacks,		'swordspells_hack');
		thePlayer.BlockAction(EIAB_HeavyAttacks,		'swordspells_hack');
		thePlayer.BlockAction(EIAB_SpecialAttackLight,	'swordspells_hack');
		thePlayer.BlockAction(EIAB_SpecialAttackHeavy,	'swordspells_hack');
		
		
		thePlayer.AddTimer('unblock_hack',1.3,false,,,false);
		FactsAdd("swordspells",,2);
	
		thePlayer.GetInventory().GetItemEquippedOnSlot(EES_SteelSword, steelid);
		thePlayer.GetInventory().GetItemEquippedOnSlot(EES_SilverSword, silverid);
		
		if ( thePlayer.GetInventory().IsItemHeld(steelid) || thePlayer.GetInventory().IsItemHeld(silverid) )
		{
			
			swordid = thePlayer.GetInventory().GetCurrentlyHeldSword();
			sword_for_effect = thePlayer.GetInventory().GetItemEntityUnsafe(swordid);
			sword_for_effect.CalcEntitySlotMatrix( 'blood_fx_point', weaponSlotMatrix );
			weaponTipPosition = MatrixGetTranslation( weaponSlotMatrix );
			lenght = AbsF(VecDistance(weaponTipPosition, sword_for_effect.GetWorldPosition()));
			
			sgntype = GetWitcherPlayer().GetEquippedSign();
			switch(sgntype)
			{
				case ST_Igni:
					FactsAdd("rotate_fireball",,1);
					thePlayer.GetInventory().GetItemEntityUnsafe( GetInventory().GetItemFromSlot('r_weapon') ).PlayEffectSingle( 'runeword1_fire_trail' );
					
					thePlayer.AddTimer('igni_sword',0.74,false,,,false);
					
					if( RandF() <= 0.5)
					{	thePlayer.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'man_geralt_sword_attack_strong_8_lp_70ms',0.2,0.8);	}
					else
					{	thePlayer.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'man_geralt_sword_attack_strong_4_lp_70ms',0.2,0.8);	}
					
					for( n=0.3; n<=lenght; n+=0.2 )
					{	
						effect = theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\effects_for_sword.w2ent",true ), thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
						effect.CreateAttachment( sword_for_effect,,Vector( 0, 0, 1*n ));
						effect.PlayEffect('igni');
						effect.StopAllEffectsAfter(0.7);
						effect.DestroyAfter(2);
					}
					
					thePlayer.SoundEvent("fx_rune_activate_igni");thePlayer.SoundEvent("fx_rune_activate_igni");thePlayer.SoundEvent("fx_rune_activate_igni");
						
					break;
			
				case ST_Axii:
					
					theSound.SoundLoadBank( "ep2_mutations_06.bnk", true );
					
					thePlayer.AddTimer('axii_sword',0.7,false,,,false);
					
					if( RandF() <= 0.5)
					{	thePlayer.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'man_geralt_sword_attack_strong_6_rp_70ms',0.2,0.8);	}
					else
					{	thePlayer.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'man_geralt_sword_attack_strong_8_rp_70ms',0.2,0.8);	}
					
					for( n=0.2; n<=lenght; n+=0.1 )
					{	
						effect = theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\effects_for_sword.w2ent",true ), thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
						effect.CreateAttachment( sword_for_effect,,Vector( 0, 0, 1*n ));
						effect.PlayEffect('axii');effect.PlayEffect('axii1');
						effect.StopAllEffectsAfter(0.6);
						effect.DestroyAfter(3);
					}
					
					thePlayer.SoundEvent("fx_rune_activate_axii");thePlayer.SoundEvent("fx_rune_activate_axii");thePlayer.SoundEvent("fx_rune_activate_axii");
					
					break;
				
				case ST_Aard:
				
					theSound.SoundLoadBank( "magic_man_mage.bnk", true );

					thePlayer.AddTimer('aard_sword',0.75,false,,,false);
					
					if( RandF() <= 0.5)
					{	thePlayer.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'man_geralt_sword_attack_strong_9_lp_70ms',0.2,0.8);	}
					else
					{	thePlayer.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'man_geralt_sword_attack_strong_10_lp_70ms',0.2,0.8);	}
					
					for( n=0.2; n<=lenght+0.2; n+=0.1 )
					{	
						effect = theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\effects_for_sword.w2ent",true ), thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
						effect.CreateAttachment( sword_for_effect,,Vector( 0, 0, 1*n ));
						effect.PlayEffect('aard');
						effect.StopAllEffectsAfter(0.6);
						effect.DestroyAfter(3);
					}
					
					thePlayer.SoundEvent("fx_rune_activate_aard");thePlayer.SoundEvent("fx_rune_activate_aard");thePlayer.SoundEvent("fx_rune_activate_aard");
					
					break;
				
				case ST_Quen:
					
					thePlayer.AddTimer('quen_sword',0.7,false,,,false);
					
					if( RandF() <= 0.5)
					{	thePlayer.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'man_geralt_sword_attack_strong_9_rp_70ms',0.2,0.8);	}
					else
					{	thePlayer.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'man_geralt_sword_attack_strong_4_rp_70ms',0.2,0.8);	}
					
					for( n=0.2; n<=lenght; n+=0.1 )
					{	
						effect = theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\effects_for_sword.w2ent",true ), thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
						effect.CreateAttachment( sword_for_effect,,Vector( 0, 0, 1*n ));
						effect.PlayEffect('quen');effect.PlayEffect('quen1');
						effect.StopAllEffectsAfter(0.6);
						effect.DestroyAfter(3);
					}
					
					thePlayer.SoundEvent("fx_rune_activate_quen");thePlayer.SoundEvent("fx_rune_activate_quen");thePlayer.SoundEvent("fx_rune_activate_quen");
					
					break;
				
				case ST_Yrden:
					
					thePlayer.AddTimer('yrden_sword',0.7,false,,,false);
					thePlayer.AddTimer('yrden_sword_sound',0.4,false,,,false);
					
					for( n=0.2; n<=lenght; n+=0.1 )
					{	
						effect = theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\effects_for_sword.w2ent",true ), thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
						effect.CreateAttachment( sword_for_effect,,Vector( 0, 0, 1*n ));
						effect.PlayEffect('yrden');
						effect.StopAllEffectsAfter(0.6);
						effect.DestroyAfter(3);
					}
					
					if( RandF() <= 0.5)
					{	thePlayer.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'man_geralt_sword_attack_strong_1_rp_70ms',0.2,0.8);	}
					else 
					{	thePlayer.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'man_geralt_sword_attack_strong_1_lp_70ms',0.2,0.8);	}
					
					thePlayer.SoundEvent("fx_rune_activate_yrden");thePlayer.SoundEvent("fx_rune_activate_yrden");thePlayer.SoundEvent("fx_rune_activate_yrden");
					
					break;
					
				default:		
					break;
			}
		}
	}
	
	
	
	public function Spells_heavy()
	{
		//if( !thePlayer.GetInventory().HasItem( 'sword_tome' ) && !GetWitcherPlayer().GetHorseManager().IsItemEquippedByName('sword_tome')) {	return; }
		
		thePlayer.GetInventory().GetItemEquippedOnSlot(EES_SteelSword, steelid);
		thePlayer.GetInventory().GetItemEquippedOnSlot(EES_SilverSword, silverid);
		
		if ( thePlayer.GetInventory().IsItemHeld(steelid) || thePlayer.GetInventory().IsItemHeld(silverid) )
		{
			
			swordid = thePlayer.GetInventory().GetCurrentlyHeldSword();
			sword_for_effect = thePlayer.GetInventory().GetItemEntityUnsafe(swordid);
			sword_for_effect.CalcEntitySlotMatrix( 'blood_fx_point', weaponSlotMatrix );
			weaponTipPosition = MatrixGetTranslation( weaponSlotMatrix );
			lenght = AbsF(VecDistance(weaponTipPosition, sword_for_effect.GetWorldPosition()));
			
			sgntype = GetWitcherPlayer().GetEquippedSign();
			switch(sgntype)
			{
				case ST_Igni:
				
					thePlayer.AddTimer('igni_sword_heavy',0.5,false,,,false);
					
					if (FactsQuerySum("effect_heavy")<=0 )
					{
						FactsAdd("effect_heavy",,2);
						thePlayer.SoundEvent("fx_rune_activate_igni");thePlayer.SoundEvent("fx_rune_activate_igni");thePlayer.SoundEvent("fx_rune_activate_igni");
						thePlayer.PlayEffect('mutation_1_igni_power');
						for( n=0.3; n<=lenght; n+=0.2 )
						{	
							effect = theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\effects_for_sword.w2ent",true ), thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
							effect.CreateAttachment( sword_for_effect,,Vector( 0, 0, 1*n ));
							effect.PlayEffectSingle('igni');
							effect.StopAllEffectsAfter(1.9);
							effect.DestroyAfter(3);
						}
					}
					break;
			
				case ST_Axii:
					
					theSound.SoundLoadBank( "ep2_mutations_06.bnk", true );
					
					thePlayer.AddTimer('axii_sword_heavy',0.5,false,,,false);
					if (FactsQuerySum("effect_heavy")<=0 )
					{
						FactsAdd("effect_heavy",,2);
						thePlayer.SoundEvent("fx_rune_activate_axii");thePlayer.SoundEvent("fx_rune_activate_axii");thePlayer.SoundEvent("fx_rune_activate_axii");
						thePlayer.PlayEffect('mutation_1_aard_power');
						for( n=0.2; n<=lenght; n+=0.1 )
						{	
							effect = theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\effects_for_sword.w2ent",true ), thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
							effect.CreateAttachment( sword_for_effect,,Vector( 0, 0, 1*n ));
							effect.PlayEffectSingle('axii');effect.PlayEffectSingle('axii1');
							effect.StopAllEffectsAfter(1.7);
							effect.DestroyAfter(3);
						}
					}
					
					
					break;
				
				case ST_Aard:
				
					theSound.SoundLoadBank( "magic_man_mage.bnk", true );

					thePlayer.AddTimer('aard_sword_heavy',0.5,false,,,false);
					
					if (FactsQuerySum("effect_heavy")<=0 )
					{
						FactsAdd("effect_heavy",,2);
						thePlayer.SoundEvent("fx_rune_activate_aard");thePlayer.SoundEvent("fx_rune_activate_aard");thePlayer.SoundEvent("fx_rune_activate_aard");
						
						for( n=0.2; n<=lenght; n+=0.1 )
						{	
							effect = theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\effects_for_sword.w2ent",true ), thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
							effect.CreateAttachment( sword_for_effect,,Vector( 0, 0, 1*n ));
							effect.PlayEffectSingle('aard');
							effect.StopAllEffectsAfter(1.7);
							effect.DestroyAfter(3);
						}
					}
					
					
					break;
				
				case ST_Quen:
					
					theSound.SoundLoadBank( "magic_man_mage.bnk", true );
					
					thePlayer.AddTimer('quen_sword_heavy',0.5,false,,,false);
					
					if (FactsQuerySum("effect_heavy")<=0 )
					{
						FactsAdd("effect_heavy",,2);
						thePlayer.SoundEvent("fx_rune_activate_quen");thePlayer.SoundEvent("fx_rune_activate_quen");thePlayer.SoundEvent("fx_rune_activate_quen");
						
						for( n=0.2; n<=lenght; n+=0.1 )
						{	
							effect = theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\effects_for_sword.w2ent",true ), thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
							effect.CreateAttachment( sword_for_effect,,Vector( 0, 0, 1*n ));
							effect.PlayEffectSingle('quen');effect.PlayEffectSingle('quen');effect.PlayEffectSingle('quen');
							effect.StopAllEffectsAfter(1.7);
							effect.DestroyAfter(3);
						}
					}
					
					
					break;
				
				case ST_Yrden:
					
					thePlayer.AddTimer('yrden_sword_heavy',0.5,false,,,false);
					thePlayer.AddTimer('yrden_sword_sound',0.3,false,,,false);
					thePlayer.AddTimer('yrden_sword_heavy_sound',1,false,,,false);
					theSound.SoundLoadBank( "magic_sorceress.bnk", true );
					if (FactsQuerySum("effect_heavy")<=0 )
					{
						FactsAdd("effect_heavy",,2);
						thePlayer.SoundEvent("fx_rune_activate_yrden");thePlayer.SoundEvent("fx_rune_activate_yrden");thePlayer.SoundEvent("fx_rune_activate_yrden");
						thePlayer.PlayEffect('mutation_1_yrden_power');
						for( n=0.2; n<=lenght; n+=0.1 )
						{	
							effect = theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\effects_for_sword.w2ent",true ), thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
							effect.CreateAttachment( sword_for_effect,,Vector( 0, 0, 1*n ));
							effect.PlayEffectSingle('yrden');
							effect.StopAllEffectsAfter(1.7);
							effect.DestroyAfter(3);
						}
					}
					
					
					break;
					
				default:		
					break;
			}
		}
	}
	
	public function Igni_sword_heavy()
	{	
		shootposition = thePlayer.GetWorldPosition()+thePlayer.GetHeadingVector()*2;
		
		aard_wave = (W3TraceGroundProjectile)theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\igni_proj.w2ent",true ), 
		shootposition, thePlayer.GetWorldRotation());
		aard_wave.Init(NULL);
		
		targetent = (CEntity)theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\poisonyrden\pc_aard.w2ent",true ), 
		thePlayer.GetWorldPosition()+thePlayer.GetHeadingVector()*5, thePlayer.GetWorldRotation());
		targetent.DestroyAfter(1);
		
		aard_wave.ShootProjectileAtNode(0, 13, targetent,11);
		
		shootposition = GetWitcherPlayer().GetWorldPosition()-GetWitcherPlayer().GetHeadingVector()*2;
		
		rot = thePlayer.GetWorldRotation();
		rot.Roll += 90;
		shootposition.Z-=2;
		effect_entity = (CEntity)theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\igni_heavy.w2ent",true ), 
		shootposition, rot);
		effect_entity.PlayEffect('fx_pushigni');
		shootposition.Z+=3;
		effect_entity = (CEntity)theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\igni_heavy.w2ent",true ), 
		shootposition, rot);
		effect_entity.PlayEffect('fx_pushigni');
		effect_entity.DestroyAfter(5);
		
		thePlayer.SoundEvent('sign_igni_charge_begin');
		
		for( i = 5; i <= 13; i += 1 )   
		{ theGame.GetSurfacePostFX().AddSurfacePostFXGroup(thePlayer.GetWorldPosition()+thePlayer.GetHeadingVector()*i, 0.1f+i*0.05, 2.f, 2.f, 10, 1 ); }
	}
	
	public function Axii_sword_heavy()
	{	
		shootposition = thePlayer.GetWorldPosition()+thePlayer.GetHeadingVector()*2;
		aard_wave = (W3TraceGroundProjectile)theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\axii_proj.w2ent",true ), 
		shootposition, thePlayer.GetWorldRotation());
		aard_wave.Init(NULL);
		
		targetent = (CEntity)theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\poisonyrden\pc_aard.w2ent",true ), 
		thePlayer.GetWorldPosition()+thePlayer.GetHeadingVector()*5, thePlayer.GetWorldRotation());
		targetent.DestroyAfter(1);
		
		aard_wave.ShootProjectileAtNode(0, 15, targetent,11);
		
		thePlayer.SoundEvent('ep2_mutations_06_frosty_aard');
		
		for( i = 4; i <= 14; i += 1 )   
		{ theGame.GetSurfacePostFX().AddSurfacePostFXGroup(thePlayer.GetWorldPosition()+thePlayer.GetHeadingVector()*i, 0.1f+i*0.05, 2.f, 2.f, 10, 0 ); }
		
		shootposition = GetWitcherPlayer().GetWorldPosition()-GetWitcherPlayer().GetHeadingVector()*2;
		
		rot = thePlayer.GetWorldRotation();
		rot.Roll += 90;
		shootposition.Z-=2;
		effect_entity = (CEntity)theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\igni_heavy.w2ent",true ), 
		shootposition, rot);
		effect_entity.PlayEffect('fx_pushaxii');
		shootposition.Z+=3;
		effect_entity = (CEntity)theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\igni_heavy.w2ent",true ), 
		shootposition, rot);
		effect_entity.PlayEffect('fx_pushaxii');
		effect_entity.DestroyAfter(5);
		
		thePlayer.SoundEvent('sign_igni_charge_begin');
		
		
	}
	public function Yrden_sword_heavy()
	{	
		
		shootposition = GetWitcherPlayer().GetWorldPosition()-GetWitcherPlayer().GetHeadingVector()*2;
		
		rot = thePlayer.GetWorldRotation();
		rot.Roll += 90;
		shootposition.Z-=2;
		effect_entity = (CEntity)theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\igni_heavy.w2ent",true ), 
		shootposition, rot);
		effect_entity.PlayEffect('fx_pushyrden');
		shootposition.Z+=3;
		effect_entity = (CEntity)theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\igni_heavy.w2ent",true ), 
		shootposition, rot);
		effect_entity.PlayEffect('fx_pushyrden');
		effect_entity.DestroyAfter(5);
		
		
		shootposition = thePlayer.GetWorldPosition()+thePlayer.GetHeadingVector()*2;
		aard_wave = (W3TraceGroundProjectile)theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\yrden_proj.w2ent",true ), 
		shootposition, thePlayer.GetWorldRotation());
		aard_wave.Init(NULL);
		
		aard_wave2 = (W3TraceGroundProjectile)theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\yrden_proj2.w2ent",true ), 
		shootposition, thePlayer.GetWorldRotation());
		aard_wave2.Init(NULL);
		
		targetent = (CEntity)theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\poisonyrden\pc_aard.w2ent",true ), 
		thePlayer.GetWorldPosition()+thePlayer.GetHeadingVector()*5, thePlayer.GetWorldRotation());
		targetent.DestroyAfter(1);
		
		aard_wave.ShootProjectileAtNode(0, 10, targetent,11);
		aard_wave2.ShootProjectileAtNode(0, 10, targetent,11);
		
		thePlayer.SoundEvent("magic_sorceress_vfx_lightning_bolt");
	}
	public function Aard_sword_heavy()
	{	
		shootposition = thePlayer.GetWorldPosition()+thePlayer.GetHeadingVector()*2;
		
		aard_wave = (W3TraceGroundProjectile)theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\giant_shockwave_proj.w2ent",true ), 
		shootposition, thePlayer.GetWorldRotation());
		aard_wave.PlayEffect('aard_heavy');
		aard_wave.DestroyAfter(7);
		thePlayer.SoundEvent("magic_man_push");
		
		
		aard_wave2 = (W3TraceGroundProjectile)theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\aard_proj.w2ent",true ), 
		shootposition, thePlayer.GetWorldRotation());
		aard_wave2.Init(NULL);
		
		targetent = (CEntity)theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\poisonyrden\pc_aard.w2ent",true ), 
		thePlayer.GetWorldPosition()+thePlayer.GetHeadingVector()*5, thePlayer.GetWorldRotation());
		targetent.DestroyAfter(1);
		
		aard_wave2.ShootProjectileAtNode(0, 25, targetent,11);
	}
	public function Quen_sword_heavy()
	{	
		shootposition = thePlayer.GetWorldPosition()+thePlayer.GetHeadingVector()*2;
		
		aard_wave2 = (W3TraceGroundProjectile)theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\giant_shockwave_proj.w2ent",true ), 
		shootposition, thePlayer.GetWorldRotation());
		aard_wave2.PlayEffect('quen_heavy');
		aard_wave2.DestroyAfter(7);
		thePlayer.SoundEvent("magic_man_push");
		
		aard_wave = (W3TraceGroundProjectile)theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\swordeffects\quen_proj.w2ent",true ), 
		shootposition, thePlayer.GetWorldRotation());
		aard_wave.Init(NULL);
		
		targetent = (CEntity)theGame.CreateEntity( (CEntityTemplate) LoadResource( "dlc\adtomes\poisonyrden\pc_aard.w2ent",true ), 
		thePlayer.GetWorldPosition()+thePlayer.GetHeadingVector()*5, thePlayer.GetWorldRotation());
		targetent.DestroyAfter(1);
		
		aard_wave.ShootProjectileAtNode(0, 15, targetent,11);
	}
}
