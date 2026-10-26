var/list/SCOUTER_CEILING = list(2, 5, 10, 20, 40)
var/list/SCOUTER_RANGE = list(6, 10, 13, 16, 20)

#define SCOUTER_GAG_OVER 4
#define SCOUTER_GAG_CHANCE 5
#define SCOUTER_GAG_DAMAGE 5
#define SCOUTER_NAME_RANGE 16
#define SCOUTER_QUIET_POWER 25
#define SCOUTER_PING_RANGE 80
#define SCOUTER_TICK 50
#define SCOUTER_CHARGE 10
#define SCOUTER_SCAN_MINUTE 600
#define SCOUTER_REVEAL_RADIUS 5
#define SCOUTER_ROW_REFRESH 5

#define SCAN_ROW_X 22
#define SCAN_ROW_W 162
#define SCAN_ROW_H 16
#define SCAN_ROW_GAP 3
#define SCAN_ROW_STEP 14
#define SCAN_ROW_CHARS 27
#define SCAN_ROW_COLOR "#bfefff"
#define SCAN_ERR_COLOR "#ff5050"

mob/var/tmp/scouter_watching = 0
mob/var/tmp/scouter_scan_on = 0
mob/var/tmp/scouter_scan_next = 0

/obj/Items/Tech/Scouter
	UpdatesDescription = 1
	var
		Uses = SCOUTER_CHARGE
		MaxUses = SCOUTER_CHARGE

	proc/Update_Description()
		var/q = ScouterBand()
		desc = "[initial(desc)]<br><br>[QualityName(q)]: reads up to [SCOUTER_CEILING[q]]x your own power, [SCOUTER_RANGE[q]] tiles away.<br>Scanner charge: [Uses] of [MaxUses] minutes."

	proc/ScouterBand()
		return QualityClamp(CraftQuality)

	proc/ScouterRange()
		return SCOUTER_RANGE[ScouterBand()]

	proc/ScouterCeiling(mob/M)
		return SCOUTER_CEILING[ScouterBand()] * max(1, M.Get_Scouter_Reading(M))

	ScouterReadPlayers(mob/M)
		if(!M) return
		var/range = ScouterRange()
		var/ceiling = ScouterCeiling(M)
		var/list/shown = list()
		var/blow = 0
		for(var/mob/Players/P in players)
			if(P.z != M.z || P.AdminInviso) continue
			if(P.HasVoid() || P.HasMechanized() || P.HasGodKi() || P.HasMaouKi()) continue
			var/d = get_dist(M, P)
			if(d > range) continue
			var/near = d < SCOUTER_NAME_RANGE
			if(!near && P.PowerControl <= SCOUTER_QUIET_POWER) continue
			shown += P
			var/facing = M.CheckDirection(P)
			if(!facing) facing = "Here"
			var/where = near ? "[facing] - <b><font color='red'>NEARBY</font></b>" : "[facing] - [Commas(d)] tiles away"
			var/who = near ? "<b>[P.name]</b> - " : ""
			var/reading = M.Get_Scouter_Reading(P)
			if(reading > ceiling)
				M << "[who]<font color='red'>ERROR: past this scouter's limit</font> - [where]"
				if(!blow && ScouterBand() == QUAL_POOR && reading > ceiling * SCOUTER_GAG_OVER && prob(SCOUTER_GAG_CHANCE))
					blow = 1
				continue
			M << "[who][Commas(reading)] - [where]"
		for(var/mob/Players/P in players)
			if(P == M || P.z != M.z || P.AdminInviso || (P in shown)) continue
			var/d = get_dist(M, P)
			if(d > SCOUTER_PING_RANGE) continue
			M << "<b>!!!</b> - [M.CheckDirection(P)] - [Commas(d)] tiles away"
		if(blow) ScouterBlowUp(M)

	proc/ScouterBlowUp(mob/M)
		OMsg(M, "<font color='#ff6b6b'>[M]'s scouter overloads and bursts apart!</font>")
		M.LoseHealth(M.PctToHP(SCOUTER_GAG_DAMAGE))
		M.ScannerOff(null)
		if(suffix == "*Equipped*") UnEquip(M)
		loc = null
		if(M.client) M.client.BuildInvPage()
		del src

	proc/ScouterTick(mob/M)
		M.ScouterGrantScanner()
		if(M.scouter_scan_on) M.ScannerPay(src)
		if(M.InMagitekRestrictedRegion() || IsJammed(M)) return
		var/range = ScouterRange()
		var/key = M.DeviceKey()
		for(var/mob/Players/P in players)
			if(P == M || P.z != M.z) continue
			var/d = get_dist(M, P)
			var/facing = M.CheckDirection(P)
			if(!facing) facing = "Here"
			if(d <= range && P.IsTracerTagged())
				M << "<font color='#ffb347'>Tracer signal</font> - [facing] - [Commas(d)] tiles away"
			if(key && P.tracker_tag_by == key && P.IsTrackerTagged() && !IsJammed(P))
				M << "<font color='#8be9ff'>Tracker tag on [P.name]</font> - [facing] - [Commas(d)] tiles away"
		if(M.scouter_scan_on && !M.IsCloaked()) M.RevealCloaked(SCOUTER_REVEAL_RADIUS)

	Equip(mob/A)
		..()
		if(suffix && ismob(A))
			A.ScouterGrantScanner()
			A.ScouterWatch()

	UnEquip(mob/A)
		..()
		if(!suffix && ismob(A) && A.scouter_scan_on && !A.EquippedScouter())
			A.ScannerOff("Your Combat Scanner shuts off with the Scouter.")

