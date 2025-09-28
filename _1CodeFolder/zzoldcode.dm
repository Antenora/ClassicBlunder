
/* mob/proc/Melee(var/damagemulti=1,var/speedmulti=1,var/iconoverlay,var/forcewarp,var/MeleeTarget=null,var/ExtendoAttack=null,var/SecondStrike,var/ThirdStrike,var/accmulti=1, var/SureKB=0, var/NoKB=0, var/IgnoreCounter=0, var/BreakAttackRate=0)


	if(damagemulti<=0)
		damagemulti=1
	if(src.Stasis)
		return
	if(SecondStrike || ThirdStrike)
		BreakAttackRate=1

	if(!src.CanAttack() && !BreakAttackRate)
		return

	var/UnarmedAttack=1
	var/SwordAttack=0
	var/LightAttack=0

	var/Delay=SpeedDelay()
	log2text("Delay", Delay, "damageDebugs.txt", "[src.ckey]/[src.name]")
	if(src.AttackQueue)
		if(src.AttackQueue.Combo && !(src.AttackQueue.Counter + src.AttackQueue.CounterTemp))
			if(!src.Target||src.Target==src)
				src << "You need a target to combo!"
				return
			if(src.AttackQueue.ComboPerformed>0)
				src.Comboz(src.Target)
			if(src.AttackQueue.ComboPerformed<=src.AttackQueue.Combo)
				src.AttackQueue.ComboPerformed++
			else
				src.ClearQueue()
			if(src.AttackQueue.ComboHitMessages.len>0)
				var/Message=src.AttackQueue.ComboHitMessages[src.AttackQueue.ComboPerformed]
				if(Message)
					if(src.AttackQueue.TextColor)
						src.OMessage(10, "<font color='[src.AttackQueue.TextColor]'><b>[src] [Message]</b></font color>", "[src]([src.key]) hit with [src.AttackQueue].")
					else
						src.OMessage(10, "<font color='[src.Text_Color]'><b>[src] [Message]</b></font color>", "[src]([src.key]) hit with [src.AttackQueue].")
			Delay/=5
		if(src.AttackQueue.Rapid||src.AttackQueue.Launcher)
			Delay/=10//gatta go fass.

	var/obj/Items/Sword/s=src.EquippedSword()
	var/obj/Items/Sword/s2=src.EquippedSecondSword()
	if(!s2 && UsingDualWield()) s2 = s
	var/obj/Items/Sword/s3=src.EquippedThirdSword()
	if(!s3 && UsingTrinityStyle()) s3 = s
	var/obj/Items/Enchantment/Staff/st=src.EquippedStaff()
	var/Accuracy=1
	var/Damage
	var/DamageRoll=src.GetDamageMod()
	log2text("DamageRoll", "Starting DamageRoll", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("DamageRoll", DamageRoll, "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("Damage", "Starting Damage", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("Damage", Power, "damageDebugs.txt", "[src.ckey]/[src.name]")
	var/adjustedPower = Power * GLOBAL_POWER_MULT
	if(new_damage_calc == 1)
		Damage = get_potential() * DamageRoll
	else
		Damage=adjustedPower*DamageRoll //Normal
	log2text("Damage", "After Power * Dmg mult or w/e", "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("Damage", Damage, "damageDebugs.txt", "[src.ckey]/[src.name]")
	if(s||!src.NotUsingLiving())
		UnarmedAttack=0
		SwordAttack=1

	if(src.AttackQueue)
		if(src.AttackQueue.NeedsSword)
			UnarmedAttack=0
			SwordAttack=1
		else
			UnarmedAttack=1
			SwordAttack=0
	log2text("Damage", "After Hybrid/Stat Scaling", "damageDebugs.txt", "[src.ckey]/[src.name]")
	if(src.UsingSunlight()||src.HasSpiritHand()&&(UnarmedAttack||SwordAttack))
		var/forModifier = 1
		if(src.StyleActive!="Sunlight"&&src.StyleActive!="Moonlight"&&src.StyleActive!="Atomic Karate"&&!src.CheckSpecial("Prana Burst"))
			forModifier = GetFor()**(1/2)
			Damage *= 1 + ((src.GetStr()*forModifier)/10)
		else
			forModifier = clamp(src.GetFor(0.5), 1.25, 2)
			Damage*= 1 + ((src.GetStr()*forModifier)/10)
	else if(SwordAttack&&src.HasSpiritSword())
		var/str = src.GetStr(src.GetSpiritSword())
		var/force = src.GetFor(src.GetSpiritSword())
		Damage*= 1 + ((str+force) / 10 )
	else if(src.HasHybridStrike())
		var/str = src.GetStr()
		var/force = src.GetFor(src.GetHybridStrike())
		Damage*= 1 + ((str+force) / 10)
	else if(src.HasSpiritStrike())
		Damage*= 1 + (src.GetFor() /10 )
	else
		Damage*= 1 + (src.GetStr() / 10)

	log2text("Damage", Damage, "damageDebugs.txt", "[src.ckey]/[src.name]")
	log2text("Damage", "After Global Mult", "damageDebugs.txt", "[src.ckey]/[src.name]")
	Damage *= GLOBAL_MELEE_MULT
	log2text("Damage", Damage, "damageDebugs.txt", "[src.ckey]/[src.name]")

	// if(src.HasPridefulRage())
	// 	var/enduranceRatio = min(P.GetEnd(), 1) / ENDURANCE_DIVISOR
	// 	newTest = min(ENDURANCE_BASE_RATIO - (enduranceRatio), ENDURANCE_BASE_RATIO)
	// else
	// 	var/enduranceRatio = P.GetEnd() / ENDURANCE_DIVISOR
	// 	if(P.GetEnd() >= ENDURANCE_DIVISOR)
	// 		newTest = 0.001
	// 	else
	// 		newTest = min(ENDURANCE_BASE_RATIO - (enduranceRatio), ENDURANCE_BASE_RATIO)
	// newTest *= Damage
	// powerRatio = min(P.Power / (P.Power + POWER_MULT_DIVISOR), POWER_BASE_RATIO-0.01)
	// var/attackerPowerRatio = min(src.Power / (src.Power + POWER_MULT_DIVISOR), POWER_BASE_RATIO-0.01)
	// newTest *= POWER_BASE_RATIO - powerRatio
	// newTest *= POWER_BASE_RATIO + attackerPowerRatio
	// if(newTest < 0.05)
	// 	newTest = 0.05

	// Damage = newTest



	if(!src.AttackQueue)
		if(src.HasDoubleStrike())
			if(prob(25*src.GetDoubleStrike()+(25*src.GetTripleStrike()))&&!SecondStrike)
				Melee(SecondStrike=1)
			if(src.HasTripleStrike())
				if(prob(25*src.GetTripleStrike())&&SecondStrike&&!ThirdStrike)
					Melee(SecondStrike=1,ThirdStrike=1)
	var/itemDamageMod = 0
	if(st)
		if(src.UsingBattleMage())
			Delay/=src.GetStaffDrain(st)

			itemDamageMod+=src.GetStaffDamage(st)

			Accuracy*=src.GetStaffAccuracy(st)

	if(!SecondStrike&&!ThirdStrike)

		if((s||!src.NotUsingLiving())&&SwordAttack)

			Delay/=src.GetSwordDelay(s)

			itemDamageMod+=src.GetSwordDamage(s)

			Accuracy*=GetSwordAccuracy(s)

	if(SecondStrike&&!ThirdStrike)

		if(s2&&SwordAttack)

			Delay/=src.GetSwordDelay(s2)

			itemDamageMod+=src.GetSwordDamage(s2)

			Accuracy*=GetSwordAccuracy(s2)

		else if((s||!src.NotUsingLiving())&&!s2&&SwordAttack)

			Delay/=src.GetSwordDelay(s)

			itemDamageMod+=src.GetSwordDamage(s)

			Accuracy*=GetSwordAccuracy(s)

		else if(src.ArcaneBladework&&st)

			Delay/=src.GetStaffDrain(st)

			itemDamageMod+=src.GetStaffDamage(st)

			Accuracy*=src.GetStaffAccuracy(st)

			SwordAttack=0

	if(SecondStrike&&ThirdStrike)

		if(s3&&SwordAttack)

			Delay/=src.GetSwordDelay(s3)

			itemDamageMod+=src.GetSwordDamage(s3)

			Accuracy*=GetSwordAccuracy(s3)

		else if((s||!src.NotUsingLiving())&&!s3&&SwordAttack)

			Delay/=src.GetSwordDelay(s)

			itemDamageMod+=src.GetSwordDamage(s)

			Accuracy*=GetSwordAccuracy(s)
	if(itemDamageMod > 0)
		itemDamageMod *= GLOBAL_ITEM_DAMAGE_MULT
		Damage*=itemDamageMod
		log2text("Damage", "After Item", "damageDebugs.txt", "[src.ckey]/[src.name]")
		log2text("Damage", Damage, "damageDebugs.txt", "[src.ckey]/[src.name]")
	var/WarpingStrike=0
	if(src.AttackQueue&&!src.AttackQueue.NoWarp)
		if(src.AttackQueue.Warp)
			if(!src.AttackQueue.InstantStrikes)
				WarpingStrike=src.AttackQueue.Warp
			else
				WarpingStrike=src.AttackQueue.Warp
				if(src.AttackQueue.InstantStrikesDelay<2)
					src.AttackQueue.NoWarp=1
	if(src.UsingIaido())
		var/ReqCounter=0
		if(src.HasSword())
			if(src.UsingTrinityStyle())
				switch(s.Class)
					if("Wooden")
						ReqCounter+=8
					if("Light")
						ReqCounter+=3
					if("Medium")
						ReqCounter+=5
					if("Heavy")
						ReqCounter+=8
				switch(s2.Class)
					if("Wooden")
						ReqCounter+=8
					if("Light")
						ReqCounter+=3
					if("Medium")
						ReqCounter+=5
					if("Heavy")
						ReqCounter+=8
				switch(s3.Class)
					if("Wooden")
						ReqCounter+=8
					if("Light")
						ReqCounter+=3
					if("Medium")
						ReqCounter+=5
					if("Heavy")
						ReqCounter+=8
			else if(src.UsingDualWield())
				switch(s.Class)
					if("Wooden")
						ReqCounter+=13
					if("Light")
						ReqCounter+=5
					if("Medium")
						ReqCounter+=8
					if("Heavy")
						ReqCounter+=13
				switch(s2.Class)
					if("Wooden")
						ReqCounter+=13
					if("Light")
						ReqCounter+=5
					if("Medium")
						ReqCounter+=8
					if("Heavy")
						ReqCounter+=13
			switch(s.Class)
				if("Wooden")
					ReqCounter=25
				if("Light")
					ReqCounter=10
				if("Medium")
					ReqCounter=15
				if("Heavy")
					ReqCounter=25
		else
			ReqCounter=10
		if(src.UsingIaido()>1)
			ReqCounter-=((src.UsingIaido()-1)*5)
		if(src.Saga=="Weapon Soul"&&src.SagaLevel>=2)
			ReqCounter=max(1, ReqCounter-3)
		if(src.IaidoCounter>=ReqCounter)
			WarpingStrike=5

	if(src.UsingKendo()&&src.HasSword())
		var/ReqCounter
		if(s.Class=="Wooden")
			ReqCounter=10
		else
			ReqCounter=20
		if(src.IaidoCounter>=ReqCounter)
			WarpingStrike=5


	if(src.UsingSpeedRave())
		var/ReqCounter=10
		if(src.IaidoCounter>=ReqCounter)
			WarpingStrike=3

	if(src.Warping)
		WarpingStrike=src.Warping
		if(WarpingStrike<2)
			WarpingStrike=2//Make sure that you can at least warp from one tile away.

	if(src.BladeMode)
		if(src.Target)
			if(!src.CheckSlotless("Blade Mode"))
				if(src.Target.Launched||src.Target.Stunned)
					if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Blade_Mode, src))
						src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Blade_Mode)
					for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Blade_Mode/bm in src)
						if(!bm.Using)
							animate(src.client, color = list(0.5,0.5,0.55, 0.6,0.6,0.66, 0.31,0.31,0.37, 0,0,0), time = 3)
							bm.Trigger(src)


	if(WarpingStrike)
		if(src.Target)
			if(src.Target!=src)
				if(src.Target in view(WarpingStrike, src))
					forcewarp=src.Target

	if(forcewarp)
		src.Comboz(forcewarp)
		if(src.IaidoCounter)
			src.IaidoCounter=0

	if(src.UsingFencing()&&src.HasSword())
		switch(s.Class)
			if("Wooden")
				Delay*=1.1
			if("Light")
				Delay*=0.75
			if("Medium")
				Delay*=1.1
			if("Heavy")
				Delay*=1.3
		if(src.UsingFencing()>1)
			Delay/=(1+((src.UsingFencing()-1) * 0.25))
		if(src.Saga=="Weapon Soul"&&src.SagaLevel>=2)
			Delay/=1.25
	if(src.UsingKendo()&&src.HasSword())
		if(s.Class=="Wooden")
			Delay*=0.75
			if(src.UsingKendo()>1)
				Delay/=(1+((src.UsingKendo()-1)*0.25))
		else
			Delay/=1.25
			if(src.UsingKendo()>1)
				Delay/=(1+((src.UsingKendo()-1)*0.25))
	if(src.UsingFencing()&&!src.HasSword())
		if(src.UsingBattleMage())
			Delay*=0.75
		else
			Delay*=1.1
	log2text("Delay","After Sword","damageDebugs.txt","[src.ckey]/[src.name]")
	log2text("Delay",Delay,"damageDebugs.txt","[src.ckey]/[src.name]")
	if(src.UsingSpeedRave())
		Delay/=1.25
	if(src.UsingCriticalImpact())
		Delay*=1.4//yer slow as fuck 'arry

	if(!BreakAttackRate) src.NextAttack = world.time

	var/list/Pawnch=list()
	if(src.AttackQueue&&src.AttackQueue.PrecisionStrike)
		for(var/mob/Yo in view(src.AttackQueue.PrecisionStrike, src))
			if(Yo!=src&&Yo.density)
				if(Yo==src.Target)
					if(Yo in get_step(src,dir))
						Pawnch:Add(Yo)
					else
						Pawnch:Add(Yo)
						src.NextAttack+=10
	else if((src.HasSweepingStrike() || src.HasPassive("GiantSwings", BuffsOnly = 1, NoMobVar = 1))&&!src.AttackQueue )
		var/range = src.GetPassive("GiantSwings",BuffsOnly = 1, NoMobVar = 1) ? src.GetPassive("GiantSwings",BuffsOnly = 1, NoMobVar = 1) : 1
		for(var/mob/Yo in oview(range, src))
			if(Yo!=src&&Yo.density)
				Pawnch:Add(Yo)
	else if(HasPassive("PowerPole", BuffsOnly = 1 , NoMobVar = 1))
		var/distance = GetPassive("PowerPole", BuffsOnly = 1, NoMobVar = 1)
		var/totalDist
		switch(dir)
			if(NORTH)
				if(y+distance>world.maxy)
					totalDist = world.maxy
				else
					totalDist = y+distance
				for(var/turf/T in block(locate(x,y,z), locate(x, totalDist,z)))
					for(var/mob/Yo in T.contents)
						if(Yo.density && Yo)
							Pawnch:Add(Yo)
			if(SOUTH)
				if(y-distance<0)
					totalDist = 0
				else
					totalDist = y-distance
				for(var/turf/T in block(locate(x,y,z), locate(x, totalDist,z)))
					for(var/mob/Yo in T.contents)
						if(Yo.density)
							Pawnch:Add(Yo)
			if(EAST)
				if(x+distance>world.maxx)
					totalDist = world.maxx
				else
					totalDist = x+distance
				for(var/turf/T in block(locate(x,y,z), locate(totalDist, y,z)))
					for(var/mob/Yo in T.contents)
						if(Yo.density)
							Pawnch:Add(Yo)
			if(WEST)
				if(x-distance<0)
					totalDist = 0
				else
					totalDist = x-distance
				for(var/turf/T in block(locate(x,y,z), locate(totalDist, y,z)))
					for(var/mob/Yo in T.contents)
						if(Yo.density)
							Pawnch:Add(Yo)
	else
		for(var/mob/Yo in get_step(src,dir))
			if(Yo.density)
				Pawnch:Add(Yo)
	if(src.Grab)
		Pawnch.Add(src.Grab)
	if(src.party)
		Pawnch.Remove(src.party.members)
	if(Pawnch.len>0)
		NextAttack+=Delay
		for(var/mob/P in Pawnch)
			if(istype(P, /mob/irlNPC))
				continue
			if(istype(P, /mob/MonkeySoldier))
				continue
			if(P==src)
				continue
			if(P.Stasis)
				continue

			if(src.StyleActive=="Rhythm of War")
				if(!locate(/obj/Skills/Projectile/Warsong, src))
					src.AddSkill(new/obj/Skills/Projectile/Warsong)
				for(var/obj/Skills/Projectile/Warsong/sk in src)
					src.UseProjectile(sk)

			if(forcewarp)
				if(src.IaidoCounter)
					src.IaidoCounter=0
				if(src.StyleActive=="Secret Knife")
					if(!locate(/obj/Skills/Projectile/Secret_Knives, src))
						src.AddSkill(new/obj/Skills/Projectile/Secret_Knives)
					for(var/obj/Skills/Projectile/Secret_Knives/sk in src)
						src.UseProjectile(sk)
				if(src.StyleActive=="Blade Singing")
					if(!locate(/obj/Skills/Projectile/Murder_Music, src))
						src.AddSkill(new/obj/Skills/Projectile/Murder_Music)
					for(var/obj/Skills/Projectile/Murder_Music/sk in src)
						if(src.CheckSlotless("Legend of Black Heaven"))
							if(sk.IconLock=='CheckmateKnives.dmi')
								sk.IconLock='Soundwave.dmi'
						src.UseProjectile(sk)

			if(src.HasPridefulRage())
				var/endRatio = (GetStr()-1)/5
				Damage *= 1 + endRatio
			else
				var/endRatio = GetStr()-Target.GetEnd()
				if(endRatio < -5)
					endRatio = -5
				Damage *= 1 + (endRatio/5)
			log2text("Damage", "After end", "damageDebugs.txt", "[src.ckey]/[src.name]")
			log2text("Damage", Damage, "damageDebugs.txt", "[src.ckey]/[src.name]")
			var/powerDynamic = (Power - P.Power)/10
			if(powerDynamic == 0)
				powerDynamic = 0.1
			if(powerDynamic < 0)
				powerDynamic = 100-(abs(powerDynamic)/10)
			Damage *= powerDynamic

			var/obj/Items/Armor/HittingArmor=P.EquippedArmor()
			var/obj/Items/Armor/WearingArmor=src.EquippedArmor()

			//Reduced damage
			if(HittingArmor)
				Damage/=P.GetArmorDamage(HittingArmor)
			log2text("Damage","After Armor","damageDebugs.txt","[src.ckey]/[src.name]")
			log2text("Damage",Damage,"damageDebugs.txt","[src.ckey]/[src.name]")
			//Reduced delay and accuracy
			if(WearingArmor)
				Accuracy*=src.GetArmorAccuracy(WearingArmor)
				Delay/=src.GetArmorDelay(WearingArmor)
			log2text("Delay","After Armor","damageDebugs.txt","[src.ckey]/[src.name]")
			log2text("Delay",Delay,"damageDebugs.txt","[src.ckey]/[src.name]")
			if(speedmulti)
				Delay/=speedmulti
			if(damagemulti)
				Damage*=damagemulti
			log2text("Damage","After Multi","damageDebugs.txt","[src.ckey]/[src.name]")
			log2text("Damage",Damage,"damageDebugs.txt","[src.ckey]/[src.name]")
			log2text("Delay","After Multi","damageDebugs.txt","[src.ckey]/[src.name]")
			log2text("Delay",Delay,"damageDebugs.txt","[src.ckey]/[src.name]")
			// var/newTest=1
			// var/powerRatio=1
			var/Knock_Distance=round(round(randValue(1,3),0.1)*(src.Power/P.Power)*max(1,src.GetStr()/P.GetEnd()))
			if(src.AttackQueue)//Queued techniques like Axe Kick, Headbutt, and GET DUNKED.
				Damage*=src.QueuedDamage(P)
				log2text("Damage", "After queue damage", "damageDebugs.txt","[src.ckey]/[src.name]")
				log2text("Damage", Damage, "damageDebugs.txt","[src.ckey]/[src.name]")
				if(src.QueuedKBMult()<1&&!src.QueuedKBAdd())
					NoKB=1
				else
					Knock_Distance*=src.QueuedKBMult()
				Knock_Distance+=src.QueuedKBAdd()

			var/multiAtkNerf = 1
			if(AttackQueue && AttackQueue?.ComboPerformed>0)
				multiAtkNerf = 1 - clamp(AttackQueue.ComboPerformed * 0.07, 0.07, 0.99)
			// Damage/=BlahX

			log2text("Damage","After Power","damageDebugs.txt","[src.ckey]/[src.name]")
			log2text("Damage",Damage,"damageDebugs.txt","[src.ckey]/[src.name]")
			Damage *= multiAtkNerf
			log2text("Damage","After multiatknerf","damageDebugs.txt","[src.ckey]/[src.name]")
			log2text("Damage",Damage,"damageDebugs.txt","[src.ckey]/[src.name]")

			if(src.KBAdd)
				Knock_Distance+=src.KBAdd

			if(src.Grab==P)
				Knock_Distance+=5//yeet that bitch
				src.Grab=null

			if(src.UsingZornhau()&&src.HasSword())
				switch(s.Class)
					if("Wooden")
						Knock_Distance+=0.25
					if("Light")
						Knock_Distance+=0.75
					if("Medium")
						Knock_Distance+=1.25
					if("Heavy")
						Knock_Distance+=2
				if(src.UsingZornhau()>1)
					Knock_Distance+=src.UsingZornhau()
				if(src.Saga=="Weapon Soul"&&src.SagaLevel>=2)
					Knock_Distance+=2
			if(src.UsingKendo()&&src.HasSword())
				if(s.Class=="Wooden")
					Knock_Distance+=(2*src.UsingKendo())
				else
					Knock_Distance+=2

			if(src.UsingCriticalImpact())
				Knock_Distance*=2

			if(src.UsingFencing())
				NoKB=1

			var/hitResolution = Accuracy_Formula(src,P,Accuracy*accmulti)
			var/didIWiffLOL = hitResolution[2]
			hitResolution = hitResolution[1] // 0 , 1, or 2. 0 is a miss, 1 is a hit, 2 is glancing
			if(P.icon_state=="Meditate"||P.KO)
				hitResolution=1
				didIWiffLOL = 0

			Melee_Graphics()
			var/Countered=0

			if((src.AttackQueue&&src.AttackQueue.Dunker&&P.Launched))
				if(src.AttackQueue.Dunker)
					spawn()
						Jump(src)
					sleep(3)
					spawn()
						LaunchEnd(P)
			else if(!src.AttackQueue && (P.Launched || P.Stunned || P.Knockback)) //suffering prevention on high attack speed builds
				Damage*=0.33
			log2text("Damage","After launch/stun/knockback","damageDebugs.txt","[src.ckey]/[src.name]")
			log2text("Damage",Damage,"damageDebugs.txt","[src.ckey]/[src.name]")
			if(!src.AttackQueue && src.HotHundred)
				LightAttack=1
				var/Adjust=0
				src.Comboz(P, LightAttack=1)
				if(src.HotHundred)
					LightAttack=0
					Adjust=src.HotHundred-1

				Damage/=max(2,4-Adjust)
				if(!Adjust)
					NoKB=1
				if(SecondStrike || ThirdStrike)
					Damage *= 0.3
				NextAttack = world.time + 1.25
			log2text("Damage","After HotHundred","damageDebugs.txt","[src.ckey]/[src.name]")
			log2text("Damage",Damage,"damageDebugs.txt","[src.ckey]/[src.name]")
			if( ( ( P.AttackQueue && (P.AttackQueue.Counter || P.AttackQueue.CounterTemp) ) || (P.BusterTech&&P.BusterTech.CounterShot) )&&(!P.Stunned&&!P.Launched)&&!IgnoreCounter)
				P.dir=get_dir(P, src)
				if(P.BusterTech&&P.BusterTech.CounterShot)
					P.UseProjectile(P.BusterTech)
				else
					if(!src.AttackQueue||!(src.AttackQueue&&(src.AttackQueue.Counter||src.AttackQueue.CounterTemp)))
						Countered=(P.AttackQueue.Counter+P.AttackQueue.CounterTemp) * P.AttackQueue.DamageMult
					if(P.UsingAnsatsuken())
						P.HealMana(P.SagaLevel / 15, 1)
					if(Countered && P.CanAttack())
						P.Melee1(CounterDamage(Countered),2,0,0,null,null,0,0,2,1,0,1)

			if(P.Stunned)
				hitResolution=1
				didIWiffLOL = 0

			if(!Countered)
				var/Dodged=0
				var/DisperseX=rand(-8,8)
				var/DisperseY=rand(-8,8)

				if(hitResolution)

					if(!P.NoDodge)

						if(P.HasFlow()&&!IgnoreCounter)
							var/BASE_FLOW_PROB = 12
							var/flow = P.GetFlow()
							var/inst=src.HasInstinct()
							var/result = 0
							if(inst)
								result = flow - inst
							else
								result = flow

							if(prob(BASE_FLOW_PROB * result))
								if(src.AttackQueue)
									if(src.AttackQueue.HitSparkIcon)
										DisperseX=rand((-1)*src.AttackQueue.HitSparkDispersion,src.AttackQueue.HitSparkDispersion)
										DisperseY=rand((-1)*src.AttackQueue.HitSparkDispersion,src.AttackQueue.HitSparkDispersion)
										src.HitEffect(P, UnarmedAttack, SwordAttack, SecondStrike, ThirdStrike, DisperseX, DisperseY)
								if(P.CheckSpecial("Ultra Instinct"))
									StunClear(P)
									UltraPrediction(P)
								else
									StunClear(P)
									WildSense(P, src, 0)
								Dodged=1
								if(P.CombatCPU)
									P.LoseMana(1)


						if(P.AfterImageStrike>0&&!Dodged)
							P.AfterImageStrike-=1
							if(P.AfterImageStrike<0)
								P.AfterImageStrike=0
							var/inst=src.HasInstinct()
							if(prob(100-(inst*25)))
								if(src.AttackQueue)
									if(src.AttackQueue.HitSparkIcon)
										DisperseX=rand((-1)*src.AttackQueue.HitSparkDispersion,src.AttackQueue.HitSparkDispersion)
										DisperseY=rand((-1)*src.AttackQueue.HitSparkDispersion,src.AttackQueue.HitSparkDispersion)
										src.HitEffect(P, UnarmedAttack, SwordAttack, SecondStrike, ThirdStrike, DisperseX, DisperseY)
								StunClear(P)
								AfterImageStrike(P,src,1)
								Dodged=1
							else
								StunClear(P)
								AfterImageStrike(P,src,0)
								AfterImageStrike(src,P,0)

					else

						if(P.AfterImageStrike>0&&!src.NoDodge&&!Dodged&&!IgnoreCounter)
							P.AfterImageStrike-=1
							if(P.AfterImageStrike<0)
								P.AfterImageStrike=0
							var/inst=src.HasInstinct()
							if(prob(100-(inst*25)))
								if(src.AttackQueue)
									if(src.AttackQueue.HitSparkIcon)
										DisperseX=rand((-1)*src.AttackQueue.HitSparkDispersion,src.AttackQueue.HitSparkDispersion)
										DisperseY=rand((-1)*src.AttackQueue.HitSparkDispersion,src.AttackQueue.HitSparkDispersion)
										src.HitEffect(P, UnarmedAttack, SwordAttack, SecondStrike, ThirdStrike, DisperseX, DisperseY)
								P.dir=get_dir(P,src)
								StunClear(P)
								P.NextAttack=0
								P.Melee1(1, 1, SureKB=1)
								Dodged=1
							else
								StunClear(P)
								AfterImageStrike(src,P,0)

					if(!Dodged)
						STRIKE
						if(src.UsingSpellWeaver())
							if(prob(50))
								if(!locate(/obj/Skills/Projectile/DancingBlast, src))
									src.AddSkill(new/obj/Skills/Projectile/DancingBlast)
								for(var/obj/Skills/Projectile/DancingBlast/db in src)
									src.UseProjectile(db)
									break
						if(P.GiantForm || P.HasMythical() >= 1)
							Damage/=DamageRoll
							var/modifier = upper_damage_roll / 4
							DamageRoll = GetDamageMod(0, -modifier)
							Damage*=DamageRoll//Take out the damage mult
							log2text("DamageRoll", "After Giant Form", "damageDebugs.txt", "[src.ckey]/[src.name]")
							log2text("DamageRoll",DamageRoll,"damageDebugs.txt","[src.ckey]/[src.name]")
							log2text("Damage","After Giant Form","damageDebugs.txt","[src.ckey]/[src.name]")
							log2text("Damage",Damage,"damageDebugs.txt","[src.ckey]/[src.name]")
						// this is for whiffing, aka forced misses
						if(didIWiffLOL)
							if(AttackQueue)
								if(AttackQueue.NoWhiff)
									if(!src.NoForcedWhiff)
										Damage /= 4
									else Damage /= 4
								else Damage = 0
						if(hitResolution==2)
							Damage /= 4
							// KenShockwave(P,icon=ShockIcon,Size=ShockSize)
							log2text("Damage","After Glancing","damageDebugs.txt","[src.ckey]/[src.name]")
							log2text("Damage",Damage,"damageDebugs.txt","[src.ckey]/[src.name]")
						if(P.EnergySiphon)
							if(src.HasSpiritHand()||src.HasSpiritSword()||src.HasHybridStrike()||src.UsingSpiritStrike())
								var/Heal=Damage*P.EnergySiphon//Energy siphon is a value from 0.1 to 1 which reduces damage and heals energy.
								if(src.HasSpiritSword())
									Heal*=src.GetSpiritSword()
								else if(src.HasHybridStrike())
									Heal*=src.GetHybridStrike()
								Damage-=Heal//negated
								P.HealEnergy(Heal)
								log2text("Damage","After Energy Siphon","damageDebugs.txt","[src.ckey]/[src.name]")
								log2text("Damage",Damage,"damageDebugs.txt","[src.ckey]/[src.name]")

						if(src.AttackQueue)
							if(src.AttackQueue.Dunker)
								if(P.Launched)
									P.Dunked=src.AttackQueue.Dunker
									LightAttack=0
									NoKB=0
									SureKB=1
									Knock_Distance+=2*src.AttackQueue.Dunker
							if(src.AttackQueue.MortalBlow)
								if(prob(20*src.AttackQueue.MortalBlow))
									var/MortalDamage = P.Health * 0.15
									P.LoseHealth(MortalDamage)
									P.WoundSelf(MortalDamage)
									P.MortallyWounded+=1
									src << "<b><font color=#ff0000>You mortally injure [P]!</font></b>"
							if(src.AttackQueue.InstantStrikes && AttackQueue.InstantStrikesPerformed>=1)
								var/mod =  1 - (0.25 * AttackQueue.InstantStrikesPerformed)
								if(mod <= 0)
									mod = 0.1
								Damage *= mod
								log2text("Damage","After Instant Strikes","damageDebugs.txt","[src.ckey]/[src.name]")
								log2text("Damage",Damage,"damageDebugs.txt","[src.ckey]/[src.name]")
						src.DoDamage(P, Damage, UnarmedAttack, SwordAttack, SecondStrike, ThirdStrike) //melee dmg
						if(src.HasPassive("MonkeyKing", BuffsOnly = 1))
							if(prob(GetPassive("MonkeyKing", BuffsOnly = 1) * 25))
								Damage = min_max_scaling(Damage)
								summonMonkeySoldier(Damage, GetPassive("MonkeyKing", BuffsOnly = 1))

						if(src.UsingAnsatsuken())
							src.HealMana(Damage/20 * (SagaLevel/8), 1)

						var/OtherDmg=min_max_scaling(Damage+src.GetIntimidation())*(1+(2*src.GetGodKi()))

						if(src.UsingZornhau()&&src.HasSword())
							switch(s.Class)
								if("Wooden")
									OtherDmg*=1
								if("Light")
									OtherDmg*=1
								if("Medium")
									OtherDmg*=1.25
								if("Heavy")
									OtherDmg*=1.5
							if(src.UsingZornhau()>1)
								OtherDmg*=src.UsingZornhau()/1.5
							if(src.Saga=="Weapon Soul"&&src.SagaLevel>=2)
								OtherDmg*=1.25
						if(src.UsingKendo()&&src.HasSword())
							if(s.Class=="Wooden")
								OtherDmg*=(1+(src.UsingKendo()*0.5))
							else
								OtherDmg*=(1+(src.UsingKendo()*0.25))

						if(src.UsingCriticalImpact())
							OtherDmg*=1.5

						var/Shocked=0
						if(src.AttackQueue)
							if(src.AttackQueue.HitSparkDispersion)
								DisperseX=rand((-1)*src.AttackQueue.HitSparkDispersion,src.AttackQueue.HitSparkDispersion)
								DisperseY=rand((-1)*src.AttackQueue.HitSparkDispersion,src.AttackQueue.HitSparkDispersion)
							if(src.AttackQueue.PushOut)
								var/Shockwaves=src.AttackQueue.PushOutWaves
								var/ShockSize=src.AttackQueue.PushOut
								var/ShockIcon=src.AttackQueue.PushOutIcon
								for(var/wav=Shockwaves, wav>0, wav--)
									KenShockwave(P,icon=ShockIcon,Size=ShockSize)
									ShockSize/=2
								Shocked=1

						src.HitEffect(P, UnarmedAttack, SwordAttack, SecondStrike, ThirdStrike, DisperseX, DisperseY)
						if(src.AttackQueue)
							if(src.AttackQueue.WarpAway)
								WarpEffect(P, src.AttackQueue.WarpAway)

						if(src.UsingVortex()&&OtherDmg>=3)
							for(var/mob/m in oview(round(OtherDmg/3,1),src))
								m.AddSlow(max(OtherDmg/3,5), src)

						if(OtherDmg >=3||src.AttackQueue&&src.QueuedKBAdd()||SureKB)
							if(!Shocked)
								KenShockwave(P,Size=max(OtherDmg*GoCrand(0.04,0.4),0.2),PixelX=DisperseX,PixelY=DisperseY, Time=6)
							var/QuakeIntensity=OtherDmg
							if(QuakeIntensity>24)
								QuakeIntensity=24
							spawn()
								P.Earthquake(QuakeIntensity,-4,4,-4,4)

						if((SureKB||src.AttackQueue&&src.QueuedKBAdd())&&!NoKB)
							Knock_Distance=round(Knock_Distance)
							if(SureKB&&Knock_Distance<max(SureKB,5))
								Knock_Distance=max(SureKB,5)
							if(!src.AttackQueue||src.AttackQueue&&!src.AttackQueue.Grapple)
								if(P.HasPassive("Blubber", BuffsOnly=1 ))
									P.Knockback(Knock_Distance * (0.25 * P.GetPassive("Blubber",BuffsOnly=1)),src)
									Knock_Distance*= 1 - (0.25 * P.GetPassive("Blubber", BuffsOnly=1))
								src.Knockback(Knock_Distance,P)

						if(src.AttackQueue)

							if(src.AttackQueue.Launcher)
								var/Time=src.AttackQueue.Launcher
								if(!P.Launched)
									spawn()
										LaunchEffect(src, P, Time)
								else
									P.Launched+=5

							if(src.AttackQueue.InstantStrikes)

								if(src.AttackQueue.InstantStrikesDelay)
									sleep(src.AttackQueue.InstantStrikesDelay)
								if(src.AttackQueue.InstantStrikesPerformed<src.AttackQueue.InstantStrikes-1)
									src.AttackQueue.InstantStrikesPerformed++
									goto STRIKE

							src.QueuedHitMessage(P)//Displays hit message, if it exists
							if(src.AttackQueue.SpecialEffect)
								if(src.AttackQueue.SpecialEffect=="Darkness")
									var/image/i=image(icon='Night.dmi', layer=MOB_LAYER+1)
									for(var/turf/t in Turf_Circle(P, src.AttackQueue.SpecialEffectRange))
										spawn(rand(2,8))
											t.overlays+=i
											spawn(20)
												t.overlays-=i
								if(src.AttackQueue.SpecialEffect=="Ice")
									for(var/turf/T in Turf_Circle(P,src.AttackQueue.SpecialEffectRange))
										spawn(rand(4,8))new/turf/Ice1(locate(T.x, T.y, T.z))
										spawn(rand(4,8))Destroy(T)
								if(src.AttackQueue.SpecialEffect=="Fire")
									for(var/turf/T in Turf_Circle(P,src.AttackQueue.SpecialEffectRange))
										spawn(rand(4,8))new/turf/Waters/Water7(locate(T.x, T.y, T.z))
										spawn(rand(4,8))Destroy(T)
								if(src.AttackQueue.SpecialEffect=="Thunder")
									LightningBolt(P,src.AttackQueue.SpecialEffectRange)
								if(src.AttackQueue.SpecialEffect=="Smash")
									for(var/turf/T in Turf_Circle(P,src.AttackQueue.SpecialEffectRange))
										sleep(-1)
										Dust(T)
							if(src.AttackQueue.Grapple)
								src.Grab_Mob(P, Forced=1)
							if(src.AttackQueue.Explosive)
								Bang(P.loc, src.AttackQueue.Explosive)
							if(src.AttackQueue.Shining)
								P.Shockwave(src.AttackQueue.Shining, 1)
							if(src.AttackQueue.MultiHit)
								src.AttackQueue.HitsUsed++
								if(src.AttackQueue.InstantStrikes)
									src.AttackQueue.InstantStrikesPerformed=0
								if(src.AttackQueue.HitsUsed>=src.AttackQueue.MultiHit)
									src.AttackQueue.HitsUsed=0
									src.ClearQueue()
									sleep()
							else
								if(!src.AttackQueue.Combo)
									src.ClearQueue()
									sleep()
								else if(src.AttackQueue.Combo)
									if(src.AttackQueue.InstantStrikes)
										src.AttackQueue.InstantStrikesPerformed=0
									if(src.AttackQueue.ComboPerformed>=src.AttackQueue.Combo)
										src.ClearQueue()
										sleep()


				else
					if(P.CheckSpecial("Ultra Instinct"))
						if(src.AttackQueue)
							if(src.AttackQueue.HitSparkIcon)
								DisperseX=rand((-1)*src.AttackQueue.HitSparkDispersion,src.AttackQueue.HitSparkDispersion)
								DisperseY=rand((-1)*src.AttackQueue.HitSparkDispersion,src.AttackQueue.HitSparkDispersion)
								src.HitEffect(P, UnarmedAttack, SwordAttack, SecondStrike, ThirdStrike, DisperseX, DisperseY)
						UltraPrediction2(P, src)
					else if(src.AttackQueue&&src.AttackQueue.NoWhiff)
						P.dir=get_dir(P,src)
						flick("Attack", P)
						if(!LightAttack)
							KenShockwave(P,icon='KenShockwave.dmi',Size=(src.GetIntimidation()+P.GetIntimidation())*0.4,PixelX=((P.x-src.x)*(-16)+pick(-12,-8,8,12)),PixelY=((P.y-src.y)*(-16)+pick(-12,-8,8,12)), Time=6)
						if(src.AttackQueue&&src.AttackQueue.DrawIn)//Queued techniques like Axe Kick, Headbutt, and GET DUNKED.
							AddAttracting((src.AttackQueue.DrawIn*src.QueuedDamage(P)),P)
					else if(!Accuracy_Formula(src,P,BaseChance=(global.WorldWhiffRate))&&!src.NoWhiff||Dodged)
						spawn()
							Dodge(P)
					else
						P.dir=get_dir(P,src)
						flick("Attack", P)
						if(!LightAttack)
							KenShockwave(P,icon='KenShockwave.dmi',Size=max((src.GetIntimidation()+P.GetIntimidation())*GoCrand(0.04,0.4),0.2),PixelX=((P.x-src.x)*(-16)+pick(-12,-8,8,12)),PixelY=((P.y-src.y)*(-16)+pick(-12,-8,8,12)), Time=6)
						if(P.UsingAnsatsuken())
							P.HealMana(P.SagaLevel)
						if(src.AttackQueue&&src.AttackQueue.DrawIn)//Queued techniques like Axe Kick, Headbutt, and GET DUNKED.
							AddAttracting((src.AttackQueue.DrawIn*src.QueuedDamage(P)),P)
					if(src.AttackQueue)
						spawn()
							src.QueuedMissMessage()//displays miss message, clears queue, and does any effects.

			if(forcewarp)
				if(src.StyleActive=="Secret Knife")
					if(!locate(/obj/Skills/Projectile/Secret_Knives, src))
						src.AddSkill(new/obj/Skills/Projectile/Secret_Knives)
					for(var/obj/Skills/Projectile/Secret_Knives/sk in src)
						src.UseProjectile(sk)
				if(src.StyleActive=="Blade Singing")
					if(!locate(/obj/Skills/Projectile/Murder_Music, src))
						src.AddSkill(new/obj/Skills/Projectile/Murder_Music)
					for(var/obj/Skills/Projectile/Murder_Music/sk in src)
						if(src.CheckSlotless("Legend of Black Heaven"))
							if(sk.IconLock=='CheckmateKnives.dmi')
								sk.IconLock='Soundwave.dmi'
						src.UseProjectile(sk)

			if(Delay<=0.5)
				Delay=0.5
	else
		var/TurfDamage=(src.potential_power_mult*src.PowerBoost*src.Power_Multiplier*src.AngerMax)*(src.GetStr(3)+src.GetFor(2)+src.GetIntimidation()+(10*src.GetWeaponBreaker()))
		for(var/turf/T in get_step(src,src.dir))
			Melee_Graphics()
			T.Health-=TurfDamage
			if(T.Health<=0) Destroy(T)
			return
		for(var/obj/P in get_step(src,src.dir))
			if(!P.Attackable)
				continue
			Melee_Graphics()
			for(var/obj/Seal/S in P)
				if(src.ckey!=S.Creator)
					TurfDamage=0
			if(P.Destructable)
				if(P.Health<=TurfDamage)
					Destroy(P)
			return
		if(src.HasSpecialStrike())
			Melee_Graphics()
			NextAttack=world.time
			if(src.CheckSpecial("Ray Gear"))
				if(src.AttackQueue)
					if(src.AttackQueue.Warp)
						if(!locate(/obj/Skills/Projectile/Homing_Ray_Missiles, src))
							src.AddSkill(new/obj/Skills/Projectile/Homing_Ray_Missiles)
						for(var/obj/Skills/Projectile/Homing_Ray_Missiles/pc in src)
							src.UseProjectile(pc)
					else
						if(!locate(/obj/Skills/Projectile/Plasma_Cannon, src))
							src.AddSkill(new/obj/Skills/Projectile/Plasma_Cannon)
						for(var/obj/Skills/Projectile/Plasma_Cannon/pc in src)
							src.UseProjectile(pc)
					src.ClearQueue()
					NextAttack+=15
				else
					if(!locate(/obj/Skills/Projectile/Machine_Gun_Burst, src))
						src.AddSkill(new/obj/Skills/Projectile/Machine_Gun_Burst)
					for(var/obj/Skills/Projectile/Machine_Gun_Burst/pc in src)
						src.UseProjectile(pc)
					NextAttack+=15
			else if(src.CheckSpecial("Wisdom Form"))
				if(!locate(/obj/Skills/Projectile/Wisdom_Form_Blast, src))
					src.AddSkill(new/obj/Skills/Projectile/Wisdom_Form_Blast)
				for(var/obj/Skills/Projectile/Wisdom_Form_Blast/pc in src)
					src.UseProjectile(pc)
				NextAttack+=15
			else if(src.CheckSlotless("OverSoul"))
				if(!locate(/obj/Skills/AutoHit/DurendalPressure, src))
					src.AddSkill(new/obj/Skills/AutoHit/DurendalPressure)
				for(var/obj/Skills/AutoHit/DurendalPressure/pc in src)
					src.Activate(pc)
				NextAttack+=15
			else if(src.CheckSlotless("Heavenly Ring Dance"))
				if(src.Target&&src.Target!=src)
					src.Target.Frozen=1
					src.Target.AddCrippling(20)
					if(src.Target.SenseRobbed<(src.SenseUnlocked-1)&&!src.AttackQueue&&src.TotalFatigue<50&&!BreakAttackRate)
						RecoverImage(src.Target)
						src.Target.SenseRobbed++
						src.GainFatigue(10)
						if(src.Target.SenseRobbed==1)
							src.Target << "You've been stripped of your sense of touch! You find it harder to move!"
						else if(src.Target.SenseRobbed==2)
							src.Target << "You've been stripped of your sense of smell! You find it harder to breathe!"
						else if(src.Target.SenseRobbed==3)
							src.Target << "You've been stripped of your sense of taste! You find it harder to speak!"
						else if(src.Target.SenseRobbed==4)
							src.Target << "You've been stripped of your sense of hearing! You find it harder to hear!"
						else if(src.Target.SenseRobbed==5)
							src.Target << "You've been stripped of your sense of sight! You find it harder to see!"
							animate(src.Target.client, color = list(-1,0,0, 0,-1,0, 0,0,-1, 1,1,1), time = 5)
						else if(src.Target.SenseRobbed==6)
							src.Target << "You've been stripped of your sixth sense! Your mind is clouded and your abilities are crippled!"
					else
						src.ClearQueue()
						src.Activate(new/obj/Skills/AutoHit/Heavenly_Ring_Dance)
						for(var/obj/Skills/Buffs/SlotlessBuffs/Heavenly_Ring_Dance/TH in usr)
							usr.UseBuff(TH)

					NextAttack+=30
					sleep(10)
					src.Target.Frozen=0
				else
					src.Activate(new/obj/Skills/AutoHit/Heavenly_Ring_Dance_Burst)
					for(var/obj/Skills/Buffs/SlotlessBuffs/Heavenly_Ring_Dance/TH in usr)
						usr.UseBuff(TH)
			else if(src.CheckSlotless("Libra Armory")&&src.AttackQueue)
				if(!locate(/obj/Skills/Projectile/Libra_Slash, src))
					src.AddSkill(new/obj/Skills/Projectile/Libra_Slash)
				for(var/obj/Skills/Projectile/Libra_Slash/pc in src)
					src.UseProjectile(pc)
				src.ClearQueue()
				NextAttack+=15
			else if(src.CheckSlotless("Spirit Bow"))
				if(!locate(/obj/Skills/Projectile/Aether_Arrow, src))
					src.AddSkill(new/obj/Skills/Projectile/Aether_Arrow)
				for(var/obj/Skills/Projectile/Aether_Arrow/pc in src)
					src.UseProjectile(pc)
				NextAttack+=15
			return
*/


