

mob/var
	SagaLevel=0//Level for all tier s.
	SagaEXP=0//holds rpp investment
	SagaAdminPermission //allows override of rpp requirements and is required for tier 7/8
	UILevel=0//Seems to be the best place to put this. Sorry!

	list/SagaAscension=list("Str"=0, "End"=0, "Spd"=0, "For"=0)

	//Tier S variables.

	//WEAPON SOUL
	WeaponSoulType
	BoundLegend//GIVE ME MY SWORD BACK NO JUTSU

	//PERSONA!!!
	PersonaName
	PersonaAction
	PersonaType
	PersonaStrength
	PersonaEndurance
	PersonaSpeed
	PersonaForce
	PersonaOffense
	PersonaDefense
	PersonaRegeneration
	PersonaRecovery

	//JAGAN EYE
	JaganPowerNerf

	//UNLIMITED BLADE WORKS
	UBWReinforce//Adds extra reinforcement stats.
	UBWTrace//When this is marked, you can trace legendary weapons.
	KanshouBakuyaProject
	HolyBladeProject
	CorruptEdgeProject
	ProjectExcalibur
	ProjectLightbringer
	ProjectMuramasa
	ProjectDeathbringer
	MadeOfSwords
	PerfectProjection
	InUBW

	//ANSATSUKEN
	AnsatsukenPath
	AnsatsukenAscension

	//EIGHT GATES
	GatesActive=0
	Gate8Used=0
	Gate8Getups=0

	//VAIZARD
	VaizardRage//TODO: REMOVE
	VaizardHealth//You become immune to damage while this is up.
	VaizardType//Physical, Spiritual, Technical, Balanced
	VaizardIcon
	VaizardCounter//The more you get knocked out, the more likely vaizard is to trigger.

	//SHARINGAN
	SharinganEvolution
	//FORCE
	DarkSide
	LightSide
	//JINCHUURIKI
	JinchuuType

	//KAMUI
	KamuiType//Purity or Impulse
	KamuiBuffLock//Disallows active slot buffs

	//KEYBLADES
	KeybladeType
	KeybladeColor
	KeybladePath
	list/Keychains=list()
	KeychainAttached
	SyncAttached
	LimitCounter=0//Add one each form use; used to determine when antiform happens.
	NobodyOriginType //Used for Nobodies only
	//REBIRTH
	RebirthHeroType
	RebirthHeroPath
	tmp/AwakeningSkillUsed
	Snowgrave=5
	TranceLevel=0
	UndyingLoc
	FinalHeroChoice
	//SAINT SEIYA
	SenseUnlocked=5
	ClothBronze
	ClothGold

	chikaraWhitelist = FALSE
	//JESSE BULLSHIT
	Tier7SagaUnlocked=0

	//SHINIGAMI
	ShinigamiRelease
	AsauchiName
	ShikaiCall
	BankaiPrefix
	ZanpakutoClass
	ShihakushoClass
	ShikaiIcon
	ShikaiIconX = 0
	ShikaiIconY = 0
	BankaiIcon
	BankaiIconX = 0
	BankaiIconY = 0
	BankaiShihakushoIcon
	BankaiShihakushoIconX = 0
	BankaiShihakushoIconY = 0
	InShinigamiForm = FALSE
	UsedFinalGetsuga = FALSE

	ShikaiIconDual
	ShikaiIconDualX = 0
	ShikaiIconDualY = 0
	tmp/HideInShadowsActive = 0
	tmp/HiddenInShadow = 0
	tmp/KageoniEndTime = 0
	tmp/KageoniMidTransition = 0
	tmp/obj/Effects/Shadowbringer_Shadow/CurrentShadow
	tmp/obj/Effects/Shadowbringer_Shadow/ShadowbringerShadowObj
	tmp/IroniActive = 0
	tmp/IroniColor
	tmp/mob/IroniCaster
	tmp/DarumaActive = 0
	tmp/mob/DarumaTarget
	tmp/DarumaEndTime = 0
	tmp/ProjectileAttacking = 0

	// Kido pick tracking, shared across all four trees (Hado, Bakudo, Hoho, Hakuda)
	KidoSL1Picks = 0   // max 2; tier cap <=1
	KidoSL3Picks = 0   // max 2; tier cap <=2
	KidoSL5Picks = 0   // max 1; tier cap <=3
	KidoSL6Picks = 0   // max 1; tier cap <=4
	KidoSL7Picks = 0   // max 1; tier cap <=5


