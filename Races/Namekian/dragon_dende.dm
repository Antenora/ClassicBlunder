/globalTracker/var/NamekElderGiftEnabled = TRUE

/obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Energy_Effect
	name = "Kami's Energy"
	BuffName = "Kami's Energy"
	Copyable = 0
	Cooldown = 0
	SilentCast = 1
	TimerLimit = 20
	ForMult = 1.1
	ActiveMessage = "surges with Kami's Energy!"
	OffMessage = "feels Kami's Energy ebb away."

/obj/Skills/Buffs/SlotlessBuffs/Namekian/Unleashed_Spirit_Effect
	name = "Unleashed Spirit"
	BuffName = "Unleashed Spirit"
	Copyable = 0
	Cooldown = 0
	SilentCast = 1
	TimerLimit = 600
	ActiveMessage = "feels their spirit unleashed!"
	OffMessage = "feels their spirit settle back to its old limits."

/obj/Skills/Utility/Namekian/Super_Healing_Wave
	name = "Super Healing Wave"
	desc = "Channel for two seconds, then heal your targeted party member for 40 percent of their health, or yourself if you target no ally. Costs double mana on an evil heart."
	Copyable = 0
	ManaCost = 8
	Cooldown = 32
	var/HealAmount = 40
	var/CastTime = 20
	var/SupportRange = 10

	verb/Super_Healing_Wave()
		set name = "Super Healing Wave"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekTargetHealStart(src, src.HealAmount, src.CastTime, src.SupportRange)

/obj/Skills/Utility/Namekian/Kamis_Mercy
	name = "Kami's Mercy"
	desc = "Heal every party member within three tiles, yourself included, for 20 percent of their health. Costs double mana if any of them has an evil heart."
	Copyable = 0
	ManaCost = 10
	Cooldown = 15
	var/HealAmount = 20
	var/MercyRange = 3

	verb/Kamis_Mercy()
		set name = "Kamis Mercy"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekKamisMercy(src)

/mob/proc/NamekKamisMercy(obj/Skills/Utility/Namekian/Kamis_Mercy/S)
	if(!NamekCastReady(S))
		return
	var/list/allies = NamekAllies(S.MercyRange)
	var/drain = NamekManaDrain(S, NamekAnyEvil(allies))
	if(!NamekHasMana(S, drain))
		return
	NamekSpendMana(drain)
	for(var/mob/m in allies)
		m.HealHealth(S.HealAmount)
		NamekSupportFX(m)
	src.OMessage(10, "[src] spreads Kami's Mercy over everyone around them!", "<font color=green>[src]([src.key]) heals [allies.len] allies with Kami's Mercy.")
	S.Cooldown(1, null, src)

/obj/Skills/Utility/Namekian/Divine_Cure
	name = "Divine Cure"
	desc = "Purge bleeding, burning, poison, chill and shock from your targeted party member, or from yourself if you target no ally."
	Copyable = 0
	ManaCost = 4
	Cooldown = 20
	var/SupportRange = 10

	verb/Divine_Cure()
		set name = "Divine Cure"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekDivineCure(src)

/mob/proc/NamekDivineCure(obj/Skills/Utility/Namekian/Divine_Cure/S)
	if(!NamekCastReady(S))
		return
	var/mob/T = NamekSupportTarget(S.SupportRange)
	var/drain = NamekManaDrain(S)
	if(!NamekHasMana(S, drain))
		return
	NamekSpendMana(drain)
	T.NamekCleanseGauges(0)
	NamekSupportFX(T)
	src.OMessage(10, "[src] purges the ailments from [T == src ? "their own body" : T]!", "<font color=green>[src]([src.key]) cleanses [T] with Divine Cure.")
	S.Cooldown(1, null, src)

/obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Healing_Technique
	name = "Kami's Healing Technique"
	BuffName = "Kami's Healing Technique"
	desc = "Open your body to Kami's healing arts: every heal you receive is 50 percent stronger for two minutes."
	Copyable = 0
	ManaCost = 3
	Cooldown = 30
	TimerLimit = 120
	ActiveMessage = "opens their body to Kami's healing arts!"
	OffMessage = "lets Kami's healing arts settle."
	var/HealReceivedMult = 1.5

	verb/Kamis_Healing_Technique()
		set name = "Kamis Healing Technique"
		set category = "Skills"
		src.Trigger(usr)

/mob/proc/NamekHealReceivedMult()
	var/obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Healing_Technique/B = src.SlotlessBuffs["Kami's Healing Technique"]
	if(istype(B) && B.SlotlessOn)
		return B.HealReceivedMult
	return 1

