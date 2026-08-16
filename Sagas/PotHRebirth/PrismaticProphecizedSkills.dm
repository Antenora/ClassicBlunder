//Style
/obj/Skills/Buffs/NuStyle/SwordStyle //T1
	Fight_or_Flight
		StyleStr = 1.15
		StyleFor = 1.15
		StyleOff = 1.05
		StyleDef = 1.05
		StyleActive = "Fight or Flight"
		passives = list("HybridStyle" = "MysticStyle", "FocusShiftRelease" = 2)
		verb/Fight_or_Flight()
			set hidden=1
			src.Trigger(usr)

	Mountain_King //T2
		StyleStr = 1.25
		StyleFor = 1.25
		StyleOff = 1.15
		StyleDef = 1.10
		StyleSpd = 1.10
		StyleActive = "Mountain King"
		passives = list("HybridStyle" = "MysticStyle", "DoubleStrike" = 1, "FocusShiftRelease" = 4)
		verb/Mountain_King()
			set hidden=1
			src.Trigger(usr)

	Dreamlike_Savior//T3
		StyleStr = 1.35
		StyleFor = 1.35
		StyleOff = 1.25
		StyleDef = 1.20
		StyleSpd = 1.20
		StyleActive = "Dreamlike Savior"
		passives = list("HybridStyle" = "MysticStyle",    \
		"DoubleStrike" = 2, "Deflection" = 2, "FocusShiftRelease" = 5)
		verb/Dreamlike_Savior()
			set hidden=1
			src.Trigger(usr)

	Afterlife//T4
		StyleStr = 1.50
		StyleFor = 1.50
		StyleOff = 1.40
		StyleDef = 1.35
		StyleSpd = 1.35
		StyleActive = "Afterlife"
		passives = list("HybridStyle" = "MysticStyle",\
		"DoubleStrike" = 2, "TripleStrike" = 0.5, "Deflection" = 2,  "PUSpike" = 50, "FocusShiftRelease" = 6)
		verb/Afterlife()
			set hidden=1
			src.Trigger(usr)
