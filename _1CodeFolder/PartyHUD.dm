#define PCARD_W 240
#define PCARD_H 70
#define PCARD_GAP 4
#define PCARD_FONT "font-family:'monogram'; font-size:12pt"
#define PCARD_BAR_FONT "font-family:'Pixel Operator 8'; font-size:6pt"
#define PBAR_W 160          // tbar_track.png width (reused)
#define PBAR_FILL_W 158     // tbar_fill_*/tbar_mask width (reused)
#define PBAR_X 72           // card-local x of the bar's left edge (clears the 64px portrait frame)
#define PBAR_HP_Y 32        // card-local y (from bottom) of the HP bar
#define PBAR_EN_Y 16        // card-local y of the EN bar
#define PCARD_NAME_X 72
#define PCARD_NAME_Y 50
#define PCARD_NAME_W 150
#define PMANAGE_W 116       // promote/kick side panel width (party_manage.png)

/var/PARTY_STAR_RESOURCE = 'HUD/party_leader_star.png'

mob/var/tmp/Party/pending_party     
mob/var/tmp/pending_invite_id = 0    

// one ally's stacked card and its child screen objects
/datum/pcard
	var/mob/member
	var/atom/movable/shud/pcardbg/card
	var/atom/movable/shud/cardtext/nametext
	var/atom/movable/shud/star
	var/atom/movable/shud/hp_track
	var/atom/movable/shud/hp_fill
	var/atom/movable/shud/cardtext/hp_text
	var/atom/movable/shud/en_track
	var/atom/movable/shud/en_fill
	var/atom/movable/shud/cardtext/en_text
	var/hp_last = 0
	var/en_last = 0
	var/cur_cb = 0          // last card-bottom pixel offset, so the manage panel can ride alongside

/atom/movable/shud/pcardbg
	mouse_opacity = 1
	layer = MCARD_LAYER
	var/mob/member
	Click(location, control, params)
		if(!usr || !usr.client || !member) return
		if(params && findtext(params, "right=1"))
			usr.client.TogglePartyManage(member)   // leader-only promote/kick panel
		else
			usr.client.TargetPartyMember(member)   // left-click targets the ally

/atom/movable/shud/pmanagebg
	mouse_opacity = 2
	Click(location, control, params)
		if(params && findtext(params, "right=1"))
			if(usr && usr.client) usr.client.HidePartyManage()

/atom/movable/shud/pmanagebtn
	mouse_opacity = 2
	var/action
	var/mob/target
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")
	Click(location, control, params)
		if(!usr || !usr.client) return
		if(params && findtext(params, "right=1"))
			usr.client.HidePartyManage()           // right-click a row dismisses; never fires the action
			return
		usr.client.PartyManageAction(src.action, src.target)

/atom/movable/shud/partyinvitebg
	mouse_opacity = 2
	Click(location, control, params)
		if(params && findtext(params, "right=1"))
			if(usr && usr.client) usr.client.DeclinePartyInvite()   // right-click dismiss = No

/atom/movable/shud/partyinvitebtn
	mouse_opacity = 2
	var/action
	Click(location, control, params)
		if(usr && usr.client) usr.client.PartyInviteAction(src.action)

client
	var/tmp
		list/datum/pcard/party_cards
		atom/movable/shud/party_leader_badge        
		pcard_row = 1
		party_badge_shown = 0                        // tracks the badge fade so it only animates on transition
		// invite prompt
		list/party_invite_objs
		Party/party_invite_from
		// leader manage panel
		list/party_manage_objs
		mob/party_manage_target
		atom/movable/shud/pmanagebg/pmanage_bg
		atom/movable/shud/pmanagebtn/pmanage_promo
		atom/movable/shud/pmanagebtn/pmanage_kick

client/proc/InitPartyHUD()
	ResetPartyHUD()
	party_cards = list()
	party_leader_badge = new
	party_leader_badge.icon = 'HUD/party_leader_star.png'
	party_leader_badge.layer = MCARD_LAYER + 0.62
	party_leader_badge.mouse_opacity = 0
	party_leader_badge.alpha = 0
	screen += party_leader_badge
	RebuildPartyCards()

