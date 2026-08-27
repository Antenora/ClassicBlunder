#define MCARD_LAYER (FLY_LAYER+2)
#define MCARD_FONT "font-family:'monogram'; font-size:12pt"
#define PORTRAIT_SIZE 38

// bundles the default portrait into the rsc
/var/PORTRAIT_DEFAULT_RESOURCE = 'HUD/portrait_default.png'

mob/var/icon/CharPortrait // null = use placeholder, saves with mob

mob/proc/GetPortrait()
	return CharPortrait ? CharPortrait : 'HUD/portrait_default.png'

mob/proc/GetCardPower()
	if(!EnergyMax) return 0
	if(!Kaioken && !passive_handler.Get("Red Hot Rage"))
		return round((Energy / EnergyMax) * 100) * round(GetPowerUpRatioVisble(), 0.01)
	return round((100 / EnergyMax) * 100) * round(GetPowerUpRatioVisble(), 0.01) * KaiokenBP

mob/proc/ChoosePortrait()
	set waitfor = 0
	var/chosen = input(usr, "Choose a portrait image. Intended size is [PORTRAIT_SIZE]x[PORTRAIT_SIZE]. Accepts .png, .bmp, .jpg or .dmi.", "Set Portrait") as null|file
	if(!chosen) return
	var/icon/I = icon(chosen)
	if(!I)
		usr << "<font color=red>That file couldn't be loaded as an image.</font>"
		return
	I.Scale(PORTRAIT_SIZE, PORTRAIT_SIZE)
	CharPortrait = I
	client?.UpdateCharacterCard()
	usr << "Portrait updated."

/atom/movable/shud/cardbg
	mouse_opacity = 1
	layer = MCARD_LAYER
	Click(location, control, params)
		if(!usr) return
		var/list/pl = params2list(params)
		var/ix = text2num(pl["icon-x"])
		var/iy = text2num(pl["icon-y"])
		if(ix >= 21 && ix <= 60 && iy >= 29 && iy <= 68)
			spawn() usr.ChoosePortrait()

/atom/movable/shud/cardtext
	mouse_opacity = 0
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

/atom/movable/shud/intentchip
	layer = MCARD_LAYER + 0.55
	mouse_opacity = 2
	icon = 'HUD/intent_chip.png'
	var/action
	var/labeltext
	var/atom/movable/shud/cardtext/lbl   // outlined label rides above the chip, clicks pass through it
	Click(location, control, params)
		if(usr) usr.client.IntentChipAction(action)


client
	var/tmp
		atom/movable/shud/cardbg/card
		atom/movable/shud/cardtext/cardtext   // line 1: name
		atom/movable/shud/cardtext/cardstatus // line 2: PWR / INJ-LTL / RP
		list/intent_chips
		list/debuff_icons                     // pool of /atom/movable/shud/debufficon
		list/tbuff_icons                      // pool of /atom/movable/shud/tbufficon (timed buffs)
		list/debuff_panel_objs
		debuff_panel_name                     // which debuff the panel is showing, for toggle
		// target card
		atom/movable/shud/cardbg/tcard
		atom/movable/shud/cardtext/tcardtext
		atom/movable/shud/cardtext/tcardstatus
		mob/tcard_last                        // target the composite was last built for, rebuild on change
		atom/movable/shud/tbar_hp_track
		atom/movable/shud/tbar_hp_fill
		atom/movable/shud/cardtext/tbar_hp_text
		atom/movable/shud/tbar_en_track
		atom/movable/shud/tbar_en_fill
		atom/movable/shud/cardtext/tbar_en_text
		atom/movable/shud/tbar_gd_track
		atom/movable/shud/tbar_gd_fill
		atom/movable/shud/tdebuff_icon
		atom/movable/shud/debuffnum/tdebuff_num
		tcard_hp_last = 0
		tcard_en_last = 0
		tcard_gd_last = 0
		tcard_basetile = 1                    // cached card anchor so bars place relative to it
		tcard_basepix = 0
		tcard_row = 1

#define MCARD_W 264        // card icon width
#define MCARD_TILES_TALL 3
#define MCARD_MARGIN_X 6   // px inset from the left edge
#define MCARD_MARGIN_Y 4   // px down from the top
// target card resource bars
#define TBAR_OUTER_W 160   // track icon width
#define TBAR_X 23          // card-local x of the track's left edge
#define TBAR_HP_Y 35
#define TBAR_EN_Y 22
#define TBAR_GD_Y 9
#define TBAR_FILL_W 158
#define TBAR_FILL_INSET 1  // fill offset from the track border
#define TBAR_FONT "font-family:'Pixel Operator 8'; font-size:6pt"
#define TDBUFF_X 204
#define TDBUFF_Y 20
#define INTENT_CHIP_W 58
#define INTENT_CHIP_H 18
#define INTENT_CHIP_GAP 4
#define INTENT_CHIP_BELOW 3 // gap between the card's bottom edge and the chip row
#define INTENT_FONT "font-family:'monogram'; font-size:12pt"

client/proc/InitCharacterCard()
	ResetCharacterCard()
	if(!mob) return
	card = new
	screen += card
	cardtext = new
	cardtext.layer = MCARD_LAYER + 0.5
	cardtext.maptext_width = 162
	cardtext.maptext_height = 40
	cardtext.maptext_x = 80
	cardtext.maptext_y = 60
	screen += cardtext
	cardstatus = new
	cardstatus.layer = MCARD_LAYER + 0.5
	cardstatus.maptext_width = 162
	cardstatus.maptext_height = 40
	cardstatus.maptext_x = 80
	cardstatus.maptext_y = 48
	screen += cardstatus
	InitIntentChips()
	InitFinisherBar()
	InitGuardBar()
	UpdateCharacterCard()
	UpdateCardText()
	PositionCharacterCard()
	UpdateDebuffs()
	UpdateTimedBuffs()
	InitTargetCard()
	InitPartyHUD()

