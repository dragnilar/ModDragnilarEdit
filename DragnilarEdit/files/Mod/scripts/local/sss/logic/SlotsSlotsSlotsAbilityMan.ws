function SSS_BaseSlotsCount():int
{
	return 16;
}

function SSS_SkillSlotsPerMutagenGroup():int
{
	return 3;
}

function SSS_DeSynergyGroupNum():int
{
	return 999;
}

function SSS_FirstAdditionalMutagenGroupNum():int
{
	return 6;
}

function SSS_CheckRequiredReinit(isFromLoad:bool) : bool
{	
	var abMgr : W3PlayerAbilityManager;
	var res   : bool;
	abMgr = (W3PlayerAbilityManager)thePlayer.abilityManager;
	res = false;
	if(isFromLoad && abMgr.SSS_IsMutationSlotsInitRequired() || SSS_GetTabsCountFromSlotsCount() < 1 || SSS_IsExistingSkillSlotsInconsistent() || abMgr.SSS_IsMutagenBonusesArrayIncorrect() )
	{
		//reinit from scratch
		//((W3PlayerWitcher)thePlayer).ResetCharacterDev();
		abMgr.SSS_UnequipAllSkills();
		SSS_UnequipAllMutagens();
		SSS_ReInitSkillSlots(12);
		((W3PlayerAbilityManager)thePlayer.abilityManager).SSS_UpdateSkillSlotsLocks();
		((W3PlayerAbilityManager)thePlayer.abilityManager).SSS_UpdateMutagenSlotsLock();
		res = true;
	}
	
	if( SSS_TargetSlotsTabs() != SSS_GetTabsCountFromSlotsCount()) 
	{
		abMgr.SSS_UnequipAllSkills();
		SSS_UnequipAllMutagens();
		SSS_ReInitSkillSlots(12);
		SSS_ChangeSkillSlotsCount();
		((W3PlayerAbilityManager)thePlayer.abilityManager).SSS_UpdateSkillSlotsLocks();
		((W3PlayerAbilityManager)thePlayer.abilityManager).SSS_UpdateMutagenSlotsLock();
		res = true;
	}
	return res;
}

function SSS_IsExistingSkillSlotsInconsistent() : bool
{
	// check if existing skill slots are inconsistent with the current config
	var i, j, k, groupID, groupCounter : int;

	var skillSlots         : array<SSkillSlot>;
	var slotsCount 	       : int;
	
	skillSlots = thePlayer.GetSkillSlots();
	slotsCount = skillSlots.Size();
	
	groupCounter = 0;
	groupID = skillSlots[0].groupID;
	
	for(i=0; i<skillSlots.Size(); i+=1)
	{
		if ( skillSlots[i].groupID != 5 && skillSlots[i].id < SSS_TargetFirstNonSynergySlot() )
		{
			
			//Check old version skill slots array
			if( groupID != skillSlots[i].groupID || skillSlots[i].groupID == SSS_DeSynergyGroupNum() )
			{
				groupID = skillSlots[i].groupID;
				groupCounter = 0;
			}
			groupCounter += 1;
			if( groupCounter > 3 )
			{
				// found more than 3 skill slots from one group in a row 
				// current array was created by an old Slots mod version
				// should recreate skill slots array
				return true;
			}
		}
		if( skillSlots[i].id >= SSS_TargetFirstNonSynergySlot() && skillSlots[i].groupID != SSS_DeSynergyGroupNum() )
		{
			// the SSS_DeSynergyGroupNum was decreased, need to reinit skill slots
			return true;
		}
		if( skillSlots[i].id < SSS_TargetFirstNonSynergySlot() && skillSlots[i].groupID == SSS_DeSynergyGroupNum() )
		{
			// non synergy slot found where it shouldn't
			// the SSS_DeSynergyGroupNum was increased, need to reinit skill slots
			return true;
		}
		
		//zur13 modSSS mutTabs
		if( SSS_TargetMutagenSlotsTabbed() && i >= SSS_BaseSlotsCount() && skillSlots[i].groupID < SSS_FirstAdditionalMutagenGroupNum() )
		{
			// user wants tabbed mutagen slots but skill slots was generated for not tabbed
			return true;
		}
		//zur13 modSSS mutTabs
		if( !SSS_TargetMutagenSlotsTabbed() && i >= SSS_BaseSlotsCount() && skillSlots[i].groupID >= SSS_FirstAdditionalMutagenGroupNum() && skillSlots[i].groupID != SSS_DeSynergyGroupNum() )
		{
			// user wants non-tabbed mutagen slots but skill slots was generated for tabbed
			return true;
		}
	}
	
	//Check skill slots array has different level requirements
	if( slotsCount >= 18 )
	{
		i = skillSlots[17].unlockedOnLevel-skillSlots[16].unlockedOnLevel;
		if( i != SSS_TargetSkillSlotLevelRequirementsStep() || skillSlots[16].unlockedOnLevel != SSS_TargetSkillSlotLevelRequirementsBase() )
		{
			return true;
		}
	}
	
	return false;
}

