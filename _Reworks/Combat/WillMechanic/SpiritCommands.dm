mob/var/tmp
	SpiritNextDamageMult = 0
	SpiritDamageBoostUntil = 0
	SpiritFlashReady = FALSE
	SpiritFlashUntil = 0
	SpiritPersistReady = FALSE
	SpiritBullseyeUntil = 0


	SpiritBullseyeReady = FALSE
	SpiritPersistUntil = 0

mob/proc/ClearInstantSpiritCommands()
	SpiritNextDamageMult = 0
	SpiritDamageBoostUntil = 0
	SpiritFlashReady = FALSE
	SpiritFlashUntil = 0
	SpiritBullseyeReady = FALSE
	SpiritBullseyeUntil = 0
	SpiritPersistReady = FALSE
	SpiritPersistUntil = 0

mob/proc/RefreshSpiritDamageBoost()
	if(SpiritDamageBoostUntil && world.time >= SpiritDamageBoostUntil)
		SpiritNextDamageMult = 0
		SpiritDamageBoostUntil = 0

mob/proc/ApplySpiritCommandDamage(mob/defender, val)
	if(!defender || defender == src || val <= 0)
		return val

	if(SpiritNextDamageMult > 1)
		// first hit starts the window
		if(!SpiritDamageBoostUntil)
			SpiritDamageBoostUntil = world.time + 20

		if(world.time < SpiritDamageBoostUntil)
			val *= SpiritNextDamageMult
		else
			SpiritNextDamageMult = 0
			SpiritDamageBoostUntil = 0

	if(defender.SpiritPersistReady)
		if(!defender.SpiritPersistUntil)
			defender.SpiritPersistUntil = world.time + 20

		if(world.time < defender.SpiritPersistUntil)
			val *= 0.125
		else
			defender.SpiritPersistReady = FALSE
			defender.SpiritPersistUntil = 0

	return val

mob/proc/RefreshSpiritCommandStates()
	if(SpiritDamageBoostUntil && world.time >= SpiritDamageBoostUntil)
		SpiritNextDamageMult = 0
		SpiritDamageBoostUntil = 0

	if(SpiritFlashUntil && world.time >= SpiritFlashUntil)
		SpiritFlashReady = FALSE
		SpiritFlashUntil = 0

	if(SpiritBullseyeUntil && world.time >= SpiritBullseyeUntil)
		SpiritBullseyeReady = FALSE
		SpiritBullseyeUntil = 0

	if(SpiritPersistUntil && world.time >= SpiritPersistUntil)
		SpiritPersistReady = FALSE
		SpiritPersistUntil = 0


obj/Skills/Buffs/SpiritCommands
	parent_type = /obj/Skills/Buffs/SlotlessBuffs
	Copyable = 0
	var/tmp/SpiritActivating = FALSE

	Trigger(mob/User, Override = 0)
		if(!User) return 0
		//active commands may expire or be forcibly removed without SP costs
		if(User.BuffOn(src))
			if(Override)
				return ..()
			User << "[src] is already active."
			return 0

		if(SpiritActivating) return 0
		if(loc != User) return 0
		if(!User.WillPowered())
			User << "You cannot use Spirit Commands."
			return 0
		if(User.KO || User.Dead) return 0
		if(User.icon_state == "Meditate")
			User << "Stop meditating before using a Spirit Command."
			return 0
		if(User.BuffingUp || Sealed) return 0
		if(BuffName && User.CheckSlotless(BuffName))
			User << "[BuffName] is already active."
			return 0

		var/cost = max(SpiritCost, 0)
		if(User.Spirit < cost)
			User << "[src] requires [cost] Spirit Points. You have [User.Spirit]."
			return 0

		//reserve sp for activation, refund if fails
		SpiritActivating = TRUE
		User.Spirit -= cost
		..(User, 0)

		var/activated = User.BuffOn(src)
		if(!activated)
			User.Spirit += cost
		if(activated)
			PlaySpiritGraphics(User)
		SpiritActivating = FALSE
		User.client.updateWillMeter()
		return activated