/mob/Players/HealAfterCuts(val)
	. = ..()
	if(. > 0)
		. *= NamekHealReceivedMult()

/obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Aurora
	name = "Kami's Aurora"
	BuffName = "Kami's Aurora"
	desc = "Radiate Kami's Aurora for twenty seconds: you and every party member within two tiles regain 2 percent energy each second."
	Copyable = 0
	ManaCost = 8
	Cooldown = 30
	TimerLimit = 20
	ActiveMessage = "radiates Kami's Aurora, restoring the energy of those around them!"
	OffMessage = "lets Kami's Aurora fade."
	var/AuroraRange = 2
	var/AuroraEnergyPct = 2
	var/tmp/AuroraStamp = 0

	Trigger(mob/User, Override = 0)
		. = ..()
		if(src.SlotlessOn && ismob(User))
			User.NamekAuroraLoop(src)

	verb/Kamis_Aurora()
		set name = "Kamis Aurora"
		set category = "Skills"
		src.Trigger(usr)

/mob/proc/NamekAuroraLoop(obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Aurora/B)
	set waitfor = 0
	var/stamp = world.time
	B.AuroraStamp = stamp
	var/until = world.time + B.TimerLimit * 10
	while(world.time < until)
		sleep(10)
		if(!B || !B.SlotlessOn || B.AuroraStamp != stamp)
			return
		if(src.KO || src.Dead)
			break
		for(var/mob/m in NamekAllies(B.AuroraRange))
			m.HealEnergy(B.AuroraEnergyPct, 1)
	if(B && B.SlotlessOn && B.AuroraStamp == stamp)
		B.Trigger(src, Override = 1)

/obj/Skills/Utility/Namekian/Kamis_Energy
	name = "Kami's Energy"
	desc = "Pour 10 percent of your own health into every party member in view, yourself included: their Force rises by 10 percent for twenty seconds."
	Copyable = 0
	Cooldown = 60
	var/HealthCostPct = 10
	var/ForceMult = 1.1
	var/EnergyTime = 20
	var/PartyRange = 10

	verb/Kamis_Energy()
		set name = "Kamis Energy"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekKamisEnergy(src)

/mob/proc/NamekKamisEnergy(obj/Skills/Utility/Namekian/Kamis_Energy/S)
	if(!NamekCastReady(S))
		return
	if(src.HealthPct() <= S.HealthCostPct)
		src << "You are too hurt to give away any more of your health."
		return
	var/list/allies = NamekAllies(S.PartyRange)
	src.DamageSelf(S.HealthCostPct)
	for(var/mob/m in allies)
		var/obj/Skills/Buffs/B = NamekEffect(/obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Energy_Effect, S.EnergyTime)
		B.ForMult = S.ForceMult
		NamekGiveEffect(m, B)
		NamekSupportFX(m)
	src.OMessage(10, "[src] pours their own life into Kami's Energy!", "<font color=green>[src]([src.key]) casts Kami's Energy on [allies.len] allies.")
	S.Cooldown(1, null, src)

/obj/Skills/Utility/Namekian/Unleashed_Spirit
	name = "Unleashed Spirit"
	desc = "Unleash the spirit of every party member in view, yourself included: their maximum health and maximum energy rise by 10 percent for ten minutes. Costs double mana if any of them has an evil heart."
	Copyable = 0
	ManaCost = 8
	Cooldown = 60
	var/SpiritShare = 0.1
	var/SpiritEnergy = 10
	var/SpiritTime = 600
	var/PartyRange = 10

	verb/Unleashed_Spirit()
		set name = "Unleashed Spirit"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekUnleashedSpirit(src)

/mob/proc/NamekUnleashedSpirit(obj/Skills/Utility/Namekian/Unleashed_Spirit/S)
	if(!NamekCastReady(S))
		return
	var/list/allies = NamekAllies(S.PartyRange)
	var/drain = NamekManaDrain(S, NamekAnyEvil(allies))
	if(!NamekHasMana(S, drain))
		return
	NamekSpendMana(drain)
	for(var/mob/m in allies)
		NamekGiveEffect(m, NamekEffect(/obj/Skills/Buffs/SlotlessBuffs/Namekian/Unleashed_Spirit_Effect, S.SpiritTime, list("Vigor" = m.NamekVigorFor(S.SpiritShare), "MaxEnergyBonus" = S.SpiritEnergy)))
		NamekSupportFX(m)
	src.OMessage(10, "[src] unleashes the spirit of their allies!", "<font color=green>[src]([src.key]) casts Unleashed Spirit on [allies.len] allies.")
	S.Cooldown(1, null, src)

