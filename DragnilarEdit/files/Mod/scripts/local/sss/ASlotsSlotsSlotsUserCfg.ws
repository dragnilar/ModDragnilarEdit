	// The lines which start from the double slashes // are comment lines like this one
	// and this one 
	// all comment lines will be indented for easy reading
	
	// >>>>> Comment lines are your friends they have information for you. Read it.  <<<<<
	
	// To change some setting change the value after the return string that is not commented or indented.
	// Every setting has a description: it is a group of comment lines above it.


function SSS_SlotTabsCount(): int
{
	// ==========================================================================================================
	// Brief: Number of tabs for skill slots / mutagen slots
	// ==========================================================================================================
	// Set one of the following numbers after "return " statement:
	// 1, 2, 3, 4, 5, 6, 7, 8, 9 to set this amount of Skill Slot Tabs
	
return 8
;
}

function SSS_MutagenSlotsTabbed(): int
{
	// ==========================================================================================================
	// Brief: Use different mutagen slots for each skill slot tab
	// ==========================================================================================================
	// Set one of the following numbers after "return " statement:
	// 0 use same 4 default mutagen slots for all skill slot tabs
	// 1 use different mutagen slots for each skill slot tab
	
return 0
;
}

function SSS_MaxActiveMutations(): int
{
	// ==========================================================================================================
	// Brief: Maximum number of active mutations 
	// ==========================================================================================================
	// Number of mutations that can be activated simultaneously.
	// Set one of the following numbers after "return " statement:
	// 0 master mutation level controls number of active mutations (up to four active mutations)
	// 1 only one mutation can be activated simultaneously
	// 2 two mutations can be activated simultaneously
	// 3 three mutations can be activated simultaneously
	// ...
	// 99 ninety nine mutations can be activated simultaneously
	
return 99
;
}

function SSS_UnlockAllSkillSlots(): int
{
	// ==========================================================================================================
	// Brief: Unlock all skill slots setting (except 4 mutation skill slots)
	// ==========================================================================================================
	// Set one of the following numbers after "return " statement:
	// 0 to lock skill slots and use default unlock policy (by gaining required level for slot to unlock)
	// 1 to unlock all skill slots
	
return 1
;
}

function SSS_UnlockMutagenSlots(): int
{
	// ==========================================================================================================
	// Brief: Unlock all mutagen slots setting
	// ==========================================================================================================
	// Set one of the following numbers after "return " statement:
	// 0 to lock mutagen slots and use default unlock policy (by gaining required level for slot to unlock)
	// 1 to unlock all mutagen slots
	
return 1
;
}

function SSS_DisableMutationSkillSlotsColorRestrictions(): int
{
	// ==========================================================================================================
	// Brief: Disable color restrictions on 4 skill slots added by mutations
	// ==========================================================================================================
	// Set one of the following numbers after "return " statement:
	// 0 to enable color restrictions (game default behavior)
	// 1 to disable color restrictions
	
return 1
;
}

function SSS_DisableMutagenSynergyColorRestrictions(): int
{
	// ==========================================================================================================
	// Brief: Mutagen synergy bonus added for any skills with any color in mutagen skill slots
	// ==========================================================================================================
	// Set one of the following numbers after "return " statement:
	// 0 to enable color restrictions (game default behavior)
	// 1 to disable color restrictions
	
return 1
;
}

function SSS_RememberLastOpenedTab(): int
{
	// ==========================================================================================================
	// Brief: Open last used tab when return to Character menu or always open first tab
	// ==========================================================================================================
	// Set one of the following numbers after "return " statement:
	// 0 open first tab (v4.5 and v4.6 and v4.7 worked as this)
	// 1 open last used tab (Default behavior for v4.7.1+)
	
return 1
;
}

function SSS_AdditionalSkillSlotLevelRequirementsBaseLevel(): int
{
	// ==========================================================================================================
	// Brief: This is the additional Skill slot level requirement BASE.
	// ==========================================================================================================
	// This setting controls the unlock level requirement of first additional skill slot ( see also additional 
	// skill slot level requirement STEP).
	// Set any number after "return " statement
	
return 1
;
}

