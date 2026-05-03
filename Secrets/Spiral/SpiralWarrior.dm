#define DARWIN_POKEDEX list("Spiral", "Inorganic", "Cursed", "Stagnant")

obj/Skills/Buffs/SlotlessBuffs/Spiral/ClobberApply
	StrMult=1.25
	ForMult=1.25
	TimerLimit=30
	ActiveMessage="is slugged in the face and focuses!"
	OffMessage="shakes off the effects of getting clobbered."

obj/Skills/Buffs/SlotlessBuffs/Spiral/Clobber
	applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/Spiral/ClobberApply
	AffectTarget=1
	EndYourself=1
	Range=5
	Cooldown=120
	ActiveMessage="screams LET ME SEE YOU GRIT THOSE TEETH!"
	verb/Clobber()
		set category="Skills"
		if(!usr.Target || usr.Target==usr)
			usr << "You need to target someone else."
			return
		if(!altered)
			adjust(usr)
			applyToTarget?:adjust(usr)
		src.Trigger(usr)

obj/Skills/Buffs/SlotlessBuffs/Spiral/InspiredEvoApply
	PowerGlows=list(1,0.8,0.8, 0,1,0, 0.8,0.8,1, 0,0,0)
	KenWave = 4
	KenWaveIcon='SparkleGreen.dmi'
	HitSpark='Spiral_Hitspark.dmi'
	TopOverlayLock = 'SpiralAura.dmi'
	TopOverlayX = -32
	TimerLimit=20
	ActiveMessage="screams <b>WHO THE HELL DO YOU THINK WE ARE?</b>"
	OffMessage="limits themselves once again."
	TextColor="green"
	MagicNeeded=0
	passives = list("SpiralPowerUnlocked" = 1)
obj/Skills/Buffs/SlotlessBuffs/Spiral/ImposedEvoApply
	PowerGlows=list(1,0.8,0.8, 0,1,0, 0.8,0.8,1, 0,0,0)
	BuffName="Desperate Evolution"
	KenWave = 4
	KenWaveIcon='SparkleRed.dmi'
	HitSpark='Spiral_Hitspark.dmi'
	TopOverlayLock = 'SpiralNemesisAura.dmi'
	TopOverlayX = -32
	TimerLimit=360
	ActiveMessage="screams: <b>DO YOU SERIOUSLY THINK WE'RE GONNA BE WIPED OUT BY THE LIKES OF YOU?!</b>"
	OffMessage="limits themselves once again."
	TextColor="red"
	MagicNeeded=0
	passives = list("SpiralPowerUnlocked" = 1)
	adjust(mob/p)
		switch(p.Health)
			if(1 to 10)
				passives = list("SpiralPowerUnlocked" = 7)
				HealthHeal=25
				p.passive_handler.Set("SpiralSpark", 1)
			if(11 to 30)
				passives = list("SpiralPowerUnlocked" = 4)
			if(31 to 50)
				passives = list("SpiralPowerUnlocked" = 3)
			if(51 to 70)
				passives = list("SpiralPowerUnlocked" = 2)
			if(71 to 100)
				passives = list("SpiralPowerUnlocked" = 1)
obj/Skills/Buffs/SlotlessBuffs/Spiral/Spiral_King
	PowerGlows=list(1,0.8,0.8, 0,1,0, 0.8,0.8,1, 0,0,0)
	BuffName="Spiral King"
	KenWave = 4
	KenWaveIcon='SparkleRed.dmi'
	HitSpark='Spiral_Hitspark.dmi'
	TopOverlayLock = 'SpiralNemesisAura.dmi'
	TopOverlayX = -32
	TimerLimit=360
	ActiveMessage="screams: <b>Do you possess the same sheer fortitude as I?! DO YOU?! I SAY, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NOT! AT! ALL</b>"
	OffMessage="limits themselves once again."
	TextColor="red"
	MagicNeeded=0
	passives = list("SpiralPowerUnlocked" = 1)
	adjust(mob/p)
		switch(p.Health)
			if(1 to 10)
				passives = list("SpiralPowerUnlocked" = 7)
				HealthHeal=25
			if(11 to 30)
				passives = list("SpiralPowerUnlocked" = 4)
			if(31 to 50)
				passives = list("SpiralPowerUnlocked" = 3)
			if(51 to 70)
				passives = list("SpiralPowerUnlocked" = 2)
			if(71 to 100)
				passives = list("SpiralPowerUnlocked" = 1)

