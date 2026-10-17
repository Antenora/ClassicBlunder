/obj/Skills/Buffs/SpecialBuffs/Namekian_Giant_Form
	name = "Giant Form"
	desc = "Channel your regeneration into monstrous growth: stronger and tougher, but slower, easier to hit and more vulnerable to stuns and blinding flashes."
	Copyable = 0
	Enlarge = 2
	StrMult = 1.2
	EndMult = 1.2
	SpdMult = 0.6
	DefMult = 0.7
	passives = list("GiantForm" = 1, "NoDodge" = 1, "Juggernaut" = -1, "EnergyLeak" = 1)
	Cooldown = 120
	ActiveMessage = "channels their regeneration into monstrous growth!"
	OffMessage = "shrinks back to their normal size."

	verb/Giant_Form()
		set name = "Giant Form"
		set category = "Skills"
		if(!usr.BuffOn(src) && usr.Class == NAMEK_CLAN_DRAGON)
			usr << "The Dragon clan cannot take a giant form."
			return
		src.Trigger(usr)
