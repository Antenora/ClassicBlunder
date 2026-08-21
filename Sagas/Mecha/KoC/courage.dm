
sagaInfo/courage
	choicesPaths = list("1" = list("Endless Evolution", "Bright Bravery", "Divine Destiny"))
	perLevelPassives = list("Deus Ex Machina" = 5)
	skillsPerTier = list()

sagaInfo/courage/Endless_Evolution
	choicesPaths = list("2" = list("Overwhelming Force", "Unstoppable Strength", "Peerless Agility"))

	specificPassives =list("3" = list("Overwhelming Force" = list("MovingCharge" = 1)))

	skillsPerTier = list(	"2" = list("Overwhelming Force" = "/obj/Skills/Projectile/Beams/Will_Beam", "Unstoppable Strength" = "/obj/Skills/Grapple/Seismic_Toss", \
										"Peerless Agility" = "/obj/Skills/AutoHit/Drill_of_Defiance"), \

							"3" = list("Unstoppable Strength" = "/obj/Skills/Buffs/SlotlessBuffs/Plot_Armor"), \

							"4" = list("/obj/Skills/Buffs/SlotlessBuffs/Veiled_Reality", \
										"Peerless Agility" = "/obj/Skills/AutoHit/Giga_Drill_Breaker"), \
							"5" = "/obj/Skills/Buffs/SlotlessBuffs/Evolve", \

							"6" = "/obj/Skills/Queue/Shine_Shine_Spark")	
