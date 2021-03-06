/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class W3GuiEnchantingInventoryComponent extends W3GuiBaseInventoryComponent
{
	private var REQUIRED_SLOTS_COUNTS : int;
	default REQUIRED_SLOTS_COUNTS = 3;
	
	public function CheckSlotsCount( item : SItemUniqueId ):bool
	{
		var aerondightLevel : int;

		CheckItem(item);
		
		//Dragnilar - Aerondight level 4 cannot be enchanted since it has Severence built into it.
		if(_inv.IsAerondight(item))
		{
			aerondightLevel = RoundMath(CalculateAttributeValue( thePlayer.GetInventory().GetItemAttributeValue( item, 'item_level_min' ) ));
			aerondightLevel = aerondightLevel / 50;
			if(aerondightLevel >= 4)
				return false;
		}

		return _inv.GetItemEnhancementSlotsCount( item ) >= REQUIRED_SLOTS_COUNTS;
	}
	
	//Dragnilar - override from Enchanting No Limits
	public function ShouldShowItem( item : SItemUniqueId ) : bool
	{
		var catName:name;
		
		catName = _inv.GetItemCategory(item);
		return super.ShouldShowItem(item) && (catName== 'steelsword' || catName== 'silversword' || catName== 'armor' || catName == 'boots' || catName == 'gloves' || catName == 'pants') && !_inv.ItemHasTag(item, 'SecondaryWeapon');
	}
	
	// override
	public function SetInventoryFlashObjectForItem( item : SItemUniqueId, out flashObject : CScriptedFlashObject) : void
	{
		var isEquipped:bool;
		var isNotEnoughSockets:bool;
		var slotsCount:int;
		
		super.SetInventoryFlashObjectForItem(item, flashObject);
		
		slotsCount = _inv.GetItemEnhancementSlotsCount( item );

		CheckItem(item);

		isNotEnoughSockets = slotsCount < REQUIRED_SLOTS_COUNTS;
		isEquipped = GetWitcherPlayer().IsItemEquipped(item);
		
		flashObject.SetMemberFlashString( "itemName", GetLocStringByKeyExt( _inv.GetItemLocalizedNameByUniqueID( item ) ) );
		flashObject.SetMemberFlashString( "description", GetLocStringByKeyExt("panel_enchanting_warning_not_enough_sockets") + " " + slotsCount + " / " + REQUIRED_SLOTS_COUNTS);
		flashObject.SetMemberFlashBool( "isEquipped",  isEquipped);
		flashObject.SetMemberFlashBool( "isNotEnoughSockets",  isNotEnoughSockets);
		flashObject.SetMemberFlashBool( "disableAction", isNotEnoughSockets);
		flashObject.SetMemberFlashUInt( "enchantmentId", NameToFlashUInt(_inv.GetEnchantment(item)));
		
	}

	private function CheckItem(item : SItemUniqueId)
	{
		var catName : name;

		//Dragnilar - Checks if the item is a pants, boots or gloves item and set slots count to 2
		catName = _inv.GetItemCategory(item);
		if (catName == 'boots' || catName == 'pants' || catName == 'gloves')
		{
			REQUIRED_SLOTS_COUNTS = 0;
		}
	}
}