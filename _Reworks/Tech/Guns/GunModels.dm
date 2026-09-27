obj/Items/Gun
	var/list/LegendNames

obj/Items/Gun/Handgun/Handgun
	desc = "A reliable sidearm with a ten-round magazine. Its weapon art is Quickdraw."
	Techniques = list(/obj/Skills/Projectile/GunArt/Quickdraw)
	LegendNames = list("Legendary Handgun", "Legendary Handgun", "Legendary Handgun")

obj/Items/Gun/Handgun/USP
	name = "USP"
	desc = "A service pistol with a twelve-round magazine. A little lighter in the hand and a little more accurate. Its weapon art is Quickdraw."
	Class = "Light"
	MagSize = 12
	icon_state = "USP"
	EquipIcon = 'Blaster.dmi'
	pixel_x = 0
	pixel_y = 0
	BulletIcon = 'BlastTracer.dmi'
	BulletSize = 1
	BulletLockX = 0
	BulletLockY = 0
	BulletHitW = 12
	BulletHitH = 32
	MuzzleX = 0
	MuzzleY = 0
	ModelDamage = 0.95
	ModelAccuracy = 1.1
	ModelSpeed = 1
	Techniques = list(/obj/Skills/Projectile/GunArt/Quickdraw)
	LegendNames = list("Legendary USP", "Legendary USP", "Legendary USP")

obj/Items/Gun/Handgun/Red9
	name = "Red 9"
	desc = "A heavy old pistol with an eight-round magazine. It hits hard but slow. Its weapon art is Ricochet."
	Class = "Light"
	MagSize = 8
	icon_state = "Red 9"
	EquipIcon = 'Blaster.dmi'
	pixel_x = 0
	pixel_y = 0
	BulletIcon = 'BlastTracer.dmi'
	BulletSize = 1
	BulletLockX = 0
	BulletLockY = 0
	BulletHitW = 12
	BulletHitH = 32
	MuzzleX = 0
	MuzzleY = 0
	ModelDamage = 1.15
	ModelAccuracy = 0.95
	ModelSpeed = 0.9
	Techniques = list(/obj/Skills/Projectile/GunArt/Ricochet)
	LegendNames = list("Legendary Red 9", "Legendary Red 9", "Legendary Red 9")

obj/Items/Gun/Handgun/Magnum
	name = "Magnum"
	desc = "A six-shot revolver with a brutal kick. Every round lands like a hammer. Its weapon art is Fan the Hammer."
	Class = "Light"
	MagSize = 6
	icon_state = "Magnum"
	EquipIcon = 'Blaster.dmi'
	pixel_x = 0
	pixel_y = 0
	BulletIcon = 'BlastTracer.dmi'
	BulletSize = 1
	BulletLockX = 0
	BulletLockY = 0
	BulletHitW = 12
	BulletHitH = 32
	MuzzleX = 0
	MuzzleY = 0
	ModelDamage = 1.6
	ModelAccuracy = 1
	ModelSpeed = 0.75
	Techniques = list(/obj/Skills/Projectile/GunArt/Fan_the_Hammer)
	LegendNames = list("Legendary Magnum", "Legendary Magnum", "Legendary Magnum")

obj/Items/Gun/Handgun/Dualwield
	name = "Dualwield"
	desc = "A matched pair of pistols sharing sixteen rounds. Wild, but never short of lead. Its weapon art is Fan the Hammer."
	Class = "Light"
	MagSize = 16
	icon_state = "Dualwield"
	EquipIcon = 'Blaster.dmi'
	pixel_x = 0
	pixel_y = 0
	BulletIcon = 'BlastTracer.dmi'
	BulletSize = 1
	BulletLockX = 0
	BulletLockY = 0
	BulletHitW = 12
	BulletHitH = 32
	MuzzleX = 0
	MuzzleY = 0
	ModelDamage = 0.9
	ModelAccuracy = 0.8
	ModelSpeed = 1
	Techniques = list(/obj/Skills/Projectile/GunArt/Fan_the_Hammer)
	LegendNames = list("Legendary Dualwield", "Legendary Dualwield", "Legendary Dualwield")

obj/Items/Gun/Automatic/SMG
	desc = "A compact automatic with a thirty-round magazine. Hold the trigger to stream fire. Its weapon art is Burst."
	Techniques = list(/obj/Skills/Projectile/GunArt/Burst)
	LegendNames = list("Legendary SMG", "Legendary SMG", "Legendary SMG")

obj/Items/Gun/Automatic/TMP
	name = "TMP"
	desc = "A machine pistol that fires faster than it should, from a twenty-round magazine. Its weapon art is Burst."
	Class = "Light"
	MagSize = 20
	icon_state = "TMP"
	EquipIcon = 'AssaultRifle.dmi'
	pixel_x = 0
	pixel_y = 0
	BulletIcon = 'BlastTracer.dmi'
	BulletSize = 1
	BulletLockX = 0
	BulletLockY = 0
	BulletHitW = 12
	BulletHitH = 32
	MuzzleX = 0
	MuzzleY = 0
	ModelDamage = 0.85
	ModelAccuracy = 1
	ModelSpeed = 1.2
	Techniques = list(/obj/Skills/Projectile/GunArt/Burst)
	LegendNames = list("Legendary TMP", "Legendary TMP", "Legendary TMP")

