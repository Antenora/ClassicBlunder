#define OPP_CHANCE_BASE 10
#define OPP_CHANCE_PITY 15
#define OPP_CHANCE_MAX 100
#define OPP_ACCEPTS_PER_DAY 2

/datum/life_opp
	var/id
	var/skill
	var/name
	var/desc
	var/rank_req = 1
	var/rare = 0
	var/kind              // windfall | challenge_timing | challenge_hold | fish_arm | farm_mod | soon
	var/mag = 1           // kind-specific magnitude (windfall count, farm yield mult /10, etc)

var/list/LifeOppDefs = list()       // id -> datum
var/list/LifeOppCommons = list()    // skill -> common id
var/list/LifeOppRares = list()      // skill -> list of rare ids (rotates daily)

proc/LifeOppAdd(id, skill, name, desc, rank_req, rare, kind, mag = 1)
	var/datum/life_opp/o = new
	o.id = id
	o.skill = skill
	o.name = name
	o.desc = desc
	o.rank_req = rank_req
	o.rare = rare
	o.kind = kind
	o.mag = mag
	LifeOppDefs[id] = o
	if(rare)
		if(!LifeOppRares[skill]) LifeOppRares[skill] = list()
		var/list/L = LifeOppRares[skill]
		L += id
	else
		LifeOppCommons[skill] = id

proc/RegisterLifeOpps()
	if(LifeOppDefs.len) return
	// commons: instant windfalls
	LifeOppAdd("ore_pocket",     "Mining",   "Ore Pocket",      "a strike exposes a bonus pocket of the same ore", 1, 0, "windfall", 3)
	LifeOppAdd("verdant_bloom",  "Foraging", "Verdant Bloom",   "a gather turns up a hidden flush of the same growth", 1, 0, "windfall", 3)
	LifeOppAdd("feeding_frenzy", "Fishing",  "Feeding Frenzy",  "a school churns - bonus fish on a catch", 1, 0, "windfall", 2)
	LifeOppAdd("open_season",    "Hunting",  "Open Season",     "a clean carve frees extra usable parts", 1, 0, "windfall", 2)
	LifeOppAdd("bumper_sprouts", "Farming",  "Bumper Sprouts",  "a harvest comes up half again as heavy", 1, 0, "farm_mod", 15)   // mag = +50%
	// rares: failable challenges and armed strikes
	LifeOppAdd("motherlode",     "Mining",   "Unstable Motherlode", "crack an exposed motherlode before it collapses - ore hoard + a gem", 4, 1, "challenge_timing", 6)
	LifeOppAdd("crystal_seam",   "Mining",   "Crystal Seam",        "a glittering seam - steady hands pry the gems intact", 6, 1, "challenge_hold", 2)
	LifeOppAdd("rare_specimen",  "Foraging", "Rare Specimen",       "a prize specimen sprouts nearby - take it without bruising it", 4, 1, "challenge_hold", 5)
	LifeOppAdd("verdant_cache",  "Foraging", "Verdant Cache",       "a hidden cache of growth - work fast before it scatters", 6, 1, "challenge_timing", 6)
	LifeOppAdd("legendary_strike","Fishing", "Legendary Strike",    "something enormous circles - your next hook here fights like a legend", 4, 1, "fish_arm", 1)
	LifeOppAdd("sunken_cache",   "Fishing",  "Sunken Cache",        "your next catch drags up more than fish", 6, 1, "fish_arm", 2)
	LifeOppAdd("mutant_growth",  "Farming",  "Mutant Growth",       "a harvest mutates - double yield, finer quality", 4, 1, "farm_mod", 20)
	LifeOppAdd("golden_harvest", "Farming",  "Golden Harvest",      "a once-a-season pull - triple yield", 6, 1, "farm_mod", 30)
	LifeOppAdd("prime_pelts",    "Hunting",  "Prime Pelts",         "a pristine carcass - extra parts at finer quality", 4, 1, "windfall", 3)
	LifeOppAdd("alpha_contract", "Hunting",  "Contract: Alpha Mark", "a marked beast stalks the carver... (contracts arrive soon)", 6, 1, "soon")

