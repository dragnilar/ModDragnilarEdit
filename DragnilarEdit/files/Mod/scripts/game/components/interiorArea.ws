/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



import class CR4InteriorAreaComponent extends CTriggerAreaComponent
{
	editable var isDarkPlace : bool;	
		default isDarkPlace = false;
		hint isDarkPlace = "If set area is considered a dark place (player should use torch / cat potion)";
	
	editable var allowHorseInThisInterior : bool;
		default allowHorseInThisInterior = false;
		hint allowHorseInThisInterior = "If left at false Geralt won't be able to mount, summon or ride horse inside this area and will be automatically dismount on enter";
	
	
	editable var movementLock : EPlayerMovementLockType;	default movementLock	= PMLT_NoSprint;
	
	
	event OnPlayerEntered( entered : bool )
	{
		switch( movementLock )
		{
			case PMLT_NoSprint :
				thePlayer.interiorTracker.LockSprint( entered );
			break;
			case PMLT_NoRun :
				thePlayer.interiorTracker.LockRun( entered );
			break;
		}

		//Dragnilar - Seeing in dark places
		if( GetWitcherPlayer().IsInDarkPlace() && GetWitcherPlayer().IsInCombat() && !thePlayer.HasBuff( EET_Mutation12Cat ) )
		{
			thePlayer.AddEffectDefault( EET_Mutation12Cat, thePlayer, "Mutation12 Senses", false );
		}
		
		
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if(activator.GetEntity() != thePlayer)
			return false;
			
		
		if(isDarkPlace)
			FactsAdd("tut_in_dark_place");
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		if(activator.GetEntity() != thePlayer)
			return false;
		
		
		if(isDarkPlace)
		{
			FactsSubstract("tut_in_dark_place");
			
			
			if( FactsQuerySum( "tut_in_dark_place" ) <= 0 )
			{
				//Dragnilar - seeing in dark places
				//thePlayer.RemoveBuff( EET_Mutation12Cat );
				thePlayer.RemoveAllBuffsOfType( EET_Mutation12Cat ); 
			}
		}
	}
}