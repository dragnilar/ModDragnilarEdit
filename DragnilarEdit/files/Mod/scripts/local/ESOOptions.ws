class ESOOptions
{
	////////////////////////////////    General    ///////////////////////////////////
	
	// Scaling enable/disable
	public function Scale() : bool
	{
		return theGame.GetInGameConfigWrapper().GetVarValue('esoGeneral', 'esoScale');
	}
	
	// Upscaling only enable/disable
	public function UpscaleOnly() : bool
	{
		return theGame.GetInGameConfigWrapper().GetVarValue('esoGeneral', 'esoUpscale');
	}
	
	// Scaling Type
	public function ScaleType() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoGeneral', 'esoScaleType') );
	}
	
	// Enemy bonuses enable/disable
	public function LevelBonuses() : bool
	{
		return theGame.GetInGameConfigWrapper().GetVarValue('esoGeneral', 'esoEnemyBonus');
	}
	
	// Guard bonus levels enable/disable
	public function GuardBonus() : bool
	{
		return theGame.GetInGameConfigWrapper().GetVarValue('esoGeneral', 'esoGuardBonus');
	}
	
	// XP scaling enable/disable
	public function XPScale() : bool
	{
		return theGame.GetInGameConfigWrapper().GetVarValue('esoGeneral', 'esoXPScale');
	}
	
	////////////////////////////////    Health Modifiers    ///////////////////////////////////
	
	// Human health
	public function GetHealthMultHuman() : float
	{		
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('esoHealthModifiers', 'esoHumanHealth') );
	}
	
	// Beast health
	public function GetHealthMultBeast() : float
	{		
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('esoHealthModifiers', 'esoBeastHealth') );
	}
	
	// Monster health
	public function GetHealthMultMonster() : float
	{		
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('esoHealthModifiers', 'esoMonsterHealth') );
	}
	
	// Group Monster health
	public function GetHealthMultGroupMonster() : float
	{		
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('esoHealthModifiers', 'esoGroupMonsterHealth') );
	}
	
	// Contract monster health
	public function GetHealthMultContract() : float
	{		
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('esoHealthModifiers', 'esoContractHealth') );
	}
	
	// Boss health
	public function GetHealthMultBoss() : float
	{		
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('esoHealthModifiers', 'esoBossHealth') );
	}
	
	////////////////////////////////    Damage Modifiers    ///////////////////////////////////
	
	// Human Damage
	public function GetDamageMultHuman() : float
	{		
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('esoDamageModifiers', 'esoHumanDamage') );
	}
	
	// Beast Damage
	public function GetDamageMultBeast() : float
	{		
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('esoDamageModifiers', 'esoBeastDamage') );
	}
	
	// Monster Damage
	public function GetDamageMultMonster() : float
	{		
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('esoDamageModifiers', 'esoMonsterDamage') );
	}
	
	// Group Monster Damage
	public function GetDamageMultGroupMonster() : float
	{		
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('esoDamageModifiers', 'esoGroupMonsterDamage') );
	}
	
	// Contract monster Damage
	public function GetDamageMultContract() : float
	{		
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('esoDamageModifiers', 'esoContractDamage') );
	}
	
	// Boss Damage
	public function GetDamageMultBoss() : float
	{		
		return StringToFloat( theGame.GetInGameConfigWrapper().GetVarValue('esoDamageModifiers', 'esoBossDamage') );
	}
	
	////////////////////////////////    Resistance Modifiers    ///////////////////////////////////
	
	// Human Force modifier
	public function GetForceModHuman() : int
	{		
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersHuman', 'esoHumanForce') );
	}
	
	// Beast Force modifier
	public function GetForceModBeast() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersBeast', 'esoBeastForce') );
	}
	
	// Monster Force modifier
	public function GetForceModMonster() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersMonster', 'esoMonsterForce') );
	}
	
	// Grouped Monsters Force modifier
	public function GetForceModGroupMonster() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersGroupMonster', 'esoGroupMonsterForce') );
	}

	// Contract Monster Force modifier
	public function GetForceModContract() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersContractMonster', 'esoContractMonsterForce') );
	}
		
	// Boss Force modifier
	public function GetForceModBoss() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersBoss', 'esoBossForce') );
	}
	
	// Human Burn modifier
	public function GetBurnModHuman() : int
	{		
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersHuman', 'esoHumanBurn') );
	}
	
	// Beast Burn modifier
	public function GetBurnModBeast() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersBeast', 'esoBeastBurn') );
	}
	
	// Monster Burn modifier
	public function GetBurnModMonster() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersMonster', 'esoMonsterBurn') );
	}
	
	// Grouped Monsters Burn modifier
	public function GetBurnModGroupMonster() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersGroupMonster', 'esoGroupMonsterBurn') );
	}

	// Contract Monster Burn modifier
	public function GetBurnModContract() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersContractMonster', 'esoContractMonsterBurn') );
	}
		
	// Boss Burn modifier
	public function GetBurnModBoss() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersBoss', 'esoBossBurn') );
	}
	
	// Human Will modifier
	public function GetWillModHuman() : int
	{		
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersHuman', 'esoHumanWill') );
	}
	
	// Beast Will modifier
	public function GetWillModBeast() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersBeast', 'esoBeastWill') );
	}
	
	// Monster Will modifier
	public function GetWillModMonster() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersMonster', 'esoMonsterWill') );
	}
	
	// Grouped Monsters Will modifier
	public function GetWillModGroupMonster() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersGroupMonster', 'esoGroupMonsterWill') );
	}

	// Contract Monster Will modifier
	public function GetWillModContract() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersContractMonster', 'esoContractMonsterWill') );
	}
		
	// Boss Will modifier
	public function GetWillModBoss() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersBoss', 'esoBossWill') );
	}
	
	// Human Shock modifier
	public function GetShockModHuman() : int
	{		
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersHuman', 'esoHumanShock') );
	}
	
	// Beast Shock modifier
	public function GetShockModBeast() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersBeast', 'esoBeastShock') );
	}
	
	// Monster Shock modifier
	public function GetShockModMonster() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersMonster', 'esoMonsterShock') );
	}
	
	// Grouped Monsters Shock modifier
	public function GetShockModGroupMonster() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersGroupMonster', 'esoGroupMonsterShock') );
	}

	// Contract Monster Shock modifier
	public function GetShockModContract() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersContractMonster', 'esoContractMonsterShock') );
	}
		
	// Boss Shock modifier
	public function GetShockModBoss() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersBoss', 'esoBossShock') );
	}
	
	// Human Bleed modifier
	public function GetBleedModHuman() : int
	{		
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersHuman', 'esoHumanBleed') );
	}
	
	// Beast Bleed modifier
	public function GetBleedModBeast() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersBeast', 'esoBeastBleed') );
	}
	
	// Monster Bleed modifier
	public function GetBleedModMonster() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersMonster', 'esoMonsterBleed') );
	}
	
	// Grouped Monsters Bleed modifier
	public function GetBleedModGroupMonster() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersGroupMonster', 'esoGroupMonsterBleed') );
	}

	// Contract Monster Bleed modifier
	public function GetBleedModContract() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersContractMonster', 'esoContractMonsterBleed') );
	}
		
	// Boss Bleed modifier
	public function GetBleedModBoss() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersBoss', 'esoBossBleed') );
	}
	
	// Human Poison modifier
	public function GetPoisonModHuman() : int
	{		
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersHuman', 'esoHumanPoison') );
	}
	
	// Beast Poison modifier
	public function GetPoisonModBeast() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersBeast', 'esoBeastPoison') );
	}
	
	// Monster Poison modifier
	public function GetPoisonModMonster() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersMonster', 'esoMonsterPoison') );
	}
	
	// Grouped Monsters Poison modifier
	public function GetPoisonModGroupMonster() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersGroupMonster', 'esoGroupMonsterPoison') );
	}

	// Contract Monster Poison modifier
	public function GetPoisonModContract() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersContractMonster', 'esoContractMonsterPoison') );
	}
		
	// Boss Poison modifier
	public function GetPoisonModBoss() : int
	{
		return StringToInt( theGame.GetInGameConfigWrapper().GetVarValue('esoResistModifiersBoss', 'esoBossPoison') );
	}
}