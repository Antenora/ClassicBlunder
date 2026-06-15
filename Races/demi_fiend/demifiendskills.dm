/obj/Skills/AutoHit/DemiFiend/Lunge
	Area="Wave"
	Distance=5
	DamageMult=6
	Rush=5
	ControlledRush=1
	Cooldown=30
	StrOffense=1
	RushAfterImages=3
	RushNoFlight=1
	ActiveMessage="lunges forward with blinding speed!"
	MaxCharges=2
	Charges=2
	ChargeRefresh=15

	verb/Lunge()
		set category="Skills"
		src.Trigger(usr)

	adjust(mob/p)
		var/scaling = round(p.Potential / 25)
		Distance = 5 + scaling
		DamageMult = 6 + scaling
		Rush = 5 + scaling

/obj/Skills/AutoHit/DemiFiend/Ice_Breath
	ElementalClass="Water"
	SpellElement="Water"
	StrOffense=0
	ForOffense=2
	SpecialAttack=1
	GuardBreak=0
	DamageMult=10
	Chilling=20
	Freezing=20
	TurfIce=1
	TurfIceOffset=1
	HitSparkIcon='BLANK.dmi'
	HitSparkX=0
	HitSparkY=0
	WindUp=0.5
	WindupMessage="breathes deeply..."
	ActiveMessage="lets loose an enormous breath infused with frost!"
	Cooldown=60
	Distance=20
	Slow=1
	Area="Arc"
	verb/Ice_Breath()
		set category="Skills"
		if(!altered)
			DamageMult = 10 + (0.75 * usr.AscensionsAcquired)
			Distance = 20 + (2 * usr.AscensionsAcquired)
			ForOffense = 2 + (0.25 * usr.AscensionsAcquired)
		usr.Activate(src)

/obj/Skills/AutoHit/DemiFiend/Flame_Breath
	ElementalClass="Fire"
	SpellElement="Fire"
	StrOffense=1
	ForOffense=1
	SpecialAttack=1
	GuardBreak=0
	DamageMult=10
	Scorching=30
	TurfErupt=1
	WindUp=0.5
	WindupMessage="breathes deeply..."
	ActiveMessage="lets loose an enormous breath infused with flame!"
	Cooldown=60
	Distance=40
	Slow=1
	Area="Arc"
	verb/Flame_Breath()
		set category="Skills"
		if(!altered)
			DamageMult = 10 + (1.5 * usr.AscensionsAcquired)
			Distance = 10 + (3 * usr.AscensionsAcquired)
			ForOffense = 1 + (0.25 * usr.AscensionsAcquired)
			StrOffense = 1 + (0.25 * usr.AscensionsAcquired)
		usr.Activate(src)

/obj/Skills/AutoHit/DemiFiend/Fog_Breath
	SpellElement="Water"
	StrOffense=0
	ForOffense=1
	DamageMult=0.5
	SpecialAttack=1
	Slow=1
	Chilling=20
	Freezing=15
	Confusing=35
	Shocking=10
	Silencing=5
	TurfFog=1
	TurfFogOffset=1
	Area="Arc"
	Distance=20
	Cooldown=60
	Rounds=12
	DelayTime=2
	HitSparkIcon='BLANK.dmi'
	HitSparkX=0
	HitSparkY=0
	WindUp=0.5
	ActiveMessage="releases a choking veil of Fog Breath!"
	verb/Fog_Breath()
		set category="Skills"
		if(!altered)
			Confusing = 35 + (5 * usr.AscensionsAcquired)
			Chilling = 10 + (10 * usr.AscensionsAcquired)
		usr.Activate(src)

// Target debuff skills - apply stat-reducing debuffs for 30 seconds
obj/Skills/Buffs/SlotlessBuffs/DemiFiend/TarundaApply
	StrMult=0.75
	ForMult=0.75
	TimerLimit=30
	ActiveMessage="has their strength and fortitude sapped!"
	OffMessage="recovers from the Tarunda debuff."

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Tarunda
	applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/TarundaApply
	AffectTarget=1
	EndYourself=1
	Range=12
	Cooldown=60
	ActiveMessage="saps the target's strength and fortitude!"
	verb/Tarunda()
		set category="Skills"
		if(!usr.Target || usr.Target==usr)
			usr << "You need to target someone else."
			return
		if(!altered)
			adjust(usr)
			applyToTarget?:adjust(usr)
		src.Trigger(usr)

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/SukundaApply
	SpdMult=0.75
	OffMult=0.75
	DefMult=0.75
	TimerLimit=30
	ActiveMessage="has their speed, offense, and defense reduced!"
	OffMessage="recovers from the Sukunda debuff."

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Sukunda
	applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/SukundaApply
	AffectTarget=1
	EndYourself=1
	Range=12
	Cooldown=60
	ActiveMessage="reduces the target's speed, offense, and defense!"
	verb/Sukunda()
		set category="Skills"
		if(!usr.Target || usr.Target==usr)
			usr << "You need to target someone else."
			return
		if(!altered)
			adjust(usr)
			applyToTarget?:adjust(usr)
		src.Trigger(usr)

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/RakundaApply
	EndMult=0.75
	TimerLimit=30
	ActiveMessage="has their endurance sapped!"
	OffMessage="recovers from the Rakunda debuff."

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Rakunda
	applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/RakundaApply
	AffectTarget=1
	EndYourself=1
	Range=12
	Cooldown=60
	ActiveMessage="saps the target's endurance!"
	verb/Rakunda()
		set category="Skills"
		if(!usr.Target || usr.Target==usr)
			usr << "You need to target someone else."
			return
		if(!altered)
			adjust(usr)
			applyToTarget?:adjust(usr)
		src.Trigger(usr)

