struct enemyStruct
{
	var enemyType : EMonsterCategory;
	var enemyCount : int;
	var enemyName : name;
}

struct actorNameType
{
	var actorName : array<name>;
}	

class AutoApplyOilsFunctions extends CR4Player
{
	var enemyArray : array<CActor>;
	var equippedItems : array<SItemUniqueId>;
	var nameIsTypeArray : array<actorNameType>;
	var blankItemId : SItemUniqueId;
	var oilAppliedForBoss : string;
	var notificationStrings : array<string>;
	var errorStrings : array<string>;
	var warningStrings : array<string>;
	var steelOilApplied : bool;
	var silverOilApplied : bool;
	var displayNotifications : bool; default displayNotifications = false;
	
	function Initialise()
	{
		var i , j : int;
		var tempActorNameType : actorNameType;
		var tempActorNameArray : array<name>;
		var monsterCategory : EMonsterCategory;
		var monsterName : name;
		var tempBool : bool;
		var nameIsInArray : bool;
		var rangeToScan : float;
		var playerPos : Vector;
		var enemyPos : Vector;
		var enemyTooLow : float;
		
		inv = GetWitcherPlayer().GetInventory();
		steelOilApplied = false;
		silverOilApplied = false;
		
		enemyTooLow = 3;
		
		if ( GetWitcherPlayer().IsInInterior() || PlayerInTown() )
		{
			// shorter range in town picks up fewer actors, more efficient code
			rangeToScan = 20;
		}
		else
		{
			// long range to find flying enemies while in wilderness
			rangeToScan = 30;
		}
		enemyArray = GetActorsInRange(GetWitcherPlayer(),rangeToScan,,,true);
		playerPos = GetWitcherPlayer().GetWorldPosition();
		for (i = 0; i < enemyArray.Size(); i += 1)
		{
			enemyPos = enemyArray[i].GetWorldPosition();
			// delete if not hostile
			if (GetAttitudeBetween(enemyArray[i], GetWitcherPlayer()) != AIA_Hostile)
			{
				enemyArray.EraseFast(i);
				i -= 1;
			}
			// delete enemy if too far below
			else if (( playerPos.Z - enemyPos.Z ) > enemyTooLow)
			{
				enemyArray.EraseFast(i);
				i -= 1;
			}
		}
		
		for (i = 0; i < enemyArray.Size(); i += 1)
		{
			theGame.GetMonsterParamsForActor(enemyArray[i],monsterCategory,monsterName,tempBool,tempBool,tempBool);
			tempActorNameType = nameIsTypeArray[monsterCategory];
			tempActorNameArray = tempActorNameType.actorName;
			nameIsInArray = false;
			for (j = 0; j < tempActorNameArray.Size(); j += 1)
			{
				if (monsterName == tempActorNameArray[j]) nameIsInArray = true;
			}
			
			if (nameIsInArray == false)
			{
				tempActorNameArray.PushBack(monsterName);
				tempActorNameType.actorName = tempActorNameArray;
				nameIsTypeArray[monsterCategory] = tempActorNameType;
			}
		}
	}
	
	// use nearby doors to determine whether player is in town. Tried using GetCurrentZone() but wouldn't work for some reason
	function PlayerInTown() : bool
	{
		var entities : array< CGameplayEntity >;
		var i , j : int;
		var tagArray : array<name>;
		var tagString : string;
		var doorRange : float;
		var doorCount : int;
		
		doorRange = 30;
		doorCount = 100;
		FindGameplayEntitiesInRange( entities, GetWitcherPlayer(), doorRange, doorCount,, FLAG_ExcludePlayer,, 'CGameplayEntity' );
		
		for ( i = 0; i < entities.Size(); i += 1 )
		{
			tagArray = entities[i].GetTags();
			for ( j = 0; j < tagArray.Size(); j += 1)
			{
				tagString = StrLower(NameToString(tagArray[j]));
				if ( StrContains( tagString , "door" ) )
				{
					return true;
				}
			}
		}
		return false;
	}

