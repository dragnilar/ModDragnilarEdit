function SSS_PrevTab(characterMenuRef : CR4CharacterMenu)
{
	var tab: int;
	tab = characterMenuRef.SSS_DecrementAndGetCurrrentTab();
	characterMenuRef.SSS_SetTabsText(tab+"/"+SSS_GetTabsCountFromSlotsCount());
}

function SSS_NextTab(characterMenuRef : CR4CharacterMenu)
{
	var tab: int;
	tab = characterMenuRef.SSS_IncrementAndGetCurrrentTab();
}



function SSS_SkillSlotsPerAdditionalTab():int
{
	//skill slots per tab (except first tab which contains 4 additional skill slots added by mutation)
	return 12;
}

function SSS_GetTabsCountFromSlotsCount():int
{
	// return tabs count or -1 if skill slots does not correspond to integer tabs count
	var sltCnt, res : int;
	
	var abMgr : W3PlayerAbilityManager;
	abMgr = (W3PlayerAbilityManager)thePlayer.abilityManager;
	
	sltCnt = abMgr.GetSkillSlotsCount();
	if(sltCnt < SSS_BaseSlotsCount())
	{
		res = 1;
	}
	else 
	{
		res = 1;
		sltCnt -= SSS_BaseSlotsCount(); // first tab slots
		if( sltCnt % SSS_SkillSlotsPerAdditionalTab() != 0)
		{
			res = -1;
		}
		else
		{
			res = (sltCnt / SSS_SkillSlotsPerAdditionalTab()) +1;
		}
	}
	return res;
}

function SSS_GetTabFirstSlotIndex(tab:int):int
{
	// return tabs count
	var res : int;
	
	res = 0; // first slot for invalid input
	
	if( tab == 1 )
	{
		return res; 
	}
	
	if( tab > 1 )
	{
		res = SSS_BaseSlotsCount() + SSS_SkillSlotsPerAdditionalTab() * ( tab - 2 );
	}
	return res;
}

function SSS_GetTabBySlot(slotID:int):int
{
	// return tabs count
	var res, tmp : int;
	
	tmp = slotID-1; //slot index
	
	res = 1; // first tab
	
	if( slotID > 16 )
	{
		res = (tmp - SSS_BaseSlotsCount()) / SSS_SkillSlotsPerAdditionalTab() + 2;
	}
	
	return res;
}

function SSS_ConvertSlotIDToTabSlotID(slotID:int, tab:int):int
{
	// convert slot id to tab slot id
	var res, tmp : int;
	res = slotID;
	if( slotID < BSS_SkillSlot1 || slotID > BSS_SkillSlot4 )
	{
		// do not convert BSS_SkillSlots
		tmp = SSS_GetTabFirstSlotIndex(tab);
		
		res = res - tmp;
	}
	return res;
}

function SSS_ConvertTabSlotIDToSlotID(tabSlotID:int, tab:int):int
{
	// convert slot id to tab slot id
	var res, tmp : int;
	res = tabSlotID;
	if( tabSlotID < BSS_SkillSlot1 || tabSlotID > BSS_SkillSlot4 )
	{	
		// do not convert BSS_SkillSlots
		tmp = SSS_GetTabFirstSlotIndex(tab);
		
		res = res + tmp;
	}
	return res;
}

function SSS_IsSlotOnCurrentTab(slotID:int, characterMenuRef : CR4CharacterMenu):bool
{
	// convert slot id to tab slot id
	var res, tmp : int;
	var tab	               : int;
	var tabFirstSlotId     : int;
	var nextTabFirstSlotId : int;
	
	tab = characterMenuRef.SSS_GetCurrentTab();
	tabFirstSlotId = SSS_GetTabFirstSlotIndex( tab ) + 1;
	nextTabFirstSlotId = SSS_GetTabFirstSlotIndex( tab + 1 ) + 1;
	
	if( tab == 1 && slotID < SSS_GetTabFirstSlotIndex( tab + 1 ) + 1 )
	{
		return true;
	}
	
	if( slotID >= BSS_SkillSlot1 && slotID <= BSS_SkillSlot4 )
	{
		return true;
	}
	
	if( slotID >= SSS_GetTabFirstSlotIndex( tab ) + 1 && slotID <= SSS_GetTabFirstSlotIndex( tab + 1 ) + 1 )
	{
		return true;
	}
	
	return false;
}

