/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class W3Effect_Aerondight extends CBaseGameplayEffect
{
	private var maxCharges					: int;
	private saved var currentChargeCount			: int;
	private saved var m_wasDischarged		: bool;
	private saved var m_aerondightTime		: float;
	private var dmgBoostAmount					: SAbilityAttributeValue;
	private var stacksPerLevel			: SAbilityAttributeValue;
	private saved var m_currChargingEffect	: name;	
	private var m_aerondightDelay			: float;
	private saved var timeOfPause			: GameTime;
	private var aerondightLevel             : int; //Dragnilar - aerondight can have levels now due to upgrades
	default effectType 				= EET_Aerondight;
	default isPositive 				= true;
	
	event OnUpdate( deltaTime : float )
	{
		m_aerondightTime -= deltaTime;
		
		if( m_aerondightTime <=0 && currentChargeCount > 0 )
		{
			currentChargeCount -= 1;
			UpdateAerondightFX();
			ResetAerondightTime();
		}
		
		super.OnUpdate( deltaTime );
	}
	
	public function OnTimeUpdated(dt : float)
	{
		super.OnTimeUpdated( dt );
	}
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		ResetAerondightTime();
		
		super.OnEffectAdded( customParams );
	}
	
	event OnEffectAddedPost()
	{
		LoadParams();		
	
		super.OnEffectAddedPost();
	}
	
	private function LoadParams()
	{
		var val : SAbilityAttributeValue;
		var aerondight					: SItemUniqueId;

		dmgBoostAmount = target.GetAbilityAttributeValue( 'AerondightEffect', 'perm_dmg_boost' );
		stacksPerLevel = target.GetAbilityAttributeValue( 'AerondightEffect', 'stacks_per_level' );
		
		val = target.GetAbilityAttributeValue( 'AerondightEffect', 'maxStacks' );
		maxCharges = (int) val.valueAdditive;
		val = target.GetAbilityAttributeValue( 'AerondightEffect', 'stackDrainDelay' );
		m_aerondightDelay = val.valueAdditive;

	}
	
	public function OnLoad( t : CActor, eff : W3EffectManager )
	{
		super.OnLoad( t, eff );
		
		LoadParams();
		GetAerondightLevel();
		ResetAerondightTime();
	}
	
	event OnEffectRemoved()
	{
		StopAerondightEffects();
		
		super.OnEffectRemoved();
	}
		
	public function IncreaseAerondightCharges( attackName : name )
	{
		ResetAerondightTime();
		
		if( m_wasDischarged )
		{
			m_wasDischarged = false;
			return;
		}
		
		if( currentChargeCount < maxCharges && !m_wasDischarged )
		{
			if( target.IsLightAttack( attackName ) || thePlayer.GetCombatAction() == EBAT_SpecialAttack_Light )
			{
				currentChargeCount += 1;
			}
			else 
			{
				currentChargeCount = Min( maxCharges, ( currentChargeCount + 2 ) );
			}
			
			UpdateAerondightFX();
		}
	}
	
	private function UpdateAerondightFX()
	{
		var aerondightEntity			: CItemEntity;
		var l_effectComponent		: W3AerondightFXComponent;
		var l_newChargingEffect		: name;
		
		target.GetInventory().GetCurrentlyHeldSwordEntity( aerondightEntity );
		
		l_effectComponent = (W3AerondightFXComponent)aerondightEntity.GetComponentByClassName( 'W3AerondightFXComponent' );
		
		aerondightEntity.StopEffect( m_currChargingEffect );
		
		l_newChargingEffect = l_effectComponent.m_visualEffects[ currentChargeCount - 1 ];
		
		aerondightEntity.PlayEffect( l_newChargingEffect );
		
		m_currChargingEffect = l_newChargingEffect;
	}
	
	public function DischargeAerondight() : bool
	{	
		var playerInventory					: CInventoryComponent;
		var aerondight					: SItemUniqueId;
		var currentDmgBoost		: float;
		var newPermDmgBoost		: float;
		var playerLevel				: int;
		
		//Dragnilar - Aerondight does not need to be boosted anymore in final form
		if (GetAerondightLevel() > 3)
			return false;

		playerInventory = target.GetInventory();
		aerondight = playerInventory.GetCurrentlyHeldSword();

		//Dragnilar - Just use the player level
		playerLevel = thePlayer.GetLevel();
		currentDmgBoost = playerInventory.GetItemModifierFloat( aerondight, 'PermDamageBoost' );

		//If the current damage boost is negative or something weird, reset it to zero
		if( currentDmgBoost < 0 )
		{
			currentDmgBoost = 0;
		}
		
		//Dragnilar - If the current damage boost is greater than or equal to player level * stacks per level, then don't discharge
		//Dragnilar - Aerondight's level increases the maximum number of stacks
		if ((playerLevel * stacksPerLevel.valueAdditive * GetAerondightLevel()) >= currentDmgBoost)
		{
			return false;
		}
		//Discharge aerondight
		m_wasDischarged = true;
		target.PlayEffect( 'lasting_shield_discharge' );
		newPermDmgBoost = currentDmgBoost + dmgBoostAmount.valueAdditive;
		playerInventory.SetItemModifierFloat( aerondight, 'PermDamageBoost', newPermDmgBoost );
		
		//Dragnilar - don't burn stacks on level up if Aerondight is level 4
		if(GetAerondightLevel() < 4)
		{
			ResetCurrentCount();
			StopAerondightEffects();
			m_currChargingEffect = '';
		}
		return true;
	}

	public function FillAerondightBoost()
	{
		//Used to fill aerondight
		var playerInventory					: CInventoryComponent;
		var aerondight					: SItemUniqueId;
		var currentDmgBoost		: float;
		var playerLevel				: int;
		var boostDifference         : float;
		var maximumDamage : float;
		
		//Dragnilar - Aerondight does not need to be boosted anymore in final form
		if (GetAerondightLevel() > 3)
			return;

		playerInventory = target.GetInventory();
		aerondight = GetWitcherPlayer().GetAerondightFromInventory();
		playerLevel = thePlayer.GetLevel();

		currentDmgBoost = CalculateAttributeValue(playerInventory.GetItemAttributeValue(aerondight, 'PermDamageBoost'));
		maximumDamage = playerLevel * stacksPerLevel.valueAdditive * GetAerondightLevel();
		if( currentDmgBoost < 0 )
		{
			currentDmgBoost = 0;
		}
		//Dragnilar - Determine if Aerondight is full, if not fill it with the difference
		if (maximumDamage >= currentDmgBoost)
		{	
			boostDifference = maximumDamage - currentDmgBoost;
			playerInventory.SetItemModifierFloat( aerondight, 'PermDamageBoost', boostDifference );
			theGame.GetGuiManager().ShowNotification(FloatToString(boostDifference) + " Boosts Added To Aerondight");
		}
		else
		{
			theGame.GetGuiManager().ShowNotification("Aerondight is already fully boosted.");
		}
		
	}
	
	protected function OnPaused()
	{
		super.OnPaused();
		
		SetShowOnHUD( false );
		StopAerondightEffects();
		timeOfPause = theGame.GetGameTime();
	}
	
	protected function OnResumed()
	{
		var aerondightEntity	: CItemEntity;
		var secsInPause : float;
		var stacksLost : int;
		var timeInPause : GameTime;
		
		super.OnResumed();
		
		
		timeInPause = theGame.GetGameTime() - timeOfPause;
		secsInPause = ConvertGameSecondsToRealTimeSeconds( GameTimeToSeconds( timeInPause ) );
		stacksLost = FloorF( secsInPause / m_aerondightDelay );
		currentChargeCount = Max( 0, currentChargeCount - stacksLost );
		OnUpdate( secsInPause - stacksLost * m_aerondightDelay );	
		
		if( target.GetInventory().ItemHasTag( target.GetInventory().GetCurrentlyHeldSword(), 'Aerondight' ) )
		{
			UpdateAerondightFX();
			
			SetShowOnHUD( true );
			if( m_currChargingEffect != '' )
			{
				target.GetInventory().GetCurrentlyHeldSwordEntity( aerondightEntity );
				aerondightEntity.PlayEffect( m_currChargingEffect );
			}
		}
	}
	
	public function StopAerondightEffects()
	{
		var aerondightEntity			: CItemEntity;
		
		target.GetInventory().GetCurrentlyHeldSwordEntity( aerondightEntity );
		
		
		aerondightEntity.StopEffect( m_currChargingEffect );
	}
	
	protected function StopTargetFX()
	{
		super.StopTargetFX();
		
		StopAerondightEffects();
	}
	
	public function IsFullyCharged() : bool
	{
		return currentChargeCount == maxCharges;
	}
	
	
	
	public function GetCurrentCount() : int
	{
		return currentChargeCount;
	}
	
	public function GetMaxCount() : int
	{
		return maxCharges;
	}
	
	
	
	public function ResetAerondightTime()
	{
		m_aerondightTime = m_aerondightDelay;
	}
	
	public function ReduceAerondightStacks()
	{
		//Dragnilar - Reduce stacks by one when hit; only cancel effect if the count is 0. Adjusted the function so that it is safer, to avoid negative stacks.
		currentChargeCount -= 1;
		
		if (currentChargeCount <= 0)
		{	
			currentChargeCount = 0;
			StopAerondightEffects();
		}

	}
	
	public function ResetCurrentCount()
	{
		currentChargeCount = 0;
	}

	public function GetAerondightLevel() : int
	{
		var aerondight : SItemUniqueId;
		//Dragnilar - public getter for Aerondight level
		if (aerondightLevel < 1)
		{
			//Dragnilar - Get the aerondight level since Aerondight can be upgraded now
			aerondight = GetWitcherPlayer().GetAerondightFromInventory();
			//Dragnilar - Kind of a hack to get the aerondight level, but the game doesn't like storing custom attributes on items
			aerondightLevel = RoundMath(CalculateAttributeValue( thePlayer.GetInventory().GetItemAttributeValue( aerondight, 'item_level_min' ) ));
			aerondightLevel = aerondightLevel / 50;
		}
		return aerondightLevel;
	}
	
}

class W3AerondightFXComponent extends CScriptedComponent
{
	editable var m_visualEffects	: array<name>;
}