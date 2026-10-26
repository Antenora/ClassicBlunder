mob/var/tmp/mech_chaff_until = 0

/obj/Items/MechPart/Back
	var/thrust_charges = 0
	var/thrust_len_mult = 0
	var/thrust_attack = 0
	var/thrust_ram = 0
	var/thrust_heat = 0
	var/attack_mult = 0
	var/ram_mult = 0
	var/ram_kb = 0
	var/front_cut = 0
	var/grants_flight = 0
	var/extra_melee_hits = 0
	var/extra_melee_mult = 1

	Booster_Pack
		name = "Booster Pack"
		desc = "Extra thrusters for a mech's Back. Thrust gains a second charge and a burst half again as long, and the burst strikes everything it passes through at 1.2x STR. 8 heat per burst."
		heat_cost = 8
		thrust_charges = 2
		thrust_len_mult = 1.5
		thrust_attack = 1
		thrust_heat = 8
		attack_mult = 1.2

	Shoulder_Ram
		name = "Shoulder Ram"
		desc = "An armored ram for a mech's Back. Thrust becomes a charge: whatever it hits takes damage that grows with your speed and is knocked back 3 tiles. 10 heat per burst."
		heat_cost = 10
		thrust_ram = 1
		thrust_heat = 10
		ram_mult = 1
		ram_kb = 3

	Chaff_and_Smoke
		name = "Chaff and Smoke"
		desc = "A countermeasure launcher for a mech's Back. Grants Chaff and Smoke: a cloud of smoke over the 3 by 3 tiles around you, and 4 seconds in which homing shots lose track of you. 10 heat."
		heat_cost = 10
		Techniques = list(/obj/Skills/Mech/Chaff_and_Smoke)

	Heat_Sink_Fins
		name = "Heat Sink Fins"
		desc = "Radiator fins for a mech's Back. The mech sheds 3 more heat every second."
		dissipation_flat = 3

	Back_Shield
		name = "Back Shield"
		desc = "A shoulder-mounted shield for a mech's Back. Hits from your front arc deal 25 percent less, on top of any other frontal cut."
		front_cut = 0.25

	Wing_Binder
		name = "Wing Binder"
		desc = "A flight pack for a mech's Back. Any model can fly with it fitted, Thrust included. Flyers gain nothing more."
		part_tier = MECH_TIER_WALKER
		grants_flight = 1

	Sub_Arms
		name = "Sub-Arms"
		desc = "A pair of extra arms for a mech's Back. Each Normal Attack lands one more hit at 0.6x damage."
		part_tier = MECH_TIER_WALKER
		extra_melee_hits = 1
		extra_melee_mult = 0.6

/obj/Traps/Smoke_Cloud/Mech
	lifetime = 60

/obj/Skills/AutoHit/Mech_Thrust_Hit
	name = "Thrust Strike"
	Area = "Target"
	Distance = 2
	StrScaling = 1
	DamageMult = 1
	Knockback = 0
	NoGCD = 1
	Cooldown = 0

/obj/Skills/Mech/Chaff_and_Smoke
	name = "Chaff and Smoke"
	desc = "Blow smoke over the 3 by 3 tiles around you for 6 seconds and scatter chaff: for 4 seconds, homing shots aimed at you lose their lock. 10 heat."
	Cooldown = 12
	mech_heat = 10
	mech_ranged = 1
	var/chaff_ds = 40
	verb/Chaff_and_Smoke()
		set category = "Skills"
		usr.MechPartUse(src)
	MechFire(mob/p, noGCD = FALSE)
		if(!p.MechSkillGo(src, noGCD)) return 0
		var/turf/T = get_turf(p)
		if(!T) return 0
		Cooldown(1, null, p)
		OrdSpreadClouds(/obj/Traps/Smoke_Cloud/Mech, p, T)
		p.mech_chaff_until = world.time + chaff_ds
		OMsg(p, "[p] bursts chaff and smoke!")
		return 1

/obj/Skills/Projectile/_Projectile/HomingBroken(atom/target)
	if(ismob(target))
		var/mob/M = target
		if(M.mech_chaff_until > world.time) return 1
	return ..()

mob/Players/MechThrustHeat()
	. = ..()
	var/h = 0
	for(var/obj/Items/MechPart/Back/P in MechAllParts())
		if(P.thrust_heat > h) h = P.thrust_heat
	if(h) . = h * MechThrustHeatMult()

mob/Players/MechThrustCrossed(mob/M)
	..()
	if(!mech || !M || M == src || M.KO || M.Dead) return
	var/mult = 0
	var/kb = 0
	for(var/obj/Items/MechPart/Back/P in MechAllParts())
		if(mech_thrust_attack && P.thrust_attack) mult = max(mult, P.attack_mult)
		if(mech_thrust_ram && P.thrust_ram)
			var/v = MechVmax()
			mult = max(mult, P.ram_mult * (v > 0 ? MechSpeed() / v : 1))
			kb = max(kb, P.ram_kb)
	if(mult > 0) MechThrustStrike(M, mult, kb)

mob/proc/MechThrustStrike(mob/M, mult, kb)
	if(!mech || !M) return 0
	var/obj/Skills/AutoHit/Mech_Thrust_Hit/S = mech.MechKept(/obj/Skills/AutoHit/Mech_Thrust_Hit)
	if(S.loc != src) AddSkill(S)
	else if(!(S in Skills)) AddSkill(S, 1)
	S.DamageMult = mult
	S.Knockback = kb
	S.Distance = max(1, get_dist(src, M) + 1)
	var/was = Target
	Target = M
	. = Activate(S, ignoreCuck = TRUE, ignoreAttackLock = TRUE, noGCD = TRUE)
	Target = was

mob/proc/MechExtraHitMult(i)
	if(!mech) return 1
	var/n = MECH_BAKED_MELEE_HITS[mech.model]
	if(i <= (isnum(n) ? n - 1 : 0)) return 1
	. = 1
	for(var/obj/Items/MechPart/Back/P in MechAllParts())
		if(P.extra_melee_hits > 0) . = min(., P.extra_melee_mult)

/mob/Players/Melee1(dmgmulti=1, spdmulti=1, iconoverlay, forcewarp, forcedTarget=null, ExtendoAttack=null, SecondStrike, ThirdStrike, AsuraStrike, accmulti=1, SureKB=0, NoKB=0, IgnoreCounter=0, BreakAttackRate=0, hitback = 0, WhipOnly = 0)
	if(mech && (SecondStrike || ThirdStrike) && !AsuraStrike) dmgmulti *= MechExtraHitMult(ThirdStrike ? 2 : 1)
	return ..(dmgmulti, spdmulti, iconoverlay, forcewarp, forcedTarget, ExtendoAttack, SecondStrike, ThirdStrike, AsuraStrike, accmulti, SureKB, NoKB, IgnoreCounter, BreakAttackRate, hitback, WhipOnly)

mob/Players/MechFrontCut()
	. = ..()
	if(!mech) return
	for(var/obj/Items/MechPart/Back/P in MechAllParts())
		. += P.front_cut