var/list/LIFE_OPP_SKILLS = list("Mining", "Hunting", "Foraging", "Fishing", "Farming")

// today's rare rotates with the day
proc/LifeOppTodayRare(skill)
	RegisterLifeOpps()
	var/list/rares = LifeOppRares[skill]
	if(!rares || !rares.len) return null
	var/off = 0
	for(var/s in LIFE_OPP_SKILLS)
		if(s == skill) break
		off++
	return rares[((DaysOfWipe() + off * 3) % rares.len) + 1]

mob/var/opp_day = -1
mob/var/list/opp_accepted      // id > 1 accepted, 2 complete (reset daily)
mob/var/opp_accepts = 0        // accept slots used today (max OPP_ACCEPTS_PER_DAY)
mob/var/opp_pity = 0
mob/var/opp_fish_armed = ""    // armed fishing listing, consumed on the next catch

mob/proc/OppSettleDay()
	if(opp_day == DaysOfWipe()) return
	opp_day = DaysOfWipe()
	opp_accepted = list()
	opp_accepts = 0
	opp_fish_armed = ""

mob/proc/OppState(id)          // 0 none, 1 accepted, 2 complete
	OppSettleDay()
	if(!opp_accepted) opp_accepted = list()
	return opp_accepted[id] ? opp_accepted[id] : 0

mob/proc/OppMarkComplete(datum/life_opp/o)
	if(!opp_accepted) opp_accepted = list()
	opp_accepted[o.id] = 2
	src << "<font color=#78eb78><b>Opportunity complete: [o.name].</b></font>"
	if(client && client.oppmenu_open) client.RefreshOppMenu()

mob/proc/LifeOppRoll(skill, tier, ytype, q = QUAL_NORMAL, kind_filter = "")
	if(!client) return null
	OppSettleDay()
	RegisterLifeOpps()
	var/rank = LifeRank(skill)
	var/list/eligible = list()
	for(var/id in list(LifeOppCommons[skill], LifeOppTodayRare(skill)))
		if(!id) continue
		var/datum/life_opp/o = LifeOppDefs[id]
		if(!o || o.kind == "soon" || rank < o.rank_req) continue
		if(OppState(id) != 1) continue
		if(kind_filter && o.kind != kind_filter) continue
		if(!kind_filter && o.kind == "farm_mod") continue
		eligible += o
	if(!eligible.len)
		return null
	var/chance = OPP_CHANCE_BASE + opp_pity * OPP_CHANCE_PITY
	if(!prob(min(chance, OPP_CHANCE_MAX)))
		opp_pity++
		return null
	opp_pity = 0
	var/datum/life_opp/o = pick(eligible)
	FireLifeOpp(o, skill, tier, ytype, q, rank)
	return o

mob/proc/FireLifeOpp(datum/life_opp/o, skill, tier, ytype, q, rank)
	switch(o.kind)
		if("windfall")
			var/wq = q
			if(o.id == "prime_pelts") wq = min(q + 1, LifeQualityCap(rank))
			src << "<font color=#b46bff><b>[o.name]!</b></font>"
			OppGrant(skill, ytype, o.mag, wq)
			OppMarkComplete(o)
		if("challenge_timing", "challenge_hold")
			spawn() RunOppChallenge(o, skill, tier, ytype, rank)
		if("fish_arm")
			opp_fish_armed = o.id
			src << "<font color=#b46bff><b>[o.name]!</b> [o.desc]</font>"
		if("farm_mod")
			src << "<font color=#b46bff><b>[o.name]!</b> [o.desc]</font>"
			OppMarkComplete(o)

mob/proc/OppGrant(skill, ytype, n, q)
	if(!ytype || n <= 0) return
	var/obj/Items/Material/s = new ytype
	var/nm = s.name
	del s
	GiveMaterial(src, ytype, n, q)
	src << "<font color=#78eb78>+[n]x [QualityName(q)] [nm].</font>"
	LifeLogFind(skill, nm)