// Healing skills
obj/Skills/Buffs/SlotlessBuffs/DemiFiend/DiaApply
	StableHeal=1
	HealthHeal=0.6
	TimerLimit=10
	ActiveMessage="is healed by restorative energy!"
	OffMessage="releases the healing energy."

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Dia
	ElementalClass="Light"
	applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/DiaApply
	AffectTarget=1
	EndYourself=1
	Range=12
	Cooldown=150
	KenWave=1
	KenWaveIcon='SparkleYellow.dmi'
	KenWaveSize=3
	KenWaveX=105
	KenWaveY=105
	ActiveMessage="invokes restorative energy upon their target!"
	OffMessage="finishes casting Dia."
	verb/Dia()
		set category="Skills"
		if(!usr.Target || usr.Target==usr)
			usr << "You can't use Dia on yourself!"
			return
		if(!altered)
			adjust(usr)
			applyToTarget?:adjust(usr)
		src.Trigger(usr)

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/MediaApply
	StableHeal=1
	HealthHeal=0.3
	TimerLimit=10
	ActiveMessage="is healed by powerful restorative energy!"
	OffMessage="the healing energy fades..."
	MagicNeeded=0

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Media
	ElementalClass="Light"
	EndYourself=1
	Cooldown=300
	KenWave=1
	KenWaveIcon='SparkleYellow.dmi'
	KenWaveSize=4
	KenWaveX=105
	KenWaveY=105
	ActiveMessage="invokes restorative magic upon their party!"
	OffMessage="finishes casting Media."
	verb/Media()
		set category="Skills"
		var/mob/User = usr
		if(!User.party || !User.party.members || User.party.members.len == 0)
			User << "You need to be in a party to use Media."
			return
		if(src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return
		if(!altered)
			adjust(User)
		var/baseHeal = 15
		for(var/mob/m in User.party.members)
			if(!m || !ismob(m)) continue
			var/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/MediaApply/applyBuff = new
			applyBuff.HealthHeal = (m == User ? baseHeal / 2 : baseHeal)
			applyBuff.StableHeal = 1
			applyBuff.TimerLimit = 10
			applyBuff.Trigger(m, 1)
		User.OMessage(1, null, "[User] invokes restorative energy upon [User.party.members.len == 1 ? "themselves" : "their party"]!")
		src.Cooldown(1, null, User)

obj/Skills/Projectile/DemiFiend/Tornado
	SpellElement="Air"
	name = "Tornado"
	IconLock = 'Tornado.dmi'
	IconSize = 2
	LockX = -32
	LockY = -32
	Speed = 0.4
	Distance = 25
	DamageMult = 15
	StrRate = 0.5
	ForRate = 0.5
	HyperHoming = 1
	Homing = 1
	Launcher = 3
	LingeringTornado = 1
	Piercing = 1
	Cooldown = 60
	verb/Tornado()
		set category = "Skills"
		usr.UseProjectile(src)

/obj/Skills/AutoHit/DemiFiend/Berserk
	Area="Wave"
	Distance=8
	DamageMult=2
	StrOffense=2
	SpecialAttack=1
	Cooldown=45
	Slow=1
	Rounds=5
	DelayTime=2
	RoundMovement=0
	ObjIcon=1
	Icon='roundhouse.dmi'
	IconX=-16
	IconY=-16
	Size=1.5
	HitSparkIcon='Impacts VFX3.dmi'
	//HitSparkX=-32
	//HitSparkY=-32
	HitSparkTurns=1
	HitSparkSize=1
	HitSparkDispersion=1
	TurfStrike=1
	WindUp=0.3
	WindupMessage="enters a berserker rage..."
	ActiveMessage="unleashes a flurry of devastating strikes!"
	verb/Berserk()
		set category="Skills"
		if(!altered)
			DamageMult = 2 + (0.25 * usr.AscensionsAcquired)
			Distance = 8 + (2 * usr.AscensionsAcquired)
			StrOffense = 2 + (0.25 * usr.AscensionsAcquired)
		usr.Activate(src)

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/TauntDebuffApply
	StrMult=1.5
	ForMult=1.5
	EndMult=0.5
	TimerLimit=30
	ActiveMessage="is taunted into a reckless frenzy!"
	OffMessage="shakes off the effects of the taunt."

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Taunt
	EndYourself=1
	Cooldown=90
	ActiveMessage="taunts all nearby enemies into a reckless frenzy!"
	OffMessage="finishes taunting."
	verb/Taunt()
		set category="Skills"
		var/mob/User = usr
		if(src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return
		var/hit = 0
		for(var/mob/m in oview(12, User))
			if(m == User) continue
			if(User.party && (m in User.party.members)) continue
			if(!m.client && !isAI(m)) continue
			var/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/TauntDebuffApply/applyBuff = new
			applyBuff.Trigger(m, 1)
			hit++
		if(hit)
			User.OMessage(1, null, "[User] lets out a taunting roar, provoking [hit] nearby foe\s into a reckless frenzy!")
		else
			User << "No enemies nearby to taunt."
			return
		src.Cooldown(1, null, User)

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/WarCryApply
	StrMult=0.6
	ForMult=0.6
	TimerLimit=30
	ActiveMessage="has their fighting spirit shattered by a terrifying war cry!"
	OffMessage="recovers from the war cry."

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/War_Cry
	EndYourself=1
	Cooldown=90
	ActiveMessage="lets out a bone-chilling war cry!"
	OffMessage="finishes the war cry."
	verb/War_Cry()
		set category="Skills"
		var/mob/User = usr
		if(src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return
		var/hit = 0
		for(var/mob/m in oview(12, User))
			if(m == User) continue
			if(User.party && (m in User.party.members)) continue
			if(!m.client && !isAI(m)) continue
			var/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/WarCryApply/applyBuff = new
			applyBuff.Trigger(m, 1)
			hit++
		if(hit)
			User.OMessage(1, null, "[User] lets out a devastating war cry, weakening [hit] nearby foe\s!")
		else
			User << "No enemies nearby."
			return
		src.Cooldown(1, null, User)

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Focus
	StrMult=2.5
	ForMult=2.5
	TimerLimit=5
	Cooldown=120
	ActiveMessage="concentrates their power to its absolute limit!"
	OffMessage="releases their focused state."
	verb/Focus()
		set category="Skills"
		src.Trigger(usr)

/obj/Skills/AutoHit/DemiFiend/Heat_Wave
	StrOffense=2
	Cooldown=90

	verb/Heat_Wave()
		set category="Skills"
		var/mob/User = usr
		if(src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return
		var/obj/Effects/HeatWaveShock/W = new(User.loc)
		W.owner = User
		if(!altered)
			W.DamageMult = 20 + (1 * User.AscensionsAcquired)
		else
			W.DamageMult = 20
		W.StrOffense = 2
		User.OMessage(1, null, "[User] releases a devastating shockwave of scorching heat — Heat Wave!")
		src.Cooldown(1, null, User)

/obj/Skills/AutoHit/DemiFiend/Freikugel
	ElementalClass="Ultima"
	Area="Wave"
	Distance=6
	DamageMult=8
	Rush=6
	ControlledRush=1
	StrOffense=2
	ForOffense=1
	SpecialAttack=1
	GuardBreak=1
	Cooldown=90
	Slow=1
	RushAfterImages=5
	WindUp=1
	WindupMessage="concentrates an overwhelming surge of power..."
	ActiveMessage="fires a devastating burst of almighty force!"
	verb/Freikugel()
		set category="Skills"
		if(!altered)
			DamageMult = 8 + (3 * usr.AscensionsAcquired)
			Distance = 6 + (2 * usr.AscensionsAcquired)
			Rush = 6 + (2 * usr.AscensionsAcquired)
			StrOffense = 2 + (0.5 * usr.AscensionsAcquired)
			ForOffense = 1 + (0.25 * usr.AscensionsAcquired)
		usr.Activate(src)

/obj/Skills/AutoHit/DemiFiend/Shock
	ElementalClass="Wind"
	SpellElement="Wind"
	StrOffense=0
	ForOffense=1
	SpecialAttack=1
	DamageMult=12
	Shocking=20
	Paralyzing=20
	Bolt=4
	BoltOffset=0
	Area="Target"
	Distance=8
	Cooldown=45
	WindUp=0.3
	HitSparkIcon='BLANK.dmi'
	HitSparkX=0
	HitSparkY=0
	ActiveMessage="calls down a bolt of Shock on their target!"
	verb/Shock()
		set category="Skills"
		if(!altered)
			DamageMult = 12 + (1 * usr.AscensionsAcquired)
		usr.Activate(src)

// =========================================================================
// Anathema skills
// =========================================================================

obj/Skills/Projectile/DemiFiend/Mamudo
	name = "Mamudo"
	ElementalClass = "Dark"
	SpellElement = "Dark"
	IconLock = 'DarkShock.dmi'
	IconSize = 1
	LockX = -16
	LockY = -16
	Speed = 0.3
	Distance = 20
	DamageMult = 6
	ForRate = 1
	Homing = 1
	Cooldown = 30
	verb/Mamudo()
		set category = "Skills"
		if(!altered)
			DamageMult = 6 + (1 * usr.AscensionsAcquired)
			Distance = 20 + (2 * usr.AscensionsAcquired)
		usr.UseProjectile(src)

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/EvilGazeApply
	TimerLimit=30
	ActiveMessage="is gripped by primal terror..."
	OffMessage="shakes off the dread."

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Evil_Gaze
	applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/EvilGazeApply
	AffectTarget=1
	EndYourself=1
	Range=12
	Cooldown=60
	KenWave=1
	KenWaveIcon='SparkleIndigo.dmi'
	KenWaveSize=3
	ActiveMessage="fixes their target with a dreadful gaze!"
	OffMessage="finishes the gaze."
	verb/Evil_Gaze()
		set category="Skills"
		if(!usr.Target || usr.Target==usr)
			usr << "You need to target someone else."
			return
		if(!altered)
			adjust(usr)
			applyToTarget?:adjust(usr)
		usr.Target.AddConfusing(40, usr)
		src.Trigger(usr)

/obj/Skills/AutoHit/DemiFiend/Mamudoon
	ElementalClass="Dark"
	SpellElement="Dark"
	Area="Around Target"
	Distance=12
	DistanceAround=8
	DamageMult=1.5
	ForOffense=2
	SpecialAttack=1
	Doom=15
	ObjIcon=1
	Icon='Warlock VFX7.dmi'
	IconX=-64
	IconY=-64
	Size=2
	Rounds=10
	DelayTime=2
	HitSparkIcon='BLANK.dmi'
	HitSparkX=0
	HitSparkY=0
	Cooldown=90
	WindUp=0.5
	WindupMessage="calls upon the voice of the damned..."
	ActiveMessage="erupts in a wave of deathly darkness - Mamudoon!"
	verb/Mamudoon()
		set category="Skills"
		if(!altered)
			DamageMult = 1.5 + (0.25 * usr.AscensionsAcquired)
			Doom = 15 + (4 * usr.AscensionsAcquired)
		usr.Activate(src)

// =========================================================================
// Miasma skills
// =========================================================================

obj/Skills/Projectile/DemiFiend/Glacial_Blast
	name = "Glacial Blast"
	ElementalClass = "Water"
	SpellElement = "Water"
	IconLock = 'IceCoffin.dmi'
	IconSize = 2
	LockX = -32
	LockY = -32
	Speed = 0.35
	Distance = 25
	DamageMult = 5
	ForRate = 1
	Chilling = 50
	Freezing = 20
	Piercing = 1
	Homing = 1
	Cooldown = 45
	verb/Glacial_Blast()
		set category = "Skills"
		if(!altered)
			DamageMult = 5 + (1.5 * usr.AscensionsAcquired)
			Distance = 25 + (2 * usr.AscensionsAcquired)
		usr.UseProjectile(src)

/obj/Skills/AutoHit/DemiFiend/Wild_Dance
	ElementalClass="Dark"
	SpellElement="Dark"
	Area="Target"
	Distance=10
	DamageMult=0.001
	StrOffense=0
	ForOffense=1
	SpecialAttack=1
	Confusing=100
	HitSparkIcon='Dark Mage VFX2.dmi'
	HitSparkX=-64
	HitSparkY=-64
	HitSparkTurns=1
	HitSparkSize=1
	Cooldown=75
	WindUp=0.3
	WindupMessage="begins a spiraling dance..."
	ActiveMessage="performs Wild Dance, sowing chaos in their target's mind!"
	verb/Wild_Dance()
		set category="Skills"
		if(!altered)
			Confusing = 100 + (15 * usr.AscensionsAcquired)
		usr.Activate(src)

// =========================================================================
// Nirvana skills
// =========================================================================

obj/Skills/Projectile/DemiFiend/Divine_Shot
	name = "Divine Shot"
	ElementalClass = "Light"
	SpellElement = "Light"
	IconLock = 'Priest VFX4.dmi'
	IconSize = 1.5
	LockX = -16
	LockY = -16
	Speed = 0.7
	Distance = 40
	DamageMult = 30
	AccMult = 1.15
	Blasts = 1
	Charge = 1.5
	Explode = 1
	Homing = 1
	Knockback = 1
	CriticalChance = 10
	Cooldown = 120
	verb/Divine_Shot()
		set category = "Skills"
		if(!altered)
			DamageMult = 30 + (1.5 * usr.AscensionsAcquired)
		usr.UseProjectile(src)

/obj/Skills/AutoHit/DemiFiend/Violet_Flash
	ElementalClass="Light"
	SpellElement="Light"
	Area="Around Target"
	Distance=10
	DistanceAround=8
	DamageMult=2
	ForOffense=1
	SpecialAttack=1
	ObjIcon=1
	Icon='Dark Mage VFX4.dmi'
	IconX=-64
	IconY=-64
	Size=1.5
	Rounds=10
	DelayTime=2
	HitSparkIcon='BLANK.dmi'
	HitSparkX=0
	HitSparkY=0
	Cooldown=75
	WindUp=0.4
	WindupMessage="gathers radiant light..."
	ActiveMessage="unleashes a blinding flash of violet radiance!"
	verb/Violet_Flash()
		set category="Skills"
		if(!altered)
			DamageMult = 2 + (0.25 * usr.AscensionsAcquired)
		usr.Activate(src)

// =========================================================================
// Murakumo skills
// =========================================================================

/obj/Skills/AutoHit/DemiFiend/Chaos_Blade
	Area="Arc"
	Distance=5
	Size=2
	DamageMult=2
	StrOffense=1
	ForOffense=1
	SpecialAttack=1
	Rounds=8
	DelayTime=1
	TurfErupt=1
	Confusing=40
	HitSparkIcon='BLANK.dmi'
	HitSparkX=0
	HitSparkY=0
	Cooldown=60
	WindUp=0.3
	WindupMessage="draws the cloud-gathering blade..."
	ActiveMessage="cleaves everything with Chaos Blade!"
	verb/Chaos_Blade()
		set category="Skills"
		if(!altered)
			DamageMult = 2 + (0.25 * usr.AscensionsAcquired)
		usr.Activate(src)

// =========================================================================
// Geis skills
// =========================================================================

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/DiaramaApply
	StableHeal=1
	HealthHeal=1.5
	TimerLimit=10
	ActiveMessage="is bathed in potent restorative energy!"
	OffMessage="releases the restorative energy."

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Diarama
	ElementalClass="Light"
	applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/DiaramaApply
	AffectTarget=1
	EndYourself=1
	Range=12
	Cooldown=180
	KenWave=1
	KenWaveIcon='SparkleYellow.dmi'
	KenWaveSize=4
	KenWaveX=105
	KenWaveY=105
	ActiveMessage="invokes potent restorative energy upon their target!"
	OffMessage="finishes casting Diarama."
	verb/Diarama()
		set category="Skills"
		if(!usr.Target || usr.Target==usr)
			usr << "You can't use Diarama on yourself!"
			return
		if(!altered)
			adjust(usr)
			applyToTarget?:adjust(usr)
		src.Trigger(usr)

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/MediaramaApply
	StableHeal=1
	HealthHeal=1
	TimerLimit=10
	ActiveMessage="is bathed in powerful restorative energy!"
	OffMessage="the healing energy fades..."
	MagicNeeded=0

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Mediarama
	ElementalClass="Light"
	EndYourself=1
	Cooldown=300
	KenWave=1
	KenWaveIcon='SparkleYellow.dmi'
	KenWaveSize=5
	KenWaveX=105
	KenWaveY=105
	ActiveMessage="invokes powerful restorative magic upon their party!"
	OffMessage="finishes casting Mediarama."
	verb/Mediarama()
		set category="Skills"
		var/mob/User = usr
		if(!User.party || !User.party.members || User.party.members.len == 0)
			User << "You need to be in a party to use Mediarama."
			return
		if(src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return
		if(!altered)
			adjust(User)
		var/baseHeal = 35
		for(var/mob/m in User.party.members)
			if(!m || !ismob(m)) continue
			var/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/MediaramaApply/applyBuff = new
			applyBuff.HealthHeal = (m == User ? baseHeal / 2 : baseHeal)
			applyBuff.StableHeal = 1
			applyBuff.TimerLimit = 10
			applyBuff.Trigger(m, 1)
		User.OMessage(1, null, "[User] invokes powerful restorative energy upon [User.party.members.len == 1 ? "themselves" : "their party"]!")
		src.Cooldown(1, null, User)

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/DiarahanApply
	StableHeal=1
	HealthHeal=3
	TimerLimit=3
	ActiveMessage="is enveloped in an overwhelming wave of restorative light!"
	OffMessage="the flood of healing recedes."

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Diarahan
	ElementalClass="Light"
	applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/DiarahanApply
	AffectTarget=1
	EndYourself=1
	Range=12
	Cooldown=600
	KenWave=1
	KenWaveIcon='SparkleYellow.dmi'
	KenWaveSize=6
	KenWaveX=105
	KenWaveY=105
	ActiveMessage="invokes an overwhelming flood of restorative light!"
	OffMessage="finishes casting Diarahan."
	verb/Diarahan()
		set category="Skills"
		if(!usr.Target || usr.Target==usr)
			usr << "You can't use Diarahan on yourself!"
			return
		if(!altered)
			adjust(usr)
			applyToTarget?:adjust(usr)
		src.Trigger(usr)

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/TetrajaApply
	EndMult=2
	TimerLimit=30
	ActiveMessage="is shrouded by a sacred ward!"
	OffMessage="the sacred ward fades."

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Tetraja
	ElementalClass="Light"
	applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/TetrajaApply
	EndYourself=1
	Cooldown=180
	ActiveMessage="invokes a sacred ward upon themselves!"
	OffMessage="finishes casting Tetraja."
	verb/Tetraja()
		set category="Skills"
		if(!altered)
			adjust(usr)
			applyToTarget?:adjust(usr)
		src.Trigger(usr)

// =========================================================================
// Djed skills (self-buffs)
// =========================================================================

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/TarukajaApply
	StrMult=1.25
	ForMult=1.25
	TimerLimit=30
	ActiveMessage="has their offensive power bolstered!"
	OffMessage="the offensive bolster fades."

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Tarukaja
	applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/TarukajaApply
	EndYourself=1
	Cooldown=60
	ActiveMessage="bolsters their offensive power!"
	OffMessage="finishes casting Tarukaja."
	verb/Tarukaja()
		set category="Skills"
		if(!altered)
			adjust(usr)
			applyToTarget?:adjust(usr)
		src.Trigger(usr)

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/RakukajaApply
	EndMult=1.25
	TimerLimit=30
	ActiveMessage="has their endurance bolstered!"
	OffMessage="the defensive bolster fades."

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Rakukaja
	applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/RakukajaApply
	EndYourself=1
	Cooldown=60
	ActiveMessage="bolsters their endurance!"
	OffMessage="finishes casting Rakukaja."
	verb/Rakukaja()
		set category="Skills"
		if(!altered)
			adjust(usr)
			applyToTarget?:adjust(usr)
		src.Trigger(usr)

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/SukukajaApply
	SpdMult=1.25
	OffMult=1.25
	DefMult=1.25
	TimerLimit=30
	ActiveMessage="has their agility bolstered!"
	OffMessage="the agility bolster fades."

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Sukukaja
	applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/SukukajaApply
	EndYourself=1
	Cooldown=60
	ActiveMessage="bolsters their agility!"
	OffMessage="finishes casting Sukukaja."
	verb/Sukukaja()
		set category="Skills"
		if(!altered)
			adjust(usr)
			applyToTarget?:adjust(usr)
		src.Trigger(usr)

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/MakakajaApply
	ForMult=1.25
	TimerLimit=30
	ActiveMessage="has their magical fortitude bolstered!"
	OffMessage="the magical bolster fades."

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Makakaja
	applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/MakakajaApply
	EndYourself=1
	Cooldown=60
	ActiveMessage="bolsters their magical fortitude!"
	OffMessage="finishes casting Makakaja."
	verb/Makakaja()
		set category="Skills"
		if(!altered)
			adjust(usr)
			applyToTarget?:adjust(usr)
		src.Trigger(usr)

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/DekajaApply
	StrMult=0.75
	ForMult=0.75
	EndMult=0.75
	SpdMult=0.75
	OffMult=0.75
	DefMult=0.75
	TimerLimit=30
	ActiveMessage="has all their enhancements stripped away!"
	OffMessage="recovers from the Dekaja dispel."

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Dekaja
	EndYourself=1
	Cooldown=120
	ActiveMessage="invokes a sweeping dispel!"
	OffMessage="finishes casting Dekaja."
	verb/Dekaja()
		set category="Skills"
		var/mob/User = usr
		if(src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return
		var/hit = 0
		for(var/mob/m in oview(12, User))
			if(m == User) continue
			if(User.party && (m in User.party.members)) continue
			if(!m.client && !isAI(m)) continue
			var/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/DekajaApply/applyBuff = new
			applyBuff.Trigger(m, 1)
			hit++
		if(hit)
			User.OMessage(1, null, "[User] invokes Dekaja, stripping enhancements from [hit] nearby foe\s!")
		else
			User << "No enemies nearby to dispel."
			return
		src.Cooldown(1, null, User)

// =========================================================================
// Muspell skills
// =========================================================================

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/TentarafooApply
	TimerLimit=30
	ActiveMessage="is beset by dizzying phantasms!"
	OffMessage="the phantasms fade."

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Tentarafoo
	EndYourself=1
	Cooldown=75
	ActiveMessage="unleashes dizzying phantasms!"
	OffMessage="finishes casting Tentarafoo."
	verb/Tentarafoo()
		set category="Skills"
		var/mob/User = usr
		if(src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return
		var/hit = 0
		for(var/mob/m in oview(12, User))
			if(m == User) continue
			if(User.party && (m in User.party.members)) continue
			if(!m.client && !isAI(m)) continue
			m.AddConfusing(40, User)
			var/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/TentarafooApply/applyBuff = new
			applyBuff.Trigger(m, 1)
			hit++
		if(hit)
			User.OMessage(1, null, "[User] invokes Tentarafoo, confusing [hit] nearby foe\s!")
		else
			User << "No enemies nearby."
			return
		src.Cooldown(1, null, User)

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/MakajamonApply
	TimerLimit=20
	ActiveMessage="is silenced by an ancient curse!"
	OffMessage="the silencing curse fades."

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Makajamon
	EndYourself=1
	Cooldown=75
	ActiveMessage="unleashes a silencing curse!"
	OffMessage="finishes casting Makajamon."
	verb/Makajamon()
		set category="Skills"
		var/mob/User = usr
		if(src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return
		var/hit = 0
		for(var/mob/m in oview(12, User))
			if(m == User) continue
			if(User.party && (m in User.party.members)) continue
			if(!m.client && !isAI(m)) continue
			m.passive_handler.Increase("Silenced", 1)
			var/mob/sil_tgt = m
			spawn(150)
				if(sil_tgt && sil_tgt.passive_handler)
					sil_tgt.passive_handler.Decrease("Silenced", 1)
			var/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/MakajamonApply/applyBuff = new
			applyBuff.Trigger(m, 1)
			hit++
		if(hit)
			User.OMessage(1, null, "[User] invokes Makajamon, silencing [hit] nearby foe\s!")
		else
			User << "No enemies nearby."
			return
		src.Cooldown(1, null, User)

/obj/Skills/AutoHit/DemiFiend/Xeros_Beat
	Area="Wave"
	Distance=8
	DamageMult=2.5
	StrOffense=2
	SpecialAttack=1
	CriticalChance=30
	ObjIcon=1
	Icon='Impacts VFX1.dmi'
	IconX=-16
	IconY=-16
	Size=2
	Rounds=12
	DelayTime=2
	HitSparkIcon='Hit Effect Wind.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkTurns=1
	HitSparkSize=1
	HitSparkDispersion=1
	TurfStrike=1
	Cooldown=90
	WindUp=0.5
	WindupMessage="crushes the ground underfoot..."
	ActiveMessage="unleashes a devastating Xeros Beat!"
	verb/Xeros_Beat()
		set category="Skills"
		if(!altered)
			DamageMult = 2.5 + (0.25 * usr.AscensionsAcquired)
			Distance = 8 + (2 * usr.AscensionsAcquired)
			StrOffense = 2 + (0.5 * usr.AscensionsAcquired)
		usr.Activate(src)

// =========================================================================
// Gehenna skills
// =========================================================================

/obj/Skills/AutoHit/DemiFiend/Hellfire
	ElementalClass="Fire"
	SpellElement="Fire"
	Area="Wave"
	Distance=10
	DamageMult=3
	StrOffense=1
	ForOffense=2
	SpecialAttack=1
	GuardBreak=1
	Scorching=100
	Combustion=50
	ObjIcon=1
	Icon='fevExplosion - Hellfire.dmi'
	IconX=-16
	IconY=-16
	Size=2
	Rounds=10
	DelayTime=2
	HitSparkIcon='BLANK.dmi'
	HitSparkX=0
	HitSparkY=0
	TurfErupt=1
	Cooldown=90
	WindUp=0.8
	WindupMessage="draws breath from the valley of flames..."
	ActiveMessage="unleashes the roar of Hellfire!"
	verb/Hellfire()
		set category="Skills"
		if(!altered)
			DamageMult = 3 + (0.25 * usr.AscensionsAcquired)
			Distance = 10 + (2 * usr.AscensionsAcquired)
			ForOffense = 2 + (0.5 * usr.AscensionsAcquired)
			StrOffense = 1 + (0.25 * usr.AscensionsAcquired)
		usr.Activate(src)

/obj/Skills/AutoHit/DemiFiend/Magma_Axis
	ElementalClass="Fire"
	SpellElement="Fire"
	Area="Wave"
	Distance=6
	Rush=5
	ControlledRush=1
	DamageMult=3
	StrOffense=2
	ForOffense=1
	SpecialAttack=1
	GuardBreak=1
	Scorching=75
	ObjIcon=1
	Icon='Slash - Hellfire.dmi'
	IconX=-16
	IconY=-16
	Size=2
	Rounds=8
	DelayTime=2
	HitSparkIcon='Hit Effect Wind.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkTurns=1
	HitSparkSize=1
	HitSparkDispersion=1
	TurfStrike=1
	TurfErupt=1
	Cooldown=75
	WindUp=0.5
	WindupMessage="ignites the ground along the blade's path..."
	ActiveMessage="cleaves forward with Magma Axis!"
	verb/Magma_Axis()
		set category="Skills"
		if(!altered)
			DamageMult = 3 + (0.25 * usr.AscensionsAcquired)
			Distance = 6 + (2 * usr.AscensionsAcquired)
			Rush = 5 + (1 * usr.AscensionsAcquired)
			StrOffense = 2 + (0.5 * usr.AscensionsAcquired)
			ForOffense = 1 + (0.25 * usr.AscensionsAcquired)
		usr.Activate(src)

// =========================================================================
// Kamurogi skills
// =========================================================================

/obj/Skills/AutoHit/DemiFiend/Blight
	Area="Wave"
	Distance=3
	Rush=3
	ControlledRush=1
	DamageMult=4
	StrOffense=2
	SpecialAttack=1
	GuardBreak=1
	Poisoning=80
	TurfStrike=1
	Rounds=4
	DelayTime=1
	HitSparkIcon='Slash - Hellfire.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkTurns=1
	HitSparkSize=1.5
	HitSparkDispersion=1
	Cooldown=60
	WindUp=0.4
	WindupMessage="gathers virulent essence..."
	ActiveMessage="unleashes a choking wave of Blight!"
	verb/Blight()
		set category="Skills"
		if(!altered)
			DamageMult = 4 + (0.5 * usr.AscensionsAcquired)
			StrOffense = 2 + (0.25 * usr.AscensionsAcquired)
		usr.Activate(src)

/obj/Skills/AutoHit/DemiFiend/Iron_Claw
	Area="Arc"
	Distance=2
	Rush=4
	ControlledRush=1
	DamageMult=3
	StrOffense=2
	SpecialAttack=1
	GuardBreak=1
	ComboMaster=1
	TurfStrike=1
	Rounds=3
	DelayTime=1
	RoundMovement=0
	HitSparkIcon='Claw markings.dmi'
	HitSparkX=-16
	HitSparkY=-16
	HitSparkTurns=1
	HitSparkSize=1
	Cooldown=60
	WindUp=0.3
	WindupMessage="tenses their hand into a claw..."
	ActiveMessage="lashes out with Iron Claw!"
	verb/Iron_Claw()
		set category="Skills"
		if(!altered)
			DamageMult = 3 + (0.5 * usr.AscensionsAcquired)
			StrOffense = 2 + (0.25 * usr.AscensionsAcquired)
		usr.Activate(src)

/obj/Skills/AutoHit/DemiFiend/Oni_Kagura
	Area="Wave"
	Distance=4
	DamageMult=15
	StrOffense=2
	SpecialAttack=1
	GuardBreak=1
	ComboMaster=1
	PassThrough=1
	PreShockwave=1
	PostShockwave=0
	Shockwave=2
	Shockwaves=2
	CriticalChance=20
	HitSparkIcon='Slash - Vampire.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkTurns=1
	HitSparkSize=1.5
	HitSparkDispersion=1
	TurfStrike=1
	TurfShift='Dirt1.dmi'
	TurfShiftDuration=3
	Cooldown=90
	WindUp=0.5
	WindupMessage="invokes the ancestral dance of the Oni..."
	ActiveMessage="whirls into the fury of Oni-Kagura!"
	verb/Oni_Kagura()
		set category="Skills"
		if(!altered)
			DamageMult = 15 + (1 * usr.AscensionsAcquired)
		usr.Activate(src)

// =========================================================================
// Satan skills
// =========================================================================

/obj/Skills/AutoHit/DemiFiend/Deadly_Fury
	Area="Arc"
	Distance=2
	Rush=4
	ControlledRush=1
	DamageMult=3
	StrOffense=1
	SpecialAttack=1
	ComboMaster=1
	TurfStrike=1
	CriticalChance=35
	Rounds=4
	DelayTime=1
	RoundMovement=0
	HitSparkIcon='Impacts VFX4.dmi'
	HitSparkX=-64
	HitSparkY=-64
	HitSparkTurns=1
	HitSparkSize=1
	Cooldown=90
	WindUp=0.4
	WindupMessage="burns with murderous intent..."
	ActiveMessage="erupts into Deadly Fury!"
	verb/Deadly_Fury()
		set category="Skills"
		if(!altered)
			DamageMult = 3 + (0.5 * usr.AscensionsAcquired)
			CriticalChance = 35 + (5 * usr.AscensionsAcquired)
		usr.Activate(src)

// =========================================================================
// Adama skills
// =========================================================================

/obj/Skills/AutoHit/DemiFiend/Bolt_Storm
	ElementalClass="Wind"
	SpellElement="Air"
	Area="Around Target"
	Distance=12
	DistanceAround=10
	Bolt=4
	BoltOffset=2
	DamageMult=2
	ForOffense=1
	SpecialAttack=1
	Paralyzing=8
	Shocking=20
	Rounds=15
	DelayTime=2
	HitSparkIcon='BLANK.dmi'
	HitSparkX=0
	HitSparkY=0
	Cooldown=120
	WindUp=0.6
	WindupMessage="draws down a thundering squall..."
	ActiveMessage="calls forth a Bolt Storm!"
	verb/Bolt_Storm()
		set category="Skills"
		if(!altered)
			DamageMult = 2 + (0.25 * usr.AscensionsAcquired)
			Rounds = 15 + (3 * usr.AscensionsAcquired)
		usr.Activate(src)

// =========================================================================
// Vimana skills
// =========================================================================

/obj/Skills/AutoHit/DemiFiend/Tempest
	ElementalClass="Wind"
	SpellElement="Air"
	Area="Wide Wave"
	Distance=6
	DamageMult=12
	ForOffense=2
	SpecialAttack=1
	Shearing=50
	TurfShift='Dirt1.dmi'
	TurfShiftDuration=3
	TurfStrike=1
	HitSparkIcon='Slash.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkTurns=1
	HitSparkSize=1.5
	HitSparkDispersion=1
	Cooldown=90
	WindUp=0.4
	WindupMessage="whirls the air into a cutting gale..."
	ActiveMessage="unleashes a howling Tempest!"
	verb/Tempest()
		set category="Skills"
		if(!altered)
			DamageMult = 12 + (1 * usr.AscensionsAcquired)
		usr.Activate(src)

/obj/Skills/AutoHit/DemiFiend/Javelin_Rain
	Area="Circle"
	Distance=1
	Wander=10
	DamageMult=2.5
	ForOffense=2
	SpecialAttack=1
	Shearing=50
	Pacifying=50
	ObjIcon=1
	Icon='SparkleGreen.dmi'
	IconX=-16
	IconY=-16
	Size=1.5
	Rounds=14
	DelayTime=2
	HitSparkIcon='BLANK.dmi'
	HitSparkX=0
	HitSparkY=0
	Cooldown=120
	WindUp=0.6
	WindupMessage="calls down the heavens' spears..."
	ActiveMessage="unleashes a deluge of Javelin Rain!"
	verb/Javelin_Rain()
		set category="Skills"
		if(!altered)
			DamageMult = 2.5 + (0.15 * usr.AscensionsAcquired)
			Wander = 10 + (2 * usr.AscensionsAcquired)
			ForOffense = 2 + (0.5 * usr.AscensionsAcquired)
		usr.Activate(src)

// =========================================================================
// Gundari skills
// =========================================================================

/obj/Skills/Projectile/DemiFiend/Wind_Cutter
	ElementalClass="Wind"
	SpellElement="Air"
	IconLock='SparkleGreen.dmi'
	IconSize=1
	LockX=-16
	LockY=-16
	Speed=0.2
	Distance=22
	DamageMult=10
	ForRate=1
	Shearing=50
	Homing=1
	Cooldown=45
	verb/Wind_Cutter()
		set category="Skills"
		if(!altered)
			DamageMult = 10 + (1.5 * usr.AscensionsAcquired)
			Distance = 22 + (2 * usr.AscensionsAcquired)
		usr.UseProjectile(src)

/obj/Skills/AutoHit/DemiFiend/Spiral_Viper
	Area="Wave"
	Distance=8
	Rush=7
	ControlledRush=1
	DamageMult=5
	StrOffense=2
	ForOffense=1
	SpecialAttack=1
	GuardBreak=1
	CriticalChance=30
	Shearing=50
	ObjIcon=1
	Icon='Slash - Ragna.dmi'
	IconX=-16
	IconY=-16
	Size=1.5
	Rounds=6
	DelayTime=1
	HitSparkIcon='Hit Effect Wind.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkTurns=1
	HitSparkSize=1
	Cooldown=100
	WindUp=0.4
	WindupMessage="coils around themselves like a serpent..."
	ActiveMessage="lashes out with Spiral Viper!"
	verb/Spiral_Viper()
		set category="Skills"
		if(!altered)
			DamageMult = 5 + (0.5 * usr.AscensionsAcquired)
			Distance = 8 + (2 * usr.AscensionsAcquired)
			Rush = 7 + (1 * usr.AscensionsAcquired)
			StrOffense = 2 + (0.5 * usr.AscensionsAcquired)
		usr.Activate(src)

// =========================================================================
// Sophia skills
// =========================================================================

/obj/Skills/Projectile/DemiFiend/Thunderclap
	ElementalClass="Light"
	SpellElement="Light"
	IconLock='AvalonLight.dmi'
	IconSize=1
	LockX=-16
	LockY=-16
	Speed=0.2
	Distance=24
	DamageMult=11
	ForRate=1
	Homing=1
	Cooldown=50
	verb/Thunderclap()
		set category="Skills"
		if(!altered)
			DamageMult = 11 + (1.5 * usr.AscensionsAcquired)
			Distance = 24 + (2 * usr.AscensionsAcquired)
		usr.UseProjectile(src)

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/MediarahanApply
	StableHeal=1
	HealthHeal=1.5
	TimerLimit=10
	ActiveMessage="is bathed in radiant healing light!"
	OffMessage="the radiant healing fades..."
	MagicNeeded=0

obj/Skills/Buffs/SlotlessBuffs/DemiFiend/Mediarahan
	ElementalClass="Light"
	EndYourself=1
	Cooldown=600
	KenWave=1
	KenWaveIcon='SparkleYellow.dmi'
	KenWaveSize=6
	KenWaveX=105
	KenWaveY=105
	ActiveMessage="calls down a flood of miraculous light upon their party!"
	OffMessage="finishes casting Mediarahan."
	verb/Mediarahan()
		set category="Skills"
		var/mob/User = usr
		if(!User.party || !User.party.members || User.party.members.len == 0)
			User << "You need to be in a party to use Mediarahan."
			return
		if(!altered)
			adjust(User)
		for(var/mob/m in User.party.members)
			if(!m || !ismob(m)) continue
			var/obj/Skills/Buffs/SlotlessBuffs/DemiFiend/MediarahanApply/applyBuff = new
			applyBuff.HealthHeal = 1.5
			applyBuff.StableHeal = 1
			applyBuff.TimerLimit = 10
			applyBuff.Trigger(m, 1)
		User.OMessage(1, null, "[User] calls down a flood of miraculous light upon [User.party.members.len == 1 ? "themselves" : "their party"]!")
		src.Cooldown(1, null, User)

/obj/Skills/AutoHit/DemiFiend/Holy_Wrath
	ElementalClass="Light"
	SpellElement="Light"
	Area="Around Target"
	Distance=12
	DistanceAround=8
	Erupt=1
	EruptOffset=1
	DamageMult=1.5
	ForOffense=2
	SpecialAttack=1
	MortalBlow=1
	Rounds=10
	DelayTime=2
	HitSparkIcon='BLANK.dmi'
	HitSparkX=0
	HitSparkY=0
	Cooldown=120
	WindUp=0.6
	WindupMessage="calls forth divine condemnation..."
	ActiveMessage="unleashes Holy Wrath upon the wicked!"
	verb/Holy_Wrath()
		set category="Skills"
		if(!altered)
			DamageMult = 1.5 + (0.25 * usr.AscensionsAcquired)
			DistanceAround = 8 + (1 * usr.AscensionsAcquired)
		usr.Activate(src)

// =========================================================================
// Gaea skills
// =========================================================================

/obj/Skills/AutoHit/DemiFiend/Deathbound
	StrOffense=2
	EndDefense=1
	HeldSkill=TRUE
	ChargePeriod=3
	SweetSpot=2
	SweetSpotBenefit=4
	ChargeOverlay='DarkShock.dmi'
	ChargeWaveIcon='DarkKiai.dmi'
	ChargeWaveBlend=2
	Cooldown=120

	OnHeldRelease(mob/p, var/benefit)
		var/obj/Effects/DeathboundWave/W = new(p.loc)
		W.owner = p
		W.DamageMult = (8 + p.AscensionsAcquired) * benefit
		W.StrOffense = 2

	verb/Deathbound()
		set category="Skills"
		usr.BeginHeldSkill(src)

/obj/Skills/AutoHit/DemiFiend/Gaea_Rage
	Area="Circle"
	Distance=10
	DamageMult=20
	StrOffense=2
	ForOffense=1
	SpecialAttack=1
	TurfErupt=2
	TurfEruptOffset=3
	Divide=1
	PullIn=20
	CriticalChance=15
	Slow=1
	HitSparkIcon='BLANK.dmi'
	HitSparkX=0
	HitSparkY=0
	Cooldown=180
	WindUp=1
	WindupMessage="gathers the fury of the living earth..."
	ActiveMessage="erupts into Gaea Rage!"
	verb/Gaea_Rage()
		set category="Skills"
		if(!altered)
			DamageMult = 20 + (5 * usr.AscensionsAcquired)
			Distance = 10 + (1 * usr.AscensionsAcquired)
		usr.Activate(src)

// =========================================================================
// Kailash skills
// =========================================================================

/obj/Skills/AutoHit/DemiFiend/Hades_Blast
	Area="Arc"
	Distance=4
	DamageMult=1
	StrOffense=2
	SpecialAttack=1
	GuardBreak=1
	ComboMaster=1
	TurfStrike=1
	Rounds=12
	DelayTime=1
	RoundMovement=0
	HitSparkIcon='Slash - Vampire.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkTurns=1
	HitSparkSize=1.5
	HitSparkDispersion=1
	Cooldown=120
	WindUp=0.5
	WindupMessage="gathers the unbearable weight of the underworld..."
	ActiveMessage="unleashes a shattering Hades Blast!"
	verb/Hades_Blast()
		set category="Skills"
		if(!altered)
			DamageMult = 1 + (0.25 * usr.AscensionsAcquired)
		usr.Activate(src)

// New versions of skills (old paths preserved for save compatibility)
/obj/Skills/Projectile/DemiFiend/Freikugel_Beam
	name = "Freikugel"
	ElementalClass = "Ultima"
	Area = "Beam"
	IconLock = 'Beam17Dark.dmi'
	LockX = -16
	LockY = -16
	IconSize = 1
	Distance = 50
	DamageMult = 40
	ChargeRate = 0.5
	BeamTime = 25
	AccMult = 1.175
	Knockback = 1
	Deflectable = -1
	Cooldown = 90
	ChargeMessage = "concentrates an overwhelming surge of almighty power..."
	ActiveMessage = "fires a devastating beam of almighty force - Freikugel!"
	adjust(mob/p)
		if(!altered)
			DamageMult = 40 + (2 * p.AscensionsAcquired)
	verb/Freikugel()
		set category = "Skills"
		adjust(usr)
		usr.UseProjectile(src)

/obj/Skills/AutoHit/DemiFiend/Glacial_Blast_Ice
	name = "Glacial Blast"
	ElementalClass = "Water"
	SpellElement = "Water"
	Area = "Around Target"
	Distance = 12
	DistanceAround = 8
	ObjIcon = 1
	Icon = 'Frost Mage VFX6.dmi'
	IconX = -64
	IconY = -64
	Size = 1.5
	DamageMult = 1
	ForOffense = 1
	Rounds = 10
	DelayTime = 2
	Chilling = 20
	Freezing = 20
	IceAge = 50
	HitSparkIcon = 'BLANK.dmi'
	HitSparkX = 0
	HitSparkY = 0
	Cooldown = 90
	WindUp = 0.5
	WindupMessage = "calls down an icy shroud..."
	ActiveMessage = "erupts in a glacial blast of frozen force!"
	adjust(mob/p)
		if(!altered)
			DamageMult = 1 + (0.25 * p.AscensionsAcquired)
			Freezing = 40 + (5 * p.AscensionsAcquired)
	verb/Glacial_Blast()
		set category = "Skills"
		adjust(usr)
		usr.Activate(src)

/obj/Skills/Projectile/DemiFiend/Javelin_Rain_Proj
	name = "Javelin Rain"
	ZoneAttack = 1
	Blasts = 20
	Homing = 1
	Explode = 1
	Distance = 20
	DamageMult = 1
	AccMult = 1
	IconLock = 'Blast22.dmi'
	LockX = -16
	LockY = -16
	IconSize = 1
	ZoneAttackX = 5
	ZoneAttackY = 5
	Hover = 8
	Silencing = 5
	Cooldown = 120
	ChargeMessage = "calls down the heavens' spears..."
	ActiveMessage = "unleashes a deluge of Javelin Rain!"
	adjust(mob/p)
		if(!altered)
			DamageMult = 1 + (0.25 * p.AscensionsAcquired)
			Blasts = 20 + (2 * p.AscensionsAcquired)
	verb/Javelin_Rain()
		set category = "Skills"
		adjust(usr)
		usr.UseProjectile(src)

/obj/Skills/Projectile/DemiFiend/Magma_Axis_Beam
	name = "Magma Axis"
	ElementalClass = "Fire"
	SpellElement = "Fire"
	Area = "Beam"
	IconLock = 'BeamBig6.dmi'
	Distance = 40
	DamageMult = 20
	BeamTime = 20
	ChargeRate = 1
	AccMult = 1.175
	Knockback = 1
	Deflectable = -1
	Scorching = 50
	Cooldown = 90
	ChargeMessage = "ignites the magma within their blade..."
	ActiveMessage = "fires a blazing Magma Axis!"
	adjust(mob/p)
		if(!altered)
			DamageMult = 20 + (2 * p.AscensionsAcquired)
			Scorching = 10 + (5 * p.AscensionsAcquired)
	verb/Magma_Axis()
		set category = "Skills"
		adjust(usr)
		usr.UseProjectile(src)

/obj/Skills/Projectile/DemiFiend/Spiral_Viper_Beam
	name = "Spiral Viper"
	SpellElement = "Air"
	Area = "Beam"
	IconLock = 'BeamFS.dmi'
	Distance = 50
	DamageMult = 30
	ChargeRate = 1
	BeamTime = 15
	AccMult = 1.175
	Knockback = 1
	Deflectable = -1
	Shocking = 10
	CriticalChance = 20
	Cooldown = 120
	ChargeMessage = "coils their power into a singular lethal strike..."
	ActiveMessage = "fires Spiral Viper with devastating force!"
	adjust(mob/p)
		if(!altered)
			DamageMult = 30 + (1.5 * p.AscensionsAcquired)
	verb/Spiral_Viper()
		set category = "Skills"
		adjust(usr)
		usr.UseProjectile(src)

/obj/Skills/AutoHit/DemiFiend/Mamudo_Curse
	name = "Mamudo"
	ElementalClass = "Dark"
	SpellElement = "Dark"
	Area = "Target"
	Distance = 10
	DamageMult = 8
	ForOffense = 2
	Doom = 20
	HitSparkIcon = 'Warlock VFX3.dmi'
	HitSparkX = -64
	HitSparkY = -64
	HitSparkTurns = 1
	HitSparkSize = 1
	Cooldown = 60
	WindUp = 0.4
	WindupMessage = "whispers a dark incantation..."
	ActiveMessage = "calls down Mamudo upon their foe!"
	adjust(mob/p)
		if(!altered)
			DamageMult = 8 + (1 * p.AscensionsAcquired)
			Doom = 20 + (5 * p.AscensionsAcquired)
	verb/Mamudo()
		set category = "Skills"
		adjust(usr)
		usr.Activate(src)

/obj/Skills/AutoHit/DemiFiend/Wind_Cutter_Gust
	name = "Wind Cutter"
	ElementalClass = "Wind"
	SpellElement = "Air"
	Area = "Around Target"
	Distance = 10
	DistanceAround = 8
	ObjIcon = 1
	Icon = 'Warrior VFX4.dmi'
	IconX = -64
	IconY = -64
	Size = 1.5
	DamageMult = 2
	ForOffense = 1
	Rounds = 8
	DelayTime = 2
	Shearing = 20
	Shocking = 30
	HitSparkIcon = 'BLANK.dmi'
	HitSparkX = 0
	HitSparkY = 0
	Cooldown = 60
	WindupMessage = "summons a cutting gale..."
	ActiveMessage = "unleashes Wind Cutter!"
	adjust(mob/p)
		if(!altered)
			DamageMult = 2 + (0.25 * p.AscensionsAcquired)
	verb/Wind_Cutter()
		set category = "Skills"
		adjust(usr)
		usr.Activate(src)

/obj/Skills/Projectile/DemiFiend/Xeros_Beat_Proj
	name = "Xeros Beat"
	Blasts = 12
	Charge = 1
	DamageMult = 1
	Homing = 2
	Explode = 1
	Distance = 20
	Speed = 0.3
	AccMult = 1.5
	ZoneAttackX = 5
	ZoneAttackY = 5
	Hover = 8
	IconLock = 'Blast31.dmi'
	LockX = -16
	LockY = -16
	IconSize = 1
	Cooldown = 90
	ActiveMessage = "launches a storm of crushing blasts — Xeros Beat!"
	adjust(mob/p)
		if(!altered)
			DamageMult = 1 + (0.25 * p.AscensionsAcquired)
			Blasts = 12 + (2 * p.AscensionsAcquired)
	verb/Xeros_Beat()
		set category = "Skills"
		adjust(usr)
		usr.UseProjectile(src)

/obj/Skills/Projectile/DemiFiend/Hellfire_Proj
	name = "Hellfire"
	ElementalClass = "Fire"
	SpellElement = "Fire"
	Distance = 50
	DamageMult = 5.5
	MultiHit = 5
	Radius = 2
	Knockback = 5
	Explode = 2
	Scorching = 10
	Homing = 1
	Cooldown = 120
	IconLock = 'Fire VFX8.dmi'
	LockX = -16
	LockY = -16
	IconSize = 1
	ChargeMessage = "concentrates a devastating surge of hellfire..."
	ActiveMessage = "unleashes a torrent of Hellfire!"
	adjust(mob/p)
		if(!altered)
			DamageMult = 5.5 + (0.25 * p.AscensionsAcquired)
			Scorching = 10 + (10 * p.AscensionsAcquired)
	verb/Hellfire()
		set category = "Skills"
		adjust(usr)
		usr.UseProjectile(src)

/obj/Skills/AutoHit/DemiFiend/Thunderclap_Storm
	name = "Thunderclap"
	ElementalClass = "Wind"
	SpellElement = "Air"
	Area = "Circle"
	Distance = 8
	Bolt = 4
	BoltOffset = 1
	DamageMult = 10
	ForOffense = 1
	Paralyzing = 15
	MortalBlow = 1
	HitSparkIcon = 'BLANK.dmi'
	HitSparkX = 0
	HitSparkY = 0
	Cooldown = 45
	WindUp = 0.5
	WindupMessage = "gathers a crackling thunderstorm overhead..."
	ActiveMessage = "calls down Thunderclap!"
	adjust(mob/p)
		if(!altered)
			DamageMult = 10 + (1 * p.AscensionsAcquired)
	verb/Thunderclap()
		set category = "Skills"
		adjust(usr)
		usr.Activate(src)

/obj/Effects/DeathboundWave
	icon = 'DarkKiai.dmi'
	pixel_x = -105
	pixel_y = -105
	Grabbable = 0
	mouse_opacity = 0
	layer = EFFECTS_LAYER
	var/max_size = 4.0
	var/wave_lifetime = 25
	var/mob/Players/owner
	var/DamageMult = 8
	var/StrOffense = 2
	var/EndRes = 1
	var/list/hitList = list()

	New()
		animate(src)
		transform = matrix() * 0.1
		alpha = 255
		spawn(0)
			hitDetectLoop()

	proc/hitDetectLoop()
		set waitfor = FALSE
		var/start_time = world.time
		var/prev_radius_tiles = 0.0
		var/list/outsideSet = list()
		while(src)
			var/tick_begin = world.time
			if(!owner || !owner.loc) break
			if(owner.PureRPMode)
				sleep(1)
				start_time += (world.time - tick_begin)
				continue

			var/elapsed = world.time - start_time
			if(elapsed >= wave_lifetime)
				EffectFinish()
				break

			var/t = elapsed / wave_lifetime
			var/scale = 0.1 + (max_size - 0.1) * t
			var/curr_radius_tiles = (scale * 121.0) / 32.0
			src.transform = matrix() * scale
			src.alpha = round(255 * (1 - t))

			for(var/mob/Players/P in players)
				if(!P.client) continue
				if(P == owner) continue
				if(P.z != owner.z) continue
				if(owner.inParty(P.ckey)) continue

				var/dx = P.x - owner.x
				var/dy = P.y - owner.y
				var/dist = sqrt(dx * dx + dy * dy)

				if(dist > curr_radius_tiles)
					if(!(P in outsideSet))
						outsideSet += P
				else
					if(P in outsideSet)
						outsideSet -= P
						if(!(P in hitList))
							if(dist > prev_radius_tiles)
								hitList += P
								dealWaveDamage(P)

			prev_radius_tiles = curr_radius_tiles
			sleep(1)

	proc/dealWaveDamage(mob/Players/target)
		if(!owner || !target) return
		if(owner.PureRPMode) return

		var/powerDif = owner.Power / target.Power
		if(glob.CLAMP_POWER && !owner.ignoresPowerClamp())
			powerDif = clamp(powerDif, glob.MIN_POWER_DIFF, glob.MAX_POWER_DIFF)

		var/atk = owner.GetStr(StrOffense)
		if(atk <= 0) atk = 0.01

		var/def = target.getEndStat(1) * EndRes
		if(def <= 0) def = 0.01

		var/FinalDmg = (clamp(powerDif, 0.1, 100000) ** glob.DMG_POWER_EXPONENT) * \
		               (glob.CONSTANT_DAMAGE_EXPONENT + glob.AUTOHIT_EFFECTIVNESS) ** \
		               -(def ** glob.DMG_END_EXPONENT / atk ** glob.DMG_STR_EXPONENT)
		FinalDmg *= DamageMult
		FinalDmg *= owner.GetDamageMod()
		FinalDmg *= glob.AUTOHIT_GLOBAL_DAMAGE

		if(FinalDmg <= 0) return
		target.LoseHealth(FinalDmg)

		var/obj/Effects/HE = new(null, 'fevExplosion - Hellfire.dmi', -32, -32, 0, 1, 8)
		HE.appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		HE.Target = target
		target.vis_contents += HE

/obj/Effects/HeatWaveShock
	icon = 'KenShockwaveBloodlust.dmi'
	pixel_x = -105
	pixel_y = -105
	Grabbable = 0
	mouse_opacity = 0
	layer = EFFECTS_LAYER
	var/max_size = 4.0
	var/wave_lifetime = 20
	var/mob/Players/owner
	var/DamageMult = 7
	var/StrOffense = 2
	var/EndRes = 1
	var/list/hitList = list()

	New()
		animate(src)
		transform = matrix() * 0.1
		alpha = 255
		spawn(0)
			hitDetectLoop()

	proc/hitDetectLoop()
		set waitfor = FALSE
		var/start_time = world.time
		var/prev_radius_tiles = 0.0
		var/list/outsideSet = list()
		while(src)
			var/tick_begin = world.time
			if(!owner || !owner.loc) break
			if(owner.PureRPMode)
				sleep(1)
				start_time += (world.time - tick_begin)
				continue

			var/elapsed = world.time - start_time
			if(elapsed >= wave_lifetime)
				EffectFinish()
				break

			var/t = elapsed / wave_lifetime
			var/scale = 0.1 + (max_size - 0.1) * t
			var/curr_radius_tiles = (scale * 121.0) / 32.0
			src.transform = matrix() * scale
			src.alpha = round(255 * (1 - t))

			for(var/mob/Players/P in players)
				if(!P.client) continue
				if(P == owner) continue
				if(P.z != owner.z) continue
				if(owner.inParty(P.ckey)) continue

				var/dx = P.x - owner.x
				var/dy = P.y - owner.y
				var/dist = sqrt(dx * dx + dy * dy)

				if(dist > curr_radius_tiles)
					if(!(P in outsideSet))
						outsideSet += P
				else
					if(P in outsideSet)
						outsideSet -= P
						if(!(P in hitList))
							if(dist > prev_radius_tiles)
								hitList += P
								dealWaveDamage(P)

			prev_radius_tiles = curr_radius_tiles
			sleep(1)

	proc/dealWaveDamage(mob/Players/target)
		if(!owner || !target) return
		if(owner.PureRPMode) return

		var/powerDif = owner.Power / target.Power
		if(glob.CLAMP_POWER && !owner.ignoresPowerClamp())
			powerDif = clamp(powerDif, glob.MIN_POWER_DIFF, glob.MAX_POWER_DIFF)

		var/atk = owner.GetStr(StrOffense)
		if(atk <= 0) atk = 0.01

		var/def = target.getEndStat(1) * EndRes
		if(def <= 0) def = 0.01

		var/FinalDmg = (clamp(powerDif, 0.1, 100000) ** glob.DMG_POWER_EXPONENT) * \
		               (glob.CONSTANT_DAMAGE_EXPONENT + glob.AUTOHIT_EFFECTIVNESS) ** \
		               -(def ** glob.DMG_END_EXPONENT / atk ** glob.DMG_STR_EXPONENT)
		FinalDmg *= DamageMult
		FinalDmg *= owner.GetDamageMod()
		FinalDmg *= glob.AUTOHIT_GLOBAL_DAMAGE

		if(FinalDmg <= 0) return
		target.LoseHealth(FinalDmg)

		var/obj/Effects/HE = new(null, 'fevExplosion - Hellfire.dmi', -32, -32, 0, 1, 8)
		HE.appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		HE.Target = target
		target.vis_contents += HE