mob/Admin3/verb
	SagaManagement(mob/Players/P in players)
		set category="Admin"
		var/Level7=0
		var/list/SagaList=list("Cancel","Ansatsuken","Devil Summoner","Eight Gates","Cosmo", "Hero","Hiten Mitsurugi-Ryuu","Kamui","Keyblade","King of Braves","Path of a Hero: Rebirth","Sharingan","Shinigami","Weapon Soul", "Unlimited Blade Works","Force")
		if(P.Saga)
			if(P.Saga=="Keyblade"||P.Saga=="Weapon Soul"||P.Saga=="Cosmo"||P.Saga=="King of Braves"||P.Saga=="Hiten Mitsurugi-Ryuu"||P.Saga=="Shinigami")
				Level7=1
			if(P.Saga=="Devil Summoner")
				Level7=2  // Devil Summoner has 8 tiers
			if(P.SagaLevel>=6+Level7)
				src << "They've already fully mastered the power of their soul."
				return
			for(var/obj/Items/Enchantment/Crystal_of_Bilocation/CoD in world)
				if(CoD.Signature==P.ckey)
					switch(input("This character has a Crystal of Bilocation setup right now. Are you sure you would like to tier them up?") in list("Yes","No"))
						if("No")
							return

			// Zangetsu-specific, they must use Final Getsuga Tenshou before reaching Tier 7
			if(P.Saga == "Shinigami" && P.ShinigamiRelease == "Zangetsu" && P.SagaLevel >= 6 && !P.UsedFinalGetsuga)
				src << "[P] has not yet used Final Getsuga Tenshou. They must sacrifice their Shinigami powers before they can transcend to the final tier."
				return

			var/list/choices=list("Cancel")
			var/math=(7-P.SagaLevel+Level7)
			for(var/x=1, x<math, x++)
				choices.Add(x)

			var/input=input("This character is currently [P.Saga] Tier [P.SagaLevel]. How many levels do you want to add to them?") in choices
			if(input=="Cancel") return
			P.SagaAdminPermission=input
			P << "You've had [input] levels of your Saga unlocked! Meditate to obtain your new powers!"
			Log("Admin", "[ExtractInfo(src)] has increased [ExtractInfo(P)]'s [P.Saga] level from [P.SagaLevel] to [P.SagaLevel+input].")

		else
			var/selection
			if(P.race.type in glob.NoSagaRaces)
				src << "[P] is a [P.race.name], and they are therefore not eligible to receive a Saga."
				return
			else
				selection=input("Select a Tier S to grant. This will set them to T1 in it, granting whatever verbs at that level.") in SagaList
			for(var/obj/Skills/Buffs/NuStyle/s in P)
				if(P.BuffOn(s))
					s.Trigger(P, TRUE)
			var/list/passiveGain=list();
			switch(selection)
				if("Hero")
					P.Saga="Hero"
					P.SagaLevel=1
					HeroLegend = input(P, "What legend are you going to follow?") in glob.Heroes
					var/path = "/obj/Skills/Buffs/ActiveBuffs/Hero/[HeroLegend]Buff"
					var/obj/Skills/Buffs/ActiveBuffs/Hero/h = new path
					P.AddSkill(h)
					tierUpSaga("Hero")
				if("King of Courage")
					P.Saga="King of Courage"
					P.SagaLevel=1
					P.AddSkill(new/obj/Skills/Buffs/SpecialBuff/King_Of_Courage)
					tierUpSaga("King of Courage")
				if("Cosmo")
					P.Saga="Cosmo"
					P.SagaLevel=1
					P.passive_handler.Increase("KiControlMastery")
					P.KiControlMastery+=1
					if(!P.ClothBronze)
						if(!glob.infConstellations)
							var/list/openConstellations = glob.getOpen("BronzeConstellation")
							if(length(openConstellations) < 1)
								src<< "There are no more constellations available."
								return
							P.ClothBronze=input(P, "What cloth are you going!?") in openConstellations
							glob.takeLimited("BronzeConstellation", P.ClothBronze)
						else
							P.ClothBronze=input(P, "What cloth are you going!?") in glob.BronzeConstellationNames
					var/path = "/obj/Skills/Buffs/SpecialBuffs/Saint_Cloth/Bronze_Cloth/[P.ClothBronze]_Cloth"
					P.AddSkill(new path)
					P<<"Your destiny is defined by the stars of [P.ClothBronze]; you have become a champion of Gods: <b>Saint</b>!"
					P<<"You gained the ability to ignite your Cosmo, exchanging stamina for the ability to unlock extrasensory perception on the level of heroes and deities..."
					P<<"Your celestial guardian blesses you with a trump card technique!"
					switch(P.ClothBronze)
						if("Pegasus")
							if(!locate(/obj/Skills/AutoHit/Pegasus_Meteor_Fist, P))
								P.AddSkill(new/obj/Skills/AutoHit/Pegasus_Meteor_Fist)
						if("Dragon")
							if(!locate(/obj/Skills/Queue/Rising_Dragon_Fist, P))
								P.AddSkill(new/obj/Skills/Queue/Rising_Dragon_Fist)
						if("Cygnus")
							if(!locate(/obj/Skills/Projectile/Diamond_Dust, P))
								P.AddSkill(new/obj/Skills/Projectile/Diamond_Dust)
						if("Andromeda")
							if(!locate(/obj/Skills/Projectile/Nebula_Stream, P))
								P.AddSkill(new/obj/Skills/Projectile/Nebula_Stream)
						if("Phoenix")
							if(!locate(/obj/Skills/Queue/Phoenix_Demon_Illusion_Strike, P))
								P.AddSkill(new/obj/Skills/Queue/Phoenix_Demon_Illusion_Strike)
						if("Unicorn")
							if(!locate(/obj/Skills/AutoHit/Unicorn_Gallop, P))
								P.AddSkill(new/obj/Skills/AutoHit/Unicorn_Gallop)

				if("Weapon Soul")
					P.gainWeaponSoul()

				if("Persona")
					P<<"You awaken an arcane power through confronting your shadow... <b>Persona</b>!"
					P.Saga="Persona"
					P.AddSkill(new/obj/Skills/Buffs/ActiveBuffs/Persona)
					P.SagaLevel=1

				if("King of Braves")
					P<<"You are the embodiment of courage. The hero everyone has been waiting for...the <b>King of Braves</b>!"
					P.Saga="King of Braves"
					if(!locate(/obj/Skills/Buffs/SpecialBuffs/King_of_Braves, P))
						P.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/King_of_Braves)
					if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Genesic_Brave, P))
						P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Genesic_Brave)
					if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Will_Knife, P))
						P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Will_Knife)
					if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Protect_Shade, P))
						P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Protect_Shade)
					if(!locate(/obj/Skills/Projectile/King_of_Braves/Broken_Magnum, P))
						P.AddSkill(new/obj/Skills/Projectile/King_of_Braves/Broken_Magnum)
					P.CyberizeMod+=0.2
					P.passive_handler.Increase("PilotingProwess", 1)
					P.PilotingProwess+=1
					P.SagaLevel=1

				if("Unlimited Blade Works")
					P<<"Your whole life is... <b>Unlimited Blade Works</b>!"
					P.Saga="Unlimited Blade Works"
					P.SagaLevel=1
					P << "I am the bone of my sword."
					var/obj/Skills/Buffs/SlotlessBuffs/Aria_Chant/s = new/obj/Skills/Buffs/SlotlessBuffs/Aria_Chant
					s.Aria = list()
					s.Aria.Add("I am the bone of my sword.")
					s.Aria.Add("Steel is my body and fire is my blood.")
					s.Aria.Add("I have created over a thousand blades.")
					s.Aria.Add("Unaware of ||||.")
					P.AddSkill(s)
					P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Copy_Blade)
					P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Projection)
					P.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Sword_Savant)
					P << "You can conjure copies of equipment just from mana..."
					if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Magic/Reinforce_Self, P))
						P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Magic/Reinforce_Self)
						P<<"You can reinforce your body leagues past anything else..."

				if("Hiten Mitsurugi-Ryuu")
					P.gainHitenMitsurugi();
				if("Ansatsuken")
					P<<"You begin to learn of the assassin's fist... <b>Ansatsuken</b>!"
					P.Saga="Ansatsuken"
					P.SagaLevel=1
					P.passive_handler.Increase("SlayerMod", 0.625)
					P.passive_handler.Set("FavoredPrey", "Mortal")
					if(!locate(/obj/Skills/Buffs/NuStyle/UnarmedStyle/Ansatsuken_Style, P))
						var/obj/Skills/Buffs/NuStyle/s=new/obj/Skills/Buffs/NuStyle/UnarmedStyle/Ansatsuken_Style
						P.AddSkill(s)
						P << "You have learned the style of the Assassin's Fist..."
					if(!locate(/obj/Skills/Projectile/Ansatsuken/Hadoken, P))
						P << "You've learned how to project a wave of energy: <b>Hadoken</b>!"
						P.AddSkill(new/obj/Skills/Projectile/Ansatsuken/Hadoken)
					if(!locate(/obj/Skills/Queue/Shoryuken, P))
						P << "You've learned how to release the uppercut of the dragon: <b>Shoryuken</b>!"
						P.AddSkill(new/obj/Skills/Queue/Shoryuken)
					if(!locate(/obj/Skills/AutoHit/Tatsumaki, P))
						P << "You've learned to unleash a mighty whirlwind kick: <b>Tatsumaki</b>!"
						P.AddSkill(new/obj/Skills/AutoHit/Tatsumaki)


				if("Eight Gates")
					P<<"After tirelessly training you finally managed to arrive at the summit of martial arts... <b>Eight Gates</b>!"
					P.Saga="Eight Gates"
					P.SagaLevel=1
					P<<"Your constant hard work shows its effects..."
					// P.SagaThreshold("Str", 0.125)
					// P.SagaThreshold("End", 0.125)
					// P.SagaThreshold("Spd", 0.125)
					P<<"You learn to shatter your natural limitations. Be wary though: the strain of doing that may haunt your future..."
					P.AddSkill(new/obj/Skills/Buffs/ActiveBuffs/Eight_Gates)
					P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/GateOne)
					P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/GateTwo)
					P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/GateThree)
					P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/GateFour)
					P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/GateFive)
					P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/GateSix)
					P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/GateSeven)
					P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/GateEight)
					if(!locate(/obj/Skills/Queue/Front_Lotus, P))
						P.AddSkill(new/obj/Skills/Queue/Front_Lotus)
					if(!locate(/obj/Skills/Buffs/NuStyle/UnarmedStyle/Strong_Fist, P))
						var/obj/Skills/Buffs/NuStyle/s=new/obj/Skills/Buffs/NuStyle/UnarmedStyle/Strong_Fist
						P.AddSkill(s)

				if("Sharingan")
					P.SagaLevel=1
					P.Saga="Sharingan"
					P.AddSkill(new/obj/Skills/AutoHit/Sharingan_Genjutsu)
					P.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Sharingan)
					P.AddSkill(new/obj/Skills/Buffs/NuStyle/UnarmedStyle/Move_Duplication)
					P<<"The curse of hatred blooms in you..."

				if("Shinigami")
					P.gainShinigami()

				if("Kamui")
					P.SagaLevel=1
					P.Saga="Kamui"
					var/choice
					var/confirm
					while(confirm!="Yes")
						choice=alert(P, "What kind of weave do you represent?", "Kamui", "Senketsu", "Junketsu")
						switch(choice)
							if("Senketsu")
								confirm=alert(P, "Senketsu highlights the unity between clothes and humanity, recklessly fighting alongside one another.  Is this your weave?", "Kamui Path", "Yes", "No")
							if("Junketsu")
								confirm=alert(P, "Junketsu highlights humanity's superiority over clothing, using them as protective garment subjugated by your will.  Is this your weave?", "Kamui Path", "Yes", "No")
					P.KamuiType=choice
					if(P.KamuiType=="Senketsu")
						P.contents+=new/obj/Items/Symbiotic/Kamui/KamuiSenketsu
						var/obj/Items/Sword/Medium/Scissor_Blade/SB = new()
						P.AddItem(SB)
						var/ScissorBladeClass = input(P, "What class would you like to set the Scissor Blade to?") in list("Light", "Medium", "Heavy")
						SB.Class = ScissorBladeClass
						SB.setStatLine()
						P << "A sword weaved from fibers finds its way into a case in your care. (Sheath to put it in it's case.)"
						P << "Sheer embarassment washes over you, you feel like if you were to wear this, you'd practically be naked...! You can't even imagine if you had to wear it in front of others..."
						P<<"You are cloaked in unearthly robes... <b>Kamui</b>!"
						P<<"<i>Let's get naked.</i>"

					else if(P.KamuiType=="Junketsu")
						P.contents += new/obj/Items/Sword/Heavy/Secret_Sword_Bakuzan
						P.passive_handler.Increase("CriticalDamage", 0.1)
						P.passive_handler.Increase("CriticalChance", 10)
						P.passive_handler.Increase("CriticalBlock", 0.1)
						P.passive_handler.Increase("BlockChance", 10)
						P.passive_handler.Increase("LikeWater", 2)
						P.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Resolve)
						P<<"With each movement forward towards the realization of your ideals, your resolve strengthens..."

				if("Magic Knight")
					P.SagaLevel=1
					P.Saga="Magic Knight"
					P << "You stake yourself on a code of honor and truthfulness."
					var/Weapon=alert(P, "As an Magic Knight, you may draw a blade made of Aether or create a bow and arrow.  Which do you choose?", "Aether Weapon", "Blade", "Bow")
					switch(Weapon)
						if("Blade")
							if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Spirit_Sword, P))
								P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Spirit_Sword)
								P << "You take up the path of the Aether Blade!"
						if("Bow")
							if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Spirit_Bow, P))
								P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Spirit_Bow)
								P << "You take up the path of the Aether Bow!"
					var/list/Aethers=list("Strength", "Endurance", "Force", "Offense", "Defense")
					var/Aether=input(P, "As your mastery of Aether grows, it heightens one of your attributes at rest.  Which attribute?", "Aether Ascension") in Aethers
					switch(Aether)
						if("Strength")
							P.StrAscension+=0.5
						if("Endurance")
							P.EndAscension+=0.5
						if("Force")
							P.ForAscension+=0.5
						if("Offense")
							P.OffAscension+=0.5
						if("Defense")
							P.DefAscension+=0.5
				if("Force")
					src.ChoseSideOfForce()
					P.Saga="Force"
					P.SagaLevel=1
				if("Path of a Hero: Rebirth")
					P.SagaLevel=1
					P.Saga="Path of a Hero: Rebirth"
					var/list/Choices=list("Blue", "Red","Rainbow")
					var/choice
					var/confirm
					while(confirm!="Yes")
						choice=input(P, "What legacy will you take upon yourself?", "Rebirth Hero") in Choices
						switch(choice)
							if("Blue")
								confirm=alert(P, "You won't give them the chance to strike. You begin your journey to forge a Legend...", "The Unsung Hero of Glory, the one who will engrave their name into history.", "Yes", "No")
							if("Red")
								confirm=alert(P, "You'll bleed, but that only makes you stronger. You set out to defy all expectations...", "The Unsung Hero of Perseverance, the one who will never bend.", "Yes", "No")
							if("Rainbow")
								confirm=alert(P, "Possibility shines, deep within you. Will the world be your playground...?", "The Unsung Hero of Change, the one whose sands are ever-shifting.", "Yes", "No")

					P.SagaLevel=1
					switch(choice)
						if("Blue")
							P.RebirthHeroType="Blue"
							P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Hero_Soul)
						if("Red")
							P.RebirthHeroType="Red"
							P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Hero_Heart)
						if("Rainbow")
							P.RebirthHeroType="Rainbow"
							P.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Prismatic_Hero)
				//	tierUpSaga("Rebirth")

				if("Devil Summoner")
					P.Saga = "Devil Summoner"
					P.SagaLevel = 1
					P.demon_party_cap = 3
					if(!P.demon_party)      P.demon_party      = list()
					if(!P.demon_compendium) P.demon_compendium = list()
					P.verbs += /mob/proc/verb_SummonDemon
					P.verbs += /mob/proc/verb_CallDemon
					P << "You have gained the ability to summon and use existences known as demons... you have become a <b>Devil Summoner</b>!"
					P << "You may carry up to 3 demons. Seek out demons through Potential, then use <b>Summon Demon</b> to call them to your side."
					P << "Meditate for 15 seconds to restore your demons' HP."
					P.GrantStarterDemons(1)

				if("Keyblade")
					var/list/Choices=list("A Sword of Courage", "A Staff of Spirit", "A Shield of Kindness")
					var/choice
					var/confirm
					while(confirm!="Yes")
						choice=input(P, "A weapon is engraved upon every heart.  What lies within yours?", "Keyblade Awakening") in Choices
						switch(choice)
							if("A Sword of Courage")
								confirm=alert(P, "With this, your heart will be dedicated and impulsive.", "A Sword who's strength is Courage. Bravery to stand against anything.", "Yes", "No")
							if("A Staff of Spirit")
								confirm=alert(P, "With this, your heart will be flexible and unrestrained.", "A Staff who's strenth is Spirit. Power the eye cannot see.", "Yes", "No")
							if("A Shield of Kindness")
								confirm=alert(P, "With this, your heart will be able to endure anything for the sake of those you love.", "A Shield who's strength is Kindness. The desire to help one's friends.", "Yes", "No")
					switch(choice)
						if("A Sword of Courage")
							P.KeybladeType="Sword"
						if("A Staff of Spirit")
							P.KeybladeType="Staff"
						if("A Shield of Kindness")
							P.KeybladeType="Shield"
					var/Color=alert(P, "Light or Darkness?", "Keyblade", "Light", "Darkness")
					P.AddSkill(new/obj/Skills/Buffs/ActiveBuffs/Keyblade)
					P.AddSkill(new/obj/Skills/Teleport/Dive_To_Heart)
					P<<"You awaken the [P.KeybladeType] of your heart!"
					P.Saga="Keyblade"
					P.SagaLevel=1
					P.KeybladeColor=Color
					if(P.KeybladeType=="Sword")
						P.ChooseMartialSkill(1)
					if(P.KeybladeType=="Shield")
						var/inp = input(P, "What path of magic will you fall under?") in list("Fire", "Ice", "Thunder")
						P.KeybladePath = inp
						switch(P.KeybladePath)
							if("Fire")
								P.AddSkill(new/obj/Skills/Projectile/Magic/Fire)
							if("Ice")
								P.AddSkill(new/obj/Skills/AutoHit/Magic/Blizzard)
							if("Thunder")
								P.AddSkill(new/obj/Skills/AutoHit/Magic/Thunder)
					if(P.KeybladeType=="Staff")
						P.KeybladePath="Magical"
						P.AddSkill(new/obj/Skills/AutoHit/Magic/Thunder)
						P.AddSkill(new/obj/Skills/AutoHit/Magic/Blizzard)
						P.AddSkill(new/obj/Skills/Projectile/Magic/Fire)
						P << "You've mastered the magical arts!"
					switch(P.KeybladeColor)
						if("Light")
							P.KeychainAttached="Kingdom Key"
							P.SyncAttached="Kingdom Key"
						if("Darkness")
							P.KeychainAttached="Kingdom Key D"
							P.SyncAttached="Kingdom Key D"
			if(passiveGain.len > 0) passive_handler.increaseList(passiveGain);
			Log("Admin","[ExtractInfo(usr)] granted [selection] to [P].")

	Keychain_Add(mob/Players/m in players)
		set category="Admin"
		var/list/Options=glob.Keychains
		for(var/o in m.Keychains)
			Options.Remove(o)
		var/Choice=input(usr, "What keychain do you wish to grant to [m]?", "Heart Share") in Options
		if(Choice=="Cancel")
			return
		m.Keychains.Add(Choice)
		Log("Admin", "[ExtractInfo(usr)] unlocked [Choice] keychain for [ExtractInfo(m)]!")