// the failable extra round
mob/proc/RunOppChallenge(datum/life_opp/o, skill, tier, ytype, rank)
	if(!client || client.life_minigame_sink) return
	src << "<font color=#b46bff><b>[o.name]!</b> [o.desc]</font>"
	sleep(8)
	var/D = min(tier * 2 + 1, 10)
	var/perf
	if(o.kind == "challenge_timing")
		perf = RunLifeMinigame(src, "timing_bar", D, list("speed_mult" = 1.2))
	else
		var/need = LIFE_HOLD_NEED(D)
		perf = RunLifeMinigame(src, "hold_fill", D, list("need" = need, "limit" = round(need * 1.3)))
	if(perf < 1.0)
		src << "<font color=#ff6464>It slips away - the [o.name] is lost for now.</font>"
		return
	// the prize
	var/wq = min(QUAL_GOOD + (perf >= 1.4 ? 1 : 0), LifeQualityCap(rank))
	switch(o.id)
		if("motherlode")
			src << "<font color=#b46bff>The motherlode cracks open!</font>"
			OppGrant(skill, ytype, o.mag + round(rank / 2), wq)
			var/gem_id = LifeRandomGemFor(tier)
			if(gem_id)
				var/datum/ore_def/g = LifeOreDef(gem_id)
				if(g)
					src << "<font color=#b46bff>A [g.name] gleams in the rubble!</font>"
					OppGrant("Mining", g.yield_type, 1, wq)
			AddLifeXP(skill, LifeGatherXP(skill, tier) * 2, LIFE_PERF_MAX)
		if("crystal_seam")
			src << "<font color=#b46bff>The seam yields its crystals intact!</font>"
			for(var/i = 1 to o.mag)
				var/gem_id = LifeRandomGemFor(tier)
				if(gem_id)
					var/datum/ore_def/g = LifeOreDef(gem_id)
					if(g) OppGrant("Mining", g.yield_type, 1, min(wq + 1, LifeQualityCap(rank)))
			AddLifeXP(skill, LifeGatherXP(skill, tier) * 2, LIFE_PERF_MAX)
		if("rare_specimen")
			src << "<font color=#b46bff>The specimen comes up whole - a beauty!</font>"
			OppGrant(skill, ytype, o.mag, wq)
			OppGrant(skill, ytype, 1, min(wq + 1, LifeQualityCap(rank)))
			AddLifeXP(skill, LifeGatherXP(skill, tier) * 2, LIFE_PERF_MAX)
		if("verdant_cache")
			src << "<font color=#b46bff>The cache spills open!</font>"
			OppGrant(skill, ytype, o.mag + round(rank / 2), wq)
			AddLifeXP(skill, LifeGatherXP(skill, tier) * 2, LIFE_PERF_MAX)
	OppMarkComplete(o)

mob/proc/OppFishArmed()
	return opp_fish_armed && LifeOppDefs[opp_fish_armed] ? LifeOppDefs[opp_fish_armed] : null

mob/proc/OppFishResolve(datum/life_opp/o, tier, rank)
	opp_fish_armed = ""
	if(o.id == "sunken_cache")
		var/loot = tier * 400
		GiveMoney(loot)
		var/gem_id = LifeRandomGemFor(tier)
		if(gem_id)
			var/datum/ore_def/g = LifeOreDef(gem_id)
			if(g)
				GiveMaterial(src, g.yield_type, 1, min(QUAL_GOOD, LifeQualityCap(rank)))
				src << "<font color=#b46bff>Tangled in the line: a [g.name] and $[Commas(loot)] in salvage!</font>"
			else
				src << "<font color=#b46bff>Tangled in the line: $[Commas(loot)] in salvage!</font>"
		AddLifeXP("Fishing", LifeGatherXP("Fishing", tier) * 2, LIFE_PERF_MAX)
	OppMarkComplete(o)