obj/Skills/Buffs/SpiritCommands/Instant //immediate use commands
	TimerLimit = 0

	Trigger(mob/User, Override = 0)
		if(!User || loc != User) return FALSE
		if(Override) return FALSE
		if(Using || SpiritActivating || Sealed) return FALSE
		if(!User.WillPowered()) return FALSE
		if(User.PureRPMode) return FALSE
		if(User.KO || User.Dead || User.Stunned || User.AutoHitting)
			return FALSE
		if(User.Frozen || User.Suspended || User.Stasis)
			return FALSE
		if(User.BuffingUp || User.judgement_cut_chain_active)
			return FALSE
		if(User.HeldSkillBlocksAction()) return FALSE
		if(User.GCDBlocked(src)) return FALSE

		if(User.passive_handler.Get("Silenced"))
			User << "You cannot use Spirit Commands while silenced."
			return FALSE

		if(User.icon_state == "Meditate")
			User << "Stop meditating before using a Spirit Command."
			return FALSE

		var/cost = max(SpiritCost, 0)
		if(User.Spirit < cost)
			User << "[src] requires [cost] Spirit Points. You have [User.Spirit]."
			return FALSE

		SpiritActivating = TRUE
		User.Spirit -= cost

		if(!ApplySpiritEffect(User))
			User.Spirit += cost
			SpiritActivating = FALSE
			return FALSE

		// buffs are excluded from automatic GCD inside Cooldown()
		User.StartGCD(src)
		src.Cooldown(p = User)
		PlaySpiritGraphics(User)

		if(ActiveMessage)
			OMsg(User, "[User] [ActiveMessage]")

		SpiritActivating = FALSE
		User.client.updateWillMeter()
		return TRUE

	proc/ApplySpiritEffect(mob/User)
		return FALSE


#define TIER1SPIRIT list("Focus", "Accel", "Spirit")
#define TIER2SPIRIT list("Drive", "Valor", "Bullseye")
#define TIER3SPIRIT list("Soul", "Flash", "Persist")

obj/Skills/Buffs/SpiritCommands/Focus
	BuffName = "Spirit Command: Focus"
	Desc = "Temporarily improves accuracy and evasion."
	SpiritCost = 15
	TimerLimit = 10
	Cooldown = 30
	OffMult = 1.3
	DefMult = 1.3
	ActiveMessage = "sharpens their senses!"
	OffMessage = "lets their heightened focus settle."

	verb/Focus()
		set category = "Skills"
		set hidden = 1
		src.Trigger(usr)

obj/Skills/Buffs/SpiritCommands/Accel
	BuffName = "Spirit Command: Accel"
	Desc = "Temporarily increases speed."
	SpiritCost = 10
	TimerLimit = 5
	Cooldown = 20
	SpdMult = 1.3
	ActiveMessage = "surges forward!"
	OffMessage = "returns to their normal pace."

	verb/Accel()
		set category = "Skills"
		set hidden = 1
		src.Trigger(usr)

obj/Skills/Buffs/SpiritCommands/Instant/Spirit
	name = "Spirit"
	BuffName = "Spirit Command: Spirit"
	Desc = "Raises Will by 10, up to your current maximum."
	SpiritCost = 20
	Cooldown = 5
	ActiveMessage = "steadies their resolve!"

	ApplySpiritEffect(mob/User)
		var/cap = User.WillMax
		if(User.Will >= cap)
			User << "Your Will is already at its maximum."
			return FALSE

		User.Will = min(User.Will + 10, cap)
		return TRUE

	verb/Spirit()
		set category = "Skills"
		set hidden = 1
		src.Trigger(usr)

obj/Skills/Buffs/SpiritCommands/Instant/Drive
	name = "Drive"
	BuffName = "Spirit Command: Drive"
	Desc = "Raises Will by 30, up to your current maximum."
	SpiritCost = 40
	Cooldown = 10
	ActiveMessage = "flares their fighting spirit!"

	ApplySpiritEffect(mob/User)
		var/cap = User.WillMax
		if(User.Will >= cap)
			User << "Your Will is already at its maximum."
			return FALSE

		User.Will = min(User.Will + 30, cap)
		return TRUE

	verb/Drive()
		set category = "Skills"
		set hidden = 1
		src.Trigger(usr)