function SSS_IsMutagenEquipmentSltsBroken() : bool
{
	var i, j, k : int;
	var item : SItemUniqueId;
	var slotsCount 	       : int;
	var mutagenSlots 	   : array<SMutagenSlot>; //zur13 modSSS mutTabs
	//zur13 modSSS mutTabs
	//try  to fix the case when other mod added equipment slots and moved additional mutagen slot indexes
	mutagenSlots = thePlayer.GetPlayerSkillMutagens();
	for(i=0; i<mutagenSlots.Size(); i+=1)
	{
		j = (EES_SkillMutagen5+i-4);
		k = mutagenSlots[i].equipmentSlot;
		if( i >= 4 && k != j )
		{
			return true;
		}
	}
	for(i=0; i<mutagenSlots.Size(); i+=1)
	{
		j = (EES_SkillMutagen5+i-4);
		
		if( i >= 4 )
		{
			if(GetWitcherPlayer().GetItemEquippedOnSlot(mutagenSlots[i].equipmentSlot, item))
			{
				if( mutagenSlots[i].item != item )
				{
					return true;
				}
			}
		}
	}
	return false;
}

function SSS_UnequipAllItems(optional itemSlots : array<SItemUniqueId>, optional spawnPlayerEntity : W3PlayerWitcher)
{
	// this method unequipes items from all slots
	var i : int;
	var eqSlots : array<SItemUniqueId>;
	var witcher : W3PlayerWitcher;
	//GetWitcherPlayer().UnequipItemFromSlot(EES_SkillMutagen1);
	//GetWitcherPlayer().UnequipItemFromSlot(EES_SkillMutagen2);
	//GetWitcherPlayer().UnequipItemFromSlot(EES_SkillMutagen3);
	//GetWitcherPlayer().UnequipItemFromSlot(EES_SkillMutagen4);
	
	//for(i=1; i <= EnumGetMax('EEquipmentSlots') ; i+=1) //zur13 modSSS mutTabs
	//{
	//	GetWitcherPlayer().UnequipItemFromSlot(i);
	//}
	if( spawnPlayerEntity ) 
	{
		witcher = spawnPlayerEntity;
	}
	else
	{
		witcher = GetWitcherPlayer();
	}
	
	eqSlots = witcher.GetEquippedItems();
	if( itemSlots.Size() > 0 ) 
	{
		eqSlots = itemSlots;
	}
	
	
	for(i=EES_Potion4+1; i < eqSlots.Size(); i+=1) //zur13 modSSS mutTabs2
	{
		witcher.UnequipItem(eqSlots[i]);
	}
}

function SSS_UnequipAllMutagens()
{
	// this method unequipes all mutagens
	var i : int;
	GetWitcherPlayer().UnequipItemFromSlot(EES_SkillMutagen1);
	GetWitcherPlayer().UnequipItemFromSlot(EES_SkillMutagen2);
	GetWitcherPlayer().UnequipItemFromSlot(EES_SkillMutagen3);
	GetWitcherPlayer().UnequipItemFromSlot(EES_SkillMutagen4);
	
	for(i=EES_SkillMutagen5; i <= EES_SkillMutagen48; i+=1) //zur13 modSSS mutTabs
	{
		GetWitcherPlayer().UnequipItemFromSlot(i);
	}

}