client/proc/InitTargetCard()
	tcard = new
	tcard.alpha = 0
	screen += tcard
	tcardtext = new
	tcardtext.layer = MCARD_LAYER + 0.5
	tcardtext.maptext_width = 162
	tcardtext.maptext_height = 40
	tcardtext.maptext_x = 22
	tcardtext.maptext_y = 60
	tcardtext.alpha = 0
	screen += tcardtext
	tcardstatus = new
	tcardstatus.layer = MCARD_LAYER + 0.5
	tcardstatus.maptext_width = 162
	tcardstatus.maptext_height = 40
	tcardstatus.maptext_x = 22
	tcardstatus.maptext_y = 48
	tcardstatus.alpha = 0
	screen += tcardstatus
	tbar_hp_track = new
	tbar_hp_track.icon = 'HUD/tbar_track.png'
	tbar_hp_track.layer = MCARD_LAYER + 0.55
	tbar_hp_track.alpha = 0
	screen += tbar_hp_track
	tbar_hp_fill = new
	tbar_hp_fill.icon = 'HUD/tbar_fill_hp.png'
	tbar_hp_fill.layer = MCARD_LAYER + 0.56
	tbar_hp_fill.filters = filter(type="alpha", icon='HUD/tbar_mask.png', x=-TBAR_FILL_W) // start empty
	tbar_hp_fill.alpha = 0
	screen += tbar_hp_fill
	tbar_hp_text = new
	tbar_hp_text.layer = MCARD_LAYER + 0.6
	tbar_hp_text.maptext_width = TBAR_OUTER_W
	tbar_hp_text.maptext_height = 16
	tbar_hp_text.maptext_x = 0
	tbar_hp_text.maptext_y = -3
	tbar_hp_text.alpha = 0
	screen += tbar_hp_text
	tbar_en_track = new
	tbar_en_track.icon = 'HUD/tbar_track.png'
	tbar_en_track.layer = MCARD_LAYER + 0.55
	tbar_en_track.alpha = 0
	screen += tbar_en_track
	tbar_en_fill = new
	tbar_en_fill.icon = 'HUD/tbar_fill_en.png'
	tbar_en_fill.layer = MCARD_LAYER + 0.56
	tbar_en_fill.filters = filter(type="alpha", icon='HUD/tbar_mask.png', x=-TBAR_FILL_W)
	tbar_en_fill.alpha = 0
	screen += tbar_en_fill
	tbar_en_text = new
	tbar_en_text.layer = MCARD_LAYER + 0.6
	tbar_en_text.maptext_width = TBAR_OUTER_W
	tbar_en_text.maptext_height = 16
	tbar_en_text.maptext_x = 0
	tbar_en_text.maptext_y = -3
	tbar_en_text.alpha = 0
	screen += tbar_en_text
	tbar_gd_track = new
	tbar_gd_track.icon = 'HUD/tbar_track.png'
	tbar_gd_track.layer = MCARD_LAYER + 0.55
	tbar_gd_track.alpha = 0
	screen += tbar_gd_track
	tbar_gd_fill = new
	tbar_gd_fill.icon = 'HUD/tbar_fill_en.png'
	tbar_gd_fill.layer = MCARD_LAYER + 0.56
	tbar_gd_fill.color = "#e8a33d"	//their guard meter, amber
	tbar_gd_fill.filters = filter(type="alpha", icon='HUD/tbar_mask.png', x=-TBAR_FILL_W)
	tbar_gd_fill.alpha = 0
	screen += tbar_gd_fill
	tdebuff_icon = new
	tdebuff_icon.layer = MCARD_LAYER + 0.6
	tdebuff_icon.alpha = 0
	screen += tdebuff_icon
	tdebuff_num = new
	tdebuff_num.layer = MCARD_LAYER + 0.61
	tdebuff_num.alpha = 0
	screen += tdebuff_num

client/proc/ResetTargetCard()
	for(var/atom/movable/o in list(tcard, tcardtext, tcardstatus, tbar_hp_track, tbar_hp_fill, tbar_hp_text, tbar_en_track, tbar_en_fill, tbar_en_text, tbar_gd_track, tbar_gd_fill, tdebuff_icon, tdebuff_num))
		if(o)
			screen -= o
			del o
	tcard = null
	tcardtext = null
	tcardstatus = null
	tbar_hp_track = null
	tbar_hp_fill = null
	tbar_hp_text = null
	tbar_en_track = null
	tbar_en_fill = null
	tbar_en_text = null
	tbar_gd_track = null
	tbar_gd_fill = null
	tdebuff_icon = null
	tdebuff_num = null
	tcard_last = null
	tcard_hp_last = 0
	tcard_en_last = 0
	tcard_gd_last = 0

client/proc/BuildTargetComposite(mob/T)
	if(!tcard || !T) return
	var/icon/composite = icon('HUD/card_base.png')
	var/icon/p = icon(T.GetPortrait())
	p.Blend(icon('HUD/portrait_mask.png'), ICON_MULTIPLY)               // clip to the frame opening
	composite.Blend(p, ICON_OVERLAY, 22, 40)                            // same placement as the left card
	composite.Blend(icon('HUD/portrait_frame.png'), ICON_OVERLAY, 9, 27)
	composite.Flip(EAST)
	tcard.icon = composite

client/proc/PositionTargetCard()
	if(!tcard) return
	var/list/v = splittext("[view]", "x")
	if(v.len < 2) return
	var/tw = text2num(v[1])
	var/th = text2num(v[2])
	if(!tw || !th) return
	var/row = max(th - (MCARD_TILES_TALL - 1), 1)
	var/leftpx = tw * 32 - MCARD_MARGIN_X - MCARD_W   // left edge so the right edge sits MARGIN_X from the view right
	tcard_basetile = (leftpx - leftpx % 32) / 32 + 1
	tcard_basepix = leftpx % 32
	tcard_row = row
	var/sl = "[tcard_basetile]:[tcard_basepix],[row]:-[MCARD_MARGIN_Y]"
	tcard.screen_loc = sl
	if(tcardtext) tcardtext.screen_loc = sl
	if(tcardstatus) tcardstatus.screen_loc = sl
	PlaceTargetBars()

client/proc/TargetChildLoc(bx, by)
	return "[tcard_basetile]:[tcard_basepix + bx],[tcard_row]:[by - MCARD_MARGIN_Y]"

client/proc/PlaceTargetBars()
	if(!tbar_hp_track) return
	tbar_hp_track.screen_loc = TargetChildLoc(TBAR_X, TBAR_HP_Y)
	tbar_en_track.screen_loc = TargetChildLoc(TBAR_X, TBAR_EN_Y)
	tbar_hp_fill.screen_loc  = TargetChildLoc(TBAR_X + TBAR_FILL_INSET, TBAR_HP_Y + TBAR_FILL_INSET)
	tbar_en_fill.screen_loc  = TargetChildLoc(TBAR_X + TBAR_FILL_INSET, TBAR_EN_Y + TBAR_FILL_INSET)
	tbar_hp_text.screen_loc  = TargetChildLoc(TBAR_X, TBAR_HP_Y)
	tbar_en_text.screen_loc  = TargetChildLoc(TBAR_X, TBAR_EN_Y)
	if(tbar_gd_track)
		tbar_gd_track.screen_loc = TargetChildLoc(TBAR_X, TBAR_GD_Y)
		tbar_gd_fill.screen_loc  = TargetChildLoc(TBAR_X + TBAR_FILL_INSET, TBAR_GD_Y + TBAR_FILL_INSET)
	if(tdebuff_icon) tdebuff_icon.screen_loc = TargetChildLoc(TDBUFF_X, TDBUFF_Y)
	if(tdebuff_num)  tdebuff_num.screen_loc  = TargetChildLoc(TDBUFF_X, TDBUFF_Y)