client/proc/ResetPartyHUD()
	HidePartyInvite()
	HidePartyManage()
	ClearPartyCards()
	if(party_leader_badge)
		screen -= party_leader_badge
		del party_leader_badge
		party_leader_badge = null

client/proc/FreePCard(datum/pcard/pc)
	if(!pc) return
	for(var/atom/movable/o in list(pc.card, pc.nametext, pc.star, pc.hp_track, pc.hp_fill, pc.hp_text, pc.en_track, pc.en_fill, pc.en_text))
		if(o)
			screen -= o
			del o
	pc.member = null

client/proc/ClearPartyCards()
	if(party_cards)
		for(var/datum/pcard/pc in party_cards)
			FreePCard(pc)
	party_cards = list()

client/proc/BuildPCardIcon(mob/m)
	var/icon/comp = icon('HUD/card_party.png')              // 240x70
	var/icon/p = icon(m.GetPortrait())
	p.Blend(icon('HUD/portrait_mask.png'), ICON_MULTIPLY)   // identical mask to the main/target cards
	comp.Blend(p, ICON_OVERLAY, 17, 16)                     // 38px portrait, +13,+13 inside the 64 frame
	comp.Blend(icon('HUD/portrait_frame.png'), ICON_OVERLAY, 4, 3)
	return comp

client/proc/NewPBar(ic, ly)
	var/atom/movable/shud/o = new
	o.icon = ic
	o.layer = ly
	o.mouse_opacity = 0          // clicks fall through to the card bg below
	screen += o
	return o

client/proc/NewPBarFill(ic, ly)
	var/atom/movable/shud/o = new
	o.icon = ic
	o.layer = ly
	o.mouse_opacity = 0
	o.filters = filter(type="alpha", icon='HUD/tbar_mask.png', x=-PBAR_FILL_W)   // start empty
	screen += o
	return o

client/proc/NewPBarText(ly)
	var/atom/movable/shud/cardtext/o = new
	o.layer = ly
	o.mouse_opacity = 0
	o.maptext_width = PBAR_W
	o.maptext_height = 16
	o.maptext_x = 0
	o.maptext_y = -3
	screen += o
	return o

client/proc/MakePCard(mob/m)
	var/datum/pcard/pc = new
	pc.member = m
	pc.card = new
	pc.card.member = m
	pc.card.icon = BuildPCardIcon(m)
	pc.card.layer = MCARD_LAYER
	screen += pc.card
	pc.nametext = new
	pc.nametext.layer = MCARD_LAYER + 0.5
	pc.nametext.mouse_opacity = 0
	pc.nametext.maptext_x = PCARD_NAME_X
	pc.nametext.maptext_y = PCARD_NAME_Y
	pc.nametext.maptext_width = PCARD_NAME_W
	pc.nametext.maptext_height = 16
	screen += pc.nametext
	pc.hp_track = NewPBar('HUD/tbar_track.png', MCARD_LAYER + 0.55)
	pc.hp_fill  = NewPBarFill('HUD/tbar_fill_hp.png', MCARD_LAYER + 0.56)
	pc.hp_text  = NewPBarText(MCARD_LAYER + 0.6)
	pc.en_track = NewPBar('HUD/tbar_track.png', MCARD_LAYER + 0.55)
	pc.en_fill  = NewPBarFill('HUD/tbar_fill_en.png', MCARD_LAYER + 0.56)
	pc.en_text  = NewPBarText(MCARD_LAYER + 0.6)
	if(mob && mob.party && mob.party.leader == m)
		pc.star = new
		pc.star.icon = 'HUD/party_leader_star.png'
		pc.star.layer = MCARD_LAYER + 0.62
		pc.star.mouse_opacity = 0
		screen += pc.star
	return pc

client/proc/RebuildPartyCards()
	if(!mob) return
	if(!party_cards) party_cards = list()
	HidePartyManage()                   // roster changed, drop any open manage panel
	ClearPartyCards()
	if(!mob.party || !card)             // no party (or the main card isn't up yet)
		UpdateLeaderBadge()
		return
	var/cap = MAX_PARTY_LIMIT - 1       
	for(var/mob/m in mob.party.members)
		if(m == mob) continue
		party_cards += MakePCard(m)
		if(party_cards.len >= cap) break
	UpdateLeaderBadge()
	RepositionPartyCards()
	UpdatePartyCards()

