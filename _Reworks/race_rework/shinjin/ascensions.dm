ascension
	shinjin
		unlock_potential = -1
		onAscension(mob/owner)
			skills = list(/obj/Skills/Utility/Bind_To_Plane, /obj/Skills/Teleport/Kai_Kai)

			if(owner.ShinjinAscension=="Kai")
				passives = list("SpiritPower" = 0.5, "GodKi" = 0.25)
				skills += /obj/Skills/Utility/Heal
				skills += /obj/Skills/Utility/Send_Energy
			if(owner.ShinjinAscension=="Makai")
				owner.ContractPowered=1
				intimidation = 50
				owner.PotentialCap*=2
				passives = list("GodKi" = 0.5)
			..()