/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/





class CharacterStatsPopupData extends TextPopupData
{	
	var m_flashValueStorage : CScriptedFlashValueStorage;
	
	protected  function GetContentRef() : string 
	{
		return "StatisticsFullRef";
	}
	
	protected  function DefineDefaultButtons():void
	{
		AddButtonDef("panel_button_common_exit", "escape-gamepad_B", IK_Escape);
		AddButtonDef("input_feedback_scroll_text", "gamepad_R_Scroll");
	}
	
	public function  OnUserFeedback( KeyCode:string ) : void
	{
		if (KeyCode == "escape-gamepad_B") 
		{
			ClosePopup();
		}
	}
	
	public  function GetGFxData(parentFlashValueStorage : CScriptedFlashValueStorage) : CScriptedFlashObject 
	{
		var gfxData : CScriptedFlashObject;
		
		m_flashValueStorage = parentFlashValueStorage;
		
		gfxData = parentFlashValueStorage.CreateTempFlashObject();
		GetPlayerStatsGFxData(parentFlashValueStorage);
		gfxData.SetMemberFlashString("ContentRef", GetContentRef());
		
		return gfxData;
	}
}

function GetPlayerStatsGFxData(parentFlashValueStorage : CScriptedFlashValueStorage) : CScriptedFlashObject
{ 
	var statsArray : CScriptedFlashArray;
	var gfxData    : CScriptedFlashObject;
	
	var gfxSilverDamage : CScriptedFlashObject;
	var gfxSteelDamage  : CScriptedFlashObject;
	var gfxArmor 		: CScriptedFlashObject;
	var gfxVitality 	: CScriptedFlashObject;
	var gfxSpellPower 	: CScriptedFlashObject;
	var gfxToxicity 	: CScriptedFlashObject;
	var gfxStamina 		: CScriptedFlashObject;
	var gfxCrossbow  	: CScriptedFlashObject;
	var gfxAdditional  	: CScriptedFlashObject;
	
	var gfxSilverDamageSub : CScriptedFlashArray;
	var gfxSteelDamageSub  : CScriptedFlashArray;
	var gfxArmorSub 	   : CScriptedFlashArray;
	var gfxVitalitySub 	   : CScriptedFlashArray;
	var gfxSpellPowerSub   : CScriptedFlashArray;
	var gfxToxicitySub 	   : CScriptedFlashArray;
	var gfxStaminaSub	   : CScriptedFlashArray;
	var gfxCrossbowSub     : CScriptedFlashArray;
	var gfxAdditionalSub   : CScriptedFlashArray;
	
	var gameTime		: GameTime;
	var gameTimeHours	: string;
	var gameTimeMinutes : string;
	
	gfxData = parentFlashValueStorage.CreateTempFlashObject();
	statsArray = parentFlashValueStorage.CreateTempFlashArray();
	gfxSilverDamage = AddCharacterStatU("mainSilverStat", 'silverdamage', "panel_common_statistics_tooltip_silver_dps", "attack_silver", statsArray, parentFlashValueStorage);
	gfxSilverDamageSub = parentFlashValueStorage.CreateTempFlashArray();
	
	AddCharacterHeader("panel_common_statistics_tooltip_silver_dps", gfxSilverDamageSub, parentFlashValueStorage, true, "Red");
	AddCharacterStatU("silverStat2", 'silverFastDPS', "panel_common_statistics_tooltip_silver_fast_dps", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("silverStat3", 'silverFastCritChance', "panel_common_statistics_tooltip_silver_fast_crit_chance", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("silverStat4", 'silverFastCritDmg', "panel_common_statistics_tooltip_silver_fast_crit_dmg", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("Dummy", '', "", "", gfxSilverDamageSub, parentFlashValueStorage);
	AddCharacterStatU("silverStat5", 'silverStrongDPS', "panel_common_statistics_tooltip_silver_strong_dps", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("silverStat6", 'silverStrongCritChance', "panel_common_statistics_tooltip_silver_strong_crit_chance", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("silverStat7", 'silverStrongCritDmg', "panel_common_statistics_tooltip_silver_strong_crit_dmg", "", gfxSilverDamageSub, parentFlashValueStorage); 	
	AddCharacterStatU("Dummy", '', "", "", gfxSilverDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("silverStat9", 'silver_desc_poinsonchance_mult', "attribute_name_desc_poinsonchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU2("silverStat10", 'silver_desc_bleedingchance_mult', "attribute_name_desc_bleedingchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU2("silverStat11", 'silver_desc_burningchance_mult', "attribute_name_desc_burningchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU2("silverStat12", 'silver_desc_confusionchance_mult', "attribute_name_desc_confusionchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU2("silverStat13", 'silver_desc_freezingchance_mult', "attribute_name_desc_freezingchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU2("silverStat14", 'silver_desc_staggerchance_mult', "attribute_name_desc_staggerchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage);
	gfxSilverDamage.SetMemberFlashArray("subStats", gfxSilverDamageSub);
	
	
	
	gfxSteelDamage = AddCharacterStatU("mainSteelStat", 'steeldamage', "panel_common_statistics_tooltip_steel_dps", "attack_steel", statsArray, parentFlashValueStorage);
	gfxSteelDamageSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("panel_common_statistics_tooltip_steel_dps", gfxSteelDamageSub, parentFlashValueStorage, true, "Red");
	AddCharacterStatU("steelStat2", 'steelFastDPS', "panel_common_statistics_tooltip_steel_fast_dps", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat3", 'steelFastCritChance', "panel_common_statistics_tooltip_steel_fast_crit_chance", "", gfxSteelDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("steelStat4", 'steelFastCritDmg', "panel_common_statistics_tooltip_steel_fast_crit_dmg", "", gfxSteelDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("defStat7", '', "", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat5", 'steelStrongDPS', "panel_common_statistics_tooltip_steel_strong_dps", "", gfxSteelDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("steelStat6", 'steelStrongCritChance', "panel_common_statistics_tooltip_steel_strong_crit_chance", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat7", 'steelStrongCritDmg', "panel_common_statistics_tooltip_steel_strong_crit_dmg", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat8", '', "", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("steelStat9", 'steel_desc_poinsonchance_mult', "attribute_name_desc_poinsonchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("steelStat10", 'steel_desc_bleedingchance_mult', "attribute_name_desc_bleedingchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("steelStat11", 'steel_desc_burningchance_mult', "attribute_name_desc_burningchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("steelStat12", 'steel_desc_confusionchance_mult', "attribute_name_desc_confusionchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("steelStat13", 'steel_desc_freezingchance_mult', "attribute_name_desc_freezingchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("steelStat14", 'steel_desc_staggerchance_mult', "attribute_name_desc_staggerchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	gfxSteelDamage.SetMemberFlashArray("subStats", gfxSteelDamageSub);
	
	
	
	gfxArmor = AddCharacterStat("mainResStat", 'armor', "attribute_name_armor", "armor", statsArray, parentFlashValueStorage);
	gfxArmorSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("attribute_name_armor", gfxArmorSub, parentFlashValueStorage, true, "Red");
	AddCharacterStatF("defStat2", 'slashing_resistance_perc', "slashing_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat3", 'piercing_resistance_perc', "attribute_name_piercing_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat4", 'bludgeoning_resistance_perc', "bludgeoning_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat5", 'rending_resistance_perc', "attribute_name_rending_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat6", 'elemental_resistance_perc', "attribute_name_elemental_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatU("defStat7", '', "", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat8", 'poison_resistance_perc', "attribute_name_poison_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat9", 'bleeding_resistance_perc', "attribute_name_bleeding_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat10", 'burning_resistance_perc', "attribute_name_burning_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	gfxArmor.SetMemberFlashArray("subStats", gfxArmorSub);
	
	
	
	gfxCrossbow = AddCharacterStat("majorStat4", 'crossbow', "item_category_crossbow", "crossbow", statsArray, parentFlashValueStorage);
	gfxCrossbowSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("item_category_crossbow", gfxCrossbowSub, parentFlashValueStorage, true, "Red");
	AddCharacterStatU("steelStat17", 'crossbowCritChance', "panel_common_statistics_tooltip_crossbow_crit_chance", "", gfxCrossbowSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat18", 'crossbowSteelDmg', "attribute_name_piercingdamage", "", gfxCrossbowSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat19", 'crossbowSilverDmg', "attribute_name_silverdamage", "", gfxCrossbowSub, parentFlashValueStorage);
	gfxCrossbow.SetMemberFlashArray("subStats", gfxCrossbowSub);
	
	
	
	gfxVitality =  AddCharacterStat("majorStat1", 'vitality', "vitality", "vitality", statsArray, parentFlashValueStorage);
	gfxVitalitySub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("vitality", gfxVitalitySub, parentFlashValueStorage, true, "Green");
	AddCharacterStat("defStat12", 'vitalityRegen', "panel_common_statistics_tooltip_outofcombat_regen", "", gfxVitalitySub, parentFlashValueStorage);
	AddCharacterStat("defStat13", 'vitalityCombatRegen', "panel_common_statistics_tooltip_incombat_regen", "", gfxVitalitySub, parentFlashValueStorage);
	gfxVitality.SetMemberFlashArray("subStats", gfxVitalitySub);
	
	
	
	gfxToxicity = AddCharacterStat("majorStat2", 'toxicity', "attribute_name_toxicity", "toxicity", statsArray, parentFlashValueStorage);
	gfxToxicitySub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("attribute_name_toxicity", gfxToxicitySub, parentFlashValueStorage, true, "Green");	
	AddCharacterStatToxicity("lockedToxicity", 'lockedToxicity', "toxicity_offset", "", gfxToxicitySub, parentFlashValueStorage);
	AddCharacterStatToxicity("toxicity", 'toxicity', "toxicity", "", gfxToxicitySub, parentFlashValueStorage);
	gfxToxicity.SetMemberFlashArray("subStats", gfxToxicitySub);
	
	
	
	gfxSpellPower = AddCharacterStat("mainMagicStat", 'spell_power', "stat_signs", "spell_power", statsArray, parentFlashValueStorage);
	gfxSpellPowerSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("stat_signs", gfxSpellPowerSub, parentFlashValueStorage, true, "Blue");
	AddCharacterHeader("Aard", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("aardStat1", 'aard_knockdownchance', "attribute_name_knockdown", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("aardStat2", 'aard_damage', "attribute_name_forcedamage", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterHeader("Igni", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("igniStat1", 'igni_damage', "attribute_name_firedamage", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("igniStat2", 'igni_burnchance', "effect_burning", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterHeader("Quen", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("quenStat1", 'quen_damageabs', "physical_resistance", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterHeader("Yrden", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("yrdenStat1", 'yrden_slowdown', "SlowdownEffect", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("yrdenStat2", 'yrden_damage', "ShockDamage", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("yrdenStat3", 'yrden_duration', "duration", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterHeader("Axii", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("axiiStat1", 'axii_duration_confusion', "duration", "", gfxSpellPowerSub, parentFlashValueStorage);
	gfxSpellPower.SetMemberFlashArray("subStats", gfxSpellPowerSub);
	
	
	
	gfxStamina = AddCharacterStat("majorStat3", 'stamina', "stamina", "stamina", statsArray, parentFlashValueStorage);
	gfxStaminaSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("stamina", gfxStaminaSub, parentFlashValueStorage, true, "Blue");
	AddCharacterStat("defStat14", 'staminaOutOfCombatRegen', "attribute_name_staminaregen_out_of_combat", "", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterStat("defStat15", 'staminaRegen', "attribute_name_staminaregen", "", gfxStaminaSub, parentFlashValueStorage);
	gfxStamina.SetMemberFlashArray("subStats", gfxStaminaSub);
	
	
	
	gfxAdditional = AddCharacterStat("majorStat5", 'additional', "panel_common_statistics_category_additional", "additional", statsArray, parentFlashValueStorage);
	gfxAdditionalSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("panel_common_statistics_category_additional", gfxAdditionalSub, parentFlashValueStorage, true, "Brown");
	AddCharacterStatF("extraStat1", 'bonus_herb_chance', "bonus_herb_chance", "", gfxAdditionalSub, parentFlashValueStorage);
	AddCharacterStatU("extraStat2", 'instant_kill_chance_mult', "instant_kill_chance", "", gfxAdditionalSub , parentFlashValueStorage);
	AddCharacterStatU("extraStat3", 'human_exp_bonus_when_fatal', "human_exp_bonus_when_fatal", "", gfxAdditionalSub , parentFlashValueStorage);
	AddCharacterStatU("extraStat4", 'nonhuman_exp_bonus_when_fatal', "nonhuman_exp_bonus_when_fatal", "", gfxAdditionalSub , parentFlashValueStorage);
	gfxAdditional.SetMemberFlashArray("subStats", gfxAdditionalSub);
	
	
	
	gameTime =	theGame.CalculateTimePlayed();
	gameTimeHours = (string)(GameTimeDays(gameTime) * 24 + GameTimeHours(gameTime));
	gameTimeMinutes = (string)GameTimeMinutes(gameTime);
	
	gfxData.SetMemberFlashArray("stats", statsArray);
	gfxData.SetMemberFlashString("hoursPlayed", gameTimeHours);
	gfxData.SetMemberFlashString("minutesPlayed", gameTimeMinutes);
	
	return gfxData;
}

function AddCharacterHeader(locKey:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage, optional isSuperHeader : bool, optional color : string):void
{
	var statObject : CScriptedFlashObject;
	statObject = flashMaster.CreateTempFlashObject();
	
	statObject.SetMemberFlashString("name", GetLocStringByKeyExt(locKey));
	statObject.SetMemberFlashString("value", "");
	
	if (isSuperHeader)
	{
		statObject.SetMemberFlashString("tag", "SuperHeader");
		statObject.SetMemberFlashString("backgroundColor", color);
	}
	else
	{
		statObject.SetMemberFlashString("tag", "Header");
	}
	
	statObject.SetMemberFlashString("iconTag", "");
	toArray.PushBackFlashObject(statObject);
}

function AddCharacterStat(tag : string, nmKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var statObject 		: CScriptedFlashObject;
	var valueStr 		: string;
	var valueMaxStr 	: string;
	var valueAbility 	: float;
	var final_name 		: string;
	var sp 				: SAbilityAttributeValue;
	var itemColor		: string;
	
	var gameTime		: GameTime;
	var gameTimeDays	: string;
	var gameTimeHours	: string;
	var gameTimeMinutes	: string;
	var gameTimeSeconds	: string;
	
	statObject			= 	flashMaster.CreateTempFlashObject();
	
	gameTime			=	theGame.CalculateTimePlayed();
	gameTimeDays 		= 	(string)GameTimeDays(gameTime);
	gameTimeHours 		= 	(string)GameTimeHours(gameTime);
	gameTimeMinutes 	= 	(string)GameTimeMinutes(gameTime);
	gameTimeSeconds 	= 	(string)GameTimeSeconds(gameTime);
	
	valueMaxStr = "";
	itemColor = "";

	if ( nmKey == 'vitality' )
	{
		valueStr = (string)RoundMath(thePlayer.GetStat(BCS_Vitality, true));
		valueMaxStr = (string)RoundMath(thePlayer.GetStatMax(BCS_Vitality));
		itemColor = "Green";
	}
	else if ( nmKey == 'toxicity' )
	{
		valueStr = (string)RoundMath(thePlayer.GetStat(BCS_Toxicity, false));
		valueMaxStr = (string)RoundMath(thePlayer.GetStatMax(BCS_Toxicity));
		itemColor = "Green";
	}
	else if ( nmKey == 'stamina' ) 	
	{ 
		valueStr = (string)RoundMath(thePlayer.GetStat(BCS_Stamina, true));
		valueMaxStr = (string)RoundMath(thePlayer.GetStatMax(BCS_Stamina)); 
		itemColor = "Blue";
	}
	else if ( nmKey == 'focus' )
	{
		valueStr = (string)FloorF(thePlayer.GetStat(BCS_Focus, true));
		valueMaxStr = (string)RoundMath(thePlayer.GetStatMax(BCS_Focus));
		itemColor = "Blue";
	}
	else if ( nmKey == 'spell_power' )
	{
		sp += GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_1);
		sp += GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_2);
		sp += GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
		sp += GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_4);
		sp += GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_5);
		
		valueAbility = sp.valueMultiplicative / 5 - 1;
		valueStr = "+" + (string)RoundMath(valueAbility * 100) + " %";
		
		itemColor = "Blue";
	}
	else if ( nmKey == 'vitalityRegen' ) 
	{ 
		valueStr = NoTrailZeros(RoundMath(CalculateAttributeValue( GetWitcherPlayer().GetAttributeValue( nmKey ) ))) + "/" + GetLocStringByKeyExt("per_second");
	}
	else if ( nmKey == 'vitalityCombatRegen' ) 
	{ 
		valueStr = NoTrailZeros(RoundMath(CalculateAttributeValue( GetWitcherPlayer().GetAttributeValue( nmKey ) ))) + "/" + GetLocStringByKeyExt("per_second");
	}
	else if ( nmKey == 'staminaRegen' ) 
	{
		sp = GetWitcherPlayer().GetAttributeValue(nmKey);
		valueAbility = sp.valueAdditive + sp.valueMultiplicative * GetWitcherPlayer().GetStatMax(BCS_Stamina);
		
		valueAbility *= 1 + GetWitcherPlayer().CalculatedArmorStaminaRegenBonus();
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "/" + GetLocStringByKeyExt("per_second"); 
	}
	else if ( nmKey == 'staminaOutOfCombatRegen' ) 
	{
		sp = GetWitcherPlayer().GetAttributeValue(nmKey);
		
		valueAbility = GetWitcherPlayer().GetStatMax(BCS_Stamina) * sp.valueMultiplicative + sp.valueAdditive;
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "/" + GetLocStringByKeyExt("per_second"); 
	}
	else if( nmKey == 'armor')
	{	
		valueAbility =  CalculateAttributeValue( GetWitcherPlayer().GetTotalArmor() );
		valueStr = IntToString( RoundMath(  valueAbility ) );
		itemColor = "Red";
	}
	else if (nmKey == 'crossbow')
	{
		valueStr = NoTrailZeros(RoundMath(GetEquippedCrossbowDamage()));
		itemColor = "Red";
	}	
	else if (nmKey == 'additional')
	{
		valueStr = "";
		itemColor = "Brown";
	}
	else
	{	
		valueAbility =  CalculateAttributeValue( GetWitcherPlayer().GetAttributeValue( nmKey ) );
		valueStr = IntToString( RoundMath(  valueAbility ) );
	}
	
	final_name = GetLocStringByKeyExt(locKey); if ( final_name == "#" ) { final_name = ""; }
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr);
	statObject.SetMemberFlashString("maxValue", valueMaxStr);
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	statObject.SetMemberFlashString("itemColor", itemColor);
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function AddCharacterStatToxicity(tag : string, nmKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var statObject : CScriptedFlashObject;
	var valueStr : string;
	var valueAbility : float;
	
	var toxicityLocked : float;
	var toxicityNoLock : float;
	
	var sp : SAbilityAttributeValue;
	var final_name 		: string;
	var itemColor		: string;
	
	statObject = flashMaster.CreateTempFlashObject();
	
	toxicityNoLock = GetWitcherPlayer().GetStat(BCS_Toxicity, true);
	toxicityLocked = GetWitcherPlayer().GetStat(BCS_Toxicity) - toxicityNoLock;
	
	if ( nmKey == 'lockedToxicity' )	
	{
		valueStr = NoTrailZeros(RoundMath(toxicityLocked));
	}
	else
	{
		valueStr = NoTrailZeros(RoundMath(toxicityNoLock));
	}
	
	final_name = GetLocStringByKeyExt(locKey); if ( final_name == "#" ) { final_name = ""; }
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr);
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	statObject.SetMemberFlashString("itemColor", itemColor);
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function AddCharacterStatSigns(tag : string, nmKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var statObject : CScriptedFlashObject;
	var valueStr : string;
	var valueAbility, aardSecondary : float;
	var final_name : string;
	var min, max : float;
	var sp, mutDmgMod, mutMin, mutMax, yrdenMultiplier, freezingCold : SAbilityAttributeValue; //Dragnilar - Added YrdenMultiplier
	var sword : SItemUniqueId;
	
	statObject = flashMaster.CreateTempFlashObject();
	
	if( GetWitcherPlayer().IsMutationActive( EPMT_Mutation1 ) )
	{
		sword = thePlayer.inv.GetCurrentlyHeldSword();
			
		if( thePlayer.inv.GetItemCategory(sword) == 'steelsword' )
		{
			mutDmgMod += thePlayer.inv.GetItemAttributeValue(sword, theGame.params.DAMAGE_NAME_SLASHING);
		}
		else if( thePlayer.inv.GetItemCategory(sword) == 'silversword' )
		{
			mutDmgMod += thePlayer.inv.GetItemAttributeValue(sword, theGame.params.DAMAGE_NAME_SILVER);
		}
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation1', 'dmg_bonus_factor', mutMin, mutMax);
			
		mutDmgMod.valueBase *= CalculateAttributeValue(mutMin);
	}
	
	
	if ( nmKey == 'aard_knockdownchance' )	
	{ 
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_1);
		valueAbility = sp.valueMultiplicative / theGame.params.MAX_SPELLPOWER_ASSUMED - 4 * theGame.params.NPC_RESIST_PER_LEVEL;  
		valueStr = (string)RoundMath( valueAbility * 100 ) + " %";
	}
	else if ( nmKey == 'aard_damage' ) 	
	{  
		//Dragnilar - Reworked Aard damage
		if ( GetWitcherPlayer().CanUseSkill(S_Magic_s12) )
		{
			sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_s12);
			valueAbility = GetWitcherPlayer().GetSkillLevel(S_Magic_s12) * CalculateAttributeValue( GetWitcherPlayer().GetSkillAttributeValue( S_Magic_s12, theGame.params.DAMAGE_NAME_FORCE, false, true ) );
			valueAbility += mutDmgMod.valueBase;
			valueAbility *= thePlayer.GetLevel() * 25; //Dragnilar - Added multiplier for the changes to Aard Mastery
			if(thePlayer.IsSkillSlotted(S_Magic_s12))
				valueAbility *= 2;
			valueAbility *= sp.valueMultiplicative;
			if(GetWitcherPlayer().GetSkillLevel(S_Magic_s12) > 2)
			{
				aardSecondary = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s12, theGame.params.DAMAGE_NAME_FROST, false, true));
				aardSecondary *= thePlayer.GetLevel() * 10;
				if(thePlayer.IsSkillSlotted(S_Magic_s12))
					aardSecondary *= 2;					
				aardSecondary = aardSecondary * sp.valueMultiplicative;
				valueAbility += aardSecondary;
			}
			if(GetWitcherPlayer().CanUseSkill(S_Magic_s06))
			{
				freezingCold = GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s06, 'ForceDamage', false, false) * thePlayer.GetSkillLevel(S_Magic_s06);
				valueAbility += CalculateAttributeValue(freezingCold) * sp.valueMultiplicative;
			}
			valueStr = (string)RoundMath( valueAbility );
		}
		else
			valueStr = "0";
	}
	else if ( nmKey == 'igni_damage' ) 	
	{  
		//Dragnilar - TODO - This probably is misleading after the changes made to Igni; in fact the tool tip may have been misleading to begin with... :-/
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_2);
		valueAbility = CalculateAttributeValue( GetWitcherPlayer().GetSkillAttributeValue( S_Magic_2, theGame.params.DAMAGE_NAME_FIRE, false, true ) );
		valueAbility += mutDmgMod.valueBase;
		valueAbility *= 1 + (sp.valueMultiplicative-1) * theGame.params.IGNI_SPELL_POWER_MILT;		
		valueStr = (string)RoundMath( valueAbility );
	}
	else if ( nmKey == 'igni_burnchance' ) 	
	{  
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_2);
		valueAbility = sp.valueMultiplicative / theGame.params.MAX_SPELLPOWER_ASSUMED - 4 * theGame.params.NPC_RESIST_PER_LEVEL;
		if (GetWitcherPlayer().CanUseSkill(S_Magic_s07))
		{
			sp = GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s07, 'chance_bonus', false, false);
			valueAbility += valueAbility * sp.valueMultiplicative * GetWitcherPlayer().GetSkillLevel(S_Magic_s07) + sp.valueAdditive * GetWitcherPlayer().GetSkillLevel(S_Magic_s07);
		}
		valueStr = (string)Min(100, RoundMath(valueAbility * 100)) + " %";
	}
	else if ( nmKey == 'quen_damageabs' )
	{
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_4);
		valueAbility = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_4, 'shield_health', false, false));
		valueAbility += mutDmgMod.valueBase;
		valueAbility *= sp.valueMultiplicative;
		valueStr = (string)RoundMath( valueAbility );
	}
	else if ( nmKey == 'yrden_slowdown' )
	{
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
		min = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_3, 'min_slowdown', false, true));
		max = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_3, 'max_slowdown', false, true));
		valueAbility = sp.valueMultiplicative / 4;
		valueAbility =  min + (max - min) * valueAbility;
		valueAbility = ClampF( valueAbility, min, max );
		valueAbility *= 1 - ClampF(4 * theGame.params.NPC_RESIST_PER_LEVEL, 0, 1) ;
		valueStr = (string)RoundMath( valueAbility * 100 ) + " %";
	}
	else if ( nmKey == 'yrden_damage' )
	{
		if (GetWitcherPlayer().CanUseSkill(S_Magic_s03))
		{
			//Dragnilar - Added the player level scaling and yrden damage multiplier bonus
			sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_s03);
			valueAbility = CalculateAttributeValue( GetWitcherPlayer().GetSkillAttributeValue( S_Magic_s03, theGame.params.DAMAGE_NAME_SHOCK, false, true ) );
			valueAbility *= sp.valueMultiplicative;	
			valueAbility *= thePlayer.GetSkillLevel(S_Magic_s03);
			valueAbility *= thePlayer.GetLevel();
			if(thePlayer.CanUseSkill(S_Magic_s16))
			{
				yrdenMultiplier = GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s16, 'yrden_damage_multiplier', false, false) * (thePlayer.GetSkillLevel(S_Magic_s16) + thePlayer.AddSlotBonusForSkillInt(S_Magic_s16, 1));
				valueAbility *= yrdenMultiplier.valueMultiplicative;
			}
			valueAbility += mutDmgMod.valueBase;
			valueStr = (string)RoundMath( valueAbility );
		}
		else
			valueStr = "0";
	}
	else if ( nmKey == 'yrden_duration' )
	{
		sp += GetWitcherPlayer().GetSkillAttributeValue(S_Magic_3, 'trap_duration', false, true);
		sp += GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
		sp.valueMultiplicative -= 1;
		valueAbility = CalculateAttributeValue(sp);
		//Dragnilar - cap yrden duration at 90 seconds
		if (valueAbility > 90.f)
		{
			valueAbility = 90.f;
		}
		valueStr = FloatToStringPrec( valueAbility, 2 ) + GetLocStringByKeyExt("per_second");
	}
	else if ( nmKey == 'axii_duration_confusion' )
	{
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_5);
		sp += GetWitcherPlayer().GetSkillAttributeValue(S_Magic_5, 'duration', false, true);
		valueStr = FloatToStringPrec( CalculateAttributeValue(sp), 2 ) + GetLocStringByKeyExt("per_second");
	}
	
	else
	{	
		valueAbility =  CalculateAttributeValue( GetWitcherPlayer().GetAttributeValue( nmKey ) );
		valueStr = IntToString( RoundF(  valueAbility ) );
	}
	
	final_name = GetLocStringByKeyExt(locKey); if ( final_name == "#" ) { final_name = ""; }
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr);
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	statObject.SetMemberFlashString("itemColor", "Blue");
	
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function AddCharacterStatF(tag : string, nmKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var statObject : CScriptedFlashObject;
	var valueStr : string;
	var valueAbility, pts, perc : float;
	var final_name : string;
	var witcher : W3PlayerWitcher;
	var isPointResist : bool;
	var stat : EBaseCharacterStats;
	var resist : ECharacterDefenseStats;
	var attributeValue : SAbilityAttributeValue;
	var powerStat : ECharacterPowerStats;
	
	statObject = flashMaster.CreateTempFlashObject();
		
	
	witcher = GetWitcherPlayer();
	stat = StatNameToEnum(nmKey);
	if(stat != BCS_Undefined)
	{
		valueAbility = witcher.GetStat(stat);
	}
	else
	{
		resist = ResistStatNameToEnum(nmKey, isPointResist);
		if(resist != CDS_None)
		{
			witcher.GetResistValue(resist, pts, perc);
			
			if(isPointResist)
				valueAbility = pts;
			else
				valueAbility = perc;
		}
		else
		{
			powerStat = PowerStatNameToEnum(nmKey);
			if(powerStat != CPS_Undefined)
			{
				attributeValue = witcher.GetPowerStatValue(powerStat);
			}
			else
			{
				attributeValue = witcher.GetAttributeValue(nmKey);
			}
			
			valueAbility = CalculateAttributeValue( attributeValue );
		}
	}
	
	
	valueStr = NoTrailZeros( RoundMath(valueAbility * 100) );
	
	final_name = GetLocStringByKeyExt(locKey);
	if ( final_name == "#" )
	{
		final_name = "";
	}
	
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr + " %");
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function AddCharacterStatU(tag : string, nmKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var curStats:SPlayerOffenseStats;
	var statObject : CScriptedFlashObject;
	var valueStr : string;
	var valueAbility, maxHealth, curHealth, swordS4value : float; //Dragnilar - Added swordS4Value for Strength Training
	var sp : SAbilityAttributeValue;
	var final_name : string;
	var item : SItemUniqueId;

	statObject = flashMaster.CreateTempFlashObject();

	if(nmKey != 'instant_kill_chance_mult' && nmKey != 'human_exp_bonus_when_fatal' && nmKey != 'nonhuman_exp_bonus_when_fatal' && nmKey != 'area_nml' && nmKey != 'area_novigrad' && nmKey != 'area_skellige')
	{
		curStats = GetWitcherPlayer().GetOffenseStatsList();
	}
	
	if ( nmKey == 'silverdamage' ) 				valueStr = NoTrailZeros(RoundMath((curStats.silverFastDPS+curStats.silverStrongDPS)/2));
	else if ( nmKey == 'steeldamage' ) 			valueStr = NoTrailZeros(RoundMath((curStats.steelFastDPS+curStats.steelStrongDPS)/2));	
	else if ( nmKey == 'silverFastDPS' ) 			valueStr = NoTrailZeros(RoundMath(curStats.silverFastDmg));	
	else if ( nmKey == 'silverFastCritChance' )	valueStr = NoTrailZeros(RoundMath(curStats.silverFastCritChance))+" %";
	else if ( nmKey == 'silverFastCritDmg' )		valueStr = NoTrailZeros(RoundMath(curStats.silverFastCritDmg));
	else if ( nmKey == 'silverStrongDPS' )			valueStr = NoTrailZeros(RoundMath(curStats.silverStrongDmg));
	else if ( nmKey == 'silverStrongCritChance' )	valueStr = NoTrailZeros(RoundMath(curStats.silverStrongCritChance))+" %";
	else if ( nmKey == 'silverStrongCritDmg' )		valueStr = NoTrailZeros(RoundMath(curStats.silverStrongCritDmg));
	else if ( nmKey == 'steelFastDPS' ) 			valueStr = NoTrailZeros(RoundMath(curStats.steelFastDmg));	
	else if ( nmKey == 'steelFastCritChance' )		valueStr = NoTrailZeros(RoundMath(curStats.steelFastCritChance))+" %";
	else if ( nmKey == 'steelFastCritDmg' )		valueStr = NoTrailZeros(RoundMath(curStats.steelFastCritDmg));
	else if ( nmKey == 'steelStrongDPS' )			valueStr = NoTrailZeros(RoundMath(curStats.steelStrongDmg));
	else if ( nmKey == 'steelStrongCritChance' )	valueStr = NoTrailZeros(RoundMath(curStats.steelStrongCritChance))+" %";
	else if ( nmKey == 'steelStrongCritDmg' )		valueStr = NoTrailZeros(RoundMath(curStats.steelStrongCritDmg));
	else if ( nmKey == 'crossbowCritChance' )		valueStr = NoTrailZeros(RoundMath(curStats.crossbowCritChance * 100))+" %";
	else if ( nmKey == 'crossbowDmg' )				valueStr = "";
	else if ( nmKey == 'crossbowSteelDmg' )				
	{ 
		valueStr = NoTrailZeros(RoundMath(curStats.crossbowSteelDmg));
		switch (curStats.crossbowSteelDmgType)
		{
			case theGame.params.DAMAGE_NAME_BLUDGEONING: locKey = "attribute_name_bludgeoningdamage"; break;
			case theGame.params.DAMAGE_NAME_FIRE: locKey = "attribute_name_firedamage"; break;
			default : locKey = "attribute_name_piercingdamage"; break;
		}
	} 
	else if ( nmKey == 'crossbowSilverDmg' )				
	{
		valueStr = NoTrailZeros(RoundMath(curStats.crossbowSilverDmg));
	}
	else if ( nmKey == 'instant_kill_chance_mult') 
	{
		valueAbility = 0;
		if (thePlayer.CanUseSkill(S_Sword_s03))
		{
			sp += GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s03, 'instant_kill_chance', false, true);
			valueAbility = CalculateAttributeValue(sp);
			valueAbility *= thePlayer.GetSkillLevel(S_Sword_s03);
			valueAbility *= RoundF(thePlayer.GetStat(BCS_Focus));
		}
		//Dragnilar - Strength training adds brutal strike 
		if (thePlayer.CanUseSkill(S_Sword_s04) && thePlayer.GetSkillLevel(S_Sword_s04) > 2)
		{	
			sp = GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s04, 'instant_kill_chance', false, true);
			swordS4value = sp.valueAdditive * thePlayer.GetSkillLevel(S_Sword_s04);
			valueAbility +=  swordS4value;
		}
		//Dragnilar - Temerian Devil Expertiese adds brutal strike 
		if (thePlayer.CanUseSkill(S_Sword_s08) && thePlayer.GetSkillLevel(S_Sword_s08) > 2)
		{	
			sp = GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s08, 'instant_kill_chance', false, true);
			valueAbility +=  sp.valueAdditive; //Dragnilar - Doesn't scale with skill level
			valueAbility += thePlayer.AddSlotBonusForSkillFloat(S_Sword_s08, 2);
		}
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(item, nmKey)); 
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(item, nmKey)); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if (nmKey == 'human_exp_bonus_when_fatal' || nmKey == 'nonhuman_exp_bonus_when_fatal') 
	{
		sp = thePlayer.GetAttributeValue(nmKey);

		valueStr = NoTrailZeros(RoundMath(CalculateAttributeValue(sp) * 100)) + " %";
	}
	else if (nmKey == 'area_nml') 
	{
		if (!thePlayer.HasAbility(nmKey))
			locKey = "";
		else
		{
			
			
		}
	}
	else if (nmKey == 'area_novigrad') 
	{
		if (!thePlayer.HasAbility(nmKey))
			locKey = "";
		else
		{
			
			
		}
	}
	else if (nmKey == 'area_skellige') 
	{
		if (!thePlayer.HasAbility(nmKey))
			locKey = "";
		else
		{
			
			
		}
	}
	
	final_name = GetLocStringByKeyExt(locKey); if ( final_name == "#" ) { final_name = ""; }
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr );
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	statObject.SetMemberFlashString("itemColor", "Red");
	
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function AddCharacterStatU2(tag : string, nmKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var curStats:SPlayerOffenseStats;
	var statObject : CScriptedFlashObject;
	var valueStr : string;
	var valueAbility, maxHealth, curHealth : float;
	var sp : SAbilityAttributeValue;
	var final_name : string;
	var item : SItemUniqueId;

	statObject = flashMaster.CreateTempFlashObject();
	
	if ( nmKey == 'silver_desc_poinsonchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_poinsonchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( nmKey == 'silver_desc_bleedingchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_bleedingchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( nmKey == 'silver_desc_burningchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_burningchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( nmKey == 'silver_desc_confusionchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_confusionchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( nmKey == 'silver_desc_freezingchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_freezingchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( nmKey == 'silver_desc_staggerchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_staggerchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	}
	else if ( nmKey == 'steel_desc_poinsonchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_poinsonchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( nmKey == 'steel_desc_bleedingchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_bleedingchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( nmKey == 'steel_desc_burningchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_burningchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( nmKey == 'steel_desc_confusionchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_confusionchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( nmKey == 'steel_desc_freezingchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_freezingchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( nmKey == 'steel_desc_staggerchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_staggerchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	}
	
	final_name = GetLocStringByKeyExt(locKey); if ( final_name == "#" ) { final_name = ""; }
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr );
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function GetEquippedCrossbowDamage():float
{
	var equippedBolt		  : SItemUniqueId;
	var equippedCrossbow	  : SItemUniqueId;
	var crossbowPower         : SAbilityAttributeValue;
	var crossbowStatValueMult : float;
	var primaryStatLabel      : string;
	var primaryStatValue      : float;
	var silverDamageValue	  : float;
	var min, max 			  : SAbilityAttributeValue;
	
	GetWitcherPlayer().GetItemEquippedOnSlot(EES_RangedWeapon, equippedCrossbow);
	if (!thePlayer.inv.IsIdValid(equippedCrossbow))
	{
		return 0;
	}
	
	crossbowPower = thePlayer.inv.GetItemAttributeValue(equippedCrossbow, 'attack_power');
	if(thePlayer.CanUseSkill(S_Perk_02))
	{				
		crossbowPower += thePlayer.GetSkillAttributeValue(S_Perk_02, PowerStatEnumToName(CPS_AttackPower), false, true);
	}
	//Dragnilar - Crossbow Mastery increases crossbow damage
	if(thePlayer.CanUseSkill(S_Sword_s13))
	{
		crossbowPower += thePlayer.GetSkillAttributeValue(S_Sword_s13, PowerStatEnumToName(CPS_AttackPower), false, true) * 
			(thePlayer.GetSkillLevel(S_Sword_s13) + thePlayer.AddSlotBonusForSkillInt(S_Sword_s13, 1)) * thePlayer.GetSkillLevel(S_Sword_s13);
	}
	if ( thePlayer.HasBuff(EET_Mutagen05) && (thePlayer.GetStat(BCS_Vitality) == thePlayer.GetStatMax(BCS_Vitality)) )
	{
		crossbowPower += thePlayer.GetAttributeValue('damageIncrease');
	}
	crossbowPower += thePlayer.GetPowerStatValue(CPS_AttackPower);
	
	if (crossbowStatValueMult == 0)
	{
		
		crossbowStatValueMult = 1;
	}
	GetWitcherPlayer().GetItemEquippedOnSlot(EES_Bolt, equippedBolt);
	if (thePlayer.inv.IsIdValid(equippedBolt))
	{
		thePlayer.inv.GetItemPrimaryStat(equippedBolt, primaryStatLabel, primaryStatValue);
		silverDamageValue = CalculateAttributeValue(GetWitcherPlayer().GetInventory().GetItemAttributeValue(equippedBolt, theGame.params.DAMAGE_NAME_SILVER));
	}
	else
	{
		thePlayer.inv.GetItemStatByName('Bodkin Bolt', 'PiercingDamage', primaryStatValue);
		thePlayer.inv.GetItemStatByName('Bodkin Bolt', 'SilverDamage', silverDamageValue);
	}
	
	
	if( GetWitcherPlayer().IsMutationActive( EPMT_Mutation9 ) )
	{
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation9', 'damage', min, max );
		primaryStatValue += min.valueAdditive;
		silverDamageValue += min.valueAdditive;
	}
	
	primaryStatValue = (primaryStatValue + crossbowPower.valueBase) * crossbowPower.valueMultiplicative + crossbowPower.valueAdditive;
	silverDamageValue = (silverDamageValue + crossbowPower.valueBase) * crossbowPower.valueMultiplicative + crossbowPower.valueAdditive;
	
	return (primaryStatValue + silverDamageValue) / 2;
}