client/proc/PCardLoc(cb, bx, by)
	return "1:[MCARD_MARGIN_X + bx],[pcard_row]:[cb + by]"

client/proc/PlacePCard(datum/pcard/pc, cb)
	pc.cur_cb = cb
	pc.card.screen_loc     = PCardLoc(cb, 0, 0)
	pc.nametext.screen_loc = PCardLoc(cb, 0, 0)
	pc.hp_track.screen_loc = PCardLoc(cb, PBAR_X, PBAR_HP_Y)
	pc.en_track.screen_loc = PCardLoc(cb, PBAR_X, PBAR_EN_Y)
	pc.hp_fill.screen_loc  = PCardLoc(cb, PBAR_X + 1, PBAR_HP_Y + 1)
	pc.en_fill.screen_loc  = PCardLoc(cb, PBAR_X + 1, PBAR_EN_Y + 1)
	pc.hp_text.screen_loc  = PCardLoc(cb, PBAR_X, PBAR_HP_Y)
	pc.en_text.screen_loc  = PCardLoc(cb, PBAR_X, PBAR_EN_Y)
	if(pc.star)
		pc.star.screen_loc = PCardLoc(cb, PCARD_W - 24, PCARD_H - 18)

client/proc/RepositionPartyCards()
	if(!mob) return
	if(!party_cards || !party_cards.len)         
		UpdateLeaderBadge()
		return
	var/list/v = splittext("[view]", "x")
	if(v.len < 2) return
	var/th = text2num(v[2])
	if(!th) return
	pcard_row = max(th - (MCARD_TILES_TALL - 1), 1)         // same anchor row as the main card / intent / buffs
	var/cluster_bottom = -(MCARD_MARGIN_Y + INTENT_CHIP_BELOW + INTENT_CHIP_H)
	var/buffs = mob.GetTimedBuffs().len
	if(buffs)
		var/rows = round(buffs / TBUFF_PER_ROW)
		if(rows * TBUFF_PER_ROW < buffs) rows++             // ceil to whole rows
		cluster_bottom -= TBUFF_BELOW_INTENT + rows * TBUFF_ICON + (rows - 1) * TBUFF_GAP
	var/cb = cluster_bottom - PCARD_GAP - PCARD_H
	if(party_cards)
		for(var/datum/pcard/pc in party_cards)
			PlacePCard(pc, cb)
			cb -= (PCARD_H + PCARD_GAP)
	UpdateLeaderBadge()
	if(party_manage_target) PositionPartyManage()

client/proc/UpdateLeaderBadge()
	if(!party_leader_badge) return
	if(!(mob && mob.party && mob.party.leader == mob && card))
		party_leader_badge.alpha = 0
		party_badge_shown = 0                     // reset so the badge fades back in when you next lead
		return
	var/list/v = splittext("[view]", "x")
	if(v.len < 2) return
	var/th = text2num(v[2])
	if(!th) return
	var/row = max(th - (MCARD_TILES_TALL - 1), 1)
	party_leader_badge.screen_loc = "1:[MCARD_MARGIN_X + MCARD_W - 24],[row]:[-MCARD_MARGIN_Y + 76]"
	if(!party_badge_shown)                        // fade in once on becoming leader
		party_leader_badge.alpha = 0
		animate(party_leader_badge, alpha = 255, time = 3, easing = SINE_EASING)
		party_badge_shown = 1

client/proc/UpdatePartyCards()
	if(!party_cards || !party_cards.len) return
	for(var/datum/pcard/pc in party_cards)
		var/mob/m = pc.member
		if(!m) continue
		var/nm = m.name
		if(length(nm) > 18) nm = copytext(nm, 1, 17) + ".."
		pc.nametext.maptext = "<center><span style=\"[PCARD_FONT]; color:#ffffff\">[nm]</span></center>"
		var/hp = min(max(round(m.Health, 0.01), 0), 100)
		var/en = m.EnergyMax ? min(max(round((m.Energy / m.EnergyMax) * 100, 0.01), 0), 100) : 0
		UpdatePCardBars(pc, hp, en)