function SSS_GetTabFirstMutagenIdx(tab:int):int
{
	// return tabs count
	var res : int;
	res = 0; // first slot for invalid input
	
	if( tab == 1 )
	{
		return res; 
	}
	
	if( tab > 1 && SSS_TargetMutagenSlotsTabbed() )
	{
		res = (tab - 1) * 4;
	}
	return res;
}

function SSS_ConvertMutSlotIDToFlash(eqSlot:int):int
{
	// convert mutagen slot id to tab slot id
	var res, tmp : int;
	res = eqSlot;
	
	if ( eqSlot<=EES_SkillMutagen4 )
	{
		res = eqSlot;
	}
	else
	{
		tmp = (eqSlot-EES_SkillMutagen5) % 4;
		if( tmp == 0 )
		{
			res = EES_SkillMutagen1;
		}
		else if( tmp == 1 )
		{
			res = EES_SkillMutagen2;
		}
		else if( tmp == 2 )
		{
			res = EES_SkillMutagen3;
		}
		else if( tmp == 3 )
		{
			res = EES_SkillMutagen4;
		}
	}
	
	return res;
}

function SSS_ConvertMutSlotIDFromFlash(eqSlot:int, tab:int):int
{
	// convert tab mutagen slot id to mutagen slot id
	var res, tmp : int;
	res = eqSlot;
	
	if ( tab != 1 && SSS_TargetMutagenSlotsTabbed() )
	{
		res = EES_SkillMutagen5 + (tab-2)*4 + (eqSlot-EES_SkillMutagen1) ;
	}
	
	return res;
}

function SSS_ConvertMutGroupIDFromFlash(groupId:int, tab:int):int
{
	// convert tab mutagen group id to real mutagen group id
	var res, tmp : int;
	res = groupId;
	
	if ( tab != 1 && SSS_TargetMutagenSlotsTabbed() )
	{
		res = SSS_FirstAdditionalMutagenGroupNum() + (tab-2)*4 + groupId - 1;
	}
	
	return res;
}

function SSS_GetMutageSlotColor(mutSlot : SMutagenSlot, characterMenuRef : CR4CharacterMenu, invComponent : CInventoryComponent):ESkillColor
{
	// this method disables synergy coloring by disabling mutagen slots colors
	var res, tmp : int;
	var tab	               : int;
	var tabFirstSlotId     : int;
	var nextTabFirstSlotId : int;
	var firstDisabledMutSlot: int;
	
	firstDisabledMutSlot = 9999999;
	
	tab = characterMenuRef.SSS_GetCurrentTab();
	tabFirstSlotId = SSS_GetTabFirstSlotIndex( tab ) + 1;
	nextTabFirstSlotId = SSS_GetTabFirstSlotIndex( tab + 1 ) + 1;
	
	if ( invComponent.IsIdValid(mutSlot.item) )
	{
		if( tab != 1 && SSS_TargetFirstNonSynergySlot() <  nextTabFirstSlotId && SSS_TargetFirstNonSynergySlot() >=  tabFirstSlotId )
		{
			// non synergy skill slot on current tab
			firstDisabledMutSlot = ( SSS_TargetFirstNonSynergySlot() - tabFirstSlotId ) / 4 + 1; //zur13 modSSS mutTabs XXX: SSS_TargetMutagenSlotsTabbed()
			if ( SSS_TargetMutagenSlotsTabbed() || mutSlot.skillGroupID < firstDisabledMutSlot )
			{
				return invComponent.GetSkillMutagenColor(mutSlot.item);
			}
		}
		else
		{
			return invComponent.GetSkillMutagenColor(mutSlot.item);
		}
	}
	
	return SC_None;
}