#define OB_LAYER (FLY_LAYER + 4.7)
#define OB_W 624
#define OB_H 344
#define OB_CARD_W 244
#define OB_CARD_H 50
#define OB_ROW_PITCH 54

/atom/movable/shud/obbg
	layer = OB_LAYER
	mouse_opacity = 2
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	MouseDown(location, control, params)
		if(usr) usr.client.OppPanelStart(params)
	MouseDrag(over, src_loc, over_loc, src_ctrl, over_ctrl, params)
		if(usr) usr.client.OppPanelMove(params)
	MouseUp(location, control, params)
		if(usr) usr.client.OppPanelEnd()

/atom/movable/shud/obpic
	layer = OB_LAYER + 0.3
	mouse_opacity = 0

/atom/movable/shud/obtext
	layer = OB_LAYER + 0.6
	mouse_opacity = 0
	New()
		..()
		filters = filter(type = "outline", size = 1, color = "#000000")

/atom/movable/shud/obbtn
	layer = OB_LAYER + 0.5
	mouse_opacity = 2
	var/oid
	MouseEntered(location, control, params)
		filters = filter(type = "drop_shadow", x = 0, y = 0, size = 2, color = "#8be9ff")
	MouseExited(location, control, params)
		filters = null
	Click()
		if(usr && usr.client) usr.client.OppAcceptClick(oid)

/atom/movable/shud/obconfirm
	layer = OB_LAYER + 1.1
	mouse_opacity = 2
	var/act
	MouseEntered(location, control, params)
		filters = filter(type = "drop_shadow", x = 0, y = 0, size = 2, color = "#8be9ff")
	MouseExited(location, control, params)
		filters = null
	Click()
		if(usr && usr.client) usr.client.OppConfirmAction(act)

/atom/movable/shud/obwidget
	parent_type = /atom/movable/shud/pressbtn
	layer = OB_LAYER + 0.65
	mouse_opacity = 2
	DoAction()
		if(usr && usr.client) usr.client.CloseOppMenu()

client
	var/tmp
		oppmenu_open = 0
		list/opp_hud
		list/opp_confirm_objs
		opp_confirm_id = ""
		opp_atx = 1
		opp_aty = 1
		opp_pan_x = 0
		opp_pan_y = 0
		opp_pan_mx = 0
		opp_pan_my = 0
		opp_pan_ox = 0
		opp_pan_oy = 0
		opp_pan_dragged = 0

client/proc/OBloc(dx, dyTop, h = 0)
	var/py = OB_H - dyTop - h
	var/ax = dx + opp_pan_x
	var/ay = py + opp_pan_y
	var/axp = ((ax % 32) + 32) % 32
	var/ayp = ((ay % 32) + 32) % 32
	return "[opp_atx + (ax - axp) / 32]:[axp],[opp_aty + (ay - ayp) / 32]:[ayp]"

client/proc/ObAdd(atom/movable/o)
	opp_hud += o
	screen += o

client/proc/ObText(dx, dyTop, w, h, txt, lay = 0.6)
	var/atom/movable/shud/obtext/T = new
	T.layer = OB_LAYER + lay
	T.maptext_width = w
	T.maptext_height = h
	T.screen_loc = OBloc(dx, dyTop, h)
	T.maptext = txt
	ObAdd(T)
	return T

client/proc/ToggleOppMenu()
	if(oppmenu_open) CloseOppMenu()
	else OpenOppMenu()

