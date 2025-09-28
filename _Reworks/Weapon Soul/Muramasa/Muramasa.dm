obj/Items/Sword/Light/Legendary/WeaponSoul/Bane_of_Blades//Muramasa
	name="Bane of Blades"
	icon='Muramasa.dmi'
	pixel_x=-16
	pixel_y=-16
	passives = list("WeaponBreaker" = 1)

obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Muramasa
	name = "Heavenly Regalia: The Death"
	StrMult=1.3
	OffMult=1.3
	DefMult=1.3
	passives = list("PureDamage" = 4, "Curse" = 1, "MaimStrike" = 1) // im so not sorry if this triggers.
	IconLock='EyeFlameC.dmi'
	ActiveMessage="'s deadly treasures ring in resonance: Heavenly Regalia!"
	OffMessage="'s treasures lose their deadly luster..."
	verb/Heavenly_Regalia()
		set category="Skills"
		src.Trigger(usr)