/obj/Items/Tech/Power_Pack/RechargeExtras(mob/user)
	. = ..()
	for(var/obj/Items/Tech/Scouter/S in user)
		if(S.Uses < S.MaxUses) . += S

mob/proc/EquippedScouter()
	for(var/obj/Items/Tech/Scouter/S in src)
		if(S.suffix == "*Equipped*") return S
	return null

mob/proc/ScouterWatch()
	if(scouter_watching || !client) return
	scouter_watching = 1
	spawn() ScouterWatchLoop()

mob/proc/ScouterWatchLoop()
	set waitfor = 0
	while(client)
		var/obj/Items/Tech/Scouter/S = EquippedScouter()
		if(!S) break
		S.ScouterTick(src)
		sleep(SCOUTER_TICK)
	scouter_watching = 0
	if(scouter_scan_on && !EquippedScouter()) ScannerOff("Your Combat Scanner shuts off with the Scouter.")

mob/proc/ScouterResume()
	if(EquippedScouter()) ScouterWatch()

mob/Players/Login()
	..()
	spawn(20) ScouterResume()

mob/proc/ScannerKnown()
	return knowledgeTracker && ("Combat Scanning" in knowledgeTracker.learnedKnowledge)

mob/proc/ScouterGrantScanner()
	if(!ScannerKnown()) return
	if(locate(/obj/Skills/Combat_Scanner) in src) return
	AddSkill(new /obj/Skills/Combat_Scanner)
	src << "Your Scouter can run the Combat Scanner now. Its skill is in your skill list, ready for the hotbar."

mob/proc/ScannerPay(obj/Items/Tech/Scouter/S)
	if(world.time < scouter_scan_next) return 1
	if(!S || S.Uses < 1)
		ScannerOff("Your Scouter runs out of charge and the Combat Scanner shuts off.")
		return 0
	S.Uses--
	scouter_scan_next = world.time + SCOUTER_SCAN_MINUTE
	return 1

mob/proc/ScannerToggle()
	if(scouter_scan_on)
		ScannerOff("You switch the Combat Scanner off.")
		return
	if(!ScannerKnown())
		src << "You need the Combat Scanning node to run the scanner."
		return
	var/obj/Items/Tech/Scouter/S = EquippedScouter()
	if(!S)
		src << "Equip a Scouter first."
		return
	if(S.Uses < 1 && world.time >= scouter_scan_next)
		src << "Your Scouter has no charge left for the scanner. A Power Pack recharges it."
		return
	scouter_scan_on = 1
	if(!ScannerPay(S)) return
	src << "Combat Scanner on. Your target's power, ammo and status effects show on their card."
	ScouterWatch()

mob/proc/ScannerOff(msg)
	if(!scouter_scan_on) return 0
	scouter_scan_on = 0
	if(msg) src << msg
	if(client) client.ScannerCardRows(null)
	return 1

