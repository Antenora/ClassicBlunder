/mob/proc/NamekFoeInReach(mob/T, range, obj/Skills/S)
	if(!ismob(T) || T == src || T.Dead || T.z != src.z)
		src << "You need a target to use [S]."
		return 0
	if(get_dist(src, T) > range)
		src << "[T] is too far away for [S]."
		return 0
	return 1

/mob/proc/NamekPayEnergy(obj/Skills/S)
	if(!S || !S.EnergyCost)
		return
	var/drain = src.passive_handler["Drained"] ? S.EnergyCost * (1 + src.passive_handler["Drained"] / 10) : S.EnergyCost
	src.LoseEnergy(drain)

/obj/Skills/Projectile/Namekian/Explosive_Demon_Wave
	name = "Explosive Demon Wave"
	desc = "Brace one arm with the other and hurl the heavy demon wave straight ahead."
	Copyable = 0
	DamageMult = 2
	Cooldown = 15
	EnergyCost = 3
	Knockback = 1
	Explode = 1
	Variation = 0
	IconLock = 'Blast - Basic.dmi'
	ActiveMessage = "braces one arm and hurls the Explosive Demon Wave!"

	verb/Explosive_Demon_Wave()
		set name = "Explosive Demon Wave"
		set category = "Skills"
		usr.UseProjectile(src)

/obj/Skills/Projectile/Namekian/Eye_Laser
	name = "Eye Laser"
	desc = "Fire two thin, fast beams from your eyes."
	Copyable = 0
	DamageMult = 0.25
	Blasts = 2
	Delay = 0
	Distance = 10
	Cooldown = 5
	EnergyCost = 1
	Knockback = 0
	Variation = 6
	IconLock = 'Blast - Small.dmi'
	ActiveMessage = "fires twin beams from their eyes!"

	verb/Eye_Laser()
		set name = "Eye Laser"
		set category = "Skills"
		usr.UseProjectile(src)

/obj/Skills/Projectile/Namekian/Finger_Beam
	name = "Finger Beam"
	desc = "A precise bolt from the fingertip that pierces through its target. It homes in on a foe who bears your Demon Mark."
	Copyable = 0
	DamageMult = 1.1
	Piercing = 1
	Cooldown = 9
	EnergyCost = 1
	Knockback = 0
	Variation = 0
	IconLock = 'Blast - Small.dmi'
	ActiveMessage = "fires a piercing beam from their fingertip!"

	adjust(mob/p)
		Homing = (p && p.NamekDemonMarkOn(p.Target)) ? 1 : initial(Homing)

	verb/Finger_Beam()
		set name = "Finger Beam"
		set category = "Skills"
		adjust(usr)
		usr.UseProjectile(src)

/obj/Skills/AutoHit/Namekian/Exploding_Wave
	name = "Exploding Wave"
	desc = "Blow a crater open under your target: half a second later, the ground erupts around the tile they stood on."
	Copyable = 0
	Area = "Around Target"
	Distance = 10
	DistanceAround = 1
	ForScaling = 1
	DamageMult = 1.4
	WindUp = 0.5
	Knockback = 0
	Cooldown = 14
	EnergyCost = 2
	TurfErupt = 1
	TurfEruptOffset = 6
	ActiveMessage = "blows the ground apart beneath their target!"

	verb/Exploding_Wave()
		set name = "Exploding Wave"
		set category = "Skills"
		usr.Activate(src)

/obj/Skills/AutoHit/Namekian/Hyper_Explosive_Demon_Wave
	name = "Hyper Explosive Demon Wave"
	desc = "Cross your arms, then fling them up to blast everything within three tiles. It costs 30 percent of your energy and 10 fatigue."
	Copyable = 0
	Area = "Circle"
	Distance = 3
	ForScaling = 1
	DamageMult = 2.5
	Cooldown = 45
	EnergyCost = 30
	FatigueCost = 10
	ShockIcon = 'KenShockwavePurple.dmi'
	Shockwave = 3
	Shockwaves = 1
	PostShockwave = 1
	ActiveMessage = "crosses their arms, then flings them up in a Hyper Explosive Demon Wave!"
	var/HyperEnergyShare = 0.3

	adjust(mob/p)
		EnergyCost = p ? p.EnergyMax * HyperEnergyShare : initial(EnergyCost)

	verb/Hyper_Explosive_Demon_Wave()
		set name = "Hyper Explosive Demon Wave"
		set category = "Skills"
		adjust(usr)
		usr.Activate(src)

/obj/Skills/Projectile/Namekian/Darkness_Twin_Star
	name = "Darkness Twin Star"
	desc = "Hurl two dark orbs. Each one paralyzes a foe for half a second on hit."
	Copyable = 0
	DamageMult = 1
	Blasts = 2
	Delay = 0
	Stunner = 0.5
	Cooldown = 15
	EnergyCost = 3
	Knockback = 0
	Variation = 12
	IconLock = 'Plasma2.dmi'
	ActiveMessage = "hurls a pair of dark orbs!"

	verb/Darkness_Twin_Star()
		set name = "Darkness Twin Star"
		set category = "Skills"
		usr.UseProjectile(src)
