/atom/movable/shud/ougi_gauge
	mouse_opacity = 0

/atom/movable/shud/ougi_gauge/Click()
	if(usr && usr.client && usr.client.ougi_gauge_mode == "full")
		usr.UseOugi()

mob/proc/OugiGaugeFrac()
	var/cap = max(getTensionCap(), 1)
	return clamp(Tension / cap, 0, 1)

#define OUGI_TAB_GOLD "#ffd278"
#define OUGI_TAB_GRAY "#9fb4c7"

/atom/movable/shud/skmenu_icon/ougi
	mouse_drag_pointer = 0

/atom/movable/shud/skmenu_icon/ougi/New()
	..()
	OugiOutline()

/atom/movable/shud/skmenu_icon/ougi/proc/OugiOutline(hover = 0)
	var/mob/M = skill ? skill.loc : null
	var/equipped = ismob(M) && M.EquippedOugi == "[skill.type]"
	var/col = hover ? "#8be9ff" : (equipped ? OUGI_TAB_GOLD : "#29b8d4")
	filters = filter(type="outline", size=1, color=col)

/atom/movable/shud/skmenu_icon/ougi/MouseEntered(location, control, params)
	OugiOutline(1)
	usr?.client?.SkillMenuHoverIcon(skill, TRUE)

/atom/movable/shud/skmenu_icon/ougi/MouseExited(location, control, params)
	OugiOutline(0)
	usr?.client?.SkillMenuHoverIcon(skill, FALSE)

/atom/movable/shud/skmenu_icon/ougi/Click(location, control, params)
	if(!usr || !usr.client || !skill) return
	if(params && findtext(params, "right=1"))
		if(usr.client.skinfo_skill == skill) usr.client.CloseSkillInfo()
		else usr.client.ShowSkillInfo(skill)
		return
	if(usr.OugiEquip(skill)) usr.client.BuildSkillMenuGrid()

/atom/movable/shud/skmenu_icon/ougi/MouseDrop(atom/over_object, atom/src_location, atom/over_location, src_control, over_control, params)
	return

client/var/tmp/atom/movable/shud/menutext/ougi_tab_sub

mob/proc/OugiOwnedList()
	var/list/out = list()
	var/list/owned = list()
	for(var/obj/Skills/Ougi/O in contents)
		owned[O.type] = O
	if(!owned.len) return out
	for(var/c in list("Unarmed", "Armed", "Gun", "Energy"))
		for(var/T in subtypesof(/obj/Skills/Ougi))
			var/obj/Skills/Ougi/O = owned[T]
			if(O && O.OugiCategory == c) out += O
	return out

client/proc/OugiTabSummary(obj/Skills/Ougi/O)
	if(!O) return ""
	return "[O.OugiCategory] | [O.OugiBlendShort()] | [O.OugiSecondary]"

client/proc/OugiTabFooter()
	if(!skmenu_pagetext || !mob) return
	var/obj/Skills/Ougi/E = mob.OugiEquipped()
	var/pg = (skmenu_pages > 1) ? "  [skmenu_page]/[skmenu_pages]" : ""
	if(E)
		skmenu_pagetext.maptext = "<center><span style=\"[MHUD_FONT]; color:[OUGI_TAB_GOLD]\">Equipped: [E.name][pg]</span></center>"
	else
		skmenu_pagetext.maptext = "<center><span style=\"[MHUD_FONT]; color:[OUGI_TAB_GRAY]\">No Ougi equipped[pg]</span></center>"
	OugiTabSubline(E, E ? E.OugiGateNote(mob) : null)

client/proc/OugiTabSubline(obj/Skills/Ougi/O, note)
	if(!ougi_tab_sub) return
	var/t = note ? note : OugiTabSummary(O)
	ougi_tab_sub.maptext = "<center><span style=\"[MHUD_FONT]; color:[OUGI_TAB_GRAY]\">[t]</span></center>"