obj/Items/Gun/Automatic/Glock18C
	name = "Glock 18C"
	desc = "A pistol converted to full auto. It chews through pistol rounds from an eighteen-round magazine and hits hard for its size. Its weapon art is Burst."
	Caliber = GUN_CALIBER_PISTOL
	Class = "Light"
	MagSize = 18
	icon_state = "Glock 18C"
	EquipIcon = 'AssaultRifle.dmi'
	pixel_x = 0
	pixel_y = 0
	BulletIcon = 'BlastTracer.dmi'
	BulletSize = 1
	BulletLockX = 0
	BulletLockY = 0
	BulletHitW = 12
	BulletHitH = 32
	MuzzleX = 0
	MuzzleY = 0
	ModelDamage = 1.4
	ModelAccuracy = 0.9
	ModelSpeed = 0.85
	Techniques = list(/obj/Skills/Projectile/GunArt/Burst)
	LegendNames = list("Legendary Glock 18C", "Legendary Glock 18C", "Legendary Glock 18C")

obj/Items/Gun/Automatic/Tactical
	name = "Tactical"
	desc = "A steady rifle with a forty-round magazine, built to hold a line. Its weapon art is Suppressing Fire."
	Class = "Light"
	MagSize = 40
	icon_state = "Tactical"
	EquipIcon = 'AssaultRifle.dmi'
	pixel_x = 0
	pixel_y = 0
	BulletIcon = 'BlastTracer.dmi'
	BulletSize = 1
	BulletLockX = 0
	BulletLockY = 0
	BulletHitW = 12
	BulletHitH = 32
	MuzzleX = 0
	MuzzleY = 0
	ModelDamage = 1
	ModelAccuracy = 1.15
	ModelSpeed = 0.9
	Techniques = list(/obj/Skills/Projectile/GunArt/Suppressing_Fire)
	LegendNames = list("Legendary Tactical", "Legendary Tactical", "Legendary Tactical")

obj/Items/Gun/Shotgun/Shotgun
	desc = "A pump shotgun holding six shells. Brutal up close, useless far away. Its weapon art is Slug."
	Techniques = list(/obj/Skills/Projectile/GunArt/Slug)
	LegendNames = list("Legendary Shotgun", "Legendary Shotgun", "Legendary Shotgun")

obj/Items/Gun/Shotgun/Punisher
	name = "Punisher"
	desc = "A sawed-off double barrel. Two shells, and nothing survives them at arm's length. Its weapon art is Point Blank."
	Class = "Heavy"
	MagSize = 2
	icon_state = "Punisher"
	EquipIcon = 'AssaultRifle.dmi'
	pixel_x = 0
	pixel_y = 0
	BulletIcon = 'BlastTracer.dmi'
	BulletSize = 1
	BulletLockX = 0
	BulletLockY = 0
	BulletHitW = 10
	BulletHitH = 32
	MuzzleX = 0
	MuzzleY = 0
	ModelDamage = 1.5
	ModelAccuracy = 0.9
	ModelSpeed = 0.9
	Techniques = list(/obj/Skills/Projectile/GunArt/Point_Blank)
	LegendNames = list("Legendary Punisher", "Legendary Punisher", "Legendary Punisher")

/proc/GunModelTypes()
	return list(\
		/obj/Items/Gun/Handgun/Handgun, /obj/Items/Gun/Handgun/USP, /obj/Items/Gun/Handgun/Red9,\
		/obj/Items/Gun/Handgun/Magnum, /obj/Items/Gun/Handgun/Dualwield,\
		/obj/Items/Gun/Automatic/SMG, /obj/Items/Gun/Automatic/TMP, /obj/Items/Gun/Automatic/Glock18C,\
		/obj/Items/Gun/Automatic/Tactical,\
		/obj/Items/Gun/Shotgun/Shotgun, /obj/Items/Gun/Shotgun/Punisher)

/mob/Admin4/verb/gunContentKit()
	set category = "Admin"
	set name = "Gun Content Kit"
	for(var/p in GunModelTypes())
		var/obj/Items/Gun/G = new p(usr)
		G.LoadedType = text2path("/obj/Items/Ammo/[G.Caliber]/Standard")
		G.Loaded = G.MagSize
	for(var/p in typesof(/obj/Items/Ammo) - list(/obj/Items/Ammo, /obj/Items/Ammo/Pistol, /obj/Items/Ammo/Rifle, /obj/Items/Ammo/Shell))
		var/obj/Items/Ammo/A = new p(usr)
		A.TotalStack = 200
		A.suffix = "[A.TotalStack]"
	for(var/p in typesof(/obj/Items/GunMod) - /obj/Items/GunMod)
		new p(usr)
	var/frag = text2path("/obj/Items/Ordnance/Frag_Grenade")
	if(frag)
		var/obj/Items/F = new frag(usr)
		F.TotalStack = 5
		F.suffix = "[F.TotalStack]"
	if(usr.client)
		usr.client.BuildInvPage()
	usr << "Every gun model loaded, 200 of every round, one of every mod and five Frag Grenades added."