client/proc/SetTargetCardAlpha(a)
	for(var/atom/movable/o in list(tcard, tcardtext, tcardstatus, tbar_hp_track, tbar_hp_fill, tbar_hp_text, tbar_en_track, tbar_en_fill, tbar_en_text, tdebuff_icon, tdebuff_num))
		if(o) o.alpha = a
	if(!a)
		if(tbar_gd_track) tbar_gd_track.alpha = 0
		if(tbar_gd_fill) tbar_gd_fill.alpha = 0

client/proc/UpdateTargetBars(hp, en, snap, gd = 0)
	if(!tbar_hp_fill || !tbar_en_fill) return
	var/iconToUse = 'HUD/tbar_fill_hp.png'
	var/mob/T = mob.Target
	var/fakeHP = T.passive_handler.Get("Health Obfuscation")
	var/valid = (T && T != mob && (isplayer(T) || istype(T, /mob/Player)))
	if(valid)
		if(fakeHP) // Used for "Heatlh Obfuscation" passive to make your HP bar seemingly infinite
			iconToUse = 'HUD/tbar_infinite.gif'
		else
			iconToUse = 'HUD/tbar_fill_hp.png'
	tbar_hp_fill.icon = iconToUse
	var/hpx = round(TBAR_FILL_W * hp / 100) - TBAR_FILL_W
	var/enx = round(TBAR_FILL_W * en / 100) - TBAR_FILL_W
	var/gdx = round(TBAR_FILL_W * gd / 100) - TBAR_FILL_W
	if(snap)
		if(fakeHP)
			tbar_hp_fill.filters = filter(type="alpha", icon='HUD/tbar_mask.png', x=0)
		else
			tbar_hp_fill.filters = filter(type="alpha", icon='HUD/tbar_mask.png', x=hpx)
		tbar_en_fill.filters = filter(type="alpha", icon='HUD/tbar_mask.png', x=enx)
		if(tbar_gd_fill) tbar_gd_fill.filters = filter(type="alpha", icon='HUD/tbar_mask.png', x=gdx)
	else
		var/tt = OrbAnimTime(tcard_hp_last, hp)
		if(fakeHP)
			if(tt) animate(tbar_hp_fill.filters[1], x = 0, time = tt, easing = SINE_EASING)
		else
			if(tt) animate(tbar_hp_fill.filters[1], x = hpx, time = tt, easing = SINE_EASING)
		var/te = OrbAnimTime(tcard_en_last, en)
		if(te) animate(tbar_en_fill.filters[1], x = enx, time = te, easing = SINE_EASING)
		if(tbar_gd_fill)
			var/tg = OrbAnimTime(tcard_gd_last, gd)
			if(tg) animate(tbar_gd_fill.filters[1], x = gdx, time = tg, easing = SINE_EASING)
	if(valid)
		if(fakeHP)
			tbar_hp_text.maptext = "<center><span style=\"[TBAR_FONT]; color:#ffffff\">???%</span></center>"
		else
			tbar_hp_text.maptext = "<center><span style=\"[TBAR_FONT]; color:#ffffff\">[hp]%</span></center>"
	tcard_hp_last = hp
	tcard_en_last = en
	tcard_gd_last = gd
	tbar_en_text.maptext = "<center><span style=\"[TBAR_FONT]; color:#ffffff\">[en]%</span></center>"

client/proc/UpdateTargetCard()
	if(!tcard || !mob) return
	var/mob/T = mob.Target
	var/valid = (T && T != mob && (isplayer(T) || istype(T, /mob/Player)))
	if(!valid)
		SetTargetCardAlpha(0)
		tcard_last = null
		return
	SetTargetCardAlpha(255)
	var/newtarget = (T != tcard_last) // composite and bar snap only happen on a target swap
	if(newtarget)
		BuildTargetComposite(T)
		tcard_last = T
	PositionTargetCard()
	var/nm = T.name
	if(length(nm) > 24)
		nm = copytext(nm, 1, 22) + "..."
	tcardtext.maptext = "<center><span style=\"[MCARD_FONT]; color:#ffffff\">[nm]</span></center>"
	var/showinj = !(T.HasFakePeace() || (T.WoundIntent == 0 && !T.SwordWounds() && !T.CursedWounds() && !(mob.IsEvil() && T.HasPurity())))
	var/showltl = !(T.HasFakePeace() || (T.Lethal == 0 && !T.CursedWounds() && !(mob.IsEvil() && T.HasPurity())))
	var/intent = showltl ? "<span style=\"color:#ff5050\">LTL</span>&nbsp;&nbsp;" : (showinj ? "<span style=\"color:#ff5050\">INJ</span>&nbsp;&nbsp;" : "")
	var/rp = T.PureRPMode ? "<span style=\"color:#55ee55\">RP</span>&nbsp;&nbsp;" : ""
	tcardstatus.maptext = "<center><span style=\"[MCARD_FONT]; color:#bfefff\">[intent][rp][get_dist(mob, T)] Tiles</span></center>"
	var/hp = min(max(round(T.HealthPct(), 0.01), 0), 100)
	var/en = T.EnergyMax ? min(max(round((T.Energy / T.EnergyMax) * 100, 0.01), 0), 100) : 0
	var/gd = 0
	gd = min(max(round((T.GuardMeter / max(glob.GUARD_METER_MAX, 1)) * 100, 0.01), 0), 100)
	var/showgd = (T.Guarding || T.GuardMeter > 0)
	if(tbar_gd_track) tbar_gd_track.alpha = showgd ? 255 : 0
	if(tbar_gd_fill) tbar_gd_fill.alpha = showgd ? 255 : 0
	UpdateTargetBars(hp, en, newtarget, gd)
	UpdateTargetDebuff(T)

client/proc/UpdateTargetDebuff(mob/T)
	if(!tdebuff_icon || !tdebuff_num) return
	var/passive/ph = mob.passive_handler
	var/dicon = null
	var/dcount = null
	if(ph && ph.Get("EruptingBlows") && T.Burn > 0)
		dicon = 'HUD/debuff_burn.png'
		dcount = "[round(T.Burn)]"
	else if(ph && ph.Get("SilentPoison") && T.Poison > 0)
		dicon = 'HUD/debuff_poison.png'
		dcount = "[round(T.Poison)]"
	if(dicon)
		tdebuff_icon.icon = dicon
		tdebuff_icon.alpha = 255
		tdebuff_num.alpha = 255
		tdebuff_num.maptext = "<span style=\"[TBAR_FONT]; color:#ffffff\">[dcount]</span>"
	else
		tdebuff_icon.alpha = 0
		tdebuff_num.alpha = 0