	function AutoApplyOil(passedArray : array<CActor>, optional bossMode : bool)
	{
		var steelOilId, silverOilId : SItemUniqueId;
		var equippedItems : array<SItemUniqueId>;
		var enemySteel : enemyStruct;
		var enemySilver : enemyStruct;
		var blankEnemyStruct : enemyStruct;
		
		enemySteel = GetEnemyMaxArrayOil(passedArray, false, true);
		if (steelOilApplied == false)
		{
			if (enemySteel != blankEnemyStruct)
			{
				steelOilId = GetOilFromEnemyType(enemySteel.enemyType);
			}
		}
		
		enemySilver = GetEnemyMaxArrayOil(passedArray, false, false);
		if (silverOilApplied == false)
		{
			if (enemySilver != blankEnemyStruct)
			{
				silverOilId = GetOilFromEnemyType(enemySilver.enemyType);
			}
		}
		
		equippedItems = GetWitcherPlayer().GetEquippedItems();
		if (inv.IsIdValid(steelOilId))
		{
			if (inv.IsIdValid(equippedItems[EES_SteelSword]))
			{
				GetWitcherPlayer().ApplyOil(steelOilId,equippedItems[EES_SteelSword]);
				steelOilApplied = true;
				//Dragnilar - Do not use notifications
				// if (bossMode)
				// {
				// 	notificationStrings.PushBack("Oil applied for " + NameToString(enemySteel.enemyName) + " boss");
				// }
				// else
				// {
				// 	notificationStrings.PushBack("Oil applied for " + MonsterTypeToString(enemySteel.enemyType) + " enemy type");
				// }
			}
		}
		if (inv.IsIdValid(silverOilId))
		{
			if (inv.IsIdValid(equippedItems[EES_SilverSword]))
			{
				GetWitcherPlayer().ApplyOil(silverOilId,equippedItems[EES_SilverSword]);
				silverOilApplied = true;
				//Dragnilar - Do not use notifications
				// if (bossMode)
				// {
				// 	notificationStrings.PushBack("Oil applied for " + NameToString(enemySilver.enemyName) + " boss");
				// }
				// else
				// {
				// 	notificationStrings.PushBack("Oil applied for " + MonsterTypeToString(enemySilver.enemyType) + " enemy type");
				// }
			}
		}
	}
	
	function GetOilFromEnemyType(enemyTypeName : EMonsterCategory) : SItemUniqueId
	{
		var tempItemId : SItemUniqueId;

		switch(enemyTypeName)
		{
			case MC_Beast :
			{
				tempItemId = GetItemIdFromType("Beast oil");
				break;
			}
			case MC_Cursed :
			{
				tempItemId = GetItemIdFromType("Cursed oil");
				break;
			}
			case MC_Draconide :
			{
				tempItemId = GetItemIdFromType("Draconide oil");
				break;
			}
			case MC_Human :
			{
				tempItemId = GetItemIdFromType("Hanged Man Venom");
				break;
			}
			case MC_Hybrid :
			{
				tempItemId = GetItemIdFromType("Hybrid oil");
				break;
			}
			case MC_Insectoid :
			{
				tempItemId = GetItemIdFromType("Insectoid oil");
				break;
			}
			case MC_Magicals :
			{
				tempItemId = GetItemIdFromType("Magicals oil");
				break;
			}
			case MC_Necrophage :
			{
				tempItemId = GetItemIdFromType("Necrophage oil");
				break;
			}
			case MC_Relic :	
			{
				tempItemId = GetItemIdFromType("Relic oil");
				break;
			}
			case MC_Specter :
			{
				tempItemId = GetItemIdFromType("Specter oil");
				break;
			}
			case MC_Troll :
			{
				tempItemId = GetItemIdFromType("Ogre oil");
				break;
			}
			case MC_Vampire :
			{
				tempItemId = GetItemIdFromType("Vampire oil");
				break;
			}
			default :
			{
				tempItemId = blankItemId;
				LogChannel('modDragnilarEdit',"Auto apply oils: Cannot apply oil, enemy type is not defined. Most likely it is a horse or something that oils are not programmed to work on anyway.");
				//errorStrings.PushBack("Unknown enemy type");
			}
		}		
		return tempItemId;
	}
	
