obj/Items/Sword/Heavy/Legendary/WeaponSoul/Sword_of_Hope//Durendal
	name="Sword of Hope"
	icon='Durendal.dmi'
	passives = list("ShockwaveBlows" = 1, "ArmorPeeling" = 1)
	Destructable=0
	ShatterTier=0

obj/Skills/AutoHit/Shockwave_Blows
	Area="Circle"
	Distance=5
	AdaptRate = 1
	GuardBreak=1
	DamageMult=1
	Knockback=2
	Cooldown=1
	Shockwaves=1
	Shockwave=3
	HitSparkIcon='BLANK.dmi'
	HitSparkX=0
	HitSparkY=0
	ActiveMessage="swings their blade hard enough to make the air ripple!"
	EnergyCost=5

obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Durendal
	name = "Heavenly Regalia: The Saint"
	StrMult=1.3
	EndMult=1.3
	DefMult=1.3
	passives = list("ShockwaveBlows" = 1, "HolyMod" = 2)
	IconLock='EyeFlameC.dmi'
	ActiveMessage="'s legendary weapon and horn ring in resonance: Heavenly Regalia!"
	OffMessage="'s treasures lose their Saintly luster..."
	verb/Heavenly_Regalia()
		set category="Skills"
		src.Trigger(usr)