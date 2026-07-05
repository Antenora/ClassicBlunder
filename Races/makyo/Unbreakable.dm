/obj/Skills/AutoHit/Unbreakable_Release
	Area     = "Circle"
	Distance = 3
	ActiveMessage = "remains unbroken by your efforts."

/obj/Effects/BloodShieldAura
	icon         = 'Blood Shield.dmi'
	layer        = EFFECTS_LAYER
	mouse_opacity = 0

/obj/Skills/Buffs/SlotlessBuffs/Makyo/Unbreakable
	Cooldown     = 60
	TimerLimit   = 15
	Slotless     = 1
	ActiveMessage = "braces themselves, ready to endure anything!"
	OffMessage    = "releases all their withheld force in a devastating burst!"

	adjust(mob/p)
		passives = list("Unbroken" = 1 + p.AscensionsAcquired)

	Trigger(mob/user)
		. = ..()
		if(!SlotlessOn) return

		user.unbreakable_tracking = 1
		user.unbroken_absorbed    = 0

		var/obj/Effects/BloodShieldAura/shield = new(user.loc)
		shield.transform = user.transform
		user.vis_contents += shield

		spawn(TimerLimit * 10)
			_unbreakable_release(user, shield)

		// Pulse warning
		spawn(12 * 10)
			if(user && SlotlessOn)
				animate(shield, alpha=80, time=8, loop=-1, easing=SINE_EASING)
				animate(alpha=255, time=8)

	proc/_unbreakable_release(mob/user, obj/Effects/BloodShieldAura/shield)
		if(!user) return
		if(!SlotlessOn) return

		if(shield && shield.loc)
			user.vis_contents -= shield
			shield.EffectFinish()

		var/stored   = user.unbroken_absorbed
		user.unbreakable_tracking = 0
		user.unbroken_absorbed    = 0

		var/ampBonus = max(min(stored / 2, 20), 1)

		var/obj/Skills/AutoHit/Unbreakable_Release/atk = new()
		atk.DamageMult = ampBonus
		user.Activate(atk)

		KenShockwave(user, icon='KenShockwaveBloodlust.dmi', Size=1, Time=8)

		// Deactivate the buff after the release fires
		if(SlotlessOn)
			Trigger(user)

	verb/Unbreakable()
		set category="Skills"
		src.adjust(usr)
		src.Trigger(usr)
