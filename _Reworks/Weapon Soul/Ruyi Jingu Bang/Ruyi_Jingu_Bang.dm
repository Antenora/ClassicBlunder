obj/Items/Sword/Wooden/Legendary/WeaponSoul/RyuiJinguBang
	name = "Ryui Jingu Bang"
	icon = 'WukongSheathe-32-32.dmi'
	unsheatheIcon = 'WukongStaff-32-32.dmi'
	removeSheathedOnUnSheathe = TRUE
	pixel_x = -32
	pixel_y = -32
	unsheatheOffsetX = -32
	unsheatheOffsetY = -32
	passives = list("Steady" = 1)
	ElementallyInfused = "Earth"

obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Ryui_Jingu_Bang
	name = "Heavenly Regalia: Monkey King"
	StrMult=1.3
	OffMult=1.3
	DefMult = 1.3
	EndMult=1.3
	passives = list("DoubleStrike" = 2, "Flow" = 2, "Instinct" = 2, "EnhancedHearing" = 1, "EnhancedSmell" = 1)
	IconLock='EyeFlameC.dmi'
	ActiveMessage="'s bountiful treasures ring in resonance: Heavenly Regalia!"
	OffMessage="'s treasures lose their strange luster..."
	verb/Heavenly_Regalia()
		set category="Skills"
		src.Trigger(usr)