client/BuildSkillMenuGrid(fade = FALSE)
	if(skmenu_tab != "Ougi") return ..()
	if(!mob || !skmenu_open) return
	while(skmenu_icon_objs.len)
		var/atom/movable/o = skmenu_icon_objs[skmenu_icon_objs.len]
		skmenu_icon_objs.len--
		screen -= o
		del o
	ougi_tab_sub = null
	var/list/L = mob.OugiOwnedList()
	skmenu_pages = max(1, -round(-L.len / SKMENU_PAGE_SIZE))
	skmenu_page = min(max(skmenu_page, 1), skmenu_pages)
	var/start = (skmenu_page - 1) * SKMENU_PAGE_SIZE
	for(var/k = 1 to SKMENU_PAGE_SIZE)
		var/idx = start + k
		if(idx > L.len) break
		var/obj/Skills/Ougi/S = L[idx]
		var/col = (k - 1) % SKMENU_COLS
		var/row = round((k - 1) / SKMENU_COLS)
		var/gx = SKMENU_GRID_X0 + col * SKMENU_GRID_PITCH
		var/gy = SKMENU_GRID_Y0 - row * SKMENU_GRID_PITCH
		var/atom/movable/shud/skmenu_icon/ougi/E = new
		E.skill = S
		E.icon = SkillMenuIcon(S)
		E.icon_state = SkillMenuIconState(S)
		E.screen_loc = "CENTER:[gx],CENTER:[gy]"
		E.OugiOutline()
		skmenu_icon_objs += E
		if(mob.EquippedOugi == "[S.type]")
			var/atom/movable/shud/menutext/b = new
			b.layer = MHUD_LAYER + 0.45
			b.maptext_width = 8
			b.maptext_height = 16
			b.maptext = "<span style=\"[MHUD_FONT]; color:[OUGI_TAB_GOLD]\">E</span>"
			b.screen_loc = "CENTER:[gx + 24],CENTER:[gy - 4]"
			skmenu_icon_objs += b
		if(S.SecretOugi)
			var/atom/movable/shud/menutext/s = new
			s.layer = MHUD_LAYER + 0.45
			s.maptext_width = 32
			s.maptext_height = 16
			s.maptext = "<center><span style=\"[MHUD_FONT]; color:[OUGI_TAB_GOLD]\">S</span></center>"
			s.screen_loc = "CENTER:[gx],CENTER:[gy + 24]"
			skmenu_icon_objs += s
	ougi_tab_sub = new
	ougi_tab_sub.maptext_width = 280
	ougi_tab_sub.maptext_height = 16
	ougi_tab_sub.screen_loc = "CENTER:-140,CENTER:-98"
	skmenu_icon_objs += ougi_tab_sub
	for(var/atom/movable/o in skmenu_icon_objs)
		screen += o
	OugiTabFooter()
	PanShift(skmenu_icon_objs, sk_pan_x, sk_pan_y)
	if(fade)
		KineticEntrance(skmenu_icon_objs)

client/UpdateSkillPageText()
	if(skmenu_tab == "Ougi") return OugiTabFooter()
	return ..()

client/SkillMenuHoverIcon(obj/Skills/S, over)
	if(skmenu_tab != "Ougi" || !istype(S, /obj/Skills/Ougi)) return ..()
	if(!skmenu_open || !skmenu_pagetext) return
	var/obj/Skills/Ougi/O = S
	if(over)
		var/tag = O.SecretOugi ? "  <span style=\"color:[OUGI_TAB_GOLD]\">SECRET</span>" : ""
		skmenu_pagetext.maptext = "<center><span style=\"[MHUD_FONT]; color:#8be9ff\">[O.name][tag]</span></center>"
		OugiTabSubline(O, null)
	else
		OugiTabFooter()

