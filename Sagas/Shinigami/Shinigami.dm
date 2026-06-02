mob/proc/gainShinigami()
	src << "You feel the touch of death upon your soul... you have become a <b>Shinigami</b>."
	src.Saga = "Shinigami"
	src.SagaLevel = 1

	var/list/Releases = list("Zangetsu", "Senbonzakura", "Shirayuki", "Hozukimaru", "Nozarashi", "Shinso", "Suzumushi", "Tachikaze", "Ryujin Jakka", "Katen Kyokotsu")
	src.ShinigamiRelease = input("Which Release does [src] receive?", "Zanpakutō Release") in Releases

	src.ZanpakutoClass = input(src, "What form does your Zanpakutō take?", "Zanpakutō Class") in list("Light", "Medium", "Heavy")

	src.ShihakushoClass = input(src, "What weight is your Shihakushō?", "Shihakushō Class") in list("Light", "Medium", "Heavy")

	if(src.ShinigamiRelease != "Nozarashi")
		src.AsauchiName = input(src, "What is the name of your Asauchi?", "Asauchi Name") as text
		src.ShikaiCall = input(src, "What is your call before their name? (for example, \"Scatter\")", "Shikai Call") as text
	else
		src.AsauchiName = "???"

	var/obj/Items/Sword/Medium/Legendary/Shinigami/Zanpakuto/z = new(src)
	z.Class = src.ZanpakutoClass
	z.setStatLine()
	z.name = "Zanpakutō ([src.AsauchiName])"
	z.Ascended = min(1 + src.SagaLevel, 6)

	if(src.ShinigamiRelease == "Katen Kyokotsu")
		var/obj/Items/Sword/Medium/Legendary/Shinigami/Zanpakuto_Dual/z2 = new(src)
		z2.Class = src.ZanpakutoClass
		z2.setStatLine()
		z2.name = "Zanpakutō ([src.AsauchiName])"
		z2.Ascended = min(1 + src.SagaLevel, 6)

	var/obj/Items/Armor/sh
	switch(src.ShihakushoClass)
		if("Light")
			sh = new/obj/Items/Armor/Mobile_Armor/Shinigami_Shihakusho(src)
		if("Medium")
			sh = new/obj/Items/Armor/Balanced_Armor/Shinigami_Shihakusho(src)
		if("Heavy")
			sh = new/obj/Items/Armor/Plated_Armor/Shinigami_Shihakusho(src)
	sh.Ascended = min(1 + src.SagaLevel, 6)

	src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form)
	src.AddSkill(new/obj/Skills/Buffs/NuStyle/SwordStyle/Zanjutsu)
	src << "Your training grants you access to Kidō. You can currently select 2 Tier 1 spells."

	if(src.ShinigamiRelease == "Nozarashi")
		src << "A <b>[src.ZanpakutoClass]</b> Zanpakutō and <b>[src.ShihakushoClass]</b> Shihakushō have found their way into your possession, somehow."
	else if(src.ShinigamiRelease == "Katen Kyokotsu")
		src << "A matched pair of <b>[src.ZanpakutoClass]</b> Zanpakutō and a <b>[src.ShihakushoClass]</b> Shihakushō have formed for you, twin extensions of your soul."
	else
		src << "A <b>[src.ZanpakutoClass]</b> Zanpakutō and <b>[src.ShihakushoClass]</b> Shihakushō have formed for you, serving as an extension of your soul."
	src << "Use <b>Shinigami Form</b> to don your Zanpakutō and Shihakushō."