client/proc/PositionCharacterCard()
	if(!card) return
	var/list/v = splittext("[view]", "x")
	if(v.len < 2) return
	var/th = text2num(v[2])
	if(!th) return
	var/row = max(th - (MCARD_TILES_TALL - 1), 1) // bottom row of the card
	var/sl = "1:[MCARD_MARGIN_X],[row]:-[MCARD_MARGIN_Y]"
	card.screen_loc = sl
	if(cardtext) cardtext.screen_loc = sl
	if(cardstatus) cardstatus.screen_loc = sl
	PlaceIntentChips() // re-place on resize
	UpdateDebuffs() // re-place on resize
	UpdateTimedBuffs() // re-place on resize
	PositionFinisherBar() // re-place on resize
	PositionGuardBar() // re-place on resize

client/proc/ResetCharacterCard()
	ResetFinisherBar()
	ResetGuardBar()
	if(card)
		screen -= card
		del card
	card = null
	if(cardtext)
		screen -= cardtext
		del cardtext
	cardtext = null
	if(cardstatus)
		screen -= cardstatus
		del cardstatus
	cardstatus = null
	if(debuff_icons)
		for(var/atom/movable/o in debuff_icons)
			screen -= o
			del o
		debuff_icons = null
	if(tbuff_icons)
		for(var/atom/movable/o in tbuff_icons)
			screen -= o
			del o
		tbuff_icons = null
	ResetIntentChips()
	HideDebuffPanel()
	ResetTargetCard()
	ResetPartyHUD()

client/proc/UpdateCharacterCard()
	if(!card || !mob) return
	var/icon/composite = icon('HUD/card_base.png')
	var/icon/p = icon(mob.GetPortrait())
	p.Blend(icon('HUD/portrait_mask.png'), ICON_MULTIPLY)               // clip to the frame opening
	composite.Blend(p, ICON_OVERLAY, 22, 40)
	composite.Blend(icon('HUD/portrait_frame.png'), ICON_OVERLAY, 9, 27)
	card.icon = composite

client/proc/UpdateCardText()
	if(!cardtext || !cardstatus || !mob) return
	var/nm = mob.name
	if(length(nm) > 24)
		nm = copytext(nm, 1, 22) + "..." // fits the 24-char plate
	var/intent
	if(mob.Lethal >= 1)
		intent = "<span style=\"[MCARD_FONT]; color:#ff5050\">LTL</span>"
	else if(mob.WoundIntent >= 1)
		intent = "<span style=\"[MCARD_FONT]; color:#ff5050\">INJ</span>"
	else
		intent = "<span style=\"[MCARD_FONT]\">&nbsp;&nbsp;&nbsp;</span>"
	var/rp = (mob.PureRPMode == 1) ? "<span style=\"[MCARD_FONT]; color:#55ee55\">RP</span>" : ""
	cardtext.maptext = "<center><span style=\"[MCARD_FONT]; color:#ffffff\">[nm]</span></center>"
	cardstatus.maptext = "<span style=\"[MCARD_FONT]; color:#bfefff\">PWR [mob.GetCardPower()]%</span>&nbsp;&nbsp;&nbsp;[intent]&nbsp;&nbsp;&nbsp;[rp]"
	UpdateIntentChips()

client/proc/InitIntentChips()
	intent_chips = list()
	var/list/defs = list(list("injure", "Injure"), list("kill", "Kill"), list("rp", "RP"), list("count", "Count"))
	for(var/list/d in defs)
		var/atom/movable/shud/intentchip/c = new
		c.action = d[1]
		c.labeltext = d[2]
		c.lbl = new                       // cardtext type gives the outline and click-through
		c.lbl.layer = MCARD_LAYER + 0.56
		c.lbl.maptext_x = 0
		c.lbl.maptext_width = INTENT_CHIP_W
		c.lbl.maptext_height = INTENT_CHIP_H
		c.lbl.maptext_y = 4
		intent_chips += c
		screen += c
		screen += c.lbl

client/proc/ResetIntentChips()
	if(intent_chips)
		for(var/atom/movable/shud/intentchip/c in intent_chips)
			if(c.lbl)
				screen -= c.lbl
				del c.lbl
			screen -= c
			del c
		intent_chips = null

client/proc/PlaceIntentChips()
	if(!intent_chips) return
	var/list/v = splittext("[view]", "x")
	if(v.len < 2) return
	var/th = text2num(v[2])
	if(!th) return
	var/row = max(th - (MCARD_TILES_TALL - 1), 1)
	var/total = 4 * INTENT_CHIP_W + 3 * INTENT_CHIP_GAP
	var/start = MCARD_MARGIN_X + round((MCARD_W - total) / 2)
	var/ypix = -(MCARD_MARGIN_Y + INTENT_CHIP_BELOW + INTENT_CHIP_H)  // sit just below the card's bottom edge
	var/i = 0
	for(var/atom/movable/shud/intentchip/c in intent_chips)
		var/sl = "1:[start + i * (INTENT_CHIP_W + INTENT_CHIP_GAP)],[row]:[ypix]"
		c.screen_loc = sl
		if(c.lbl) c.lbl.screen_loc = sl
		i++

client/proc/UpdateIntentChips()
	if(!intent_chips || !mob) return
	for(var/atom/movable/shud/intentchip/c in intent_chips)
		var/col = "#8be9ff"
		switch(c.action)
			if("injure") col = (mob.WoundIntent >= 1) ? "#ff5050" : "#7f8c9a"
			if("kill")   col = (mob.Lethal >= 1) ? "#ff5050" : "#7f8c9a"
			if("rp")     col = (mob.PureRPMode == 1) ? "#55ee55" : "#7f8c9a"
		if(c.lbl) c.lbl.maptext = "<center><span style=\"[INTENT_FONT]; color:[col]\">[c.labeltext]</span></center>"

client/proc/IntentChipAction(action)
	if(!mob) return
	var/mob/Players/p = mob
	if(!istype(p)) return
	switch(action)
		if("injure") spawn() p.WoundIntent()
		if("kill")   spawn() p.LethalityToggle()
		if("rp")     spawn() p.ToggleRPMode()
		if("count")  spawn() p.Countdown()

