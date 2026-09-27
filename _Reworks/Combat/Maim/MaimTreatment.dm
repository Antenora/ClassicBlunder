#define TRAUMA_CHANNEL 100
#define TRAUMA_GAMBLE_CHANCE 50
#define SURGERY_CHANNEL 100
#define SURGERY_FRACTION 0.1
#define SURGERY_FLOOR 0.001
#define SURGERY_COOLDOWN 6000
#define PAINKILLER_TIME 1200
#define PAINKILLER_CREEP 2
#define MAIM_INV_BTN_X 252
#define MAIM_INV_BTN_Y 162

var/list/MAIM_PROSTHETIC_PARTS = list("Arms", "Legs")
var/list/SURGERY_CUTS = list("HealthCut" = "Health", "StrCut" = "Strength", "EndCut" = "Endurance", "SpdCut" = "Speed", "ForCut" = "Force", "OffCut" = "Offense", "DefCut" = "Defense", "RecovCut" = "Recovery")
var/list/MEDSCAN_COLS = list(list("l" = "READING", "a" = "l"), list("l" = "TIER", "a" = "r"), list("l" = "SEVERITY", "a" = "r"), list("l" = "TREATING", "a" = "l"), list("l" = "EASES IN", "a" = "r"), list("l" = "WORSENING", "a" = "r"))

mob/var/tmp/surgery_ready_at = 0

mob/proc/MaimIsProsthetic(part)
	return (prosthetic_parts && prosthetic_parts[part]) ? 1 : 0

mob/proc/MaimCareAndroid()
	return race && isRace(ANDROID)

mob/proc/MaimCareAndroidLine(mob/user)
	return "[src == user ? "Your frame needs" : "[src]'s frame needs"] a Frame Repair Kit or a Maintenance Pod, not medicine."

mob/proc/MaimCareHint(mob/T)
	var/mob/O = Target
	if(T != src || !ismob(O) || O == src || O.z != z || get_dist(src, O) > 1)
		return ""
	return " To work on [O], they must be in your party or knocked out."

mob/proc/MaimCareConsent(mob/user, what)
	if(src == user || KO)
		return 1
	return Ask(src, "[user] wants to [what]. Allow it?", "Medical care", null, "confirm", null, 1, "No", "Yes") == "Yes"

mob/proc/MaimCareGuard(obj/Items/I, fightline)
	if(!I || I.loc != src)
		return 0
	if(Secret == "Heavenly Restriction" && secretDatum?:hasRestriction("Science"))
		return 0
	if(KO)
		src << "You cannot do that while knocked out."
		return 0
	if(I.Using)
		src << "You're already using this."
		return 0
	if(InCombat())
		src << fightline
		return 0
	return 1

mob/proc/MaimCareReach(mob/T, obj/Items/I)
	if(!I || I.loc != src || !T || T.Dead || KO || Dead)
		return 0
	if(T != src && (!T.loc || T.z != z || get_dist(src, T) > 1))
		src << "[T] is too far away."
		return 0
	if(InCombat() || T.InCombat())
		src << "Someone here is fighting. The work has to wait."
		return 0
	return 1

mob/proc/MaimCareChannel(mob/T, obj/Items/I, ticks)
	var/hs = Health
	var/ht = T.Health
	var/end = world.time + ticks
	while(world.time < end)
		sleep(2)
		if(!T || !I || I.loc != src || KO || Dead || T.Dead)
			src << "The work is interrupted."
			return 0
		if(T != src && (!T.loc || T.z != z || get_dist(src, T) > 1))
			src << "[T] moved out of reach. The work stops."
			return 0
		if(Health < hs || T.Health < ht)
			src << "Damage breaks the work off. Nothing is spent."
			if(T != src)
				T << "Damage breaks off [src]'s work on you."
			return 0
		hs = max(hs, Health)
		ht = max(ht, T.Health)
	return 1

