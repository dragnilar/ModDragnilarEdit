
// ======================= playerAbilityManager ===============================

function SSS_IsMutationEquipped( mutationType : EPlayerMutationType, equippedMutations : array< EPlayerMutationType > ) : bool
{
	return equippedMutations.Contains(mutationType);
}

function SSS_CanEquipMutation(chMenu : CR4CharacterMenu , mutationType : EPlayerMutationType, equippedMutations : array< EPlayerMutationType > ) : bool
{
	var maxActive : int;
	
	maxActive = 999;
	
	if( SSS_TargetIsMasterControlsMaxActiveMutations() )
	{
		maxActive = ((W3PlayerAbilityManager)thePlayer.abilityManager).GetMasterMutationStage();
		if( maxActive <= 0 )
		{
			maxActive = 1;
		}
	} 
	else
	{
		maxActive = SSS_TargetMaxActiveMutations();
	}
	
	if( equippedMutations.Size() >= maxActive )
	{
		chMenu.OnPlaySoundEvent( "gui_global_denied" );
		return false;
	}
	return true;
}
// ========================== characterMenu ====================================

function SSS_UpdateMasterMutation( chMenu : CR4CharacterMenu ):void
{
	var currentlyEquipped : EPlayerMutationType;
	var equippedMutations : array< EPlayerMutationType >;
	var i				  : int;
	
	equippedMutations = GetWitcherPlayer().SSS_GetEquippedMutationType();
	
	for(i=0; i<equippedMutations.Size(); i=i+1)
	{
		currentlyEquipped = equippedMutations[i];
		if( currentlyEquipped != EPMT_None )
		{
			chMenu.SSS_UpdateTargetMutationData( currentlyEquipped );
		}
	}
}