function SSS_AdditionalSkillSlotLevelRequirementsStep(): int
{
	// ==========================================================================================================
	// Brief: This is the additional Skill slot level requirement STEP.
	// ==========================================================================================================
	// This setting controls the level requirement increment of additional skill slots (except first).
	//
	// Or in other words: new slot will be unlocked every STEP levels starting from BASE level:
	// tab #2 skill slot #1 will be unlocked on the BASE level, tab #2 skill slot #2 will be unlocked on the 
	// BASE+STEP level, tab #2 skill slot #3 will be unlocked on the BASE+STEP+STEP level and so on.
	//
	// So if the STEP value is X and the base level requirement is Y  the additional slots Z will have this level 
	// requirement: Z*X+Y
	//
	// Set one of the following numbers after "return " statement:
	// 0  to unlock all additional skill slots after gaining base level
	// 1  to unlock tab #2 slot #1 on level Y, slot #2 - on level 1+Y, slot #3 on level 2+Y, slot #4 on level 3+Y
	// 2  to unlock tab #2 slot #1 on level Y, slot #2 - on level 2+Y, slot #3 on level 4+Y, slot #4 on level 6+Y
	// ...
	// 99 to unlock tab #2 slot #1 on level Y, slot #2 - on level 99+Y, slot #3 on level 198+Y, slot #4 on level 297+Y
	
return 0
;
}



function SSS_AdditionalMutagenSlotLevelRequirementsBaseLevel(): int
{
	// ==========================================================================================================
	// Brief: This is the additional Mutagen slot level requirement BASE.
	// ==========================================================================================================
	// This setting controls the unlock level requirement of first additional Mutagen slot ( see also additional 
	// Mutagen slot level requirement STEP).
	// Set any number after "return " statement
	
return 1
;
}

function SSS_AdditionalMutagenSlotLevelRequirementsStep(): int
{
	// ==========================================================================================================
	// Brief: This is the additional Mutagen slot level requirement STEP.
	// ==========================================================================================================
	// This setting controls the level requirement increment of additional Mutagen slots (except first).
	//
	// Or in other words: new slot will be unlocked every STEP levels starting from BASE level:
	// tab #2 Mutagen slot #1 will be unlocked on the BASE level, tab #2 Mutagen slot #2 will be unlocked on the 
	// BASE+STEP level, tab #2 Mutagen slot #3 will be unlocked on the BASE+STEP+STEP level and so on.
	//
	// So if the STEP value is X and the base level requirement is Y  the additional slots Z will have this level 
	// requirement: Z*X+Y
	//
	// Set one of the following numbers after "return " statement:
	// 0  to unlock all additional Mutagen slots after gaining base level
	// 1  to unlock tab #2 slot #1 on level Y, slot #2 - on level 1+Y, slot #3 on level 2+Y, slot #4 on level 3+Y
	// 2  to unlock tab #2 slot #1 on level Y, slot #2 - on level 2+Y, slot #3 on level 4+Y, slot #4 on level 6+Y
	// ...
	// 99 to unlock tab #2 slot #1 on level Y, slot #2 - on level 99+Y, slot #3 on level 198+Y, slot #4 on level 297+Y
	
return 0
;
}

function SSS_FirstNonSynergySlot(): int
{
	// ==========================================================================================================
	// Brief: Disable Mutagen synergy bonuses for additional skill slots starting from this skill slot.
	// ==========================================================================================================
	// All skill slots starting from skill slot with this number will not add mutagen synergy bonuses 
	// this means that any skills placed in such skill slots will not add synergy bonuses to the mutagens.
	// Additional skill slots has numbers starting from 17 and there are 12 additional skill slots per tab.
	// This value will be automatically rounded down to the first slot in mutagen group 
	// (30 and 31 will be rounded down to 29; 33 and 34 will be rounded down to 32 etc.).
	// 
	// Set one of the following numbers after "return " statement:
	// 0  default, all Skill Slots add synergy bonuses to the corresponding mutagen slot
	// ...
	// 16 default, all Skill Slots add synergy bonuses to the corresponding mutagen slot
	// 17 additional skill slots does not add synergy bonuses (only skill slots on the tab #1 add synergy bonuses)
	// 29 skill slots on tab #1 and tab #2 add synergy bonuses
	// 41 skill slots on tab #1, tab#2 and tab #3 add synergy bonuses
	// 53 skill slots on tab #1, tab#2, tab #3 and tab #4 add synergy bonuses
	// ...
	// 89  skill slots on tab #1, tab#2, tab #3, tab #4, tab #5, tab #6 and tab #7 add synergy bonuses
	
return 0
;
}
