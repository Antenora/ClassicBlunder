#define QUINCY_HERITAGE_LEVEL 5
#define QUINCY_RANSOTENGAI_IMMUNE 100
#define QUINCY_RANSOTENGAI_AUTO 20
#define QUINCY_BLUT_SWITCH_LOCK 20
#define QUINCY_BLUT_TEAR_LOCK 30
#define QUINCY_BLUT_TEAR_PCT 20
#define QUINCY_ANHAUFER_REFUND 2

mob/var/tmp/QuincyHeritageAsking = 0
mob/var/tmp/QuincyRansotengaiWatching = 0

/mob/Players/QuincyLevelCheck()
	..()
	if(QuincyIsQuincy() && src.QuincyLevel >= QUINCY_HERITAGE_LEVEL && !src.QuincyHeritage)
		spawn()
			if(src)
				QuincyHeritagePrompt()

/mob/proc/QuincyHeritagePrompt()
	if(src.QuincyHeritageAsking || src.QuincyHeritage || !src.client)
		return
	src.QuincyHeritageAsking = 1
	var/pick = Ask(src, "Your Reishi stirs, and the truth of your blood comes to light. This choice is permanent. Echt: Pure blood. Blut runs in your veins; the Kaiser may one day carve a letter into your soul. Gemischt: Mixed blood. The tools of the Ishida line are yours: more tubes, the gatherer's edge, Sprenger.", "Quincy Heritage", null, "pick", list("Echt", "Gemischt"), 1)
	if(!src)
		return
	src.QuincyHeritageAsking = 0
	if(isnull(pick) || src.QuincyHeritage || src.QuincyLevel < QUINCY_HERITAGE_LEVEL)
		return
	if(pick != "Echt" && pick != "Gemischt")
		return
	QuincySetHeritage(pick)

/mob/proc/QuincySetHeritage(h)
	src.QuincyHeritage = h
	if(h == "Echt")
		src << "<font color=#9fd8ff><b>Your blood runs Echt. Blut answers you.</b></font>"
	else
		src << "<font color=#9fd8ff><b>Your blood runs Gemischt. The tools of the Ishida line are yours.</b></font>"
	src.GintoTubes = QuincyGintoMax()
	src.GintoRefillStamp = world.time
	QuincySyncSkills()

/mob/Admin3/verb/Set_Quincy_Heritage()
	set category = "Admin"
	set name = "Set Quincy Heritage"
	var/mob/Players/P = QuincyPickTarget("Set Quincy Heritage")
	if(!P)
		return
	var/pick = Ask(usr, "Set [P]'s heritage. Current: [P.QuincyHeritage ? P.QuincyHeritage : "none"].", "Set Quincy Heritage", null, "pick", list("Echt", "Gemischt"), 1)
	if(isnull(pick) || !P)
		return
	P.QuincySetHeritage(pick)
	P << "<font color=yellow>An admin has set your Quincy heritage to [pick].</font>"
	usr << "<font color=yellow>[P] is now [pick].</font>"
	Log("Admin", "[ExtractInfo(usr)] set [ExtractInfo(P)]'s Quincy heritage to [pick].")

/mob/Players/QuincySyncSkills()
	..()
	var/obj/Skills/Buffs/SlotlessBuffs/Anhaufer/A = QuincyOwnedSkill(/obj/Skills/Buffs/SlotlessBuffs/Anhaufer)
	var/want = QuincyIsQuincy() && src.QuincyHeritage == "Gemischt" && src.QuincyWeapon == "Sword" && src.QuincyLevel >= QUINCY_HERITAGE_LEVEL
	if(want && !A)
		src.AddSkill(new /obj/Skills/Buffs/SlotlessBuffs/Anhaufer)
	else if(!want && A)
		if(src.BuffOn(A))
			A.Trigger(src, 1)
		src.DeleteSkill(A)
	if(src.SprengerStakes && !QuincyOwnedSkill(/obj/Skills/Ginto/Sprenger))
		QuincySprengerClear()

/mob/Players/QuincyFreeRegistry()
	..()
	var/obj/Skills/Buffs/SlotlessBuffs/Anhaufer/A = QuincyOwnedSkill(/obj/Skills/Buffs/SlotlessBuffs/Anhaufer)
	if(A)
		if(src.BuffOn(A))
			A.Trigger(src, 1)
		src.DeleteSkill(A)
	if(src.SprengerStakes)
		QuincySprengerClear()