// Skills
obj
	Skills/Buffs/SpecialBuffs
		Hyperdeath_Mode
			BuffName = "Hyperdeath Mode"
			StrMult = 1.25
			EndMult = 1.10
			SpdMult = 1.15
			ForMult = 1.25
			RecovMult = 1.10
			passives = list( "TechniqueMastery" = 2,    \
			"AfterImages" = 1, "AfterImageSkin" = "Rainbow", "Health Obfuscation" = 1, "FocusShiftRelease" = 5, "FocusShiftMastery" = 1, "FocusShiftBurst" = 0.25)
			FlashChange = 1
			KenWaveIcon = 'Unbound.dmi'
			KenWave = 1
			KenWaveSize = 1
			KenWaveX = 72
			KenWaveY = 72
			KenWaveBlend = 2
			KenWaveTime = 5
			ActiveMessage = "awakens their Hyperdeath state!"
			OffMessage = "returns to their normal self..."
			adjust(mob/p)
				var/pLv = p.SagaLevel
				StrMult = 1.25 + (0.01 * pLv)
				ForMult = 1.25 + (0.01 * pLv)
				SpdMult = 1.15 + (0.01 * pLv)
				EndMult = 1.10 + (0.01 * pLv)
				RecovMult = 1.10 + (0.01 * pLv)
				passives = list("TechniqueMastery" = 2,    \
				 "AfterImages" = 1, "AfterImageSkin" = "Rainbow", "Health Obfuscation" = 1, "FocusShiftRelease" = 5+(pLv*2), "FocusShiftMastery" = 1+(pLv*2), "FocusShiftBurst" = 0.25+(pLv/2))
				if(pLv > 4)
					passives = list("TechniqueMastery" = 2,    \
					 "AfterImages" = 1, "AfterImageSkin" = "Rainbow", "GodKi" = min(max((pLv - 4) * 0.25, 0), 0.5), "Health Obfuscation" = 1, "FocusShiftRelease" = 5+(pLv*1.5), "FocusShiftMastery" = 1+(pLv*2), "FocusShiftBurst" = 0.25+(pLv/2))
			verb/Hyperdeath_Mode()
				set category = "Skills"
				adjust(usr)
				if((usr.HyperdeathMeterCurrent < usr.HyperdeathThreshold) && (!usr.CheckSpecial("Hyperdeath Mode")))
					usr << "You haven't accumulated enough power yet! <Requires [usr.HyperdeathThreshold]% power.>"
				else
					src.Trigger(usr)
					usr.HyperMeterUpdate()

	Skills/Buffs/SlotlessBuffs
		ChaosSaber
			MakesSword=1
			BuffName="Chaos Saber"
			SwordName="Spookysword"
			SwordIcon='Spookysword.dmi'
			SwordX=-32
			SwordY=-32
			FocusShifter=1
			FocusShiftType="STR"
			FocusShiftBoost=2
			SwordClass="Medium"
			Cooldown = 1
			SwordAscension=3
			ActiveMessage="readies CHAOS SABER!"
			OffMessage="dispels the CHAOS SABER."
			adjust(mob/p)
				MakesSword = 1
				SwordAscension = 2
				StrMult = 1.35
				ForMult = 1.15
				PowerMult = 1.15
				EnergyHeal=1
				passives = list("SwordAscension" = 2, "PUSpike" = 25, "KiControl" = 1,   \
				"DoubleStrike" = 0.5, "CriticalBlock" = 0.05, "ManaGeneration" = 1)
				if(p.SagaLevel>=3)
					SwordAscension=p.SagaLevel
					StrMult=1.50
					ForMult=1.25
					PowerMult=1.20
					passives = list("SwordAscension"=p.SagaLevel, "Secret Knives" = "ChaosKnife", "Tossing"=2, "PUSpike"=35,"KiControl" = 1,"Chaos Buster" = 1, \
					"DoubleStrike" = 1, "CriticalBlock" = 0.10, "ManaGeneration" = 2)
				if(p.SagaLevel>=4)
					MakesSecondSword=1
					StrMult=1.60
					ForMult=1.35
					PowerMult=1.25
					ActiveMessage="manifests their Chaos Sabers in a burst of prismatic light."
					OffMessage="dispels the Chaos Sabers."
					passives = list("SwordAscension"=p.SagaLevel, "SwordAscensionSecond"=p.SagaLevel, "Secret Knives" = "ChaosKnife", "Tossing"=2, "PUSpike"=50, "KiControl" = 1, "Chaos Buster" = 1,  \
					"DoubleStrike" = 1.5,  "CriticalBlock" = 0.15, "ManaGeneration" = 3)
				if(p.SagaLevel>=5)
					MakesSecondSword=1
					StrMult=1.65
					ForMult=1.40
					PowerMult=1.30
					passives = list("SwordAscension"=p.SagaLevel, "SwordAscensionSecond"=p.SagaLevel, "Secret Knives" = "ChaosKnife", "Tossing"=2, "PUSpike"=50, "KiControl" = 1, "Chaos Buster" = 1,  \
					"DoubleStrike" = 2, "TripleStrike" = 0.5,  "CriticalBlock" = 0.15, "ManaGeneration" = 4)
			verb/Chaos_Saber()
				set category="Skills"
				if(usr.CheckSlotless("Chaos Buster"))
					var/obj/Skills/Buffs/SlotlessBuffs/ChaosBuster/cb = locate(/obj/Skills/Buffs/SlotlessBuffs/ChaosBuster) in usr.contents
					cb.Trigger(usr)
				src.Trigger(usr)
		ChaosBuster
			BuffName="Chaos Buster"
			MakesStaff=1
			FlashDraw=1
			StaffName="Chaos Buster"
			StaffIcon='Aether Bow.dmi'
			ActiveMessage="readies CHAOS BUSTER!"
			OffMessage="dispels their CHAOS BUSTER."
			FocusShifter=1
			FocusShiftType="FOR"
			FocusShiftBoost=2
			StaffAscension=2
			adjust(mob/p)
				StrMult=1.15
				ForMult=1.35
				PowerMult = 1.15
				StaffAscension=2
				passives = list("KiControl" = 1, "StaffAscension" = 2, "Chaos Buster" = 1,   "Godspeed" = 1, "Skimming" = 1, "MovingCharge" = 1, "QuickCast" = 1)
				if(p.SagaLevel>=3)
					passives = list("KiControl" = 1, "StaffAscension" = 3, "Chaos Buster" = 2,   "Godspeed" = 2, "Skimming" = 1, "MovingCharge" = 1, "QuickCast" = 1)
					StrMult=1.25
					ForMult=1.50
					PowerMult = 1.20
					StaffAscension=3
				if(p.SagaLevel>=4)
					passives = list("KiControl" = 1, "StaffAscension" = 4, "Chaos Buster" = 2,   "Godspeed" = 2, "Skimming" = 1, "MovingCharge" = 1, "QuickCast" = 2,)
					StrMult=1.30
					ForMult=1.60
					PowerMult = 1.25
					StaffAscension=4
				if(p.SagaLevel>=5)
					passives = list("KiControl" = 1, "StaffAscension" = p.SagaLevel, "Chaos Buster" = 2,   "Godspeed" = 2, "Skimming" = 1, "MovingCharge" = 1, "QuickCast" =3)
					StrMult=1.30
					ForMult=1.60
					PowerMult = 1.25
					StaffAscension=p.SagaLevel
			verb/Transfigure_Chaos_Buster()
				set category="Utility"
				set hidden = 1
				var/Choice
				if(!usr.BuffOn(src))
					var/Lock=alert(usr, "Do you wish to alter the icon used?", "Weapon Icon", "No", "Yes")
					if(Lock=="Yes")
						src.StaffIcon=input(usr, "What icon will your Chaos Buster use?", "Chaos Buster Icon") as icon|null
						src.StaffX=input(usr, "Pixel X offset.", "Chaos Buster Icon") as num
						src.StaffY=input(usr, "Pixel Y offset.", "Chaos Buster Icon") as num
					Choice=input(usr, "What class of gun do you want your Chaos Buster to be?", "Transfigure Chaos Buster") in list("Light", "Medium", "Heavy")
					switch(Choice)
						if("Light")
							src.StaffClass="Wand"
						if("Medium")
							src.StaffClass="Rod"
						if("Heavy")
							src.StaffClass="Staff"
					usr << "Chaos Buster class set as [Choice]!"
				else
					usr << "You can't set this while using Chaos Buster."
			verb/Chaos_Buster()
				set category="Skills"
				if(usr.CheckSlotless("Chaos Saber"))
					var/obj/Skills/Buffs/SlotlessBuffs/ChaosSaber/cb = locate(/obj/Skills/Buffs/SlotlessBuffs/ChaosSaber) in usr.contents
					cb.Trigger(usr)
				src.Trigger(usr)

	Skills/Projectile
		ChaosBusterShot // Fired from Chaos Saber too at a higher Saber level, requires 10 mana min to use with Chaos Saber so you don't spam text chat with "can't use"
			Radius=0
			DamageMult=0.25
			AccMult=0.5
			StrScaling=0.5
			ForScaling=0.5
			EndEffectiveness=1
			Distance=30
			Homing=1
			ManaCost=2
			Piercing=1
			AttackReplace=1
			Striking=1
			Blasts=5
			IconLock='ChaosBuster - Projectile.dmi'
			Variation=48
			Radius=1
		SuperChaosBusterShot
			Radius=0
			DamageMult=0.75
			AccMult=1
			StrScaling=1
			ForScaling=1
			EndEffectiveness=1
			Piercing=1
			IconSize=2
			Distance=30
			Homing=1
			ManaCost=4
			AttackReplace=1
			Striking=1
			Blasts=5
			IconLock='ChaosBuster - Projectile.dmi'
			Variation=48
			Radius=1

	Skills/AutoHit
		Shocker_Breaker
			ElementalClass="Wind"
			SpellElement="Air"
			FlickAttack=1
			Distance=6
			AdaptRate=1
			Area="Target"
			ForScaling=1.5
			DamageMult=6
			FocusShifter=1
			FocusShiftBoost=2
			Paralyzing=5
			Size=1
			Bolt=5
			BoltOffset=0
			HitSparkIcon='BLANK.dmi'
			HitSparkX=0
			HitSparkY=0
			WindUp=0.5
			ManaCost=10
			SpecialAttack=1
			CanBeDodged=1
			CanBeBlocked=0
			Cooldown=45
			WindupMessage="used <font size=+1>SHOCKER BREAKER!</font size>"
			verb/Shocker_Breaker()
				set category="Skills"
				adjust(usr)
				usr.Activate(src)

	Skills/Projectile
		ChaosSaberToss
			DamageMult=6
			AccMult=2
			Cooldown=45
			IconSize=1
			Homing = 1
			StrScaling = 1.5
			FocusShifter=1
			FocusShiftBoost=2
			Knockback=3
			ManaCost=5
			Trail='Trail - Flare.dmi'
			TrailSize=1
			IconLock='ChaosSaberProjectile.dmi'
			adjust(mob/p)
				DamageMult = initial(DamageMult)
			verb/ChaosSaberToss()
				set category="Skills"
				set hidden=0
				if(Using || cooldown_remaining)
					return FALSE
				if(usr.CheckSpecial("Hyperdeath Mode"))
					var/hyper_mana_cost = 15
					if(usr.ManaAmount < hyper_mana_cost)
						usr << "You need [hyper_mana_cost] mana."
						return FALSE
					if(!usr.Target || usr.Target == usr)
						usr << "You need a valid target."
						return FALSE
					adjust(usr)
					usr.ManaAmount -= hyper_mana_cost
					if(usr.ManaAmount < 0)
						usr.ManaAmount = 0
					src.Cooldown(1, null, usr)
					usr.SpawnMMOCrossMarkers(/obj/Skills/Projectile/ChaosSaberWave, usr.Target, 11)
					return TRUE
				adjust(usr)
				usr.UseProjectile(src)

		ChaosSaberWave
			YSpawnOffset=4
			DamageMult=20
			AccMult=2
			IconSize=1
			DirOverride=2
			Piercing=1
			Striking=1
			ManaCost=0
			Cooldown=0
			Trail='Trail - Flare.dmi'
			TrailSize=1
			IconLock='ChaosSaberProjectile.dmi'
			adjust(mob/p)
				DamageMult = initial(DamageMult) * glob.MMO_PROJ_DAMAGE_MULT
			verb/AOEFireball()
				set category="Skills"
				set hidden=1
				if(usr.CheckSpecial("Hyperdeath Mode"))
					adjust(usr)
					usr.UseProjectile(src)