mob/tierUpSaga(Path)
	..()
	if(Path == "Shinigami")
		switch(SagaLevel)
			if(2)
				switch(ShinigamiRelease)
					if("Nozarashi")
						src << "The name of your Asauchi continues to elude you... but you feel like you don't need it anyway."
						src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Unleash_Spiritual_Pressure)
					else
						src << "The spirit within your Zanpakutō stirs... <b>Shikai</b> is within your grasp."
						switch(ShinigamiRelease)
							if("Zangetsu")
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Zangetsu)
							if("Senbonzakura")
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura)
							if("Shirayuki")
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Zanpakuto/Shikai/SodenoShirayuki)
								src.AddSkill(new/obj/Skills/AutoHit/Tsukishiro)
								src.AddSkill(new/obj/Skills/AutoHit/Hakuren)
							if("Hozukimaru")
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Hozukimaru)
							if("Shinso")
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Shinso)
							if("Suzumushi")
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Suzumushi)
								src.AddSkill(new/obj/Skills/AutoHit/Suzumushi)
							if("Tachikaze")
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Tachikaze)
								src.AddSkill(new/obj/Skills/Projectile/Air_Blades)
							if("Ryujin Jakka")
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Ryujin_Jakka)
								src.AddSkill(new/obj/Skills/AutoHit/Taimatsu)
								src.AddSkill(new/obj/Skills/Jokaku_Enjo)
							if("Katen Kyokotsu")
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Katen_Kyokotsu)
								src.AddSkill(new/obj/Skills/Projectile/Bushogoma)
								src.AddSkill(new/obj/Skills/Takaoni)
								src.AddSkill(new/obj/Skills/Kageoni)
				updateShinigamiAscended()

			if(3)
				src << "Your Kidō deepens. You can learn 2 more spells (Tier 2 or lower)."
				switch(ShinigamiRelease)
					if("Nozarashi")
						src.AddSkill(new/obj/Skills/Queue/Two_Hands)
						src << "You remembered that you can use <b>Two Hands</b> to swing your sword even harder."
					else
						src << "You have mastered your Shikai. Its drain fades..."
						switch(ShinigamiRelease)
							if("Senbonzakura")
								if(!locate(/obj/Skills/SenbonzakuraPetalWall, src))
									src.AddSkill(new/obj/Skills/SenbonzakuraPetalWall)
									src << "Your control over your petals sharpens. You can now use <b>Petal Wall</b>."
							if("Shirayuki")
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Shirafune)
								src<<"You learn <i>San no mai, Shirafune!</i>"
							if("Suzumushi")
								if(!locate(/obj/Skills/Projectile/Benihiko, src))
									src.AddSkill(new/obj/Skills/Projectile/Benihiko)
									src << "Your blade's cry splits into countless blades of sound. You can now use <b>Benihiko</b>."
							if("Tachikaze")
								if(!locate(/obj/Skills/Projectile/Bakudantsuki, src))
									src.AddSkill(new/obj/Skills/Projectile/Bakudantsuki)
									src << "Your blade learns to detonate the air itself. You can now use <b>Bakudantsuki</b>."
							if("Ryujin Jakka")
								if(!locate(/obj/Skills/Ennetsu_Jigoku, src))
									src.AddSkill(new/obj/Skills/Ennetsu_Jigoku)
									src << "The flames of your blade descend into a converging hell. You can now use <b>Ennetsu Jigoku</b>."
							if("Katen Kyokotsu")
								if(!locate(/obj/Skills/Irooni, src))
									src.AddSkill(new/obj/Skills/Irooni)
								if(!locate(/obj/Skills/Daruma_san_ga_Koronda, src))
									src.AddSkill(new/obj/Skills/Daruma_san_ga_Koronda)
								if(!locate(/obj/Skills/Kageokuri, src))
									src.AddSkill(new/obj/Skills/Kageokuri)
								src << "You learn new games. You can now use <b>Irooni</b>, <b>Daruma-san ga Koronda</b>, and <b>Kageokuri</b>."
				updateShinigamiAscended()

			if(4)
				switch(ShinigamiRelease)
					if("Nozarashi")
						src << "The spirit within your Zanpakutō finally speaks its name..."
						src.AsauchiName = input(src, "What is the name of your Asauchi?", "Asauchi Name") as text
						src.ShikaiCall = input(src, "What is your call before their name? (for example, \"Cut\", \"Devour\")", "Shikai Call") as text
						for(var/obj/Items/i in src)
							if(i.IsZanpakuto)
								i.name = "Zanpakutō ([src.AsauchiName])"
						src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Nozarashi)
						src.AddSkill(new/obj/Skills/AutoHit/Leap_Attack)
					else
						src << "The full power of your soul erupts, <b>Bankai</b> is yours."
						switch(ShinigamiRelease)
							if("Zangetsu")
								src.BankaiPrefix = input(src, "Your Bankai takes shape. What prefix precedes your Zanpakutō's name?", "Bankai Prefix") as text
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Tensa_Zangetsu)
							if("Senbonzakura")
								src.BankaiPrefix = input(src, "Your Bankai takes shape. What suffix comes after your Zanpakutō's name?", "Bankai Suffix") as text
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Kageyoshi)
								if(!locate(/obj/Skills/SenbonzakuraGoukei, src))
									src.AddSkill(new/obj/Skills/SenbonzakuraGoukei)
									src << "The petals converge at your will. You can now use <b>Goukei</b>."
							if("Shirayuki")
								src.BankaiPrefix = input(src, "Your Bankai takes shape. What is your Zanpakutō's true name?", "Bankai Prefix") as text
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Zanpakuto/Bankai/HakkanoTogame)
								src.AddSkill(new/obj/Skills/AutoHit/Hakusen)
							if("Hozukimaru")
								src.BankaiPrefix = input(src, "Your Bankai takes shape. What prefix precedes your Zanpakutō's name?", "Bankai Prefix") as text
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Ryumon_Hozukimaru)
							if("Shinso")
								src.BankaiPrefix = input(src, "Your Bankai's true name reveals itself. What is it?", "Bankai True Name") as text
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Kamishini_no_Yari)
							if("Suzumushi")
								src.BankaiPrefix = input(src, "Your Bankai manifests. What suffix comes after your Zanpakutō's name?", "Bankai Suffix") as text
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Enma_Korogi)
							if("Tachikaze")
								src.BankaiPrefix = input(src, "Your Bankai takes shape. What prefix precedes your Zanpakutō's name?", "Bankai Prefix") as text
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Tekken_Tachikaze)
							if("Ryujin Jakka")
								src.BankaiPrefix = input(src, "Your Bankai's true name reveals itself. What is it?", "Bankai Prefix") as text
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Zanka_no_Tachi)
								src << "All the flames of your [src.AsauchiName] condense into your blade. Entering Bankai awakens <b>Higashi: Kyokujitsujin</b>."
							if("Katen Kyokotsu")
								src.BankaiPrefix = input(src, "Your Bankai manifests. What suffix comes after your Zanpakutō's name?", "Bankai Suffix") as text
								src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Karamatsu_Shinju)
								src.AddSkill(new/obj/Skills/Ichidanme)
								src.AddSkill(new/obj/Skills/Nidanme)
								src.AddSkill(new/obj/Skills/Sandanme)
								src.AddSkill(new/obj/Skills/Shime_no_Dan)
								src << "Your soul's despair takes the stage in the form of a four-act tragedy played out upon your foe."
				updateShinigamiAscended()

			if(5)
				src << "Your mastery of Kidō sharpens. You can select 1 spell (Tier 3 or lower)."
				if(ShinigamiRelease == "Nozarashi")
					src << "You have mastered your Shikai. Its drain fades..."
				else
					src << "You have mastered your Bankai. Its drain fades..."
				src.passive_handler.Increase("GodKi", 0.15)
				switch(ShinigamiRelease)
					if("Zangetsu")
						if(!locate(/obj/Skills/Buffs/SpecialBuffs/Sword/Getsuga_Tenshou_Clad, src))
							src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Sword/Getsuga_Tenshou_Clad)
							src << "The black-clad Getsuga surges through your blade, you can now use <b>Getsuga Tenshou Clad</b>."
					if("Senbonzakura")
						if(!locate(/obj/Skills/SenbonzakuraSenkei, src))
							src.AddSkill(new/obj/Skills/SenbonzakuraSenkei)
							src << "Your petals can arrange themselves into swords of light. You can now use <b>Senkei</b>."
					if("Shinso")
						if(!locate(/obj/Skills/Butou, src))
							src.AddSkill(new/obj/Skills/Butou)
							src << "The accuracy of your blade's reach grows. You can now use <b>Butou</b>."
					if("Tachikaze")
						if(!locate(/obj/Skills/Queue/Enhanced_Sandbag_Beat, src))
							src.AddSkill(new/obj/Skills/Queue/Enhanced_Sandbag_Beat)
							src << "Your fists rage like a relentless storm. You can now use <b>Enhanced Sandbag Beat</b>."
					if("Ryujin Jakka")
						if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Zanjitsu_Gokui, src))
							src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Zanjitsu_Gokui)
							src << "Your blade shrouds you in an inferno of searing heat. You can now use <b>Nishi: Zanjitsu Gokui</b>."
				updateShinigamiAscended()

			if(6)
				src << "You are nearing the heights of Kidō. You can select 1 spell (Tier 4 or lower)."
				switch(ShinigamiRelease)
					if("Nozarashi")
						src << "The full power of your soul erupts. <b>Bankai</b> is yours."
						src.BankaiPrefix = input(src, "Your Bankai takes shape. What prefix precedes your Zanpakutō's name?", "Bankai Prefix") as text
						src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Nozarashi_Bankai)
					else
						src.passive_handler.Increase("GodKi", 0.1)
						switch(ShinigamiRelease)
							if("Zangetsu")
								if(!locate(/obj/Skills/Buffs/SpecialBuffs/Sword/Final_Getsuga_Tenshou, src))
									src.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Sword/Final_Getsuga_Tenshou)
								src << "The depths of your soul reveal the <b>Final Getsuga Tenshou</b>. Using it will cost you everything... but it may open a new path."
							if("Senbonzakura")
								if(!src.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Hakuteiken))
									src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Senbonzakura_Hakuteiken)
									src << "The ultimate form of your blade awakens. You can now use <b>Shukei: Hakuteiken</b>."
							if("Shinso")
								if(!locate(/obj/Skills/Butou_Renjin, src))
									src.AddSkill(new/obj/Skills/Butou_Renjin)
									src << "Your thrusts compound into a relentless barrage. You can now use <b>Butou: Renjin</b>."
							if("Ryujin Jakka")
								if(!locate(/obj/Skills/Queue/Tenchi_Kaijin, src))
									src.AddSkill(new/obj/Skills/Queue/Tenchi_Kaijin)
									src << "Your strikes reduce all they touch to ash. You can now use <b>Kita: Tenchi Kaijin</b>."
				updateShinigamiAscended()

			if(7)
				src << "The highest art of Kidō is within reach. You can select 1 spell (Tier 5 or lower)."
				src.passive_handler.Increase("GodKi", 0.25)
				if(ShinigamiRelease == "Nozarashi")
					src << "Your body can finally withstand your Bankai's power."
				switch(ShinigamiRelease)
					if("Zangetsu")
						for(var/obj/Skills/Buffs/SlotlessBuffs/Mugetsu_Aftermath/MA in src)
							if(MA.SlotlessOn)
								MA.Trigger(src)
							del MA
						src.StrCut = 0
						src.EndCut = 0
						src.ForCut = 0
						src.ManaCut = 0
						src.EnergyCut = 0
						if(!locate(/obj/Skills/Projectile/Getsuga_Jujisho, src))
							src.AddSkill(new/obj/Skills/Projectile/Getsuga_Jujisho)
						if(!locate(/obj/Skills/Projectile/True_Getsuga_Tenshou, src))
							src.AddSkill(new/obj/Skills/Projectile/True_Getsuga_Tenshou)
						src << "Your sacrifice was not in vain. Your power returns - greater, and free. You can now use <b>Getsuga Jujisho</b> and <b>True Getsuga Tenshou</b>."
					if("Senbonzakura")
						if(!locate(/obj/Skills/SenbonzakuraIkkaSenjinka, src))
							src.AddSkill(new/obj/Skills/SenbonzakuraIkkaSenjinka)
							src << "Every one of your Senkei blades can answers your call at once. You can now use <b>Ikka Senjinka</b>."
					if("Shinso")
						if(!locate(/obj/Skills/Korose, src))
							src.AddSkill(new/obj/Skills/Korose)
							src << "Your blade now carries a deadly poison. You can now use <b>Korose</b>."
					if("Ryujin Jakka")
						if(!locate(/obj/Skills/Kaka_Jumanokushi_Daisojin, src))
							src.AddSkill(new/obj/Skills/Kaka_Jumanokushi_Daisojin)
							src << "The ashes of all you have burned rise as a blazing army. You can now use <b>Minami: Kaka Jūmanokushi Daisōjin</b>."
				updateShinigamiAscended()

mob/proc/InShikai()
	for(var/sb in SlotlessBuffs)
		var/obj/Skills/Buffs/SlotlessBuffs/b = SlotlessBuffs[sb]
		if(b && b.IsShikaiForm && b.SlotlessOn)
			return TRUE
	return FALSE

mob/proc/InBankai()
	for(var/sb in SlotlessBuffs)
		var/obj/Skills/Buffs/SlotlessBuffs/b = SlotlessBuffs[sb]
		if(b && b.IsBankaiForm && b.SlotlessOn)
			return TRUE
	return FALSE

mob/proc/updateShinigamiAscended()
	var/newAsc = min(1 + SagaLevel, 6)
	for(var/obj/Items/i in src)
		if(i.IsZanpakuto || i.IsShihakusho)
			i.Ascended = newAsc
