/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
struct SAxiiEffects
{
	editable var castEffect		: name;
	editable var throwEffect	: name;
}

statemachine class W3AxiiEntity extends W3SignEntity
{
	editable var effects		: array< SAxiiEffects >;	
	editable var projTemplate	: CEntityTemplate;
	editable var distance		: float;	
	editable var projSpeed		: float;
	
	default skillEnum = S_Magic_5;
	
	protected var targets		: array<CActor>;
	protected var orientationTarget : CActor;
	
	public function GetSignType() : ESignType
	{
		return ST_Axii;
	}
	
	function Init( inOwner : W3SignOwner, prevInstance : W3SignEntity, optional skipCastingAnimation : bool, optional notPlayerCast : bool ) : bool
	{	
		var ownerActor : CActor;
		var prevSign : W3SignEntity;
		
		ownerActor = inOwner.GetActor();
		
		if( (CPlayer)ownerActor )
		{
			prevSign = GetWitcherPlayer().GetSignEntity(ST_Axii);
			if(prevSign)
				prevSign.OnSignAborted(true);
		}
		
		ownerActor.SetBehaviorVariable( 'bStopSign', 0.f );
		//Dragnilar - This messes up Puppet (the alternate cast for Axii) according to Ghost Mode
		// if ( inOwner.CanUseSkill(S_Magic_s17) && inOwner.GetSkillLevel(S_Magic_s17) > 1)
		// 	ownerActor.SetBehaviorVariable( 'bSignUpgrade', 1.f );
		// else
		ownerActor.SetBehaviorVariable( 'bSignUpgrade', 0.f );
		
		return super.Init( inOwner, prevInstance, skipCastingAnimation );
	}
		
	event OnProcessSignEvent( eventName : name )
	{
		if ( eventName == 'axii_ready' )
		{
			PlayEffect( effects[fireMode].throwEffect );
		}
		else if ( eventName == 'horse_cast_begin' )
		{
			OnHorseStarted();
		}
		else
		{
			return super.OnProcessSignEvent( eventName );
		}
		
		return true;
	}
	
	event OnStarted()
	{
		var player : CR4Player;
		var i : int;
		
		SelectTargets();
		
		for(i=0; i<targets.Size(); i+=1)
		{
			AddMagic17Effect(targets[i]);
		}
		
		Attach(true);
		
		player = (CR4Player)owner.GetActor();
		if(player)
		{
			GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
			player.AddTimer('ResetPadBacklightColorTimer', 2);
		}
			
		PlayEffect( effects[fireMode].castEffect );
		
		if ( owner.ChangeAspect( this, S_Magic_s05 ) )
		{
			CacheActionBuffsFromSkill();
			GotoState( 'AxiiChanneled' );
		}
		else
		{
			GotoState( 'AxiiCast' );
		}		
	}
	
	
	function OnHorseStarted()
	{
		Attach(true);
		PlayEffect( effects[fireMode].castEffect );
	}
	
	
	private final function IsTargetValid(actor : CActor, isAdditionalTarget : bool) : bool
	{
		var npc : CNewNPC;
		var horse : W3HorseComponent;
		var attitude : EAIAttitude;
		
		if(!actor)
			return false;
			
		if(!actor.IsAlive())
			return false;
		
				
		attitude = GetAttitudeBetween(owner.GetActor(), actor);
		
		
		if(isAdditionalTarget && attitude != AIA_Hostile)
			return false;
		
		npc = (CNewNPC)actor;
		
	
		if(attitude == AIA_Friendly)
		{
			
			if(npc.GetNPCType() == ENGT_Quest && !actor.HasTag(theGame.params.TAG_AXIIABLE_LOWER_CASE) && !actor.HasTag(theGame.params.TAG_AXIIABLE))
				return false;
		}
					
		
		if(npc)
		{
			horse = npc.GetHorseComponent();				
			if(horse && !horse.IsDismounted())	
			{
				if(horse.GetCurrentUser() != owner.GetActor())	
					return false;
			}
		}
		
		return true;
	}
	
	private function SelectTargets()
	{
		var projCount, i, j : int;
		var actors, finalActors : array<CActor>;
		var ownerPos : Vector;
		var ownerActor : CActor;
		var actor : CActor;
		
		//Dragnilar - Since domination is now a part of Delusion, the effect is only granted at level 3
		if(owner.CanUseSkill(S_Magic_s17) && owner.GetSkillLevel(S_Magic_s17) == 3) 
			projCount = 2;
		else
			projCount = 1;
		
		targets.Clear();
		actor = (CActor)thePlayer.slideTarget;	
		
		if(actor && IsTargetValid(actor, false))
		{
			targets.PushBack(actor);
			projCount -= 1;
			
			if(projCount == 0)
				return;
		}
		
		ownerActor = owner.GetActor();
		ownerPos = ownerActor.GetWorldPosition();
		
		
		actors = ownerActor.GetNPCsAndPlayersInCone(15, VecHeading(ownerActor.GetHeadingVector()), 120, 20, , FLAG_OnlyAliveActors + FLAG_TestLineOfSight);
					
		
		for(i=actors.Size()-1; i>=0; i-=1)
		{
			
			if(ownerActor == actors[i] || actor == actors[i] || !IsTargetValid(actors[i], true))
				actors.Erase(i);
		}
		
		
		if(actors.Size() > 0)
			finalActors.PushBack(actors[0]);
					
		for(i=1; i<actors.Size(); i+=1)
		{
			for(j=0; j<finalActors.Size(); j+=1)
			{
				if(VecDistance(ownerPos, actors[i].GetWorldPosition()) < VecDistance(ownerPos, finalActors[j].GetWorldPosition()))
				{
					finalActors.Insert(j, actors[i]);
					break;
				}
			}
			
			
			if(j == finalActors.Size())
				finalActors.PushBack(actors[i]);
		}
		
		
		if(finalActors.Size() > 0)
		{
			for(i=0; i<projCount; i+=1)
			{
				if(finalActors[i])
					targets.PushBack(finalActors[i]);
				else
					break;	
			}
		}
	}
	
	protected function ProcessThrow()
	{
		var proj : W3AxiiProjectile;
		var i : int;				
		var spawnPos : Vector;
		var spawnRot : EulerAngles;		
		
		
		
				
		
		spawnPos = GetWorldPosition();
		spawnRot = GetWorldRotation();
		
		
		StopEffect( effects[fireMode].castEffect );
		PlayEffect('axii_sign_push');
		
		
		for(i=0; i<targets.Size(); i+=1)
		{
			proj = (W3AxiiProjectile)theGame.CreateEntity( projTemplate, spawnPos, spawnRot );
			proj.PreloadEffect( proj.projData.flyEffect );
			proj.ExtInit( owner, skillEnum, this );			
			proj.PlayEffect(proj.projData.flyEffect );				
			proj.ShootProjectileAtNode(0, projSpeed, targets[i]);
		}		
	}
	
	event OnEnded(optional isEnd : bool)
	{
		var buff : EEffectInteract;
		var conf : W3ConfuseEffect;
		var i : int;
		var duration, durationAnimal : SAbilityAttributeValue;
		var casterActor : CActor;
		var dur, durAnimals : float;
		var params, staggerParams : SCustomEffectParams;
		var npcTarget : CNewNPC;
		var jobTreeType : EJobTreeType;
		var axiiDotEffect : SCustomEffectParams; // Dragnilar - For new domination dot effect
		var hexerAction : W3DamageAction;
		var witcher : W3PlayerWitcher; // Dragnilar - For new domination dot effect
		var sp : SAbilityAttributeValue; //Dragnilar - for new domination dot effect
		var min, max : SAbilityAttributeValue; //For Hexer mutagen effect
		var hexerLifeLeech : float; //For Hexer mutagen effect
		var targetPosition, heading, newPos : Vector; //Dragnilar - For slot bonus teleport effect
		var targetRotation : EulerAngles; //Dragnilar - For slot bonus teleport effect 
		var randYaw : float; //Dragnilar - For slot bonus teleport effect
		var entityToCreate : CEntityTemplate; //Dragnilar - For slot bonus teleport effect
		var portal : W3OnSpawnPortal; //Dragnilar - For slot bonus teleport effect

		
		casterActor = owner.GetActor();		
		ProcessThrow();
		StopEffect(effects[fireMode].throwEffect);
		witcher = GetWitcherPlayer();

		
		for(i=0; i<targets.Size(); i+=1)
		{
			RemoveMagic17Effect(targets[i]);

			//Dragnilar - Domination now adds bleeding damage, IF the target is hostile (don't want to make Roach or friendlies bleed.)

			if (casterActor == thePlayer && GetAttitudeBetween(targets[i], casterActor) == AIA_Hostile && thePlayer.IsInCombat())
			{
				
				//Blessing of Water adds ice armor
				if(thePlayer.CanUseSkill(S_Magic_s19) && thePlayer.IsSkillSlotted(S_Magic_s19))
				{
					witcher.AddAbility('IceArmor');
					thePlayer.PlayEffect( 'ice_armor' );
				}
			}

		}
		
		
		RemoveMagic17Effect(orientationTarget);
				
		if(IsAlternateCast())
		{
			thePlayer.LockToTarget( false );
			thePlayer.EnableManualCameraControl( true, 'AxiiEntity' );
		}
		
		if (targets.Size() > 0 )
		{
			
			duration = thePlayer.GetSkillAttributeValue(skillEnum, 'duration', false, true);
			durationAnimal = thePlayer.GetSkillAttributeValue(skillEnum, 'duration_animals', false, true);
			
			duration.valueMultiplicative = 1.0f;
			durationAnimal.valueMultiplicative = 1.0f;
			
			
			
			//Dragnilar - Since domination is now a part of delusion, it only takes effect at level 3
			if(owner.CanUseSkill(S_Magic_s17) && owner.GetSkillLevel(S_Magic_s17) == 3)
			{
				duration -= owner.GetSkillAttributeValue(S_Magic_s17, 'duration', false, true) * (3 - owner.GetSkillLevel(S_Magic_s17));
				durationAnimal -= owner.GetSkillAttributeValue(S_Magic_s17, 'duration', false, true) * (3 - owner.GetSkillLevel(S_Magic_s17));
			}
			
			
			dur = CalculateAttributeValue(duration);
			durAnimals = CalculateAttributeValue(durationAnimal);
			
			
			params.creator = casterActor;
			params.sourceName = "axii_" + skillEnum;			
			params.customPowerStatValue = casterActor.GetTotalSignSpellPower(skillEnum);
			params.isSignEffect = true;
			
			for(i=0; i<targets.Size(); i+=1)
			{
				npcTarget = (CNewNPC)targets[i];
				
				//Dragnilar - Puppet slot bonus adds teleporting effect to Axii
				if(thePlayer.IsSkillSlotted(S_Magic_s05) && !IsAlternateCast() && thePlayer.HasBuff(EET_WhiteWolfBuff))
				{
					targetPosition = npcTarget.GetWorldPosition();
					targetRotation=npcTarget.GetWorldRotation();
					heading = casterActor.GetHeadingVector();
					randYaw = RandRangeF( 180.0, -180.0 );
					targetRotation.Yaw = randYaw;
					entityToCreate = (CEntityTemplate)LoadResource( "portal_04" );
					
					if(VecDistance(casterActor.GetWorldPosition(),npcTarget.GetWorldPosition())<=5)
					{
						if(!theGame.GetWorld().NavigationFindSafeSpot( TraceFloor(targetPosition + heading * 10), 1, 1, newPos ))
						{theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt( "menu_cannot_perform_action_here" ),, true );}
						else
						{
							portal = (W3OnSpawnPortal)theGame.CreateEntity( entityToCreate, targetPosition, targetRotation );
							portal.DestroyAfter( 0.5 );
							npcTarget.TeleportWithRotation(TraceFloor(targetPosition + heading * 10), targetRotation);
							portal = (W3OnSpawnPortal)theGame.CreateEntity( entityToCreate, targetPosition + heading * 10, targetRotation );
							portal.DestroyAfter( 1 );
						}
					}
					else if(VecDistance(casterActor.GetWorldPosition(),npcTarget.GetWorldPosition())>5)
					{
						if(!theGame.GetWorld().NavigationFindSafeSpot( GetWorldPosition() + heading*0.2, -1, 1, newPos ))
						{theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt( "menu_cannot_perform_action_here" ),, true );}
						else
						{
							portal = (W3OnSpawnPortal)theGame.CreateEntity( entityToCreate, targetPosition, targetRotation );
							portal.DestroyAfter( 0.5 );
							npcTarget.TeleportWithRotation(GetWorldPosition() + heading*0.2, targetRotation);
							portal = (W3OnSpawnPortal)theGame.CreateEntity( entityToCreate, GetWorldPosition() + heading, targetRotation );
							portal.DestroyAfter( 0.5 );
						}
					}
				}
				
				if( targets[i].IsAnimal() || npcTarget.IsHorse() )
				{
					params.duration = durAnimals;
				}
				else
				{
					params.duration = dur;
				}
				
				jobTreeType = npcTarget.GetCurrentJTType();	
					
				if ( jobTreeType == EJTT_InfantInHand )
				{
					params.effectType = EET_AxiiGuardMe;
				}
				
				else if(IsAlternateCast() && owner.GetActor() == thePlayer && GetAttitudeBetween(targets[i], owner.GetActor()) == AIA_Friendly)
				{
					params.effectType = EET_Confusion;
				}
				else
				{
					params.effectType = actionBuffs[0].effectType;
				}

				//Dragnilar - Hexer Mutagen causes Axii to inflict direct damage and heals Geralt
				if(thePlayer.HasMutagenEquipped(M_Hexer) && IsRequiredAttitudeBetween(casterActor, targets[i], true))
				{
					theGame.GetDefinitionsManager().GetAbilityAttributeValue('hexer_mutagen_bonus', 'damage', min, max);
					sp = witcher.GetTotalSignSpellPower(S_Magic_5);
					hexerLifeLeech = min.valueAdditive * thePlayer.GetLevel();
					hexerLifeLeech = hexerLifeLeech * sp.valueMultiplicative;
					hexerAction = new W3DamageAction in this;
					hexerAction.Initialize(casterActor, targets[i], NULL, "Hexer mutagen", EHRT_None, CPS_SpellPower, true, false, false, false );	
					hexerAction.SetCannotReturnDamage( true );		
					hexerAction.SetHitAnimationPlayType(EAHA_ForceYes);
					hexerAction.SetHitReactionType(EHRT_Heavy);
					hexerAction.SetPointResistIgnored(true);
					hexerAction.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, hexerLifeLeech);
					hexerLifeLeech = hexerLifeLeech * 0.10; //Returns 10% life of damage
					LogChannel('modDragnilarEdit',"Geralt gets life back from using Hexer mutagen: " + FloatToString(hexerLifeLeech));
					witcher.Heal(hexerLifeLeech);
					theGame.damageMgr.ProcessAction(hexerAction);
				}
			
				
				RemoveMagic17Effect(targets[i]);
			
				buff = targets[i].AddEffectCustom(params);
				if( buff == EI_Pass || buff == EI_Override || buff == EI_Cumulate )
				{
					targets[i].OnAxiied( casterActor );

					//Dragnilar - Apparently this is leftover from the "Demotivate" ability that doesn't exist anymore, per Ghost Mode.			
					// if(owner.CanUseSkill(S_Magic_s18))
					// {
					// 	conf = (W3ConfuseEffect)(targets[i].GetBuff(params.effectType, "axii_" + skillEnum));
					// 	conf.SetDrainStaminaOnExit();
					// } 
				}
				else
				{
					
					if(owner.CanUseSkill(S_Magic_s17) && owner.GetSkillLevel(S_Magic_s17) == 3)
					{
						staggerParams = params;
						staggerParams.effectType = EET_Stagger;
						params.duration = 0.5; //Dragnilar - From Ghost Mode	
						targets[i].AddEffectCustom(staggerParams);					
					}
					else
					{
						
						owner.GetActor().SetBehaviorVariable( 'axiiResisted', 1.f );
					}
				}
			}
		}
		
		casterActor.OnSignCastPerformed(ST_Axii, fireMode);
		
		super.OnEnded();
	}
	
	event OnSignAborted( optional force : bool )
	{
		HAXX_AXII_ABORTED();
		super.OnSignAborted(force);
	}
	
	
	public function HAXX_AXII_ABORTED()
	{
		var i : int;
		
		for(i=0; i<targets.Size(); i+=1)
		{
			RemoveMagic17Effect(targets[i]);
		}
		RemoveMagic17Effect(orientationTarget);
	}
	
	
	public function OnDisplayTargetChange(newTarget : CActor)
	{
		var buffParams : SCustomEffectParams;
	
		
		if(!owner.CanUseSkill(S_Magic_s17) || owner.GetSkillLevel(S_Magic_s17) == 0)
			return;
	 
		if(newTarget == orientationTarget)
			return;
			
		RemoveMagic17Effect(orientationTarget);
		orientationTarget = newTarget;
		
		AddMagic17Effect(orientationTarget);			
	}
	
	private function AddMagic17Effect(target : CActor)
	{
		var buffParams : SCustomEffectParams;
		
		if(!target || owner.GetActor() != GetWitcherPlayer() || !GetWitcherPlayer().CanUseSkill(S_Magic_s17))
			return;
		
		buffParams.effectType = EET_SlowdownAxii;
		buffParams.creator = this;
		buffParams.sourceName = "axii_immobilize";
		buffParams.duration = 10;
		buffParams.effectValue.valueAdditive = 0.999f;
		buffParams.isSignEffect = true;
		
		target.AddEffectCustom(buffParams);
	}
	
	private function RemoveMagic17Effect(target : CActor)
	{
		if(target)
			target.RemoveBuff(EET_SlowdownAxii, true, "axii_immobilize");
	}
}

