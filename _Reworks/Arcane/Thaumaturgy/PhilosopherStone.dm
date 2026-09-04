obj/Items/Enchantment/PhilosopherStone
	name="Philosopher Stone"
	icon='enchantmenticons.dmi'
	icon_state="PhiloStone"
	desc="A philosopher's stone is the result of a sapient being transmuted into pure mana.  They regenerate capacity.<br>"
	suffix = "Will Use."
	var/CurrentCapacity
	var/MaxCapacity
	var/RegenRate
	var/SoulStrength//regen+recov at moment of stoning
	var/SoulIdentity//UID of person stoned
	var/ToggleUse = 1
	New()
		..()
		Update_Description()
	verb/ToggleStone()
		set name = "Toggle Stone"
		ToggleUse = !ToggleUse
		Update_Description()

	UpdatesDescription=1
	Fake
		CurrentCapacity = 200
		MaxCapacity = 200
		RegenRate = 1
		proc/reintegrate(mob/Players/user)
			if(SoulIdentity==user.UniqueID)
				user.ManaSealed = 0
				OMsg(user, "[user] has been reintegrated with their magical circuits!")
				del src
			else
				user << "This stone doesn't belong to your circuits!"

		verb/Reintegrate_Stone()
			set name = "Reintegrate Stone"
			reintegrate(usr)
	True
		CurrentCapacity=400
		MaxCapacity=400
		RegenRate=1
	Artificial
		name="Philosopher Stone (Artificial)"
		CurrentCapacity=200
		MaxCapacity=200
		RegenRate=1
	Magicite
		name="Magicite Stone"
		icon_state = "MagiStone"
		CurrentCapacity=1
		MaxCapacity=1
		RegenRate=0
		SoulStrength=2
		Update_Description()
			src.desc="A magicite stone, operating as a source of mana.<br>Your [src] mana storage: [round(src.CurrentCapacity)] / [src.MaxCapacity]"
			if(ToggleUse)
				usr << "This stone is now available for enchanting."
				src.suffix = "[round(src.CurrentCapacity)] / [src.MaxCapacity] (Enabled for Use)"
			else
				usr << "This stone will not be used for enchanting."
				src.suffix = "[round(src.CurrentCapacity)] / [src.MaxCapacity] (Disabled for Use)"
	proc/Update_Description()
		src.desc="A philosopher's stone is the result of a sapient being transmuted into pure mana.<br>Your [src] mana storage: [round(src.CurrentCapacity)] / [src.MaxCapacity]"
		if(ToggleUse)
			usr << "This stone is now available for enchanting."
			src.suffix = "[round(src.CurrentCapacity)] / [src.MaxCapacity] (Enabled for Use)"
		else
			usr << "This stone will not be used for enchanting."
			src.suffix = "[round(src.CurrentCapacity)] / [src.MaxCapacity] (Disabled for Use)"