obj/Skills/Buffs/SpiritCommands/Instant/Valor
	name = "Valor"
	BuffName = "Spirit Command: Valor"
	Desc = "Upon landing a hit, for two seconds, it and following hits' damage get increased by 2."
	SpiritCost = 30
	Cooldown = 10
	ActiveMessage = "burns with the will to win!"

	ApplySpiritEffect(mob/User)
		User.RefreshSpiritDamageBoost()

		if(User.SpiritDamageBoostUntil)
			User << "Your damage boost is already in progress."
			return FALSE
		if(User.SpiritNextDamageMult >= 2)
			User << "An equal or stronger damage command is already prepared."
			return FALSE

		User.SpiritNextDamageMult = 2
		return TRUE

	verb/Valor()
		set category = "Skills"
		set hidden = 1
		src.Trigger(usr)

obj/Skills/Buffs/SpiritCommands/Instant/Soul
	name = "Soul"
	BuffName = "Spirit Command: Soul"
	Desc = "Upon landing a hit, for two seconds, it and following hits' damage get increased by 2.2. Overrides Valor."
	SpiritCost = 40
	Cooldown = 10
	ActiveMessage = "is ready to hit with everything they've got!"

	ApplySpiritEffect(mob/User)
		User.RefreshSpiritDamageBoost()

		if(User.SpiritDamageBoostUntil)
			User << "Your damage boost is already in progress."
			return FALSE
		if(User.SpiritNextDamageMult >= 2.2)
			User << "Soul is already prepared."
			return FALSE

		User.SpiritNextDamageMult = 2.2
		return TRUE

	verb/Soul()
		set category = "Skills"
		set hidden = 1
		src.Trigger(usr)

obj/Skills/Buffs/SpiritCommands/Instant/Persist
	name = "Persist"
	BuffName = "Spirit Command: Persist"
	Desc = "Upon being hit, reduce incoming damage by 87.5% for two seconds."
	SpiritCost = 15
	Cooldown = 10
	ActiveMessage = "braces for impact!"

	ApplySpiritEffect(mob/User)
		if(User.SpiritPersistUntil && world.time >= User.SpiritPersistUntil)
			User.SpiritPersistReady = FALSE
			User.SpiritPersistUntil = 0

		if(User.SpiritPersistReady)
			User << "Persist is already prepared or active."
			return FALSE

		User.SpiritPersistReady = TRUE
		User.SpiritPersistUntil = 0
		return TRUE

	verb/Persist()
		set category = "Skills"
		set hidden = 1
		src.Trigger(usr)

obj/Skills/Buffs/SpiritCommands/Instant/Flash
	name = "Flash"
	BuffName = "Spirit Command: Flash"
	Desc = "Automatically evade for two seconds upon an attack connecting."
	SpiritCost = 15
	Cooldown = 10
	ActiveMessage = "sees the next hit coming!"

	ApplySpiritEffect(mob/User)
		if(User.SpiritFlashUntil && world.time >= User.SpiritFlashUntil)
			User.SpiritFlashReady = FALSE
			User.SpiritFlashUntil = 0

		if(User.SpiritFlashReady)
			User << "Flash is already prepared or active."
			return FALSE

		User.SpiritFlashReady = TRUE
		User.SpiritFlashUntil = 0
		return TRUE

	verb/Flash()
		set category = "Skills"
		set hidden = 1
		src.Trigger(usr)

obj/Skills/Buffs/SpiritCommands/Instant/Bullseye
	name = "Bullseye"
	BuffName = "Spirit Command: Bullseye"
	Desc = "Guarantees accuracy for 10 seconds. Flash can still evade your attacks."
	SpiritCost = 20
	Cooldown = 20
	ActiveMessage = "prepares Bullseye!"

	ApplySpiritEffect(mob/User)
		if(User.SpiritBullseyeUntil && world.time >= User.SpiritBullseyeUntil)
			User.SpiritBullseyeReady = FALSE
			User.SpiritBullseyeUntil = 0

		if(User.SpiritBullseyeReady)
			User << "Bullseye is already prepared or active."
			return FALSE

		User.SpiritBullseyeReady = TRUE
		User.SpiritBullseyeUntil = 0
		return TRUE

	verb/Bullseye()
		set category = "Skills"
		set hidden = 1
		src.Trigger(usr)