state AxiiCast in W3AxiiEntity extends NormalCast
{
	event OnEnded(optional isEnd : bool)
	{
		var player			: CR4Player;
		
		
		parent.OnEnded(isEnd);
		super.OnEnded(isEnd);
			
		player = caster.GetPlayer();
		
		if( player )
		{
			parent.ManagePlayerStamina();
			parent.ManageGryphonSetBonusBuff();
		}
		else
		{
			caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
		}
	}
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		parent.owner.GetActor().SetBehaviorVariable( 'axiiResisted', 0.f );
	}
	
	event OnThrowing()
	{
		if( super.OnThrowing() )
		{
			
			caster.GetActor().SetBehaviorVariable( 'bStopSign', 1.f );
		}
	}
	
	event OnSignAborted( optional force : bool )
	{
		parent.HAXX_AXII_ABORTED();
		parent.StopEffect( parent.effects[parent.fireMode].throwEffect );
		parent.StopEffect( parent.effects[parent.fireMode].castEffect );
		
		super.OnSignAborted(force);
	}
}

state AxiiChanneled in W3AxiiEntity extends Channeling
{
	event OnEnded(optional isEnd : bool)
	{
		
		parent.OnEnded(isEnd);
		super.OnEnded(isEnd);
	}
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		parent.owner.GetActor().SetBehaviorVariable( 'axiiResisted', 0.f );
		caster.OnDelayOrientationChange();
	}

	event OnProcessSignEvent( eventName : name )
	{
		if( eventName == 'axii_alternate_ready' )
		{
			
			
		}
		else
		{
			return parent.OnProcessSignEvent( eventName );
		}
		
		return true;
	}
	
	event OnThrowing()
	{
		if( super.OnThrowing() )
			ChannelAxii();			
	}
		
	event OnSignAborted( optional force : bool )
	{
		parent.HAXX_AXII_ABORTED();
		parent.StopEffect( parent.effects[parent.fireMode].throwEffect );
		parent.StopEffect( parent.effects[parent.fireMode].castEffect );

		if ( caster.IsPlayer() )
		{
			caster.GetPlayer().LockToTarget( false );
		}
	
		super.OnSignAborted( force );
	}
	
	entry function ChannelAxii()
	{	
		while( Update() )
		{
			Sleep( 0.0001f );
		}
	}
}

