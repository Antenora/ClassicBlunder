#define QUINCY_VOLL_LEVEL 6
#define QUINCY_SKLAVEREI_LEVEL 7
#define QUINCY_VOLL_MULT 1.3
#define QUINCY_VOLL_MANALEAK 3
#define QUINCY_VOLL_FATIGUE_COST 5
#define QUINCY_VOLL_FATIGUE_EVERY 100
#define QUINCY_VOLL_FATIGUE_TICK 1
#define QUINCY_VOLL_FATIGUE_END 90
#define QUINCY_SKLAVEREI_TICK 20
#define QUINCY_SKLAVEREI_RANGE 4
#define QUINCY_SKLAVEREI_DRAIN 3
#define QUINCY_SKLAVEREI_DRAIN_MAX 5
#define QUINCY_VOLL_ABSORB_MANA 3
#define QUINCY_VOLL_ABSORB_HEAL 2
#define QUINCY_VOLL_HALO_PCT 25
#define QUINCY_VOLL_VOLLEY_MULT 2
#define QUINCY_VOLL_HIREN_CHARGES 4
#define QUINCY_VOLL_HIREN_CHARGES_MAX 6

mob/var/tmp/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/QuincyVollstandigBuff
mob/var/tmp/QuincySklavereiGen = 0

/obj/Skills/Buffs/SlotlessBuffs/Vollstandig
	name = "Vollstandig"
	BuffName = "Vollstandig"
	Slotless = 1
	IsVollstandig = 1
	StrMult = QUINCY_VOLL_MULT
	EndMult = QUINCY_VOLL_MULT
	SpdMult = QUINCY_VOLL_MULT
	ForMult = QUINCY_VOLL_MULT
	OffMult = QUINCY_VOLL_MULT
	DefMult = QUINCY_VOLL_MULT
	passives = list("ManaLeak" = QUINCY_VOLL_MANALEAK)
	FatigueCost = QUINCY_VOLL_FATIGUE_COST
	FlashChange = 1
	var/form_name = "Vollstandig"
	var/letter
	var/tmp/prev_flying = 0

	adjust(mob/p)
		ActiveMessage = "enters [form_name]. A pillar of light, wings of Reishi, and a halo."
		CustomOff = "[p]'s wings dissolve into the air."

	verb/Quincy_Vollstandig()
		set name = "Quincy Vollstandig"
		set category = "Skills"
		if(src.SlotlessOn)
			src.Trigger(usr)
			return
		if(!usr.QuincyVollstandigReady())
			return
		src.Trigger(usr)

/mob/proc/QuincyVollstandigType()
	return /obj/Skills/Buffs/SlotlessBuffs/Vollstandig

/mob/proc/QuincyVollstandigOnNow()
	var/obj/Skills/Buffs/V = src.QuincyVollstandigBuff
	return V && V.SlotlessOn

/mob/proc/QuincyVollstandigReady()
	if(src.QuincyHeritage != "Echt" || src.QuincyLevel < QUINCY_VOLL_LEVEL)
		src << "Only an Echt Quincy at Signature Mastery Level 6 can reach Vollstandig."
		return 0
	if(!QuincyWeaponDrawn())
		src << "Draw your Spirit Weapon first."
		return 0
	if(src.QuincyLetztActive)
		src << "Letzt Stil already burns through your Reishi."
		return 0
	var/seal = text2path("/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Quincy_Seal")
	if(seal && (locate(seal) in src))
		src << "Your body has sealed itself off from the Reishi."
		return 0
	if(src.QuincyVollstandigBlockedUntil > world.realtime)
		src << "Auswahlen has taken this from you for now."
		return 0
	return 1

/mob/Players/QuincySyncSkills()
	..()
	QuincyVollstandigSync()

/mob/proc/QuincyVollstandigSync()
	var/want
	if(QuincyIsQuincy() && src.QuincyHeritage == "Echt" && src.QuincyLevel >= QUINCY_VOLL_LEVEL)
		want = QuincyVollstandigType()
		if(!ispath(want, /obj/Skills/Buffs/SlotlessBuffs/Vollstandig))
			want = null
	var/list/drop = list()
	var/kept = 0
	for(var/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/V in src)
		if(want && !kept && V.type == want)
			kept = 1
			continue
		drop += V
	for(var/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/V in drop)
		if(V.SlotlessOn)
			V.Trigger(src, 1)
		src.DeleteSkill(V)
	if(want && !kept)
		src.AddSkill(new want)
	var/obj/Skills/Hoho/Hirenkyaku/H = locate(/obj/Skills/Hoho/Hirenkyaku) in src
	if(H)
		H.MaxCharges = src.QuincyLevel >= QUINCY_SKLAVEREI_LEVEL ? QUINCY_VOLL_HIREN_CHARGES_MAX : QUINCY_VOLL_HIREN_CHARGES
		H.Charges = min(H.Charges, H.MaxCharges)

/mob/Players/AllSkillsAdd(var/obj/Skills/Buffs/B)
	. = ..()
	if(istype(B, /obj/Skills/Buffs/SlotlessBuffs/Vollstandig))
		QuincyVollstandigOn(B)