/var/MDEBUFF_FONT_RESOURCE = 'HUD/PixelOperator8.ttf'
#define MDEBUFF_FONT "font-family:'Pixel Operator 8'; font-size:6pt"
#define MDEBUFF_ICON 16
#define MDEBUFF_GAP 4
#define MDEBUFF_NUM_W 16   // reserved width for a stack count
#define MDEBUFF_START_X 76 // first row starts under the nameplate's left edge
#define MDEBUFF_ROW2_X 19  // rows below the first start near the portrait's left edge
#define MDEBUFF_END_X 254  // wrap before here, fits 5 icons on the top row
#define MDEBUFF_ROW0_Y 27
#define MDEBUFF_ROW1_Y 10  // 1px under row 1 so it never clips
#define MDEBUFF_ROW_H 19   // vertical pitch for rows below the second

/atom/movable/shud/debuffnum
	mouse_opacity = 0
	maptext_width = 28
	maptext_height = 16
	pixel_x = 17 // sits just right of the 16px icon
	pixel_y = 1
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

/atom/movable/shud/debufficon
	mouse_opacity = 1 // right-clickable for the info panel
	layer = MCARD_LAYER + 0.6
	var/debuff_name
	var/debuff_desc
	var/atom/movable/shud/debuffnum/num
	New()
		..()
		num = new
		num.layer = MCARD_LAYER + 0.61
		vis_contents += num
	Del()
		if(num)
			vis_contents -= num
			del num
		..()
	Click(location, control, params)
		if(!usr) return
		if(params && findtext(params, "right=1"))
			if(usr.client && usr.client.debuff_panel_name == debuff_name)
				usr.client.HideDebuffPanel()
			else if(usr.client)
				usr.client.ShowDebuffPanel(src)

// timed-buff strip
#define TBUFF_ICON 32
#define TBUFF_GAP 4
#define TBUFF_PER_ROW 4
#define TBUFF_BELOW_INTENT 4   // gap between the intent chip row's bottom and the first buff row
#define TBUFF_NUM_FONT "font-family:'Pixel Operator 8'; font-size:6pt"

/atom/movable/shud/tbuffnum
	mouse_opacity = 0           // clicks fall through to the icon
	maptext_width = 30
	maptext_height = 9
	maptext_x = 1
	maptext_y = 1               // bottom-right corner of the 32px icon
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

/atom/movable/shud/tbufficon
	mouse_opacity = 1           // right-clickable for the reused buff info panel
	layer = MCARD_LAYER + 0.6
	var/obj/Skills/Buffs/buff
	var/atom/movable/shud/tbuffnum/num
	New()
		..()
		num = new
		num.layer = MCARD_LAYER + 0.62
		vis_contents += num
	Del()
		if(num)
			vis_contents -= num
			del num
		..()
	Click(location, control, params)
		if(!usr || !usr.client || !buff) return
		if(params && findtext(params, "right=1"))
			if(usr.client.skinfo_skill == buff)
				usr.client.CloseSkillInfo()
			else
				usr.client.ShowBuffInfo(buff)   // same boosts + passives panel as the skill menu

mob/proc/GetTimedBuffs()
	var/list/out = list()
	for(var/obj/Skills/Buffs/b in GetMenuBuffs())
		if(IsStripBuff(b)) out += b              // timed, non-debuff, currently active
	return out

client/proc/UpdateTimedBuffs()
	if(!tbuff_icons) tbuff_icons = list()
	var/list/active = (mob && card) ? mob.GetTimedBuffs() : list()
	var/list/v = splittext("[view]", "x")
	var/th = (v.len >= 2) ? (text2num(v[2]) || 20) : 20
	var/row = max(th - (MCARD_TILES_TALL - 1), 1)            // card's bottom tile, same anchor as the intent chips
	var/intent_total = 4 * INTENT_CHIP_W + 3 * INTENT_CHIP_GAP
	var/start_x = MCARD_MARGIN_X + round((MCARD_W - intent_total) / 2)
	var/ypix0 = -(MCARD_MARGIN_Y + INTENT_CHIP_BELOW + INTENT_CHIP_H) - TBUFF_BELOW_INTENT - TBUFF_ICON
	var/col = 0
	var/rw = 0
	var/i = 0
	for(var/obj/Skills/Buffs/b in active)
		i++
		var/atom/movable/shud/tbufficon/di
		if(i <= tbuff_icons.len)
			di = tbuff_icons[i]
		else
			di = new
			tbuff_icons += di
			screen += di
		if(di.buff != b)                                     // only rebuild the scaled icon when the slot changes
			var/icon/I = icon(SkillMenuIcon(b), SkillMenuIconState(b))
			I.Scale(TBUFF_ICON, TBUFF_ICON)
			di.icon = I
			di.buff = b
		var/x = start_x + col * (TBUFF_ICON + TBUFF_GAP)
		var/y = ypix0 - rw * (TBUFF_ICON + TBUFF_GAP)
		di.screen_loc = "1:[x],[row]:[y]"
		di.alpha = 255
		var/rem = b.TimerLimit - b.Timer                     // Timer advances 1.0/sec
		var/secs = round(rem)
		if(secs < rem) secs++                                // ceil so it reads as time remaining
		if(secs < 0) secs = 0
		di.num.maptext = "<span style=\"[TBUFF_NUM_FONT]; color:#ffffff; text-align:right\">[secs]</span>"
		di.num.alpha = (di.num.alpha == 255) ? 254 : 255     // nudge to force a maptext flush each tick
		col++
		if(col >= TBUFF_PER_ROW)
			col = 0
			rw++
	for(var/j = active.len + 1 to tbuff_icons.len)           // hide pooled icons from a larger prior set
		var/atom/movable/shud/tbufficon/spare = tbuff_icons[j]
		spare.alpha = 0
		spare.buff = null
		spare.num.maptext = ""
		spare.screen_loc = null
	RepositionPartyCards()   // ally cards ride below the buff cluster, whose height just changed

