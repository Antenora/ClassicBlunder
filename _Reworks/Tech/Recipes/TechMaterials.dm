/datum/life_matfamily/tech_parts
	root = /obj/Items/Material/Part
	category = "Ingots"
	sell_skill = "Technology"

/obj/Items/Material/Part
	desc = "A manufactured component. Technologists build everything from these."
	var/tier = 1
	Wiring { name = "Wiring"; MaterialClass = "Wiring"; icon = 'device.dmi'; icon_state = "headset"; tier = 1; desc = "Drawn copper wire. Every device needs some." }
	Casing { name = "Casing"; MaterialClass = "Casing"; icon = 'Tech.dmi'; icon_state = "Frame"; tier = 1; desc = "A stamped metal shell that holds a device together." }
	Propellant { name = "Propellant"; MaterialClass = "Propellant"; icon = 'device.dmi'; icon_state = "igniter"; tier = 1; desc = "A packed charge of coal and guano. It burns fast." }
	BioGel { name = "BioGel"; MaterialClass = "BioGel"; icon = 'Tech.dmi'; icon_state = "Weird"; tier = 1; desc = "A healing gel of herb and gelatin, the base of every medicine." }
	CircuitBoard { name = "Circuit Board"; MaterialClass = "CircuitBoard"; icon = 'Tech.dmi'; icon_state = "SecChip"; tier = 2; desc = "Etched traces on a gelatin board. The brain of a device." }
	Servo { name = "Servo"; MaterialClass = "Servo"; icon = 'device.dmi'; icon_state = "timer0"; tier = 2; desc = "A steel motor strung with sinew. It moves things." }
	PowerCell { name = "Power Cell"; MaterialClass = "PowerCell"; icon = 'Tech.dmi'; icon_state = "CoinChip"; tier = 2; desc = "A monster core sealed in cobalt. It holds a charge." }
	Lens { name = "Lens"; MaterialClass = "Lens"; icon = 'Tech.dmi'; icon_state = "SPR"; tier = 3; desc = "Ground gem glass in a silver ring." }
	FuelCell { name = "Fuel Cell"; MaterialClass = "FuelCell"; icon = 'device.dmi'; icon_state = "emp"; tier = 3; desc = "A sealed canister of fuel for engines and generators." }
	Nanites { name = "Nanites"; MaterialClass = "Nanites"; icon = 'device.dmi'; icon_state = "hydro"; tier = 5; desc = "A swarm of starmetal machines, each smaller than a grain of sand." }

/datum/life_tagset/tech
	tags = list(\
		"BoarSinew" = list("sinew"),\
		"OgreSinew" = list("sinew"),\
		"SlimeCore" = list("core"),\
		"MudGolemCore" = list("core"),\
		"StoneGolemCore" = list("core"),\
		"FireGolemCore" = list("core"),\
		"ColossalCore" = list("core"),\
		"RedHerb" = list("herb"),\
		"GreenHerb" = list("herb"),\
		"GoldenHerb" = list("herb"),\
		"OliveHerb" = list("herb"),\
		"MintSprig" = list("herb"),\
		"FrostHerb" = list("herb"),\
		"Witchweed" = list("herb"),\
		"Nightleaf" = list("herb"),\
		"Ashwort" = list("herb"),\
		"Moonwort" = list("herb"),\
		"Wheat" = list("grain", "coal or grain"),\
		"Corn" = list("grain", "coal or grain"),\
		"Coal" = list("coal or grain"),\
		"Silver" = list("silver or gold"),\
		"Gold" = list("silver or gold"),\
		"Lens" = list("lens or servo"),\
		"Servo" = list("lens or servo"))

	New()
		..()
		for(var/T in typesof(/obj/Items/Material/Ingot) - /obj/Items/Material/Ingot)
			var/obj/Items/Material/m = new T
			var/mc = m.MaterialClass
			del m
			if(!mc || mc == "Scrap") continue
			var/list/cur = tags[mc]
			if(!cur)
				cur = list()
				tags[mc] = cur
			if(!("ingot" in cur)) cur += "ingot"
