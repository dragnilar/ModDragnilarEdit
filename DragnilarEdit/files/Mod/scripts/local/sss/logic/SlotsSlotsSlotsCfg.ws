function SSS_TargetSlotsTabs(): int
{
	// Get the desired amount of skill slot pages
	// The values from ASlotsSlotsSlotsUserCfg.ws has a highest priority
	var targetTabs : int;
	
	targetTabs = SSS_SlotTabsCount();
	
	if(!SSS_IsManualCfg())
	{	
		targetTabs = FloorF(StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue( 'modSSS1', 'modSSS_TabCnt' )));
	}
	
	if(targetTabs<1)
	{
		targetTabs = 1;
	}
	
	if(targetTabs>12)
	{
		targetTabs = 12;
	}
	return targetTabs;
}

function SSS_TargetMutagenSlotsTabbed(): bool
{
	// Tabs affect mutagen slots state true/false
	// The values from ASlotsSlotsSlotsUserCfg.ws has a highest priority
	var res : bool;
	res = false;
	
	if(SSS_MutagenSlotsTabbed()==1)
	{
		res = true;
	}
	
	if(!SSS_IsManualCfg())
	{	
		res = theGame.GetInGameConfigWrapper().GetVarValue( 'modSSS1', 'modSSS_MutTabbed' );
	}
	
	return res;
	
}

function SSS_TargetIsMasterControlsMaxActiveMutations(): bool
{
	// Get the desired Master mutation level affects max active mutations state true/false
	// The values from ASlotsSlotsSlotsUserCfg.ws has a highest priority
	var res : bool;
	res = false;
	
	if(SSS_MaxActiveMutations()<=0)
	{
		res = true;
	}
	
	if(!SSS_IsManualCfg())
	{	
		res = theGame.GetInGameConfigWrapper().GetVarValue( 'modSSS1', 'modSSS_ActMutationsByMaster' );
	}
	
	return res;
}

function SSS_TargetMaxActiveMutations(): int
{
	var res : int;
	res = SSS_MaxActiveMutations();	
	
	if(!SSS_IsManualCfg())
	{	
		res = FloorF(StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue( 'modSSS1', 'modSSS_ActMutations' )));
	}
	
	if( res < 1 )
	{
		res = 1;
	}
	return res;
}

function SSS_TargetUnlockSkillSlots(): bool
{
	// Get the desired skill slots unlock state true/false
	// The values from ASlotsSlotsSlotsUserCfg.ws has a highest priority
	var res : bool;
	res = false;
	
	if(SSS_UnlockAllSkillSlots()==1)
	{
		res = true;
	}
	
	if(!SSS_IsManualCfg())
	{	
		res = theGame.GetInGameConfigWrapper().GetVarValue( 'modSSS2', 'modSSS_UnlockSkillSlots' );
	}
	
	return res;
}

function SSS_TargetUnlockMutagenSlots(): bool
{
	// Get the desired mutagen slots unlock state true/false
	// The values from ASlotsSlotsSlotsUserCfg.ws has a highest priority
	var res : bool;
	res = false;
	
	if(SSS_UnlockMutagenSlots()==1)
	{
		res = true;
	}
	
	if(!SSS_IsManualCfg())
	{	
		res = theGame.GetInGameConfigWrapper().GetVarValue( 'modSSS2', 'modSSS_UnlockMutagenSlots' );
	}
	
	return res;
}

function SSS_TargetDisableMutationSkillSlotsColorRestrictions(): bool
{
	// Get the desired disable mutagen skill slots color restriction state true/false
	// The values from ASlotsSlotsSlotsUserCfg.ws has a highest priority
	var res : bool;
	res = false;
	
	if(SSS_DisableMutationSkillSlotsColorRestrictions()==1)
	{
		res = true;
	}
	
	if(!SSS_IsManualCfg())
	{	
		res = theGame.GetInGameConfigWrapper().GetVarValue( 'modSSS1', 'modSSS_DisableMutSkillSlotsColorRestriction' );
	}
	
	return res;
}

