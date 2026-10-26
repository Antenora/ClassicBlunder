/obj/Items/Tech/Door/var/breached = 0
/obj/Items/Tech/Reinforced_Door/var/breached = 0

/obj/Items/Tech/Door/Close()
	if(breached) return
	..()

/obj/Items/Tech/Reinforced_Door/Close()
	if(breached) return
	..()

proc/OrdBreachDoor(obj/D)
	if(istype(D, /obj/Items/Tech/Door))
		var/obj/Items/Tech/Door/X = D
		X.breached = 1
		X.Open()
	else if(istype(D, /obj/Items/Tech/Reinforced_Door))
		var/obj/Items/Tech/Reinforced_Door/R = D
		R.breached = 1
		R.Open()

proc/OrdBreachable(obj/D)
	if(istype(D, /obj/Items/Tech/Door))
		var/obj/Items/Tech/Door/X = D
		if(X.GodDoor || istype(X, /obj/Items/Tech/Door/Guild_Door)) return 0
		return 1
	return istype(D, /obj/Items/Tech/Reinforced_Door)

proc/OrdDoorBreached(obj/D)
	if(istype(D, /obj/Items/Tech/Door))
		var/obj/Items/Tech/Door/X = D
		return X.breached
	if(istype(D, /obj/Items/Tech/Reinforced_Door))
		var/obj/Items/Tech/Reinforced_Door/R = D
		return R.breached
	return 0

mob/proc/BreachTargetDoor()
	var/turf/T = get_step(src, dir)
	if(!T) return null
	for(var/obj/Items/Tech/D in range(2, T))
		if(!OrdBreachable(D)) continue
		if(!OrdBoxOverlap(D, T)) continue
		return D
	return null

mob/proc/OrdnancePlaceMine(obj/Items/Ordnance/I)
	if(!I || !I.mine_type || !isturf(loc)) return 0
	var/obj/Traps/Mine/M = new I.mine_type(loc, src)
	M.step_x = step_x
	M.step_y = step_y
	src << "You set [I.name] at your feet. It arms in [ORD_MINE_ARM / 10] seconds."
	return 1

mob/proc/PlaceBreachingCharge(obj/Items/Ordnance/Breaching_Charge/C)
	if(!C || C.loc != src) return 0
	if(Secret == "Heavenly Restriction" && secretDatum?:hasRestriction("Science")) return 0
	if(KO || Dead) return 0
	if(InCombat())
		src << "<font color='#ff6b6b'>You cannot set a charge in a fight.</font>"
		return 0
	var/obj/D = BreachTargetDoor()
	if(!D)
		src << "<font color='#ff6b6b'>There is no door right in front of you to breach.</font>"
		return 0
	if(OrdDoorBreached(D))
		src << "<font color='#ff6b6b'>[D] is already breached.</font>"
		return 0
	for(var/obj/Traps/Breaching_Charge/B in ord_live_traps)
		if(B.door == D)
			src << "<font color='#ff6b6b'>[D] already has a charge on it.</font>"
			return 0
	var/obj/Traps/Breaching_Charge/B = new(D.loc, src)
	B.door = D
	OMsg(src, "<font color='#ffb347'>[src] fixes a breaching charge to [D]! It will blow in [ORD_BREACH_TIME / 10] seconds.</font>")
	var/alarm = text2path("/proc/AlarmCheck")
	if(alarm) call(alarm)(D, src)
	if(C.Stackable && C.TotalStack > 1)
		C.TotalStack--
		C.suffix = "[C.TotalStack]"
	else
		del C
	if(client) client.BuildInvPage()
	return 1