function SSS_IsMutagenSlotsUnlocked() : bool
{
	// check if currently all existing mutagen slots unlocked
	var idx				  : int;
	var skillMutagenSlots : array<SMutagenSlot>;
	var currentMutSlot	  : SMutagenSlot;
	var mutCount		  : int;
		
	skillMutagenSlots = GetWitcherPlayer().GetPlayerSkillMutagens();
	mutCount = skillMutagenSlots.Size();
	
	for (idx = 0; idx < mutCount; idx+=1)
	{
		currentMutSlot = skillMutagenSlots[idx];
		if( currentMutSlot.unlockedAtLevel != 1 )
		{
			return false;
		}
	}
	return true;
}

function SSS_ChangeSkillSlotsCount()
{
	// set skill slots count accordingly to the target tabs count
	var i, targetTabs : int;
	var abMgr : W3PlayerAbilityManager;
	abMgr = (W3PlayerAbilityManager)thePlayer.abilityManager;
	
	targetTabs = SSS_TargetSlotsTabs();
	
	for( i = 2; i <= targetTabs; i += 1 )
	{
		SSS_AddTabSkillSlots();
	}
}

function SSS_ReInitSkillSlots(selectedSlotsCount:int)
{
	var abMgr          : W3PlayerAbilityManager;
	
	abMgr = (W3PlayerAbilityManager)thePlayer.abilityManager;
	abMgr.SSS_ClearSkillSlots(selectedSlotsCount);
	abMgr.SSS_InitSkillSlots();
	abMgr.SSS_CheckAndInitMutationsSkillSlots();
	abMgr.SSS_UpdateSkillSlotsLocks();
	((W3PlayerAbilityManager)thePlayer.abilityManager).SSS_UpdateMutagenSlotsLock();
}


function SSS_AddTabSkillSlots()
{
	// Add skill slots for one tab
	var slot : SSkillSlot;
	var dm : CDefinitionsManagerAccessor;
	var main : SCustomNode;
	var i, g, k, lastSkillSlotIdx, lastSkillSlotId : int;
	var abMgr          : W3PlayerAbilityManager;
	
	abMgr = (W3PlayerAbilityManager)thePlayer.abilityManager;
	
	lastSkillSlotIdx = abMgr.GetSkillSlotsCount()-1;
	lastSkillSlotId =  abMgr.GetSkillSlotIDFromIndex(lastSkillSlotIdx);
	
	g = 1; // group
	k = 1; // slot in group
	
	for( i = 0; i < SSS_SkillSlotsPerAdditionalTab(); i += 1 )
	{
		slot.id = lastSkillSlotId+i+1;
		slot.unlockedOnLevel = SSS_TargetSkillSlotLevelRequirementsBase()+(slot.id-17)*SSS_TargetSkillSlotLevelRequirementsStep();
		
		slot.groupID = i / 3 + 1; // default non tabbed
		
		if( slot.id >= SSS_TargetFirstNonSynergySlot() )
		{
			slot.groupID = SSS_DeSynergyGroupNum();
		} 
		else if ( SSS_TargetMutagenSlotsTabbed() )
		{
			// tabbed
			slot.groupID = (slot.id-17)/3 + SSS_FirstAdditionalMutagenGroupNum() ; //zur13 modSSS mutTabs
		}
		
		//if( i == 17) {slot.groupID = 1;}
		//if( i == 18) {slot.groupID = 1;}
		//if( i == 19) {slot.groupID = 1;}
		
		//if( i == 20) {slot.groupID = 2;}
		
		//if( i == 28) {slot.groupID = 4;}
		
		abMgr.SSS_AddSkillSlot(slot);
		
		slot.id = -1;
		slot.unlockedOnLevel = 0;
		slot.groupID = -1;
	}
}