obj/Skills/Buffs/SlotlessBuffs/Miracle_of_DreamsApply
	PowerGlows=list(1,0.8,0.8, 0,1,0, 0.8,0.8,1, 0,0,0)
	KenWave = 4
	KenWaveIcon='SparkleRainbow.dmi'
	HitSpark='Spiral_Hitspark.dmi'
	TopOverlayLock = 'RainbowAura.dmi'
	TopOverlayX = -32
	TimerLimit=20
	ActiveMessage="screams: <b><font color=#FF0000>N</font color><font color=#FF2900>O</font color><font color=#FF5200>T</font color><font color=#FF7C00>H</font color><font color=#FFA500>I</font color><font color=#FFCE00>N</font color><font color=#FFF800>G</font color> <font color=#B3FF00>I</font color><font color=#89FF00>S</font color> <font color=#37FF00>S</font color><font color=#0DFF00>T</font color><font color=#00FF1B>R</font color><font color=#00FF44>O</font color><font color=#00FF6E>N</font color><font color=#00FF97>G</font color><font color=#00FFC0>E</font color><font color=#00FFEA>R</font color> <font color=#00C0FF>T</font color><font color=#0097FF>H</font color><font color=#006EFF>A</font color><font color=#0044FF>N</font color> <font color=#0D00FF>O</font color><font color=#3700FF>U</font color><font color=#6000FF>R</font color> <font color=#B300FF>D</font color><font color=#DC00FF>R</font color><font color=#FF00F8>E</font color><font color=#FF00CE>A</font color><font color=#FF00A5>M</font color><font color=#FF007C>S</font color><font color=#FF0052>!</font color><font color=#FF0029>!</font color></b>"
	OffMessage="once again dreams as normal."
	TextColor="green"
	MagicNeeded=0

