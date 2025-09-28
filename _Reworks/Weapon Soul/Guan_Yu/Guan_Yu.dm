obj/Items/Sword/Heavy/Legendary/WeaponSoul/Spear_of_War // "Green Dragon Crescent Blade" / Guan Yu
	pixel_x = -16
	pixel_y = -16
	name = "Spear of War"
	icon = 'GreenDragonCrescentBlade_NoTrain.dmi'
	passives = list("SweepingStrike" = 1)

obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Guan_Yu
	name = "Heavenly Regalia: War King"
	StrMult=1.3
	OffMult=1.3
	DefMult=1.3
	passives = list("Zornhau" = 1, "Steady" = 2, "LikeWater" = 1, "Iaijutsu" = 1)
	IconLock='EyeFlameC.dmi'
	ActiveMessage="'s warful treasures ring in resonance: Heavenly Regalia!"
	OffMessage="'s treasures lose their warful luster..."
	verb/Heavenly_Regalia()
		set category="Skills"
		src.Trigger(usr)