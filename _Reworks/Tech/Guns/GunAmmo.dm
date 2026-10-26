obj/Items/Ammo/Pistol/Training
	name = "Training Pistol Rounds"
	desc = "Soft practice rounds. They sting and never wound, whatever intent is behind the trigger."
	RiderNoInjury = 1
	RiderDamageMult = 0.6

obj/Items/Ammo/Pistol/Hollow_Point
	name = "Hollow-Point Pistol Rounds"
	desc = "Rounds that open up on impact and leave the target bleeding."
	RiderBleed = 1
	RiderDamageMult = 0.9

obj/Items/Ammo/Pistol/Armor_Piercing
	name = "Armor-Piercing Pistol Rounds"
	desc = "Hardened rounds that punch through part of a target's toughness, at the cost of some raw damage."
	RiderPierce = 0.35
	RiderDamageMult = 0.85

obj/Items/Ammo/Pistol/Tranq
	name = "Tranq Pistol Rounds"
	desc = "Sedative darts. Each hit in quick succession slows the target more, up to three times over."
	RiderSlow = 1
	RiderDamageMult = 0.5

obj/Items/Ammo/Pistol/Tracer
	name = "Tracer Pistol Rounds"
	desc = "Rounds that leave a trackable mark on whoever they hit for twenty seconds."
	RiderTag = 1

obj/Items/Ammo/Pistol/EMP
	name = "EMP Pistol Rounds"
	desc = "Rounds carrying an electromagnetic charge. They barely hurt, but they drop shields and drain powered gear."
	RiderEMP = 1
	RiderDamageMult = 0.3

obj/Items/Ammo/Rifle/Training
	name = "Training Rifle Rounds"
	desc = "Soft practice rounds. They sting and never wound, whatever intent is behind the trigger."
	RiderNoInjury = 1
	RiderDamageMult = 0.6

obj/Items/Ammo/Rifle/Hollow_Point
	name = "Hollow-Point Rifle Rounds"
	desc = "Rounds that open up on impact and leave the target bleeding."
	RiderBleed = 1
	RiderDamageMult = 0.9

obj/Items/Ammo/Rifle/Armor_Piercing
	name = "Armor-Piercing Rifle Rounds"
	desc = "Hardened rounds that punch through part of a target's toughness, at the cost of some raw damage."
	RiderPierce = 0.35
	RiderDamageMult = 0.85

obj/Items/Ammo/Rifle/Tranq
	name = "Tranq Rifle Rounds"
	desc = "Sedative darts. Each hit in quick succession slows the target more, up to three times over."
	RiderSlow = 1
	RiderDamageMult = 0.5

obj/Items/Ammo/Rifle/Tracer
	name = "Tracer Rifle Rounds"
	desc = "Rounds that leave a trackable mark on whoever they hit for twenty seconds."
	RiderTag = 1

obj/Items/Ammo/Rifle/EMP
	name = "EMP Rifle Rounds"
	desc = "Rounds carrying an electromagnetic charge. They barely hurt, but they drop shields and drain powered gear."
	RiderEMP = 1
	RiderDamageMult = 0.3

obj/Items/Ammo/Shell/Training
	name = "Training Shells"
	desc = "Shells packed with soft shot. They sting and never wound, whatever intent is behind the trigger."
	RiderNoInjury = 1
	RiderDamageMult = 0.6

obj/Items/Ammo/Shell/Slug
	name = "Slug Shells"
	desc = "A single heavy slug instead of shot. It hits as hard as a full spread and carries twice as far."
	RiderSlug = 1

obj/Items/Ammo/Shell/Dragons_Breath
	name = "Dragon's Breath Shells"
	desc = "Shells packed with incendiary shot. Every pellet that lands sets the target burning."
	RiderBurn = 1
	RiderDamageMult = 0.8

obj/Items/Ammo/var/RiderAntiMateriel = 0

/mob/var/tmp/tracer_tag_until = 0
/mob/var/tmp/tranq_stacks = 0
/mob/var/tmp/tranq_until = 0

mob/proc/IsTracerTagged()
	return tracer_tag_until > world.time

mob/proc/GunTranqHit(amount, mob/shooter)
	if(amount <= 0)
		return
	if(tranq_until <= world.time)
		tranq_stacks = 0
	tranq_stacks = min(tranq_stacks + 1, GUN_TRANQ_STACKS)
	tranq_until = world.time + GUN_TRANQ_WINDOW
	AddSlow(amount * tranq_stacks, shooter)

mob/GunHitMult(mob/victim, obj/Skills/Projectile/_Projectile/P)
	. = ..()
	if(victim && victim.GunWovenVest())
		. *= GUN_WEAVE_MULT

mob/GunOnHit(mob/victim, obj/Skills/Projectile/_Projectile/P)
	..()
	if(!victim || !P)
		return
	var/obj/Skills/Projectile/S = P.from_skill
	if(!istype(S))
		return
	var/obj/Items/Ammo/A = S.gun_ammo
	if(ispath(A, /obj/Items/Ammo))
		if(initial(A.RiderTag))
			victim.tracer_tag_until = world.time + GUN_TRACER_TIME
		var/slow = initial(A.RiderSlow)
		if(slow > 0)
			victim.GunTranqHit(slow, src)
		var/emp = initial(A.RiderEMP)
		if(emp > 0 && hascall(victim, "EMPHit"))
			call(victim, "EMPHit")(emp)
	GunArtOnHit(victim, P, S)