obj/Skills/Buffs/SlotlessBuffs/Miracle_of_Dreams
	EndYourself=1
	Cooldown=600
	KenWave=1
	KenWaveIcon='SparkleRainbow.dmi'
	KenWaveSize=4
	KenWaveX=50
	KenWaveY=50
	Range=20
	verb/Miracle_of_Dreams()
		set category="Skills"
		set name="Miracle of Dreams"
		var/mob/User = usr
		if(!User.party || !User.party.members || User.party.members.len == 0)
			User << "You're fighting all by yourself..."
			return
		if(src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return
		if(!altered)
			adjust(User)
		for(var/mob/m in User.party.members)
			if(!m || !ismob(m)) continue
			if(m.race.type in INORGANIC_RACES)
				User << "[m] is synthetic and cannot dream."
				m << "[User] tried to uplift your dreams, but you do not have those."
				continue
			if(m.race.type in CURSED_RACES)
				User << "[m]'s supernatural influence prevents them from truly dreaming.."
				m <<"[User] tried to inspire you to dream, but your supernatural gifts interferred."
				continue
			if(m.race.type in STAGNANT_RACES)
				User <<"[m] is a supernatural entity. They are incapable of dreaming."
				m <<"[User] tried to inspire you to dream, but your nature prevents you from lowering yourself to their level."
				continue
			ActiveMessage="lets their dream burst forth!!"
			var/obj/Skills/Buffs/SlotlessBuffs/Miracle_of_DreamsApply/applyBuff = new
			var/sl = User.SagaLevel
			var/OmegaPower=1
			var/extraP
			switch(sl)
				if(1 to 2)//this will never happen unless the skill is given unnaturally
					OmegaPower=1//which, i guess, given the subject matter, is more likely than you'd think
				if(3)
					OmegaPower=1
				if(4)
					OmegaPower=1
				if(5)
					OmegaPower=2
			switch(m.RebirthHeroType)
				if("Cyan")
					m << "Even if broken, you are more than a cage. <b>X-Slash is now Omega X-Slash!</b>"
					if(m.FinalHeroChoice=="White Pen of Hope")
						m << "Faint courage blossoms into unwavering determination! <b>Your DF went up!</b>"
						extraP = list("PureReduction" = 5)
					if(m.FinalHeroChoice=="Roaring Knight")
						m << "<i>Hear my voice. Look my way. I'm with you no matter what.</i> <b>Your AT went up!</b>"
						extraP = list("PureDamage" = 5, "Forever After" = 1)
				if("Purple")
					m << "Write what you know, right? <b>Rude Buster is now Omega Buster!</b>"
			applyBuff.PowerMult=1+(0.05*sl*sl)
			applyBuff.StrMult=1.25
			applyBuff.ForMult=1.25
			applyBuff.EndMult=1.25
			applyBuff.TimerLimit = 20 * (m.AscensionsAcquired+2)
			applyBuff.passives = list("OmegaPower" = OmegaPower) + extraP
			if(m == User)
				applyBuff.ActiveMessage="screams: <b><font color=#FF0000>N</font color><font color=#FF2900>O</font color><font color=#FF5200>T</font color><font color=#FF7C00>H</font color><font color=#FFA500>I</font color><font color=#FFCE00>N</font color><font color=#FFF800>G</font color> <font color=#B3FF00>I</font color><font color=#89FF00>S</font color> <font color=#37FF00>S</font color><font color=#0DFF00>T</font color><font color=#00FF1B>R</font color><font color=#00FF44>O</font color><font color=#00FF6E>N</font color><font color=#00FF97>G</font color><font color=#00FFC0>E</font color><font color=#00FFEA>R</font color> <font color=#00C0FF>T</font color><font color=#0097FF>H</font color><font color=#006EFF>A</font color><font color=#0044FF>N</font color> <font color=#0D00FF>O</font color><font color=#3700FF>U</font color><font color=#6000FF>R</font color> <font color=#B300FF>D</font color><font color=#DC00FF>R</font color><font color=#FF00F8>E</font color><font color=#FF00CE>A</font color><font color=#FF00A5>M</font color><font color=#FF007C>S</font color><font color=#FF0052>!</font color><font color=#FF0029>!</font color></b>"
			else
				applyBuff.ActiveMessage="'s dreams burst forth!"
			applyBuff.Trigger(m, 1)
		User.OMessage(1, null, "[User] manifests the dreams of [User.party.members.len == 1 ? "themselves" : "their party"]!")
		src.Cooldown(1, null, User)



/obj/Skills/AutoHit/Jarona
	name = "Jarona"
	Area = "Target"
	NeedsSword=0
	Distance = 16
	DamageMult = 5
	Knockback = 10
	StrScaling = 1
	EndEffectiveness = 1
	PassThrough = 1
	Rush = 1
	RushAfterImages = 1
	RushNoFlight = 1
	StopAtTarget = 1
	Copyable=6
	Cooldown = 75
	ComboMaster = 1
	GuardBreak = 1
	NoLock = 1
	NoAttackLock = 1
	ChargeWaveIcon   = 'BLANK.dmi'
	ActiveMessage = "rushes down the opponent and shouts 'JARONA'!"
	HeldSkill = TRUE
	ChargePeriod = 3
	SweetSpot = 1.5
	SweetSpotBenefit = 1.5
	adjust(mob/p)
		var/tmp/jaboner = pick("rushes down the opponent and shouts 'JARONA'!", "rushes down the opponent and shouts 'JA-Orange'!", "rushes down the opponent and shouts 'JA-st kidding'!")
		ActiveMessage = jaboner

	var/tmp/chain_active = FALSE
	var/tmp/chain_count = 0
	var/tmp/mob/chain_user = null
	var/tmp/mob/chain_target = null
	var/tmp/initial_charge_period = 3
	var/tmp/saved_cooldown = 75
	var/tmp/reengage_deadline = 0
	var/tmp/window_loop_running = FALSE


	proc/RollSweetSpot()
		var/min_ss = 3
		var/period_ticks = round(ChargePeriod * 10)
		var/window_ticks = max(1, round(SweetSpotWindow * 10))
		var/max_ss = max(min_ss, period_ticks - window_ticks)
		return rand(min_ss, max_ss) / 10

	proc/StartChain(mob/user, mob/target)
		chain_active = TRUE
		chain_user = user
		chain_target = target
		chain_count = 0
		DamageMult = 10
		ChargePeriod = initial_charge_period
		SweetSpotWindow = 0.3
		SweetSpot = RollSweetSpot()
		user.judgement_cut_chain_active = TRUE
		saved_cooldown = Cooldown > 0 ? Cooldown : initial(Cooldown)
		Cooldown = 0

	proc/EndChain(var/apply_cooldown = TRUE)
		if(!chain_active) return
		var/mob/user = chain_user
		chain_active = FALSE
		window_loop_running = FALSE
		if(user)
			user.judgement_cut_chain_active = FALSE
		chain_user = null
		chain_target = null
		chain_count = 0
		DamageMult = 10
		ChargePeriod = initial_charge_period
		SweetSpotWindow = 0.3
		SweetSpot = initial_charge_period / 2
		Cooldown = saved_cooldown > 0 ? saved_cooldown : initial(Cooldown)
		if(user)
			Using = 0
			cooldown_remaining = 0
			cooldown_start = 0
			if(apply_cooldown)
				src.Cooldown(1, null, user)

	proc/ScheduleReengageWindow(mob/user)
		if(window_loop_running) return
		window_loop_running = TRUE
		reengage_deadline = world.time + 10
		while(world.time < reengage_deadline)
			if(!chain_active)
				window_loop_running = FALSE
				return
			if(user.Stunned || user.Suspended || user.Launched || user.Stasis > 0 || user.KO)
				window_loop_running = FALSE
				EndChain()
				return
			if(!chain_target || chain_target.KO || chain_target.Stasis > 0 || chain_target.Health <= 0)
				window_loop_running = FALSE
				EndChain()
				return
			// hold has started again.
			if(user.held_skill == src)
				window_loop_running = FALSE
				reengage_deadline = world.time + 10
				return
			sleep(1)
		// Window expired
		if(chain_active && (!user.held_skill || user.held_skill != src))
			window_loop_running = FALSE
			EndChain()

	OnHeldRelease(mob/p, var/benefit, var/sweet_spot_hit = FALSE)
		if(!chain_active) return
		if(!sweet_spot_hit)
			EndChain()
			return
		if(!chain_target || chain_target.KO || chain_target.Stasis > 0 || chain_target.Health <= 0)
			EndChain()
			return
		chain_count++
		DamageMult = 10 * (1.2 ** (chain_count - 1))
		p.Target = chain_target
		p.Activate(src, ignoreCuck=TRUE, ignoreAttackLock=TRUE)
		p.judgement_cut_bonus_value = 1.2 ** (chain_count - 1)
		p.judgement_cut_bonus_chain_count = chain_count
		p.judgement_cut_bonus_end_time = world.time + 30
		ChargePeriod = max(0.6, initial_charge_period - (chain_count * 0.3))
		SweetSpotWindow = max(0.1, ChargePeriod * 0.1)
		SweetSpot = RollSweetSpot()
		p.held_skill_last_release = 0
		spawn() ScheduleReengageWindow(p)

	OnHeldFizzle(mob/p)
		if(chain_active)
			EndChain()
		// Safety net
		if(p)
			p.judgement_cut_chain_active = FALSE

	verb/Jarona()
		set category = "Skills"
		var/mob/p = usr
		if(!chain_active && cooldown_remaining)
			p << "<font color='red'>[name] is on cooldown.</font>"
			return
		if(!chain_active)
			if(!p.Target || p.Target == p || !ismob(p.Target))
				p << "<font color='red'>You need a target.</font>"
				return
			var/mob/T = p.Target
			if(T.KO || T.Stasis > 0 || T.Health <= 0)
				p << "<font color='red'>Invalid target.</font>"
				return
			if(get_dist(p, T) > Distance)
				p << "<font color='red'>Target is out of range.</font>"
				return
			StartChain(p, T)
		else
			if(world.time > reengage_deadline)
				EndChain()
				return
		p.BeginHeldSkill(src)
		if(p.held_skill != src && chain_active && chain_user == p)
			EndChain(apply_cooldown = FALSE)

#define HYPER_FILL_WIDTH 186
#define HYPER_MASK_RSC 'HyperdeathMeterMask.dmi'

//Meter
obj/HyperdeathMeterBarBG
	icon = 'HyperdeathMeter.dmi'
	icon_state = "Background"
	screen_loc = "CENTER-2.5,BOTTOM+3.1"
	layer = FLOAT_LAYER
	plane = FLOAT_PLANE
	mouse_opacity = 0

obj/HyperdeathMeterBarFill
	icon = 'HyperdeathMeter.dmi'
	icon_state = "FillActive"
	screen_loc = "CENTER-2.5,BOTTOM+3.1"
	layer = FLOAT_LAYER + 50
	plane = FLOAT_PLANE
	mouse_opacity = 0

	var/tmp/last_fill_width = -1

	New()
		..()

		filters = list(
			filter(
				type = "alpha",
				icon = HYPER_MASK_RSC,
				x = -HYPER_FILL_WIDTH
			)
		)

mob/var/tmp/obj/HyperdeathMeterBarBG/HyperBar
mob/var/tmp/obj/HyperdeathMeterBarFill/HyperBarFill

mob/proc/HyperMeterCreate()
	if(src.client && !src.HyperBar)
		src.HyperBar = new
		src.client.screen += src.HyperBar

	if(src.client && !src.HyperBarFill)
		src.HyperBarFill = new
		src.client.screen += src.HyperBarFill

mob/proc/HyperMeterUpdate()
	if(!client)
		return

	if(!HyperBar || !HyperBarFill)
		HyperMeterCreate()

	if(HyperdeathMeterCurrent <= 0)
		HyperBar.alpha = 0
		HyperBarFill.alpha = 0

		HyperBar.invisibility = 0
		HyperBarFill.invisibility = 0

		if(HyperBarFill.filters && HyperBarFill.filters.len)
			var/F = HyperBarFill.filters[1]
			animate(F)
			F:x = -HYPER_FILL_WIDTH

		HyperBarFill.last_fill_width = 0
		return

	HyperBar.alpha = 255
	HyperBarFill.alpha = 255

	HyperBar.invisibility = 0
	HyperBarFill.invisibility = 0

	if(!HyperBarFill.filters || !HyperBarFill.filters.len)
		HyperBarFill.filters = list(
			filter(
				type = "alpha",
				icon = HYPER_MASK_RSC,
				x = -HYPER_FILL_WIDTH
			)
		)

	var/percent = HyperdeathMeterCurrent / 100
	percent = min(max(percent, 0), 1)

	var/fill_width = round(HYPER_FILL_WIDTH * percent)
	fill_width = min(max(fill_width, 0), HYPER_FILL_WIDTH)

	if(CheckSpecial("Hyperdeath Mode") || HyperdeathMeterCurrent >= HyperdeathThreshold)
		HyperBarFill.icon_state = "FillActive"
	else
		HyperBarFill.icon_state = "FillInactive"

	if(fill_width != HyperBarFill.last_fill_width)
		var/F = HyperBarFill.filters[1]

		animate(F)
		F:x = fill_width - HYPER_FILL_WIDTH

		HyperBarFill.last_fill_width = fill_width


/*
obj/AttackMarker
	icon = 'MMOAttackMarker.dmi'
	icon_state = "WarningBox"
	layer = EFFECTS_LAYER
	mouse_opacity = 0

	var/mob/owner
	var/delay = 20
	var/projectile_type
	var/fire_dir = null

	New(loc, mob/O, projectile_path = null, custom_delay = null, custom_dir = null)
		..()

		owner = O

		if(ispath(projectile_path, /obj/Skills/Projectile))
			projectile_type = projectile_path

		if(!isnull(custom_delay))
			delay = custom_delay

		if(custom_dir)
			fire_dir = custom_dir

		spawn(delay)
			FireMMOAttack()

	proc/FireMMOAttack()
		if(!src || !loc)
			return

		if(!owner)
			del(src)
			return

		var/path = projectile_type

		if(!ispath(path, /obj/Skills/Projectile))
			path = /obj/Skills/Projectile/ChaosSaberWave

		var/obj/Skills/Projectile/p = new path

		p.adjust(owner)

		p.SpawnPosition = src

		if(fire_dir)
			p.DirOverride = fire_dir
		if(fire_dir == EAST)
			p.YSpawnOffset=0
			p.XSpawnOffset=-4
		if(fire_dir == WEST)
			p.YSpawnOffset=0
			p.XSpawnOffset=4
		if(fire_dir == NORTH)
			p.YSpawnOffset=-4
			p.XSpawnOffset=0
		if(fire_dir == SOUTH)
			p.YSpawnOffset=4
			p.XSpawnOffset=0

		owner.UseProjectile(p)

		del(src)

mob/proc/SpawnAttackMarker(path, Target)
	var/turf/T = get_turf(Target)

	if(!T)
		return

	new /obj/AttackMarker(T, src, path)

mob/proc/SpawnCheckerboardMarkers(projectile_path, Target, marker_range = 3)
	if(!Target)
		return

	var/turf/Center = get_turf(Target)
	if(!Center)
		return

	for(var/dx = -marker_range to marker_range)
		for(var/dy = -marker_range to marker_range)
			if((abs(dx) + abs(dy)) % 2 != 0)
				continue

			var/turf/T = locate(Center.x + dx, Center.y + dy, Center.z)
			if(!T)
				continue

			new /obj/AttackMarker(T, src, projectile_path)


mob/proc/SpawnCrossMarkers(projectile_path, Target, marker_range = 3)
	if(!Target)
		return

	var/turf/Center = get_turf(Target)
	if(!Center)
		return

	var/count = 0

	for(var/dx = -marker_range to marker_range)
		var/turf/T = locate(Center.x + dx, Center.y, Center.z)
		if(!T)
			continue

		var/side_dir

		if(dx > 0)
			side_dir = NORTH
		else
			side_dir = SOUTH

		var/marker_delay = 20 + round(count / 4)
		new /obj/AttackMarker(T, src, projectile_path, marker_delay, side_dir)

		count++

	sleep(10)

	for(var/dy = -marker_range to marker_range)

		var/turf/T = locate(Center.x, Center.y + dy, Center.z)
		if(!T)
			continue

		var/side_dir

		if(dy > 0)
			side_dir = EAST
		else
			side_dir = WEST

		var/marker_delay = 20 + round(count / 4)
		new /obj/AttackMarker(T, src, projectile_path, marker_delay, side_dir)

		count++*/

/strikeHook/prismaticHyperdeathAttacker
	stage = "post"
	fire(strike/S)
		var/mob/attacker = S.attacker
		var/val = S.dealt
		if((attacker.Saga=="Path of a Hero: Rebirth") && (attacker.RebirthHeroType=="Prismatic"))
			var/meterGain = min(max(val,0.1), 0.9)
			attacker.HyperdeathMeterCurrent=min(attacker.HyperdeathMeterCurrent+meterGain, 100)
			attacker.HyperMeterUpdate()

/strikeHook/prismaticHyperdeathDefender
	stage = "post"
	fire(strike/S)
		var/mob/defender = S.defender
		var/val = S.dealt
		if((defender.Saga=="Path of a Hero: Rebirth") && (defender.RebirthHeroType=="Prismatic"))
			var/meterGain = min(max(val,0.1), 0.2)
			defender.HyperdeathMeterCurrent=min(defender.HyperdeathMeterCurrent+meterGain, 100)
			defender.HyperMeterUpdate()