client/proc/GetActiveDebuffs()
	var/list/out = list()
	if(!mob) return out
	var/mob/m = mob
	if(m.Bleed > 0) out += list(list('HUD/debuff_bleed.png', "Bleed", "[round(m.Bleed)]"))
	var/vb = max(0, m.Burn - m.SilentBurnAmount)
	if(vb > 0) out += list(list('HUD/debuff_burn.png', "Burn", "[round(vb)]"))
	var/vp = max(0, m.Poison - m.SilentPoisonAmount)
	if(vp > 0) out += list(list('HUD/debuff_poison.png', "Poison", "[round(vp)]"))
	if(m.Shatter > 0) out += list(list('HUD/debuff_shatter.png', "Shatter", "[round(m.Shatter)]"))
	if(m.Shock > 0) out += list(list('HUD/debuff_shock.png', "Shock", "[round(m.Shock)]"))
	if(m.Slow > 0) out += list(list('HUD/debuff_chill.png', "Chill", "[round(m.Slow)]"))
	if(m.Crippled > 0) out += list(list('HUD/debuff_cripple.png', "Cripple", "[round(m.Crippled)]"))
	if(m.Doomed > 0) out += list(list('HUD/debuff_doom.png', "Doom", "[round(m.Doomed)]"))
	if(m.DownToEarth > 0) out += list(list('HUD/debuff_downtoearth.png', "Down to Earth", "[round(m.DownToEarth)]"))
	if(m.Frenzy > 0) out += list(list('HUD/debuff_frenzy.png', "Frenzy", "[round(m.Frenzy)]"))
	if(m.Confused > 0) out += list(list('HUD/debuff_confuse.png', "Confuse", "[round(m.Confused)]"))
	if(m.Sheared > 0 && !(m.Frenzy > 0 && !m.IsDarkDragonPlayer())) out += list(list('HUD/debuff_sheared.png', "Sheared", "[round(m.Sheared)]"))
	if(m.Oxygen != 100) out += list(list('HUD/debuff_oxygen.png', "Oxygen", "[round(m.Oxygen)]"))
	if(m.Stunned) out += list(list('HUD/debuff_stun.png', "Stun", null))
	if(m.passive_handler && m.passive_handler.Get("Disarmed")) out += list(list('HUD/debuff_disarm.png', "Disarm", null))
	if(m.Stasis > 0) out += list(list('HUD/debuff_stasis.png', "Stasis", null))
	if(m.passive_handler && m.passive_handler.Get("Silenced")) out += list(list('HUD/debuff_silence.png', "Silence", null))
	if(m.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Charmed)) out += list(list('HUD/debuff_charmed.png', "Charmed", null))
	if(m.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Blinded)) out += list(list('HUD/debuff_blind.png', "Blind", null))
	if(m.CheckSlotless("Tilted")) out += list(list('HUD/debuff_tilted.dmi', "Tilted", null))
	return out

client/proc/UpdateDebuffs()
	if(!debuff_icons) debuff_icons = list()
	var/list/active = (mob && card) ? GetActiveDebuffs() : list()
	var/th = 20
	var/list/v = splittext("[view]", "x")
	if(v.len >= 2) th = text2num(v[2]) || 20
	var/row = max(th - (MCARD_TILES_TALL - 1), 1)
	var/cur_row = 0
	var/start_x = MDEBUFF_START_X
	var/col_x = start_x
	var/i = 0
	for(var/list/d in active)
		i++
		var/numtxt = d[3]
		var/needed = MDEBUFF_ICON + (numtxt ? MDEBUFF_NUM_W : 0)
		if(col_x > start_x && col_x + needed > MDEBUFF_END_X) // wrap to the next row
			cur_row++
			start_x = MDEBUFF_ROW2_X
			col_x = start_x
		var/atom/movable/shud/debufficon/di
		if(i <= debuff_icons.len)
			di = debuff_icons[i]
		else
			di = new
			debuff_icons += di
			screen += di
		di.icon = d[1]
		di.debuff_name = d[2]
		di.num.maptext = numtxt ? "<span style=\"[MDEBUFF_FONT]; color:#ffffff\">[numtxt]</span>" : ""
		var/icy = (cur_row == 0) ? MDEBUFF_ROW0_Y : (MDEBUFF_ROW1_Y - (cur_row - 1) * MDEBUFF_ROW_H)
		di.screen_loc = "1:[MCARD_MARGIN_X + col_x],[row]:[icy - MCARD_MARGIN_Y]"
		di.alpha = 255
		col_x += needed + MDEBUFF_GAP
	// hide pooled icons left over from a larger debuff set
	for(var/j = active.len + 1 to debuff_icons.len)
		var/atom/movable/shud/debufficon/spare = debuff_icons[j]
		spare.alpha = 0
		spare.num.maptext = ""
		spare.screen_loc = null

#define MDEBUFF_LINE_H 16    // px per wrapped description line
#define MDEBUFF_PANEL_GAP 4  // px gap between the card's bottom and the panel's top

/atom/movable/shud/dppart
	mouse_opacity = 0
	layer = MCARD_LAYER + 1.1
/atom/movable/shud/dptext
	parent_type = /atom/movable/shud/dppart
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")
/atom/movable/shud/debuffpanel
	mouse_opacity = 2 // right-click anywhere on the panel closes it
	layer = MCARD_LAYER + 1.0
	Click(location, control, params)
		if(params && findtext(params, "right=1"))
			if(usr && usr.client)
				usr.client.HideDebuffPanel()

client/proc/GetDebuffDesc(name)
	switch(name)
		if("Bleed") return "Deals damage over time, increases injury with each step taken."
		if("Burn") return "Deals damage over time."
		if("Poison") return "Deals damage over time."
		if("Shatter") return "Lowers endurance in proportion with stack amount."
		if("Shock") return "Lowers offense and defense in proportion with stack amount."
		if("Chill") return "Lowers speed in proportion with stack amount."
		if("Cripple") return "Reduces movement speed."
		if("Doom") return "Halves Vaizard Health, quarters mana, and reduces God Ki at max stacks."
		if("Down to Earth") return "Immune to Doom until this debuff expires."
		if("Frenzy") return "Deals damage over time, applies Shearing, only cleared by attacking. On Dark Dragons, increases STR/OFF/SPD."
		if("Confuse") return "Chance to move in a random direction on movement."
		if("Sheared") return "Reduces incoming healing."
		if("Oxygen") return "Lose energy and fatigue below 10 oxygen, KO at 0."
		if("Stun") return "Unable to act, can be cleansed with After Image Strike."
		if("Disarm") return "Skills that require weapons deal reduced damage."
		if("Charmed") return "Slowly move towards the charmer, unable to control movement. You can still attack."
		if("Tilted") return "Lowers endurance and offense, slightly increases attack."
		if("Stasis") return "Unable to act, immune to most other statuses and damage."
		if("Silence") return "Cannot use any skills."
		if("Blind") return "Reduced Flow, Instinct, FluidForm, and Defense stat."
	return ""

client/proc/HideDebuffPanel()
	debuff_panel_name = null
	if(debuff_panel_objs)
		while(debuff_panel_objs.len)
			var/atom/movable/o = debuff_panel_objs[debuff_panel_objs.len]
			debuff_panel_objs.len--
			screen -= o
			del o
		debuff_panel_objs = null

client/proc/GetDebuffLines(name)
	switch(name)
		if("Burn", "Poison", "Cripple", "Sheared", "Silence") return 1
		if("Doom", "Charmed") return 3
		if("Frenzy") return 4
	return 2