var
	HiyoriTaken
	IchigoTaken
	KanameTaken
	KenseiTaken
	LisaTaken
	LoveTaken
	MashiroTaken
	RojuroTaken
	ShinjiTaken
	ShowlongTaken
	TousenTaken
proc
	CheckVaizardMasksTaken()
		if(HiyoriTaken&&IchigoTaken&&KanameTaken&&KenseiTaken&&LisaTaken&&LoveTaken&&MashiroTaken&&RojuroTaken&&ShinjiTaken&&ShowlongTaken&&TousenTaken)
			HiyoriTaken=0
			IchigoTaken=0
			KanameTaken=0
			KenseiTaken=0
			LisaTaken=0
			LoveTaken=0
			MashiroTaken=0
			RojuroTaken=0
			ShinjiTaken=0
			ShowlongTaken=0
			TousenTaken=0

mob
	proc
		GetVaizardIcon()
			CheckVaizardMasksTaken()
			var/list/Masks=list('Hiyori.dmi', 'Ichigo.dmi', 'Kaname.dmi', 'Kensei.dmi', 'Lisa.dmi', 'Love.dmi', 'Mashiro.dmi', 'Rojuro.dmi', 'Shinji.dmi', 'Showlong.dmi')
			if(HiyoriTaken)
				Masks.Remove('Hiyori.dmi')
			if(IchigoTaken)
				Masks.Remove('Ichigo.dmi')
			if(KanameTaken)
				Masks.Remove('Kaname.dmi')
			if(KenseiTaken)
				Masks.Remove('Kensei.dmi')
			if(LisaTaken)
				Masks.Remove('Lisa.dmi')
			if(LoveTaken)
				Masks.Remove('Love.dmi')
			if(MashiroTaken)
				Masks.Remove('Mashiro.dmi')
			if(RojuroTaken)
				Masks.Remove('Rojuro.dmi')
			if(ShinjiTaken)
				Masks.Remove('Shinji.dmi')
			if(ShowlongTaken)
				Masks.Remove('Showlong.dmi')
			src.VaizardIcon=pick(Masks)
			if(src.VaizardIcon=='Hiyori.dmi')
				HiyoriTaken=1
			if(src.VaizardIcon=='Ichigo.dmi')
				IchigoTaken=1
			if(src.VaizardIcon=='Kaname.dmi')
				KanameTaken=1
			if(src.VaizardIcon=='Kensei.dmi')
				KenseiTaken=1
			if(src.VaizardIcon=='Lisa.dmi')
				LisaTaken=1
			if(src.VaizardIcon=='Love.dmi')
				LoveTaken=1
			if(src.VaizardIcon=='Mashiro.dmi')
				MashiroTaken=1
			if(src.VaizardIcon=='Rojuro.dmi')
				RojuroTaken=1
			if(src.VaizardIcon=='Shinji.dmi')
				ShinjiTaken=1
			if(src.VaizardIcon=='Showlong.dmi')
				ShowlongTaken=1
/*proc
	GetKeychainClass(var/KC)
		switch(KC)
			if("Kingdom Key")
				return "Wooden"
			if("Kingdom Key D")
				return "Wooden"
			if("Wayward Wind")
				return "Light"
			if("Oathkeeper")
				return "Light"
			if("Way To Dawn")
				return "Light"
			if("Nightwing")
				return "Light"
			if("Rainfell")
				return "Medium"
			if("Oblivion")
				return "Medium"
			if("No Name")
				return "Medium"
			if("Ultima Weapon")
				return "Medium"
			if("Earthshaker")
				return "Heavy"
			if("Fenrir")
				return "Heavy"
			if("Chaos Ripper")
				return "Heavy"
			if("X-Blade")
				return "Heavy"
	GetKeychainDamage(var/KC)
		switch(KC)
			if("Kingdom Key")
				return 1
			if("Kingdom Key D")
				return 1
			if("Wayward Wind")
				return 1.5
			if("Rainfell")
				return 1.5
			if("Earthshaker")
				return 2
			if("Oathkeeper")
				return -1
			if("Oblivion")
				return 2
			if("Fenrir")
				return 2
			if("No Name")
				return 1
			if("Way To Dawn")
				return 1.5
			if("Chaos Ripper")
				return 2
			if("Ultima Weapon")
				return 2
			if("Nightwing")
				return 1.5
			if("X-Blade")
				return 3
	GetKeychainAccuracy(var/KC)
		switch(KC)
			if("Kingdom Key")
				return 0
			if("Kingdom Key D")
				return 0
			if("Wayward Wind")
				return 0
			if("Rainfell")
				return -1
			if("Earthshaker")
				return -1
			if("Oathkeeper")
				return -1
			if("Oblivion")
				return -1
			if("Fenrir")
				return -2
			if("No Name")
				return -2
			if("Way To Dawn")
				return -1
			if("Chaos Ripper")
				return 0
			if("Ultima Weapon")
				return 1.25
			if("X-Blade")
				return 1.5
			if("Nightwing")
				return 2
	GetKeychainDelay(var/KC)
		switch(KC)
			if("Kingdom Key")
				return 1
			if("Kingdom Key D")
				return 1
			if("Wayward Wind")
				return 2
			if("Rainfell")
				return 1
			if("Earthshaker")
				return 0
			if("Oathkeeper")
				return 2
			if("Oblivion")
				return -1
			if("Fenrir")
				return -2
			if("No Name")
				return 0
			if("Way To Dawn")
				return 0
			if("Chaos Ripper")
				return 0
			if("Ultima Weapon")
				return 1
			if("X-Blade")
				return 0
			if("Nightwing")
				return 2
	GetKeychainElement(var/KC)
		switch(KC)
			if("Kingdom Key")
				return 0
			if("Kingdom Key D")
				return 0
			if("Wayward Wind")
				return "Wind"
			if("Rainfell")
				return "Water"
			if("Earthshaker")
				return "Earth"
			if("Oathkeeper")
				return "Light"
			if("Oblivion")
				return "Dark"
			if("Fenrir")
				return 0
			if("No Name")
				return "Void"
			if("Way To Dawn")
				return 0
			if("Chaos Ripper")
				return "Fire"
			if("Ultima Weapon")
				return "Love"
			if("X-Blade")
				return "Ultima"
			if("Nightwing")
				return "Truth"
	GetKeychainIcon(var/KC)
		switch(KC)
			if("Kingdom Key")
				return 'KingdomKey.dmi'
			if("Kingdom Key D")
				return 'KingdomKeyD.dmi'
			if("Wayward Wind")
				return 'WaywardWind.dmi'
			if("Rainfell")
				return 'Rainfell.dmi'
			if("Earthshaker")
				return 'Earthshaker.dmi'
			if("Oathkeeper")
				return 'Oathkeeper.dmi'
			if("Oblivion")
				return 'Oblivion.dmi'
			if("Fenrir")
				return 'Fenrir.dmi'
			if("No Name")
				return 'NoName.dmi'
			if("Way To Dawn")
				return 'WayToTheDawn.dmi'
			if("Chaos Ripper")
				return 'ChaosRipper.dmi'
			if("Ultima Weapon")
				return 'Ultima Keyblade.dmi'
			if("X-Blade")
				return 'X-Blade NEOBIG.dmi'
	GetKeychainIconReversed(var/KC)
		switch(KC)
			if("Kingdom Key")
				return 'KingdomKeySync.dmi'
			if("Kingdom Key D")
				return 'KingdomKeySync.dmi'
			if("Wayward Wind")
				return 'WaywardWindSync.dmi'
			if("Rainfell")
				return 'RainfellSync.dmi'
			if("Earthshaker")
				return 'EarthshakerSync.dmi'
			if("Oathkeeper")
				return 'OathkeeperSync.dmi'
			if("Oblivion")
				return 'OblivionSync.dmi'
			if("Fenrir")
				return 'FenrirSync.dmi'
			if("No Name")
				return 'NoNameSync.dmi'
			if("Way To Dawn")
				return 'WayToTheDawnSync.dmi'
			if("Chaos Ripper")
				return 'ChaosRipperSync.dmi'
*/
mob
	proc
		GetPersonaPoints()
			var/Points=0
			if(src.PersonaStrength)
				Points+=src.PersonaStrength
			if(src.PersonaEndurance)
				Points+=src.PersonaEndurance
			if(src.PersonaSpeed)
				Points+=src.PersonaSpeed
			if(src.PersonaForce)
				Points+=src.PersonaForce
			if(src.PersonaOffense)
				Points+=src.PersonaOffense
			if(src.PersonaDefense)
				Points+=src.PersonaDefense
			if(src.PersonaRegeneration)
				Points+=src.PersonaRegeneration
			if(src.PersonaRecovery)
				Points+=src.PersonaRecovery
			return Points
		AssignPowerPersonaPoints()
			var/list/Stats=list("Strength", "Endurance", "Speed", "Offense", "Defense")
			var/Pick=pick(Stats)
			switch(Pick)
				if("Strength")
					src.PersonaStrength+=0.5
					src.PersonaOffense+=0.5
				if("Endurance")
					src.PersonaEndurance+=0.5
					src.PersonaDefense+=0.5
				if("Speed")
					src.PersonaOffense+=0.5
					src.PersonaSpeed+=0.5
				if("Offense")
					src.PersonaEndurance+=0.5
					src.PersonaOffense+=0.5
				if("Defense")
					src.PersonaStrength+=0.5
					src.PersonaDefense+=0.5
		AssignSkillPersonaPoints()
			var/list/Stats=list("Speed", "Force", "Offense", "Defense", "Regeneration")
			var/Pick=pick(Stats)
			switch(Pick)
				if("Speed")
					src.PersonaDefense+=0.5
					src.PersonaSpeed+=0.5
				if("Force")
					src.PersonaForce+=0.5
					src.PersonaOffense+=0.5
				if("Offense")
					src.PersonaSpeed+=0.5
					src.PersonaOffense+=0.5
				if("Defense")
					src.PersonaForce+=0.5
					src.PersonaDefense+=0.5
				if("Regeneration")
					src.PersonaRegeneration+=0.5
					src.PersonaSpeed+=0.5
		AssignGimmickPersonaPoints()
			var/list/Stats=list("Strength", "Endurance", "Speed", "Force", "Offense", "Defense", "Regeneration", "Recovery")
			var/Pick=pick(Stats)
			switch(Pick)
				if("Strength")
					src.PersonaStrength+=0.5
					src.PersonaOffense+=0.5
				if("Endurance")
					src.PersonaEndurance+=0.5
					src.PersonaDefense+=0.5
				if("Speed")
					src.PersonaOffense+=0.5
					src.PersonaSpeed+=0.5
				if("Force")
					src.PersonaForce+=0.5
					src.PersonaOffense+=0.5
				if("Offense")
					src.PersonaEndurance+=0.5
					src.PersonaOffense+=0.5
				if("Defense")
					src.PersonaForce+=0.5
					src.PersonaDefense+=0.5
				if("Regeneration")
					src.PersonaRegeneration+=0.5
					src.PersonaSpeed+=0.5
				if("Recovery")
					src.PersonaDefense+=0.5
					src.PersonaRecovery+=0.5