/obj/Skills/Combat_Scanner
	name = "Combat Scanner"
	Desc = "Runs your equipped Scouter's Combat Scanner: your target's power reading, loaded ammo and status effects show on their card, and cloaked people within 5 tiles are exposed every 5 seconds. It spends 1 Scouter charge a minute."
	verb/Combat_Scanner()
		set category = "Skills"
		usr.ScannerToggle()

client/var/tmp/list/scan_rows
client/var/tmp/scan_rows_next = 0

client/proc/ScannerRowsMake()
	if(scan_rows) return
	scan_rows = list()
	for(var/i = 1 to 3)
		var/atom/movable/shud/cardtext/r = new
		r.layer = MCARD_LAYER + 0.5
		r.maptext_x = SCAN_ROW_X
		r.maptext_width = SCAN_ROW_W
		r.maptext_height = SCAN_ROW_H
		r.alpha = 0
		scan_rows += r
		screen += r

client/proc/ScannerRowsHide()
	for(var/atom/movable/shud/cardtext/r in scan_rows)
		r.alpha = 0
		r.maptext = ""
	scan_rows_next = 0

client/proc/ScannerRowText(txt, color = SCAN_ROW_COLOR)
	return "<center><span style=\"[MCARD_FONT]; color:[color]\">[txt]</span></center>"

client/proc/ScannerStatusText(mob/T)
	var/list/parts = list()
	for(var/list/d in GetActiveDebuffs(T))
		parts += d[3] ? "[d[2]] [d[3]]" : "[d[2]]"
	return parts.len ? jointext(parts, ", ") : "No status effects"

client/proc/ScannerPowerText(mob/M, mob/T, obj/Items/Tech/Scouter/S)
	if(T.z != M.z || get_dist(M, T) > S.ScouterRange())
		return ScannerRowText("PWR out of range")
	if(T.HasVoid() || T.HasMechanized() || T.HasGodKi() || T.HasMaouKi())
		return ScannerRowText("PWR no reading")
	var/reading = M.Get_Scouter_Reading(T)
	if(reading > S.ScouterCeiling(M))
		return ScannerRowText("PWR ERROR", SCAN_ERR_COLOR)
	return ScannerRowText("PWR [Commas(reading)]")

client/ScannerCardRows(mob/T)
	..()
	var/mob/M = mob
	if(!T || !M || !M.scouter_scan_on || !tcard)
		ScannerRowsHide()
		return
	var/obj/Items/Tech/Scouter/S = M.EquippedScouter()
	if(!S)
		ScannerRowsHide()
		return
	ScannerRowsMake()
	if(world.time < scan_rows_next) return
	scan_rows_next = world.time + SCOUTER_ROW_REFRESH
	var/list/texts = list()
	var/list/heights = list()
	if(M.InMagitekRestrictedRegion() || IsJammed(M))
		texts += ScannerRowText("Scanner: static")
		heights += SCAN_ROW_H
	else
		texts += ScannerPowerText(M, T, S)
		heights += SCAN_ROW_H
		var/obj/Items/Gun/G = T.EquippedGun()
		if(G)
			texts += ScannerRowText("AMMO [G.Loaded] / [G.MagSize]")
			heights += SCAN_ROW_H
		var/list/lines = WrapDescLines(ScannerStatusText(T), SCAN_ROW_CHARS)
		texts += ScannerRowText(jointext(lines, "<br>"))
		heights += SCAN_ROW_H * max(1, lines.len)
	var/top = -SCAN_ROW_GAP
	for(var/i = 1 to scan_rows.len)
		var/atom/movable/shud/cardtext/r = scan_rows[i]
		if(i > texts.len)
			r.alpha = 0
			r.maptext = ""
			continue
		r.maptext_height = heights[i]
		r.screen_loc = TargetChildLoc(0, top - heights[i])
		if(r.maptext != texts[i]) r.maptext = texts[i]
		r.alpha = 255
		top -= heights[i] - SCAN_ROW_H + SCAN_ROW_STEP

client/ScannerCardReset()
	..()
	for(var/atom/movable/o in scan_rows)
		screen -= o
		del o
	scan_rows = null
	scan_rows_next = 0