	function GetItemIdFromType( itemType : string ) : SItemUniqueId
	{
		var items : array<SItemUniqueId>;
		var itemName : name;
		var i : int;
		var itemLevel : int;
		var level1 : SItemUniqueId;
		var level2 : SItemUniqueId;
		var level3 : SItemUniqueId;
		
		inv.GetAllItems(items);
		
		for ( i = 0; i < items.Size(); i+=1)
		{
			itemName = inv.GetItemName(items[i]);
			if (StrStartsWith(StrLower(NameToString(itemName)) , StrLower(itemType)))
			{
				itemLevel = (int)CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(items[i], 'level'));
				if (itemLevel == 1)
				{
					level1 = items[i];
				}
				else if (itemLevel == 2)
				{
					level2 = items[i];
				}
				else if (itemLevel == 3)
				{
					level3 = items[i];
				}
			}
		}
		
		if (level3 != blankItemId)
		{
			return level3;
		}
		else if (level2 != blankItemId)
		{
			return level2;
		}
		else if (level1 != blankItemId)
		{
			return level1;
		}
		else
		{
			LogChannel('modDragnilarEdit',"Auto apply oils: No " + itemType + "in inventory.");
			//errorStrings.PushBack("No " + itemType + " in inventory");
			return blankItemId;
		}
	}
	
	function GetEnemyMaxArrayOil( passedArray : array<CActor> , searchByName : bool , optional steelSword : bool ) : enemyStruct
	{
		var i : int;
		var max_i : int;
		var enemyIndex : int;
		var enemyMaxArray : array<enemyStruct>;
		var tempEnemyStruct : enemyStruct;
		var tempBool : bool;
		var monsterName : name;
		var monsterCategory : EMonsterCategory;
	
		for (i = 0; i < enemyArray.Size(); i += 1)
		{
			theGame.GetMonsterParamsForActor(passedArray[i],monsterCategory,monsterName,tempBool,tempBool,tempBool);
			if (steelSword == false && monsterCategory != MC_Human && monsterCategory != MC_Beast)
			{
				if (searchByName)
				{
					enemyIndex = NameExistsInArray(enemyMaxArray, monsterName);
				}
				else
				{
					enemyIndex = TypeExistsInArray(enemyMaxArray, monsterCategory);
				}
				
				if (enemyIndex == -1) 
				{
					tempEnemyStruct.enemyType = monsterCategory;
					tempEnemyStruct.enemyName = monsterName;
					tempEnemyStruct.enemyCount = 1;
					enemyMaxArray.PushBack(tempEnemyStruct);
				}
				else
				{
					tempEnemyStruct = enemyMaxArray[enemyIndex];
					tempEnemyStruct.enemyCount += 1;
					enemyMaxArray[enemyIndex] = tempEnemyStruct;
				}
			}
			else if (steelSword == true && (monsterCategory == MC_Human || monsterCategory == MC_Beast))
			{
				if (searchByName)
				{
					enemyIndex = NameExistsInArray(enemyMaxArray, monsterName);
				}
				else
				{
					enemyIndex = TypeExistsInArray(enemyMaxArray, monsterCategory);
				}
				
				if (enemyIndex == -1) 
				{
					tempEnemyStruct.enemyType = monsterCategory;
					tempEnemyStruct.enemyName = monsterName;
					tempEnemyStruct.enemyCount = 1;
					enemyMaxArray.PushBack(tempEnemyStruct);
				}
				else
				{
					tempEnemyStruct = enemyMaxArray[enemyIndex];
					tempEnemyStruct.enemyCount += 1;
					enemyMaxArray[enemyIndex] = tempEnemyStruct;
				}
			}
		}
		for (i = 0; i < enemyMaxArray.Size(); i += 1)
		{
			if ( enemyMaxArray[i].enemyCount > enemyMaxArray[max_i].enemyCount )
			{
				max_i = i;
			}
		}
		return enemyMaxArray[max_i];
	}
	
	function TypeExistsInArray( passedArray : array<enemyStruct> , monsterType : EMonsterCategory) : int
	{
		var i : int;		
		
		for (i=0; i < passedArray.Size(); i+=1)
		{
			if (passedArray[i].enemyType == monsterType) return i;
		}
		return -1;
	}
	
	function NameExistsInArray( passedArray : array<enemyStruct> , monsterName : name) : int
	{
		var i : int;
		
		for (i=0; i < passedArray.Size(); i+=1)
		{
			if (passedArray[i].enemyName == monsterName) return i;
		}
		return -1;
	}

	//Dragnilar - Do not use notifications	
	// function NotifyPlayer()
	// {
	// 	var blankStringArray : array<string>;
	// 	var stringToPrint : string;
	// 	var i : int;
		
	// 	if (notificationStrings != blankStringArray && displayNotifications == true)
	// 	{
	// 		stringToPrint = stringToPrint + "AutoApplyOils: <br/>";
			
	// 		for (i = 0; i < notificationStrings.Size(); i += 1)
	// 		{
	// 			if ( i != (notificationStrings.Size() - 1) || errorStrings != blankStringArray || warningStrings != blankStringArray )
	// 			{
	// 				stringToPrint = stringToPrint + notificationStrings[i] + "<br/>";
	// 			}
	// 			else
	// 			{
	// 				stringToPrint = stringToPrint + notificationStrings[i];
	// 			}
	// 		}
	// 	}
		
	// 	if (errorStrings != blankStringArray)
	// 	{
	// 		stringToPrint = stringToPrint + "AutoApplyOils Errors: <br/>";
			
	// 		for (i = 0; i < errorStrings.Size(); i += 1)
	// 		{
	// 			if ( i != (errorStrings.Size() - 1) || warningStrings != blankStringArray )
	// 			{
	// 				stringToPrint = stringToPrint + errorStrings[i] + "<br/>";
	// 			}
	// 			else
	// 			{
	// 				stringToPrint = stringToPrint + errorStrings[i];
	// 			}
	// 		}
	// 	}
		
	// 	if (warningStrings != blankStringArray)
	// 	{
	// 		stringToPrint = stringToPrint + "AutoApplyOils Warnings: <br/>";
			
	// 		for (i = 0; i < warningStrings.Size(); i += 1)
	// 		{
	// 			if (i != warningStrings.Size() - 1)
	// 			{
	// 				stringToPrint = stringToPrint + warningStrings[i] + "<br/>";
	// 			}
	// 			else
	// 			{
	// 				stringToPrint = stringToPrint + warningStrings[i];
	// 			}
	// 		}
	// 	}
	// 	if (stringToPrint != "")
	// 	{
	// 		theGame.GetGuiManager().ShowNotification( stringToPrint, 5000);
	// 	}
	// }
	
	function MonsterTypeToString( monsterType : EMonsterCategory ) : string
	{
		switch ( monsterType )
		{
			case MC_Hybrid : return "Hybrid";
			case MC_Human : return "Human";
			case MC_Necrophage : return "Necrophage";
			case MC_Troll : return "Ogroid";
			case MC_Vampire : return "Vampire";
			case MC_Beast : return "Beast";
			case MC_Cursed : return "Cursed";
			case MC_Draconide : return "Draconid";
			case MC_Insectoid : return "Insectoid";
			case MC_Magicals : return "Elementa";
			case MC_Specter : return "Specter";
			case MC_Relic : return "Relict";
			default : return "";
		}
	}
}