mob
	proc
		saga_up_self()
			if(!src.SagaAdminPermission)
				if(src.SagaLevel>=6)
					return
				if(!src.SignatureCheck)
					return
			else
				if(src.SagaLevel>=6)
					src << "You've been bestowed an additional tier of your Saga purposefully; enjoy your new powers, this is not a bug!"

			src.SagaLevel++
			src.SagaEXP=0
			src.SagaAdminPermission--
			if(src.SagaAdminPermission<0)
				src.SagaAdminPermission=0

			switch(src.Saga)
				if("Hero")
					tierUpSaga("Hero")
				if("Path of a Hero: Rebirth")
					switch(SagaLevel)
						if(2)
							var/list/Choices=list("Prophesized Hero", "Unsung Hero")
							var/choice
							var/confirm
							while(confirm!="Yes")
								choice=input(src, "Are you the hero spoken of in legends? Or has your story yet to be written?", "Hero Path") in Choices
								switch(choice)
									if("Unsung Hero")
										confirm=alert(src, "You remain the hero nobody knows, but one day, your name will be its own legend.", "The Unsung Hero, a story yet to be written.", "Yes", "No")
									if("Prophesized Hero")
										confirm=alert(src, "A story told in glass, a tragedy written into time and space.", "The Hero of Prophecy, chosen by fate.", "Yes", "No")
							src.SagaLevel=2
							src<<"Unwavering courage wells up within you! You have unlocked the ACT meter!"
							switch(choice)
								if("Unsung Hero")
									src.RebirthHeroPath="Unsung"
									if(src.RebirthHeroType=="Blue")
										src.AddSkill(new/obj/Skills/Queue/NeverKnowsBest)
										src.AddSkill(new/obj/Skills/Projectile/Rude_Buster)
									if(src.RebirthHeroType=="Red")
										src.AddSkill(new/obj/Skills/Utility/NeverTooLate)
										src.passive_handler.Increase("Determination")
										src.passive_handler.Increase("Determination(Red)")
										src<< "Your ACT meter slows, but as it builds, a certain power wells up within you..."
										src<< "You unlock the Red SOUL color, boosting your crit rate as you gain ACT!"
										src.AddSkill(new/obj/Skills/AutoHit/Scream_of_Fury)
									if(src.RebirthHeroType=="Rainbow")
										src.AddSkill(new/obj/Skills/AutoHit/NeverSeeItComing)
										src.AddSkill(new/obj/Skills/Projectile/Beams/TasteTheRainbow)
										src<< "nyoro~n :3c"
									src.AddSkill(new/obj/Skills/Utility/NeverTooEarly)
								if("Prophesized Hero")
									src.RebirthHeroPath="Prophesized"
									if(src.RebirthHeroType=="Blue")
										src.RebirthHeroType="Cyan"
										src<< "You are now the Cyan Hero of Soul, a cage for a human SOUL. Your ACT meter slows, but as it builds, a certain power wells up within you..."
										src.passive_handler.Increase("Determination")
										src.AddSkill(new/obj/Skills/Utility/SoulShift)
										src<<"You unlock the Red SOUL color, boosting your crit rate as you gain ACT!"
										src<<"You unlock the Yellow SOUL color, granting your melee attacks projectiles!!"
										src.AddSkill(new/obj/Skills/Buffs/Rebirth/Spookysword)
									if(src.RebirthHeroType=="Red")
										src.RebirthHeroType="Purple"
										src<< "You are now the Purple Hero of Hope, who attacks with dark energy."
										src<< "You gain the Rude Buster ability, a homing blast that requires 50% ACT and cannot miss. You also gain Red Buster, a stronger version of Rude Buster that can only be used if you have a Cyan Hero of Soul in your party."
										src.AddSkill(new/obj/Skills/Projectile/Rude_Buster)
										src.AddSkill(new/obj/Skills/Projectile/Red_Buster)
										src.AddSkill(new/obj/Skills/Buffs/Rebirth/Devilsknife)
										src.AddSkill(new/obj/Skills/Utility/UltimateHeal)
										src<<"You can also attempt to heal people, but the keyword is attempt."
									if(src.RebirthHeroType=="Rainbow")
										src.RebirthHeroType="Prismatic"
										src<<"You are now the Prismatic Hero of Dreams, emboldened by Hearts beating as One. (WIP)"
										src<<"Swap between Chaos Saber and Chaos Buster to fight at close range or at range!"
										src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/ChaosSaber)
										src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/ChaosBuster)
										src.AddSkill(new/obj/Skills/AutoHit/Shocker_Breaker)
										src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Hyperdeath_Mode)
						if(3)
							src.SagaLevel=3
							if(src.RebirthHeroType=="Cyan")
								src<< "You have unlocked the green SOUL color, which reduces the damage you take as you build ACT. You also gain the BlackShard, a small weapon that can hardly be considered one, but carries great power..."
								src.AddSkill(new/obj/Skills/Utility/SoulShiftGreen)
								src.AddSkill(new/obj/Skills/Utility/SoulShiftOrange)
								src.AddSkill(new/obj/Skills/Buffs/Rebirth/BlackShard)
								src.AddSkill(new/obj/Skills/AutoHit/Unleash)
							if(src.RebirthHeroType=="Purple")
								src<< "Your story has finally come into its own. You have become the Axe of Justice, with hope crossed on your heart."
								src.AddSkill(new/obj/Skills/Buffs/Rebirth/JusticeAxe)
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Axe_of_Justice)
							if(src.RebirthHeroType=="Blue")
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Shining_Star)
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/The_Blue_Experience)
							if(src.RebirthHeroType=="Red")
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Unwavering_Soul)
								src.AddSkill(new/obj/Skills/Queue/FistOfTheRedStar)
								src.AddSkill(new/obj/Skills/Projectile/Beams/Unbelievable_Rage)
							if(src.RebirthHeroType=="Rainbow")
								src.AddSkill(new/obj/Skills/AutoHit/PowerWordGenderDysphoria)
								src.AddSkill(new/obj/Skills/Grapple/CHAOS_DUNK)
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Hero_Of_Chaos)
							if(src.RebirthHeroType=="Prismatic")
								src<< "Your Chaos Saber can now fire projectiles! These still cost ACT to use."
								src<< "Your Chaos Buster has been upgraded!"
						if(4)
							src.SagaLevel=4
							if(src.RebirthHeroType=="Cyan")
								src<<"The special power you wield grows stronger, heightening the strength of your SOUL colors."
								src<<"You have gained Banish."
								src.AddSkill(new/obj/Skills/AutoHit/Banish)
								src.AddSkill(new/obj/Skills/Utility/SoulShiftPurple)
							if(src.RebirthHeroType=="Purple")
								src<<"<font color='#9BFD4D'><b>I see a story hidden in your eyes.</font></b>" //i literally extracted the mod files for gerson's rude buster to make sure this color was as accurate as possible. praise me.
								src<<"<font color='#9BFD4D'><b>Burnin' bright...</font></b>"
								src.passive_handler.Increase("HolyMod" = 3)
								src.AddSkill(new/obj/Skills/Projectile/Burning_Black)
								src<<"<font color='#9BFD4D'><b>Burnin' black...</font></b>"
								src.AddSkill(new/obj/Skills/AutoHit/Burning_Up_Everything)
								src<<"<font color='#9BFD4D'><b>Burnin' up everything.</font></b>"
							if(src.RebirthHeroType=="Rainbow")
								src<<"Surprise! You're a woman now. RP accordingly."
								if(src.Gender=="Female")
									src<<"Oh, wait, you were before? Well, surprise! You're transfem now and have been all along. Good job on the voice training."
								if(src.Gender=="Neuter")
									src<<"Oh, you didn't have a gender before now? Well, congrats! Now you do! Now go burn down a forest over it."
								src.Gender="Female"
								src.AddSkill(new/obj/Skills/Projectile/Zone_Attacks/Final_Chaos)
							if(src.RebirthHeroType=="Blue")
								src.AddSkill(new/obj/Skills/AutoHit/MakeItCount)
							if(src.RebirthHeroType=="Red")
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Burning_Soul)
							if(src.RebirthHeroType=="Prismatic")
								src<<"You now wield two Chaos Sabers at once!"
						if(5)
							src.SagaLevel=5
							if(src.RebirthHeroType=="Blue")
								src.AddSkill(new/obj/Skills/Buffs/Rebirth/CrownlessKing)
							if(src.RebirthHeroType=="Red")
								src.AddSkill(new/obj/Skills/Buffs/Rebirth/ComebackKing)
							if(src.RebirthHeroType=="Rainbow")
								src.AddSkill(new/obj/Skills/Buffs/Rebirth/ChaosQueen)
							if(src.RebirthHeroType=="Cyan")
								var/list/Choices=list("Roaring Knight", "White Pen of Hope")
								var/choice
								var/confirm
								while(confirm!="Yes")
									choice=input(src, "Will you bring your tragic fate to fruition? Or will you face it with courage?", "Hero Path") in Choices
									switch(choice)
										if("Roaring Knight")
											confirm=alert(src, "A tragedy taken into your own hands. A bringer of the end.", "The Roaring Knight, a bringer of the end.", "Yes", "No")
										if("White Pen of Hope")
											confirm=alert(src, "Fate accepted, yet change made possible through others", "The White Pen of Hope, author of a new story..", "Yes", "No")
									src.FinalHeroChoice=choice
								if(src.FinalHeroChoice=="Roaring Knight")
									src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/The_Roaring_Knight)
									src.AddSkill(new/obj/Skills/Buffs/Rebirth/BlackKnife)
									src.AddSkill(new/obj/Skills/Buffs/Slotless/Rebirth/RefractiveArmor)
								if(src.FinalHeroChoice=="White Pen of Hope")
									src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/White_Pen_Of_Hope)
									src.AddSkill(new/obj/Skills/Buffs/Rebirth/White_Pen_of_Hope)
							if(src.RebirthHeroType=="Purple")
								src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Justice_Incarnate)
							if(src.RebirthHeroType=="Prismatic")
								src<< "Your happy ending... Your hopes, your dreams..."
								src<< "It's not just those you're carrying on your back, are they?"
								src<< "<buff goes here>"
						if(6)
							src.SagaLevel=6
							if(src.RebirthHeroType=="Cyan")
								if(src.FinalHeroChoice=="White Pen of Hope")
									src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Banish_The_ANGELS_HEAVEN)
								if(src.FinalHeroChoice=="Roaring Knight")
									src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Blanket_The_World_In_Darkness)
							if(src.RebirthHeroType=="Purple")
								src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Shatter_The_Glass_Of_Fate)
							if(src.RebirthHeroType=="Red")
								src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Glory_To_The_Comeback_King)
								src<<"You are defiance incarnate; Hail the Comeback King."
							if(src.RebirthHeroType=="Blue")
								src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/All_Hail_The_Crownless_King)
								src<< "You have become a Fighter of Legend; Glory to the Crownless King."
							if(src.RebirthHeroType=="Prismatic")
								src<< "The Hearts of the World resonate with Yours."
								src<< "final buff goes here wooo"
				if("Cosmo")
					tierUpSaga("Cosmo")
				if("Shinigami")
					tierUpSaga("Shinigami")

				if("Weapon Soul")
					tierUpSaga("Weapon Soul")

				if("Devil Summoner")
					tierUpSaga("Devil Summoner")

				if("Unlimited Blade Works")
					switch(src.SagaLevel)
						if(2)
							if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Magic/Reinforce_Object, src))
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Magic/Reinforce_Object)
							src<<"You can reinforce any blade, regardless of your magical skill."
							src<< "You grasp the understanding of a legendary weapon forgotten to time..."
							UBWLegendaryWeapon()
						if(3)
							var/choice
							var/confirm
							while(confirm!="Yes")
								choice=input(src, "What kind of path do you take on your wretched path of blades?") in list ("Feeble","Strong","Firm")
								switch(choice)
									if("Feeble")
										confirm=alert(src, "The path of Feebleness matters on lurching towards the future, pushing yourself past your limits to achieve your own selfish ideals of protecting those dear to you. Is this your path?", "UBW Path", "Yes", "No")
									if("Strong")
										confirm=alert(src, "The path of the Strong strengthens your foundations, letting the user push forward despite all odds with a baseline mastery of their skills the other paths cannot boast. Is this your path?", "UBW Path", "Yes", "No")
									if("Firm")
										confirm = alert(src, "The path of Firmness is one forged by remaining on your convictions, caring, and yet remaining ever selfless. A amount of durability the other two paths cannot boast due to the amount of steel in your spine. Is this your path?", "UBW Path", "Yes", "No")
							src.UBWPath = choice
							var/ariaStored
							for(var/obj/Skills/Buffs/SlotlessBuffs/Aria_Chant/s in src.contents)
								ariaStored = s.Aria[4]
								s.Aria.Cut(4,5)
							switch(UBWPath)
								if("Feeble")
								//	if(!locate(/obj/Items/Symbiotic/Shroud_of_Martin, src))
									//	src.contents += new/obj/Items/Symbiotic/Shroud_of_Martin
									src << "Your arm sears and burns, sizzling as it grows darker before stopping..."
									src << "KNOWLEDGE barrages your mind, thousands, hundreds of thousands, more, of blades hammer and assault your mind."
									src << "Your circuits begin heating up, coiling in your chest before --"
									src << "A red piece of cloth wraps around your arm, sealing off your ability to call on more then you can chew."
									src << "Though, you can always pull part of it off for increased access..."
									for(var/obj/Skills/Buffs/SlotlessBuffs/Aria_Chant/s in src.contents)
										s.Aria.Add("Unaware of loss.")
										s.Aria.Add("Nor aware of gain.")
										s.Aria.Add("Withstood pain to protect what is dear to me.")
										s.Aria.Add("My dream has died, yet my life has only just started.")
										s.Aria.Add("My whole life is Unlimited Blade Works.")
								if("Strong")
									src << "You feel your experience hone itself into results."
									src << "Practice, experience, understanding of yourself and your limits leads to a unprecedented level of efficency."
									for(var/obj/Skills/Buffs/SlotlessBuffs/Aria_Chant/s in src.contents)
										s.Aria.Add("Unknown to Death,")
										s.Aria.Add("Nor known to Life.")
										s.Aria.Add("Have withstood pain to create many weapons.")
										s.Aria.Add("But yet, those hands will never hold anything.")
										s.Aria.Add("So as I pray, Unlimited Blade Works.")
									src<< "You grasp the understanding of a legendary weapon forgotten to time because of your self-honing..."
									UBWLegendaryWeapon()
								if("Firm")
									for(var/obj/Skills/Buffs/SlotlessBuffs/Aria_Chant/s in src.contents)
										s.Aria.Add("Unaware of loss.")
										s.Aria.Add("Nor aware of gain.")
										s.Aria.Add("Withstood pain to create weapons, waiting for one's arrival.")
										s.Aria.Add("I have no regrets, this is the only path.")
										s.Aria.Add("My whole life was Unlimited Blade Works.")
							for(var/obj/Skills/Buffs/SlotlessBuffs/Aria_Chant/s in src.contents)
								s.Aria[4] = ariaStored
							if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Magic/Broken_Phantasm, src))
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Magic/Broken_Phantasm)
							src<<"You can overreinforce any blade due to your mastery with Broken Phantasm."

						if(4)
							src<< "You grasp the understanding of a legendary weapon forgotten to time..."
							//todo: study summon system & add src as a psuedo t1-3 summon that can piggyback off of summoner's mana to fuel them as they exist, then ubw users mana until they hit 50% and unsummon.
							UBWLegendaryWeapon()
							// src.SagaThreshold("Str", 0.25*src.SagaLevel)
							// src.SagaThreshold("End", 0.25*src.SagaLevel)
							// src.SagaThreshold("Spd", 0.25*src.SagaLevel)
							// src.SagaThreshold("Off", 0.25*src.SagaLevel)
							// src.SagaThreshold("Def", 0.25*src.SagaLevel)
							switch(UBWPath)
								if("Feeble")
									passive_handler.Increase("Tenacity")
								if("Strong")
									// passive_handler.Increase("Desperation")
									passive_handler.Increase("WeaponBreaker")
								if("Firm")
									passive_handler.Increase("DebuffResistance",0.5)
									passive_handler.Increase("PureReduction",2)
						if(5)
							Adaptation += 0.5
							src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Minds_Eye)
							switch(UBWPath)
								if("Feeble")
									passive_handler.Increase("Tenacity", 2)
									passive_handler.Increase("Adrenaline")
									passive_handler.Increase("DeathField", 2)
								if("Strong")
									src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/WillofAlaya)
								if("Firm")
									passive_handler.Increase("SpiritFlow",0.5)
									passive_handler.Increase("DeathField", 2)
									passive_handler.Increase("VoidField", 2)

						if(6)
							// src.SagaThreshold("Str", 0.25*src.SagaLevel)
							// src.SagaThreshold("End", 0.25*src.SagaLevel)
							// src.SagaThreshold("Spd", 0.25*src.SagaLevel)
							// src.SagaThreshold("Off", 0.25*src.SagaLevel)
							// src.SagaThreshold("Def", 0.25*src.SagaLevel)
							passive_handler.Increase("GodKi", 0.5)
							UBWLegendaryWeapon()
							src<< "You grasp the understanding of a legendary weapon forgotten to time..."


				if("Hiten Mitsurugi-Ryuu") tierUpSaga("Hiten Mitsurugi-Ryuu");
				if("Ansatsuken")
					if(src.SagaLevel>=1&&src.SagaLevel<4)
						if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Satsui_Infected, src))
							if(prob(glob.SATSUICHANCE))
								src << "Your drive for victory sometimes overwhelms you..."
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Satsui_Infected)
					passive_handler.Increase("SlayerMod",0.5)
					if(src.SagaLevel>=2)
						if(!locate(/obj/Skills/Projectile/Ansatsuken/Hadoken_EX, src))
							src.AddSkill(new/obj/Skills/Projectile/Ansatsuken/Hadoken_EX)
						if(!locate(/obj/Skills/Queue/EX_Shoryuken, src))
							src.AddSkill(new/obj/Skills/Queue/EX_Shoryuken)
						if(!locate(/obj/Skills/AutoHit/EX_Tatsumaki, src))
							src.AddSkill(new/obj/Skills/AutoHit/EX_Tatsumaki)
					if(src.SagaLevel==2)
						src<<"Your Ansatsuken becomes refined enough to use EX versions of your abilities! Remember: every EX version costs 25 Meter."
						if(!src.AnsatsukenPath)
							src.AnsatsukenPath=alert(src, "You have refined your abilities to excel in one area of Ansatsuken...But what area?", "Ansatsuken Path", "Hadoken", "Shoryuken", "Tatsumaki")
						switch(src.AnsatsukenPath)
							if("Hadoken")
								src << "Your Hadoken and EX-Hadoken improve!"
								for(var/obj/Skills/Buffs/NuStyle/UnarmedStyle/Ansatsuken_Style/ans in src)
									ans.Finisher="/obj/Skills/Queue/Finisher/Isshin"
									src << "You learn to perform the special finisher: Isshin!"
							if("Shoryuken")
								src << "Your Shoryuken and EX-Shoryuken improve!"
								for(var/obj/Skills/Buffs/NuStyle/UnarmedStyle/Ansatsuken_Style/ans in src)
									ans.Finisher="/obj/Skills/Queue/Finisher/Shin_Shoryuken"
									src << "You learn to perform the special finisher: Shin Shoryuken!"
							if("Tatsumaki")
								src << "Your Tatsumaki and EX-Tatsumaki improve!"
								for(var/obj/Skills/Buffs/NuStyle/UnarmedStyle/Ansatsuken_Style/ans in src)
									ans.Finisher="/obj/Skills/Queue/Finisher/Shippu_Jinraikyaku"
									src << "You learn to perform the special finisher: Shippu Jinraikyaku!"
					if(src.SagaLevel==3)
						switch(src.AnsatsukenPath)
							if("Hadoken")
								if(!locate(/obj/Skills/Projectile/Ansatsuken/Shinku_Hadoken, src))
									src << "You've developed almighty energy projection: Shinku Hadoken!"
									src.AddSkill(new/obj/Skills/Projectile/Ansatsuken/Shinku_Hadoken)
							if("Shoryuken")
								if(!locate(/obj/Skills/Queue/Shinryureppa, src))
									src << "You've developed peerless coordination: Shinryureppa!"
									src.AddSkill(new/obj/Skills/Queue/Shinryureppa)
							if("Tatsumaki")
								if(!locate(/obj/Skills/AutoHit/ShinkuTatsumaki, src))
									src << "You've developed domineering aerial power: Shinku Tatsumaki!"
									src.AddSkill(new/obj/Skills/AutoHit/ShinkuTatsumaki)
					if(src.SagaLevel==4)
						if(!src.AnsatsukenAscension)
							src.AnsatsukenAscension=alert(src, "The time has come to decide the fate of your soul.  Will you give everything away for victory or hold on to your sanity at the price of becoming a fighting machine?", "Ansatsuken Ascension", "Satsui", "Chikara")
							src <<"Your Ansatsuken stance is refined to suit your beliefs..."
							var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Satsui_Infected/SI = new()
							SI = locate() in src
							if(src.AnsatsukenAscension=="Satsui")
								if(!SI)
									src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Satsui_no_Hado)
								else
									del SI
									src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Satsui_no_Hado)
							else
								for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Satsui_Infected/S in src.contents)
									del S
									src << "You learn to harness your raging desire to dominate in battle."
									src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Kyoi_no_Hado)
					if(src.SagaLevel==5)
						switch(src.AnsatsukenAscension)
							// if("Satsui")
							// 	src << "Your lust for victory grows...you'll even sacrifice your soul."
							// 	for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Satsui_Infected/SI in src.contents)
							// 		SI.NeedsHealth=0
							// 		SI.NeedsAnger=1
							// 		SI.VaizardHealth=0
							// 		SI.ActiveMessage="projects a murderous aura fueled only by the desire for victory!"
							// 		SI.OffMessage="conceals their murderous intent..."
							if("Chikara")
								src << "You've refined your discipline to the point of controlling the electricity coursing through you body..."
								if(!locate(/obj/Skills/Buffs/SpecialBuffs/Denjin_Renki, src))
									src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Denjin_Renki)
						src << "Your abilities with Ansatsuken allow you to rival any foe!"
						switch(src.AnsatsukenAscension)
							if("Satsui")
								src <<"Your rage grows and hones into a new attack!"
								var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Satsui_no_Hado/SI = new()
								SI = locate() in src
								if(SI)
									SI.NeedsHealth=0
									SI.TooMuchHealth = 0
									SI.NeedsAnger=1
									SI.VaizardHealth=0
									SI.ActiveMessage="emits pure killing intent in an aura around them, striving for victory at any cost!"
									SI.OffMessage="conceals their murderous intent..."
								switch(src.AnsatsukenPath)
									if("Hadoken")
										if(!locate(/obj/Skills/Projectile/Ansatsuken/Tenma_Gozanku, src))
											src << "You master a crushing barrage of projectiles: Tenma Gozanku!"
											src.AddSkill(new/obj/Skills/Projectile/Ansatsuken/Tenma_Gozanku)
									if("Shoryuken")
										if(!locate(/obj/Skills/Queue/Messatsu_Goshoryu, src))
											src << "You master a combination of strikes: Messatsu Goshoryu!"
											src.AddSkill(new/obj/Skills/Queue/Messatsu_Goshoryu)
									if("Tatsumaki")
										if(!locate(/obj/Skills/AutoHit/Demon_Armageddon, src))
											src << "You master a whirlwind of kicks: Demon Armageddon!"
											src.AddSkill(new/obj/Skills/AutoHit/Demon_Armageddon)
							if("Chikara")
								if(!locate(/obj/Skills/Projectile/Ansatsuken/Denjin_Hadoken, src))
									src << "Your internal harmony can be expressed with indiscriminate energy projection: Denjin Hadoken!"
									src.AddSkill(new/obj/Skills/Projectile/Ansatsuken/Denjin_Hadoken)
					if(src.SagaLevel==6)
						switch(src.AnsatsukenAscension)
							if("Satsui")
								for(var/obj/Skills/Buffs/NuStyle/UnarmedStyle/Ansatsuken_Style/ans in src)
									ans.Finisher="/obj/Skills/Queue/Finisher/Rakan_Dantojin"
									src << "You finisher has evolved into the ultimate murder technique: Shun Goku Satsu!"
								for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Satsui_Infected/SI in src.contents)
									src << "The demonic impulses of the Satsui no Hado have completely overtaken you."
									SI.ManaGlow="#f000e4"
									SI.ElementalOffense="Dark"
									SI.ActiveMessage="loses all shreds of humanity to become evil incarnate!"
									SI.OffMessage="barely represses their demonic power..."
							if("Chikara")
								src << "You learn of peace through fighting and become capable of utilizing the Power of Nothingness."

				if("Sharingan")
					if(src.SagaLevel==2)
						src<<"Your Sharingan's total recall allows you to master common techniques near instantly."
					if(src.SagaLevel==4)
						if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Mangekyou_Sharingan, src))
							src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Mangekyou_Sharingan)
							src << "Your sharingan has matured into a Mangekyou Sharingan!"
						var/Choice=input(src, "What kind of emotion made it mature into that form?") in list("Resolve", "Sacrifice", "Hatred")
						if(Choice)
							src.SharinganEvolution=Choice
						if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Susanoo, src))
							src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Susanoo)
							src << "You can manifest a ghastly armor to protect and augment your attacks!"
					if(src.SagaLevel==6)
						if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Rinnegan2, src))
							src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Rinnegan2)
							src << "Your Mangekyo has matured into the eyes of the sage -- Rinnegan!"

				if("Eight Gates")
					// src.SagaThreshold("Str", 0.125*src.SagaLevel)
					// src.SagaThreshold("End", 0.125*src.SagaLevel)
					// src.SagaThreshold("Spd", 0.125*src.SagaLevel)
					if(src.SagaLevel==3)
						if(!locate(/obj/Skills/Queue/Reverse_Lotus, src))
							src.AddSkill(new/obj/Skills/Queue/Reverse_Lotus)
							src << "You learned how to unleash the full might of your body in a devastating sequence of strikes: <b>Reverse Lotus</b>!!!"
						if(!locate(/obj/Skills/Buffs/NuStyle/UnarmedStyle/Stronger_Fist, src))
							var/obj/Skills/Buffs/NuStyle/s=new/obj/Skills/Buffs/NuStyle/UnarmedStyle/Stronger_Fist
							src.AddSkill(s)
					if(src.SagaLevel==4)
						if(!locate(/obj/Skills/Queue/Morning_Peacock, src))
							src.AddSkill(new/obj/Skills/Queue/Morning_Peacock)
							src << "You can perform a barrage of strikes that burn away the very air: <b>Morning Peacock</b>!!!"
					if(src.SagaLevel==5)
						if(!locate(/obj/Skills/Projectile/Beams/Big/Eight_Gates/Daytime_Tiger, src))
							src.AddSkill(new/obj/Skills/Projectile/Beams/Big/Eight_Gates/Daytime_Tiger)
							src << "You can release a wave of pure kinetic force that devours all in its path: <b>Daytime Tiger</b>!!!"
						if(!locate(/obj/Skills/Buffs/NuStyle/UnarmedStyle/Strongest_Fist, src))
							var/obj/Skills/Buffs/NuStyle/s=new/obj/Skills/Buffs/NuStyle/UnarmedStyle/Strongest_Fist
							src.AddSkill(s)
					if(src.SagaLevel==6)
						if(!locate(/obj/Skills/Projectile/Evening_Elephant, src))
							src.AddSkill(new/obj/Skills/Projectile/Evening_Elephant)
							src << "You can unleash a powerful combination that shakes the foundations of earth: <b>Evening Elephant</b>!!!"
					//		if(!locate(/obj/Skills/AutoHit/Night_Guy, src))
					//			src.contents+=new/obj/AutoHit/Night_Guy

				if("King of Braves")
					src << "You've obtained more skill with Machines!"
					passive_handler.Increase("PilotingProwess", 1)
					src.PilotingProwess+=1
					src.CyberizeMod+=0.2
					if(src.SagaLevel==2)
						src.PilotingProwess+=1
						if(!locate(/obj/Skills/Queue/DrillKnee, src))
							src.AddSkill(new/obj/Skills/Queue/DrillKnee)
						src << "You can form an energy drill out of your body, capable of delivering deciding strikes!"
					if(src.SagaLevel==3)
						src.PilotingProwess+=1
						if(!locate(/obj/Skills/AutoHit/Plasma_Hold, src))
							src.AddSkill(new/obj/Skills/AutoHit/Plasma_Hold)
						if(!locate(/obj/Skills/AutoHit/Hell_And_Heaven, src))
							src << "You become capable of delivering the ultimate finishing move: Hell and Heaven!"
							src.AddSkill(new/obj/Skills/AutoHit/Hell_And_Heaven)
					if(src.SagaLevel==4)
						src.PilotingProwess+=2
						if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Dividing_Driver, src))
							src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Dividing_Driver)
						if(!locate(/obj/Skills/AutoHit/Giga_Drill_Breaker, src))
							src.AddSkill(new/obj/Skills/AutoHit/Giga_Drill_Breaker)
						if(!locate(/obj/Skills/AutoHit/Goldion_Hammer, src))
							src.AddSkill(new/obj/Skills/AutoHit/Goldion_Hammer)
						src << "You can spawn a set of power tools strong enough to rupture dimensions: Dividing Driver and Goldion Hammer!"
					if(src.SagaLevel==5)
						src.PilotingProwess+=2
						if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Protect_Wall, src))
							src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Protect_Wall)
						if(!locate(/obj/Skills/Projectile/King_of_Braves/Broken_Phantom, src))
							src.AddSkill(new/obj/Skills/Projectile/King_of_Braves/Broken_Phantom)
						for(var/obj/Skills/Buffs/SlotlessBuffs/Genesic_Brave/gb in src)
							gb.TooMuchHealth=75
						passive_handler.Increase("SpaceWalk", 1)
						passive_handler.Increase("PilotingProwess", 1) //2 Piloting Prowess at T5 instead of 1
						src << "You upgrade your abilities to carry you into the Space Era!"
					if(src.SagaLevel==6)
						src.PilotingProwess+=3
						for(var/obj/Skills/Buffs/SlotlessBuffs/Genesic_Brave/gb in src)
							gb.TooMuchHealth=99
							gb.GodKi=0.5
							gb.passives["GodKi"] = 0.5
						src << "You master using the power of Destruction and Protection simultaneously!"
						src << "Your Heaven and Hell reaches its perfected form: <b>Genesic Heaven and Hell</b>!"
					if(src.SagaLevel==7)
						for(var/obj/Skills/Buffs/SlotlessBuffs/Genesic_Brave/gb in src)
							gb.passives["Color of Courage"] = 1
							src << "True courage manifests, when everything is thought to be lost."
							src << "You are now able to fight past your limits in Genesic!"



				if("Kamui")
					if(src.SagaLevel==2)
						if(src.KamuiType=="Senketsu")
							var/choice
							var/confirm
							while(confirm!="Yes")
								choice=input(src, "You've grown closer to your Kamui than ever before, and now it can take on a new form!  Which one do you choose?", "Kamui Ascension") in list("Kamui Senjin", "Kamui Shippu")
								switch(choice)
									if("Kamui Senjin")
										confirm=alert(src, "Kamui Senjin makes it so that your Kamui can assume a battle ready form, focused on potent strikes and endurance.  Do you wish to gain this form?", "Kamui Senjin", "Yes", "No")
									if("Kamui Shippu")
										confirm=alert(src, "Kamui Shippu makes it so that your Kamui can assume a speedy form, focused on evasion and elusive manuevers.  Do you wish to gain this form?", "Kamui Shippu", "Yes", "No")

							switch(choice)
								if("Kamui Senjin")
									src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Kamui_Senjin)
									AddSkill(new/obj/Skills/Queue/Senjin_Shredder)
									src << "You've attained a new form for your Kamui: Kamui Senjin!"
									src << "You've obtained Senjin Shredder; requiring Senjin active to shred your opponents against your many blades!"

								if("Kamui Shippu")
									src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Kamui_Shippu)
									AddSkill(new/obj/Skills/AutoHit/Shippu_Rush)
									src << "You've attained a new form for your Kamui: Kamui Shippu!"
									src << "You've obtained Shippu Rush; requiring Shippu active to rush your opponents down with your jet-like speed!"

							src << "The stares of others still bother you heavily, but not as much anymore!"
							src << "You can now properly utilize your scissor blade with Decapitation Mode & Sen-i-Soshitsu!"
							src << "You feel as if your blood may boil over at any moment if you get too angry..."
							src << "You begin to find strands of Kamui threads occasionally peeking out of your body..."
							RecovMod *= 2

						else if(src.KamuiType=="Junketsu")
							src << "You gain the means to form an empire!"
							var/name = input(src, "What do you want the empire to be named?") as text
							var/guild/guild = new()
							guild.name = name
							guild.id = ++glob.guildIDTicker
							glob.guilds += guild
							guild.joinGuild(src)
							guild.ownerID = src?:UniqueID
							guild.checkVerbs(src)
							src << "Your empire, [guild.name], is now created."
							src << "You gain the means to assign pieces of life fibers to infuse into your subjects; enough for four roles!"
							AddSkill(new/obj/Skills/Bestow_Life_Fiber/Bestow_Disciplinary_Chair)
							src << "An Disciplinary Committee Chair, someone to take the harshest of assaults at your walls."
							AddSkill(new/obj/Skills/Bestow_Life_Fiber/Bestow_Athletic_Chair)
							src << "An Athletic Committee Chair, someone with the agility to outpace even the fastest."
							AddSkill(new/obj/Skills/Bestow_Life_Fiber/Bestow_Non_Athletic_Chair)
							src << "An Non-Athletic Committee Chair, someone to manage the magic of your empire."
							AddSkill(new/obj/Skills/Bestow_Life_Fiber/Bestow_Information_and_Strategy_Chair)
							src << "An Information & Strategy Committee Chair, someone to manage the technology of your empire."

					if(src.SagaLevel==3)
						if(src.KamuiType=="Senketsu")
							if(locate(/obj/Skills/Buffs/SpecialBuffs/Kamui_Senjin, src))
								src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Kamui_Shippu)
								AddSkill(new/obj/Skills/AutoHit/Shippu_Rush)
								src << "You've attained a new form for your Kamui: Kamui Shippu!"
								src << "You've obtained Shippu Rush; requiring Shippu active to rush your opponents down with your jet-like speed!"

							else if(locate(/obj/Skills/Buffs/SpecialBuffs/Kamui_Shippu, src))
								src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Kamui_Senjin)
								AddSkill(new/obj/Skills/Queue/Senjin_Shredder)
								src << "You've attained a new form for your Kamui: Kamui Senjin!"
								src << "You've obtained Senjin Shredder; requiring Senjin active to shred your opponents against your many blades!"

							src << "You can now tweak the size of the life fibers in your scissor blade to your whim!"
							src << "The stares of others don't bother you so much anymore!"

						else if(src.KamuiType=="Junketsu")
							src << "You gain a set of life fibers donned into an aggressive, hateful thing - Kamui Junketsu."
							contents += new/obj/Items/Symbiotic/Kamui/KamuiJunketsu

					if(src.SagaLevel==4)
						if(src.KamuiType=="Senketsu")
							src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Kamui_Senjin_Shippu)
							src << "Through adapting to your trials and your own impulsive ambition, you've merged the two forms of your Kamui - Senjin Shippu!"
							src << "You feel as if those eyes on your form just bolster you, instead of hamper you! You feel fully in sync with your Kamui!"
							src << "You can now tweak the size of the life fibers in your scissor blade to your whim!"
						else if(src.KamuiType=="Junketsu")
							src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Kamui_Senpu)
							src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Kamui_Senpu_Zanken)
							src << "Kamui Senpu & Senpu Zanken beckon to your imperial will!"
							src << "Though your body may fail you, your ambition will reach across the world!"

					if(src.SagaLevel==5)
						if(src.KamuiType=="Senketsu")
							src << "You've united entirely with your Kamui, and you fight as one with hardly any downsides!"
							src << "Your whole body has become suffused with life fibers - allowing you to regenerate even the most grievous of wounds!"
							passive_handler.Increase("Unstoppable", 1)
							AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Regeneration)
							for(var/obj/Skills/Buffs/SlotlessBuffs/Regeneration/R in src)
								R.RegenerateLimbs=1
							var/obj/Regenerate/deathRegen = new()
							deathRegen.Level = 1
							contents += deathRegen

						else if(src.KamuiType=="Junketsu")
							var/choice
							var/confirm
							while(confirm != "Yes")
								choice = input("Two paths beckon before you; that of Clothes, or that of Rebellion. You may select to see more before confirming.") in list("Clothes", "Rebellion")
								var/confirmText
								if(choice == "Clothes")
									confirmText = "The path of Shinra Koketsu; to devote your existence towards that of subjugating others beneath the glory of Life Fibers. A path that forsakes Junketsu, but enhances the self with all the glory of Life Fibers have to offer."
								if(choice == "Rebellion")
									confirmText = "The path of Junketsu; to show that life fibers are just another thing meant to be brought to heel beneath you. A path that will enhance Junketsu further, pushing the Kamui beyond it's usual limits."
								confirm = input("[confirmText] <br><br>Are you sure about your decision?") in list("Yes", "No")
							if(choice == "Clothes")
								KamuiType = "Shinra Koketsu"
								passive_handler.Increase("Unstoppable", 1)
								AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Regeneration)
								for(var/obj/Skills/Buffs/SlotlessBuffs/Regeneration/R in src)
									R.RegenerateLimbs=1
								if(usr.CheckActive("Life Fiber Override"))
									usr.ActiveBuff.Trigger(usr)
								for(var/obj/Items/Symbiotic/Kamui/KamuiJunketsu/ks in usr)
									if(ks.suffix)
										ks.AlignEquip(usr)
									del ks

							if(choice == "Rebellion")
								src << "Unshatterable, your resolve gains a twofold edge...Your goals are nearly within your grasp."
								src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Resolve)

					if(src.SagaLevel==6)
						if(src.KamuiType=="Senketsu")
							src.RecovMod *= 2
							src << "You gain the ability to unite with your kamui..."
							src.contents+=new/obj/Skills/Buffs/SpecialBuffs/Kamui_Unite
							src << "Your being has merged with life fibers."
						else if(src.KamuiType=="Junketsu")
							src << "Insert cool Flavour Text Here"
							src.contents+=new/obj/Skills/Buffs/SpecialBuffs/Kamui_Unite
							src << "You gain the ability to force your Kamui to unite with you!"
						else if (KamuiType == "Shinra Koketsu")
							contents += new/obj/Items/Symbiotic/Kamui/Shinra_Koketsu
							src << "Your Magnum opus is complete... the power of Shinra Koketsu is your's to command!"
				if("Path of a Hero: Rebirth")

				if("Keyblade")
					if(src.SagaLevel==2)
						src.ChooseKeychain()
				/*		var/Choice2 = prompt("Your mastery of both keyblades and magical elements allows you to refine your command style.  Which style do you develop?", "Command Style", list("Firestorm", "Diamond Dust", "Thunderbolt"))
						switch(Choice2)
							if("Firestorm")
								src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Command/Firestorm_Style)
							if("Diamond Dust")
								src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Command/Diamond_Dust_Style)
							if("Thunderbolt")
								src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Command/Thunderbolt_Style)
						src << "You've obtained the [Choice2] command style!"*/
						switch(src.KeybladeType)
							if("Sword")
								src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Command/Speed_Rave_Style)
								src << "You've developed the focus necessary to move with blistering speeds: <b>Speed Rave Style</b>!"
							if("Shield")
								src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Command/Critical_Impact_Style)
								src << "You've developed the power necessary to make every blow count: <b>Critical Impact Style</b>!"
							if("Staff")
								src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Command/Spell_Weaver_Style)
								src << "You've developed the flexibility necessary to combine spells with swordplay: <b>Spell Weaver Style</b>!"
						switch(src.KeybladePath)
							if("Fire")
								AddSkill(new/obj/Skills/Projectile/Magic/Fira)
							if("Ice")
								AddSkill(new/obj/Skills/AutoHit/Magic/Blizzara)
							if("Thunder")
								AddSkill(new/obj/Skills/AutoHit/Magic/Thundara)
							if("Magical")
								AddSkill(new/obj/Skills/Projectile/Magic/Fira)
								AddSkill(new/obj/Skills/AutoHit/Magic/Blizzara)
								AddSkill(new/obj/Skills/AutoHit/Magic/Thundara)
						if(src.KeybladeType=="Shield")
							src.ChooseMartialSkill(1)

						if(src.KeybladeType=="Sword")
							src.ChooseMartialSkill(1)
							src.ChooseMartialSkill(2)

					if(src.SagaLevel==3)
						//T2 Command Style
						//Keychain
						var/Style
						if(src.KeybladeType=="Sword")
							Style=prompt("Your mastery of both keyblades and magical elements allows you to refine your command style.",  "Which style do you develop?", list("Wingblade", "Cyclone"))
						if(src.KeybladeType=="Shield")
							Style=prompt("Your mastery of both keyblades and magical elements allows you to refine your command style.",  "Which style do you develop?", list("Rock Breaker", "Dark Impulse"))
						if(src.KeybladeType=="Staff")
							Style=prompt("Your mastery of both keyblades and magical elements allows you to refine your command style.",  "Which style do you develop?", list("Ghost Drive", "Blade Charge"))
						switch(Style)
							if("Wingblade")
								src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Command/Wing_Blade_Style)
							if("Cyclone")
								src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Command/Cyclone_Style)
							if("Rock Breaker")
								src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Command/Rock_Breaker_Style)
							if("Dark Impulse")
								src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Command/Dark_Impulse_Style)
							if("Ghost Drive")
								src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Command/Ghost_Drive_Style)
							if("Blade Charge")
								src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Command/Blade_Charge_Style)
						src << "You've obtained the [Style] command style!"
						src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Keyblade_Armor)
						src << "You've obtained your Keyblade armor!"
						if(src.KeybladeType=="Staff")
							src.AddSkill(new/obj/Skills/AutoHit/Magic/Holy)
							src.AddSkill(new/obj/Skills/AutoHit/Magic/Gravity)
						if(src.KeybladeType=="Shield")
							src.AddSkill(new/obj/Skills/AutoHit/Magic/Magnet)
							src.ChooseMartialSkill(2)
							src.ChooseMartialSkill(1)
						if(src.KeybladeType=="Sword")
							src.ChooseMartialSkill(3)
							src.ChooseMartialSkill(2)
							src.ChooseMartialSkill(1)
					/*	switch(KeybladePath)
							if("Magic")
								AddSkill(new/obj/Skills/AutoHit/Magic/Holy)
								AddSkill(new/obj/Skills/AutoHit/Magic/Gravity)
							if("Fire")
								AddSkill(new/obj/Skills/Projectile/Magic/Firaga)
							if("Ice")
								AddSkill(new/obj/Skills/AutoHit/Magic/Blizzaga)
							if("Thunder")
								AddSkill(new/obj/Skills/AutoHit/Magic/Thundaga)*/

					if(src.SagaLevel==4)
						//Valor Form
						//T2 Magic
						if(src.KeybladeColor=="Light")
							if(src.KeybladeType=="Shield")
								src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Valor_Form)
								src.ChooseKeychain()
								src.ChooseMartialSkill(3)
								src.ChooseMartialSkill(2)
								src << "You learn to imbue every action with valor!"
								src << "Use the Attach Keychain verb to set your sync keyblade for Valor Form."
							else if(src.KeybladeType=="Staff")
								src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Wisdom_Form)
								src << "You learn to imbue every action with wisdom!"
							else if(src.KeybladeType=="Sword")
								src.ChooseMartialSkill(4)
								src.ChooseMartialSkill(3)
								src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Limit_Form)
								src << "You have honed your base skillset to its limit, unlocking Limit Form!"
						else
							src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Dark_Mode)
							src << "You can now tap into your inner darkness at will!"
						switch(src.KeybladePath)
							if("Magic")
								AddSkill(new/obj/Skills/AutoHit/Magic/Holy)
								AddSkill(new/obj/Skills/AutoHit/Magic/Gravity)
							if("Fire")
								AddSkill(new/obj/Skills/Projectile/Magic/Firaga)
							if("Ice")
								AddSkill(new/obj/Skills/AutoHit/Magic/Blizzaga)
							if("Thunder")
								AddSkill(new/obj/Skills/AutoHit/Magic/Thundaga)

					if(src.SagaLevel==5)
						if(src.KeybladeColor=="Light")
							src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Master_Form)
							src << "Merging Wisdom and Valor on the path of light, you develop the Master Form!"
							src.Keychains.Add("Prismatic Dreams")
							src << "You have unlocked the Prismatic Dreams keychain, granting you perfect control over your own darkness!"
						else
							src.Keychains.Add("Ebony Slumber")
							src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/SyncBlade)
							src << "You have unlocked the Ebony Slumber keychain, granting you perfect control over your own darkness!"