// STYLES //

/* 





    North_Star_Style
        SignatureTechnique=3
        Copyable=0
        StyleStr=1.25
        StyleEnd=1.75
        ElementalClass="Earth"
        StyleActive="North Star"
        passives = list("HardStyle" = 3, "SoftStyle" = 3, "UnarmedDamage" = 3, "CounterMaster" = 5)
        HardStyle=3
        SoftStyle=3
        UnarmedDamage=3
        CounterMaster=5
        HitSpark='HitsparkStar.dmi'
        HitX=0
        HitY=0
        HitTurn=0
        Finisher="/obj/Skills/Queue/Finisher/Pressure_Point"
        verb/North_Star_Style()
            set hidden=1
            src.Trigger(usr)
    Imperial_Style
        SignatureTechnique=3
        Copyable=0
        StyleStr=1.5
        StyleFor=1.5
        ElementalClass=list("Water", "Fire", "Earth", "Wind", "Poison")
        ElementalOffense="Void"
        ElementalDefense="Void"
        passives = list("DarknessFlame" = 2, "UnarmedDamage" = 1, "SpiritHand" = 4, "Void" = 1)
        DarknessFlame=2
        UnarmedDamage=1
        SpiritHand=1
        Void=1
        name="Imperial Devil Style"
        StyleActive="Imperial Devil"
        Finisher="/obj/Skills/Queue/Finisher/Imperial_Assessment"
        verb/Imperial_Style()
            set hidden=1
            src.Trigger(usr)
    East_Star_Style
        SignatureTechnique=3
        Copyable=0
        StyleEnd=1.5
        StyleSpd=1.5
        passives = list("SoftStyle" = 3, "SoulFire" = 3, "CyberStigma" = 3, "CounterMaster" = 3, "VoidField" = 10, "DeathField" = 10)
        SoftStyle=3
        ManaSeal=3
        CyberStigma=3
        CounterMaster=3
        VoidField=10
        DeathField=10
        NoStaff = 0
        StyleActive="East Star"
        ElementalClass=list("Water", "Fire", "Earth", "Wind", "Poison")
        Finisher="/obj/Skills/Queue/Finisher/Over_The_Horizon"
        verb/East_Star_Style()
            set hidden=1
            src.Trigger(usr)
    Atomic_Karate_Style
        SignatureTechnique=3
        Copyable=0
        StyleStr=1.5
        StyleFor=1.5
        passives = list("SpiritHand" = 4, "SpiritFlow" = 1, "CyberStigma" = 4, "PureDamage" = 2, "PureReduction" = 2)
        NoStaff = 0
        SpiritHand=1
        SpiritFlow=1
        CyberStigma=3
        ElementalClass=list("Water", "Fire", "Earth", "Wind", "Poison")
        StyleActive="Atomic Karate"
        ElementalOffense="Ultima"
        ElementalDefense="Ultima"
        Finisher="/obj/Skills/Queue/Finisher/Atomic_Split"
        verb/Atomic_Karate_Style()
            set hidden=1
            src.Trigger(usr)

			*/