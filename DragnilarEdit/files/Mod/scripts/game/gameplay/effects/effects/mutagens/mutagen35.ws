/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Mutagen35_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen35;
	default dontAddAbilityOnTarget = true;

	public function GetMonsterDamageBonus(mc : EMonsterCategory) : SAbilityAttributeValue
	{
		var min, max : SAbilityAttributeValue;
		var attName : name;
		
		attName = MonsterCategoryToAttackPowerBonus(mc);
		
		if(!IsNameValid(attName))
			return min;
			
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, attName, min, max);
		return GetAttributeRandomizedValue(min, max);
	}
}