/obj/Skills/Quincy/Ransotengai
	name = "Ransotengai"
	desc = "Move your body on strings of Reishi. Once per fight."
	Cooldown = -1
	ManaCost = 8

	verb/Ransotengai()
		set name = "Ransotengai"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		RansotengaiFire(User)

	proc/RansotengaiReady()
		return !src.Using && !(src.cooldown_remaining > 0)

	proc/RansotengaiCost(mob/User)
		if(User.HasDrainlessMana())
			return 0
		var/drain = src.ManaCost * User.ChakraCostMult(src) * User.SpellCostMult(src)
		if(drain <= 0)
			drain = 0.5
		return drain

	proc/RansotengaiFire(mob/User)
		if(!ismob(User) || User.KO)
			return 0
		if(!RansotengaiReady())
			User << "<font color=red>[src] is spent until you meditate.</font>"
			return 0
		var/drain = RansotengaiCost(User)
		if(drain && User.ManaAmount < drain)
			User << "You don't have enough mana to use [src]."
			return 0
		if(drain)
			User.LoseMana(drain)
		User.QuincyRansotengaiFree()
		OMsg(User, "[User]'s limbs move on strings of Reishi.")
		src.Cooldown(1, null, User)
		return 1

/mob/proc/QuincyRansotengaiFree()
	src.cc_immune_until = max(src.cc_immune_until, world.time + QUINCY_RANSOTENGAI_IMMUNE)
	if(src.Stunned)
		if(src.CheckSlotless("Mind Dominated") || src.passive_handler["Shellshocked"])
			var/obj/Effects/Stun/st = new
			st.appearance_flags = 66
			src.overlays -= st
			src.overlays -= 'IceCoffin.dmi'
			src.Stunned = 0
			var/mod = src.passive_handler.Get("Juggernaut") * 0.25
			src.StunImmune = world.time + (glob.STUN_IMMUNE_TIMER * (1 + mod))
			if(!src.Launched)
				src.cc_combo_hits = 0
		else
			StunClear(src)
	if(src.Suspended && src.Suspended != "Kageoni")
		src.Suspended = null
		var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/SuspendedOverlay/ov = locate() in src
		if(ov && src.BuffOn(ov))
			ov.Trigger(src, 1)
	if(src.Knockbacked)
		src.StopKB()
	if(src.passive_handler["Disarmed"])
		src.passive_handler.Set("Disarmed", 0)
	src.disarm_timer = 0
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Snare/sn = locate() in src
	if(sn && src.BuffOn(sn))
		sn.Trigger(src, 1)

/mob/proc/QuincyStunnedNow()
	return src.Stunned && src.Stunned > world.time

/mob/proc/QuincyRansotengaiWatch(obj/Skills/Quincy/Ransotengai/R)
	set waitfor = 0
	src.QuincyRansotengaiWatching = 1
	sleep(1)
	if(src && QuincyStunnedNow())
		sleep(QUINCY_RANSOTENGAI_AUTO)
		if(src && R && R.loc == src && QuincyStunnedNow() && R.RansotengaiReady())
			R.RansotengaiFire(src)
	if(src)
		src.QuincyRansotengaiWatching = 0

/strikeHook/quincyRansotengai
	stage = "post"
	fire(strike/S)
		var/mob/d = S.defender
		if(!d || d.QuincyLevel < QUINCY_HERITAGE_LEVEL || d.QuincyRansotengaiWatching)
			return
		var/obj/Skills/Quincy/Ransotengai/R = locate() in d
		if(!R || !R.RansotengaiReady())
			return
		d.QuincyRansotengaiWatch(R)