/obj/Items/Ordnance
	name = "Ordnance"
	icon = 'device.dmi'
	icon_state = ""
	Stackable = 1
	BeltUsable = 1
	BeltConsumes = 1
	BeltCooldown = ORD_BELT_CD
	BeltAlly = 0
	var/throw_skill
	var/mine_type

	BeltUse(mob/user)
		if(!user) return 0
		if(user.Secret == "Heavenly Restriction" && user.secretDatum?:hasRestriction("Science")) return 0
		if(mine_type) return user.OrdnancePlaceMine(src)
		if(throw_skill) return user.OrdnanceThrow(throw_skill) ? 1 : 0
		return 0

	Frag_Grenade
		name = "Frag Grenade"
		icon_state = "timer"
		desc = "A casing packed with propellant. Hold its belt key to throw it; it bursts on impact or at the end of its arc, shredding everyone close by."
		throw_skill = /obj/Skills/Projectile/Ordnance/Frag_Grenade

	Smoke_Grenade
		name = "Smoke Grenade"
		icon_state = "atmos"
		desc = "Fills the area where it lands with thick smoke for a few seconds. Anyone inside is hard to hit and hard to aim at."
		throw_skill = /obj/Skills/Projectile/Ordnance/Smoke_Grenade

	Flash_Grenade
		name = "Flash Grenade"
		icon_state = "flash2"
		desc = "Bursts with a blinding flash that leaves everyone close by confused."
		throw_skill = /obj/Skills/Projectile/Ordnance/Flash_Grenade

	Gas_Grenade
		name = "Gas Grenade"
		icon_state = "hydro"
		desc = "Releases a poison cloud where it lands. It poisons anyone inside who is not sealed in a suit."
		throw_skill = /obj/Skills/Projectile/Ordnance/Gas_Grenade

	EMP_Grenade
		name = "EMP Grenade"
		icon_state = "emp"
		desc = "Releases an electromagnetic pulse that drops shields and drains powered Gear in a wide area."
		throw_skill = /obj/Skills/Projectile/Ordnance/EMP_Grenade

	Flare
		name = "Flare"
		icon_state = "igniter"
		desc = "Thrown a short way, it burns for a minute, lighting the ground and exposing anyone hiding nearby."
		throw_skill = /obj/Skills/Projectile/Ordnance/Flare

	Bola
		name = "Bola"
		icon_state = "bracelet"
		desc = "Weighted cords that wrap around a target's legs. It deals no damage but cripples whoever it catches."
		throw_skill = /obj/Skills/Projectile/Ordnance/Bola

	Caltrops
		name = "Caltrops"
		icon_state = "pinup"
		desc = "A bag of iron spikes. Hold its belt key to scatter them in front of you; anyone who walks over them is crippled."

		BeltUse(mob/user)
			if(!user) return 0
			if(user.Secret == "Heavenly Restriction" && user.secretDatum?:hasRestriction("Science")) return 0
			var/turf/F = get_step(user, user.dir)
			if(!F || F.density)
				user << "<font color='#ff6b6b'>There is no room in front of you to scatter caltrops.</font>"
				return 0
			var/list/spots = list(F, get_step(F, turn(user.dir, 90)), get_step(F, turn(user.dir, -90)))
			var/placed = 0
			for(var/turf/T in spots)
				if(T.density) continue
				new /obj/Traps/Caltrops(T, user)
				placed++
			if(!placed) return 0
			OMsg(user, "[user] scatters caltrops across the ground!")
			return 1

	Frag_Mine
		name = "Frag Mine"
		icon_state = "timer0"
		desc = "Hold its belt key to set it at your feet. It arms after two seconds and bursts like a Frag Grenade under the next enemy to step on it."
		BeltHoldTime = ORD_MINE_HOLD
		mine_type = /obj/Traps/Mine/Frag_Mine

	EMP_Mine
		name = "EMP Mine"
		icon_state = "empar"
		desc = "Hold its belt key to set it at your feet. It arms after two seconds and releases an EMP under the next enemy to step on it."
		BeltHoldTime = ORD_MINE_HOLD
		mine_type = /obj/Traps/Mine/EMP_Mine

	Breaching_Charge
		name = "Breaching Charge"
		icon_state = "electropack0"
		desc = "Click it out of combat while facing a door to fix it in place. Ten seconds later the door is blown open and cannot be closed or locked until it is repaired."
		BeltUsable = 0

		Click()
			if(!(src in usr)) return ..()
			usr.PlaceBreachingCharge(src)
