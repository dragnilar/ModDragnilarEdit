/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Mutagen40_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen40;
	default dontAddAbilityOnTarget = true;
	
	public function GetProtection(dmgType : name, isDoT : bool, out bonusResist : float, out bonusReduct : float)
	{
		var res : ECharacterDefenseStats;
		var atts : array<name>;
		var min, max : SAbilityAttributeValue;
		var i : int;
		var dm : CDefinitionsManagerAccessor;
		var pointRes, percRes : name;
		
		bonusResist = 0;
		bonusReduct = 0;	
		
		res = GetResistForDamage(dmgType, isDoT);
		pointRes = ResistStatEnumToName(res, true);
		percRes = ResistStatEnumToName(res, false);
		
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributes(abilityName, atts);
		
		
		for(i=0; i<atts.Size(); i+=1)
		{
			if(pointRes == atts[i])
			{
				dm.GetAbilityAttributeValue(abilityName, atts[i], min, max);
				bonusReduct = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
			}
			else if(percRes == atts[i])
			{
				dm.GetAbilityAttributeValue(abilityName, atts[i], min, max);
				bonusResist = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
			}
		}
	}
}