client/proc/ShowDebuffPanel(atom/movable/shud/debufficon/di)
	HideDebuffPanel()
	if(!di || !card || !mob) return
	var/list/v = splittext("[view]", "x")
	if(v.len < 2) return
	var/th = text2num(v[2])
	if(!th) return
	var/lines = GetDebuffLines(di.debuff_name)
	var/content = lines * MDEBUFF_LINE_H
	var/ph = content + 36                            // panel height: 8 + 16 name + 4 gap + content + 8
	var/toprow = content + 12                        // panel-local y from the bottom of the symbol/name row
	var/ptop = MCARD_TILES_TALL * 32 + MCARD_MARGIN_Y + MDEBUFF_PANEL_GAP // panel top, px below the view top
	var/pbot = ptop + ph
	var/ptiles = round(pbot / 32)
	if(ptiles * 32 < pbot) ptiles++                                       // ceil to whole tiles
	var/prow = max(th - ptiles + 1, 1)
	var/poff = (th - prow + 1) * 32 - pbot                                // slide up so the panel bottom lands at pbot
	debuff_panel_objs = list()
	debuff_panel_name = di.debuff_name
	var/icon/bg
	switch(lines)
		if(1) bg = 'HUD/debuff_panel_1.png'
		if(2) bg = 'HUD/debuff_panel_2.png'
		if(3) bg = 'HUD/debuff_panel_3.png'
		else  bg = 'HUD/debuff_panel_4.png'
	var/atom/movable/shud/debuffpanel/P = new
	P.icon = bg
	P.screen_loc = "1:[MCARD_MARGIN_X],[prow]:[poff]"
	debuff_panel_objs += P
	var/atom/movable/shud/dppart/S = new
	S.icon = di.icon
	S.screen_loc = "1:[MCARD_MARGIN_X + 12],[prow]:[poff + toprow]"
	debuff_panel_objs += S
	var/atom/movable/shud/dptext/N = new
	N.maptext_width = 195
	N.maptext_height = 16
	N.maptext_x = 33
	N.maptext_y = toprow
	N.screen_loc = P.screen_loc
	N.maptext = "<span style=\"[MCARD_FONT]; color:#ffffff\">[di.debuff_name]</span>"
	debuff_panel_objs += N
	var/atom/movable/shud/dptext/D = new
	D.maptext_width = 216
	D.maptext_height = content
	D.maptext_x = 12
	D.maptext_y = 8
	D.screen_loc = P.screen_loc
	D.maptext = "<span style=\"[MCARD_FONT]; color:#ffffff\">[GetDebuffDesc(di.debuff_name)]</span>"
	debuff_panel_objs += D
	for(var/atom/movable/o in debuff_panel_objs)
		screen += o
	KineticEntrance(debuff_panel_objs)

// New Tension bar
// centered above the skill hotbar (slots sit at SOUTH:30..62, CENTER-anchored)
#define FIN_CX -112           // bar is 224 wide: CENTER:-112 centers it
#define FIN_SOUTH 76          // bar bottom: 14px above the hotbar slot tops
#define FIN_MINI_SOUTH 78     // minis: 12px below the bar top (bar spans 76..96)
#define FIN_FILL_X 34         // fill sweep starts here inside the fill icon
#define FIN_TRACKW 224
#define FIN_SPAN 190
#define FIN_GLOW_COLOR "#b48cff"
#define FIN_EDGE_COLOR "#5d4f96"
#define FIN_MINI_X1 92        // left mini slot (stage 2), px from the bar's left edge
#define FIN_MINI_X2 152       // right mini slot (stage 3)
#define FIN_MINI_W1 64
#define FIN_MINI_W2 62
#define FIN_MINIMASK_W 64

var/FIN_TRACK_RSC = 'HUD/fin_track.png'
var/FIN_FILL_RSC = 'HUD/fin_fill.png'
var/FIN_MASK_RSC = 'HUD/fin_mask.png'
var/FIN_MINIMASK = 'HUD/fin_minimask.png'
var/FIN_MINIFILL1 = 'HUD/fin_minifill1.png'
var/FIN_MINIFILL2 = 'HUD/fin_minifill2.png'

client
	var/tmp
		atom/movable/shud/fin_track
		atom/movable/shud/fin_fill
		list/fin_minis            // per-slot fill overlays
		fin_mini_count = -1
		fin_main_last = 0
		list/fin_mini_last
		fin_shown = 0
		fin_glowing = FALSE

client/proc/InitFinisherBar()
	ResetFinisherBar()
	fin_track = new /atom/movable/shud/orbpart
	fin_track.icon = FIN_TRACK_RSC
	fin_track.layer = MCARD_LAYER
	fin_track.filters = filter(type="outline", size=1, color=FIN_EDGE_COLOR)   // edge flair so the empty bar reads
	screen += fin_track
	fin_fill = new /atom/movable/shud/orbpart
	fin_fill.icon = FIN_FILL_RSC
	fin_fill.layer = MCARD_LAYER + 0.01
	fin_fill.filters = filter(type="alpha", icon=FIN_MASK_RSC, x=-FIN_TRACKW)   // start empty
	screen += fin_fill
	fin_minis = list()
	fin_mini_last = list()
	fin_mini_count = -1
	fin_main_last = 0
	HideFinisherBar()

client/proc/ResetFinisherBar()
	for(var/atom/movable/o in list(fin_track, fin_fill))
		if(o)
			screen -= o
			del o
	fin_track = null
	fin_fill = null
	if(fin_minis)
		while(fin_minis.len)
			var/atom/movable/o = fin_minis[fin_minis.len]
			fin_minis.len--
			screen -= o
			del o
	fin_minis = null
	fin_mini_last = null
	fin_mini_count = -1
	fin_shown = 0
	fin_glowing = FALSE

client/proc/HideFinisherBar()
	fin_shown = 0
	SetFinisherGlow(FALSE)
	if(fin_track) fin_track.alpha = 0
	if(fin_fill) fin_fill.alpha = 0
	if(fin_minis)
		for(var/atom/movable/o in fin_minis)
			o.alpha = 0

// pulsing ready-glow around the whole bar silhouette
client/proc/SetFinisherGlow(on)
	if(fin_glowing == on) return
	fin_glowing = on
	if(!fin_track) return
	if(on)
		fin_track.filters += filter(type="drop_shadow", x=0, y=0, size=2, offset=1, color=FIN_GLOW_COLOR)
		spawn(1)   // same-tick filter animation snaps instead of animating
			if(fin_glowing && fin_track && fin_track.filters && fin_track.filters.len >= 2)
				animate(fin_track.filters[2], size = 6, time = 9, loop = -1, easing = SINE_EASING)
				animate(size = 2, time = 9, easing = SINE_EASING)
	else
		fin_track.filters = filter(type="outline", size=1, color=FIN_EDGE_COLOR)