/obj/Skills/Utility/Namekian/Instantaneous_Movement
	name = "Instantaneous Movement"
	desc = "Kai Kai: vanish and reappear beside a party member of your choice, wherever they are."
	Copyable = 0
	ManaCost = 15
	Cooldown = 300

	verb/Instantaneous_Movement()
		set name = "Instantaneous Movement"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekInstantMove(src)

/mob/proc/NamekTeleportAllowed()
	if(glob.DISABLE_ALL_TELEPORTS)
		src << "The ability to teleport has been sealed off!"
		return 0
	if(src.Dead && !src.KeepBody)
		src << "You cannot teleport while dead."
		return 0
	if(src.movementSealed)
		src << "You can't teleport while your movement is sealed!"
		return 0
	if(src.Grab)
		src << "You can't teleport while holding someone."
		return 0
	if(src.NoTPZone())
		src << "You cannot teleport on this plane!"
		return 0
	return 1

/mob/proc/NamekCanReachForKaiKai(mob/m)
	if(!ismob(m) || m == src || !m.loc || m.NoTPZone())
		return 0
	if(m.z == 17 && !(locate(/obj/Skills/Teleport/Traverse_Daat) in src))
		return 0
	return 1

/mob/proc/NamekLandingBeside(mob/T)
	var/list/dirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
	while(dirs.len)
		var/d = pick(dirs)
		dirs -= d
		var/turf/W = src.ComboLandingClear(T, d)
		if(W)
			return W
	return null

/mob/proc/NamekInstantMove(obj/Skills/Utility/Namekian/Instantaneous_Movement/S)
	if(!NamekCastReady(S) || !NamekTeleportAllowed())
		return
	var/drain = NamekManaDrain(S)
	if(!NamekHasMana(S, drain))
		return
	var/list/pool = list()
	if(src.party && src.party.members)
		for(var/mob/m in src.party.members)
			if(NamekCanReachForKaiKai(m))
				pool += m
	if(!pool.len)
		src << "You have no party member you can reach."
		return
	var/list/lab = PromptLabelAtoms(pool, 1)
	var/choice = Ask(src, "Teleport to which party member?", "[S]", null, "pick", lab, 1)
	if(isnull(choice))
		return
	var/mob/T = lab[choice]
	if(!NamekCanReachForKaiKai(T))
		src << "You can no longer reach them."
		return
	if(!NamekCastReady(S) || !NamekTeleportAllowed())
		return
	drain = NamekManaDrain(S)
	if(!NamekHasMana(S, drain))
		return
	var/turf/W = NamekLandingBeside(T)
	if(!W)
		src << "There is no room to appear beside [T]."
		return
	NamekSpendMana(drain)
	src.OMessage(10, "[src] vanishes in an instant!", "<font color=green>[src]([src.key]) uses Instantaneous Movement to reach [T]([T.key]).")
	src.loc = W
	if(PmActive())
		src.step_x = T.step_x
		src.step_y = T.step_y
	var/face = get_dir(src, T)
	if(face)
		src.dir = face
	GfxBcHolderMoved(src)
	src.OMessage(10, "[src] appears beside [T] in an instant!")
	S.Cooldown(1, null, src)

/obj/Skills/Utility/Namekian/Kamis_Revival
	name = "Kami's Revival"
	desc = "Channel for five seconds over a knocked-out party member in view: they rise with 50 percent health. Your target goes first, otherwise the nearest fallen ally. Costs double mana on an evil heart."
	Copyable = 0
	ManaCost = 25
	Cooldown = 600
	var/ReviveHealthPct = 50
	var/CastTime = 50
	var/SupportRange = 10

	verb/Kamis_Revival()
		set name = "Kamis Revival"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekReviveStart(src, src.ReviveHealthPct, src.CastTime, src.SupportRange)

/obj/Skills/Utility/Namekian/Draw_Out_Potential
	name = "Draw Out Potential"
	desc = "Lay a hand on a nearby fighter and channel for ten seconds to unlock a sliver of their hidden power for good. Each person can receive it once, and you can give it five times. Costs double mana on an evil heart."
	Copyable = 0
	ManaCost = 50
	var/GiftAmount = 0.05
	var/GiftLimit = 5
	var/CastTime = 100
	var/GiftRange = 3

	verb/Draw_Out_Potential()
		set name = "Draw Out Potential"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekDrawOutStart(src)

