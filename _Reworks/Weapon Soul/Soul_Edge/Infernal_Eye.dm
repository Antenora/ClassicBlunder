obj/Skills/AutoHit/Gaze_of_Despair
	NeedsSword=1
	Distance=8
	Gravity=5
	DamageMult=3.5
	DelayTime=5
	StrOffense=1
	Rounds = 5
	ActiveMessage="gazes into the Infernal Eye. . . and reflects it's gaze back around them."
	Area="Circle"
	GuardBreak=1
	PassThrough=1
	HitSparkIcon = null
	PreShockwave=1
	PreShockwaveDelay=1
	PostShockwave=0
	Shockwaves=2
	Shockwave=0.5
	ShockIcon='KenShockwaveBloodlust.dmi'
	ShockBlend=2
	ShockDiminish=1.15
	ShockTime=4
	TurfStrike=1
	TurfShiftLayer=EFFECTS_LAYER
	TurfShiftDuration=-10
	TurfShiftDurationSpawn=0
	TurfShiftDurationDespawn=5
	TurfShift='Gravity.dmi'
	Cooldown=120
	EnergyCost=15
	Instinct=1
	verb/Gaze_of_Despair()
		set category="Skills"
		usr.Activate(src)