proc/TraumaKitReach(q)
	q = QualityClamp(q)
	if(q >= QUAL_EPIC)
		return 3
	if(q >= QUAL_GOOD)
		return 2
	return 1

proc/TraumaKitOdds(q, tier)
	var/over = tier - TraumaKitReach(q)
	if(over <= 0)
		return 100
	if(over == 1)
		return TRAUMA_GAMBLE_CHANCE
	return 0

/obj/Items/Tech/Trauma_Kit
	name = "Trauma Kit"
	desc = "Starts the healing of one maim. The kit's quality sets the worst maim it treats: Poor and Normal kits treat tier 1, Good kits tier 2, Epic and Legendary kits tier 3. On a maim one tier worse it works half the time and is spent either way. Ten seconds of work out of combat, on yourself, a party member or someone knocked out next to you."
	icon = 'Tech.dmi'
	icon_state = "FirstAid"
	TechType = "Medicine"
	SubType = "Trauma Care"
	Stackable = 1
	BeltAlly = 1

	Click()
		if(loc != usr)
			return ..()
		usr.TraumaKitUse(src)

mob/proc/TraumaKitParts(q)
	. = list()
	for(var/p in MAIM_PARTS)
		var/datum/maim/M = MaimGet(p)
		if(!M)
			continue
		var/note
		if(MaimIsProsthetic(p))
			note = "prosthetic"
		else if(M.treating)
			note = "treating"
		else
			var/odds = TraumaKitOdds(q, M.tier)
			if(!odds)
				note = "too severe for this kit"
			else if(odds < 100)
				note = "even odds"
		.["[p], tier [M.tier][note ? " ([note])" : ""]"] = p

mob/proc/TraumaKitRefusal(part, q, mob/user)
	var/whose = (src == user) ? "Your" : "[src]'s"
	if(MaimCareAndroid())
		return MaimCareAndroidLine(user)
	var/datum/maim/M = MaimGet(part)
	if(!M)
		return "[whose] [lowertext(part)] carry no maim."
	if(MaimIsProsthetic(part))
		return "[whose] prosthetic [lowertext(part)] need a Frame Repair Kit, not a Trauma Kit."
	if(M.treating)
		return "[whose] [lowertext(part)] maim is already being treated."
	if(!TraumaKitOdds(q, M.tier))
		return "A [QualityName(q)] Trauma Kit cannot treat a tier [M.tier] maim."
	return null

mob/proc/TraumaKitResolve(part, q)
	if(TraumaKitRefusal(part, q))
		return -1
	var/datum/maim/M = MaimGet(part)
	if(!prob(TraumaKitOdds(q, M.tier)))
		return 0
	return MaimTreat(part, q) ? 1 : 0

mob/proc/TraumaKitFinish(obj/Items/K, mob/T, part, q)
	. = T.TraumaKitResolve(part, q)
	if(. >= 0)
		BeltConsume(K)

mob/proc/TraumaKitUse(obj/Items/Tech/Trauma_Kit/K)
	if(!MaimCareGuard(K, "You cannot treat a maim in the middle of a fight."))
		return 0
	K.Using = 1
	. = TraumaKitRun(K)
	if(K)
		K.Using = 0

