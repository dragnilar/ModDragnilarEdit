/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Mutagen51_Effect extends W3Mutagen_Effect
{	
	default effectType = EET_Mutagen51;
	default dontAddAbilityOnTarget = true;
	
	public var addedMutation : bool;
	private var pam : W3PlayerAbilityManager;
	
	public function addedMutation() : bool
	{
		//return addedMutation;
		return false;
	}
	
	event OnEffectAddedPost()
	{
		super.OnEffectAddedPost();
		addedMutation = false;
		//UpdateMutation(); //Dragnilar - disabling this, it can cause the mutation menu to become disabled.
	}

	private final function UpdateMutation()
	{
		pam = ( W3PlayerAbilityManager ) GetWitcherPlayer().abilityManager;

		if(pam.IsMutationSystemEnabled() == false)
		{
			GetWitcherPlayer().MutationSystemEnable(true);
			pam.DEBUG_DevelopAndEquipMutation( RandRange( 12, 1 ) );
			addedMutation = true;
		}
		else
		{
			addedMutation = false;

		}	
	}


	event OnEffectRemoved()
	{
		//Dragnilar - Shouldn't onEffectRemoved get called after clearing out the abilities?
		target.RemoveAbilityAll(abilityName);
		super.OnEffectRemoved();


		// pam = ( W3PlayerAbilityManager ) GetWitcherPlayer().abilityManager;

		// if(addedMutation)
		// {
		// 	pam.ResetMutationsDev();
		// 	GetWitcherPlayer().MutationSystemEnable(false);
		// }
	
	}	
}