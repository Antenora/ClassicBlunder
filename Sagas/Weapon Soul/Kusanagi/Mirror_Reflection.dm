obj/Skills/Buffs/SlotlessBuffs/Yata_no_Kagami/Mirror_Hold_Guard
	name = "Mirror Reflection Guard"
	Slotless = 1

	adjust(mob/p)
		passives = list("PureReduction" = 10)


// Hold to gain damage reduction and slow movement. Release to open a 0.25s parry window

obj/Skills/Yata_no_Kagami/Mirror_Reflection
	name = "Mirror Reflection"
	HeldSkill       = TRUE
	NoFizzle        = TRUE   // exceeding ChargePeriod auto-releases, no fizzle
	ChargePeriod    = 3
	SweetSpot       = 1.8
	ChargeWaveIcon  = 'Icons/Effects/KenShockwave.dmi'
	ChargeWaveBlend = 2

	// Applies the hold buff and movement penalty the moment charging begins
	OnHeldStart(mob/p)
		var/obj/Skills/Buffs/SlotlessBuffs/Yata_no_Kagami/Mirror_Hold_Guard/g = locate(/obj/Skills/Buffs/SlotlessBuffs/Yata_no_Kagami/Mirror_Hold_Guard) in p
		if(!g)
			g = new /obj/Skills/Buffs/SlotlessBuffs/Yata_no_Kagami/Mirror_Hold_Guard()
			p.AddSkill(g)
		if(!g.SlotlessOn)
			g.adjust(p)
			g.Trigger(p)
		p.mirror_hold_slowing = TRUE
		p:move_speed = p.MovementSpeed()

	// Called when the player releases the key
	OnHeldRelease(mob/p, benefit, sweet_spot_hit)
		_RemoveHoldBuff(p)
		// Fixed cooldown
		var/cd = max(5, 30 - (p.SagaLevel * 2))
		Cooldown(1, cd * 10, p)
		// Open parry window on the player
		if(sweet_spot_hit)
			p.mirror_reflect_active = TRUE
		else
			p.mirror_parry_active = TRUE
		// Flash the character white to signal the parry window is open
		animate(p, color = list(1,0,0, 0,1,0, 0,0,1, 1,1,1))
		spawn(2.5)
			p.mirror_parry_active   = FALSE
			p.mirror_reflect_active = FALSE
			animate(p, color = null, time = 10, flags = ANIMATION_PARALLEL)

	// Called when the hold is interrupted
	OnHeldFizzle(mob/p)
		_RemoveHoldBuff(p)

	proc/_RemoveHoldBuff(mob/p)
		var/obj/Skills/Buffs/SlotlessBuffs/Yata_no_Kagami/Mirror_Hold_Guard/g = locate(/obj/Skills/Buffs/SlotlessBuffs/Yata_no_Kagami/Mirror_Hold_Guard) in p
		if(g && g.SlotlessOn)
			g.Trigger(p)
		p.mirror_hold_slowing = FALSE
		p:move_speed = p.MovementSpeed()

	verb/Mirror_Reflection()
		set name = "Yata no Kagami: Mirror Reflection"
		set category = "Skills"
		usr.BeginHeldSkill(src)