mob/proc/TraumaKitRun(obj/Items/Tech/Trauma_Kit/K)
	var/mob/T = BeltReceiverFor(K)
	if(T.MaimCareAndroid())
		src << T.MaimCareAndroidLine(src)
		return 0
	var/q = K.CraftQuality
	var/list/parts = T.TraumaKitParts(q)
	if(!parts.len)
		src << "[T == src ? "You have" : "[T] has"] no maim to treat.[MaimCareHint(T)]"
		return 0
	var/pick = Ask(src, "Which maim do you treat?", "Trauma Kit", null, "pick", parts, 1)
	if(!pick || !parts[pick])
		return 0
	var/part = parts[pick]
	var/why = T.TraumaKitRefusal(part, q, src)
	if(why)
		src << why
		return 0
	if(!T.MaimCareConsent(src, "treat your [lowertext(part)] maim with a Trauma Kit"))
		src << "[T] declines the treatment."
		return 0
	if(!MaimCareReach(T, K))
		return 0
	var/whose = (T == src) ? "your" : "[T]'s"
	src << "You begin treating [whose] [lowertext(part)] maim. It takes 10 seconds, and damage to either of you stops it."
	if(T != src)
		T << "[src] begins treating your [lowertext(part)] maim."
	if(!MaimCareChannel(T, K, TRAUMA_CHANNEL))
		return 0
	if(!MaimCareReach(T, K))
		return 0
	why = T.TraumaKitRefusal(part, q, src)
	if(why)
		src << why
		return 0
	var/tier = T.MaimTierOf(part)
	var/r = TraumaKitFinish(K, T, part, q)
	if(r < 0)
		return 0
	if(client)
		client.BuildInvPage()
	OMsg(src, "[src] works a Trauma Kit over [T == src ? "their own" : "[T]'s"] [lowertext(part)].")
	if(r)
		var/hours = round(T.MaimSecondsToPeel(part) / 3600, 0.1)
		src << "<font color='#78eb78'>The treatment takes. [T == src ? "Your" : "[T]'s"] [lowertext(part)] maim is healing, about [hours] hours to the next tier.</font>"
		if(T != src)
			T << "<font color='#78eb78'>[src]'s treatment takes. Your [lowertext(part)] maim is healing, about [hours] hours to the next tier.</font>"
	else
		src << "<font color='#ff6b6b'>The [QualityName(q)] kit is not enough for [whose] tier [tier] [lowertext(part)] maim. The treatment fails and the kit is spent.</font>"
		if(T != src)
			T << "<font color='#ff6b6b'>[src]'s treatment of your [lowertext(part)] maim fails.</font>"
	return 1

/obj/Items/Tech/PainKillers
	BeltUse(mob/user)
		if(!user)
			return 0
		if(user.Secret == "Heavenly Restriction" && user.secretDatum?:hasRestriction("Science"))
			return 0
		var/mob/T = user.belt_receiver ? user.belt_receiver : user
		return T.PainkillerDose(user)

	Click()
		if(loc != usr)
			return ..()
		usr.PainkillerUse(src)

mob/proc/PainkillerRefusal(mob/user)
	if(MaimCareAndroid())
		return MaimCareAndroidLine(user)
	if(!length(maims))
		return "[src == user ? "You have" : "[src] has"] no maim to numb."
	if(maim_suppressed_until > world.time)
		return "[src == user ? "You are" : "[src] is"] still numbed from the last dose."
	return null

mob/proc/PainkillerDose(mob/user)
	var/why = PainkillerRefusal(user)
	if(why)
		if(user)
			user << why
		return 0
	maim_suppressed_until = world.time + PAINKILLER_TIME
	maim_creep_mult = PAINKILLER_CREEP
	src << "<font color='#78eb78'>The painkillers take hold. Your maims stop hurting for two minutes, but fighting on them now worsens them twice as fast.</font>"
	if(user && user != src)
		user << "You give [src] painkillers."
	PainkillerWatch(maim_suppressed_until)
	return 1

mob/proc/PainkillerWatch(until)
	set waitfor = 0
	sleep(max(1, until - world.time))
	if(maim_suppressed_until != until)
		return
	maim_creep_mult = 1
	src << "The painkillers wear off. Your maims hurt again."

mob/proc/PainkillerUse(obj/Items/Tech/PainKillers/P)
	if(!MaimCareGuard(P, "In a fight you can only use what is on your belt."))
		return 0
	P.Using = 1
	var/mob/T = BeltReceiverFor(P)
	var/ok = 0
	var/why = T.PainkillerRefusal(src)
	if(why)
		src << "[why][T == src ? MaimCareHint(T) : ""]"
	else if(!T.MaimCareConsent(src, "give you painkillers"))
		src << "[T] declines the painkillers."
	else if(MaimCareReach(T, P))
		ok = T.PainkillerDose(src)
	if(P)
		P.Using = 0
		if(ok)
			BeltConsume(P)
	if(client)
		client.BuildInvPage()
	return ok

/obj/Items/Tech/Surgery_Kit
	name = "Surgery Kit"
	desc = "Ten seconds of field surgery on a conscious, willing party member next to you. It removes a tenth of their health cut and of each stat cut, and never restores health. A patient can go under the knife once every ten minutes."
	icon = 'device.dmi'
	icon_state = "genetics"
	TechType = "Medicine"
	SubType = "Improved Medical Technology"
	Stackable = 1
	BeltAlly = 1

	Click()
		if(loc != usr)
			return ..()
		usr.SurgeryUse(src)

mob/proc/SurgeryCutTotal()
	. = 0
	for(var/v in SURGERY_CUTS)
		var/c = vars[v]
		if(isnum(c) && c > 0)
			. += c

mob/proc/SurgeryRefusal(mob/user)
	if(src == user)
		return "Surgery needs a conscious party member next to you as your target."
	if(KO)
		return "[src] must be awake for surgery."
	if(MaimCareAndroid())
		return MaimCareAndroidLine(user)
	if(surgery_ready_at > world.time)
		return "[src] had surgery too recently. Try again in [-round(-(surgery_ready_at - world.time) / 600)] minutes."
	if(SurgeryCutTotal() <= 0)
		return "[src] has no cuts for surgery to remove."
	return null

mob/proc/SurgeryApply()
	. = list()
	for(var/v in SURGERY_CUTS)
		var/old = vars[v]
		if(!isnum(old) || old <= 0)
			continue
		var/nv = old - old * SURGERY_FRACTION
		if(nv < SURGERY_FLOOR)
			nv = 0
		vars[v] = clamp(nv, 0, 1)
		. += "[SURGERY_CUTS[v]] [round(old * 100, 0.1)]% to [round(nv * 100, 0.1)]%"
	surgery_ready_at = world.time + SURGERY_COOLDOWN

mob/proc/SurgeryUse(obj/Items/Tech/Surgery_Kit/K)
	if(!MaimCareGuard(K, "You cannot operate in the middle of a fight."))
		return 0
	K.Using = 1
	. = SurgeryRun(K)
	if(K)
		K.Using = 0

mob/proc/SurgeryRun(obj/Items/Tech/Surgery_Kit/K)
	var/mob/T = BeltReceiverFor(K)
	var/why = T.SurgeryRefusal(src)
	if(why)
		src << why
		return 0
	if(!T.MaimCareConsent(src, "operate on you with a Surgery Kit"))
		src << "[T] declines the surgery."
		return 0
	if(!MaimCareReach(T, K))
		return 0
	src << "You begin operating on [T]. It takes 10 seconds, and damage to either of you stops it."
	T << "[src] begins operating on you."
	if(!MaimCareChannel(T, K, SURGERY_CHANNEL))
		return 0
	if(!MaimCareReach(T, K))
		return 0
	why = T.SurgeryRefusal(src)
	if(why)
		src << why
		return 0
	var/list/done = T.SurgeryApply()
	BeltConsume(K)
	if(client)
		client.BuildInvPage()
	OMsg(src, "[src] operates on [T] with a Surgery Kit.")
	src << "<font color='#78eb78'>Surgery on [T]: [jointext(done, ", ")].</font>"
	T << "<font color='#78eb78'>[src]'s surgery eases your cuts: [jointext(done, ", ")].</font>"
	return 1

/obj/Items/Tech/Medical_Scanner
	name = "Medical Scanner"
	desc = "Reads a body at a glance: injury, fatigue, cuts, statuses, and every maim with its severity, its healing time and how close it is to worsening. Use it on yourself, or on your target next to you."
	icon = 'device.dmi'
	icon_state = "health"
	TechType = "Medicine"
	SubType = "Medicine"

	Click()
		if(loc != usr)
			return ..()
		usr.MedScanUse(src)

mob/proc/MedScanTarget()
	var/mob/T = Target
	if(!ismob(T) || T == src || !T.loc || T.z != z || get_dist(src, T) > 1)
		return src
	return T

mob/proc/MedScanRows(client/C)
	var/list/rows = list()
	rows[++rows.len] = list("sec" = "CONDITION")
	rows[++rows.len] = list("t" = "Injury", "c" = list("[round(TotalInjury, 0.1)]%"), "w" = 1)
	rows[++rows.len] = list("t" = "Fatigue", "c" = list("[round(TotalFatigue, 0.1)]%"), "w" = 1)
	for(var/v in SURGERY_CUTS)
		var/c = vars[v]
		rows[++rows.len] = list("t" = "[SURGERY_CUTS[v]] cut", "c" = list("[round((isnum(c) ? max(0, c) : 0) * 100, 0.1)]%"), "w" = 1)
	if(C)
		var/list/st = C.GetActiveDebuffs(src)
		if(st.len)
			rows[++rows.len] = list("sec" = "STATUS")
			for(var/list/d in st)
				rows[++rows.len] = list("t" = "[d[2]]", "c" = list(isnull(d[3]) ? "active" : "[d[3]]"), "w" = 1)
	if(length(maims))
		rows[++rows.len] = list("sec" = "MAIMS", "cl" = list("TIER", "SEVERITY", "TREATING", "EASES IN", "WORSENING"))
		for(var/p in MAIM_PARTS)
			var/datum/maim/M = MaimGet(p)
			if(!M)
				continue
			var/secs = MaimSecondsToPeel(p)
			rows[++rows.len] = list("t" = "[p][MaimIsProsthetic(p) ? " (prosthetic)" : ""]", "c" = list("[M.tier]", "[round(M.magnitude * 100)]%", M.treating ? "yes" : "no", secs < 0 ? "-" : "[round(secs / 3600, 0.1)] h", "[round(M.creep / MAIM_CREEP_ESCALATE * 100, 0.1)]%"))
	var/list/pros = list()
	for(var/p in MAIM_PROSTHETIC_PARTS)
		if(MaimIsProsthetic(p))
			pros += p
	if(pros.len)
		rows[++rows.len] = list("sec" = "BODY")
		rows[++rows.len] = list("t" = "Prosthetic parts", "c" = list(jointext(pros, ", ")), "w" = 1)
	return rows

mob/proc/MedScanUse(obj/Items/Tech/Medical_Scanner/S)
	if(!S || S.loc != src || !client)
		return 0
	if(Secret == "Heavenly Restriction" && secretDatum?:hasRestriction("Science"))
		return 0
	if(KO)
		src << "You cannot read a scanner while knocked out."
		return 0
	var/mob/T = MedScanTarget()
	if(T.maims)
		T.MaimSettle()
	client.TableShow("medscan:\ref[T]", "SCAN", "[T.name]", "Medical Scanner reading", MEDSCAN_COLS, T.MedScanRows(client), "", null, list("nosort" = 1, "nofilter" = 1, "nohead" = 1))
	if(T != src)
		T << "[src] runs a Medical Scanner over you."
	return 1

/obj/Items/Gear/Prosthetic_Limb
	BeltAlly = 1

mob/proc/ProstheticFitParts()
	. = list()
	for(var/p in MAIM_PROSTHETIC_PARTS)
		var/t = MaimTierOf(p)
		if(t > 0)
			.["[p], tier [t][MaimIsProsthetic(p) ? " (prosthetic)" : ""]"] = p

mob/proc/ProstheticFitRefusal(mob/user)
	if(Secret == "Heavenly Restriction" && secretDatum?:hasRestriction("Science"))
		return "[src == user ? "Your" : "[src]'s"] body rejects the technology."
	if(is_arcane_beast)
		return "A magical force surrounding [src == user ? "your" : "[src]'s"] body repels the prosthetic."
	return null

mob/proc/ProstheticFit(part)
	if(!(part in MAIM_PROSTHETIC_PARTS) || MaimTierOf(part) <= 0)
		return 0
	MaimPeel(part, MAIM_TIER_MAX)
	if(!prosthetic_parts)
		prosthetic_parts = list()
	prosthetic_parts[part] = 1
	return 1

mob/proc/ProstheticFitUse(obj/Items/Gear/Prosthetic_Limb/L)
	if(!MaimCareGuard(L, "You cannot fit a limb in the middle of a fight."))
		return 0
	if(L.type != /obj/Items/Gear/Prosthetic_Limb)
		return 0
	if(L.suffix == "*Equipped*")
		src << "Take the limb off before you fit it to someone."
		return 0
	if(length(L.Techniques))
		src << "This limb carries integrated gear. Fit a plain limb, or equip this one as gear."
		return 0
	L.Using = 1
	. = ProstheticFitRun(L)
	if(L)
		L.Using = 0

mob/proc/ProstheticFitRun(obj/Items/Gear/Prosthetic_Limb/L)
	var/mob/T = BeltReceiverFor(L)
	var/why = T.ProstheticFitRefusal(src)
	if(why)
		src << why
		return 0
	var/list/parts = T.ProstheticFitParts()
	if(!parts.len)
		src << "[T == src ? "You have" : "[T] has"] no maimed arm or leg to replace.[MaimCareHint(T)]"
		return 0
	var/pick = Ask(src, "Which part does the limb replace?", "Prosthetic Limb", null, "pick", parts, 1)
	if(!pick || !parts[pick])
		return 0
	var/part = parts[pick]
	if(!T.MaimCareConsent(src, "replace your [lowertext(part)] with a prosthetic"))
		src << "[T] declines the prosthetic."
		return 0
	if(!MaimCareReach(T, L) || L.suffix == "*Equipped*")
		return 0
	if(!T.ProstheticFit(part))
		src << "[T == src ? "Your" : "[T]'s"] [lowertext(part)] no longer need replacing."
		return 0
	BeltConsume(L)
	if(client)
		client.BuildInvPage()
	OMsg(src, "[src] fits a prosthetic to [T == src ? "their own" : "[T]'s"] [lowertext(part)].")
	src << "<font color='#78eb78'>The prosthetic takes. [T == src ? "Your" : "[T]'s"] [lowertext(part)] maim is gone.</font>"
	if(T != src)
		T << "<font color='#78eb78'>[src] fits you with a prosthetic. Your [lowertext(part)] maim is gone.</font>"
	return 1

/atom/movable/shud/invfitbtn
	layer = MINV_LAYER + 0.7
	mouse_opacity = 2
	maptext_height = 18
	var/obj/Items/Gear/Prosthetic_Limb/limb

	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

	Click(location, control, params)
		if(!usr || !usr.client)
			return
		if(params && findtext(params, "right=1"))
			usr.client.HideItemDesc()
			return
		var/mob/M = usr
		var/obj/Items/Gear/Prosthetic_Limb/L = limb
		spawn()
			if(!M || !L)
				return
			M.ProstheticFitUse(L)
			if(M && M.client)
				if(L && L.loc == M)
					M.client.ShowItemDesc(L)
				else
					M.client.HideItemDesc()

client/MaimDescButton(obj/Items/I, list/objs)
	..()
	if(!I || !islist(objs) || I.type != /obj/Items/Gear/Prosthetic_Limb || I.suffix == "*Equipped*")
		return
	var/atom/movable/shud/invfitbtn/b = new
	b.limb = I
	b.maptext_width = 100
	b.maptext = "<span style=\"[MINV_FONT]; color:#8be9ff\">&#9874; Fit to a limb</span>"
	b.screen_loc = "[InvXLoc(MAIM_INV_BTN_X)],CENTER:[MAIM_INV_BTN_Y]"
	objs += b
