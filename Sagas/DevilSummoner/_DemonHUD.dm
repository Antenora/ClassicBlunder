/obj/DemonSkillSlot
	appearance_flags = NO_CLIENT_COLOR | TILE_BOUND
	plane = 10
	layer = FLOAT_LAYER
	mouse_opacity = 1
	icon = 'Icons/DevilSummoner/SkillIcons.dmi'
	icon_state = "Physical"
	pixel_w = 0
	pixel_z = 0

	var/slot_index = 0
	var/skill_name = ""
	var/mob/hud_owner = null
	var/obj/cooldown_overlay = null
	var/obj/name_bar = null
	var/cooldown_end_time = 0

	New(mob/owner, index, sname)
		..()
		hud_owner = owner
		slot_index = index
		skill_name = sname
		name = sname

		// Set icon state based on skill element
		icon_state = GetSkillIconState(sname)

		// Create name bar object (background + text)
		name_bar = new /obj()
		name_bar.appearance_flags = NO_CLIENT_COLOR | TILE_BOUND
		name_bar.icon = 'Icons/DevilSummoner/portrait_placeholder.dmi'
		name_bar.icon_state = "N"
		name_bar.color = "#0a0818"
		name_bar.alpha = 200
		name_bar.plane = plane
		name_bar.layer = layer - 0.1
		name_bar.mouse_opacity = 0
		name_bar.pixel_w = 0
		name_bar.pixel_z = 0

		var/align = "center"
		switch(index)
			if(1) // Top slot — name bar sits above icon; top edge shifts +6px
				name_bar.pixel_w = -10
				name_bar.pixel_z = 18
				name_bar.maptext_x = 0
				name_bar.maptext_y = 9
				name_bar.maptext_width = 32
				name_bar.maptext_height = 14
				align = "center"
			if(2) // Left slot — name bar sits left of icon; left edge shifts -6px
				name_bar.pixel_w = -38
				name_bar.pixel_z = -10
				name_bar.maptext_x = 0
				name_bar.maptext_y = 9
				name_bar.maptext_width = 32
				name_bar.maptext_height = 14
				align = "center"
			if(3) // Right slot — name bar sits right of icon; right edge shifts +6px
				name_bar.pixel_w = 18
				name_bar.pixel_z = -10
				name_bar.maptext_x = 0
				name_bar.maptext_y = 9
				name_bar.maptext_width = 32
				name_bar.maptext_height = 14
				align = "center"
			if(4) // Bottom slot — name bar sits below icon; bottom edge shifts -6px
				name_bar.pixel_w = -10
				name_bar.pixel_z = -38
				name_bar.maptext_x = 0
				name_bar.maptext_y = 9
				name_bar.maptext_width = 32
				name_bar.maptext_height = 14
				align = "center"
		name_bar.maptext = "<span style='font-size:6pt;color:#c8b8ff;font-family:Arial;text-align:[align];'>[sname]</span>"
		vis_contents += name_bar

		// Cooldown overlay — must match the slot's scale
		cooldown_overlay = new /obj()
		cooldown_overlay.icon = icon
		cooldown_overlay.icon_state = icon_state
		cooldown_overlay.color = "#000000"
		cooldown_overlay.alpha = 0
		cooldown_overlay.plane = plane
		cooldown_overlay.layer = layer + 0.1
		cooldown_overlay.mouse_opacity = 0
		vis_contents += cooldown_overlay

	Click(location, control, params)
		if(!hud_owner || !skill_name) return
		if(hud_owner.KO || hud_owner.Dead) return
		if(!hud_owner.demon_active) return
		var/mob/Player/AI/Demon/d = hud_owner.demon_active
		if(!d) return
		d.DemonUseSkillManual(skill_name)

	proc/StartCooldown(duration_ticks)
		cooldown_end_time = world.time + duration_ticks
		if(cooldown_overlay)
			cooldown_overlay.alpha = 160
			animate(cooldown_overlay, alpha = 0, time = duration_ticks)

	proc/UpdateCooldownVisual()
		if(!cooldown_overlay) return
		if(cooldown_end_time <= world.time)
			if(cooldown_overlay.alpha != 0)
				cooldown_overlay.alpha = 0
			return
		// Recalculate remaining time and set alpha proportionally
		var/remaining = cooldown_end_time - world.time
		cooldown_overlay.alpha = 160
		animate(cooldown_overlay, alpha = 0, time = remaining)

	proc/Cleanup()
		if(cooldown_overlay)
			vis_contents -= cooldown_overlay
			del(cooldown_overlay)
		if(name_bar)
			vis_contents -= name_bar
			del(name_bar)
		hud_owner = null

