/obj/Items/Gauntlet
	var/Conjured
	var/ImprovedStat
	var/ElementallyInfused
	var/HitSparkIcon
	var/HitSparkX
	var/HitSparkY
	var/HitSparkSize=1
	var/Purity //waifu swords
	var/ManaGeneration=0
	var/iconAlt=null
	var/iconAltX=0
	var/iconAltY=0
	var/ClassAlt=null
	icon_state="Inventory"
	TechType="Forge"
	UpdatesDescription=1
	Repairable=1
	passives = list("ComboMaster" = 1, "HeavyHitter" = 0.5)
	Wraps // wooden

	Gloves // light

	Knucklers // med

	PushKnife // heavy ? 