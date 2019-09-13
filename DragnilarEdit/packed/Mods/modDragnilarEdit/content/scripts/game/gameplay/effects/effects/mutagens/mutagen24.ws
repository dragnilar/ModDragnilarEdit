/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Mutagen24_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen24;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{	
		super.OnEffectAdded( customparams );	
		thePlayer.SetSprintingSpeed(2.0);
	}

	event OnEffectRemoved()
	{
			
		thePlayer.SetSprintingSpeed(1.6);
		super.OnEffectRemoved();
	}
	
}