/proc/GetSkillIconState(skill_name)
	switch(skill_name)
		// Fire
		if("Agi", "Agidyne", "Inferno", "Maragi", "Maragidyne", "Fire Dance")
			return "Fire"
		// Ice
		if("Bufu", "Bufudyne", "Mabufu", "Mabufudyne", "Ice Dance")
			return "Frost"
		// Elec
		if("Zio", "Ziodyne", "Mazio", "Maziodyne", "Elec Dance")
			return "Elec"
		// Force
		if("Zan", "Zandyne", "Mazan", "Mazandyne", "Force Dance")
			return "Force"
		// Almighty
		if("Holy Strike", "Megido", "Megidolaon", "Judgement", "Holy Dance")
			return "Almighty"
		// Physical
		if("Power Hit", "Mighty Hit", "Brutal Hit", "Anger Hit", "Piercing Hit",
		   "Fatal Strike", "Assassinate", "Desperation", "Multi-Strike",
		   "Deathbound", "Mow Down", "Hassohappa", "Berserk")
			return "Physical"
		// Heal
		if("Dia", "Diarama", "Diarahan", "Media", "Mediarahan", "Prayer",
		   "Recarm", "Samarecarm", "Recarmloss")
			return "Heal"
		// Drain
		if("Drain", "Life Drain")
			return "Curse"
		// Support
		if("Amrita", "Nigayomogi", "Shield All", "Power Charge",
		   "Death Call", "Might Call", "Taunt", "Makarakarn", "Tetrakarn",
		   "Extra Cancel")
			return "Support"
		// Status
		if("Marin Karin", "Gigajama")
			return "Curse"
	return "Physical"
	
// Screen_loc positions for 4-slot diamond (bottom-right)
// Slot 1 = top, 2 = left, 3 = right, 4 = bottom
var/global/list/DEMON_HUD_POSITIONS = list(
	"RIGHT-5:8,BOTTOM+4:16",
	"RIGHT-6:0,BOTTOM+3:16",
	"RIGHT-4:16,BOTTOM+3:16",
	"RIGHT-5:8,BOTTOM+2:16"
)

/mob/proc/BuildDemonSkillHUD(datum/party_demon/pd)
	ClearDemonSkillHUD()
	if(!pd || !pd.demon_skills || !pd.demon_skills.len) return
	if(!client) return

	demon_skill_hud = list()
	var/slot = 0
	for(var/sname in pd.demon_skills)
		slot++
		if(slot > 4) break
		if(!sname || sname == "None") continue
		var/obj/DemonSkillSlot/s = new(src, slot, sname)
		s.screen_loc = DEMON_HUD_POSITIONS[slot]
		client.screen += s
		demon_skill_hud += s

		// If skill is on cooldown from swapping, show remaining cooldown
		if(pd.skill_cooldowns && (sname in pd.skill_cooldowns))
			var/cd_end = pd.skill_cooldowns[sname]
			if(cd_end > world.time)
				s.StartCooldown(cd_end - world.time)

/mob/proc/ClearDemonSkillHUD()
	if(!demon_skill_hud) return
	for(var/obj/DemonSkillSlot/s in demon_skill_hud)
		if(client) client.screen -= s
		s.Cleanup()
		del(s)
	demon_skill_hud = null

/mob/proc/UpdateDemonSkillHUD()
	if(!demon_skill_hud) return
	if(!demon_active) return
	var/datum/party_demon/pd = null
	for(var/datum/party_demon/p in demon_party)
		if(p.demon_name == demon_active_name)
			pd = p
			break
	if(!pd) return
	for(var/obj/DemonSkillSlot/s in demon_skill_hud)
		if(pd.skill_cooldowns && (s.skill_name in pd.skill_cooldowns))
			var/cd_end = pd.skill_cooldowns[s.skill_name]
			if(cd_end > world.time)
				s.cooldown_end_time = cd_end
				s.UpdateCooldownVisual()
			else
				s.cooldown_end_time = 0
				if(s.cooldown_overlay) s.cooldown_overlay.alpha = 0