/obj/Skills/Buffs/SlotlessBuffs/Blut
	name = "Blut"
	BuffName = "Blut Vene"
	Slotless = 1
	passives = list("ManaLeak" = 1)
	DefMult = 1.45
	EndMult = 1.15
	ActiveMessage = "hardens the Reishi in their veins."
	var/mode = "Vene"
	var/tmp/lock_until = 0
	var/tmp/switch_serial = 0
	var/tmp/switch_pending = 0

	adjust(mob/p)
		passives = list("ManaLeak" = 1)
		var/top = p && p.QuincyLevel >= 7
		StrMult = 1
		ForMult = 1
		DefMult = 1
		EndMult = 1
		if(src.mode == "Arterie")
			StrMult = top ? 1.4 : 1.3
			ForMult = top ? 1.4 : 1.3
			DefMult = 0.85
			BuffName = "Blut Arterie"
			ActiveMessage = "pushes Reishi into their blood."
		else
			src.mode = "Vene"
			DefMult = top ? 1.6 : 1.45
			EndMult = 1.15
			BuffName = "Blut Vene"
			ActiveMessage = "hardens the Reishi in their veins."

	verb/Blut()
		set name = "Blut"
		set category = "Skills"
		BlutPress(usr, null)

	verb/Blut_Vene()
		set name = "Blut Vene"
		set category = "Skills"
		BlutPress(usr, "Vene")

	verb/Blut_Arterie()
		set name = "Blut Arterie"
		set category = "Skills"
		BlutPress(usr, "Arterie")

	proc/BlutOther(m)
		return m == "Arterie" ? "Vene" : "Arterie"

	proc/BlutPress(mob/User, want)
		if(!ismob(User))
			return
		if(isnull(want) && src.switch_pending)
			src.switch_pending = 0
			src.switch_serial++
			User << "You let the Reishi settle; Blut stays off."
			return
		var/on = User.BuffOn(src)
		if(isnull(want))
			want = on ? BlutOther(src.mode) : "Vene"
		if(on)
			if(want == src.mode)
				src.Trigger(User)
				return
			src.Trigger(User, 1)
			src.lock_until = world.time + QUINCY_BLUT_SWITCH_LOCK
			User << "Your blood vessels switch channels..."
			BlutQueue(User, want)
			return
		if(src.lock_until > world.time)
			User << "<font color=red>Your blood vessels are still switching channels.</font>"
			return
		src.mode = want
		src.Trigger(User)

	proc/BlutQueue(mob/User, want)
		set waitfor = 0
		var/serial = ++src.switch_serial
		src.switch_pending = 1
		sleep(QUINCY_BLUT_SWITCH_LOCK)
		if(src.switch_serial != serial)
			return
		src.switch_pending = 0
		if(!User || src.loc != User || User.BuffOn(src) || src.lock_until > world.time)
			return
		src.mode = want
		src.Trigger(User)

/mob/Players/AddBleed(var/Value, var/mob/Attacker=null)
	if(Value > 0 && src.QuincyHeritage == "Echt" && src.SlotlessBuffs && src.SlotlessBuffs["Blut Vene"])
		return
	return ..()

/strikeHook/quincyBlutTear
	stage = "post"
	fire(strike/S)
		var/mob/d = S.defender
		if(!d || S.dealt <= 0 || d.QuincyHeritage != "Echt" || !d.SlotlessBuffs)
			return
		var/obj/Skills/Buffs/SlotlessBuffs/Blut/B = d.SlotlessBuffs["Blut Vene"]
		if(!istype(B) || d.HPToPct(S.dealt) <= QUINCY_BLUT_TEAR_PCT)
			return
		B.Trigger(d, 1)
		B.lock_until = world.time + QUINCY_BLUT_TEAR_LOCK
		B.switch_serial++
		B.switch_pending = 0
		OMsg(d, "[d]'s Blut Vene tears!")

/obj/Skills/Buffs/SlotlessBuffs/Anhaufer
	name = "Anhaufer"
	BuffName = "Anhaufer"
	Slotless = 1
	NeedsSword = 1
	ActiveMessage = "gathers the scattered Reishi along their blade."
	OffMessage = "lets the gathered Reishi scatter."

	verb/Anhaufer()
		set name = "Anhaufer"
		set category = "Skills"
		src.Trigger(usr)

/strikeHook/quincyAnhaufer
	stage = "post"
	fire(strike/S)
		var/mob/a = S.attacker
		if(!S.melee || !a || a == S.defender || a.QuincyHeritage != "Gemischt" || !a.SlotlessBuffs || !a.SlotlessBuffs["Anhaufer"])
			return
		a.HealMana(QUINCY_ANHAUFER_REFUND)