function SSS_OnConfigUI(characterMenuRef : CR4CharacterMenu)
{
	var slotCnt, forcedSlotCnt : int;
	var slotUnlState           : bool;
	characterMenuRef.tabChanging = true;
	//reinit required due to mutagen slots not init properly
	if(((W3PlayerAbilityManager)thePlayer.abilityManager).SSS_IsMutationSlotsInitRequired())
	{
		
		((W3PlayerAbilityManager)thePlayer.abilityManager).SSS_SetUnlockAllSkillSlots(false);
		//((W3PlayerWitcher)thePlayer).ResetCharacterDev();
		((W3PlayerAbilityManager)thePlayer.abilityManager).SSS_UnequipAllSkills();
		SSS_ReInitSkillSlots(12);
		SSS_CheckRequiredReinit(false);
		SSS_UpdateChMenuGraphics(characterMenuRef);
	} else {
		if( SSS_CheckRequiredReinit(false) ) 
		{
			SSS_UpdateChMenuGraphics(characterMenuRef);
		}
	}
	
	((W3PlayerAbilityManager)thePlayer.abilityManager).SSS_UpdateMutagenSlotsCount(); // only if needed
	
	slotUnlState = ((W3PlayerAbilityManager)thePlayer.abilityManager).unlockAllSkillSlots;

	if( SSS_TargetUnlockSkillSlots() != slotUnlState )
	{
		if(SSS_TargetUnlockSkillSlots())
		{
			//unlock
			((W3PlayerAbilityManager)thePlayer.abilityManager).SSS_SetUnlockAllSkillSlots(true);
			((W3PlayerAbilityManager)thePlayer.abilityManager).SSS_UpdateSkillSlotsLocks();
			((W3PlayerAbilityManager)thePlayer.abilityManager).SSS_UpdateMutagenSlotsLock();
			SSS_UpdateChMenuGraphics(characterMenuRef);
		}
		else
		{
			// lock
			((W3PlayerAbilityManager)thePlayer.abilityManager).SSS_SetUnlockAllSkillSlots(false);
			((W3PlayerAbilityManager)thePlayer.abilityManager).SSS_UpdateSkillSlotsLocks();
			((W3PlayerAbilityManager)thePlayer.abilityManager).SSS_UpdateMutagenSlotsLock();
			SSS_UpdateChMenuGraphics(characterMenuRef);
			
		}
	}
	
	if( SSS_IsMutagenSlotsUnlocked() != SSS_TargetUnlockMutagenSlots() )
	{
		((W3PlayerAbilityManager)thePlayer.abilityManager).SSS_UpdateMutagenSlotsLock();
	}
	((W3PlayerAbilityManager)thePlayer.abilityManager).SSS_UpdateSkillSlotsLocks();
	characterMenuRef.SSS_UpdateTabTextAndRefreshGUI();
	characterMenuRef.tabChanging = false;
}

function SSS_GetSkillTooltipStringSuffix(targetSkill : ESkill): string
{
	var oldSkillSlot2 : int;
	var oldSkillSlot3 : SSkillSlot;
	var oldSkillGroup3 : int;
	
	var equipedDesc  : string;
	var skillSlots   : array<SSkillSlot>;
	var slotsCount 	 : int;
	var visSlotNum 	 : int;
	
	oldSkillSlot2 = thePlayer.GetSkillSlotID(targetSkill);
	
	if( oldSkillSlot2 > 0 )
	{	
		visSlotNum = SSS_GetTabBySlot(oldSkillSlot2);
		equipedDesc = " ("+GetLocStringByKeyExt('modSSS_skill_tooltip_equipped_tab')+visSlotNum+")";
	}
	else
	{
		equipedDesc = "";
	}
	return equipedDesc;
}

function SSS_GetSkillTooltipSynergySufix(targetSkill : ESkill): string
{
	var oldSkillSlot2  : int;
	var oldSkillGroup2 : int;
	
	var synergySufix   : string;
	
	var mutagen 				: SItemUniqueId;
	var hasMutagen				: bool;
	var mutagenHasDifferentColor: bool;
	var mutagenSlot             : EEquipmentSlots;
	var mutagenSlotColor 	    : ESkillColor;
	
	mutagenHasDifferentColor = false;
	synergySufix = "";
	
	oldSkillSlot2 = thePlayer.GetSkillSlotID(targetSkill);
	//((W3PlayerAbilityManager)thePlayer.abilityManager).
	oldSkillGroup2 = ((W3PlayerAbilityManager)thePlayer.abilityManager).GetSkillGroupIdFromSkillSlotId(oldSkillSlot2);
	
	if( oldSkillSlot2 > 0 && oldSkillGroup2 > 0 )
	{
		hasMutagen = GetWitcherPlayer().GetItemEquippedOnSlot(thePlayer.GetMutagenSlotIDFromGroupID(oldSkillGroup2), mutagen);
		mutagenSlot = ((W3PlayerAbilityManager)thePlayer.abilityManager).SSS_GetMutagenSlotForGroupId(oldSkillGroup2);
		
		
		if(GetWitcherPlayer().GetItemEquippedOnSlot(mutagenSlot, mutagen))
			mutagenSlotColor = thePlayer.GetInventory().GetSkillMutagenColor( mutagen );
		
		
		if( !hasMutagen || mutagenSlotColor !=  ((W3PlayerAbilityManager)thePlayer.abilityManager).GetSkillColor(targetSkill) )
		{
			mutagenHasDifferentColor = true;
		}
		
		if( oldSkillSlot2 >= SSS_TargetFirstNonSynergySlot() || mutagenHasDifferentColor )
		{
			
			synergySufix = GetLocStringByKeyExt('modSSS_skill_tooltip_no_synergy');//"                                               (No Mutagen Synergy)";
		}
	
	}
	return synergySufix;
}