client/proc/AqBuildOugiTab()
	for(var/c in list("Unarmed", "Armed", "Gun", "Energy"))
		AqHeader("[uppertext(c)]  &#183;  [glob.OUGI_RPP_COST] RPP")
		for(var/T in subtypesof(text2path("/obj/Skills/Ougi/[c]")))
			var/obj/Skills/Ougi/P = T
			if(initial(P.SecretOugi) || initial(P.SagaOugi)) continue
			var/n = aq_entries.len
			AqAddBuyable("[T]", glob.OUGI_RPP_COST, "ougi")
			if(aq_entries.len == n) continue
			var/datum/aqentry/E = aq_entries[aq_entries.len]
			E.name = initial(P.name)
			if(!E.can_buy) continue
			var/why = null
			if(mob.Saga) why = "Saga characters receive their Ougi through their Saga."
			else if(mob.Potential < glob.OUGI_POTENTIAL) why = "Ougis open at Potential [glob.OUGI_POTENTIAL]."
			if(why)
				E.can_buy = 0
				E.name_col = AQ_C_LOCKED
				E.right = "LOCKED"
				E.right_col = AQ_C_NOFUND
				E.lock_reason = why

client/InitGuardBar()
	..()
	InitOugiGauge()

client/ResetGuardBar()
	ResetOugiGauge()
	..()

client/PositionGuardBar()
	..()
	PositionOugiGauge()

client/UpdateGuardBar()
	..()
	UpdateOugiGauge()

client/proc/InitOugiGauge()
	ResetOugiGauge()
	ougi_track = new /atom/movable/shud/ougi_gauge
	ougi_track.icon = FIN_TRACK_RSC
	ougi_track.layer = MCARD_LAYER
	ougi_track.filters = filter(type="outline", size=1, color=glob.OUGI_GAUGE_EDGE)
	ougi_fill = new /atom/movable/shud/ougi_gauge
	ougi_fill.icon = OUGI_FILL_GOLD_ART
	ougi_fill.layer = MCARD_LAYER + 0.01
	ougi_fill.filters = filter(type="alpha", icon=FIN_MASK_RSC, x=-FIN_TRACKW)
	screen += ougi_track
	screen += ougi_fill
	ougi_sparkles = list()
	for(var/st in list("a", "b", "c"))
		var/atom/movable/shud/ougi_gauge/K = new
		K.icon = OUGI_SPARKLE_ART
		K.icon_state = st
		K.blend_mode = BLEND_ADD
		K.layer = MCARD_LAYER + 0.02
		ougi_sparkles += K
		screen += K
	ougi_gauge_last = 0
	HideOugiGauge()

client/proc/ResetOugiGauge()
	for(var/atom/movable/o in list(ougi_track, ougi_fill) + (ougi_sparkles ? ougi_sparkles : list()))
		if(o)
			screen -= o
			del o
	ougi_track = null
	ougi_fill = null
	ougi_sparkles = null
	ougi_gauge_shown = 0
	ougi_gauge_mode = null

client/proc/HideOugiGauge()
	ougi_gauge_shown = 0
	OugiGaugeGlow(0)
	ougi_gauge_mode = null
	for(var/atom/movable/o in list(ougi_track, ougi_fill))
		if(!o) continue
		o.alpha = 0
		o.screen_loc = null
		o.mouse_opacity = 0
	OugiSparkles(0)

client/proc/PositionOugiGauge()
	if(!ougi_track || !ougi_gauge_shown) return
	var/sl = "CENTER:[FIN_CX],SOUTH:[glob.OUGI_GAUGE_SOUTH]"
	ougi_track.screen_loc = sl
	ougi_fill.screen_loc = sl
	OugiSparkles(ougi_gauge_mode == "full")

