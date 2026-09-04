mob/var
	MageElement
	MageElement2
	MageForkDone = 0
	MageLockedIn = 0

mob/var/tmp/mage_buying = 0

globalTracker/var
	list/MAGE_POT_GATES = list(0, 10, 20, 30, 45, 60, 75)
	list/MAGE_TIER_FEES = list(0, 30, 50, 70, 90, 110, 130)
	MAGE_MAX_LEVEL = 7
	MAGE_FORK_LEVEL = 4
	MAGE_SECOND_BASIC_FEE = 100
	MAGE_ADVANCED_FEE = 150
	list/MAGE_PAGE_COST_BASIC = list(15, 25, 40, 60, 90)
	list/MAGE_PAGE_COST_ADVANCED = list(25, 40, 60, 90, 130)
	list/MAGE_PAGE_LEVEL = list(1, 2, 3, 5, 6)
	MAGE_MANA_PER_LEVEL = 20
	MAGE_MANA_PER_IMAGINATION = 25
	MAGE_REGEN_OUT = 1
	MAGE_REGEN_IN = 0.35
	list/MAGE_MILESTONES = list(4, 8, 12)
	MAGE_MILESTONE_MANA = 15
	MAGE_MILESTONE_REGEN = 0.1

proc/MageElementIcon(e)
	switch(e)
		if("Fire") return '_Reworks/Arcane/Icons/fire/pinnacle icon.png'
		if("Water") return '_Reworks/Arcane/Icons/water/pinnacle icon.png'
		if("Wind") return '_Reworks/Arcane/Icons/air/pinnacle icon.png'
		if("Earth") return '_Reworks/Arcane/Icons/earth/pinnacle icon.png'
		if("Light") return '_Reworks/Arcane/Icons/light/pinnacle icon.png'
		if("Dark") return '_Reworks/Arcane/Icons/dark/pinnacle icon.png'
		if("Space") return '_Reworks/Arcane/Icons/space/pinnacle icon.png'
		if("Time") return '_Reworks/Arcane/Icons/time/pinnacle icon.png'
	return '_Reworks/Arcane/Icons/generics/unpowered pinnacle.png'

proc/MageElementHasArt(e)
	return !(e == "Ice" || e == "Lightning")

proc/IsBasicElement(e)
	return (e in ELEMENT_PHYSICAL)

proc/IsAdvancedElement(e)
	return (e in ELEMENT_ADVANCED)

mob/proc/IsMage()
	return Saga == "Mage"

mob/proc/MageElements()
	var/list/L = list()
	if(MageElement) L |= MageElement
	if(MageElement2) L |= MageElement2
	return L

mob/proc/MageOwnsElement(e)
	return (e in MageElements())

mob/proc/MageMilestones(element)
	var/n = 0
	for(var/e in (element ? list(element) : MageElements()))
		var/owned = ArcaneOwnedCount(e)
		for(var/m in glob.MAGE_MILESTONES)
			if(owned >= m) n++
	return n

mob/proc/MageNextMilestone(element)
	var/owned = ArcaneOwnedCount(element)
	for(var/m in glob.MAGE_MILESTONES)
		if(owned < m) return m
	return 0

mob/proc/MageManaBonus()
	if(!IsMage()) return 0
	return glob.MAGE_MANA_PER_LEVEL * max(SagaLevel - 1, 0) + glob.MAGE_MANA_PER_IMAGINATION * max(Imagination - 1, 0) + glob.MAGE_MILESTONE_MANA * MageMilestones()

mob/proc/MageRegenTick()
	if(!IsMage() || KO || Dead) return
	StokeWatch()
	StillnessTick()
	if(IsExhausted()) return
	var/amt = (InCombat() ? glob.MAGE_REGEN_IN : glob.MAGE_REGEN_OUT) + glob.MAGE_MILESTONE_REGEN * MageMilestones()
	amt *= mana_regen_mult
	amt += StokeRegen()
	Recover("Mana", amt)

mob/proc/CanBecomeMage()
	if(!client) return "Only players walk this path."
	if(IsMage()) return "You are already a Mage."
	if(Saga) return "You already walk the path of a Saga."
	if(race && (race.type in glob.NoSagaRaces)) return "Your race cannot take up the Mage's path."
	return null

mob/proc/BecomeMage(element)
	var/why = CanBecomeMage()
	if(why)
		src << "<font color=red>[why]</font>"
		return 0
	if(!IsBasicElement(element))
		src << "<font color=red>Mages begin with one of the six physical elements.</font>"
		return 0
	Saga = "Mage"
	SagaLevel = 1
	SagaEXP = 0
	MageElement = element
	MageElement2 = null
	MageForkDone = 0
	MageLockedIn = 0
	findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/MageGrimoire)
	YeetSignatures()
	MaxMana()
	src << "<font color=#8be9ff>You take up the path of the Mage. [element] answers your call.</font>"
	if(client) client.RefreshHotbar()
	return 1