function SSS_TargetDisableMutagenSynergyColorRestrictions(): bool
{
	// Get the desired disable mutagen skill slots color restriction state true/false
	// The values from ASlotsSlotsSlotsUserCfg.ws has a highest priority
	var res : bool;
	res = false;
	
	if(SSS_DisableMutagenSynergyColorRestrictions()==1)
	{
		res = true;
	}
	
	if(!SSS_IsManualCfg())
	{	
		res = theGame.GetInGameConfigWrapper().GetVarValue( 'modSSS3', 'modSSS_DisableMutagenSynergyColorRestrictions' );
	}
	
	return res;
}

function SSS_TargetRememberLastOpenedTab(): bool
{
	// Get the desired remember last used tab state true/false
	// The values from ASlotsSlotsSlotsUserCfg.ws has a highest priority
	var res : bool;
	res = false;
	
	if(SSS_RememberLastOpenedTab()==1)
	{
		res = true;
	}
	
	if(!SSS_IsManualCfg())
	{	
		res = theGame.GetInGameConfigWrapper().GetVarValue( 'modSSS1', 'modSSS_RememberLastOpenedTab' );
	}
	
	return res;
}

function SSS_TargetSkillSlotLevelRequirementsStep(): int
{
	var res : int;
	res = SSS_AdditionalSkillSlotLevelRequirementsStep();
	
	if(!SSS_IsManualCfg())
	{	
		res = FloorF(StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue( 'modSSS2', 'modSSS_SkillSlotLevelRequirementStep' )));
	}
	
	if( res < 0 )
	{
		res = 0;
	}
	return res;
}


function SSS_TargetSkillSlotLevelRequirementsBase(): int
{
	var res : int;
	res = SSS_AdditionalSkillSlotLevelRequirementsBaseLevel();
	
	if(!SSS_IsManualCfg())
	{	
		res = FloorF(StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue( 'modSSS2', 'modSSS_SkillSlotLevelRequirementBase' )));
	}
	
	if( res < 1 )
	{
		res = 1;
	}
	return res;
}


function SSS_TargetMutSlotLevelRequirementsStep(): int
{
	var res : int;
	res = SSS_AdditionalMutagenSlotLevelRequirementsStep();
	
	if(!SSS_IsManualCfg())
	{	
		res = FloorF(StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue( 'modSSS2', 'modSSS_MutagenSlotLevelRequirementStep' )));
	}
	
	if( res < 0 )
	{
		res = 0;
	}
	return res; // default 7
}


function SSS_TargetMutSlotLevelRequirementsBase(): int
{
	var res : int;
	res = SSS_AdditionalMutagenSlotLevelRequirementsBaseLevel();
	
	if(!SSS_IsManualCfg())
	{	
		res = FloorF(StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue( 'modSSS2', 'modSSS_MutagenSlotLevelRequirementBase' )));
	}
	
	if( res < 1 )
	{
		res = 1;
	}
	return res; // default 28
}

function SSS_TargetFirstNonSynergySlot(): int
{
	var res : int;
	var roundMod : int;
	var tab, group: int;
	
	res = SSS_FirstNonSynergySlot();
	
	if(!SSS_IsManualCfg())
	{	
		tab = StringToInt(theGame.GetInGameConfigWrapper().GetVarValue( 'modSSS3', 'modSSS_FirstNonSynergyTab' ));
		group = StringToInt(theGame.GetInGameConfigWrapper().GetVarValue( 'modSSS3', 'modSSS_FirstNonSynergyGroup' ));
		res = 17 + Abs(tab - 2) * 12 + Abs(group - 1 ) * 3;
	}
	
	if( res < 17 )
	{
		res = 999999;
	}
	else
	{
		roundMod = (res - SSS_BaseSlotsCount() - 1) % SSS_SkillSlotsPerMutagenGroup();
		res = res - roundMod;
	}
	return res;
}