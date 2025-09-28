
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Nox/The_Unholy_Wrath_of_the_Basilisk
	KenWave=1
	KenWaveIcon='Azure Crest.dmi'
	KenWaveSize=0.2
	KenWaveX=-785
	KenWaveY=-389
	IconTint=rgb(11, 159, 4)
	ManaGlow = "#000"
	ManaGlowSize=0.5
	NeedsHealth=10
	TooMuchHealth=11
	ActiveMessage = "RAAAAAHH RIIICKKKKYYYY"
	IconLock='Susanoo Blade.dmi'
	Earthshaking = 15
	Cooldown = -1
	LockX=-16
	LockY=-16
	adjust(mob/p)
		var/pot = p.Potential
		passives = list("TechniqueMastery" = 1 + round(pot/25, 0.25), "ManaSteal" = pot/10,"CursedWounds" = 1,"HeavyHitter" = 1, \
						"Extend" = 1, "Gum Gum" = 1, "Divine Technique" = 1, "SpiritFlow" =  max(1 + round(pot/25,1), 4), \
						"Juggernaut" = round(pot/30, 0.25), "EnergyLeak" = 5 - round(pot/50, 0.25), "EnergySteal" = pot, "AfterImages" = 2, "NoWhiff" = 1 )
		ForMult = 1.2 + (pot/200)
		StrMult = 1.2 + (pot/200)
		EndMult = 1.1 + (pot/200)
		DefMult = 1 - (pot/200)
		NeedsHealth = 10 + round(pot/10,1)
		TooMuchHealth = NeedsHealth + round(pot/20,1)
		