/*						var/Choice
						var/Confirm
						while(Confirm!="Yes")
							Choice=alert(src, "Every powerful heart stands in opposition to something greater than themselves.  What do you stand against?", "Keychain Ascension", "Destruction", "Emptiness", "Duality")
							switch(Choice)
								if("Destruction")
									Confirm=alert(src, "You'll crush the forces of destruction no matter what it takes.  Is this your antagonism?", "Keychain Ascension", "Yes", "No")
								if("Emptiness")
									Confirm=alert(src, "You'll stand against the feeling of emptiness eternally.  Is this your antagonism?", "Keychain Ascension", "Yes", "No")
								if("Duality")
									Confirm=alert(src, "You'll cut through delusions of duality to follow the pure path of your heart.  Is this your antagonism?", "Keychain Ascension", "Yes", "No")
						switch(Choice)
							if("Destruction")
								src.Keychains.Add("Chaos Ripper")
							if("Emptiness")
								src.Keychains.Add("No Name")
							if("Duality")
								src.Keychains.Add("Way To Dawn")
						src << "You've obtained your antagonism keychain!"*/


					if(src.SagaLevel==6)
						//Final Form
						//More Majjyk
						if(src.KeybladeType=="Shield")
							src.ChooseMartialSkill(4)
							src.ChooseMartialSkill(3)
							src.ChooseMartialSkill(2)
							src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Magic/Curaga)
						else if(src.KeybladeType=="Staff")
							src.AddSkill(new/obj/Skills/AutoHit/Magic/Ultima)
						else if(src.KeybladeType=="Sword")
							src.ChooseMartialSkill(4)
							src.ChooseMartialSkill(4)
							src.ChooseMartialSkill(3)
							src.ChooseMartialSkill(3)

						if(src.KeybladeColor=="Light")
							src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Final_Form)
							src << "The completion of your heart is fulfilled; you can now access your Final and most powerful Form!"
						else if(src.KeybladeColor=="Dark")
							src <<"I'll add something later"
					if(src.SagaLevel==7)
						var/Choice
						var/Confirm
						while(Confirm!="Yes")
							Choice=alert(src, "The greatest power in a heart is the sum of those connected to it. What do your connections mean to you?", "Final Keychain Ascension", "Unity", "Destiny")
							switch(Choice)
								if("Unity")
									Confirm=alert(src, "Your friends are your power. They give you strength, and you, them.", "Final Keychain Ascension", "Yes", "No")
								if("Destiny")
									Confirm=alert(src, "Together you can change the world. Together, you can change fate.", "Final Keychain Ascension", "Yes", "No")
								if("Future")//not in yet
									Confirm=alert(src, "Whatever awaits you, you will challenge together.", "Final Keychain Ascension", "Yes", "No")
						switch(Choice)
							if("Unity")
								src.Keychains.Add("Ultima Weapon")
								src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Command/Ultimate_Form)
							if("Destiny")
								src.Keychains.Add("X-Blade")
								src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Command/Forces_Of_Darkness)
								src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Command/Vector_to_the_Heavens)
							if("Future")
								src.Keychains.Add("Nightwing")
								src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Command/Nachtflugel)

		getAriaCount(pathEffect = 0)
			var/count = AriaCount
			if(!pathEffect)
				if(UBWPath=="Strong")
					count++
			return count

		getUBWCost(modifier)
			var/Aria = getAriaCount(1)
			var/cost = Aria*4 / SagaLevel
			if(UBWPath == "Strong")
				cost *= 0.8
			cost *= modifier
			cost = clamp(0, cost, 100)
			return cost

		UBWLegendaryWeapon()
			var/list/LegendaryWeapons = list("Gae Bolg", "Rho Aias", "Rule Breaker", "Kanshou & Byakuya", "Caladbolg")
			if(locate(/obj/Skills/Buffs/SlotlessBuffs/GaeBolg, src))
				LegendaryWeapons.Remove("Gae Bolg")

			if(locate(/obj/Skills/Buffs/SlotlessBuffs/RuleBreaker, src))
				LegendaryWeapons.Remove("Rule Breaker")

			if(locate(/obj/Skills/Buffs/SlotlessBuffs/Rho_Aias, src))
				LegendaryWeapons.Remove("Rho Aias")

			if(locate(/obj/Skills/Buffs/SlotlessBuffs/KanshouByakuya, src))
				LegendaryWeapons.Remove("Kanshou & Byakuya")

			if(locate(/obj/Skills/Projectile/Zone_Attacks/Caladbolg, src))
				LegendaryWeapons.Remove("Caladbolg")

			if(LegendaryWeapons.len == 0) return
			var/choice
			var/confirm
			while(confirm!="Yes")
				choice=input(src, "What legendary weapon do you wish to take up?") in LegendaryWeapons
				switch(choice)
					if("Gae Bolg")
						confirm=alert(src, "Gae Bolg is a cursed weapon, having a limited number of hits with bonus Slayer & Cursed Wounds, before throwing a undodgable homing projectile.Is this the weapon you want?", "Legendary Weapon", "Yes", "No")
					if("Rule Breaker")
						confirm=alert(src, "Rule Breaker gives the user Cyber Stigma & Mana Menace. Additionally has bulletkill & drains summon timers. Is this the weapon you want?", "Legendary Weapon", "Yes", "No")
					if("Rho Aias")
						confirm = alert(src, "Rho Aias gives injury equivalent to it's Vai HP given, but is a very powerful defensive tool. Is this the weapon you want?", "Legendary Weapon", "Yes", "No")
					if("Kanshou & Byakuya")
						confirm = alert(src, "Kanshou & Byakuya are more shatter resistant then typical projections, as well as having dual wield innately. Is this the weapon you want?", "Legendary Weapon", "Yes", "No")
					if("Caladbolg")
						confirm = alert(src, "Caladbolg is a projectile with homing and a windup, when fired, it tracks hard into your opponent before exploding into a high damage AoE. Is this the weapon you want?", "Legendary Weapon", "Yes", "No")
			switch(choice)
				if("Gae Bolg")
					src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/GaeBolg)
					src.AddSkill(new/obj/Skills/Projectile/Zone_Attacks/Gae_Bolg)
				if("Rule Breaker")
					src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/RuleBreaker)
				if("Rho Aias")
					src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Rho_Aias)
				if("Kanshou & Byakuya")
					src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/KanshouByakuya)
				if("Caladbolg")
					src.AddSkill(new/obj/Skills/Projectile/Zone_Attacks/Caladbolg)