client/proc/OpenOppMenu()
	if(oppmenu_open || !mob) return
	CloseLifeSkillsMenu()
	oppmenu_open = 1
	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	if(isnull(vw)) vw = 20
	if(isnull(vh)) vh = 15
	var/mtw = round(OB_W / 32); if(mtw * 32 < OB_W) mtw++
	var/mth = round(OB_H / 32); if(mth * 32 < OB_H) mth++
	opp_atx = max(1, round((vw - mtw) / 2) + 1)
	opp_aty = max(1, round((vh - mth) / 2) + 1)
	opp_pan_x = getPref("oppPanX"); if(isnull(opp_pan_x)) opp_pan_x = 0
	opp_pan_y = getPref("oppPanY"); if(isnull(opp_pan_y)) opp_pan_y = 0
	var/list/pb = OppPanBounds()
	opp_pan_x = clamp(opp_pan_x, pb[1], pb[2])
	opp_pan_y = clamp(opp_pan_y, pb[3], pb[4])
	opp_hud = list()
	var/atom/movable/shud/obbg/P = new
	P.icon = 'HUD/tech_panel.png'
	P.screen_loc = OBloc(0, 0, OB_H)
	ObAdd(P)
	var/atom/movable/shud/obpic/tp = new
	tp.icon = 'HUD/tech_titleplate.png'
	tp.screen_loc = OBloc(212, 6, 32)
	ObAdd(tp)
	ObText(212, 12, 200, 16, "<center><span style=\"[FP_FONT]; color:#ffffff\">OPPORTUNITIES</span></center>")
	var/atom/movable/shud/obwidget/X = new
	X.widget_kind = "cross"
	X.icon = 'HUD/ui_cross_1.png'
	X.screen_loc = OBloc(590, 12, 24)
	ObAdd(X)
	RefreshOppMenu()

client/proc/CloseOppMenu()
	if(!oppmenu_open && !opp_hud) return
	oppmenu_open = 0
	OppHideConfirm()
	if(opp_hud)
		for(var/atom/movable/o in opp_hud)
			screen -= o
			del o
	opp_hud = null