client/proc/OugiSparkles(on)
	if(!ougi_sparkles) return
	var/list/spots = list(list(214, 6), list(120, 12), list(46, 6))
	for(var/i = 1 to ougi_sparkles.len)
		var/atom/movable/shud/ougi_gauge/K = ougi_sparkles[i]
		if(!K) continue
		if(on && ougi_gauge_shown)
			var/list/sp = spots[i]
			K.screen_loc = "CENTER:[FIN_CX + sp[1] - 27],SOUTH:[glob.OUGI_GAUGE_SOUTH + 20 - sp[2] - 27]"
			K.alpha = 230
		else
			K.alpha = 0
			K.screen_loc = null

client/proc/OugiGaugeGlow(on)
	if(!ougi_track) return
	if(on)
		ougi_track.filters = list(filter(type="outline", size=1, color=glob.OUGI_GAUGE_EDGE), filter(type="drop_shadow", size=2, color=glob.OUGI_GAUGE_GLOW, x=0, y=0), filter(type="drop_shadow", size=2, color=glob.OUGI_GAUGE_GLOW, x=0, y=0))
		var/atom/movable/T = ougi_track
		spawn(1)
			if(T && T.filters.len >= 3)
				for(var/n = 2 to 3)
					animate(T.filters[n], size = 5, time = 9, loop = -1)
					animate(size = 2, time = 9)
	else
		ougi_track.filters = filter(type="outline", size=1, color=glob.OUGI_GAUGE_EDGE)

client/proc/UpdateOugiGauge()
	if(!mob || !ougi_track) return
	var/obj/Skills/Ougi/O = mob.OugiEquipped()
	if(!O || cutscene_active)
		if(ougi_gauge_shown) HideOugiGauge()
		return
	if(!ougi_gauge_shown)
		ougi_gauge_shown = 1
		ougi_track.alpha = 255
		ougi_fill.alpha = 255
		PositionOugiGauge()
	var/frac = mob.OugiGaugeFrac()
	var/px = frac ? FIN_FILL_X + round(FIN_SPAN * frac) : 0
	if(px != ougi_gauge_last)
		var/tm = OrbAnimTime(ougi_gauge_last, px)
		if(tm) animate(ougi_fill.filters[1], x = px - FIN_TRACKW, time = tm, easing = SINE_EASING)
		else ougi_fill.filters = filter(type="alpha", icon=FIN_MASK_RSC, x = px - FIN_TRACKW)
		ougi_gauge_last = px
	var/mode = "fill"
	if(mob.tempTensionLock || mob.HasTensionLock()) mode = "locked"
	else if(frac >= 1) mode = "full"
	if(mode == ougi_gauge_mode) return
	ougi_gauge_mode = mode
	ougi_fill.icon = (mode == "locked") ? OUGI_FILL_LOCKED_ART : OUGI_FILL_GOLD_ART
	OugiGaugeGlow(mode == "full")
	OugiSparkles(mode == "full")
	ougi_track.mouse_opacity = (mode == "full") ? 2 : 0
	ougi_fill.mouse_opacity = (mode == "full") ? 2 : 0

globalTracker/var/tmp/OUGI_CHAIN_BADGE_GAP = 4

/obj/ougi_screen/chain_badge
	layer = 40
	maptext_height = 16

proc/OugiChainBadgeRender(obj/ougi_screen/chain_badge/B, count, cat)
	if(!B) return
	var/title = "CHAIN [count]"
	var/bw = OugiPlateWidth(title)
	var/fw = OUGI_FRAME_TILES * world.icon_size
	B.icon = OugiPlateIcon(OugiPlateColor(cat), bw)
	B.screen_loc = "1:[round((fw - bw) / 2)],1:[fw - glob.OUGI_PLATE_TOP_GAP - OUGI_PLATE_H * 2 - glob.OUGI_CHAIN_BADGE_GAP]"
	B.maptext_width = bw
	B.maptext_x = round((bw - (length(title) * OUGI_FONT_ADVANCE - 1)) / 2)
	B.maptext_y = OugiPlateTextY(title)
	B.maptext = "<span style=\"[MCARD_FONT]; color:#ffffff\">[title]</span>"