obj/Skills/Buffs/SlotlessBuffs/Spiral/InspiredEvo
	EndYourself=1
	Cooldown=600
	KenWave=1
	KenWaveIcon='SparkleGreen.dmi'
	KenWaveSize=4
	KenWaveX=105
	KenWaveY=105
	Range=20
	ActiveMessage="screams WHEN THERE'S A WALL IN OUR WAY, WE DRILL RIGHT THROUGH IT!"
	verb/Inspired_Evolution()
		set category="Skills"
		set name="Inspired Evolution"
		var/mob/User = usr
		if(!User.party || !User.party.members || User.party.members.len == 0)
			User << "You need to be in a party to apply Inspired Evolution."
			return
		if(src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return
		if(!altered)
			adjust(User)
		for(var/mob/m in User.party.members)
			if(!m || !ismob(m)) continue
			if(m.race.type in INORGANIC_RACES && !m.passive_handler.Get("SpiralEngine"))
				User << "[m] is synthetic and cannot evolve."
				m << "[User] tried to inspire you to evolve, but it failed."
				return
			if(m.race.type in CURSED_RACES || (m.Secret &&  m.Secret != "Spiral"))
				User << "[m]'s biology is warped by the supernatural, they cannot evolve as you do."
				m <<"[User] tried to inspire you to evolve, but your supernatural gifts interferred."
				return
			if(m.race.type in STAGNANT_RACES)
				User <<"[m] is a supernatural entity. They are incapable of change."
				m <<"[User] tried to inspire you to evolve, but your nature prevents you from lowering yourself to their level."
				return
			ActiveMessage="screams WHEN THERE'S A WALL IN OUR WAY, TEAM [User] DRILLS RIGHT THROUGH IT!"
			var/obj/Skills/Buffs/SlotlessBuffs/Spiral/InspiredEvoApply/applyBuff = new
			var/secretLevel = User.secretDatum.currentTier
			var/SpiralPower=1
			m.passive_handler.Set("SpiralSpark", 1)
			switch(secretLevel)
				if(1 to 2)
					SpiralPower=1
				if(3)
					SpiralPower=2
				if(4)
					SpiralPower=3
				if(5)
					SpiralPower=7
			applyBuff.PowerMult=1+(0.05*secretLevel*secretLevel)
			applyBuff.StrMult=1.25
			applyBuff.ForMult=1.25
			applyBuff.EndMult=1.25
			applyBuff.TimerLimit = 20 * (m.AscensionsAcquired+2)
			applyBuff.passives = list("SpiralPowerUnlocked" = SpiralPower)
			applyBuff.Trigger(m, 1)
		User.OMessage(1, null, "[User] inspires the evolution of [User.party.members.len == 1 ? "themselves" : "their party"]!")
		src.Cooldown(1, null, User)
obj/Skills/Buffs/SlotlessBuffs/Spiral/Impose_Evolution
	EndYourself=1
	Cooldown=360
	KenWave=1
	KenWaveIcon='SparkleRed.dmi'
	KenWaveSize=4
	KenWaveX=105
	KenWaveY=105
	var/SpiralLevel=1
	ActiveMessage="screams: <b>DO YOU SERIOUSLY THINK WE'RE GONNA BE WIPED OUT BY THE LIKES OF YOU?!</b>"
	Range=200
	verb/Force_Evolution()
		set category="Skills"
		set name="Force Evolution"
		var/mob/User = usr
		if(!User.party || !User.party.members || User.party.members.len == 0)
			User << "You need to be in a party to apply Inspired Evolution."
			return
		if(src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return
		if(!altered)
			adjust(User)
		var/mob/m = User.Target
		if(m && ismob(m))
			var/obj/Skills/Buffs/SlotlessBuffs/Spiral/ImposedEvoApply/applyBuff = new
			m.passive_handler.Set("SpiralSpark", 1)
			applyBuff.StrMult=1.25
			applyBuff.ForMult=1.25
			applyBuff.EndMult=1.25
			applyBuff.ActiveMessage="[ActiveMessage]"
			applyBuff.passives = list("SpiralPowerUnlocked" = SpiralLevel)
			applyBuff.Trigger(m, 1)
		src.Cooldown(1, null, User)
obj/Skills/AutoHit/Spiral
	Impose_Evolution
		Cooldown=360
		Area="Target"
		Distance=15
		DamageMult=15
		HitSparkIcon='SparkleRed.dmi'
		HitSparkTurns=1
		HitSparkSize=5
		HitSparkCount=10
		HitSparkDispersion=1
		AdaptRate=1
		SpecialAttack=1
		BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Spiral/ImposedEvoApply"
		BuffSelf = "/obj/Skills/Buffs/SlotlessBuffs/Spiral/Spiral_King"
		verb/Impose_Evolution()
			set category="Skills"
			adjust(usr)
			usr.Activate(src)
/mob/proc/HandleSpiralUnlock(var/Stat, SL)
	var/CA=AscensionsAcquired
	var/TA=CA+SL
	var/Total
	if(TA>6)
		TA=6
	if(SL>=7&&CA>3)
		CA=3
	Total=PullAscensionStats(CA, TA, Stat)
	if(SL>=7)
		Total*=3
	if(isRace(SAIYAN)||isRace(HALFSAIYAN))
		switch(transUnlocked)
			if(0)
				Total*=1.4
			if(1)
				Total*=1.2
			if(2)
				Total*=1.5
			if(3)
				Total*=2
			if(4)
				Total*=2
			else
				Total*=1
	if((isRace(HUMAN) && Class=="Underdog") || NobodyOriginType=="Spirit")
		Total*=1+((SL)/5)
	return Total