mob/Admin3/verb
	SagaRemoval(mob/Players/P in players)
		set category="Admin"
		var/Choice=input(usr, "Are you sure you want to remove [P]'s saga?", "Saga Decision") in list("Yes", "No")
		if(Choice=="No") return
		var/list/obj/Skills/SagaSkills = list("/obj/Skills/Buffs/SpecialBuff/King_Of_Courage",\
"/obj/Skills/AutoHit/Pegasus_Meteor_Fist","/obj/Skills/Queue/Rising_Dragon_Fist",\
"/obj/Skills/Projectile/Diamond_Dust","/obj/Skills/Projectile/Nebula_Stream",\
"/obj/Skills/Queue/Phoenix_Demon_Illusion_Strike","/obj/Skills/AutoHit/Unicorn_Gallop",\
"/obj/Skills/Buffs/ActiveBuffs/Persona","/obj/Skills/Buffs/SpecialBuffs/King_of_Braves",\
"/obj/Skills/Buffs/SlotlessBuffs/Will_Knife","/obj/Skills/Buffs/SlotlessBuffs/Protect_Shade",\
"/obj/Skills/Projectile/King_of_Braves/Broken_Magnum","/obj/Skills/Buffs/SlotlessBuffs/Copy_Blade",\
"/obj/Skills/Buffs/SlotlessBuffs/Projection","/obj/Skills/Buffs/NuStyle/SwordStyle/Sword_Savant",\
"/obj/Skills/Buffs/SlotlessBuffs/Magic/Reinforce_Self","/obj/Skills/Queue/JawStrike",\
"/obj/Skills/Queue/FallingBlade","/obj/Skills/Buffs/NuStyle/UnarmedStyle/Ansatsuken_Style",\
"/obj/Skills/Projectile/Ansatsuken/Hadoken","/obj/Skills/Queue/Shoryuken","/obj/Skills/AutoHit/Tatsumaki",\
"/obj/Skills/Buffs/ActiveBuffs/Eight_Gates","/obj/Skills/Queue/Front_Lotus","/obj/Skills/AutoHit/Sharingan_Genjutsu",\
"/obj/Skills/Buffs/SpecialBuffs/Sharingan","/obj/Skills/Buffs/NuStyle/UnarmedStyle/Move_Duplication",\
"/obj/Skills/Buffs/SlotlessBuffs/Spirit_Sword","/obj/Skills/Buffs/SlotlessBuffs/Spirit_Bow",\
"/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Hero_Soul","/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Hero_Heart",\
"/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Prismatic_Hero","/obj/Skills/Buffs/ActiveBuffs/Keyblade");
		if(P.Saga == "Cosmo") P.KiControlMastery-=1
		if(P.Saga == "Hiten Mitsurugi-Ryuu")
			P.passive_handler["SlayerMod"] = 0
			P.passive_handler["Flicker"] = 0
			P.passive_handler["Pursuer"] = 0
			P.passive_handler["Godspeed"] = 0
			P.passive_handler["AttackSpeed"] = 0
			P.passive_handler["Brutalize"] = 0
			P.passive_handler["MovementMastery"] = 0
			P.passive_handler["TechniqueMastery"] = 0
			P.passive_handler["AsuraStrike"] = 0
			P.passive_handler["FavoredPrey"] = null;
		if(P.Saga == "Ansatsuken")
			P.passive_handler.Decrease("SlayerMod", 0.625)
			P.passive_handler.Set("FavoredPrey", null)
		for(var/x=1, x<=SagaSkills.len,x++)
			var/obj/Skills/s = P.FindSkill(SagaSkills[x])
			if(s)
				P.contents -= s
				P << "[s] removed."
				del s
		P.ClothBronze=null
		P.SagaLevel=0
		P.Saga=null
		Log("Admin","[ExtractInfo(usr)] removed Saga from [P].")
