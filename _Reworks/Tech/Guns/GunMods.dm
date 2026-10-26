/obj/Items/Armor/Mobile_Armor/var/ballistic_weave = 0

/obj/Items/GunMod
	name = "Gun Mod"
	desc = "A gun attachment. Click it with a gun equipped to fit it into a free mod socket."
	var/mod_short = "Mod"

	Click()
		if(!(src in usr))
			return ..()
		usr.GunModInstall(src)

/obj/Items/GunMod/Extended_Mag
	name = "Extended Mag"
	mod_short = "Extended Mag"
	desc = "A longer magazine. The gun holds a quarter more rounds, never past sixty."
	icon = 'Icons/Other/Guns.dmi'
	icon_state = "Ammo Box"
	mod_mag_mult = GUN_EXTMAG_MULT

/obj/Items/GunMod/Scope
	name = "Scope"
	mod_short = "Scope"
	desc = "An optic that adds two tiles of range and widens the aim assist."
	icon = 'device.dmi'
	icon_state = "infrared0"
	mod_range = GUN_SCOPE_RANGE
	mod_cone = GUN_SCOPE_CONE

/obj/Items/GunMod/Compensator
	name = "Compensator"
	mod_short = "Compensator"
	desc = "A muzzle brake. Each shot adds half as much bloom."
	icon = 'device.dmi'
	icon_state = "t-ray0"
	mod_bloom_mult = GUN_COMP_BLOOM

/obj/Items/GunMod/Speed_Loader
	name = "Speed Loader"
	mod_short = "Speed Loader"
	desc = "A loading clip. Reloads go a quarter faster."
	icon = 'device.dmi'
	icon_state = "dosimeter"
	mod_reload_mult = GUN_SPEEDLOADER_MULT

/obj/Items/GunMod/Laser_Sight
	name = "Laser Sight"
	mod_short = "Laser Sight"
	desc = "A laser dot that steadies your aim."
	icon = 'device.dmi'
	icon_state = "infrared1"
	mod_acc = GUN_LASER_ACC

/obj/Items/GunMod/Bayonet
	name = "Bayonet"
	mod_short = "Bayonet"
	desc = "A blade under the barrel. With an empty magazine, your swing becomes a full-strength stab that bleeds."
	icon = 'device.dmi'
	icon_state = "multitool"
	mod_whip = 1
	mod_skill = /obj/Skills/AutoHit/GunArt/Bayonet_Stab

/obj/Items/GunMod/Suppressor
	name = "Suppressor"
	mod_short = "Suppressor"
	desc = "Silences the gun. Nobody around you hears your shots or your reloads."
	icon = 'device.dmi'
	icon_state = "signaller"
	mod_silent = 1

/obj/Items/GunMod/Underbarrel_Launcher
	name = "Underbarrel Launcher"
	mod_short = "Underbarrel"
	desc = "A grenade launcher under the barrel. It fires Frag Grenades from your pack."
	icon = 'device.dmi'
	icon_state = "locator"
	mod_skill = /obj/Skills/Projectile/GunArt/Underbarrel

/obj/Items/GunMod/Ballistic_Weave
	name = "Ballistic Weave"
	mod_short = "Weave"
	desc = "Tough fiber for lining armor. Click it with an Armored Vest in your pack to weave the vest against bullets. A woven vest takes a quarter less damage from gunfire."
	icon = 'Tech.dmi'
	icon_state = "Fiber Bond"

	Click()
		if(!(src in usr))
			return ..()
		usr.GunWeaveVest(src)

mob/proc/GunModInstall(obj/Items/GunMod/M)
	if(!M || M.loc != src)
		return 0
	if(istype(M, /obj/Items/GunMod/Ballistic_Weave))
		return GunWeaveVest(M)
	var/obj/Items/Gun/G = EquippedGun()
	if(!G)
		src << "Equip a gun to fit the [M.name]."
		return 0
	if(InCombat())
		src << "You can't fit a mod in the middle of a fight."
		return 0
	if(G.HasMod(M.type))
		src << "Your [G.name] already has a [M.name]."
		return 0
	if(G.mods.len >= GUN_MOD_SLOTS)
		src << "Both mod sockets on your [G.name] are full."
		return 0
	G.mods += M
	M.loc = null
	G.SyncMag(src)
	GunArtsOn(G)
	GunRefillSkill(G)
	src << "You fit the [M.name] to your [G.name]."
	if(client)
		client.BuildInvPage()
		if(client.inv_desc_item == M)
			client.HideItemDesc()
	return 1