function SSS_GetItemTooltipSynergySufix(item : SItemUniqueId, characterMenuRef: CR4CharacterMenu): string
{
	var mutSlotIdx        : int;
	var skillMutagenSlots : array<SMutagenSlot>;
	var mutCount          : int;
	var mutSlot           : SMutagenSlot;
	var tabFirstMutSlot   : SMutagenSlot;
	
	var synergySufix : string;
	
	var tab	                 : int;
	var tabFirstSlotId       : int;
	var nextTabFirstSlotId   : int;
	var firstDisabledMutSlot : int;
	
	skillMutagenSlots = thePlayer.GetPlayerSkillMutagens();
	mutCount = skillMutagenSlots.Size();
		
	synergySufix = "";
	
	// find mutagen slot with current mutagen equipped
	mutSlotIdx = ((W3PlayerAbilityManager)thePlayer.abilityManager).SSS_GetMutagenSlotIndexFromItemId(item);
	
	
	if( mutSlotIdx >= 0 && mutSlotIdx < mutCount )
	{
		mutSlot = skillMutagenSlots[mutSlotIdx];
		
		firstDisabledMutSlot = SSS_TargetFirstNonSynergySlot();
		tab = characterMenuRef.SSS_GetCurrentTab();
		tabFirstSlotId = SSS_GetTabFirstSlotIndex( tab ) + 1;
		nextTabFirstSlotId = SSS_GetTabFirstSlotIndex( tab + 1 ) + 1;
		
		tabFirstMutSlot = skillMutagenSlots[SSS_GetTabFirstMutagenIdx(tab)];
		
		if( tab != 1 && SSS_TargetFirstNonSynergySlot() <  nextTabFirstSlotId )
		{
			// non synergy skill slot on current tab
			firstDisabledMutSlot = ( SSS_TargetFirstNonSynergySlot() - tabFirstSlotId ) / 3 + 1;
			if ( (mutSlot.skillGroupID-tabFirstMutSlot.skillGroupID+1) >= firstDisabledMutSlot || SSS_TargetFirstNonSynergySlot() <=  tabFirstSlotId)
			{
				synergySufix = GetLocStringByKeyExt('modSSS_item_tooltip_no_synergy');//"  (No Synergy)";
			}
		}
	}
	return synergySufix;
}

function SSS_UpdateChMenuGraphics(characterMenuRef: CR4CharacterMenu)
{
	var i : int;
	characterMenuRef.SSS_PopulateTabData(CharacterMenuTab_Sword);
	characterMenuRef.SSS_PopulateTabData(CharacterMenuTab_Signs);
	characterMenuRef.SSS_PopulateTabData(CharacterMenuTab_Alchemy);
	characterMenuRef.SSS_PopulateTabData(CharacterMenuTab_Perks);
	characterMenuRef.SSS_PopulateTabData(CharacterMenuTab_Mutagens);
	
	for(i = 1; i<13; i=i+1)
	{
		//characterMenuRef.SSS_UpdateAppliedSkill(i);
		characterMenuRef.SSS_Get_m_fxClearSkillSlot().InvokeSelfOneArg(FlashArgInt(i));
	}
	
	characterMenuRef.SSS_UpdateGroupsData();
	characterMenuRef.SSS_UpdateMutagens();
	characterMenuRef.SSS_UpdatePlayerStatisticsData();
	characterMenuRef.SSS_Get_m_fxPaperdollChanged().InvokeSelf();
	characterMenuRef.SSS_UpdateSkillPoints();
}