client/proc/UpdatePCardBars(datum/pcard/pc, hp, en)
	var/hpx = round(PBAR_FILL_W * hp / 100) - PBAR_FILL_W
	var/enx = round(PBAR_FILL_W * en / 100) - PBAR_FILL_W
	var/th = OrbAnimTime(pc.hp_last, hp)
	if(th) animate(pc.hp_fill.filters[1], x = hpx, time = th, easing = SINE_EASING)
	else pc.hp_fill.filters = filter(type="alpha", icon='HUD/tbar_mask.png', x=hpx)
	var/te = OrbAnimTime(pc.en_last, en)
	if(te) animate(pc.en_fill.filters[1], x = enx, time = te, easing = SINE_EASING)
	else pc.en_fill.filters = filter(type="alpha", icon='HUD/tbar_mask.png', x=enx)
	pc.hp_last = hp
	pc.en_last = en
	pc.hp_text.maptext = "<center><span style=\"[PCARD_BAR_FONT]; color:#ffffff\">[hp]%</span></center>"
	pc.en_text.maptext = "<center><span style=\"[PCARD_BAR_FONT]; color:#ffffff\">[en]%</span></center>"

client/proc/TargetPartyMember(mob/m)
	if(!mob || !m || m == mob) return
	mob.SetTarget(m)
	if(mob.Target != m)                          
		mob << "<font color=red>You can't target [m] right now.</font>"
		return
	mob << "<font color=green>Now targeting [m]!</font>"
	UpdateTargetCard()                           

client/proc/FindPCard(mob/m)
	if(!party_cards) return null
	for(var/datum/pcard/pc in party_cards)
		if(pc.member == m) return pc
	return null

client/proc/TogglePartyManage(mob/m)
	if(!mob || !mob.party) return
	if(mob.party.leader != mob) return        
	if(m == mob) return
	if(party_manage_target == m)
		HidePartyManage()
		return
	ShowPartyManage(m)

client/proc/MkManageRow(action, mob/m, label, color)
	var/atom/movable/shud/pmanagebtn/r = new
	r.action = action
	r.target = m
	r.layer = MHUD_LAYER + 0.2
	r.icon = PMRowIcon(108, 22)
	r.maptext_x = 0
	r.maptext_width = 108
	r.maptext_height = 16
	r.maptext_y = 3
	r.maptext = "<center><span style=\"[PCARD_FONT]; color:[color]\">[label]</span></center>"
	party_manage_objs += r
	screen += r
	return r

client/proc/PMRowIcon(w, h)
	var/icon/I = icon('BLANK.dmi')          // transparent click target sized to the row
	I.Scale(w, h)
	return I

client/proc/ShowPartyManage(mob/m)
	HidePartyManage()
	party_manage_target = m
	party_manage_objs = list()
	pmanage_bg = new
	pmanage_bg.icon = 'HUD/party_manage.png'
	pmanage_bg.layer = MHUD_LAYER
	party_manage_objs += pmanage_bg
	screen += pmanage_bg
	pmanage_promo = MkManageRow("promote", m, "Promote", "#bfefff")
	pmanage_kick  = MkManageRow("kick", m, "Kick", "#ff6464")
	PositionPartyManage()
	KineticEntrance(party_manage_objs)

client/proc/PositionPartyManage()
	if(!party_manage_target || !pmanage_bg) return
	var/datum/pcard/pc = FindPCard(party_manage_target)
	if(!pc)
		HidePartyManage()
		return
	var/list/v = splittext("[view]", "x")
	if(v.len < 2) return
	var/tw = text2num(v[1])
	if(!tw) return
	var/leftpx = MCARD_MARGIN_X + PCARD_W + 6    // just right of the ally card
	var/maxleft = tw * 32 - PMANAGE_W            
	if(leftpx > maxleft) leftpx = max(0, maxleft)
	var/ppix = leftpx % 32
	var/ptile = (leftpx - ppix) / 32 + 1
	var/cb = pc.cur_cb
	pmanage_bg.screen_loc = "[ptile]:[ppix],[pcard_row]:[cb + 1]"
	if(pmanage_promo) pmanage_promo.screen_loc = "[ptile]:[ppix + 4],[pcard_row]:[cb + 1 + 26]"
	if(pmanage_kick)  pmanage_kick.screen_loc  = "[ptile]:[ppix + 4],[pcard_row]:[cb + 1 + 4]"