/mob/proc/NamekGiftRefusal(obj/Skills/Utility/Namekian/Draw_Out_Potential/S, mob/T)
	if(!glob.NamekElderGiftEnabled)
		return "The elder's gift is sealed for now."
	if(src.NamekPotentialGiven >= S.GiftLimit)
		return "You have already drawn out the potential of [S.GiftLimit] people."
	if(T == src)
		return "You cannot draw out your own potential."
	if(T && T.NamekPotentialReceived)
		return "[T]'s potential has already been drawn out."
	return null

/mob/proc/NamekGiftCandidates(range)
	var/list/out = list()
	for(var/mob/Players/P in view(range, src))
		if(P == src || P.KO || P.Dead || P.NamekPotentialReceived)
			continue
		out += P
	return out

/mob/proc/NamekGrantGift(mob/T, amount)
	T.NamekMoveMagnified(amount)
	T.NamekPotentialReceived = 1
	src.NamekPotentialGiven++

/mob/proc/NamekDrawOutStart(obj/Skills/Utility/Namekian/Draw_Out_Potential/S)
	if(!NamekCastReady(S))
		return
	var/why = NamekGiftRefusal(S)
	if(why)
		src << why
		return
	var/list/pool = NamekGiftCandidates(S.GiftRange)
	if(!pool.len)
		src << "There is no one close enough whose potential is still sealed."
		return
	var/list/lab = PromptLabelAtoms(pool, 1)
	var/choice = Ask(src, "Whose potential will you draw out?", "[S]", null, "pick", lab, 1)
	if(isnull(choice))
		return
	var/mob/T = lab[choice]
	if(!ismob(T) || !NamekCastReady(S))
		return
	why = NamekGiftRefusal(S, T)
	if(why)
		src << why
		return
	var/drain = NamekManaDrain(S, T.IsEvil())
	if(!NamekHasMana(S, drain))
		return
	S.Using = 1
	spawn()
		NamekDrawOutCast(S, T)

/mob/proc/NamekDrawOutCast(obj/Skills/Utility/Namekian/Draw_Out_Potential/S, mob/T)
	src.OMessage(10, "[src] lays a hand on [T]'s head and reaches for the power sleeping inside...", "<font color=green>[src]([src.key]) begins Draw Out Potential on [T]([T.key]).")
	if(!NamekChannel(S, S.CastTime, T, S.GiftRange))
		return
	var/why = NamekGiftRefusal(S, T)
	if(why)
		src << why
		return
	var/drain = NamekManaDrain(S, T.IsEvil())
	if(!NamekHasMana(S, drain))
		return
	NamekSpendMana(drain)
	NamekGrantGift(T, S.GiftAmount)
	NamekSupportFX(T)
	src.OMessage(15, "[T]'s hidden potential surges to the surface!", "<font color=green>[src]([src.key]) draws out [T]([T.key])'s potential ([src.NamekPotentialGiven] of [S.GiftLimit]).")
	S.Cooldown(1, null, src)

/obj/Skills/Utility/Namekian/Final_Healing_Wave
	name = "Final Healing Wave"
	desc = "Restore your targeted party member, or yourself, to full health and purge every ailment gauge. Costs double mana on an evil heart."
	Copyable = 0
	ManaCost = 30
	Cooldown = 600
	var/SupportRange = 10

	verb/Final_Healing_Wave()
		set name = "Final Healing Wave"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekFinalHealingWave(src)

/mob/proc/NamekFinalHealingWave(obj/Skills/Utility/Namekian/Final_Healing_Wave/S)
	if(!NamekCastReady(S))
		return
	var/mob/T = NamekSupportTarget(S.SupportRange)
	var/drain = NamekManaDrain(S, T.IsEvil())
	if(!NamekHasMana(S, drain))
		return
	NamekSpendMana(drain)
	T.HealHealth(100)
	T.NamekCleanseGauges(1)
	NamekSupportFX(T)
	src.OMessage(15, "[src] restores [T == src ? "themselves" : T] completely with a Final Healing Wave!", "<font color=green>[src]([src.key]) uses Final Healing Wave on [T].")
	S.Cooldown(1, null, src)

/mob/Admin3/verb/Toggle_Elder_Gift()
	set category = "Admin"
	set name = "Toggle Elder Gift"
	glob.NamekElderGiftEnabled = !glob.NamekElderGiftEnabled
	usr << "<font color=yellow>Draw Out Potential is now [glob.NamekElderGiftEnabled ? "enabled" : "disabled"].</font>"
