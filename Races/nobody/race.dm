race
	nobody
		name = "Nobody"
		desc = "Empty shells left behind when someone with a strong heart passes on. They lack hearts and emotions, but possess undeniable strength."
		visual = 'Makaioshins.png'
		locked = TRUE
		strength = 1
		endurance = 1
		speed = 1
		offense = 1
		defense = 1
		force = 1
		statPoints = 11
		anger = 1
		intellect = 3
		imagination = 0.05
		learning = 1.25
		classes = list("Samurai", "Sorcerer", "Berserker","Imaginary", "Reaper")
		stats_per_class = list("Samurai" = list(1.75, 1.5, 1, 1.75, 1.5, 2),"Sorcerer" = list(1,1.75,2,2,2,1),"Berserker" = list(2,2,2,1,1,1),"Imaginary" = list(2, 2, 1, 1.25, 1.25, 1.25), "Reaper" = list(1.75, 1, 1.75, 1.75, 1, 1.5))
		onFinalization(mob/user)
			if(!islist(user.race.transformations))
				user.race.transformations = list()

			user.race.transformations.Cut()
			if(user.Class=="Samurai")
				passives = list("BlurringStrikes" = 1, "SwordAscension" = 1, "SwordAscensionSecond" = 1, "SwordAscensionThird" = 1, "Flicker"=1, "EmptyFlashStep" = 1)
				user.AddSkill(new /obj/Skills/Buffs/SlotlessBuffs/Racial/Void_Blade)
				user.AddSkill(new /obj/Skills/AutoHit/Desperation/FatalEnding)
				user.NobodyOrigin()
			if(user.Class=="Sorcerer")
				passives = list("MovingCharge" = 1, "QuickCast" = 1, "Superglide" = 1, "FullyEffecient" = 1, "Tossing" = 1, "Extra Secret Knives" = "UltimaLaser", "SpiritFlow" = 4)
				user.AddSkill(new /obj/Skills/Projectile/Zone_Attacks/Desperation/UltimaLasers)
				user.NobodyOrigin()
			if(user.Class=="Berserker")
				user.ManaAmount=0
				user.AddSkill(new /obj/Skills/Queue/Desperation/LunarRave)
				user.AddSkill(new /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Nobody/Lunar_Wrath)
				passives = list("LunarDurability" = 1, "LunarWrath" = 1,"RenameMana" = "WRATH","LunarAnger"=1)
				user.NobodyOrigin()
			if(user.Class=="Imaginary")
				user.AddSkill(new /obj/Skills/Projectile/Zone_Attacks/Desperation/MagicHour)
				user.ImaginaryKeyblade()
				user.NobodyOrigin()
				passives = list("ImbuedSoul" = 1, , "EnergyGeneration" = 2, "ManaGeneration" = 2, "DrainlessPUSpike" = 1)
			if(user.Class=="Reaper")
				passives = list( "SlayerMod" = 1, "FavoredPrey" = "Mortal", "Extend" = 1, "Gum Gum" = 1, "CriticalChance" = 15, "CriticalDamage" = 0.25, "Instinct" = 1 )
				user.AddSkill(new /obj/Skills/AutoHit/Desperation/Deathscythe)
				user.NobodyOrigin()
			passives += list("Emptiness" = 1, "Longing" = 1)
			..()
/mob/proc/NobodyOrigin()
	var/list/Choices=list("Prideful Heart", "Spirited Heart", "Simple and Clean")
	var/choice
	var/confirm
	while(confirm!="Yes")
		choice=input(src, "Nobodies are born from those with a powerful Heart passing away. To whom did it belong?", "Nobody Origin") in Choices
		switch(choice)
			if("Prideful Heart")
				confirm=alert(src, "Of a Saiyan, in spite of your lack of emotions, your body still resonates with your originator's Pride.", "You may, too, be able to call upon the legend...", "Yes", "No")
			if("Spirited Heart")
				confirm=alert(src, "Of a Human, in spite of your lack of emotions, your body remains driven with hands able to reach the heavens.", "You may, too, be able to raise your battle tension in dire straits...", "Yes", "No")
			if("Simple and Clean")
				confirm=alert(src, "You do not know, and it does not matter. Frivolous things such as Pride or Spirit do not matter to a Nobody.", "Simplicity will lead to a stronger base.", "Yes", "No")
	switch(choice)
		if("Prideful Heart")
			src.NobodyOriginType="Pride"
		if("Spirited Heart")
			src.NobodyOriginType="Spirit"
		if("Simple and Clean")
			src.NobodyOriginType="Simple"
/mob/proc/ImaginaryKeyblade()
	var/list/Choices=list("A Sword of Courage", "A Staff of Spirit", "A Shield of Kindness")
	var/choice
	var/confirm
	while(confirm!="Yes")
		choice=input(src, "A weapon is engraved upon every heart.  What lies within yours?", "Keyblade Awakening") in Choices
		switch(choice)
			if("A Sword of Courage")
				confirm=alert(src, "With this, your heart will be dedicated and impulsive.", "A Sword who's strength is Courage. Bravery to stand against anything.", "Yes", "No")
			if("A Staff of Spirit")
				confirm=alert(src, "With this, your heart will be flexible and unrestrained.", "A Staff who's strenth is Spirit. Power the eye cannot see.", "Yes", "No")
			if("A Shield of Kindness")
				confirm=alert(src, "With this, your heart will be able to endure anything for the sake of those you love.", "A Shield who's strength is Kindness. The desire to help one's friends.", "Yes", "No")
	switch(choice)
		if("A Sword of Courage")
			src.KeybladeType="Sword"
		if("A Staff of Spirit")
			src.KeybladeType="Staff"
		if("A Shield of Kindness")
			src.KeybladeType="Shield"
	var/Color=alert(src, "Light or Darkness?", "Keyblade", "Light", "Darkness")
	src.AddSkill(new/obj/Skills/Buffs/ActiveBuffs/Keyblade)
	src<<"You awaken the [src.KeybladeType] of your heart!"
	src.Saga="Keyblade"
	src.SagaLevel=1
	src.KeybladeColor=Color
	if(src.KeybladeType=="Sword")
		src.ChooseMartialSkill(1)
	if(src.KeybladeType=="Shield")
		var/inp = input(src, "What path of magic will you fall under?") in list("Fire", "Ice", "Thunder")
		src.KeybladePath = inp
		switch(src.KeybladePath)
			if("Fire")
				src.AddSkill(new/obj/Skills/Projectile/Magic/Fire)
			if("Ice")
				src.AddSkill(new/obj/Skills/AutoHit/Magic/Blizzard)
			if("Thunder")
				src.AddSkill(new/obj/Skills/AutoHit/Magic/Thunder)
	if(src.KeybladeType=="Staff")
		src.KeybladePath="Magical"
		src.AddSkill(new/obj/Skills/AutoHit/Magic/Thunder)
		src.AddSkill(new/obj/Skills/AutoHit/Magic/Blizzard)
		src.AddSkill(new/obj/Skills/Projectile/Magic/Fire)
		src << "You've mastered the magical arts!"
	switch(src.KeybladeColor)
		if("Light")
			src.KeychainAttached="Kingdom Key"
			src.SyncAttached="Kingdom Key"
		if("Darkness")
			src.KeychainAttached="Kingdom Key D"
			src.SyncAttached="Kingdom Key D"