client/proc/PartyManageAction(action, mob/m)
	if(!mob || !mob.party || mob.party.leader != mob)
		HidePartyManage()
		return
	if(!m || !(m in mob.party.members))
		HidePartyManage()
		return
	switch(action)
		if("promote")
			mob.party.pass_leader(mob, m)
		if("kick")
			mob.party.remove_member(m)
	HidePartyManage()

client/proc/HidePartyManage()
	party_manage_target = null
	pmanage_bg = null
	pmanage_promo = null
	pmanage_kick = null
	if(party_manage_objs)
		while(party_manage_objs.len)
			var/atom/movable/o = party_manage_objs[party_manage_objs.len]
			party_manage_objs.len--
			screen -= o
			del o
		party_manage_objs = null

client/proc/MkInviteBtn(action, label, color, px, py)
	var/atom/movable/shud/partyinvitebtn/b = new
	b.icon = 'HUD/pbtn.png'
	b.action = action
	b.layer = MHUD_LAYER + 1.2
	b.screen_loc = InviteLoc(px, py)
	party_invite_objs += b
	screen += b
	var/atom/movable/shud/cardtext/L = new
	L.layer = MHUD_LAYER + 1.3
	L.mouse_opacity = 0
	L.maptext_width = 80
	L.maptext_height = 24
	L.maptext_y = 4
	L.screen_loc = InviteLoc(px, py)
	L.maptext = "<center><span style=\"[PCARD_FONT]; color:[color]\">[label]</span></center>"
	party_invite_objs += L
	screen += L

client/var/tmp
	pinv_tile = 1
	pinv_pix = 0
	pinv_row = 1
	pinv_off = 0

client/proc/InviteLoc(px, py)
	return "[pinv_tile]:[pinv_pix + px],[pinv_row]:[pinv_off + py]"

client/proc/ShowPartyInvite(Party/p)
	HidePartyInvite()
	if(!p || !p.leader || !mob) return
	party_invite_from = p
	party_invite_objs = list()
	var/list/v = splittext("[view]", "x")
	if(v.len < 2) return
	var/tw = text2num(v[1]); var/th = text2num(v[2])
	if(!tw || !th) return
	var/leftpx = max(0, round((tw * 32 - 224) / 2))
	pinv_pix = leftpx % 32
	pinv_tile = (leftpx - pinv_pix) / 32 + 1
	var/toppx = max(0, round((th * 32 - 140) / 2))         // from view top
	var/pbot = toppx + 140
	var/ptiles = round(pbot / 32)
	if(ptiles * 32 < pbot) ptiles++
	pinv_row = max(th - ptiles + 1, 1)
	pinv_off = (th - pinv_row + 1) * 32 - pbot

	var/atom/movable/shud/partyinvitebg/bg = new
	bg.icon = 'HUD/party_prompt.png'
	bg.layer = MHUD_LAYER + 1
	bg.screen_loc = InviteLoc(0, 0)
	party_invite_objs += bg
	screen += bg

	// inviter portrait, 38 inside the 64 frame, built exactly like the player panel so it reliably renders
	var/icon/base = icon('HUD/portrait_frame.png')
	var/icon/pp = icon(p.leader.GetPortrait())
	pp.Blend(icon('HUD/portrait_mask.png'), ICON_MULTIPLY)
	base.Blend(pp, ICON_OVERLAY, 13, 13)             // 38px portrait centered in the 64px frame
	var/atom/movable/shud/pic = new
	pic.icon = base
	pic.layer = MHUD_LAYER + 1.1
	pic.mouse_opacity = 0
	pic.screen_loc = InviteLoc(80, 140 - 8 - 64)            // centered: (224-64)/2 = 80
	party_invite_objs += pic
	screen += pic

	var/nm = p.leader.name                                  // name on its own centered line, truncated to fit
	if(length(nm) > 22) nm = copytext(nm, 1, 21) + ".."
	var/atom/movable/shud/cardtext/nmtxt = new
	nmtxt.layer = MHUD_LAYER + 1.2
	nmtxt.mouse_opacity = 0
	nmtxt.maptext_x = 8
	nmtxt.maptext_y = 53
	nmtxt.maptext_width = 208
	nmtxt.maptext_height = 16
	nmtxt.screen_loc = InviteLoc(0, 0)
	nmtxt.maptext = "<center><span style=\"[PCARD_FONT]; color:#ffffff\">[nm]</span></center>"
	party_invite_objs += nmtxt
	screen += nmtxt

	var/atom/movable/shud/cardtext/txt = new
	txt.layer = MHUD_LAYER + 1.2
	txt.mouse_opacity = 0
	txt.maptext_x = 8
	txt.maptext_y = 37
	txt.maptext_width = 208
	txt.maptext_height = 16
	txt.screen_loc = InviteLoc(0, 0)
	txt.maptext = "<center><span style=\"[PCARD_FONT]; color:#bfefff\">invites you to their party!</span></center>"
	party_invite_objs += txt
	screen += txt

	MkInviteBtn("yes", "Yes", "#78eb78", 20, 13)
	MkInviteBtn("no",  "No",  "#ff6464", 124, 13)

	KineticEntrance(party_invite_objs)

