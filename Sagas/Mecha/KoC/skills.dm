// Autohits
/obj/Skills/AutoHit/Drill_of_Defiance
	Copyable=0
	FlickSpin=1
	Area="Circle"
	NoLock=1
	NoAttackLock=1
	DamageMult=6
	DelayTime=0
	Rush=6
	ControlledRush=1
	HitSparkIcon='Hit Effect.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkCount=3
	HitSparkDispersion=12
	Launcher=3
	DelayedLauncher=1
	Cooldown=15
	EnergyCost=3
	ObjIcon = 1
	Icon='drill.dmi'
	IconX = -8
	IconY = -8
	ActiveMessage="rushes forward to deliver a flurry of strikes!"
	verb/Dragon_Rush()
		set category="Skills"
		usr.Activate(src)
// Projectiles
/obj/Skills/Projectile/Beams/Will_Beam
	Copyable=0
	DamageMult=0.45
	Distance=50
	Knockback=1
	IconLock='BeamBig2.dmi'
	IconSize=3
	Cooldown=15
	BeamTime=10
	EnergyCost=3
	HeldSkill=TRUE
	HeldBeam=TRUE
	ChargePeriod=2.5
	verb/Will_Beam()
		set category="Skills"
		usr.BeginHeldSkill(src)
// Grapple
/obj/Skills/Grapple/Seismic_Toss
	Copyable=0
	DamageMult=0.95
	Reversal=0
	Stunner=0.8
	StrScaling=0.5
	ForScaling=0.5
	ThrowAdd=12
	ThrowMult=1.25
	OneAndDone=1
	EffectMult = 6
	DashAfter=1
	TriggerMessage="launches a tornado spin throw on"
	Effect="SpinTornado"
	Cooldown=3
	EnergyCost=1
	verb/Seismic_Toss()
		set category="Skills"
		src.Activate(usr)

// Queues