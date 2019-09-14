
//zur13 modSSS mutTabs
function SSS_GetFirstAvailableMutagenSlot(curSlot : EEquipmentSlots, player : W3PlayerWitcher) : EEquipmentSlots
{
	var i      : int;
	var slot   : EEquipmentSlots;
	
	slot = curSlot;
	if( SSS_TargetMutagenSlotsTabbed() )
	{
		for( i = EES_SkillMutagen5; i <= EES_SkillMutagen48; i+=1 )
		{
			if(!player.IsAnyItemEquippedOnSlot(i))
			{
				slot = i;
			}
		}
	}
	return slot;
}

// abstract class W3GuiBaseInventoryComponent
//zur13 modSSS mutTabs
function SSS_IsItemEquippedInAdditionalMutagenSlot( item : SItemUniqueId , gui : W3GuiBaseInventoryComponent ) : bool
{
	var slotType 			  : EEquipmentSlots;
	
	//slotType = gui.GetCurrentSlotForItem( item );
	slotType = GetWitcherPlayer().GetItemSlot( item );
	if( SSS_IsNewMutagenSlot(slotType) )
	{
		return true;
	}
	return false;
}