mob/proc/MageNextGate()
	if(!IsMage() || SagaLevel >= glob.MAGE_MAX_LEVEL) return null
	return glob.MAGE_POT_GATES[SagaLevel + 1]

mob/proc/MageNextFee()
	if(!IsMage() || SagaLevel >= glob.MAGE_MAX_LEVEL) return null
	return glob.MAGE_TIER_FEES[SagaLevel + 1]

mob/proc/MageTierUp()
	if(!IsMage()) return 0
	if(SagaLevel >= glob.MAGE_MAX_LEVEL)
		src << "You stand at the Arcane Stage. There is nothing further to attain."
		return 0
	var/next = SagaLevel + 1
	var/gate = glob.MAGE_POT_GATES[next]
	if(Potential < gate)
		src << "<font color=red>Mage Tier [next] needs [gate] Potential. You have [round(Potential, 0.01)].</font>"
		return 0
	if(mage_buying) return 0
	mage_buying = 1
	var/fee = glob.MAGE_TIER_FEES[next]
	if(!SpendRPP(fee, "Mage Tier [next]", Training = 0))
		mage_buying = 0
		return 0
	SagaLevel = next
	mage_buying = 0
	MageOnTierUp()
	return 1

mob/proc/MageOnTierUp()
	MaxMana()
	src << "<font color=#8be9ff>You ascend to Mage Tier [SagaLevel].</font>"
	switch(SagaLevel)
		if(2)
			src << "<font color=#8be9ff>Second-tier pages open, and your element's Mana Skin awaits.</font>"
		if(3)
			src << "<font color=#8be9ff>Third-tier pages open.</font>"
		if(4)
			src << "<font color=#8be9ff>The fork opens: a second element, an advanced path, or the lock-in.</font>"
		if(5)
			src << "<font color=#8be9ff>Fourth-tier pages open.</font>"
		if(6)
			src << "<font color=#8be9ff>The pinnacle page opens.</font>"
		if(7)
			src << "<font color=#8be9ff>The Arcane Stage. Your mana deepens, and one spell may be raised to its True form.</font>"

mob/proc/MageCanFork()
	if(!IsMage()) return "You are not a Mage."
	if(SagaLevel < glob.MAGE_FORK_LEVEL) return "The fork opens at Mage Tier [glob.MAGE_FORK_LEVEL]."
	if(MageElement2) return "You already command a second element."
	if(MageLockedIn) return "You have locked into [MageElement]."
	return null

mob/proc/MageDeclineFork()
	if(MageCanFork()) return 0
	if(MageForkDone) return 0
	MageForkDone = 1
	src << "<font color=#8be9ff>You keep to a single element. The lock-in will not be offered again.</font>"
	return 1

mob/proc/MageTakeSecondElement(element)
	var/why = MageCanFork()
	if(why)
		src << "<font color=red>[why]</font>"
		return 0
	if(element == MageElement || !(element in ELEMENT_LIST))
		src << "<font color=red>That cannot be your second element.</font>"
		return 0
	if(mage_buying) return 0
	mage_buying = 1
	var/fee = IsAdvancedElement(element) ? glob.MAGE_ADVANCED_FEE : glob.MAGE_SECOND_BASIC_FEE
	if(!SpendRPP(fee, "[element] Magic", Training = 0))
		mage_buying = 0
		return 0
	MageElement2 = element
	MageForkDone = 1
	mage_buying = 0
	src << "<font color=#8be9ff>[element] joins your grimoire.</font>"
	if(CheckSlotless("Mage Grimoire")) SummonTomes()
	return 1

mob/proc/MageLockIn(element)
	var/why = MageCanFork()
	if(why)
		src << "<font color=red>[why]</font>"
		return 0
	if(MageForkDone)
		src << "<font color=red>The lock-in offer has passed.</font>"
		return 0
	if(!IsAdvancedElement(element))
		src << "<font color=red>Only an advanced element can be locked into.</font>"
		return 0
	if(mage_buying) return 0
	mage_buying = 1
	if(!SpendRPP(glob.MAGE_ADVANCED_FEE, "[element] Magic", Training = 0))
		mage_buying = 0
		return 0
	var/old = MageElement
	var/refund = MageStripElement(old)
	if(refund > 0)
		RPPSpent = max(0, RPPSpent - refund)
		RPPSpendable += refund
		src << "<font color=#78eb78>[Commas(refund)] RPP from your [old] pages returns to you.</font>"
	MageElement = element
	MageElement2 = null
	MageLockedIn = 1
	MageForkDone = 1
	mage_buying = 0
	src << "<font color=#8be9ff>You forsake [old]. [element] alone fills your grimoire now.</font>"
	if(CheckSlotless("Mage Grimoire")) SummonTomes()
	return 1

mob/proc/MageStripElement(element)
	var/refund = 0
	var/list/doomed = list()
	for(var/obj/Skills/S in Skills)
		if(!S.IsSpell || S.SpellElement != element) continue
		doomed += S
	for(var/obj/Skills/S in doomed)
		refund += MagePageCost(S.SpellTier, element)
		DeleteSkill(S)
	if(client) client.RefreshHotbar()
	return refund

