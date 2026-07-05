
var/list/


mutation
	parent_type = /datum

	var/mob/owner

	var/list/boons = list()
	var/list/nerfs = list() //bad mutations. HP Cuts and such.
	var/list/skills = list()

	var/list/applied_boons = list()
	var/list/skills_granted = list()

	proc/ApplyGenome()
		if(applied_boons.len + nerfs.len + skills.len) //The mutation has already been applied.
			return
		for(var/v in boons)
			if(owner.vars[v])
				owner.vars[v] += boons[v]
				applied_boons[v] = boons[v]

		for(var/v in skills)
			var/path = text2path("[v]")
			var/obj/o = new path
			if(!locate(o, owner))
				owner.contents += o
				skills_granted += v

	proc/RemoveGenome()
		for(var/v in applied_boons)
			if(owner.vars[v])
				owner.vars[v] -= applied_boons[v]

		for(var/v in skills_granted)
			var/path = text2path("[v]")
			var/obj/o = new path
			o = locate(o) in owner
			if(o) owner.contents -= o

		applied_boons = list()
		skills_granted = list()

	proc/CopyGenome()
		var/mutation/m = new
		m.boons = boons.Copy()
		m.nerfs = nerfs.Copy()
		m.skills = skills.Copy()
		return m

mob/proc/GetGenome()
	var/mutation/m = new

	// WE ONLY WANT BASE STATISTICS SO FOR THE LOVE OF ALL THAT IS HOLY MAKE SURE THIS MOB IS COMPLETELY UNBUFFED.
	// prolly only actually important for aliens

	switch(Race)
		if("Android")
			return null //Androids don't have DNA.
		if("Saiyan")

		if("Changeling")
		if("Half Saiyan")
		if("Majin")
		if("Dragon")
		if("Namekian")
			m.boons["RegenAscension"] = 1
			m.skills |= "/obj/Skills/Buffs/SlotlessBuffs/Regeneration"
		if("Makyo")
		if("Shinjin")
			m.boons["Timeless"] = 1
			m.skills |= "/obj/Skills/Telekinesis"
			m.skills |= "/obj/Skills/Utility/Telepathy"

		if("Monster")
		if("Tuffle")
			m.boons["Intelligence"] = 1
		if("Alien")
			if(Juggernaut)
				m.boons["Juggernaut"] = 1
			if(locate(/obj/Skills/Queue/Blaze_Burst) in src)
				m.skills |= "/obj/Skills/Queue/Blaze_Burst"
				m.skills |= "/obj/Skills/Buffs/SlotlessBuffs/Elemental_Infusion"
			if(locate(/obj/Skills/Queue/Winter_Shock) in src)
				m.skills |= "/obj/Skills/Queue/Winter_Shock"
				m.skills |= "/obj/Skills/Buffs/SlotlessBuffs/Elemental_Infusion"
			if(locate(/obj/Skills/Queue/Terra_Crack) in src)
				m.skills |= "/obj/Skills/Queue/Terra_Crack"
				m.skills |= "/obj/Skills/Buffs/SlotlessBuffs/Elemental_Infusion"
			if(locate(/obj/Skills/Queue/Aero_Slash) in src)
				m.skills |= "/obj/Skills/Queue/Aero_Slash"
				m.skills |= "/obj/Skills/Buffs/SlotlessBuffs/Elemental_Infusion"
			if(Hustle)
				m.boons["Hustle"] = 1
			if(Infusion)
				m.boons["Infusion"] = 1
			if(Flicker)
				m.boons["Flicker"] = Flicker
			if(Adrenaline)
				m.boons["Adrenaline"] = 1
			if(EnhancedSmell)
				m.boons["EnhancedSmell"] = 1
				m.skills |= "/obj/Skills/Buffs/SlotlessBuffs/Camouflage"
			if(EnhancedHearing)
				m.boons["EnhanceHearing"] = 1
			if((locate(/obj/Skills/Telekinesis) in src) && (locate(/obj/Skills/Utility/Telepathy) in src))
				m.skills |= "/obj/Skills/Telekinesis"
				m.skills |= "/obj/Skills/Utility/Telepathy"
			if(Fishman)
				m.boons["Fishman"] = 1
			if(VenomResistance)
				m.boons["VenomResistance"] = 1
			if(VenomBlood)
				m.boons["VenomBlood"] = 1
			if(Xenobiology)
				m.boons["Xenobiology"] = 1
			if(Longlived)
				m.boons["Longlived"] = Longlived

	if(Neko) m.boons["Neko"] = 1
	if(Kitsune) m.boons["Kitsune"] = 1
	if(Tanuki) m.boons["Tanuki"] = 1
	if(Wolf) m.boons["Wolf"] = 1
	if(Lizard) m.boons["Lizard"] = 1
	if(Tengu) m.boons["Tengu"] = 1
	if(Bull) m.boons["Bull"] = 1


	return m

obj/Items/Tech
	DNA_Syringe
		TechType="ImprovedMedicalTechnology"
		SubType="Mutations"
		icon='Tech.dmi'
		icon_state="Genome"
		desc="An item that allows you to steal another's DNA. Increases the chance of negative mutations."
		Cost=10000000000000


	DNA_Injector
		TechType="ImprovedMedicalTechnology"
		SubType="Mutations"
		icon='Tech.dmi'
		icon_state="Genome"
		desc="A consumable item that allows you to blend someone's DNA with another's."
		Cost=10000000000000