client/proc/RefreshOppMenu()
	if(!oppmenu_open || !mob) return
	OppHideConfirm()
	// everything after the chrome rebuilds
	while(opp_hud.len > 4)
		var/atom/movable/o = opp_hud[opp_hud.len]
		opp_hud.len--
		screen -= o
		del o
	var/mob/M = mob
	M.OppSettleDay()
	RegisterLifeOpps()
	ObText(462, 38, 140, 16, "<span style=\"[FP_FONT]; color:[M.opp_accepts >= OPP_ACCEPTS_PER_DAY ? "#ff6464" : FP_C_COST]; text-align:right\">ACCEPTED [M.opp_accepts]/[OPP_ACCEPTS_PER_DAY]</span>")
	var/dy = 62
	for(var/skill in LIFE_OPP_SKILLS)
		var/rank = M.LifeRank(skill)
		ObText(18, dy + 10, 90, 14, "<span style=\"[FP_FONT]; color:#8be9ff\">[uppertext(skill)]</span>")
		ObText(18, dy + 26, 90, 12, "<span style=\"[FP_FONT_BODY]; color:[FP_C_HINT]\">rank [rank]</span>")
		var/list/ids = list(LifeOppCommons[skill], LifeOppTodayRare(skill))
		var/dx = 112
		for(var/id in ids)
			if(!id) continue
			var/datum/life_opp/o = LifeOppDefs[id]
			if(!o) continue
			OppDrawCard(M, o, dx, dy, rank)
			dx += 250
		dy += OB_ROW_PITCH

client/proc/OppDrawCard(mob/M, datum/life_opp/o, dx, dy, rank)
	var/atom/movable/shud/obpic/card = new
	card.icon = 'HUD/opp_card.png'
	card.layer = OB_LAYER + 0.35
	card.screen_loc = OBloc(dx, dy, OB_CARD_H)
	ObAdd(card)
	var/locked = (rank < o.rank_req)
	var/soon = (o.kind == "soon")
	var/state = M.OppState(o.id)
	var/tcol = soon || locked ? FP_C_HINT : (o.rare ? "#b46bff" : "#ffffff")
	var/tag = ""
	if(soon) tag = " <font color=[FP_C_HINT]>(soon)</font>"
	else if(locked) tag = " <font color=#ff6464>(rank [o.rank_req])</font>"
	ObText(dx + 8, dy + 4, 164, 14, "<span style=\"[FP_FONT_BODY]; color:[tcol]\"><b>[o.name]</b>[tag]</span>", 0.62)
	ObText(dx + 8, dy + 19, 160, 26, "<span style=\"[FP_FONT_BODY]; color:[FP_C_HINT]\">[o.desc]</span>", 0.62)
	// right zone: status or the ACCEPT button
	if(soon || locked) return
	if(state == 2)
		ObText(dx + 166, dy + 18, 76, 14, "<center><span style=\"[FP_FONT_BODY]; color:#78eb78\"><b>COMPLETE</b></span></center>", 0.62)
	else if(state == 1)
		ObText(dx + 166, dy + 18, 76, 14, "<center><span style=\"[FP_FONT_BODY]; color:[FP_C_COST]\"><b>ACCEPTED</b></span></center>", 0.62)
	else
		var/atom/movable/shud/obbtn/b = new
		b.icon = 'HUD/opp_btn.png'
		b.oid = o.id
		b.screen_loc = OBloc(dx + 172, dy + 15, 20)
		ObAdd(b)
		ObText(dx + 172, dy + 16, 64, 14, "<center><span style=\"[FP_FONT_BODY]; color:#8be9ff\">ACCEPT</span></center>", 0.62)

client/proc/OppAcceptClick(oid)
	if(!oppmenu_open || !mob) return
	var/datum/life_opp/o = LifeOppDefs[oid]
	if(!o) return
	var/mob/M = mob
	if(M.OppState(oid)) return
	if(M.opp_accepts >= OPP_ACCEPTS_PER_DAY)
		M << "You've already accepted [OPP_ACCEPTS_PER_DAY] opportunities today."
		return
	OppShowConfirm(oid)

client/proc/OppShowConfirm(oid)
	OppHideConfirm()
	var/datum/life_opp/o = LifeOppDefs[oid]
	if(!o) return
	opp_confirm_id = oid
	opp_confirm_objs = list()
	var/atom/movable/shud/obpic/P = new
	P.icon = 'HUD/party_prompt.png'
	P.layer = OB_LAYER + 1.0
	P.mouse_opacity = 2
	P.screen_loc = OBloc(200, 100, 140)
	opp_confirm_objs += P
	var/atom/movable/shud/obtext/T = new
	T.layer = OB_LAYER + 1.15
	T.maptext_width = 200
	T.maptext_height = 32
	T.screen_loc = OBloc(212, 116, 32)
	T.maptext = "<center><span style=\"[FP_FONT_BODY]; color:#ffffff\">Accept <b>[o.name]</b>?<br>([o.skill] - uses 1 of [OPP_ACCEPTS_PER_DAY] daily slots)</span></center>"
	opp_confirm_objs += T
	var/atom/movable/shud/obconfirm/Y = new
	Y.icon = 'HUD/np_btn.png'
	Y.act = "yes"
	Y.screen_loc = OBloc(208, 184, 24)
	opp_confirm_objs += Y
	var/atom/movable/shud/obtext/YL = new
	YL.layer = OB_LAYER + 1.2
	YL.maptext_width = 100
	YL.maptext_height = 16
	YL.screen_loc = OBloc(208, 188, 16)
	YL.maptext = "<center><span style=\"[FP_FONT]; color:#78eb78\">YES</span></center>"
	opp_confirm_objs += YL
	var/atom/movable/shud/obconfirm/N = new
	N.icon = 'HUD/np_btn.png'
	N.act = "no"
	N.screen_loc = OBloc(316, 184, 24)
	opp_confirm_objs += N
	var/atom/movable/shud/obtext/NL = new
	NL.layer = OB_LAYER + 1.2
	NL.maptext_width = 100
	NL.maptext_height = 16
	NL.screen_loc = OBloc(316, 188, 16)
	NL.maptext = "<center><span style=\"[FP_FONT]; color:#ff6464\">NO</span></center>"
	opp_confirm_objs += NL
	for(var/atom/movable/o2 in opp_confirm_objs)
		screen += o2

client/proc/OppHideConfirm()
	opp_confirm_id = ""
	if(opp_confirm_objs)
		for(var/atom/movable/o in opp_confirm_objs)
			screen -= o
			del o
	opp_confirm_objs = null

client/proc/OppConfirmAction(act)
	if(!mob) return
	var/oid = opp_confirm_id
	OppHideConfirm()
	if(act != "yes" || !oid) return
	var/mob/M = mob
	var/datum/life_opp/o = LifeOppDefs[oid]
	if(!o || M.OppState(oid) || M.opp_accepts >= OPP_ACCEPTS_PER_DAY) return
	M.OppSettleDay()
	if(!M.opp_accepted) M.opp_accepted = list()
	M.opp_accepted[oid] = 1
	M.opp_accepts++
	M << "<font color=#b46bff><b>Accepted: [o.name].</b> It'll surface while you [lowertext(o.skill)] today.</font>"
	RefreshOppMenu()

client/proc/OppPanBounds()
	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	var/bx = (opp_atx - 1) * 32
	var/by = (opp_aty - 1) * 32
	var/minx = -bx; if(minx > 0) minx = 0
	var/maxx = vw * 32 - OB_W - bx; if(maxx < 0) maxx = 0
	var/miny = -by; if(miny > 0) miny = 0
	var/maxy = vh * 32 - OB_H - by; if(maxy < 0) maxy = 0
	return list(minx, maxx, miny, maxy)

client/proc/OppShiftLive(dpx, dpy)
	if(!dpx && !dpy) return
	if(opp_hud) PanShift(opp_hud, dpx, dpy)
	if(opp_confirm_objs) PanShift(opp_confirm_objs, dpx, dpy)

client/proc/OppPanelStart(params)
	opp_pan_dragged = 0
	var/list/m = MouseAbs(params)
	if(!m) return
	opp_pan_mx = m[1]; opp_pan_my = m[2]
	opp_pan_ox = opp_pan_x; opp_pan_oy = opp_pan_y

client/proc/OppPanelMove(params)
	if(!oppmenu_open) return
	var/list/m = MouseAbs(params)
	if(!m) return
	var/list/b = OppPanBounds()
	var/wantx = clamp(opp_pan_ox + (m[1] - opp_pan_mx), b[1], b[2])
	var/wanty = clamp(opp_pan_oy + (m[2] - opp_pan_my), b[3], b[4])
	var/dx = wantx - opp_pan_x
	var/dy = wanty - opp_pan_y
	if(!dx && !dy) return
	opp_pan_x = wantx; opp_pan_y = wanty
	opp_pan_dragged = 1
	OppShiftLive(dx, dy)

client/proc/OppPanelEnd()
	if(!opp_pan_dragged) return
	opp_pan_dragged = 0
	setPref("oppPanX", opp_pan_x)
	setPref("oppPanY", opp_pan_y)

mob/Admin4/verb/oppForceNext()
	set category = "Admin"
	opp_pity = 100
	src << "Pity maxed - your next qualifying gather triggers an accepted opportunity."

mob/Admin4/verb/oppResetDay()
	set category = "Admin"
	opp_day = -1
	OppSettleDay()
	src << "Opportunity day reset - accepts cleared."

mob/Admin4/verb/lifeSetRank(skill as text, newrank as num)
	set category = "Admin"
	if(!(skill in LIFE_SKILL_IDS))
		src << "No such life skill. ([jointext(LIFE_SKILL_IDS, ", ")])"
		return
	newrank = clamp(round(newrank), 1, LIFE_MAX_RANK)
	var/datum/lifeskill/S = GetLifeSkill(skill)
	var/old = S.rank
	S.rank = newrank
	if(newrank > old)
		for(var/r = old + 1 to newrank)
			GrantLifeRankPerks(skill, r)
	src << "[skill] rank: [old] -> [newrank]."