mob/proc/MagePageCost(tier, element)
	tier = clamp(tier, 1, 5)
	var/list/L = IsAdvancedElement(element) ? glob.MAGE_PAGE_COST_ADVANCED : glob.MAGE_PAGE_COST_BASIC
	return L[tier]

mob/proc/MagePageLocked(obj/Skills/S)
	if(!IsMage()) return "You are not a Mage."
	if(!S || !S.IsSpell) return "That is not a spell."
	if(!MageOwnsElement(S.SpellElement)) return "You do not command [S.SpellElement]."
	if(S.SpellTier < 1 || S.SpellTier > 5) return "That page has no tier."
	var/tier = S.SpellTier
	var/need = glob.MAGE_PAGE_LEVEL[tier]
	if(SagaLevel < need) return "Tier [tier] pages open at Mage Tier [need]."
	if(tier >= 5 && IsAdvancedElement(S.SpellElement) && !MageLockedIn) return "The [S.SpellElement] pinnacle needs the lock-in."
	var/key = ArcanePageKeyFor(S.SpellElement, S.type)
	if(key)
		var/why = ArcaneNodeReason(S.SpellElement, key)
		if(why) return why
	return null

mob/proc/MageBuyPage(path)
	if(mage_buying)
		src << "Finish your current purchase first."
		return 0
	var/p = ispath(path) ? path : text2path("[path]")
	if(!p) return 0
	if(locate(p) in src)
		src << "You already hold that page."
		return 0
	var/obj/Skills/S = new p
	var/why = MagePageLocked(S)
	if(why)
		src << "<font color=red>[why]</font>"
		del S
		return 0
	var/cost = MagePageCost(S.SpellTier, S.SpellElement)
	mage_buying = 1
	if(!SpendRPP(cost, "[S.name]", Training = 0))
		del S
		mage_buying = 0
		return 0
	var/el = S.SpellElement
	var/before = MageMilestones(el)
	AddSkill(S)
	mage_buying = 0
	if(MageMilestones(el) > before)
		MaxMana()
		src << "<font color=#ffd17d>Your [el] studies deepen: [ArcaneOwnedCount(el)] pages learned. Mana +[glob.MAGE_MILESTONE_MANA], regen +[glob.MAGE_MILESTONE_REGEN].</font>"
	if(client) client.RefreshHotbar()
	return 1

mob/proc/MageClear()
	if(MageElement) MageStripElement(MageElement)
	if(MageElement2) MageStripElement(MageElement2)
	var/obj/Skills/Buffs/SlotlessBuffs/MageGrimoire/G = locate() in src
	if(G)
		if(CheckSlotless("Mage Grimoire")) G.Trigger(src, 1)
		del G
	DismissTomes(0)
	if(IsMage())
		Saga = null
		SagaLevel = 0
	MageElement = null
	MageElement2 = null
	MageForkDone = 0
	MageLockedIn = 0
	MaxMana()

mob/Admin3/verb
	MageAdmin(mob/Players/P in players)
		set category = "Admin"
		set name = "Mage Admin"
		var/list/opts = list("Cancel", "Make Mage", "Tier Up (free)", "Set Element", "Set Second Element", "Clear Mage")
		var/sel = input(src, "Mage debug for [P]: Tier [P.SagaLevel], [P.MageElement ? P.MageElement : "no element"][P.MageElement2 ? " and [P.MageElement2]" : ""]") in opts
		switch(sel)
			if("Make Mage")
				var/e = input(src, "Starting element") in ELEMENT_PHYSICAL
				if(P.BecomeMage(e))
					src << "[P] is now a [e] Mage."
			if("Tier Up (free)")
				if(!P.IsMage())
					src << "[P] is not a Mage."
					return
				if(P.SagaLevel >= glob.MAGE_MAX_LEVEL)
					src << "[P] is already at Mage Tier [glob.MAGE_MAX_LEVEL]."
					return
				P.SagaLevel++
				P.MageOnTierUp()
				src << "[P] is now Mage Tier [P.SagaLevel]."
			if("Set Element")
				if(!P.IsMage())
					src << "[P] is not a Mage."
					return
				var/e = input(src, "Primary element") in ELEMENT_LIST
				if(e == P.MageElement2)
					src << "[P] already commands [e] as their second element."
					return
				P.MageElement = e
				if(P.CheckSlotless("Mage Grimoire")) P.SummonTomes()
				src << "[P] now commands [e]."
			if("Set Second Element")
				if(!P.IsMage())
					src << "[P] is not a Mage."
					return
				var/e = input(src, "Second element") in ELEMENT_LIST
				if(e == P.MageElement)
					src << "[P] already commands [e] as their primary."
					return
				P.MageElement2 = e
				P.MageForkDone = 1
				if(P.CheckSlotless("Mage Grimoire")) P.SummonTomes()
				src << "[P] now also commands [e]."
			if("Clear Mage")
				P.MageClear()
				src << "[P] is no longer a Mage."