client/proc/RebuildFinisherMinis(count)
	fin_mini_count = count
	if(fin_minis)
		while(fin_minis.len)
			var/atom/movable/o = fin_minis[fin_minis.len]
			fin_minis.len--
			screen -= o
			del o
	fin_minis = list()
	fin_mini_last = list()
	for(var/i = 1 to count)
		var/atom/movable/shud/orbpart/m = new
		m.icon = (i == 1) ? FIN_MINIFILL1 : FIN_MINIFILL2
		m.layer = MCARD_LAYER + 0.02
		m.filters = filter(type="alpha", icon=FIN_MINIMASK, x=-FIN_MINIMASK_W)   // start empty
		m.alpha = fin_shown ? 255 : 0
		screen += m
		fin_minis += m
		fin_mini_last += 0
	PositionFinisherBar()

client/proc/PositionFinisherBar()
	if(!fin_track) return
	var/sl = "CENTER:[FIN_CX],SOUTH:[FIN_SOUTH]"
	fin_track.screen_loc = sl
	fin_fill.screen_loc = sl
	if(fin_minis)
		for(var/i = 1 to fin_minis.len)
			var/atom/movable/o = fin_minis[i]
			o.screen_loc = "CENTER:[FIN_CX + ((i == 1) ? FIN_MINI_X1 : FIN_MINI_X2)],SOUTH:[FIN_MINI_SOUTH]"

client/proc/UpdateFinisherBar()
	if(!mob || !fin_track) return
	if(!mob.StyleActive || !mob.StyleBuff || !card)
		if(fin_shown) HideFinisherBar()
		return
	var/stage = 1
	if(mob.StyleBuff.FinisherStage > 1) stage = mob.StyleBuff.FinisherStage
	var/want = min(stage, 3) - 1          // visual mini slots; mechanics are unbounded
	if(fin_mini_count != want) RebuildFinisherMinis(want)
	if(!fin_shown)
		fin_shown = 1
		fin_track.alpha = 255
		fin_fill.alpha = 255
		for(var/atom/movable/o in fin_minis)
			o.alpha = 255
	var/barMax = mob.getMaxTensionValue()
	if(barMax < 1) barMax = 1
	var/t = mob.Tension

	var/frac = t / barMax
	if(frac > 1) frac = 1
	if(frac < 0) frac = 0
	var/px = frac ? FIN_FILL_X + round(FIN_SPAN * frac) : 0
	if(px != fin_main_last)
		var/tm = OrbAnimTime(fin_main_last, px)
		if(tm) animate(fin_fill.filters[1], x = px - FIN_TRACKW, time = tm, easing = SINE_EASING)
		else fin_fill.filters = filter(type="alpha", icon=FIN_MASK_RSC, x = px - FIN_TRACKW)
		fin_main_last = px

	for(var/i = 1 to fin_minis.len)
		var/atom/movable/shud/m = fin_minis[i]
		var/mf = (t - i * barMax) / barMax
		if(mf > 1) mf = 1
		if(mf < 0) mf = 0
		var/mpx = mf ? round(((i == 1) ? FIN_MINI_W1 : FIN_MINI_W2) * mf) : 0
		if(mpx != fin_mini_last[i])
			var/tm2 = OrbAnimTime(fin_mini_last[i], mpx)
			if(tm2) animate(m.filters[1], x = mpx - FIN_MINIMASK_W, time = tm2, easing = SINE_EASING)
			else m.filters = filter(type="alpha", icon=FIN_MINIMASK, x = mpx - FIN_MINIMASK_W)
			fin_mini_last[i] = mpx

	// states: locked = grey fill; finisher ready = pulsing glow around the bar
	if(mob.tempTensionLock)
		fin_fill.color = "#666666"
		SetFinisherGlow(FALSE)
	else if(t >= barMax)
		fin_fill.color = null
		SetFinisherGlow(TRUE)
	else
		fin_fill.color = null
		SetFinisherGlow(FALSE)

// guard meter, I plan to do something different for these visuals soon though
#define GUARD_BAR_SOUTH 98
#define GUARD_FILL_COLOR "#e8a33d"
#define GUARD_HOT_COLOR "#e05545"

client
	var/tmp
		atom/movable/shud/gd_track
		atom/movable/shud/gd_fill
		gd_main_last = 0
		gd_shown = 0

client/proc/InitGuardBar()
	ResetGuardBar()
	gd_track = new /atom/movable/shud/orbpart
	gd_track.icon = FIN_TRACK_RSC
	gd_track.layer = MCARD_LAYER
	gd_track.filters = filter(type="outline", size=1, color=FIN_EDGE_COLOR)
	screen += gd_track
	gd_fill = new /atom/movable/shud/orbpart
	gd_fill.icon = FIN_FILL_RSC
	gd_fill.layer = MCARD_LAYER + 0.01
	gd_fill.filters = filter(type="alpha", icon=FIN_MASK_RSC, x=-FIN_TRACKW)
	gd_fill.color = GUARD_FILL_COLOR
	screen += gd_fill
	gd_main_last = 0
	HideGuardBar()

client/proc/ResetGuardBar()
	for(var/atom/movable/o in list(gd_track, gd_fill))
		if(o)
			screen -= o
			del o
	gd_track = null
	gd_fill = null
	gd_shown = 0

client/proc/HideGuardBar()
	gd_shown = 0
	if(gd_track) gd_track.alpha = 0
	if(gd_fill) gd_fill.alpha = 0

client/proc/PositionGuardBar()
	if(!gd_track) return
	var/sl = "CENTER:[FIN_CX],SOUTH:[GUARD_BAR_SOUTH]"
	gd_track.screen_loc = sl
	gd_fill.screen_loc = sl

client/proc/UpdateGuardBar()
	if(!mob || !gd_track) return
	if(!mob.Guarding && mob.GuardMeter <= 0 && !mob.IsGuardBroken())
		if(gd_shown) HideGuardBar()
		return
	if(!gd_shown)
		gd_shown = 1
		gd_track.alpha = 255
		gd_fill.alpha = 255
		PositionGuardBar()
	var/frac = mob.GuardMeter / max(glob.GUARD_METER_MAX, 1)
	if(frac > 1) frac = 1
	if(frac < 0) frac = 0
	var/px = frac ? FIN_FILL_X + round(FIN_SPAN * frac) : 0
	if(px != gd_main_last)
		var/tm = OrbAnimTime(gd_main_last, px)
		if(tm) animate(gd_fill.filters[1], x = px - FIN_TRACKW, time = tm, easing = SINE_EASING)
		else gd_fill.filters = filter(type="alpha", icon=FIN_MASK_RSC, x = px - FIN_TRACKW)
		gd_main_last = px
	if(mob.IsGuardBroken())
		gd_fill.color = "#666666"
	else if(frac >= 0.8)
		gd_fill.color = GUARD_HOT_COLOR
	else
		gd_fill.color = GUARD_FILL_COLOR