mob/proc/GunModRemove(obj/Items/Gun/G, obj/Items/GunMod/M)
	if(!G || !M || G.loc != src || !(M in G.mods))
		return 0
	if(InCombat())
		src << "You can't strip a mod in the middle of a fight."
		return 0
	G.mods -= M
	if(M.mod_skill && EquippedGun() == G)
		GunArtDrop(M.mod_skill)
	var/extra = G.SyncMag(src)
	if(EquippedGun() == G)
		GunRefillSkill(G)
	GiveOrDrop(M)
	src << "You take the [M.name] off your [G.name].[extra ? " [extra] round\s go back in your pack." : ""]"
	return 1

mob/proc/GunWovenVest()
	var/obj/Items/Armor/Mobile_Armor/V = EquippedArmor()
	return (istype(V) && V.ballistic_weave) ? 1 : 0

mob/proc/GunWeaveVest(obj/Items/GunMod/Ballistic_Weave/W)
	if(!W || W.loc != src)
		return 0
	if(InCombat())
		src << "You can't weave armor in the middle of a fight."
		return 0
	var/obj/Items/Armor/Mobile_Armor/V
	var/obj/Items/Armor/Mobile_Armor/worn = EquippedArmor()
	if(istype(worn) && worn.type == /obj/Items/Armor/Mobile_Armor && !worn.ballistic_weave)
		V = worn
	if(!V)
		for(var/obj/Items/Armor/Mobile_Armor/A in src)
			if(A.type == /obj/Items/Armor/Mobile_Armor && !A.ballistic_weave)
				V = A
				break
	if(!V)
		src << "You need an Armored Vest in your pack that is not woven yet."
		return 0
	V.ballistic_weave = 1
	V.name = "Woven [V.name]"
	if(W.Stackable && W.TotalStack > 1)
		W.TotalStack--
		W.suffix = "[W.TotalStack]"
	else
		del W
	src << "You weave ballistic fiber into the lining. It is now a [V.name]."
	if(client)
		client.BuildInvPage()
	return 1

/atom/movable/shud/invgunmodbtn
	layer = MINV_LAYER + 0.7
	mouse_opacity = 2
	maptext_height = 18
	var/obj/Items/Gun/gun
	var/obj/Items/GunMod/mod

	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

	Click(location, control, params)
		if(!usr || !usr.client)
			return
		if(params && findtext(params, "right=1"))
			usr.client.HideItemDesc()
			return
		if(!gun || !mod)
			return
		var/obj/Items/Gun/G = gun
		usr.GunModRemove(G, mod)
		if(usr.client.inv_desc_item == G)
			usr.client.ShowItemDesc(G)

client/GunModDescButton(obj/Items/I, list/objs)
	..()
	if(!istype(I, /obj/Items/Gun) || !islist(objs))
		return
	var/obj/Items/Gun/G = I
	for(var/i = 1 to GUN_MOD_SLOTS)
		var/y = GUN_MODROW_Y - (i - 1) * GUN_MODROW_STEP
		if(i <= G.mods.len)
			var/obj/Items/GunMod/M = G.mods[i]
			var/atom/movable/shud/invgunmodbtn/b = new
			b.gun = G
			b.mod = M
			b.maptext_width = GUN_MODROW_W
			b.maptext = "<span style=\"[MINV_FONT]; color:#8be9ff\">&#10005; [M.mod_short]</span>"
			b.screen_loc = "[InvXLoc(GUN_MODROW_X)],CENTER:[y]"
			objs += b
		else
			var/atom/movable/shud/invtext/t = new
			t.layer = MINV_LAYER + 0.6
			t.mouse_opacity = 0
			t.maptext_width = GUN_MODROW_W
			t.maptext_height = 18
			t.maptext = "<span style=\"[MINV_FONT]; color:#6b7a8d\">Empty mod socket</span>"
			t.screen_loc = "[InvXLoc(GUN_MODROW_X)],CENTER:[y]"
			objs += t
