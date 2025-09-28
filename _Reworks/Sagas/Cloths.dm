/mob/var/ZodiacCharges = 0

/mob/proc/PickGoldCloth()
	if(!ClothGold)
		ClothGold = input(src, "What Constellation do you want to be?") in glob.GoldConstellationNames
		src<<"You are now the [ClothGold] Constellation!"

sagaTierUpMessages/Cosmo
	messages = list("You gained the ability to ignite your Cosmo, exchanging stamina for the ability to unlock extrasensory perception on the level of heroes and deities...", \
	"Your celestial guardian blesses you with the ability to clad yourself in their power!", \
	"Your celestial guardian blesses you with revelations of more advanced techniques and an even stronger cloth!", \
	"You are experiencing the first glimmers of Seventh Sense when in a pinch along with the ability to call upon your zodiac!", \
	"You reach the level of a Golden Saint, standing at the summit as a champion of Gods!", \
	"Your Cosmos burns with the power of a god!", \
	)





/var/sagaTierUpMessages/allSagaMessages = list("Cosmo" = new/sagaTierUpMessages/Cosmo())


/mob/tierUpSaga(path)
	..()
	if(path == "Cosmo")
		src<<allSagaMessages[path].messages[SagaLevel]

		switch(SagaLevel)
			if(2)
				switch(src.ClothBronze)
					if("Unicorn")
						if(!locate(/obj/Skills/AutoHit/Mighty_Horn, src))
							src.AddSkill(new/obj/Skills/AutoHit/Mighty_Horn)
							src.AddSkill(new/obj/Skills/Telekinesis)
						if(!locate(/obj/Skills/Queue/Unicorn_Combination, src))
							src.AddSkill(new/obj/Skills/Queue/Unicorn_Combination)
					if("Pegasus")
						if(!locate(/obj/Skills/Projectile/Pegasus_Comet_Fist, src))
							src.AddSkill(new/obj/Skills/Queue/Pegasus_Rolling_Crash)
							src.AddSkill(new/obj/Skills/Projectile/Pegasus_Comet_Fist)
					if("Dragon")
						if(!locate(/obj/Skills/Projectile/Beams/Saint_Seiya/Soaring_Mountain_Dragon, src))
							src.AddSkill(new/obj/Skills/Projectile/Beams/Saint_Seiya/Soaring_Mountain_Dragon)
					if("Cygnus")
						if(!locate(/obj/Skills/AutoHit/Aurora_Thunder_Attack, src))
							src.AddSkill(new/obj/Skills/AutoHit/Aurora_Thunder_Attack)
					if("Phoenix")
						totalExtraVoidRolls++
						if(!locate(/obj/Skills/AutoHit/Phoenix_Rising_Wing, src))
							src.AddSkill(new/obj/Skills/AutoHit/Phoenix_Rising_Wing)
			if(3)
				SenseUnlocked = 6
				var/v2Path = "/obj/Skills/Buffs/SpecialBuffs/Saint_Cloth/Bronze_Cloth_V2/[ClothBronze]_Cloth"
				for(var/obj/Skills/Buffs/SpecialBuffs/Saint_Cloth/Bronze_Cloth/Buff in src)
					if(src.BuffOn(Buff))
						Buff.Trigger(src, 1)
					del Buff
				if(ClothBronze=="Phoenix")
					totalExtraVoidRolls++
				src.AddSkill(new v2Path)
			if(4)
				ZodiacCharges++
				if(!ClothGold)
					PickGoldCloth()
					if(!glob.infConstellations)
						glob.takeLimited("GoldConstellation", ClothGold)
				AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/SeventhSense)
				if(!locate(/obj/Skills/Utility/Zodiac_Invocation, src))
					src.AddSkill(new/obj/Skills/Utility/Zodiac_Invocation)
			if(5)
				SenseUnlocked++
				for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/SeventhSense/SS in src)
					SS.NeedsHealth = 25
					SS.ActiveMessage="burns their Cosmo with full strength and attains the Eighth Sense!!!"
					SS.OffMessage="has lost their Eighth Sense..."
					SS.TooMuchHealth = 50
					SS.passives["SpiritPower"] = 0.25
				switch(src.ClothGold)
					if("Aries")
						if(!locate(/obj/Skills/Projectile/Stardust_Revolution, src))
							src.AddSkill(new/obj/Skills/Projectile/Stardust_Revolution)
						if(!locate(/obj/Skills/AutoHit/Starlight_Extinction, src))
							src.AddSkill(new/obj/Skills/AutoHit/Starlight_Extinction)
						if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Crystal_Wall, src))
							src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Crystal_Wall)
						if(!locate(/obj/Skills/Telekinesis, src))
							src.AddSkill(new/obj/Skills/Telekinesis)
					if("Gemini")
						if(!locate(/obj/Skills/Projectile/Galaxian_Explosion, src))
							src.AddSkill(new/obj/Skills/Projectile/Galaxian_Explosion)
						if(!locate(/obj/Skills/AutoHit/Another_Dimension, src))
							src.AddSkill(new/obj/Skills/AutoHit/Another_Dimension)
						if(!locate(/obj/Skills/Queue/Demon_Emperor_Fist, src))
							src.AddSkill(new/obj/Skills/Queue/Demon_Emperor_Fist)
						if(!locate(/obj/Skills/Teleport/Traverse_Dimension, src))
							src.AddSkill(new/obj/Skills/Teleport/Traverse_Dimension)
					if("Cancer")
						if(!locate(/obj/Skills/Projectile/Praesepe_Demonic_Blue_Flames, src))
							src.AddSkill(new/obj/Skills/Projectile/Praesepe_Demonic_Blue_Flames)
						if(!locate(/obj/Skills/AutoHit/Praesepe_Underworld_Waves, src))
							src.AddSkill(new/obj/Skills/AutoHit/Praesepe_Underworld_Waves)
						if(!locate(/obj/Skills/Queue/Acubens, src))
							src.AddSkill(new/obj/Skills/Queue/Acubens)
						if(!locate(/obj/Skills/Teleport/Traverse_Underworld, src))
							src.AddSkill(new/obj/Skills/Teleport/Traverse_Underworld)
					if("Leo")
						if(!locate(/obj/Skills/Projectile/Lightning_Bolt, src))
							src.AddSkill(new/obj/Skills/Projectile/Lightning_Bolt)
						if(!locate(/obj/Skills/AutoHit/Lightning_Plasma_Burst, src))
							src.AddSkill(new/obj/Skills/AutoHit/Lightning_Plasma_Burst)
						if(!locate(/obj/Skills/Queue/Lightning_Plasma_Strike, src))
							src.AddSkill(new/obj/Skills/Queue/Lightning_Plasma_Strike)
					if("Virgo")
						if(!locate(/obj/Skills/AutoHit/Demon_Pacifier, src))
							src.AddSkill(new/obj/Skills/AutoHit/Demon_Pacifier)
						if(!locate(/obj/Skills/Queue/Six_Transmigrations, src))
							src.AddSkill(new/obj/Skills/Queue/Six_Transmigrations)
						if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Heavenly_Ring_Dance, src))
							src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Heavenly_Ring_Dance)
					if("Libra")
						if(src.ClothBronze=="Dragon")
							for(var/obj/Skills/Queue/Rising_Dragon_Fist/rdf in src.Queues)
								if(!locate(/obj/Skills/Queue/Rising_Dragon_Lord, src))
									src.AddSkill(new/obj/Skills/Queue/Rising_Dragon_Lord)
								del rdf
							for(var/obj/Skills/Projectile/Beams/Saint_Seiya/Soaring_Mountain_Dragon/smd in src)
								if(!locate(/obj/Skills/Projectile/Beams/Saint_Seiya/Soaring_Dragon_Lord, src))
									src.AddSkill(new/obj/Skills/Projectile/Beams/Saint_Seiya/Soaring_Dragon_Lord)
								del smd
						else
							if(!locate(/obj/Skills/Queue/Rising_Dragon_Fist, src))
								src.AddSkill(new/obj/Skills/Queue/Rising_Dragon_Fist)
							if(!locate(/obj/Skills/Projectile/Beams/Saint_Seiya/Soaring_Mountain_Dragon, src))
								src.AddSkill(new/obj/Skills/Projectile/Beams/Saint_Seiya/Soaring_Mountain_Dragon)
					if("Scorpio")
						if(!locate(/obj/Skills/Projectile/Scarlet_Needle, src))
							src.AddSkill(new/obj/Skills/Projectile/Scarlet_Needle)
						if(!locate(/obj/Skills/AutoHit/Restriction, src))
							src.AddSkill(new/obj/Skills/AutoHit/Restriction)
						if(!locate(/obj/Skills/Queue/Antares, src))
							src.AddSkill(new/obj/Skills/Queue/Antares)
					if("Capricorn")
						if(!locate(/obj/Skills/Projectile/Sacred_Sword, src))
							src.AddSkill(new/obj/Skills/Projectile/Sacred_Sword)
						if(!locate(/obj/Skills/AutoHit/Sacred_Sword_Excalibur, src))
							src.AddSkill(new/obj/Skills/AutoHit/Sacred_Sword_Excalibur)
						if(!locate(/obj/Skills/Queue/Jumping_Stone, src))
							src.AddSkill(new/obj/Skills/Queue/Jumping_Stone)
						if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Excalibur, src))
							src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Excalibur)
					if("Aquarius")
						if(src.ClothBronze=="Cygnus")
							for(var/obj/Skills/Projectile/Diamond_Dust/dd in src)
								if(!locate(/obj/Skills/Projectile/Diamond_Dust_Storm, src))
									src.AddSkill(new/obj/Skills/Projectile/Diamond_Dust_Storm)
								del dd
						else
							if(!locate(/obj/Skills/Projectile/Diamond_Dust, src))
								src.AddSkill(new/obj/Skills/Projectile/Diamond_Dust)
						if(!locate(/obj/Skills/Projectile/Beams/Big/Saint_Seiya/Aurora_Execution, src))
							src.AddSkill(new/obj/Skills/Projectile/Beams/Big/Saint_Seiya/Aurora_Execution)
						if(!locate(/obj/Skills/AutoHit/Ice_Coffin, src))
							src.AddSkill(new/obj/Skills/AutoHit/Ice_Coffin)
						if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Kolco, src))
							src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Kolco)
					if("Pisces")
						if(!locate(/obj/Skills/Projectile/Royal_Demon_Rose, src))
							src.AddSkill(new/obj/Skills/Projectile/Royal_Demon_Rose)
						if(!locate(/obj/Skills/Queue/Piranhan_Rose, src))
							src.AddSkill(new/obj/Skills/Queue/Piranhan_Rose)
						if(!locate(/obj/Skills/AutoHit/Bloody_Rose, src))
							src.AddSkill(new/obj/Skills/AutoHit/Bloody_Rose)
					if("Sagittarius")
						if(!locate(/obj/Skills/Projectile/Light_Impulse, src))
							src.AddSkill(new/obj/Skills/Projectile/Light_Impulse)
						if(!locate(/obj/Skills/Projectile/Infinity_Break, src))
							src.AddSkill(new/obj/Skills/Projectile/Infinity_Break)
						if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Sagittarius_Bow, src))
							src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Sagittarius_Bow)
			if(6)
				for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/SeventhSense/SS in src)
					SS.NeedsHealth = 40
					SS.TooMuchHealth = 75
				SenseUnlocked++

/obj/Skills/Buffs/SlotlessBuffs/SeventhSense // OLD
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/SeventhSense
	BuffName = "Seventh Sense"
	SenseUnlocked = 1
	TooMuchHealth = 30
	NeedsHealth = 15
	WoundIntentRequired = TRUE
	ActiveMessage="burns their Cosmo with full strength and attains the Seventh Sense!!!"
	OffMessage="has lost their Seventh Sense..."

