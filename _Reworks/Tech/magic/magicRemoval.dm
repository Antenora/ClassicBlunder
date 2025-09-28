/mob/proc/refundAllMagic()
	var/list/obj/Skills/Refundable = list()
	for(var/obj/Skills/S in src)
		if(S.MagicNeeded && !S.SignatureTechnique)
			Refundable += S
	var/cost = 0
	for(var/obj/Skills/S in Refundable)
		cost = S.SkillCost
		RPPSpendable += cost
		RPPSpent -= cost
		if(S.PreRequisite.len>0)
			if(!istype(S, /obj/Skills/Buffs/NuStyle))
				for(var/path in S.PreRequisite)
					var/p=text2path(path)
					var/obj/Skills/oldSkill = new p
					cost = oldSkill.SkillCost
					RPPSpendable += cost
					RPPSpent -= cost
					SkillsLocked.Remove(oldSkill.type)
					for(var/path2 in oldSkill.PreRequisite)
						var/p2=text2path(path2)
						var/obj/Skills/oldSkill2 = new p2
						cost = oldSkill2.SkillCost
						RPPSpendable += cost
						RPPSpent -= cost
						SkillsLocked.Remove(oldSkill.type)
						del oldSkill2
					del oldSkill
		del S
	if(RPPSpendable > RPPCurrent)
		RPPSpendable = RPPCurrent

/mob/proc/removeAllTomes()
	for(var/obj/Items/Enchantment/Tome/t in src)
		del t
	for(var/obj/Items/Enchantment/Scroll/s in src)
		del s

/mob/Admin4/verb/testREmoveMagicOveruhaul(mob/p in world)
	set name = "Remove Old Magic"
	p.refundAllMagic()
	p.refundOldMagicShit()
	p.removeAllTomes()



// is they have summoning it is OKAY! 
// everything else has to go

/mob/proc/refundOldMagicShit()
	var/cost
	var/list/trees = list("Alchemy","ToolEnchantment", "TomeCreation", "SealingMagic")
	var/list/higherTrees = list("ImprovedAlchemy", "ArmamentEnchantment", "CrestCreation", "SealingMagic", "TimeMagic")
	for(var/tree in trees)
		var/unlockedVar = "[tree]Unlocked"
		cost = 40/Imagination
		if(vars[unlockedVar]>0)
			for(var/x in 1 to vars[unlockedVar])
				RPPSpendable += cost
				RPPSpent -= cost
				vars[unlockedVar]--
	for(var/tree in higherTrees)
		var/unlockedVar = "[tree]Unlocked"
		cost = 80/Imagination
		if(vars[unlockedVar]>0)
			for(var/x in 1 to vars[unlockedVar])
				RPPSpendable += cost
				RPPSpent -= cost

				vars[unlockedVar]--
	if(RPPSpendable > RPPCurrent)
		RPPSpendable = RPPCurrent
	