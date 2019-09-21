class ESOScaling extends ESOOptions
{
	public var SimpleMin, SimpleMax : int;
	
	public var TierOneHumanMin, TierOneHumanMax : int;
	public var TierTwoHumanMin, TierTwoHumanMax : int;
	public var TierThreeHumanMin, TierThreeHumanMax : int;
	public var TierFourHumanMin, TierFourHumanMax : int;
	public var TierFiveHumanMin, TierFiveHumanMax : int;
	
	public var TierOneBeastMin, TierOneBeastMax : int;
	public var TierTwoBeastMin, TierTwoBeastMax : int;
	public var TierThreeBeastMin, TierThreeBeastMax : int;
	public var TierFourBeastMin, TierFourBeastMax : int;
	public var TierFiveBeastMin, TierFiveBeastMax : int;
	
	public var TierOneMinAdded, TierOneMaxAdded : int;
	public var TierTwoMinAdded, TierTwoMaxAdded : int;
	public var TierThreeMinAdded, TierThreeMaxAdded : int;
	public var TierFourMinAdded, TierFourMaxAdded : int;
	public var TierFiveMinAdded, TierFiveMaxAdded : int;

	public var TierOneGroupMinAdded, TierOneGroupMaxAdded : int;
	public var TierTwoGroupMinAdded, TierTwoGroupMaxAdded : int;
	public var TierThreeGroupMinAdded, TierThreeGroupMaxAdded : int;
	public var TierFourGroupMinAdded, TierFourGroupMaxAdded : int;
	public var TierFiveGroupMinAdded, TierFiveGroupMaxAdded : int;
	
	public var FeebleMin, FeebleMax : int;
	public var EasyMin, EasyMax : int;
	public var NormalMin, NormalMax : int;
	public var HardMin, HardMax : int;
	public var HardcoreMin, HardcoreMax : int;
	
	public var TierTwo : int;
	public var TierThree : int;
	public var TierFour : int;
	public var TierFive : int;
	
	public var MaximumLevelCap : int;
	
	public var ContractAdd : int;
	public var BossAdd : int;
	
	// Reads and sets the scaling levels from the mod menu
	private function ReadLevels()
	{
	
		//The beginning level for the different tiers are set here.
		//You fall into different tiers based on what level your character is,
		//so a level 15 Geralt will fall into tier two.		
		TierTwo = 10;
		TierThree = 20;
		TierFour = 30;
		TierFive = 40;
		
		// Simple scaling
		SimpleMin = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoSimpleScaling', 'esoSimpleMin') );
		SimpleMax = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoSimpleScaling', 'esoSimpleMax') );
		
		// Dynamic scaling
		// Humans
		TierOneHumanMin = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingHuman', 'HumanTier1Min') );
		TierOneHumanMax = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingHuman', 'HumanTier1Max') );
		TierTwoHumanMin = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingHuman', 'HumanTier2Min') );
		TierTwoHumanMax = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingHuman', 'HumanTier2Max') );
		TierThreeHumanMin = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingHuman', 'HumanTier3Min') );
		TierThreeHumanMax = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingHuman', 'HumanTier3Max') );
		TierFourHumanMin = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingHuman', 'HumanTier4Min') );
		TierFourHumanMax = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingHuman', 'HumanTier4Max') );
		TierFiveHumanMin = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingHuman', 'HumanTier5Min') );
		TierFiveHumanMax = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingHuman', 'HumanTier5Max') );
		
		// Beasts
		TierOneBeastMin   =	StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingBeast', 'BeastTier1Min') );
		TierOneBeastMax   = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingBeast', 'BeastTier1Max') );
		TierTwoBeastMin	  =	StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingBeast', 'BeastTier2Min') );
		TierTwoBeastMax   = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingBeast', 'BeastTier2Max') );
		TierThreeBeastMin =	StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingBeast', 'BeastTier3Min') );
		TierThreeBeastMax = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingBeast', 'BeastTier3Max') );
		TierFourBeastMin  =	StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingBeast', 'BeastTier4Min') );
		TierFourBeastMax  = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingBeast', 'BeastTier4Max') );
		TierFiveBeastMin  =	StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingBeast', 'BeastTier5Min') );
		TierFiveBeastMax  = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingBeast', 'BeastTier5Max') );
		
		// Monsters
		TierOneMinAdded   = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingMonster', 'MonsterTier1Min') );
		TierOneMaxAdded   = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingMonster', 'MonsterTier1Max') );
		TierTwoMinAdded   = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingMonster', 'MonsterTier2Min') );
		TierTwoMaxAdded   = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingMonster', 'MonsterTier2Max') );
		TierThreeMinAdded = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingMonster', 'MonsterTier3Min') );
		TierThreeMaxAdded = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingMonster', 'MonsterTier3Max') );
		TierFourMinAdded  = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingMonster', 'MonsterTier4Min') );
		TierFourMaxAdded  = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingMonster', 'MonsterTier4Max') );
		TierFiveMinAdded  = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingMonster', 'MonsterTier5Min') );
		TierFiveMaxAdded  = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingMonster', 'MonsterTier5Max') );
		
		// Group Monsters
		TierOneGroupMinAdded   = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingGroupMonster', 'GroupMonsterTier1Min') );
		TierOneGroupMaxAdded   = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingGroupMonster', 'GroupMonsterTier1Max') );
		TierTwoGroupMinAdded   = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingGroupMonster', 'GroupMonsterTier2Min') );
		TierTwoGroupMaxAdded   = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingGroupMonster', 'GroupMonsterTier2Max') );
		TierThreeGroupMinAdded = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingGroupMonster', 'GroupMonsterTier3Min') );
		TierThreeGroupMaxAdded = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingGroupMonster', 'GroupMonsterTier3Max') );
		TierFourGroupMinAdded  = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingGroupMonster', 'GroupMonsterTier4Min') );
		TierFourGroupMaxAdded  = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingGroupMonster', 'GroupMonsterTier4Max') );
		TierFiveGroupMinAdded  = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingGroupMonster', 'GroupMonsterTier5Min') );
		TierFiveGroupMaxAdded  = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoDynamicScalingGroupMonster', 'GroupMonsterTier5Max') );

		// Group scaling
		FeebleMin = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoGroupScaling', 'esoFeebleMin') );
		FeebleMax = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoGroupScaling', 'esoFeebleMax') );
		EasyMin = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoGroupScaling', 'esoEasyMin') );
		EasyMax = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoGroupScaling', 'esoEasyMax') );
		NormalMin = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoGroupScaling', 'esoNormalMin') );
		NormalMax = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoGroupScaling', 'esoNormalMax') );
		HardMin = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoGroupScaling', 'esoHardMin') );
		HardMax = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoGroupScaling', 'esoHardMax') );
		HardcoreMin = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoGroupScaling', 'esoHardcoreMin') );
		HardcoreMax = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoGroupScaling', 'esoHardcoreMax') );
		
		// Bonus levels for contract monsters and bosses
		ContractAdd = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoGeneral', 'esoContractAdd') );
		BossAdd = StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoGeneral', 'esoBossAdd') );

	}

	public function GetIsContractTypeMonster( Enemy : CNewNPC ) : bool
	{
		if ( Enemy.HasAbility('mh302_Leshy') || 
			Enemy.HasAbility('mh202_nekker') || 
			Enemy.HasAbility('mh106_HAG') || 
			Enemy.HasAbility('mh306_dao') || 
			Enemy.HasAbility('qMH208_Noonwraith') || 
			Enemy.HasAbility('mh305_doppler') || 
			Enemy.HasAbility('mh305_doppler_geralt') || 
			Enemy.HasAbility('mh301_Gryphon') || 
			Enemy.HasAbility('mh307_Minion') || 
			Enemy.HasAbility('mh207_wraith') || 
			Enemy.HasAbility('mh207_wraith_boss') || 
			Enemy.HasAbility('qMH101_cockatrice') || 
			Enemy.HasAbility('mon_wraith_mh') || 
			Enemy.HasAbility('mon_nightwraith_mh') || 
			Enemy.HasAbility('mon_noonwraith_mh') || 
			Enemy.HasAbility('mon_wild_hunt_minionMH') || 
			Enemy.HasAbility('mon_forktail_mh') || 
			Enemy.HasAbility('mon_fogling_mh') || 
			Enemy.HasAbility('q302_mh104') || 
			Enemy.HasAbility('qmh303_suc') || 
			Enemy.HasAbility('qmh210_lamia') || 
			Enemy.HasAbility('qmh208_forktail') || 
			Enemy.HasAbility('qmh108_fogling') || 
			Enemy.HasAbility('qmh304_ekima') || 
			Enemy.HasAbility('qmh206_bies') )
		{
			return true;
		}
		else return false;
	}
	
	public function GetIsBoss( Enemy : CNewNPC ) : bool
	{
		if ( Enemy.HasTag('q103_big_botch') || 
			Enemy.HasTag('q704_dettlaff_bossbar') || 
			Enemy.HasAbility('mon_EP2_SpoonCollector') || 
			Enemy.HasAbility('mon_q701_giant') || 
			Enemy.HasAbility('mon_cloud_giant') || 
			Enemy.HasAbility('mon_dettlaff_bossbar_dummy') || 
			Enemy.HasAbility('mon_fairytale_witch') || 
			Enemy.HasAbility('mon_broom_base') || 
			Enemy.HasAbility('mon_dettlaff_monster_base') || 
			Enemy.HasAbility('mon_dettlaff_vampire_base') || 
			Enemy.HasTag('q701_sharley') || 
			Enemy.HasTag('dettlaff_minion') || 
			Enemy.HasTag('sq701_gregoire') || 
			Enemy.HasAbility('WildHunt_Eredin') || 
			Enemy.HasAbility('WildHunt_Imlerith') || 
			Enemy.HasAbility('WildHunt_Caranthir') || 
			Enemy.HasAbility('WildHunt_Caranthir_NGPlus') || 
			Enemy.HasAbility('WildHunt_Imlerith_NGPlus') || 
			Enemy.HasAbility('WildHunt_Eredin_NGPlus') || 
			Enemy.HasAbility('mon_witch1') || 
			Enemy.HasAbility('mon_witch2') || 
			Enemy.HasAbility('mon_witch3') || 
			Enemy.HasAbility('q104_whboss') || 
			Enemy.HasAbility('q202_IceGiantDOOM') || 
			Enemy.HasAbility('olgierd_default_stats') || 
			Enemy.HasAbility('mon_nightwraith_iris') || 
			Enemy.HasAbility('mon_toad_base') || 
			Enemy.HasAbility('q604_caretaker') || 
			Enemy.HasAbility('mon_djinn') )
		{
			return true;
		}
		else return false;
	}
	
	public function GetIsGroupTypeMonster( Enemy : CNewNPC ) : bool
	{
		if ( Enemy.HasAbility('mon_ft_boar_ep2_base') || 
			Enemy.HasAbility('mon_kikimore_base') || 
			Enemy.HasAbility('mon_black_spider_ep2_base') || 
			Enemy.HasAbility('mon_barghest_base') || 
			Enemy.HasAbility('mon_black_spider_base') || 
			Enemy.GetSfxTag() == 'sfx_alghoul' || 
			Enemy.GetSfxTag() == 'sfx_endriaga' || 
			Enemy.GetSfxTag() == 'sfx_ghoul' || 
			Enemy.GetSfxTag() == 'sfx_wraith' || 
			Enemy.GetSfxTag() == 'sfx_drowner' || 
			Enemy.GetSfxTag() == 'sfx_fogling' || 
			Enemy.HasAbility('mon_erynia') || 
			Enemy.GetSfxTag() == 'sfx_harpy'  || 
			Enemy.GetSfxTag() == 'sfx_nekker' ||  
			Enemy.GetSfxTag() == 'sfx_siren' || 
			Enemy.GetSfxTag() == 'sfx_wildhunt_minion' || 
			Enemy.HasAbility('mon_rotfiend') || 
			Enemy.HasAbility('mon_rotfiend_large') )
		{
			return true;
		}
		else return false;
	}
	
	public function GetIsBeast( Enemy : CNewNPC ) : bool
	{
		if ( Enemy.HasAbility('mon_bear_base') || 
			Enemy.GetSfxTag() == 'sfx_wolf' || 
			Enemy.GetSfxTag() == 'sfx_wild_dog' || 
			Enemy.HasAbility('mon_boar_base') || 
			Enemy.HasAbility('eso_mon_boar_base') || 
			Enemy.HasAbility('mon_panther_base') || 
			Enemy.HasAbility('mon_boar_ep2_base') )
		{
			return true;
		}
		else return false;
	}
	
	// Determines whether the enemy should scale based on mod settings
	public function shouldScale( NPC : CNewNPC ) : bool
	{
		if ( UpscaleOnly() )
		{
			if (GetWitcherPlayer().GetLevel() > NPC.currentLevel || NPC.GetNPCType() == ENGT_Guard ) // Always scale guards to avoid a leveling bug with them
			{
				return true;
			}
			else
				return false;
		}
		else
			return true;
	}
	
	// The health multiplier gets added to the difficulty level health multiplier
	// Thus, on deathmarch 50% extra health isn't actually 50% since it adds it to the 80% from deathmarch difficulty for a total of 130%
	// This function will calculate the multiplier to use to actually increase the health by the correct amount, not exactly though due to rounding
	private function CalcHealthMult( NPC : CNewNPC, mult : float ) : int
	{
		var diffHealthMult : float;
		
		// Get the health multiplier from the difficulty level
		diffHealthMult = CalculateAttributeValue( NPC.GetAttributeValue( 'health_final_multiplier' ) );
		
		mult *= diffHealthMult;
		
		return RoundMath( mult * 10 );
	}
	
	// The damage multiplier gets added to the difficulty level damage multiplier
	// Thus, on deathmarch 50% extra damage isn't actually 50% since it adds it to the 230% from deathmarch difficulty for a total of 280%
	// This function will calculate the multiplier to use to actually increase the health by the correct amount, not exactly though due to rounding
	private function CalcDamageMult( NPC : CNewNPC, mult : float ) : int
	{
		var diffDamageMult : float;
		
		// Get the damage multiplier from the difficulty level
		diffDamageMult = CalculateAttributeValue( NPC.GetAttributeValue( 'damage_final_multiplier' ) );
		
		mult *= diffDamageMult;
		
		return RoundMath( mult * 10 );
	}
	
	// Adjusts enemy health according to menu settings
	public function ESOHealthModule( NPC : CNewNPC )
	{
		NPC.RemoveAbilityAll('esoAddHealthMod');
		NPC.RemoveAbilityAll('esoSubHealthMod');
		
		// No health modifier while playing as Ciri
		if ( thePlayer.IsCiri() )
		{
			return;
		}
		// No health modifier if animals or rats
		else if ( NPC.GetSfxTag() == 'sfx_rat' || NPC.HasAbility( 'animal_default_animal' ) )
		{
			return;
		}
		// Contract Monsters
		else if ( GetIsContractTypeMonster( NPC ) )
		{
			// Add Health
			if ( GetHealthMultContract() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoAddHealthMod', CalcHealthMult( NPC, GetHealthMultContract() ) );
			}
			// Subtract Health
			else if ( GetHealthMultContract() < 0 )
			{
				NPC.AddAbilityMultiple('esoSubHealthMod', Abs( CalcHealthMult( NPC, GetHealthMultContract() ) ) );
			}
		}
		// Bosses
		else if ( GetIsBoss( NPC ) )
		{
			// Add Health
			if ( GetHealthMultBoss() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoAddHealthMod', CalcHealthMult( NPC, GetHealthMultBoss() ) );
			}
			// Subtract Health
			else if ( GetHealthMultBoss() < 0 )
			{
				NPC.AddAbilityMultiple('esoSubHealthMod', Abs( CalcHealthMult( NPC, GetHealthMultBoss() ) ) );
			}
		}
		// Humans
		else if ( NPC.IsHuman() )
		{
			// Add Health
			if ( GetHealthMultHuman() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoAddHealthMod', CalcHealthMult( NPC, GetHealthMultHuman() ) );
			}
			// Subtract Health
			else if ( GetHealthMultHuman() < 0 )
			{
				NPC.AddAbilityMultiple('esoSubHealthMod', Abs( CalcHealthMult( NPC, GetHealthMultHuman() ) ) );
			}
		}	
		// Beasts
		else if ( GetIsBeast( NPC ) )
		{
			// Add Health
			if ( GetHealthMultBeast() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoAddHealthMod', CalcHealthMult( NPC, GetHealthMultBeast() ) );
			}
			// Subtract Health
			else if ( GetHealthMultBeast() < 0 )
			{
				NPC.AddAbilityMultiple('esoSubHealthMod', Abs( CalcHealthMult( NPC, GetHealthMultBeast() ) ) );
			}
		}	
		// Group Monsters
		else if ( GetIsGroupTypeMonster( NPC ) )
		{
			// Add Health
			if ( GetHealthMultGroupMonster() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoAddHealthMod', CalcHealthMult( NPC, GetHealthMultGroupMonster() ) );
			}
			// Subtract Health
			else if ( GetHealthMultGroupMonster() < 0 )
			{
				NPC.AddAbilityMultiple('esoSubHealthMod', Abs( CalcHealthMult( NPC, GetHealthMultGroupMonster() ) ) );
			}
		}
		// Monsters
		else
		{
			// Add Health
			if ( GetHealthMultMonster() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoAddHealthMod', CalcHealthMult( NPC, GetHealthMultMonster() ) );
			}
			// Subtract Health
			else if ( GetHealthMultMonster() < 0 )
			{
				NPC.AddAbilityMultiple('esoSubHealthMod', Abs( CalcHealthMult( NPC, GetHealthMultMonster() ) ) );
			}
		}
	}
	
	// Adjusts enemy damage according to menu settings
	public function ESODamageModule( NPC : CNewNPC )
	{
		NPC.RemoveAbilityAll('esoAddDamageMod');
		NPC.RemoveAbilityAll('esoSubDamageMod');
		
		// No damage modifier while playing as Ciri
		if ( thePlayer.IsCiri() )
		{
			return;
		}
		// No damage modifier if animals or rats
		else if ( NPC.GetSfxTag() == 'sfx_rat' || NPC.HasAbility( 'animal_default_animal' ) )
		{
			return;
		}
		// Contract Monsters
		else if ( GetIsContractTypeMonster( NPC ) )
		{
			// Add Damage
			if ( GetDamageMultContract() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoAddDamageMod', CalcDamageMult( NPC, GetDamageMultContract() ) );
			}
			// Subtract Damage
			else if ( GetDamageMultContract() < 0 )
			{
				NPC.AddAbilityMultiple('esoSubDamageMod', Abs( CalcDamageMult( NPC, GetDamageMultContract() ) ) );
			}
		}
		// Bosses
		else if ( GetIsBoss( NPC ) )
		{
			// Add Damage
			if ( GetDamageMultBoss() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoAddDamageMod', CalcDamageMult( NPC, GetDamageMultBoss() ) );
			}
			// Subtract Damage
			else if ( GetDamageMultBoss() < 0 )
			{
				NPC.AddAbilityMultiple('esoSubDamageMod', Abs( CalcDamageMult( NPC, GetDamageMultBoss() ) ) );
			}
		}
		// Humans
		else if ( NPC.IsHuman() )
		{
			// Add Damage
			if ( GetDamageMultHuman() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoAddDamageMod', CalcDamageMult( NPC, GetDamageMultHuman() ) );
			}
			// Subtract Damage
			else if ( GetDamageMultHuman() < 0 )
			{
				NPC.AddAbilityMultiple('esoSubDamageMod', Abs( CalcDamageMult( NPC, GetDamageMultHuman() ) ) );
			}
		}	
		// Beasts
		else if ( GetIsBeast( NPC ) )
		{
			// Add Damage
			if ( GetDamageMultBeast() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoAddDamageMod', CalcDamageMult( NPC, GetDamageMultBeast() ) );
			}
			// Subtract Damage
			else if ( GetDamageMultBeast() < 0 )
			{
				NPC.AddAbilityMultiple('esoSubDamageMod', Abs( CalcDamageMult( NPC, GetDamageMultBeast() ) ) );
			}
		}	
		// Group Monsters
		else if ( GetIsGroupTypeMonster( NPC ) )
		{
			// Add Damage
			if ( GetDamageMultGroupMonster() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoAddDamageMod', CalcDamageMult( NPC, GetDamageMultGroupMonster() ) );
			}
			// Subtract Damage
			else if ( GetDamageMultGroupMonster() < 0 )
			{
				NPC.AddAbilityMultiple('esoSubDamageMod', Abs( CalcDamageMult( NPC, GetDamageMultGroupMonster() ) ) );
			}
		}
		// Monsters
		else
		{
			// Add Damage
			if ( GetDamageMultMonster() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoAddDamageMod', CalcDamageMult( NPC, GetDamageMultMonster() ) );
			}
			// Subtract Damage
			else if ( GetDamageMultMonster() < 0 )
			{
				NPC.AddAbilityMultiple('esoSubDamageMod', Abs( CalcDamageMult( NPC, GetDamageMultMonster() ) ) );
			}
		}
	}
	
	public final function ESOResistanceModule ( NPC : CNewNPC )
	{
		NPC.RemoveAbilityAll('esoForceAddMod');
		NPC.RemoveAbilityAll('esoForceSubMod');
		NPC.RemoveAbilityAll('esoBurnAddMod');
		NPC.RemoveAbilityAll('esoBurnSubMod');
		NPC.RemoveAbilityAll('esoWillAddMod');
		NPC.RemoveAbilityAll('esoWillSubMod');
		NPC.RemoveAbilityAll('esoShockAddMod');
		NPC.RemoveAbilityAll('esoShockSubMod');
		NPC.RemoveAbilityAll('esoBleedAddMod');
		NPC.RemoveAbilityAll('esoBleedSubMod');
		NPC.RemoveAbilityAll('esoPoisonAddMod');
		NPC.RemoveAbilityAll('esoPoisonSubMod');
		
		// No resistances while playing as Ciri
		if ( thePlayer.IsCiri() )
		{
			return;
		}
		// No resistances if animals or rats
		else if ( NPC.GetSfxTag() == 'sfx_rat' || NPC.HasAbility( 'animal_default_animal' ) )
		{
			return;
		}
		// Contract Monsters
		else if ( GetIsContractTypeMonster( NPC ) )
		{
			// Add or subtract force resistance
			if ( GetForceModContract() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoForceAddMod', GetForceModContract() );
			}
			else if ( GetForceModContract() < 0 )
			{
				NPC.AddAbilityMultiple('esoForceSubMod', Abs( GetForceModContract() ) );
			}
			// Add or subtract burn resistance
			if ( GetBurnModContract() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoBurnAddMod', GetBurnModContract() );
			}
			else if ( GetBurnModContract() < 0 )
			{
				NPC.AddAbilityMultiple('esoBurnSubMod', Abs( GetBurnModContract() ) );
			}
			// Add or subtract will resistance
			if ( GetWillModContract() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoWillAddMod', GetWillModContract() );
			}
			else if ( GetWillModContract() < 0 )
			{
				NPC.AddAbilityMultiple('esoWillSubMod', Abs( GetWillModContract() ) );
			}
			// Add or subtract shock resistance
			if ( GetShockModContract() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoShockAddMod', GetShockModContract() );
			}
			else if ( GetShockModContract() < 0 )
			{
				NPC.AddAbilityMultiple('esoShockSubMod', Abs( GetShockModContract() ) );
			}
			// Add or subtract bleed resistance
			if ( GetBleedModContract() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoBleedAddMod', GetBleedModContract() );
			}
			else if ( GetBleedModContract() < 0 )
			{
				NPC.AddAbilityMultiple('esoBleedSubMod', Abs( GetBleedModContract() ) );
			}
			// Add or subtract poison resistance
			if ( GetPoisonModContract() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoPoisonAddMod', GetPoisonModContract() );
			}
			else if ( GetPoisonModContract() < 0 )
			{
				NPC.AddAbilityMultiple('esoPoisonSubMod', Abs( GetPoisonModContract() ) );
			}
		}
		// Bosses
		else if ( GetIsBoss( NPC ) )
		{
			// Add or subtract force resistance
			if ( GetForceModBoss() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoForceAddMod', GetForceModBoss() );
			}
			else if ( GetForceModBoss() < 0 )
			{
				NPC.AddAbilityMultiple('esoForceSubMod', Abs( GetForceModBoss() ) );
			}
			// Add or subtract burn resistance
			if ( GetBurnModBoss() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoBurnAddMod', GetBurnModBoss() );
			}
			else if ( GetBurnModBoss() < 0 )
			{
				NPC.AddAbilityMultiple('esoBurnSubMod', Abs( GetBurnModBoss() ) );
			}
			// Add or subtract will resistance
			if ( GetWillModBoss() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoWillAddMod', GetWillModBoss() );
			}
			else if ( GetWillModBoss() < 0 )
			{
				NPC.AddAbilityMultiple('esoWillSubMod', Abs( GetWillModBoss() ) );
			}
			// Add or subtract shock resistance
			if ( GetShockModBoss() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoShockAddMod', GetShockModBoss() );
			}
			else if ( GetShockModBoss() < 0 )
			{
				NPC.AddAbilityMultiple('esoShockSubMod', Abs( GetShockModBoss() ) );
			}
			// Add or subtract bleed resistance
			if ( GetBleedModBoss() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoBleedAddMod', GetBleedModBoss() );
			}
			else if ( GetBleedModBoss() < 0 )
			{
				NPC.AddAbilityMultiple('esoBleedSubMod', Abs( GetBleedModBoss() ) );
			}
			// Add or subtract poison resistance
			if ( GetPoisonModBoss() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoPoisonAddMod', GetPoisonModBoss() );
			}
			else if ( GetPoisonModBoss() < 0 )
			{
				NPC.AddAbilityMultiple('esoPoisonSubMod', Abs( GetPoisonModBoss() ) );
			}
		}
		// Humans
		else if ( NPC.IsHuman() )
		{
			// Add or subtract force resistance
			if ( GetForceModHuman() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoForceAddMod', GetForceModHuman() );
			}
			else if ( GetForceModHuman() < 0 )
			{
				NPC.AddAbilityMultiple('esoForceSubMod', Abs( GetForceModHuman() ) );
			}
			// Add or subtract burn resistance
			if ( GetBurnModHuman() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoBurnAddMod', GetBurnModHuman() );
			}
			else if ( GetBurnModHuman() < 0 )
			{
				NPC.AddAbilityMultiple('esoBurnSubMod', Abs( GetBurnModHuman() ) );
			}
			// Add or subtract will resistance
			if ( GetWillModHuman() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoWillAddMod', GetWillModHuman() );
			}
			else if ( GetWillModHuman() < 0 )
			{
				NPC.AddAbilityMultiple('esoWillSubMod', Abs( GetWillModHuman() ) );
			}
			// Add or subtract shock resistance
			if ( GetShockModHuman() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoShockAddMod', GetShockModHuman() );
			}
			else if ( GetShockModHuman() < 0 )
			{
				NPC.AddAbilityMultiple('esoShockSubMod', Abs( GetShockModHuman() ) );
			}
			// Add or subtract bleed resistance
			if ( GetBleedModHuman() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoBleedAddMod', GetBleedModHuman() );
			}
			else if ( GetBleedModHuman() < 0 )
			{
				NPC.AddAbilityMultiple('esoBleedSubMod', Abs( GetBleedModHuman() ) );
			}
			// Add or subtract poison resistance
			if ( GetPoisonModHuman() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoPoisonAddMod', GetPoisonModHuman() );
			}
			else if ( GetPoisonModHuman() < 0 )
			{
				NPC.AddAbilityMultiple('esoPoisonSubMod', Abs( GetPoisonModHuman() ) );
			}
		}	
		// Beasts
		else if ( GetIsBeast( NPC ) )
		{
			// Add or subtract force resistance
			if ( GetForceModBeast() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoForceAddMod', GetForceModBeast() );
			}
			else if ( GetForceModBeast() < 0 )
			{
				NPC.AddAbilityMultiple('esoForceSubMod', Abs( GetForceModBeast() ) );
			}
			// Add or subtract burn resistance
			if ( GetBurnModBeast() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoBurnAddMod', GetBurnModBeast() );
			}
			else if ( GetBurnModBeast() < 0 )
			{
				NPC.AddAbilityMultiple('esoBurnSubMod', Abs( GetBurnModBeast() ) );
			}
			// Add or subtract will resistance
			if ( GetWillModBeast() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoWillAddMod', GetWillModBeast() );
			}
			else if ( GetWillModBeast() < 0 )
			{
				NPC.AddAbilityMultiple('esoWillSubMod', Abs( GetWillModBeast() ) );
			}
			// Add or subtract shock resistance
			if ( GetShockModBeast() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoShockAddMod', GetShockModBeast() );
			}
			else if ( GetShockModBeast() < 0 )
			{
				NPC.AddAbilityMultiple('esoShockSubMod', Abs( GetShockModBeast() ) );
			}
			// Add or subtract bleed resistance
			if ( GetBleedModBeast() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoBleedAddMod', GetBleedModBeast() );
			}
			else if ( GetBleedModBeast() < 0 )
			{
				NPC.AddAbilityMultiple('esoBleedSubMod', Abs( GetBleedModBeast() ) );
			}
			// Add or subtract poison resistance
			if ( GetPoisonModBeast() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoPoisonAddMod', GetPoisonModBeast() );
			}
			else if ( GetPoisonModBeast() < 0 )
			{
				NPC.AddAbilityMultiple('esoPoisonSubMod', Abs( GetPoisonModBeast() ) );
			}
		}	
		// Group Monsters
		else if ( GetIsGroupTypeMonster( NPC ) )
		{
			// Add or subtract force resistance
			if ( GetForceModGroupMonster() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoForceAddMod', GetForceModGroupMonster() );
			}
			else if ( GetForceModGroupMonster() < 0 )
			{
				NPC.AddAbilityMultiple('esoForceSubMod', Abs( GetForceModGroupMonster() ) );
			}
			// Add or subtract burn resistance
			if ( GetBurnModGroupMonster() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoBurnAddMod', GetBurnModGroupMonster() );
			}
			else if ( GetBurnModGroupMonster() < 0 )
			{
				NPC.AddAbilityMultiple('esoBurnSubMod', Abs( GetBurnModGroupMonster() ) );
			}
			// Add or subtract will resistance
			if ( GetWillModGroupMonster() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoWillAddMod', GetWillModGroupMonster() );
			}
			else if ( GetWillModGroupMonster() < 0 )
			{
				NPC.AddAbilityMultiple('esoWillSubMod', Abs( GetWillModGroupMonster() ) );
			}
			// Add or subtract shock resistance
			if ( GetShockModGroupMonster() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoShockAddMod', GetShockModGroupMonster() );
			}
			else if ( GetShockModGroupMonster() < 0 )
			{
				NPC.AddAbilityMultiple('esoShockSubMod', Abs( GetShockModGroupMonster() ) );
			}
			// Add or subtract bleed resistance
			if ( GetBleedModGroupMonster() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoBleedAddMod', GetBleedModGroupMonster() );
			}
			else if ( GetBleedModGroupMonster() < 0 )
			{
				NPC.AddAbilityMultiple('esoBleedSubMod', Abs( GetBleedModGroupMonster() ) );
			}
			// Add or subtract poison resistance
			if ( GetPoisonModGroupMonster() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoPoisonAddMod', GetPoisonModGroupMonster() );
			}
			else if ( GetPoisonModGroupMonster() < 0 )
			{
				NPC.AddAbilityMultiple('esoPoisonSubMod', Abs( GetPoisonModGroupMonster() ) );
			}
		}
		// Monsters
		else
		{
			// Add or subtract force resistance
			if ( GetForceModMonster() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoForceAddMod', GetForceModMonster() );
			}
			else if ( GetForceModMonster() < 0 )
			{
				NPC.AddAbilityMultiple('esoForceSubMod', Abs( GetForceModMonster() ) );
			}
			// Add or subtract burn resistance
			if ( GetBurnModMonster() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoBurnAddMod', GetBurnModMonster() );
			}
			else if ( GetBurnModMonster() < 0 )
			{
				NPC.AddAbilityMultiple('esoBurnSubMod', Abs( GetBurnModMonster() ) );
			}
			// Add or subtract will resistance
			if ( GetWillModMonster() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoWillAddMod', GetWillModMonster() );
			}
			else if ( GetWillModMonster() < 0 )
			{
				NPC.AddAbilityMultiple('esoWillSubMod', Abs( GetWillModMonster() ) );
			}
			// Add or subtract shock resistance
			if ( GetShockModMonster() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoShockAddMod', GetShockModMonster() );
			}
			else if ( GetShockModMonster() < 0 )
			{
				NPC.AddAbilityMultiple('esoShockSubMod', Abs( GetShockModMonster() ) );
			}
			// Add or subtract bleed resistance
			if ( GetBleedModMonster() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoBleedAddMod', GetBleedModMonster() );
			}
			else if ( GetBleedModMonster() < 0 )
			{
				NPC.AddAbilityMultiple('esoBleedSubMod', Abs( GetBleedModMonster() ) );
			}
			// Add or subtract poison resistance
			if ( GetPoisonModMonster() > 0 )
			{
				NPC.AddAbilityMultiple( 'esoPoisonAddMod', GetPoisonModMonster() );
			}
			else if ( GetPoisonModMonster() < 0 )
			{
				NPC.AddAbilityMultiple('esoPoisonSubMod', Abs( GetPoisonModMonster() ) );
			}
		}
	}
	
	public function ESORemoveBonuses( NPC : CNewNPC )
	{
		if ( NPC.HasAbility( theGame.params.ENEMY_BONUS_DEADLY ) )
		{
			NPC.RemoveAbility( theGame.params.ENEMY_BONUS_DEADLY );
			NPC.RemoveBuffImmunity( EET_Blindness, 'DeadlyEnemy' );
			NPC.RemoveBuffImmunity( EET_WraithBlindness, 'DeadlyEnemy' );
		}
		if ( NPC.HasAbility( theGame.params.ENEMY_BONUS_HIGH ) )
		{
			NPC.RemoveAbility( theGame.params.ENEMY_BONUS_HIGH );
		}
		if ( NPC.HasAbility( theGame.params.ENEMY_BONUS_LOW ) )
		{
			NPC.RemoveAbility( theGame.params.ENEMY_BONUS_LOW );
		}
		if ( NPC.HasAbility( theGame.params.MONSTER_BONUS_DEADLY ) )
		{
			NPC.RemoveAbility( theGame.params.MONSTER_BONUS_DEADLY );
			NPC.RemoveBuffImmunity( EET_Blindness, 'DeadlyEnemy' );
			NPC.RemoveBuffImmunity( EET_WraithBlindness, 'DeadlyEnemy' );
		}
		if ( NPC.HasAbility( theGame.params.MONSTER_BONUS_HIGH ) )
		{
			NPC.RemoveAbility( theGame.params.MONSTER_BONUS_HIGH );
		}
		if ( NPC.HasAbility( theGame.params.MONSTER_BONUS_LOW ) )
		{
			NPC.RemoveAbility( theGame.params.MONSTER_BONUS_LOW );
		}
		NPC.RemoveAbilityAll( theGame.params.ENEMY_BONUS_PER_LEVEL );
		NPC.RemoveAbilityAll( theGame.params.ENEMY_BONUS_PER_LEVEL_GROUP );
		NPC.RemoveAbilityAll( theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED );
		NPC.RemoveAbilityAll( theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP );
		NPC.RemoveAbilityAll( theGame.params.MONSTER_BONUS_PER_LEVEL_ARMORED );
		NPC.RemoveAbilityAll( theGame.params.MONSTER_BONUS_PER_LEVEL );
		
		// Remove fake level abilities from beasts and add eso level 1 abilities - this will only happen on ESO scaling
		if ( NPC.HasAbility( 'mon_wolf' ) )
		{
			NPC.RemoveAbility( 'mon_wolf' );
			NPC.AddAbility( 'eso_mon_wolf' );
		}
		if ( NPC.HasAbility( 'mon_evil_dog_lvl12' ) )
		{
			NPC.RemoveAbility( 'mon_evil_dog_lvl12' );
			NPC.AddAbility( 'eso_mon_evil_dog_lvl12' );
		}
		if ( NPC.HasAbility( 'wild_dog_lvl9' ) )
		{
			NPC.RemoveAbility( 'wild_dog_lvl9' );
			NPC.AddAbility( 'eso_wild_dog_lvl9' );
		}
		if ( NPC.HasAbility( 'mon_wolf_alpha' ) )
		{
			NPC.RemoveAbility( 'mon_wolf_alpha' );
			NPC.AddAbility( 'eso_mon_wolf_alpha' );
		}
		if ( NPC.HasAbility( 'mon_wolf_alpha_weak' ) )
		{
			NPC.RemoveAbility( 'mon_wolf_alpha_weak' );
			NPC.AddAbility( 'eso_mon_wolf_alpha_weak' );
		}
		if ( NPC.HasAbility( 'mon_wolf_white' ) )
		{
			NPC.RemoveAbility( 'mon_wolf_white' );
			NPC.AddAbility( 'eso_mon_wolf_white' );
		}
		if ( NPC.HasAbility( 'mon_boar_base' ) )
		{
			NPC.RemoveAbility( 'mon_boar_base' );
			NPC.AddAbility( 'eso_mon_boar_base' );
		}
	}
	
	public function CalculateLevel( NPC : CNewNPC, out npcLevelToUpscaledLevelDifference : int ) : int
	{
		var enemyLevel, playerLevel : int;
		var ciriEntity  : W3ReplacerCiri;
	
		playerLevel = GetWitcherPlayer().GetLevel();
		ciriEntity = (W3ReplacerCiri)thePlayer;
		
		// Don't scale rats and other animals like cows and rabbits
		if ( NPC.GetSfxTag() == 'sfx_rat' || NPC.HasAbility( 'animal_default_animal' ) )
			return 1;
		
		// Don't scale djinn because he doesn't scale well, don't scale fistfights because of scaling inconsistencies, and don't scale while playing as Ciri
		if ( ciriEntity || NPC.HasAbility('mon_djinn') || NPC.HasAbility('fistfight_minigame') )
			return NPC.currentLevel;
		
		ReadLevels();
		
		if ( Scale() && shouldScale( NPC ) ) 
		{
			// Simple Scaling
			if ( ScaleType() == 0 )
			{
				enemyLevel = playerLevel + RandRange( SimpleMax + 1, SimpleMin );
			}
			// Dynamic Scaling
			else if ( ScaleType() == 1 )
			{
				// Tier One
				if ( playerLevel >= 1 && playerLevel < TierTwo )
				{	
					if ( GetIsGroupTypeMonster(NPC) )
					{
						enemyLevel = playerLevel + RandRange( TierOneGroupMaxAdded + 1, TierOneGroupMinAdded );
					}
					else if ( NPC.IsHuman() )
					{
						enemyLevel = playerLevel + RandRange( TierOneHumanMax + 1, TierOneHumanMin );
					}
					else if ( GetIsBeast(NPC) && NPC.GetStat( BCS_Vitality, true ) > 0 )
					{
						enemyLevel = playerLevel + RandRange( TierOneBeastMax + 1, TierOneBeastMin );
					}		
					else 
					{
						enemyLevel = playerLevel + RandRange( TierOneMaxAdded + 1, TierOneMinAdded );
					}
				}
				// Tier Two
				else if ( playerLevel < TierThree )
				{	
					if ( GetIsGroupTypeMonster(NPC) )
					{
						enemyLevel = playerLevel + RandRange( TierTwoGroupMaxAdded + 1, TierTwoGroupMinAdded );
					}
					else if ( NPC.IsHuman() )
					{
						enemyLevel = playerLevel + RandRange( TierTwoHumanMax + 1, TierTwoHumanMin );
					}
					else if ( GetIsBeast(NPC) && NPC.GetStat( BCS_Vitality, true ) > 0 )
					{
						enemyLevel = playerLevel + RandRange( TierTwoBeastMax + 1, TierTwoBeastMin );
					}		
					else
					{
						enemyLevel = playerLevel + RandRange( TierTwoMaxAdded + 1, TierTwoMinAdded );
					}
				}
				// Tier Three
				else if ( playerLevel < TierFour )
				{	
					if ( GetIsGroupTypeMonster(NPC) )
					{
						enemyLevel = playerLevel + RandRange( TierThreeGroupMaxAdded + 1, TierThreeGroupMinAdded );
					}
					else if ( NPC.IsHuman() )
					{
						enemyLevel = playerLevel + RandRange( TierThreeHumanMax + 1, TierThreeHumanMin );
					}
					else if ( GetIsBeast(NPC) && NPC.GetStat( BCS_Vitality, true ) > 0 )
					{
						enemyLevel = playerLevel + RandRange( TierThreeBeastMax + 1, TierThreeBeastMin );
					}		
					else
					{
						enemyLevel = playerLevel + RandRange( TierThreeMaxAdded + 1, TierThreeMinAdded );
					}
				}		
				// Tier Four
				else if ( playerLevel < TierFive )
				{	
					if ( GetIsGroupTypeMonster(NPC) )
					{
						enemyLevel = playerLevel + RandRange( TierFourGroupMaxAdded + 1, TierFourGroupMinAdded );
					}
					else if ( NPC.IsHuman() )
					{
						enemyLevel = playerLevel + RandRange( TierFourHumanMax + 1, TierFourHumanMin );
					}
					else if ( GetIsBeast(NPC) && NPC.GetStat( BCS_Vitality, true ) > 0 )
					{
						enemyLevel = playerLevel + RandRange( TierFourBeastMax + 1, TierFourBeastMin );
					}	
					else
					{
						enemyLevel = playerLevel + RandRange( TierFourMaxAdded + 1, TierFourMinAdded );
					}
				}	
				// Tier Five
				else if ( playerLevel >= TierFive )
				{	
					if ( GetIsGroupTypeMonster(NPC) )
					{
						enemyLevel = playerLevel + RandRange( TierFiveGroupMaxAdded + 1, TierFiveGroupMinAdded );
					}
					else if ( NPC.IsHuman() )
					{
						enemyLevel = playerLevel + RandRange( TierFiveHumanMax + 1, TierFiveHumanMin );
					}
					else if ( GetIsBeast(NPC) && NPC.GetStat( BCS_Vitality, true ) > 0 )
					{
						enemyLevel = playerLevel + RandRange( TierFiveBeastMax + 1, TierFiveBeastMin );
					}	
					else
					{
						enemyLevel = playerLevel + RandRange( TierFiveMaxAdded + 1, TierFiveMinAdded );
					}
				}		
			}
			// Group Scaling
			else if ( ScaleType() == 2 )
			{
				if ( NPC.currentLevel - 5 <= playerLevel && NPC.currentLevel + 5 >= playerLevel ) // normal enemy
					enemyLevel = playerLevel + RandRange( NormalMax + 1, NormalMin );
				else
				{
					if ( NPC.currentLevel - 6 >= playerLevel ) // if harder or hardcore enemy 
					{
						if ( NPC.currentLevel - 15 >= playerLevel ) // if hardcore enemy
						{
							enemyLevel = playerLevel + RandRange( HardcoreMax + 1, HardcoreMin );
						}
						else  // if harder enemy
							enemyLevel = playerLevel + RandRange( HardMax + 1, HardMin );
					}
					else // if weaker or pushover enemy
					{
						if ( NPC.currentLevel + 6 <= playerLevel )
						{
							if ( NPC.currentLevel + 15 <= playerLevel ) // if pushover enemy
								enemyLevel = playerLevel + RandRange( FeebleMax + 1, FeebleMin );
							else // if weaker enemy
								enemyLevel = playerLevel + RandRange( EasyMax + 1, EasyMin );				
						}
					}
				}	
			}
		}
		else 
		{
			enemyLevel = NPC.currentLevel;
		}
		
		// Account for fake levels
		enemyLevel = enemyLevel - (int)CalculateAttributeValue( NPC.GetAttributeValue('level',,true)) + 1;
		
		// Must be at least level 1
		if ( enemyLevel <= 0 )
			enemyLevel = 1;
		
		// Add bonus levels for contract and boss enemies
		if ( GetIsContractTypeMonster( NPC ) )
			enemyLevel += ContractAdd;
		else if ( GetIsBoss( NPC ) )
			enemyLevel += BossAdd;
		
		// Don't exceed the max level cap
		if ( enemyLevel > theGame.params.GetPlayerMaxLevel() + 5 )
			enemyLevel = theGame.params.GetPlayerMaxLevel() + 5;
			
		// Set scaled level difference for combat xp calculation
		npcLevelToUpscaledLevelDifference = enemyLevel - NPC.currentLevel;
		
		return enemyLevel;
	}	
	
	public function GenerateLevel( NPC : CNewNPC, Level : int )
	{
		var ciriEntity : W3ReplacerCiri;
		var levelDiff : int;
		
		ciriEntity = (W3ReplacerCiri)thePlayer;
		levelDiff = Level - thePlayer.GetLevel();
		
		if( Level + (int)CalculateAttributeValue( NPC.GetAttributeValue('level',,true)) <= 2 || NPC.HasAbility('NPCDoNotGainBoost') ) 
		{
			// Add Health, Damage, and Resistance Modifiers
			ESOHealthModule( NPC );
			ESODamageModule( NPC );
			ESOResistanceModule( NPC );
			return;
		}
		
		// Humans
		if ( NPC.IsHuman() && NPC.GetStat( BCS_Essence, true ) < 0 )
		{
			if ( NPC.GetNPCType() != ENGT_Guard || ( NPC.GetNPCType() == ENGT_Guard && !GuardBonus() ) )
			{
				if ( !NPC.HasAbility(theGame.params.ENEMY_BONUS_PER_LEVEL ) ) NPC.AddAbilityMultiple( theGame.params.ENEMY_BONUS_PER_LEVEL, Level - 1 );
			} 
			else // Guards if guard bonus is true
			{
				if ( !NPC.HasAbility(theGame.params.ENEMY_BONUS_PER_LEVEL ) ) NPC.AddAbilityMultiple( theGame.params.ENEMY_BONUS_PER_LEVEL, GetWitcherPlayer().GetLevel() + RandRange( 13, 11 ) );
			}
			
			if ( thePlayer.IsCiri() && theGame.GetDifficultyMode() == EDM_Hardcore && !NPC.HasAbility('CiriHardcoreDebuffHuman') ) NPC.AddAbility('CiriHardcoreDebuffHuman');
			
			// Deadly, High, and Low level bonuses if setting is true
			if ( !ciriEntity && LevelBonuses() )
			{
				// Deadly enemies
				if ( levelDiff >= theGame.params.LEVEL_DIFF_DEADLY )
				{
					NPC.AddAbility( theGame.params.ENEMY_BONUS_DEADLY, true );
					NPC.AddBuffImmunity( EET_Blindness, 'DeadlyEnemy', true );
					NPC.AddBuffImmunity( EET_WraithBlindness, 'DeadlyEnemy', true );
				}
				else if ( levelDiff >= theGame.params.LEVEL_DIFF_HIGH ) // High level enemies
				{
					NPC.AddAbility( theGame.params.ENEMY_BONUS_HIGH, true );
				}
				else if ( levelDiff > -theGame.params.LEVEL_DIFF_HIGH ) // Normal enemies
				{
					// Do nothing
				}
				else // Low level enemies
				{
					NPC.AddAbility( theGame.params.ENEMY_BONUS_LOW, true );
				}
			}
		} 
		else
		{
			// Single beasts
			if ( NPC.GetStat( BCS_Vitality, true ) > 0 && ( NPC.HasAbility('mon_bear_base') || NPC.HasAbility('mon_panther_base') ) )
			{
				if ( !NPC.HasAbility(theGame.params.ENEMY_BONUS_PER_LEVEL) ) NPC.AddAbilityMultiple(theGame.params.ENEMY_BONUS_PER_LEVEL, Level - 1 );
				
				// Deadly, High, and Low level bonuses if setting is true
				if ( !ciriEntity && LevelBonuses() )
				{
					// Deadly enemies
					if ( levelDiff >= theGame.params.LEVEL_DIFF_DEADLY )
					{
						NPC.AddAbility( theGame.params.ENEMY_BONUS_DEADLY, true );
						NPC.AddBuffImmunity( EET_Blindness, 'DeadlyEnemy', true );
						NPC.AddBuffImmunity( EET_WraithBlindness, 'DeadlyEnemy', true );
					}
					else if ( levelDiff >= theGame.params.LEVEL_DIFF_HIGH ) // High level enemies
					{
						NPC.AddAbility( theGame.params.ENEMY_BONUS_HIGH, true );
					}
					else if ( levelDiff > -theGame.params.LEVEL_DIFF_HIGH ) // Normal enemies
					{
						// Do nothing
					}
					else // Low level enemies
					{
						NPC.AddAbility( theGame.params.ENEMY_BONUS_LOW, true );
					}
				}
			}
			else if ( NPC.GetStat( BCS_Vitality, true ) > 0 ) // Group beasts
			{
				if ( !NPC.HasAbility(theGame.params.ENEMY_BONUS_PER_LEVEL_GROUP) ) NPC.AddAbilityMultiple(theGame.params.ENEMY_BONUS_PER_LEVEL_GROUP, Level - 1 );
				
				// Deadly, High, and Low level bonuses if setting is true
				if ( !ciriEntity && LevelBonuses() )
				{
					// Deadly enemies
					if ( levelDiff >= theGame.params.LEVEL_DIFF_DEADLY )
					{
						NPC.AddAbility( theGame.params.ENEMY_BONUS_DEADLY, true );
						NPC.AddBuffImmunity( EET_Blindness, 'DeadlyEnemy', true );
						NPC.AddBuffImmunity( EET_WraithBlindness, 'DeadlyEnemy', true );
					}
					else if ( levelDiff >= theGame.params.LEVEL_DIFF_HIGH ) // High level enemies
					{
						NPC.AddAbility( theGame.params.ENEMY_BONUS_HIGH, true );
					}
					else if ( levelDiff > -theGame.params.LEVEL_DIFF_HIGH ) // Normal enemies
					{
						// Do nothing
					}
					else // Low level enemies
					{
						NPC.AddAbility( theGame.params.ENEMY_BONUS_LOW, true );
					}
				}
			}
			else // Essence based enemies
			{
				if ( (int)CalculateAttributeValue( NPC.GetAttributeValue('armor') ) > 0 )
				{
					// Armored group monsters
					if ( GetIsGroupTypeMonster(NPC) )
					{
						if ( !NPC.HasAbility(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED) ) NPC.AddAbilityMultiple(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED, Level - 1 );
					}
					else // Armored single monsters
					{
						if ( !NPC.HasAbility(theGame.params.MONSTER_BONUS_PER_LEVEL_ARMORED) ) NPC.AddAbilityMultiple(theGame.params.MONSTER_BONUS_PER_LEVEL_ARMORED, Level - 1 );
					}
				}
				else
				{
					// Group monsters
					if ( GetIsGroupTypeMonster(NPC) )
					{
						if ( !NPC.HasAbility(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP) ) NPC.AddAbilityMultiple(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP, Level - 1 );
					}
					else // Single monsters
					{
						if ( !NPC.HasAbility(theGame.params.MONSTER_BONUS_PER_LEVEL) ) NPC.AddAbilityMultiple(theGame.params.MONSTER_BONUS_PER_LEVEL, Level - 1 );
					}
				}
				
				if ( thePlayer.IsCiri() && theGame.GetDifficultyMode() == EDM_Hardcore && !NPC.HasAbility('CiriHardcoreDebuffMonster') ) NPC.AddAbility('CiriHardcoreDebuffMonster');
				
				// Deadly, High, and Low level bonuses if setting is true
				if ( !ciriEntity && LevelBonuses() )
				{
					// Deadly enemies
					if ( levelDiff >= theGame.params.LEVEL_DIFF_DEADLY )
					{
						NPC.AddAbility( theGame.params.MONSTER_BONUS_DEADLY, true );
						NPC.AddBuffImmunity( EET_Blindness, 'DeadlyEnemy', true );
						NPC.AddBuffImmunity( EET_WraithBlindness, 'DeadlyEnemy', true );
					}
					else if ( levelDiff >= theGame.params.LEVEL_DIFF_HIGH ) // High level enemies
					{
						NPC.AddAbility( theGame.params.MONSTER_BONUS_HIGH, true );
					}
					else if ( levelDiff > -theGame.params.LEVEL_DIFF_HIGH ) // Normal enemies
					{
						// Do nothing
					}
					else // Low level enemies
					{
						NPC.AddAbility( theGame.params.MONSTER_BONUS_LOW, true );
					}
				}
			}	 
		}
		
		// Add Health, Damage, and Resistance Modifiers
		ESOHealthModule( NPC );
		ESODamageModule( NPC );
		ESOResistanceModule( NPC );
	}
	
	public function ScalingModule( NPC : CNewNPC, Level : int )
	{
		if ( Scale() && shouldScale( NPC ) )
			GenerateLevel( NPC, Level );
	}
}