/mob/Players/AllSkillsRemove(obj/Skills/Buffs/B)
	. = ..()
	if(istype(B, /obj/Skills/Buffs/SlotlessBuffs/Vollstandig))
		QuincyVollstandigOff(B)

/mob/Players/Logout()
	QuincyVollstandigEnd()
	..()

/mob/Players/Login()
	..()
	spawn(30)
		if(src && !src.QuincyVollstandigBuff)
			QuincyVollstandigEnd()

/mob/proc/QuincyVollstandigEnd()
	for(var/obj/Skills/Buffs/SlotlessBuffs/Vollstandig/V in src)
		if(V.SlotlessOn)
			V.Trigger(src, 1)

/mob/proc/QuincyVollstandigOn(obj/Skills/Buffs/SlotlessBuffs/Vollstandig/V)
	src.QuincyVollstandigBuff = V
	src.HaloBroken = 0
	V.prev_flying = src.Flying ? 1 : 0
	src.Flying = 1
	QuincySklavereiLoop(V)

/mob/proc/QuincyVollstandigOff(obj/Skills/Buffs/SlotlessBuffs/Vollstandig/V)
	if(src.QuincyVollstandigBuff == V)
		src.QuincyVollstandigBuff = null
	src.QuincySklavereiGen++
	src.HaloBroken = 0
	if(!V.prev_flying)
		src.Flying = 0
	V.prev_flying = 0

/mob/proc/QuincySklavereiLoop(obj/Skills/Buffs/SlotlessBuffs/Vollstandig/V)
	set waitfor = 0
	var/gen = ++src.QuincySklavereiGen
	var/elapsed = 0
	while(src && V && V.SlotlessOn && src.QuincySklavereiGen == gen)
		sleep(QUINCY_SKLAVEREI_TICK)
		if(!src || !V || !V.SlotlessOn || src.QuincySklavereiGen != gen)
			return
		if(!src.HaloBroken)
			QuincySklavereiDrain()
		elapsed += QUINCY_SKLAVEREI_TICK
		if(elapsed >= QUINCY_VOLL_FATIGUE_EVERY)
			elapsed -= QUINCY_VOLL_FATIGUE_EVERY
			src.TotalFatigue = min(100, src.TotalFatigue + QUINCY_VOLL_FATIGUE_TICK)
			src.MaxEnergy()
		if(src.TotalFatigue >= QUINCY_VOLL_FATIGUE_END)
			src << "Your stamina gives out."
			V.Trigger(src, 1)
			return

/mob/proc/QuincySklavereiDrain()
	var/amt = src.QuincyLevel >= QUINCY_SKLAVEREI_LEVEL ? QUINCY_SKLAVEREI_DRAIN_MAX : QUINCY_SKLAVEREI_DRAIN
	var/gained = 0
	for(var/mob/m in range(QUINCY_SKLAVEREI_RANGE, src))
		if(m == src || m.KO || m.Dead || m.ManaAmount <= 0 || QuincyVollstandigAlly(m))
			continue
		var/before = m.ManaAmount
		m.LoseMana(amt)
		gained += max(0, before - m.ManaAmount)
	if(gained > 0)
		QuincyVollstandigGainMana(gained)
	return gained

/mob/proc/QuincyVollstandigAlly(mob/m)
	if(m == src)
		return 1
	if(m.ckey && src.inParty(m.ckey))
		return 1
	if(m in src.ai_followers)
		return 1
	if(src in m.ai_followers)
		return 1
	if(istype(m, /mob/Player/AI))
		var/mob/Player/AI/ai = m
		if(!ai.ai_team_fire && ai.AllianceCheck(src))
			return 1
	return 0

/mob/proc/QuincyVollstandigGainMana(val)
	src.ManaAmount += val
	src.MaxMana()

/mob/proc/QuincyVollstandigAbsorbs(obj/Skills/Projectile/_Projectile/P)
	if(!P || P.Area == "Beam" || src.HaloBroken || !QuincyVollstandigOnNow())
		return 0
	if(src.Airborne || src.proj_immune_until > world.time)
		return 0
	if(P.Owner == src || P.SweepAllySkip(src))
		return 0
	return 1

/mob/proc/QuincyVollstandigAbsorb()
	QuincyVollstandigGainMana(QUINCY_VOLL_ABSORB_MANA)
	if(src.QuincyLevel >= QUINCY_SKLAVEREI_LEVEL)
		src.HealPct(QUINCY_VOLL_ABSORB_HEAL)
		src.MaxHealth()
	OMsg(src, "[src] drinks the shot into their wings.")

/strikeHook/quincyVollstandigHalo
	stage = "post"
	fire(strike/S)
		var/mob/d = S.defender
		if(!d || d.HaloBroken || !d.QuincyVollstandigOnNow())
			return
		if(d.HPToPct(S.dealt) <= QUINCY_VOLL_HALO_PCT)
			return
		d.HaloBroken = 1
		OMsg(d, "[d]'s Heiligenschein shatters!")