client/proc/PartyInviteAction(action)
	switch(action)
		if("yes") AcceptPartyInvite()
		if("no")  DeclinePartyInvite()

client/proc/AcceptPartyInvite()
	var/Party/p = party_invite_from
	HidePartyInvite()
	if(!mob) return
	mob.pending_party = null
	if(!p) return
	p.pending_invites -= mob
	if(mob.party)
		mob << "You're already in a party."
		return
	if(p.members.len >= MAX_PARTY_LIMIT)
		mob << "That party is full."
		if(p.leader) p.leader << "[mob] couldn't join - the party is full."
		return
	p.finalize_join(mob)

client/proc/DeclinePartyInvite()
	var/Party/p = party_invite_from
	HidePartyInvite()
	if(mob) mob.pending_party = null
	if(p)
		p.pending_invites -= mob
		if(p.leader) p.leader << "[mob] declined your party invite."

client/proc/HidePartyInvite()
	party_invite_from = null
	if(party_invite_objs)
		while(party_invite_objs.len)
			var/atom/movable/o = party_invite_objs[party_invite_objs.len]
			party_invite_objs.len--
			screen -= o
			del o
		party_invite_objs = null

mob/proc/CanInviteToParty()                      
	if(istype(src, /mob/Player/AI)) return 0
	var/mob/Players/me = src
	if(istype(me) && (me.Class in list("Dance", "Potara"))) return 0   // fused can't party
	if(party)
		if(party.leader != src) return 0          
		if(party.members.len >= MAX_PARTY_LIMIT) return 0   // party already full
		if(party.pending_invites.len) return 0    // already waiting on a response to an invite
	return 1

mob/proc/CanBeInvited()                          
	if(!client) return 0
	if(istype(src, /mob/Player/AI)) return 0
	var/mob/Players/me = src
	if(istype(me) && (me.Class in list("Dance", "Potara"))) return 0
	if(party) return 0                            // already in a party
	return 1

mob/proc/InviteToParty(mob/T)
	if(!T || T == src) return
	if(istype(src, /mob/Player/AI)) return
	var/mob/Players/me = src
	if(istype(me) && (me.Class in list("Dance", "Potara")))
		src << "Fused characters can't form parties."
		return
	if(party && party.leader != src)
		src << "Only the party leader can invite."
		return
	if(party && party.members.len >= MAX_PARTY_LIMIT)
		src << "Your party is already full."
		return
	if(party && party.pending_invites.len)
		src << "You already have a pending invite - wait for them to respond first."
		return
	if(!T.CanBeInvited())
		src << "[T] can't be invited to a party right now."
		return
	if(!party)
		var/Party/np = new
		np.create_party(src)                      // auto-create; src becomes the leader
	if(!party) return
	party.add_member(T)                           // shows T the asset Yes/No prompt
	src << "You invited [T] to your party."
