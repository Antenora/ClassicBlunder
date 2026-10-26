#define SONIDO_WINDOW_SECONDS 3
#define SONIDO_MANA 1.5
#define SONIDO_OFFENSE 1.25

/obj/Skills/Arrancar/Sonido
	name = "Sonido"
	MaxCharges = 3
	Charges = 3
	ChargeRefresh = 10
	ManaCost = 0
	var/tmp/SonidoToggle = FALSE

	verb/Sonido()
		set name = "Sonido"
		set category = "Skills"
		set hidden = 1
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		src.SonidoToggle = !src.SonidoToggle
		if(src.SonidoToggle)
			User << "Sonido active. ([src.Charges]/[src.MaxCharges] charges)"
		else
			User << "Sonido deactivated."

/mob/proc/HollowSonidoRefresh()
	if(src.AscensionsAcquired >= 6)
		return 6
	if(src.AscensionsAcquired >= 4)
		return 8
	return 10

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Sonido_Window
	BuffName = "Sonido"
	TimerLimit = SONIDO_WINDOW_SECONDS
	CooldownStatic = 1
	Cooldown = 0
	OffMult = SONIDO_OFFENSE
	ActiveMessage = "blurs out of step with the world."
	OffMessage = "settles back into step."

/mob/proc/HollowArmSonidoWindow()
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Sonido_Window/W = src.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Sonido_Window)
	if(!W)
		return
	if(src.BuffOn(W))
		return
	W.Trigger(src)

/mob/proc/HollowConsumeSonidoWindow()
	if(!src.CheckSlotless("Sonido"))
		return
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Sonido_Window/W = locate(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Sonido_Window) in src
	if(!W || !src.BuffOn(W))
		return
	W.Trigger(src, Override = 1)

/strikeHook/arrancarSonidoWindow
	stage = "post"
	fire(strike/S)
		if(!S || !S.attacker)
			return
		S.attacker.HollowConsumeSonidoWindow()

turf/Click(turf/T)
	if(!usr || !usr.client)
		return ..()
	var/obj/Skills/Arrancar/Sonido/s = locate(/obj/Skills/Arrancar/Sonido) in usr.contents
	if(!s || !s.SonidoToggle)
		return ..()
	if(usr.Admin >= 4 && usr.AdminOverwatchActive)
		return ..()
	if(usr.Target && istype(usr.Target, /obj/Others/Build))
		return ..()
	if(usr.client.macros && usr.client.macros.IsPressed("Ctrl"))
		return ..()
	if(!usr.Move_Requirements() || usr.KO)
		return ..()
	if(!T || !T.icon)
		return
	for(var/turf/A in view(0, usr))
		if(A == src)
			return
	if(T.density || usr.icon_state == "Meditate" || usr.Observing || usr.Beaming == 2)
		return
	if(s.Charges <= 0)
		return
	if(usr.ManaAmount < SONIDO_MANA)
		return
	VanishImage(usr)
	var/formerdir = usr.dir
	usr.Move(src)
	usr.dir = formerdir
	ShadowPrewarm(usr)
	if(usr.Energy < 1)
		usr.Energy = 1
	usr.LoseMana(SONIDO_MANA)
	s.ChargeRefresh = usr.HollowSonidoRefresh()
	s.Cooldown(1, null, usr)
	usr.HollowArmSonidoWindow()
