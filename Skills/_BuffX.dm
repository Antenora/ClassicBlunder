
#define ROUND_DIVIDE(N,N2) round(N/N2,0.15)
#define PURE_GRIM_SCALING FALSE
obj/Skills/Buffs
	Cooldown=1
/**
NEW VARIABLES
**/
	var/Engrain // stick user in place + make unable to be KB'd
	var/MissleSystem // Makes Projectiles into homing
	var/PowerPole // variable number = to how far an attack can reach
	var/GiantSwings // variable number  = to size of attack aoe
	var/HitScanIcon = null
	var/HitScanHitSpark = null
	var/HitScanHitSparkX = 0
	var/HitScanHitSparkY = 0

//Stats
	var/strAdd = 0
	var/endAdd = 0
	var/forAdd = 0
	var/spdAdd = 0
	var/offAdd = 0
	var/defAdd = 0


	var/PowerInvisible=1//multiplies stealth RPP
	var/PowerMult=1
	var/PowerReplacement=0
	var/StrReplace=0
	var/EndReplace=0
	var/SpdReplace=0
	var/ForReplace=0
	var/OffReplace=0
	var/DefReplace=0
	var/RegenReplace=0
	var/RecovReplace=0
	var/EnergyReplace=0
	var/StrMult=1
	var/EndMult=1
	var/SpdMult=1
	var/ForMult=1
	var/OffMult=1
	var/DefMult=1
	var/RegenMult=1
	var/RecovMult=1
	var/EnergyMult=1
	var/list/CantHaveTheseBuffs
//Slot definitions and requirements
	var/BuffName
	var/ActiveSlot //Takes active slots.
	var/SpecialSlot //Takes special slots.
	var/Slotless //Is it actually slotless?
	var/SlotlessOn=0 //No slot to fill; this is how you keep track of slotless buffs.
	var/StanceSlot //Uses your stance slot.
	var/StyleSlot //Uses your style slot.
	var/UsesStance //Cant use basic stances with this.
	var/StanceActive //sets your active stance
	var/StyleActive //sets your style
	//NoSword//Can't use swords with this.
	//NeedsSword//Have to use swords with this.
	var/list/ABuffNeeded=null
	var/SBuffNeeded//special buff req
	var/UBuffNeeded//universal (slotless) buff req, not used/implemented yet
	var/NeedsAnger//Cant use the buff before youre angry.
	var/NeedsHealth//Cant use the buff before youre below x health.
	var/NeedsSSJ//defines if buff only can be used in SSJ and in what level
	var/NeedsTrans//same as above but for non-SSJ
	var/NeedsTier//you gotta be good enough in your Saga to use
	var/WoundIntentRequired
	var/WarpZone//Tick this if it teleports you somewhere...
	var/mob/Players/WarpTarget//Keeps a copy of the key of the person warped.
	var/WarpX//then use these to determine where.
	var/WarpY
	var/WarpZ
	var/SendBack = FALSE
	var/Fusion//Adds a whole bunch of restrictions.
	var/FusionFailure//...and if you fuck it up...
	var/OldLocX//These are used to return to the previous location.
	var/OldLocY
	var/OldLocZ
	var/UnrestrictedBuff//You can use this with ENNETHING.
	var/NoRevert=0//no reversion during thing.
	var/Range//only for targetted shit
	var/ForcedRange //you need to be -exactly- in the distance
	var/obj/Skills/Buffs/applyToTarget
//Costs, drains and timers
	//AllOutAttack - IGNORE COSTS, DO IT ANYWAY.
	//HealthCost - One time cost of health to activate buff.
	//ManaCost - One time cost of mana to activate buff.
	//WoundCost=0 // One time cost of wounds to activate.
	///FatigueCost=0// On time cost of fatigue to activate.
	var/RegenerateLimbs //DOES IT REGENERATE LIMBS?!
	var/StableHeal //does it care about your regen/recov

	var/HealthDrain=0 //Subtracted every second the buff is up.
	var/HealthHeal=0
	var/HealthThreshold=0 //Lowest health that the buff can be up at.
	var/StaticHeal=0
	var/DrainAll=0
	var/EnergyDrain=0
	var/EnergyHeal=0
	var/EnergyThreshold=0
	var/ManaDrain=0
	var/ManaHeal=0
	var/ManaThreshold=0
	var/WoundDrain=0//Added every second a buff is active.
	var/WoundHeal=0
	var/WoundThreshold=0//Highest wound that the buff can be at before shutting off.
	var/FatigueDrain=0//Added every second a buff is active.
	var/FatigueHeal=0
	var/FatigueThreshold=0//Highest fatigue that the buff can be at before shutting off.
	var/CapacityDrain=0
	var/CapacityHeal=0
	var/CapacityThreshold=0
	var/TimerLimit//If the buff has a timer, this will be filled.
	var/Timer//How long youve been in the buff.  If this exceeds Timer Limit, it will snap you out of it.
	var/PhysicalHits//Unarmed or Sword hits
	var/PhysicalHitsLimit
	var/UnarmedHits//Just Unarmed
	var/UnarmedHitsLimit
	var/SwordHits//Just sword
	var/SwordHitsLimit
	var/SpiritHits//Ki attacks
	var/SpiritHitsLimit
	var/DashCount
	var/DashCountLimit
	var/CastingTime=0//how long does the buff take to perform
	var/ManaGlow
	var/ManaGlowSize
	var/ArmamentGlow
	var/ArmamentGlowSize

	var/BleedHit //Makes you deal damage to yourself when you hit.
	var/ManaLeak //Makes you spend mana when you hit
	var/EnergyLeak
	var/FatigueLeak //Makes you gain fatigue when you hit.
	var/WoundNerf //BP wounds
	var/OverClock //Gates level for things that arent gates.
	var/HealthCut //Permanently removes a portion of HP.  1=100%, 0.05=5%, and so on.
	var/EnergyCut //Reaching 1 with health/energy will kill you, btw.
	var/ManaCut //Reaching 1 with this will not.
	var/StrCut //These will not regenerate
	var/EndCut
	var/SpdCut
	var/ForCut
	var/OffCut
	var/DefCut
	var/RegenCut
	var/RecovCut
	var/StrTax//These will regenerate
	var/EndTax
	var/SpdTax
	var/ForTax
	var/OffTax
	var/DefTax
	var/RegenTax
	var/RecovTax
	//These variables will accumulate at [this value] per second
	var/StrTaxDrain
	var/StrCutDrain
	var/EndTaxDrain
	var/EndCutDrain
	var/SpdTaxDrain
	var/SpdCutDrain
	var/ForTaxDrain
	var/ForCutDrain
	var/OffTaxDrain
	var/OffCutDrain
	var/DefTaxDrain
	var/DefCutDrain
	var/RegenTaxDrain
	var/RegenCutDrain
	var/RecovTaxDrain
	var/RecovCutDrain
	var/TaxThreshold//If this is flagged, going over the value will start generating cuts rather than taxes.
	var/MaimCost
//Aesthetics
	icon='BLANK.dmi'//Normal icons
	//pixel x
	//pixel y
	var/PowerGlows
	var/StripEquip//LETS GET NAKED
	var/FlashChange
	var/DarkChange
	var/FlashFusion
	var/FlashDraw
	var/NameTrue
	var/NameFake
	var/IconLock//If this has a value, it is used for the icon always.
	var/IconLockBlend=1
	var/IconLayer=2//customization eventually
	var/LockX//These are used to make sure the locked icon is always in place.
	var/LockY
	var/IconUnder//places the lock as underlay instead
	var/IconApart//KEEP_APART the overlay alpha and color wise
	var/IconRelayer//if it needs to go under TopOverlay/hair
	var/TopOverlayLock//subs out the aura
	var/TopOverlayX
	var/TopOverlayY
	var/NoTopOverlay=0
	var/AuraLock//subs out the aura
	var/AuraUnder//specifically for underlay auras
	var/AuraX
	var/AuraY
	var/HairLock//subs out the aura
	var/HairX
	var/HairY
	var/Enlarge//Makes icon get fukcnig huge. TODO: Replace all functionalities with ProportionShift
	var/ProportionShift//uses transfrom matrix to fuck with proportions
	var/IconReplace //Icon replaces base icon.
	var/IconTransform //COMPLETE HENSHIN
	var/TransformX
	var/TransformY
	var/alphaChange
	var/IconTint//tints the base icon + current hair
	var/ClientTint//just for checks
	var/OldIcon//Holds old base icon.
	var/OldX//Old pixels.
	var/OldY
	var/DropOverlays//Using buff erases overlays.
	var/Earthshaking//makes ppl screens go woozowyfp when u activate buff hehe
	var/KenWave//makes Kiai shockwaves
	var/KenWaveIcon='fevKiai.dmi'
	var/KenWaveSize=1
	var/KenWaveBlend=1
	var/KenWaveTime=12
	var/KenWaveX
	var/KenWaveY
	var/KKTWave//makes Kiai shockwaves UNDER YOU
	var/KKTWaveIcon='fevKiai.dmi'
	var/KKTWaveSize=1
	var/KKTWaveX
	var/KKTWaveY
	var/DustWave
	var/ActiveMessage //what do you think it does?!
	var/OffMessage
	var/TextColor //Makes messages appear a certain color.
	var/HitSpark
	var/HitX=0
	var/HitY=0
	var/HitTurn=0
	var/HitSize=1
	var/TargetOverlay//puts overlay on target
	var/TargetOverlayX
	var/TargetOverlayY
	var/OverlaySize=1//self-explanatory
//	var/TopOverlaySize=1//self-explanatory
	var/OverlayTransLock//forgo the above
	var/Connector//some sort of link between user and target
	var/IconShadow
	var/IconOutline
	var/TurfShift
	var/TurfShiftLayer
	var/TrailImage
	var/VanishImage
//PU modifiers
	var/PULock//No PU.
	var/AllowedPower//declares buffs to be used at low power levels
	var/PUForce//Minus levels from PUlock.
	var/ConstantPU//PU never slows.
	var/UnlimitedPU//Lets you PU forever.
	var/EffortlessPU//Sets a value that you don't drain while you're under.
	var/HighestPU//sets a value added to your PU threshold.
	var/PUDrainReduction=0//Only reduces drain by this amount.
	var/PUSpeedModifier=0//Reduces PU gain
	var/EnergyExpenditure
	var/PURestrictionRemove//Sets Spiral Energy var
	var/ManaPU //When this is flagged, you will burn mana while powering up instead of energy.
	var/HealthPU //when this is flagged, you will burn health while powering up instead of energy.
	var/PUSpike=0//Add this amount of PowerControl on activation, subtract it on deactivation.
	var/AllOutPU//When the buff is turned off, all PU is lost.
//Offense stuff
	//HolyMod//Adds holy mod.
	//AbyssMod//Adds abyss mod.
	//Purity//Can only damage what it's designed to damage (Abyss for holy, Holy for abyss, humans for slayer)
	var/KiBlade//its fooken ki blade m8
	var/SpiritStrike //Punches with FORCE only
	var/SpiritHand //Sunlight stance passive.
	var/SpiritFlow //Moonlight stance passive.
	var/HybridStrike //Punches with For/Str
	var/PridefulRage //Ignore defenses.
	var/NoWhiff //Melee attacks won't whiff.
	//NoForcedWhiff//THEY WON'T WHIFF EVEN HARDER NOW
	//Instinct - go away, AIS/WS
	var/Steady //Consistent damage.
	var/HotHundred//No nerf on light attacks.
	var/Extend//Autohits reach longer.
	var/CriticalChance//Sets the chance to inflict a critical attack.
	var/CriticalDamage//Sets the critical multiplier.
	var/SureHitTimerLimit//Causes a constant CD for sure hit moves to proc.
	var/Duelist//does more damage/take less damage if hitting the person youre targetting; you take more damage if someone youre not targetting hits you and do less damage to them
	var/Vanishing//make invisible and autocombo
	var/UnarmedDamage
	var/SpiritualDamage
	var/MovementMastery//1.x is added to effective PU percent.
//Defense stuff
	var/KBMult//Adds KB Mult to everything.
	var/KBRes//Sets knockback resistance.
	var/KBAdd//Adds KB Add to everything.
	var/FluidForm //Makes all attacks whiff.
	var/GiantForm //Makes all attacks roll low
	var/BioArmor //Honest Vaizard Health
	var/VaizardHealth //Triggers vaizard health passive.
	var/VaizardShatter //Shatters when Vai Health runs out.
	var/Siphon//Raijuu shit
	var/Juggernaut //no KB, harder to launch after stabilizing
	//var/NoDodge//everything hits you
	var/CriticalBlock//Holds the value of division
	var/BlockChance//Holds the chance of blocking.
	var/SureDodgeTimerLimit
	var/Flow //makes you dodge without AIS/WS
	var/CounterMaster//Punch people back with ur queus
	var/Unstoppable//regen through fatigue and injury
	var/DebuffResistance//idgaf about elements
	var/VenomImmune//idgaf about poison tiles
	var/InjuryImmune//duh
	var/FatigueImmune//duuh
//Mobility stuff
	var/Warp//Forces light attacks, but doesnt reduce damage as much.
	var/Godspeed//Adds godspeed.
	var/Afterimages//Makes afterimages.
	var/SpaceWalk//Gives spacewalk.
	var/StaticWalk//Gives staticwalk.
	var/WalkThroughHell//idgaf about lava tiles
	var/WaterWalk//idgaf about water tiles
	var/Warping//Makes you home.  Dear God...
	var/Flicker//makes you nothing personell kid...
	var/Incorporeal//Makes you vanish.
	var/Pursuer//gives low cd DDash
	var/QuickCast//Reduces casting times by this value
	var/DualCast//If you have this, your spells pop off once again
	var/MovingCharge//battlemage
	var/SuperDash//Longer, more aesthetic dragondash
	var/TechniqueMastery//Cooldowns are divided by 1.x this value
	var/SweepingStrike//wingblade style attack zone
//Staff stuff
	var/MakesStaff//Does the buff make a staff?
	var/StaffClass//Is it locked to a class?
	var/StaffIcon//Alt icon
	var/StaffX//Alt X
	var/StaffY//Alt Y
	var/StaffIconUnder
	var/StaffXUnder
	var/StaffYUnder
	var/StaffName//Name (for het l0lz)
	var/StaffAscension//
	var/StaffElement//Set an element to the conjured staff
//Armor stuff
	var/MakesArmor//Conjures armor which is then equipped.
	var/NeedsArmor
	var/ArmorElement
	var/ArmorClass
	var/ArmorIcon
	var/ArmorX
	var/ArmorY
	var/ArmorIconUnder
	var/ArmorXUnder
	var/ArmorYUnder
	var/ArmorName
	var/ArmorAccuracy
	var/ArmorDamage
	var/ArmorDelay
	var/ArmorAscension
	var/ArmorKill
	var/SwordShatterTier
//Sword stuff
	var/NeedsSecondSword//MOAR!!
	var/NeedsThirdSword//MOAAR!!
	var/MakesSword//Conjures a sword which is then equipped.
	var/swordHasHistory
	var/MakesSecondSword//Conjures a second sword which is then equipped.
	var/MakesThirdSword
	//One day, we may need to make third swords.  But fuck that shit, for real, yo.
	var/SwordClass//Makes a class of sword.
	var/SwordClassOld//stores old class for wepaon transform shenanigans
	var/SwordIcon//Forces sword to have a particular icon.
	var/SwordIconOld//stores old icon for the sword
	var/SwordX//pixel_x and y for sword.
	var/SwordY
	var/SwordIconUnder
	var/SwordXUnder
	var/SwordYUnder
	var/SwordUnbreakable
	var/SwordElement
	var/SwordXOld//pixel_x and y for sword.
	var/SwordYOld
	var/SwordClassSecond
	var/SwordClassSecondOld
	var/SwordIconSecond
	var/SwordIconSecondOld
	var/SwordXSecond
	var/SwordYSecond
	var/SwordElementSecond
	var/SwordXSecondOld
	var/SwordYSecondOld
	var/SwordClassThird
	var/SwordClassThirdOld
	var/SwordIconThird
	var/SwordIconThirdOld
	var/SwordXThird
	var/SwordYThird
	var/SwordXThirdOld
	var/SwordYThirdOld
	var/SwordName
	var/SwordElementThird
	var/SwordNameSecond//gives the sword a particular name
	var/SwordNameThird//gives the sword a particular name
	var/SwordAccuracy//Adds to swords accuracy
	var/SwordAccuracySecond
	var/SwordAccuracyThird
	var/SwordDamage//Adds to swords damage
	var/SwordDamageSecond
	var/SwordDamageThird
	var/SwordDelay//Adds to swords delay
	var/SwordDelaySecond
	var/SwordDelayThird
	var/SwordAscension
	var/SwordAscensionSecond//ascension level buff. buffs everything and shatterproofs
	var/SwordAscensionThird//ascension level buff. buffs everything and shatterproofs
	var/SwordRefinement
	var/SpiritSword//ACTUALLY MAKES A SPIRIT SWORD FFS
	var/MagicSword//sword is treated as a staff. only a staff. heh.
	var/MagicSwordSecond
	var/MagicSwordThird
	var/KillSword//Kills the sword when the buff is removed.
//Anger stuff
	var/AutoAnger //Flicks anger on
	var/AngerMult //Mults anger.
	var/AngerThreshold //If anger is lower than this, it will set your anger.
	var/CalmAnger //Adds your anger to power mult.
	var/AngerStorage//holds your anger so that calm anger doesnt bug you the FUCK out.
	var/WaveringAngerLimit//Every time this amount of seconds passes, there is a chance for your anger to fail for the same interval.
	var/WaveringAnger//This tallies how long the current increment is.
	var/NoAnger //Cant be mad about that...
	var/AngerMessage //modifies anger message
	var/OldAngerMessage //holds old anger message
//Mana stuff
	var/ManaAdd//Adds this mana when used, removes this amount when turned off.
	var/ManaStats//If mana is over cap, times all stats by 1.5x*This value.  i.e. 0.5 mana stats would give 1.25x
	var/DrainlessMana//You cant lose mana.  Seriously.
	var/LimitlessMagic//Nothing will stop you from casting, ever.
	var/MartialMagic//muscle wizardry
//Special stuff
	var/TransLock//lock transes
	var/TransMimic//adds to trans active value
	var/Reversal//counter autohits
	var/Desperation//Sets desperation value.  Does cool shit.
	var/Tension=0//Holds Tension value. Does cool shit.
	var/KiControl//will be used to make sure you dont drop PU percents and get your PU stats
	var/KiControlMastery//ticks KiControl var.
	//var/DarknessFlame//makes funny thing with fire
	var/GatesLevel//A tag for gates which sets the nerf and nerf time.
	var/ShuttingGates//This has to be flagged for gates nerf to trigger.
	var/WeaponBreaker//Adds weaponbreaker variable.
	var/StealsResources //Steals resources...come on...
	var/StealsStats //
	var/ManaSeal //Seals this amount per 1 damage delivered.
	var/ArcaneBladework //sets ArcaneBladework.
	var/BuffMastery //Reduce nerfs and buff buffs.
	var/Curse//sets your Cursed Wound Variable, maybe some other stuff later
	var/FusionPowered
	var/Overdrive//synergy with cyber bp, androids, fusion cores and cyber modules
	var/OldEffortlessPU
	var/Intimidation//showy power
	var/Transform//triggers Transformations
	var/ElementalOffense//changes your elemental offense
	var/ElementalDefense//likewise
	var/ElementalEnchantment//sets elements on unenchanted swords/staves
	var/Kaioken//ITS KAIOKEN, BITCH.
	var/InstantAffect//instantly dump all affects
	var/InstantAffected//binary to check if debuffs were dumped
	var/BurnAffected//it adds burn stacks
	var/SlowAffected
	var/ShockAffected
	var/ShatterAffected
	var/PoisonAffected//it adds poison stacks
	var/CrippleAffected
	var/ShearAffected
	var/ConfuseAffected
	var/StunAffected//adds stun stacks
	var/BurningShot//It increases stats which burn out as you do
	var/MirrorStats//It makes your stats the same as the enemys.
	var/Erosion//It gradually reduces the enemys buffstats to 1.
	var/EndYourself//doh
	var/ExplosiveFinish//explodes when over
	var/ExplosiveFinishIntensity
	var/FINISHINGMOVE//It knocks the user out after it wears off.
	var/Duel //actually calls for 1v1 me faggot
	var/Invisible//Makes u invisible.
	var/SeeInvisible//makes u see the above
	var/Hardening//Makes you trigger the Hardening buff when hit.
	var/DebuffReversal//Makes you eat debuffs like mmm thats some tasty fuck
	var/StunningStrike//This value * 2.5 chance of inflicting 1 second stun.
	var/SpecialStrike//projectile attack triggers of normal when outta melee range
	var/GodKi//This adds an amount of God Ki.
	var/SenseUnlocked //like GodKi with bit less straightforward progression
	var/DefianceRetaliate//makes you counterattack with power being scaled off your missing health
	var/AffectTarget//doh
	var/Ripple //Use Oxygen
	var/BulletKill //kill bullets, duh
	var/Deflection //10% * this value to autodeflect anything that can be deflected
	var/CyberLimb//pretends you have more cyber slots
	var/Skimming//pretends youre flying
	var/Flight//actually flying
	var/BetterAim
	//var/SoftStyle//Defense / Opponent Speed * this value = Extra fatigue percent gain when hit.  Also adds fatigue into damage
	var/list/BuffTechniques=list()//techniques gained only while the buff is active
	var/Void//becum void person
	var/SpiritForm//racial for yokai; flip str and force mods
	var/LoseDurability//Sword durability gets nuked by this amount.  TODO: armor version?
	var/Mechanized//no more magic
	var/Piloting//use that brain for something
	var/Possessive//or let something else use it
	var/Xenobiology//weird body stuffs
	var/Maki//demon stuff
	var/Infatuated//cant harm what you love...
	var/InfatuatedID
	var/AdrenalBoost//getting whacked gives you BP
	var/PoseEnhancement
	var/MagicFocus//operates as a magic focus
	var/DebuffCrash//immediately deals debuff damage
//Imitation
	var/Imitate//guh!
	var/ImitateBadly//guuuuuh!!
	var/ImitateName="???"
	var/ImitateBase='Imitate.dmi'
	var/list/ImitateOverlays=list()
	var/ImitateProfile
	var/ImitateTextColor="777777"
	var/OldName//Holds old name
	var/OldBase//Old base
	var/list/OldOverlays=list()//Old clothes
	var/OldProfile//Old profile
	var/OldTextColor//Old text color
	var/FakePeace=0
//Autonomous activation variables
	var/Autonomous=0
	var/PotionCD=0
	var/NeedsVary=0//alters the health threshold of an autonomous buff to make it less reliable
	var/NeedsPassword=0//allows alteration of buffs that are applied on-hit only
	var/FadeByDeath = FALSE
	var/NeedsAlignment=0//trigger conditionally on being good/evil
	var/TooMuchHealth=0//Once this value is passed, the buff deactivates.
	var/TooLittleMana=0//Once this value is passed, the buff deactivates.
	var/AlwaysOn=0//If the object exists in the target, its always on.  When it gets turned off, delete it
	var/doNotDelete = 0
	var/ActiveBuffLock=0//Prevents active buffs from being used
	var/SpecialBuffLock=0//Prevents special buffs from being used
	var/TensionLock=0//TODO: rename to tension lock

// New things
	var/ExhaustedMessage = FALSE
	var/DesperateMessage = FALSE
	var/DeleteOnRemove = FALSE
	var/KillerInstinct = 0 // Increase Str/For Mult as missing health goes up
	var/Deicide = 0 // Do more damage vs gods, goes up to 10
	var/Blubber = 0 // reverse knockbacks at 25% of total per tick
	var/DemonicDurability
	var/BladeFisting = 0 // Punch with sword
	var/LikeWater = 0 // give flow if they have more off than your def, and instinct if they have more def than your off
	var/list/passives = list()
	var/list/current_passives
	var/FakeTextColor
	var/ProfileFake
	var/characterInformation/OldInformation
	var/characterInformation/FakeInformation
	var/FakeInformationEnabled

	skillDescription()
		..()
		if(passives.len>0)
			description += "Passives:\n"
			for(var/i in passives)
				description += "[i] - [passives[i]]\n"
	proc
		Trigger(var/mob/User, Override=0)
			if(!User.BuffOn(src))
				adjust(User) // why didnt we just add this here
			if(!Override && User.passive_handler.Get("Silenced"))
				User << "You can't use [src] you are silenced!"
				return 0
			if(!Override && User.BuffingUp)
				return 0
			if(!Override)
				User.BuffingUp++
			if(Sealed && !Override)
				User << "This spell is sealed!"
				return 0
			if(src.DashCountLimit)
				src.DashCount=0
			var/returnClause
			returnClause = User.UseBuff(src, Override)
			User.BuffingUp=0
			if(!src.BuffName)
				src.BuffName="[src.name]"
			return returnClause
	ActiveBuffs
		ActiveSlot=1
		passives = list()
//THE ONE, THE ONLY!
		Ki_Control
			BuffName="Ki Control"
			KiControl=1
			passives = list("KiControl" = 1)
			UnrestrictedBuff=1//for the poor monkey men
			Cooldown=1
			EnergyThreshold=10
			EnergyLeak=1
			KKTWave=3
			KKTWaveSize=0.5
			OverlayTransLock=0//AuraLock=1, skip everything custom.
			ActiveMessage="augments their body with excess energy!"
			OffMessage="loosens the control on their ki..."
			var/selectedPassive = "None"
			var/selectedStats = list()
			proc/init(mob/p)
				if(altered) return
				if(selectedPassive == "None")
					p.PoweredFormSetup()
				passives = list("[selectedPassive]" = 1, "KiControl" = 1, "EnergyLeak" = 1)
				vars["[selectedStats[1]]Mult"] = 1.15
				vars["[selectedStats[2]]Mult"] = 1.1
				vars["[selectedStats[3]]Mult"] = 1.05
			Trigger(var/mob/User, Override=0)
				init(User)
				..()



			verb/Customize_Powered_State()
				set category="Utility"
				var/list/Options=list("Cancel", "Overlay", "Top Overlay", "Aura", "Hair", "Text")
				Options.Add("Base")
				var/Option=input("What aspect do you wish to customize?", "Ki Control Customize") in Options
				if(Option=="Cancel")
					return
				else
					switch(Option)
						if("Overlay")
							src.IconLock=input(usr, "What icon do you want to display when activating Ki Control?", "Ki Control") as icon|null
							src.LockX=input(usr, "X offset?", "Ki Control") as num|null
							src.LockY=input(usr, "Y offset?", "Ki Control") as num|null
							var/Under=alert(usr, "Should this icon be displayed under the base rather than as an overlay?", "Ki Control", "No", "Yes")
							if(Under=="Yes")
								src.IconUnder=1
							else
								src.IconUnder=0
							var/Layer=alert(usr, "Should this icon force a relayer to appear under Top Overlays?", "Ki Control", "Yes", "No")
							if(Layer=="Yes")
								src.IconRelayer=1
							else
								src.IconRelayer=0
						if("Top Overlay")
							src.TopOverlayLock=input(usr, "What Top Overlay do you want to display when using Ki Control?", "Ki Control") as icon|null
							src.TopOverlayX=input(usr, "X offset?", "Ki Control") as num|null
							src.TopOverlayY=input(usr, "Y offset?", "Ki Control") as num|null
						if("Aura")
							var/Lock=alert(usr, "Should the aura displayed be your standard one?", "Ki Control", "No", "Yes")
							if(Lock=="Yes")
								src.AuraLock=1
							else
								src.AuraLock=input(usr, "What aura should be forced to display when using Ki Control?", "Ki Control") as icon|null
								src.AuraX=input(usr, "X offset?", "Ki Control") as num|null
								src.AuraY=input(usr, "Y offset?", "Ki Control") as num|null
							var/Under=alert(usr, "Should this aura be displayed under the base rather than as an overlay?", "Ki Control", "No", "Yes")
							if(Under=="Yes")
								usr.AuraLockedUnder=1
							else
								usr.AuraLockedUnder=0
						if("Hair")
							src.HairLock=input(usr, "What hair should be forced to display when using Ki Control?", "Ki Control") as icon|null
							src.HairX=input(usr, "X offset?", "Ki Control") as num|null
							src.HairY=input(usr, "Y offset?", "Ki Control") as num|null
						if("Text")
							src.ActiveMessage=input(usr, "What text do you want to display when entering Ki Control? This will always have your character name at the start.", "Ki Control") as text
							src.OffMessage=input(usr, "What text do you want to display when exiting Ki Control? This will always have your character name at the start.", "Ki Control") as text
							src.TextColor=input(usr, "What text color do you want to display? Default is #0080FF.", "Ki Control") as text|null
						if("Base")
							var/HulkOut=alert(usr, "Should the powered up state alter your base?", "Ki Control", "No", "Yes")
							if(HulkOut=="No")
								src.IconReplace=0
							else
								if(usr.isRace(MAKYO))
									var/Lock=alert(usr, "Should the powered up state use your default expanded state?", "Ki Control", "No", "Yes")
									if(Lock=="Yes")
										src.icon=usr.ExpandBase
										src.IconReplace=1
										return
								src.icon=input(usr, "What icon should replace your base when using Ki Control?", "Ki Control") as icon|null
								src.pixel_x=input(usr, "X offset?", "Ki Control") as num|null
								src.pixel_y=input(usr, "Y offset?", "Ki Control") as num|null
								src.IconReplace=1
		Gear
			PULock=1
			Mechanized=1
			Power_Armor
				PowerMult=1.2
				StrMult=1.1
				ForMult=1.1
				EndMult=1.2
				SpdMult=0.5
				DefMult=0.8
				passives = list("Mechanized" = 1, "PULock" = 1)
				MakesArmor=1
				ArmorClass="Heavy"
				ArmorIcon='BLANK.dmi'
				HairLock='BLANK.dmi'
				ActiveMessage="powers up their prototype steel exoskeleton!"
				OffMessage="burns out the power cell on their steel armor..."
				verb/Powered_Exoskeleton()
					set category="Skills"
					if(!usr.BuffOn(src) && !altered)
						if(usr.Saga && usr.Saga != "King of Braves")
							usr<< "Your specialization doesn't allow for this!"
							return
						if(usr.PilotingProwess>0)
							StrMult = 1.1 + (usr.PilotingProwess*0.015)
							ForMult = 1.1 + (usr.PilotingProwess*0.015)
							EndMult = 1.2 + (usr.PilotingProwess*0.015)
							SpdMult = 0.5 + (usr.PilotingProwess*0.03)
						else
							usr<<"You haven't the faintest clue on how to pilot this thing!!"
							StrMult=1.1
							ForMult=1
							EndMult=1.1
							SpdMult=0.5
							OffMult=0.5
							DefMult=0.8
					src.Trigger(usr)
			Power_Armor_Burst
				PowerMult=1.3
				StrMult=1.2
				ForMult=1.3
				OffMult=1.2
				RecovMult=0.5
				MakesArmor=1
				passives = list("Mechanized" = 1, "PULock" = 1, "ManaLeak" = 0.25, "SpiritHand" = 1)
				ArmorAscension = 1
				ArmorClass="Heavy"
				ArmorIcon='BLANK.dmi'
				HairLock='BLANK.dmi'
				ActiveMessage="powers up their high firepower armor!"
				OffMessage="burns out the power cell on their burst armor..."
				verb/Power_Armor_Burst()
					set category="Skills"
					if(!usr.BuffOn(src) && !altered)
						if(usr.Saga && usr.Saga != "King of Braves")
							usr<< "Your specialization doesn't allow for this!"
							return
						if(usr.PilotingProwess>0)
							StrMult = 1.2 + (usr.PilotingProwess*0.025)
							ForMult = 1.3 + (usr.PilotingProwess*0.025)
							OffMult = 1.2 + (usr.PilotingProwess*0.025)
							RecovMult = 0.5 + (usr.PilotingProwess*0.05)
						else
							usr<<"You haven't the faintest clue on how to pilot this thing!!"
							StrMult=1.1
							ForMult=1.1
							EndMult=1.1
							SpdMult=0.5
							DefMult=0.8
					src.Trigger(usr)
			Power_Armor_Burly
				PowerMult=1.3
				StrMult=1.2
				EndMult=1.4
				DefMult=0.7
				RecovMult=0.5
				MakesArmor=1
				passives = list("Mechanized" = 1, "PULock" = 1)
				ArmorAscension = 1
				ArmorClass="Heavy"
				ArmorIcon='BLANK.dmi'
				HairLock='BLANK.dmi'
				ActiveMessage="powers up their bulky armor!"
				OffMessage="burns out the power cell on their bulwark..."
				verb/Power_Armor_Burly()
					set category="Skills"
					if(!usr.BuffOn(src) && !altered)
						if(usr.Saga && usr.Saga != "King of Braves")
							usr<< "Your specialization doesn't allow for this!"
							return
						if(usr.PilotingProwess>0)
							StrMult = 1.3 + (usr.PilotingProwess*0.025)
							EndMult = 1.3 + (usr.PilotingProwess*0.025)
							OffMult = 1.2 + (usr.PilotingProwess*0.025)
							DefMult = 0.7 + (usr.PilotingProwess*0.025)
							SpdMult = 0.7 + (usr.PilotingProwess*0.025)
							RecovMult = 0.5 + (usr.PilotingProwess*0.05)
						else
							usr<<"You haven't the faintest clue on how to pilot this thing!!"
							StrMult=1.1
							ForMult=1.1
							EndMult=1.1
							SpdMult=0.5
							DefMult=0.8
					src.Trigger(usr)
			Power_Armor_Blitz
				PowerMult=1.3
				EndMult=0.7
				DefMult=1.2
				OffMult=1.2
				SpdMult=1.4
				StrMult = 1.1
				RecovMult=0.5
				MakesArmor=1
				passives = list("Mechanized" = 1, "PULock" = 1, "BlurringStrikes" = 1)
				ArmorAscension = 1
				ArmorClass="Heavy"
				ArmorIcon='BLANK.dmi'
				HairLock='BLANK.dmi'
				ActiveMessage="powers up their speedy armor!"
				OffMessage="burns out the power cell on their blitz armor..."
				verb/Power_Armor_Blitz()
					set category="Skills"
					if(!usr.BuffOn(src) && !altered)
						if(usr.Saga && usr.Saga != "King of Braves")
							usr<< "Your specialization doesn't allow for this!"
							return
						if(usr.PilotingProwess>0)
							OffMult = 1.2 + (usr.PilotingProwess*0.025)
							EndMult = 0.7 + (usr.PilotingProwess*0.025)
							SpdMult = 1.4 + (usr.PilotingProwess*0.025)
							DefMult = 1.2 + (usr.PilotingProwess*0.025)
							StrMult = 1.1 + (usr.PilotingProwess*0.025)
							RecovMult = 0.5 + (usr.PilotingProwess*0.05)
						else
							usr<<"You haven't the faintest clue on how to pilot this thing!!"
							StrMult=1.1
							ForMult=1.1
							EndMult=1.1
							SpdMult=0.5
							DefMult=0.8
					src.Trigger(usr)


			Mobile_Suit
				ManaHeal=100
				InstantAffect=1
				PowerReplacement=10
				passives = list("Piloting" = 1, "SpecialBuffLock" = 1,"GiantForm" = 1, "DebuffResistance" = 2, "VenomImmune" = 1, "SweepingStrike" = 1, "NoDodge" = 1)
				Piloting=1
				FusionPowered=1
				NoAnger=1
				SpecialBuffLock=1
				PowerMult=1.5
				BuffTechniques=list("/obj/Skills/Buffs/SlotlessBuffs/WeaponSystems/Skim", \
				"/obj/Skills/Projectile/Gear/Installed/Installed_Plasma_Gatling", \
				"/obj/Skills/Projectile/Gear/Installed/Installed_Missile_Launcher", \
				"/obj/Skills/Buffs/SlotlessBuffs/WeaponSystems/Beam_Saber")
				ActiveMessage="powers up their giant mobile suit!"
				OffMessage="burns out the fusion cell in their mecha..."
				proc/init(obj/Items/Gear/Mobile_Suit/mecha, mob/player)
					PowerMult = 1.25 + (mecha.Level * 0.25) + (player.AngerMax / (8 - mecha.Level))
					if(player.Saga == "King of Braves")
						passives["SpecialBuffLock"] = 0
						SpecialBuffLock = 0
				Trigger(mob/User, Override)
					var/obj/Items/Gear/Mobile_Suit/mech = User.findMecha()
					init(mech, User)
					..()
				Speed
					BuffName = "Mobile Suit"
					BuffTechniques=list("/obj/Skills/Buffs/SlotlessBuffs/WeaponSystems/Skim", \
				"/obj/Skills/Projectile/Gear/Installed/Installed_Plasma_Gatling", \
				"/obj/Skills/Projectile/Gear/Installed/Installed_Missile_Launcher", \
				"/obj/Skills/Buffs/SlotlessBuffs/WeaponSystems/Beam_Saber")
					init(obj/Items/Gear/Mobile_Suit/mecha, mob/player)
						passives = list("Piloting" = 1, "SpecialBuffLock" = 1,"GiantForm" = 1,\
									 "DebuffResistance" = 2, "VenomImmune" = 1, "SweepingStrike" = 1, \
									 "Godspeed" = mecha.Level, "SuperDash" = 1, "Pursuer" = mecha.Level, "Flicker" = mecha.Level, \
									 "Flow" = (mecha.Level * 0.25) + 1, "NoDodge" = 1)
						if(player.PilotingProwess >= 7)
							passives["NoDodge"] = 0
						Afterimages = 1
						..()
				Tank
					BuffName = "Mobile Suit"
					BuffTechniques=list("/obj/Skills/Buffs/SlotlessBuffs/WeaponSystems/Skim", \
				"/obj/Skills/Projectile/Gear/Installed/Installed_Plasma_Gatling", \
				"/obj/Skills/Projectile/Gear/Installed/Installed_Missile_Launcher", \
				"/obj/Skills/Buffs/SlotlessBuffs/WeaponSystems/Beam_Saber")
					init(obj/Items/Gear/Mobile_Suit/mecha, mob/player)
						passives = list("Piloting" = 1,"SpecialBuffLock" = 1,"GiantForm" = 1, "DebuffResistance" = 2, "VenomImmune" = 1, "SweepingStrike" = 1, \
						"Juggernaut" = mecha.Level, "Reversal" = 0.5, "BlockChance" = mecha.Level*3, "CriticalBlock" = mecha.Level*0.5, "NoDodge" = 1)
						if(player.PilotingProwess >= 7)
							passives["NoDodge"] = 0
						VaizardHealth = mecha.Level * 2
						..()
				Assault
					BuffName = "Mobile Suit"
					BuffTechniques=list("/obj/Skills/Buffs/SlotlessBuffs/WeaponSystems/Skim", \
				"/obj/Skills/Projectile/Gear/Installed/Installed_Plasma_Gatling", \
				"/obj/Skills/Projectile/Gear/Installed/Installed_Missile_Launcher", \
				"/obj/Skills/Buffs/SlotlessBuffs/WeaponSystems/Beam_Saber")
					init(obj/Items/Gear/Mobile_Suit/mecha, mob/player)
						passives = list("Piloting" = 1,"SpecialBuffLock" = 1,"GiantForm" = 1, "DebuffResistance" = 2, "VenomImmune" = 1, "SweepingStrike" = 1, \
						"CriticalChance" = mecha.Level*7, "CriticalDamage" = mecha.Level*0.15, "Steady" = mecha.Level, "Duelist" = mecha.Level, "NoDodge" = 1)
						if(player.PilotingProwess >= 7)
							passives["NoDodge"] = 0
						..()





//Tier S
		Eight_Gates
			PULock=1
			KiControl=1
			NoSword=1
			InstantAffect=1
			Flicker=0
			SuperDash=0
			AuraLock='BLANK.dmi'
			IconLock='BLANK.dmi'
			IconLockBlend=2
			IconUnder=1
			IconApart=1
			LockX=0
			LockY=0
			FatigueThreshold=98
			EnergyThreshold=1
			TimerLimit=1200
			BuffName="Eight Gates"
			OffMessage="stops Cultivating..."
			var/taxReduction = 0
			var/ignoreWounded = FALSE
			HandleBuffDeactivation(mob/source)
				Stop_Cultivation()
				source.GatesActive = 0
			proc/setUpGateVars(mob/p, num)

				if(altered) return
				SuperDash=0
				FatigueHeal=0
				IconLock=null
				AuraLock='BLANK.dmi'
				KenWave=0
				var/puBoon = num >= 4 ? TRUE : FALSE
				FatigueHeal = num * 15
				EnergyHeal = num * 20
				PUSpike = 50 + (glob.GATES_PUSPIKE_BASE * num) // changed to 150%(pu) + 8xgate; so power wall doesnt jackhammer a asshole.
				FatigueLeak = num+1 / p.SagaLevel
				BleedHit = p.SagaLevel-1
				passives = list("PUSpike" = PUSpike, "KiControl" = 1, "PULock" = 1,\
				"DemonicDurability" = clamp(num*0.2,0.25,4), "HeavyHitter" = num / 8, \
				"Flicker" = round(clamp(num/2,1,8)), "Godspeed" = round(clamp(num/2,1,8)),\
				"SuperDash" = puBoon ? 1 : 0, "Neo" = num)
				StrMult = 1.15 + num / glob.GATES_STAT_MULT_DIVISOR
				EndMult = 1.1 + num / glob.GATES_STAT_MULT_DIVISOR
				SpdMult = 1.05 + num / glob.GATES_STAT_MULT_DIVISOR
				KenWave=clamp(num / 2, 1, 4)


				if(num >= 5)
					passives["Kaioken"] = 1 // gates should die what the freak ?

				if(num == 7)
					passives["PUSpike"] = 300
					IconLock='FlameGlowHades.dmi'
					LockX=-16
					LockY=-4
					KenWave=4

			proc/handleGates(mob/p, increment)
				var/prev_gates = p.GatesActive
				if(increment)
					// handle going up a gate here
					OffMessage=0
					if(p.GatesActive >= min(8,p.SagaLevel+2))
						p << "You can't unlock the next gate."
						return
					if(p.BuffOn(src))
						src.Trigger(p, 1, 1)
						sleep(1)
						Cooldown=0
						cooldown_remaining=0
						Using=0
					p.GatesActive = prev_gates + 1
					GatesLevel = p.GatesActive
					switch(GatesLevel)
						if(1)
							ActiveMessage = "unleashes the First Gate!"
						if(2)
							ActiveMessage = "unleashes the Second Gate!"
						if(3)
							ActiveMessage = "unleashes the Third Gate!"
						if(4)
							ActiveMessage = "unleashes the Fourth Gate!"
						if(5)
							ActiveMessage = "unleashes the Fifth Gate!"
						if(6)
							ActiveMessage = "unleashes the Sixth Gate!"
						if(7)
							ActiveMessage = "unleashes the Seventh Gate!"
						if(8)
							ActiveMessage = "unleashes the Eighth Gate!"
					setUpGateVars(p, p.GatesActive)
					src.Trigger(p, 1)
				else
					// handle going down a gate here
					OffMessage="shuts their Gates..."
					setCooldown(p.GatesActive)
					shutOffEffects(p, p.GatesActive)
					p.GatesActive = 0
					GatesLevel = 0
					src.Trigger(p, 1)
/*
			Trigger(mob/User, Override, dntWound)
				..()
				if(User.BuffOn(src))
					setCooldown(User.GatesActive)
					shutOffEffects(User, User.GatesActive, dntWound)
					User.GatesActive = 0
					GatesLevel = 0*/

			verb/Check_Power_Nerf_Timer()
				set hidden = 1
				usr << "Total: [usr.GatesNerfPerc]%, Recovers in [time2text(usr.GatesNerf, "hh:mm:ss", "est")]"

			proc/shutOffEffects(mob/p, level, dontWound = FALSE)
				p.GatesActive=0

				var/tax = clamp(0.05 * level, 0.05, 1)
				if(taxReduction)
					tax = clamp(0.05 - taxReduction * level, 0.005, 1)

				if(dontWound)
					return
				if(!ignoreWounded)
					if(p.TotalInjury>=35 && p.BPPoison>=0.9)
						var/Time=RawHours(2)
						Time/=p.GetRecov()
						if(Time > p.BPPoisonTimer)
							p.BPPoisonTimer=Time
						p.BPPoison=0.9
						p.OMessage(10, "[p] has been lightly wounded!", "[p]([p.key]) has over 35% injury.")
					else if(p.TotalInjury>=60 && p.BPPoison>=0.7)
						var/Time=RawHours(4)
						Time/=p.GetRecov()
						if(Time > p.BPPoisonTimer)
							p.BPPoisonTimer=Time
						p.BPPoison=0.7
						p.OMessage(10, "[p] has been heavily wounded!", "[p]([p.key]) has over 60% injury.")
					else if(p.TotalInjury>=75)
						var/Time=RawHours(8)
						Time/=p.GetRecov()
						if(Time > p.BPPoisonTimer)
							p.BPPoisonTimer=Time
						p.BPPoison=0.5
						p.OMessage(10, "[p] has been grieviously wounded!", "[p]([p.key]) has over 80% injury.")


				if(level == 7)
					tax = 0.5
				if(level == 8)
					tax  = 0.99
				switch(level)
					if(1)
						p.GatesNerfPerc=20
						p.GatesNerf=RawMinutes(45)
					if(2)
						p.GatesNerfPerc=25
						p.GatesNerf=RawMinutes(60)
					if(3)
						p.GatesNerfPerc=30
						p.GatesNerf=RawHours(2)
					if(4)
						p.GatesNerfPerc=35
						p.GatesNerf=RawHours(3)
					if(5)
						p.GatesNerfPerc=40
						p.GatesNerf=RawHours(4)
					if(6)
						p.GatesNerfPerc=45
						p.GatesNerf=RawHours(5)
					if(7)
						p.GatesNerfPerc=50
						p.GatesNerf=RawHours(6)
				p.AddStrTax(tax)
				p.AddEndTax(tax)
				p.AddSpdTax(tax)



			verb/Cultivate()
				set category = "Skills"
				if(usr.GatesActive > 8 || usr.GatesActive > min(8,usr.SagaLevel+1))
					usr<<"You can't do that!!"
					return
				handleGates(usr, TRUE)

			verb/Stop_Cultivation()
				set category = "Skills"
				if(!usr)
					usr = src.loc
				if(usr.BuffOn(src))
					handleGates(usr, FALSE)
				else if(!usr.GatesActive)
					usr << "You can't close the Gates because they aren't open!!"
				else if(usr.GatesActive)
					usr.GatesActive=0


			proc/checkUnlocked(mob/p, num)
				if(p.SagaLevel + 2 < num)
					p << "You haven't unlocked this gate yet!"
					return 0
				else
					return 1

			proc/setCooldown(activeGate)
				if(activeGate < 5)
					src.Cooldown = 60
				else if(activeGate < 7)
					src.Cooldown = 300
				else
					src.Cooldown = 1500

		Weapon_Soul
			PULock=1
			NeedsSword=1
			PowerMult=1.5
			var/redacted = FALSE
			BuffName="Soul Resonance"
			var/multsSet = FALSE
			verb/Legendary_Weapon()
				set hidden=1
				if(!usr.BuffOn(src))
					src.SwordIcon=null
					if(!multsSet)
						var/obj/Skills/Buffs/ActiveBuffs/Ki_Control/ki = usr.FindSkill(/obj/Skills/Buffs/ActiveBuffs/Ki_Control)
						vars["[ki.selectedStats[1]]Mult"] = 1.15
						vars["[ki.selectedStats[2]]Mult"] = 1.1
						vars["[ki.selectedStats[3]]Mult"] = 1.05
						multsSet = TRUE
					switch(usr.BoundLegend)
						if("Redacted")
							passives = list("Instinct" = 1, "Flow" = 1, "PULock" = 1)
							src.SwordName=null
							src.SwordIcon=null
							src.ActiveMessage="calls forth the true form of █████████████, the ███████ of ████████!"
							src.OffMessage="conceals █████████████.."
						if("Green Dragon Crescent Blade")
							passives = list("Duelist" = max(1,usr.SagaLevel/2), "Hardening" = usr.SagaLevel/2, "Mythical" = usr.SagaLevel*0.16, "PULock" = 1)
							src.ActiveMessage="calls forth the true form of the Green Dragon Crescent Blade, the Spear of War!"
							src.OffMessage="restrains Guan Yu's fury..."

						if("Ryui Jingu Bang")
							passives = list("SpiritPower" = usr.SagaLevel*0.25, "Duelist" = usr.SagaLevel*0.25, "Extend" = max(1,usr.SagaLevel/2), "PULock" = 1)
							if(!redacted)
								src.ActiveMessage="calls forth the true form of Ryui Jingu Bang, the Pole of the Monkey King!"
								src.OffMessage="shrinks Ryui Jingu Bang back down..."
								SwordName = null
								SwordIcon = null
							else
								src.SwordName=null
								src.SwordIcon=null
								src.ActiveMessage="calls forth the true form of █████████████, the ███████ of ████████!"
								src.OffMessage="conceals █████████████.."

						if("Caledfwlch")
							var/light = TRUE
							if(usr.EquippedSword())
								if(istype(usr.EquippedSword(),/obj/Items/Sword/Medium/Legendary/WeaponSoul/Sword_of_Glory))
									light = usr.EquippedSword():caledLight
							if(light)
								passives = list("HolyMod" = usr.SagaLevel, "SpiritSword" = 0.25 * usr.SagaLevel, "LikeWater" = max(1,usr.SagaLevel/2), "PULock" = 1)
								if(!redacted)
									src.SwordName="Caledfwlch"
									src.ActiveMessage="calls forth the true form of Caledfwlch, the Sword of Glory!"
									src.OffMessage="conceals Caledfwlch's glory..."
								else
									src.SwordName=null
									src.SwordIcon=null
									src.ActiveMessage="calls forth the true form of █████████████, the ███████ of ████████!"
									src.OffMessage="conceals █████████████.."
							else
								passives = list("AbyssMod" = usr.SagaLevel, "SpiritSword" = 0.25 * usr.SagaLevel, "Instinct" = max(1, usr.SagaLevel/3), "Pursuer" = max(1,usr.SagaLevel/2),"PULock" = 1)
								if(!redacted)
									src.SwordName="Caledfwlch"
									src.ActiveMessage="calls forth the true form of Caledfwlch Morgan, the Shadow Sword of Glory!"
									src.OffMessage="conceals Caledfwlch's glory..."
								else
									src.SwordName=null
									src.SwordIcon=null
									src.ActiveMessage="calls forth the true form of █████████████, the ███████ of ████████!"
									src.OffMessage="conceals █████████████.."
						if("Kusanagi")
							passives = list("HolyMod" = usr.SagaLevel,"ManaGeneration" = usr.SagaLevel*5, "PULock" = 1)
							if(!redacted)
								src.SwordName="Kusanagi"
								src.ActiveMessage="calls forth the true form of Kusanagi, the Sword of Faith!"
								src.OffMessage="seals Kusanagi's faith..."
							else
								src.SwordName=null
								src.SwordIcon=null
								src.ActiveMessage="calls forth the true form of █████████████, the ███████ of ████████!"
								src.OffMessage="conceals █████████████.."
						if("Durendal")
							passives = list("HolyMod" = usr.SagaLevel, "LifeGeneration" = usr.SagaLevel/3, "PULock" = 1)
							if(!redacted)
								src.SwordName="Durendal"
								src.ActiveMessage="calls forth the true form of Durendal, the Sword of Hope!"
								src.OffMessage="hides the hope of Durendal..."
							else
								src.SwordName=null
								src.SwordIcon=null
								src.ActiveMessage="calls forth the true form of █████████████, the ███████ of ████████!"
								src.OffMessage="conceals █████████████.."
						if("Dainsleif")
							HealthDrain = 0
							passives = list("SlayerMod" = usr.SagaLevel/2, "FavoredPrey" = "Races", "MortalStrike" = 0.5, "AbyssMod" = usr.SagaLevel/2, "LifeSteal" = usr.SagaLevel*5, "Curse" = 1, "PULock" = 1)

							if(!redacted)
								src.SwordName="Dainsleif"
								src.ActiveMessage="calls forth the true form of Dainsleif, the Blade of Ruin!"
								src.OffMessage="dissolves Dainsleif's ruinous power..."
							else
								src.SwordName=null
								src.SwordIcon=null
								src.ActiveMessage="calls forth the true form of █████████████, the ███████ of ████████!"
								src.OffMessage="conceals █████████████.."
						if("Muramasa")
							passives = list("AbyssMod" = usr.SagaLevel, "EnergySteal" = usr.SagaLevel*7.5, "WeaponBreaker" = max(2,usr.SagaLevel/1.5), "PULock" = 1)
							if(!redacted)
								src.SwordName="Muramasa"
								src.ActiveMessage="calls forth the true form of Muramasa, the Bane of Blades!"
								src.OffMessage="casts Muramasa back into the darkness..."
							else
								src.SwordName=null
								src.SwordIcon=null
								src.ActiveMessage="calls forth the true form of █████████████, the ███████ of ████████!"
								src.OffMessage="conceals █████████████.."
						if("Masamune")
							passives = list("HolyMod"=usr.SagaLevel*2,"Purity"=1,"Steady"=usr.SagaLevel, "PULock" = 1)
							if(!redacted)
								src.SwordName="Masamune"
								src.ActiveMessage="calls forth the true form of Masamune, the Sword of Purity!"
								src.OffMessage="relaxes the light of Masamune..."
							else
								src.SwordName=null
								src.SwordIcon=null
								src.ActiveMessage="calls forth the true form of █████████████, the ███████ of ████████!"
								src.OffMessage="conceals █████████████.."
						if("Soul Calibur")
							var/light = TRUE
							if(usr.EquippedSword())
								if(istype(usr.EquippedSword(),/obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Order))
									light = usr.EquippedSword():caliburLight
							if(light)
								passives = list("HolyMod"=usr.SagaLevel,"LifeGeneration"=usr.SagaLevel/8,"Steady"=usr.SagaLevel, "PULock" = 1)
								if(!redacted)
									src.ActiveMessage="calls forth the true form of Soul Calibur, the Purified Blade of Order!"
									src.OffMessage="restricts Soul Calibur's order..."
								else
									src.SwordName=null
									src.SwordIcon=null
									src.ActiveMessage="calls forth the true form of █████████████, the ███████ of ████████!"
									src.OffMessage="conceals █████████████.."
							else
								passives = list("AbyssMod"=usr.SagaLevel,"LifeGeneration"=usr.SagaLevel/8,"Steady"=usr.SagaLevel, "PULock" = 1)
								if(!redacted)
									src.ActiveMessage="calls forth the true form of Soul Calibur, the Crystal Blade of Order!"
									src.OffMessage="restricts Soul Calibur's order..."
								else
									src.SwordName=null
									src.SwordIcon=null
									src.ActiveMessage="calls forth the true form of █████████████, the ███████ of ████████!"
									src.OffMessage="conceals █████████████.."
						if("Soul Edge")
							passives = list("AbyssMod" = usr.SagaLevel, "Steady" = usr.SagaLevel, "Extend" = 1, "BleedHit" = 1, "PULock" = 1)
							if(!redacted)
								src.SwordName="Soul Edge"
								src.ActiveMessage="calls forth the true form of Soul Edge, the Blade of Chaos!"
								src.OffMessage="releases Soul Edge's chaos..."
							else
								src.SwordName=null
								src.SwordIcon=null
								src.ActiveMessage="calls forth the true form of █████████████, the ███████ of ████████!"
								src.OffMessage="conceals █████████████.."
						if("Moonlight Greatsword")
							src.EndMult=1.3
							src.ForMult=2.25
							src.OffMult=1.5
							src.DefMult=1.3
							passives = list("SpiritFlow" = 2, "SpiritStrike" = 2, "SoulFire" = 2, "DrainlessMana" = 1, "CyberStigma" = 2)
							src.SpiritFlow=2
							src.SpiritStrike=2
							src.ManaSeal=2
							src.DrainlessMana=1
							src.CyberStigma=2
							src.SwordName="Moonlight Greatsword"
							src.ActiveMessage="conjures forth the Moonlight Greatsword, basked in otherworldly lunar radiance..."
					if(!PULock)
						passives["PULock"] = 0
				src.Trigger(usr)
			verb/Weapon_Soul()
				set category="Skills"
				Legendary_Weapon()

		Persona

		Keyblade
			ActiveMessage="draws forth a weapon shaped like a key from a flurry of light!"
			OffMessage="releases their Keyblade back to the light..."
			MakesSword=1
			FlashDraw=1
			MagicSword=1
			SwordClass="Wooden"
			SwordAscension=2
			SwordName="Keyblade"
			PULock=1
			PowerMult=1.5
			SwordX=-32
			SwordY=-32
			swordHasHistory=1
			passives = list("MagicSword" = 1)
			Cooldown=30
			verb/Summon_Keyblade()
				set category="Skills"
				if(!usr.BuffOn(src))
					passives = list()
					src.SwordClass=GetKeychainClass(usr.KeychainAttached)
					src.SwordElement=GetKeychainElement(usr.KeychainAttached)
					src.SwordIcon=GetKeychainIcon(usr.KeychainAttached)
					if(usr.KeychainAttached=="Way To Dawn")
						passives = list("PULock" = 1, "MagicSword" = 1, "SwordAscension" = 2, "HolyMod" = 3, "AbyssMod" = 3, "SpiritPower" = 0.25 )
						src.HolyMod=3
						src.AbyssMod=3
					else
						src.HolyMod=0
						src.AbyssMod=0
					if(usr.KeychainAttached=="Fenrir")
						passives = list("PULock" = 1, "MagicSword" = 1, "SwordAscension" = 2, "SlayerMod" = 1.5, "FavoredPrey" = "Races")
					else
						src.Steady=0
					if(usr.KeychainAttached=="Chaos Ripper")
						passives = list("PULock" = 1, "MagicSword" = 1, "SwordAscension" = 2, "Burning" = 3, "Scorching" = 3, "DarknessFlame" = 2)
						src.Burning=1
						src.Scorching=1
						src.DarknessFlame=1
					else
						src.Burning=0
						src.Scorching=0
						src.DarknessFlame=0
					if(usr.KeychainAttached=="No Name")
						passives = list("PULock" = 1, "MagicSword" = 1, "SwordAscension" = 2, "StealsStats" = 1)
						src.StealsStats=0
					else
						src.StealsStats=0
					switch(usr.KeybladeType)
						if("Sword")
							src.StrMult=1.2
							src.SpdMult=1.2
							src.OffMult=1.2
						if("Shield")
							src.EndMult=1.2
							src.DefMult=1.2
							src.StrMult=1.2
						if("Staff")
							src.ForMult=1.2
							src.OffMult=1.2
							src.DefMult=1.2
							// passives["ManaCapMult"] = 0.1 * usr.SagaLevel
							// passives["SpiritFlow"] = 0.15 * usr.SagaLevel
					passives["SpiritSword"] = 0.2 * usr.SagaLevel
					passives["PULock"] = 1
					passives["SwordDamage"] = GetKeychainDamage(usr.KeychainAttached)
					passives["SwordAccuracy"] = GetKeychainAccuracy(usr.KeychainAttached)
					passives["SwordDelay"] = GetKeychainDelay(usr.KeychainAttached)
				src.Trigger(usr)


	SpecialBuffs
		SpecialSlot=1
//Racial
		Giant_Form//for Warrior  Nameks instead!
			NeedsHealth=30
			TooMuchHealth=35
			StrMult = 1.2
			EndMult = 1.2
			DefMult = 0.5
			SpdMult = 0.5
			Enlarge=2
			EnergyThreshold = 1
			passives = list("GiantForm" = 1, "Sweeping Strikes" = 1, "NoDodge" = 1, "EnergyLeak" = 1)
			ActiveMessage="channels their regenerative abilities into a bout of monstrous growth!"
			OffMessage="shrinks to normal size..."
			Cooldown=0
			verb/Giant_Form()
				set category="Skills"
				src.Trigger(usr)

		Daimou_Form//for Demon Nameks!
			NeedsHealth=50
			TooMuchHealth=75
			StrMult=1.1
			ForMult=1.1
			EnergyThreshold = 1
			passives = list("Hellrisen" = 0.25, "Hellpower" = 0.1, "Flicker" = 1)
			ActiveMessage="unleashes the herectical power of the Demon clan!"
			OffMessage="discards the Demon clan's abominal power..."
			Cooldown=-1
			KenWave=2
			KenWaveIcon="LightningRed.dmi"
			adjust(mob/p)
				passives = list("HellRisen" = 0.25 * (p.AscensionsAcquired-1), "Godspeed" = p.AscensionsAcquired/2, "AfterImages" = 2, "Hellpower" = p.AscensionsAcquired/6, "Flicker" = round(p.AscensionsAcquired/2, 1), "Enrage" = p.AscensionsAcquired,  "EnergyLeak" = 1)
				StrMult = 1.15 + (p.Potential/250)
				ForMult = 1.1 + (p.Potential/250)
				EndMult = 1.1 + (p.Potential/250)
				DefMult=0.9

			verb/Daimou_Form()
				set category="Skills"
				src.Trigger(usr)

		OneHundredPercentPower
			BuffName="One Hundred Percent Power"
			UnrestrictedBuff=1
			NeedsTrans=3
			EndMult = 1.5
			SpdMult = 1.5
			AuraLock=1
			passives = list("Flicker" = 2, "Flow" = 2, "MovementMastery" = 1, "Pursuer" = 1, "AllOutPU" = 1, "PureReduction" = 3, "PureDamage" = -3, "FatigueLeak" = 2)
			Cooldown=600
			KKTWave=3
			KKTWaveSize=2
			ActiveMessage="erupts with world-shattering power!"
			OffMessage="releases their awesome power..."
		FifthForm
			SignatureTechnique=3
			BuffName="Fifth Form"
			UnrestrictedBuff=1
			NeedsTrans=3
			NeedsHealth=50
			EndMult=1.5
			DefMult=1.5
			BioArmor=50
			passives = list("Juggernaut" = 2, "AllOutPU" = 1)
			Juggernaut=2
			Enlarge=2
			AllOutPU=1
			Cooldown=600
			ActiveMessage="grows and transforms parts of their armor!"
			OffMessage="tires out..."
		Wrathful
			SignatureTechnique=3
			UnrestrictedBuff=1
			NeedsHealth=75
			StrMult=1.5
			SpdMult=1.5
			PowerReplacement=5
			AngerThreshold=2
			AutoAnger=1
			passives = list("GiantForm" = 1)
			GiantForm=1
			Enlarge=2
			KenWave=3
			KenWaveSize=4
			KenWaveIcon='KenShockwaveGold.dmi'
			IconLock='EyesSage.dmi'
			ActiveMessage="turns completely feral, their massive power running out of control!"
			OffMessage="tires out..."
			adjust(mob/p)
				PowerReplacement = DaysOfWipe()+5
				AngerMult = 2
				passives = list("AngerMult" = 2, "GiantForm" = 1, "PowerReplacement" = DaysOfWipe()+5)

			verb/Wrathful()
				set category="Skills"
				adjust(usr)
				src.Trigger(usr)

		SuperSaiyanGrade2
			SignatureTechnique=3
			UnrestrictedBuff=1
			NeedsSSJ=1
			EnergyExpenditure=1.5
			StrMult=1.2
			ForMult=1.2
			EndMult=1.2
			SpdMult=0.8
			DefMult=0.8
			AuraLock=1
			FlashChange=1
			KenWave=3
			KenWaveSize=0.5
			KenWaveIcon='KenShockwaveGold.dmi'
			ActiveMessage="bulks up greatly and erupts with power!"
			OffMessage="tires out..."
			verb/Super_Saiyan_Grade2()
				set category="Skills"
				if(usr.ExpandBase)
					IconReplace=1
					icon=usr.ExpandBase
				src.NeedsSSJ=usr.transUnlocked
				src.HairLock=usr.Hair_SSJ2
				src.Trigger(usr)
		SuperSaiyanGrade3
			SignatureTechnique=3
			UnrestrictedBuff=1
			NeedsSSJ=1
			EnergyExpenditure=2
			StrMult=1.2
			ForMult=1.2
			EndMult=1.5
			SpdMult=0.8
			OffMult=0.6
			DefMult=0.4
			IconLock='SS2Sparks.dmi'
			AuraLock=1
			FlashChange=1
			ProportionShift=matrix(1.2, 0, 0, 0, 1, 0)
			KenWave=5
			KenWaveSize=0.5
			KenWaveIcon='KenShockwaveGold.dmi'
			ActiveMessage="bulks up enormously and explodes with power!"
			OffMessage="loses steam..."
			verb/Super_Saiyan_Grade3()
				set category="Skills"
				if(usr.ExpandBase)
					IconReplace=1
					icon=usr.ExpandBase
				src.NeedsSSJ=usr.transUnlocked
				src.HairLock=usr.Hair_SSJ3
				src.Trigger(usr)
		SuperSaiyanPerfected
			SignatureTechnique=3
			Mastery=-1
			UnrestrictedBuff=1
			StrMult=1.2
			ForMult=1.2
			EndMult=1.3
			SpdMult=1.3
			MovementMastery=8
			Intimidation=2
			passives = list("MovementMastery" = 8, "PureDamage" = 2, "PureReduction" = 2, "Flicker" = 2)
			PUSpeedModifier=2
			PureDamage=2
			PureReduction=2
			Flicker=2
			AuraLock='SSJ2Aura.dmi'
			AuraX=-32
			FlashChange=1
			KenWave=5
			KenWaveSize=1
			KenWaveIcon='KenShockwaveGold.dmi'
			ActiveMessage="prepares to display immense, mastered power!"
			OffMessage="releases their perfected form..."
			verb/Super_Saiyan_Perfected()
				set category="Skills"
				if(!usr.BuffOn(src))
					src.NeedsSSJ=min(usr.transActive(),src.Mastery)
				src.Trigger(usr)

		LegendarySuperSaiyan
			SignatureTechnique=3
			Transform="Force"
			UnrestrictedBuff=1
			passives = list("PureReduction" = 5, "GiantForm" = 1)
			KenWave=5
			KenWaveSize=5
			KenWaveIcon='KenShockwaveLegend.dmi'
			Enlarge=2
			AuraLock='Amazing LSSj Aura.dmi'
			AuraX=-32
			TextColor=rgb(255, 231, 108)
			ActiveMessage="roars and bulks up enormously as their power shatters reason!"
			OffMessage="releases their legendary power..."
			adjust(mob/p)
				passives = list("PureReduction" = p.Potential / 25, "GiantForm" = 1, "LifeGeneration" = p.Potential / 100)
				PowerMult = 1.2 + p.Potential / 200
				Intimidation = 2 + p.Potential / 200
				StrMult = 1.2 + p.Potential / 200
				ForMult = 1.2 + p.Potential / 200
				EndMult = 1.3 + p.Potential / 200
				SpdMult = 1.1 + p.Potential / 200

			verb/Legendary_Super_Saiyan()
				set category="Skills"
				HairLock=usr.Hair_SSJ2
				if(usr.ExpandBase)
					IconReplace=1
					icon=usr.ExpandBase
				adjust(usr)
				src.Trigger(usr)

		Kaioken
			SignatureTechnique=3
			UnrestrictedBuff=1
			Kaioken=1
			EnergyMult=2
			IconLock='Kaioken.dmi'
			LockX=-32
			LockY=0
			IconApart=1
			IconTint=list(0.8,0,0, 0.2,0.55,0.05, 0.2,0.02,0.58, 0,0,0)
			TextColor=rgb(204, 0, 0)
			ActiveMessage="erupts with immense intensity!!"
			AllOutPU=1
			verb/Kaioken()
				set category="Skills"
				if(!usr.BuffOn(src))
					if(usr.ActiveBuff)
						if(usr.ActiveBuff.PULock==1)
							usr << "Your energy is too focused to ignite the Kaioken."
							return
					usr << "Use Power Up to increase your Kaioken level."
					usr.passive_handler.Set("Kaioken", 1)
					for(var/obj/Skills/Buffs/ActiveBuffs/Ki_Control/KC in usr)
						if(!usr.BuffOn(KC))
							usr.UseBuff(KC)
				else
					usr.passive_handler.Set("Kaioken", 0)
				usr.Auraz("Remove")
				src.Trigger(usr)
		Rekkaken
			SignatureTechnique=3
			UnrestrictedBuff=1
			EnergyMult=2
			BurnAffected=2
			passives = list("BurningShot" = 1, "NoWhiff" = 1, "SuperDash" = 1, "Pursuer" = 1)
			IconLock='SSGAura.dmi'
			IconLockBlend=4
			LockX=-32
			LockY=-32
			ActiveMessage="ignites their life-force into a sacrifical pyre!!"
			OffMessage="burns out..."
			TextColor=rgb(255, 55, 0)
			adjust(mob/p)
				passives = list("BurningShot" = 1, "NoWhiff" = 1, "SuperDash" = 1 + p.Potential/30, "Pursuer" = 1 + p.Potential/30)
				OffMult = 1 + p.Potential/300
				StrMult = 1 + p.Potential/300
			verb/Burning_Shot()
				set name="Rekkaken"
				set category="Skills"
				adjust(usr)
				src.Trigger(usr)
		Kyoukaken//wet wet fist
			SignatureTechnique=3
			UnrestrictedBuff=1
			EnergyMult=2
			passives = list("MirrorStats" = 1, "Flow" = 1, "Instinct" = 1, "LikeWater" = 4, "FluidForm" = 1)
			ActiveMessage="reflects their opponent's power like a still lake!"
			OffMessage="returns to their own movements, unable to hold the simulacrum..."
			TextColor=rgb(65, 177, 218)
			adjust(mob/p)
				passives = list("MirrorStats" = 1, "Flow" = 1 + p.Potential/30, "Instinct" = 1 + p.Potential/30, "LikeWater" = 2 + p.Potential/30, "FluidForm" = 1)
				OffMult = 1 + p.Potential/300
				DefMult = 1 + p.Potential/300
			verb/Kyoukaken()
				set category="Skills"
				adjust(usr)
				src.Trigger(usr)
		Toppuken//wind wind fist
			SignatureTechnique=3
			EnergyMult=2
			UnrestrictedBuff=1
			passives = list("Erosion" = 0.5, "SoulFire" = 1, "SoulFire" = 1, "WeaponBreaker" = 2, "DeathField" = 5, "VoidField" = 5)
			SpdMult = 1.25
			DefMult = 1.25
			ActiveMessage="gently erodes everything..."
			OffMessage="recalls their eroding aura..."
			TextColor=rgb(224, 224, 235)
			adjust(mob/p)
				passives = list("Erosion" = 0.1 + p.Potential/150, "SoulFire" = 1 + p.Potential/30, "WeaponBreaker" = 2 + p.Potential/30, "DeathField" = 5 + p.Potential/10, "VoidField" = 5 + p.Potential/10)
				SpdMult = 1.25 + p.Potential/300
				DefMult = 1.25 + p.Potential/300
			verb/Toppuken()
				set category="Skills"
				adjust(usr)
				src.Trigger(usr)
//General
		Adrenaline_Rush
			SignatureTechnique=3
			NeedsHealth=50
			WoundThreshold=2
			FatigueThreshold=2
			FINISHINGMOVE=1
			OverClock=0.5
			EnergyMult=0.5
			StrMult=1.5
			EndMult=2
			SpdMult=1.5
			DefMult=0.5
			AdrenalBoost=1
			BleedHit=1
			FatigueLeak=1
			ManaGlow=rgb(0,255,0)
			ManaGlowSize=4
			IconTint=list(0.8,0,0, 0.2,0.55,0.05, 0.2,0.02,0.58, 0,0,0)
			LockX=-32
			LockY=-32
			TextColor=rgb(0,255,0)
			ActiveMessage="feeds their pain into the fires of determination!"
			OffMessage="runs out of gumption..."
			verb/Adrenaline_Rush()
				set category="Skills"
				src.Trigger(usr)
		Cursed
			passives = list("Maki" = 1, "Curse" = 1)
			Maki=1
			Curse=1
			PreRequisite=list("/obj/Skills/Utility/Summon_Absurdity")
			Jagan_Eye
				// SignatureTechnique=3
				FatigueThreshold=90
				PowerMult = 1.25
				StrMult=1.3
				ForMult=1.3
				EndMult=0.9
				IconLock='Third Eye.dmi'
				LockX=0
				LockY=0
				passives = list("Maki" = 1, "Curse" = 1, "Instinct" = 1, "Flow" = 1, "Godspeed" = 1, "CalmAnger"=1, "FatigueLeak" = 3)
				CalmAnger=1
				Instinct=1
				Flow=1
				Godspeed=1
				ActiveMessage="draws on the power of Demon World through their Jagan Eye!"
				OffMessage="shuts their Jagan Eye..."
				TextColor="#666666"
				proc/init(mob/p)
					if(altered) return
					var/secretLevel = p.secretDatum.currentTier
					PowerMult = 1.15 + (0.1 * secretLevel/2)
					StrMult = 1.2 + (0.1 * secretLevel/2)
					ForMult = 1.2 + (0.1 * secretLevel/2)
					EndMult = 0.7 + (0.1 * secretLevel)
					SureDodgeTimerLimit = 30 - (4 * secretLevel)
					SureHitTimerLimit = 30 - (4 * secretLevel)
					passives = list("Maki" = 1, "Curse" = 1, "Instinct" = 1, "Flow" = 1, "Godspeed" = 1 + secretLevel/2, \
					"CalmAnger"=1, FatigueLeak = clamp(3 - secretLevel/2,0 , 3), \
					"PureDamage" = 1 + secretLevel)

				verb/Jagan_Eye()
					set category="Skills"
					init(usr)
					src.Trigger(usr)
			Jinchuuriki
				SignatureTechnique=3
				NeedsHealth=50
				TooMuchHealth=75
				WoundThreshold=95
				passives = list("Maki" = 1, "Curse" = 1,"LifeGeneration" = 0.5, "Deflection" = 2, "Reversal" = 0.1)
				LifeGeneration=0.5
				Deflection=2
				Reversal=0.1
				Intimidation=1.25
				AutoAnger=1
				ActiveMessage="overflows with berserk demon chakra!"
				OffMessage="can no longer bear the strain of channelling demon chakra..."
				TextColor="#FF7700"
				IconLock='BijuuV1.dmi'
				LockX=-32
				LockY=-32
				verb/Jinchuuriki()
					set category="Skills"
					if(usr.passive_handler.Get("Unstoppable") || usr.HasInjuryImmune())
						WoundThreshold = 0
					if(!usr.BuffOn(src))
						src.NeedsHealth=25+(12.5*src.Mastery)
						src.TooMuchHealth=50+(6.25*src.Mastery)
						if(Mastery >= 4)
							src.TooMuchHealth=null
						if(Mastery >= 3)
							AutoAnger=0
							passives = list("Maki" = 1, "Curse" = 1, "LifeGeneration" = 2.5, "Deflection" = 2, "Reversal" = Mastery/5,"CalmAnger" = 1)
							CalmAnger=1
						else
							AutoAnger=1
							passives = list("Maki" = 1, "Curse" = 1, "LifeGeneration" = 1, "Deflection" = 2, "AutoAnger" = 1, "Reversal" = Mastery/10)
							CalmAnger=0
					if(src.Mastery==1)
						usr << "You don't have enough of a rapport to manipulate your demon at will!"
						return
					src.Trigger(usr)
			Vaizard_Mask
				SignatureTechnique=3
				ManaThreshold=1
				CooldownStatic = 1
				Cooldown=60
				passives = list("Maki" = 1, "Curse" = 1,"Instinct" = 2, "Pursuer" = 2, "Flicker" = 2)
				AutoAnger=1
				VaizardHealth=1
				CooldownScaling = 1
				ActiveMessage="is taken over by a violent rage as a mask forms on their face!"
				OffMessage="violently rips off their mask as it shatters into fragments..."
				verb/Customize_Mask()
					if(!usr.VaizardType)
						usr.VaizardType = input(usr, "What type?") in list("Berserker", "Manipulator", "Hellion", "Phantasm")
					var/changeIcon = input(usr, "Do you want to change your mask icon?") in list("Yes", "No")
					if(changeIcon == "Yes")
						IconLock = input(usr, "What icon?") as file
						LockX = input(usr, "What X offset?") as num
						LockY = input(usr, "What Y offset?") as num
				proc/changeVariables(mob/p)
					if(altered) return
					AngerMult = 1.3 + (0.1 * Mastery)
					var/toTen = (10/usr.Intimidation) * (10  * Mastery) // give them 100 per mastery
					Intimidation = 1 + toTen
					passives = list("Maki" = 1, "Curse" = 1, "AutoAnger" = 1, "VaizardHealth" = 1)
					var/pRedBoost = 0
					var/pDmgBoost = 0
					switch(p.VaizardType)
						if("Berserker")
							VaizardHealth=1
							Intimidation *= 1.25
							pDmgBoost = 1
							StrMult = 1.3 + (0.1 * Mastery)
							OffMult = 1.3 + (0.1 * Mastery)
						if("Manipulator")
							pDmgBoost = 1
							StrMult = 1.1 + (0.1 * Mastery)
							ForMult = 1.3 + (0.1 * Mastery)
							OffMult = 1.2 + (0.1 * Mastery)
						if("Hellion")
							pDmgBoost = 0.5
							pRedBoost = 0.5
							StrMult = 1.15 + (0.1 * Mastery)
							ForMult = 1.15 + (0.1 * Mastery)
							DefMult = 1.3 + (0.1 * Mastery)
						if("Phantasm")
							pRedBoost = 2
							EndMult = 1.3 + (0.1 * Mastery)
							DefMult = 1.3 + (0.1 * Mastery)
					passives = list("ManaLeak" = 4-Mastery, "PureReduction" = (Mastery * 0.5)+ pRedBoost, "PureDamage" = (Mastery * 0.5) + pDmgBoost, \
					"Maki" = 1, "Curse" = 1,"Instinct" = 2, "Pursuer" = 2, "Flicker" = 2)
					VaizardHealth = 5 + (2.5 * Mastery)
					VaizardShatter = 1
					Cooldown=60
				verb/Don_Mask()
					set category="Skills"
					if(!usr.BuffOn(src))
						changeVariables(usr)
					src.Trigger(usr)

		Aphotic_Shield
			SignatureTechnique=3
			StrMult=1.2
			ForMult=1.2
			EndMult=1.3
			passives = list("Siphon" = 5, "FluidForm" = 1, "PureReduction" = 1.5, "SpaceWalk" = 1, "StaticWalk" = 1, "Void" = 1)
			Siphon=5
			FluidForm=1
			SpaceWalk=1
			StaticWalk=1
			Void=1
			IconLock='zekkai.dmi'
			IconLockBlend=1
			IconUnder=1
			OverlaySize=1.3
			TopOverlayLock='DarknessGlow.dmi'
			TopOverlayX=-32
			TopOverlayY=-32
			ActiveMessage="consumes all light around them to form an orb of darkness!"
			OffMessage="stops absorbing light..."
			verb/Aphotic_Shield()
				set category="Skills"
				if(!altered)
					passives = list("Siphon" = 5, "FluidForm" = 1, "PureReduction" = 1, "SpaceWalk" = 1, "StaticWalk" = 1, "Void" = 1)
				src.Trigger(usr)
		Titan_Form
			SignatureTechnique=3
			StrMult=1.3
			EndMult=1.3
			DefMult = 0.5
			Enlarge=3
			passives = list("KBMult" = 3, "KBRes" = 3, "GiantForm" = 1, "SweepingStrike" = 1)
			KBMult=3
			KBRes=3
			GiantForm=1
			SweepingStrike=1
			ActiveMessage="explodes into a mountain of flesh that weaves itself into an enormous body!"
			OffMessage="sheds the excess flesh..."
			verb/Titan_Form()
				set category="Skills"
				if(!altered)
					passives = list("KBMult" = 3, "KBRes" = 3, "GiantForm" = 1, "SweepingStrike" = 1, "PureReduction" = 2, "Steady" = 2)
				src.Trigger(usr)
		Spirit_Pulse
			SignatureTechnique=3
			DefMult = 1.2
			EndMult = 1.2
			passives = list("Flow" = 1, "FluidForm" = 1, "MovementMastery" = 3, "PureReduction" = 1)
			ActiveMessage="is enveloped in a cascading glow!!"
			OffMessage="dissipates the glow..."
			verb/Spirit_Pulse()
				set category="Skills"
				if(!altered)
					passives = list("Flow" = 1, "FluidForm" = 1, "MovementMastery" = 3, "PureReduction" = 1)
				src.Trigger(usr)
		Spirit_Burst
			SignatureTechnique=3
			FatigueThreshold=10
			passives = list("Instinct" = 1, "PureDamage" = 2, "FatigueLeak" = 3)
			FatigueDrain = 0.0025
			Instinct=1
			Flicker=1
			PureDamage=2
			PUSpike=50
			ActiveMessage="spikes their energy in sudden bursts!"
			OffMessage="quells their energy..."
			verb/Spirit_Burst()
				set category="Skills"
				if(!altered)
					passives = list("Instinct" = 2, "PureDamage" = 2, "FatigueLeak" = 3, "PUSpike" = 50)
				src.Trigger(usr)
		Unbound_Mode
			SignatureTechnique=3
			ManaThreshold=1
			EnergyLeak=1.5
			StrMult=1.2
			EndMult=1.2
			SpdMult=1.2
			ForMult=1.2
			RecovMult=1.2
			passives = list("MovementMastery" = 3, "TechniqueMastery" = 2.5, "BuffMastery" = 2)
			FlashChange=1
			KenWaveIcon='Unbound.dmi'
			KenWave=1
			KenWaveSize=1
			KenWaveX=72
			KenWaveY=72
			KenWaveBlend=2
			KenWaveTime=5
			ActiveMessage="unleashes their complete self!"
			OffMessage="returns to their old self..."
			verb/Unbound_Mode()
				set category="Skills"
				if(!usr.BuffOn(src))
					if(!altered)
						passives = list("MovementMastery" = 3, "TechniqueMastery" = 3, "BuffMastery" = clamp(round(usr.Potential/20), 1, 5))
				src.Trigger(usr)
		Sparking_Blast
			SignatureTechnique=3
			EndMult=1.3
			StrMult=1.2
			SpdMult=1.2
			passives = list("EnergyGeneration" = 3, "ManaGeneration" = 1, "SoulFire" = 1, "PureDamage" = 1, "PureReduction" = 1, "LifeSteal" = 10)
			IconLock='SparkingBlastSparks.dmi'
			IconLockBlend=2
			OverlaySize=0.7
			LockY=-4
			FlashChange=1
			KenWaveIcon='SparkingBlast.dmi'
			KenWave=1
			KenWaveSize=1
			KenWaveX=72
			KenWaveY=72
			KenWaveBlend=2
			KenWaveTime=5
			Cooldown=-1
			verb/Sparking_Blast()
				set category="Skills"
				if(!usr.BuffOn(src))
					if(!altered)
						passives = list("EnergyGeneration" = 3, "ManaGeneration" = 1, "SoulFire" = 1, "PureDamage" = 1, "PureReduction" = 1, "LifeSteal" = 10)
					if(!src.Using)
						usr.Activate(new/obj/Skills/AutoHit/Knockoff_Wave)
				if(Trigger(usr))
					if(!src.Using)
						usr.Activate(new/obj/Skills/AutoHit/Knockoff_Wave)

		Limit_Breaker
			SignatureTechnique=3
			InstantAffect=1
			FINISHINGMOVE = 1
			StableHeal=1
			NeedsHealth=50
			TooMuchHealth=51
			OverClock=0.1
			passives = list ("Persistence" = 1, "UnderDog" = 1, "Tenacity" = 1, "AutoAnger" = 1, "AngerThreshhold" = 2)
			AutoAnger=1
			Desperation=1
			SpdMult=2
			HealthDrain = 0.001
			Cooldown=-1
			ActiveMessage="goes beyonds their limits!"
			OffMessage="cannot push themselves any further..."
			verb/Limit_Breaker(n as num)
				set category="Skills"
				if(n>3) return
				if(!usr.BuffOn(src))
					switch(n)
						if(3)
							if(usr.Health > 20 && usr.TotalInjury >= 75)
								usr<<"You have too much health, or too much injuries to use Limit Break 3"
								return
							else
								WoundCost = 25
								var/desp = usr.passive_handler.Get("Persistence")
								var/underDog = usr.passive_handler.Get("UnderDog")
								var/tenacity = usr.passive_handler.Get("Tenacity")
								if(desp >= 6 || underDog >= 6 || tenacity >= 6)
									// they r gorked
									passives = list("Persistence" = 1, "UnderDog" = 1, "Tenacity" = 1, "AngerThreshold" = 2,"Adrenaline" = 2, "LimitBroken" = 1)
								else
									passives = list("Persistence" = 6 - desp, "UnderDog" = 6 - underDog, "Tenacity" = 6 - tenacity, "AngerThreshold" = 2, "Adrenaline" = 2, "LimitBroken" = 1)
								PowerMult = 1.5
								HealthDrain = 0.006
								StrMult = 1.3
								EndMult = 0.6
								DefMult = 0.6
								SpdMult = 2
								OffMult = 1.3
								OverClock = 0.5
						if(2)
							if(usr.Health > 50 && usr.TotalInjury >= 85)
								usr<<"You have too much health, or too much injuries to use Limit Break 2"
								return
							else
								WoundCost = 15
								var/desp = usr.passive_handler.Get("Persistence")
								var/underDog = usr.passive_handler.Get("UnderDog")
								var/tenacity = usr.passive_handler.Get("Tenacity")
								if(desp >= 4 || underDog >= 4 || tenacity >= 4)
									// they r gorked
									passives = list("Persistence" = 1, "UnderDog" = 1, "Tenacity" = 1, "AngerThreshold" = 2,"Adrenaline" = 2, "LimitBroken" = 1)
								else
									passives = list("Persistence" = 6 - desp, "UnderDog" = 6 - underDog, "Tenacity" = 6 - tenacity, "AngerThreshold" = 2, "Adrenaline" = 2, "LimitBroken" = 1)
								PowerMult = 1.15
								HealthDrain = 0.003
								StrMult = 1.2
								EndMult = 0.8
								DefMult = 0.8
								SpdMult = 1.4
								OffMult = 1.2
								OverClock = 0.2
						if(1)
							if(usr.TotalInjury >= 95)
								usr<<"You have too much injuries to use Limit Break 1"
							else
								WoundCost = 5
								var/desp = usr.passive_handler.Get("Persistence")
								var/underDog = usr.passive_handler.Get("UnderDog")
								var/tenacity = usr.passive_handler.Get("Tenacity")
								if(desp >=  1 || underDog >= 1 || tenacity >= 1)
									// they r gorked
									passives = list("Persistence" = 1, "UnderDog" = 1, "Tenacity" = 1, "AngerThreshold" = 2,"Adrenaline" = 2, "LimitBroken" = 1)
								else
									passives = list("Persistence" = 6 - desp, "UnderDog" = 6 - underDog, "Tenacity" = 6 - tenacity, "AngerThreshold" = 2, "Adrenaline" = 2, "LimitBroken" = 1)
								StrMult = 1.2
								SpdMult = 1.2
								OffMult = 1.2
				src.Trigger(usr)

		Trance_Form
			SignatureTechnique=3
			Cooldown=-1
			var/Class
			verb/Trance_Form()
				set category="Skills"
				/*
				var/Highest=0
				var/Class
				if((usr.StrMod+usr.StrAscension)*usr.StrChaos>Highest)
					Class="Knight"
					Highest=(usr.StrMod+usr.StrAscension)*usr.StrChaos
				if((usr.ForMod+usr.ForAscension)*usr.ForChaos>Highest)
					Class="Magus"
					Highest=(usr.ForMod+usr.ForAscension)*usr.ForChaos
				if((usr.EndMod+usr.EndAscension)*usr.EndChaos>Highest)
					Class="Holy"
					Highest=(usr.EndMod+usr.EndAscension)*usr.EndChaos
				if((usr.SpdMod+usr.SpdAscension)*usr.SpdChaos>Highest)
					Class="Beast"
					Highest=(usr.SpdMod+usr.SpdAscension)*usr.SpdChaos*/
				if(!Class)
					var/list/trances = list("Beast","Knight","Magus","Holy")
					var/chosen = input("What Trance do you wish to specialise?") in trances
					Class = chosen
				if(!usr.SpecialBuff)
					switch(Class)
						if("Knight")
							if(!locate(/obj/Skills/Buffs/SpecialBuffs/Knight_Trance, usr))
								usr.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Knight_Trance)
							for(var/obj/Skills/Buffs/SpecialBuffs/Knight_Trance/KT in usr)
								KT.alter(usr)
								KT.Trigger(usr)
						if("Magus")
							if(!locate(/obj/Skills/Buffs/SpecialBuffs/Magus_Trance, usr))
								usr.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Magus_Trance)
							for(var/obj/Skills/Buffs/SpecialBuffs/Magus_Trance/KT in usr)
								KT.alter(usr)
								KT.Trigger(usr)
						if("Holy")
							if(!locate(/obj/Skills/Buffs/SpecialBuffs/Holy_Trance, usr))
								usr.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Holy_Trance)
							for(var/obj/Skills/Buffs/SpecialBuffs/Holy_Trance/KT in usr)
								KT.alter(usr)
								KT.Trigger(usr)
						if("Beast")
							if(!locate(/obj/Skills/Buffs/SpecialBuffs/Beast_Trance, usr))
								usr.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Beast_Trance)
							for(var/obj/Skills/Buffs/SpecialBuffs/Beast_Trance/KT in usr)
								KT.alter(usr)
								KT.Trigger(usr)
				else
					usr.SpecialBuff.Trigger(usr)
		Knight_Trance
			MagicNeeded=1
			MagicFocus=1
			Cooldown=-1
			PowerMult=1
			StrMult=1.3
			OffMult=1.3
			DefMult=1.2
			Mechanized=1
			passives = list("Mechanized" = 1, "MagicFocus" = 1, "Extend" = 1, "HybridStrike" = 1, "Instinct" = 1, "SwordAscension" = 1, "SwordDamage" = 1)
			Extend=1
			HybridStrike=1
			Instinct=1
			TechniqueMastery=3
			DropOverlays=1
			HairLock='BLANK.dmi'
			IconLock='TranceArmor.dmi'
			TopOverlayLock='TranceHelm.dmi'
			FlashChange=1
			KenWave=1
			KenWaveSize=1
			KenWaveBlend=2
			KenWaveIcon='Trance.dmi'
			KenWaveX=25
			KenWaveY=25
			ActiveMessage="erupts with magical force, becoming a valiant Knight!"
			OffMessage="seals off the magical might..."
			proc/alter(mob/p)
				if(altered) return
				passives = list("Mechanized" = 1, "MagicFocus" = 1, "Extend" = 1, "HybridStrike" = 1, "Instinct" = 1, "SwordAscension" = 1, "SwordDamage" = 1)
		Magus_Trance
			MagicNeeded=1
			MagicFocus=1
			ManaThreshold = 1
			Cooldown=-1
			PowerMult=1
			ForMult=1.3
			OffMult=1.3
			DefMult=1.15
			passives = list("SpiritStrike" = 1, "HybridStrike" = 0.25, "SpiritHand" = 2, "QuickCast" = 2, "ManaLeak" = 2)
			FlashChange=1
			KenWave=1
			KenWaveSize=1
			KenWaveBlend=2
			KenWaveIcon='Trance.dmi'
			KenWaveX=25
			KenWaveY=25
			ActiveMessage="erupts with magical force, becoming a skilled Magus!"
			OffMessage="seals off the magical might..."
			proc/alter(mob/p)
				if(altered) return
				passives = list("SpiritStrike" = 1, "HybridStrike" = 0.25, "SpiritHand" = 1, "QuickCast" = 2, "ManaLeak" = 2)
		Holy_Trance
			MagicNeeded=1
			MagicFocus=1
			Cooldown=-1
			PowerMult=1
			EndMult=1.3
			OffMult=1.2
			DefMult=1.3
			passives = list("DebuffResistance" = 1, "FluidForm" = 1, "GiantForm"  = 1, "LifeGeneration" = 0.5)
			DebuffResistance=1
			FluidForm=1
			GiantForm=1
			LifeGeneration=0.25
			StableHeal=1
			FlashChange=1
			KenWave=1
			KenWaveSize=1
			KenWaveBlend=2
			KenWaveIcon='Trance.dmi'
			KenWaveX=25
			KenWaveY=25
			ActiveMessage="erupts with magical force, becoming a resilient Wiseman!"
			OffMessage="seals off the magical might..."
			proc/alter(mob/p)
				if(altered) return
				HealthHeal = (2/240) * world.tick_lag
				passives = list("DebuffResistance" = 1, "FluidForm" = 1, "GiantForm"  = 1, "LifeGeneration" = 0.5)
		Beast_Trance
			MagicNeeded=1
			MagicFocus=1
			Cooldown=-1
			PowerMult=1
			SpdMult=1.3
			OffMult=1.2
			DefMult=1.3
			passives = list("MovementMastery" = 2, "BlurringStrike" = 1, "DoubleStrike" = 1, "TripleStrike" = 0.25, "Flicker" = 1, "Pursuer" = 3)
			DoubleStrike=1
			TripleStrike=0.25
			Flicker=1
			Pursuer=3
			DropOverlays=1
			HairLock=1
			PowerGlows=list(0.7,0.3,0.5, 0.99,0.59,0.78, 0.51,0.11,0.3, 0,0,0)
			IconLock='Overlay SSJ4 Pink.dmi'
			TopOverlayLock='Tail SSJ4 Pink.dmi'
			FlashChange=1
			KenWave=1
			KenWaveSize=1
			KenWaveBlend=2
			KenWaveIcon='Trance.dmi'
			KenWaveX=25
			KenWaveY=25
			ActiveMessage="erupts with magical force, becoming a passionate Beast!"
			OffMessage="seals off the magical might..."
			proc/alter(mob/p)
				if(altered) return
				passives = list("MovementMastery" = 2, "BlurringStrike" = 1, "DoubleStrike" = 1, "TripleStrike" = 0.25, "Flicker" = 1, "Pursuer" = 3)

		High_Tension
			SignatureTechnique=3
			NeedsHealth=50
			TooMuchHealth=75
			Cooldown=60
			CooldownStatic=1
			FlashChange=1
			KenWave=2
			KenWaveSize=0.5
			KenWaveBlend=2
			KenWaveIcon='KenShockwavePurple.dmi'
			IconTint=list(0.7,0.3,0.6, 0.99,0.59,0.88, 0.51,0.11,0.4, 0,0,0)
			AuraLock=1
			Transform="Tension"
			OffMessage="releases their tension..."
			var/current_tension = 0
			verb/Psych_Up()
				set category="Skills"
				set name="Psych Up!"
				if(!usr.BuffOn(src))
					if(src.Using)
						usr << "You cannot build up Tension so rapidly!"
						return
					KenShockwave2(usr, icon='SparkleViolet.dmi', Size=3, PixelX=105, PixelY=100, Blend=2, Time=12)
					if(src.Tension<20)
						src.Tension=20
					else if(src.Tension==20)
						src.Tension=50
					else if(src.Tension==50)
						src.Tension=100
					usr << "<font color='#FF00FF'>You build up Tension!</font>"

					src.Cooldown()
				else
					if(usr.Health>50)
						usr << "You don't feel pressed enough to build up any tension!"
						return
					else
						usr << "You are already in ascended state!"
						return
			verb/Release_Tension()
				set category="Skills"
				set name="Release Tension!"
				src.Trigger(usr)
		Universal
			NoSword=0
			NoStaff=0
			Ultra_Instinct
				SignatureTechnique=4
				OffMult=1.5
				DefMult=1.5
				passives = list("MovementMastery" = 10, "TechniqueMastery" = 10, "Instinct" = 5, "Flow" = 5, "WeaponBreaker" = 3, "HybridStrike" = 1, "Reversal" = 1, "MovingCharge" = 1, "MartialMagic" = 1, "SuperDash" = 1, "Pursuer" = 1, "Flicker" = 1, "GodKi" = 1)
				MovementMastery=10
				TechniqueMastery=10
				Instinct=3
				Flow=3
				WeaponBreaker=3
				HybridStrike=1
				Reversal=5
				MovingCharge=1
				MartialMagic=1
				SuperDash=1
				Pursuer=1
				Flicker=1
				GodKi=1
				FlashChange=1
				HairLock=1
				AuraLock='BLANK.dmi'
				IconLock='UltraInstinct.dmi'
				IconUnder=1
				LockX=-18
				LockY=-21
				TopOverlayLock='UltraInstinctSpark.dmi'
				IconTint=list(1,0.15,0.15, 0.15,1,0.15, 0,0,1, 0,0,0)
				verb/Ultra_Instinct()
					set category="Skills"
					src.Trigger(usr)

		Unarmed
			NoSword=1
			NoStaff=1
			Ghost_Install
				SignatureTechnique=3
				Afterimages=1
				Cooldown = -1
				passives = list("DoubleStrike" = 1)
				DoubleStrike=1
				SpdMult=1.5
				OffMult=1.25
				DefMult=1.25
				ActiveMessage="traces their attacks with the force of a fighter's soul!"
				OffMessage="exhausts their multiplied assault..."
				verb/Ghost_Install(fightingType in list("Berserker", "Warrior", "Hunter"))
					set category="Skills"
					if(!altered)
						if(!usr.BuffOn(src))
							AngerMult = 0
							AutoAnger = 0
							switch(fightingType)
								if("Berserker")
									AngerMult = 1.25
									passives = list("PureReduction" = -1, "PureDamage" = 2, "DoubleStrike" = 1, "HeavyHitter" = 0.5, "Steady" = 1, "CancelDemonicDura" = 1 )
									StrMult = 1.3
									ForMult = 1.3
									OffMult = 1.3
									DefMult = 0.8
								if("Warrior")
									passives = list("UnarmedDamage" = 1, "Steady" = 1, "PureReduction" = 1, "PureDamage" = 1, "MovementMastery" = 3)
									StrMult = 1.2
									ForMult = 1.2
									EndMult = 1.2
									OffMult = 1.2
									DefMult = 1.2
								if("Hunter")
									passives = list("Godspeed" = 2, "Flicker" = 1, "Pursuer" = 2, "FluidForm" = 1, "BlurringStrikes" = 1)
									SpdMult = 1.5
									OffMult = 1.3
									DefMult = 1.3
					src.Trigger(usr)

			Way_of_the_Stripe//true tiger
				SignatureTechnique=3
				PreRequisite=list("/obj/Skills/Buffs/NuStyle/UnarmedStyle/Cat_Style")
				passives = list("MovementMastery" = 2,"TechniqueMastery" = 2, "HardStyle" = 1, "UnarmedDamage" = 1)
				HardStyle=1
				StrMult=1.2
				SpdMult=1.1
				OffMult=1.2
				ActiveMessage="bristles with unmitigated aggression as they take up the Way of the Stripe!"
				OffMessage="relaxes their mastery of Tiger style..."
				verb/Way_of_the_Stripe()
					set category="Skills"
					src.Trigger(usr)
			Constricting_Coil_Dance//true dragon
				SignatureTechnique=3
				PreRequisite=list("/obj/Skills/Buffs/NuStyle/UnarmedStyle/Snake_Style")
				Cooldown = -1
				passives = list("MovementMastery" = 2,"TechniqueMastery" = 2, "SoftStyle" = 1, "SpiritHand" = 1, "Deflection" = 1)
				TechniqueMastery=5
				SoftStyle=1
				CounterMaster=2
				SpiritHand=1
				Deflection=1
				ForMult=1.2
				SpdMult=1.1
				DefMult=1.2
				ActiveMessage="embraces patient harmony as they assume the Constricting Coil Dance!"
				OffMessage="relaxes their mastery of Dragon style..."
				verb/Constricting_Coil_Stance()
					set category="Skills"
					if(!altered)
						passives = list("MovementMastery" = 2,"TechniqueMastery" = 2, "SoftStyle" = 1, "SpiritHand" = 1, "Deflection" = 1)
					src.Trigger(usr)
			Hollow_Shell_Kata//true tortoise
				SignatureTechnique=3
				PreRequisite=list("/obj/Skills/Buffs/NuStyle/UnarmedStyle/Turtle_Style")
				Cooldown = -1
				passives = list("MovementMastery" = 2,"TechniqueMastery" = 2, "Void" = 1, "FluidForm" = 1, "VoidField" = 2, "DeathField" = 2)
				Void=1
				FluidForm=1
				StrMult=1.2
				EndMult=1.2
				DefMult=1.1
				ActiveMessage="empties their heart of emotion as they practice the Hollow Shell Kata!"
				OffMessage="relaxes their mastery of Tortoise style..."
				verb/Hollow_Shell_Kata()
					set category="Skills"
					if(!altered)
						passives = list("MovementMastery" = 2,"TechniqueMastery" = 2, "Void" = 1, "FluidForm" = 1, "VoidField" = 2, "DeathField" = 2)
					src.Trigger(usr)
			Sky_Emperor_Walk//true phoenix
				SignatureTechnique=3
				PreRequisite=list("/obj/Skills/Buffs/NuStyle/UnarmedStyle/Crane_Style")
				Cooldown = -1
				passives = list("MovementMastery" = 2,"TechniqueMastery" = 2, "Skimming" = 2, "SpiritFlow" = 1, "HybridStrike" = 0.25 )
				SpiritFlow=1
				ForMult=1.2
				StrMult=1.2
				ActiveMessage="ascends with serene grace as they ascend into the Sky Emperor's Walk!"
				OffMessage="relaxes their mastery of Phoenix style..."
				verb/Sky_Emperor_Walk()
					set name="Sky Emperor's Walk"
					set category="Skills"
					if(!altered)
						passives = list("MovementMastery" = 2,"TechniqueMastery" = 2, "Skimming" = 2, "SpiritFlow" = 1, "HybridStrike" = 0.25 )
					src.Trigger(usr)
			Sacred_Energy
				SignatureTechnique=4
				StrMult=1.25
				EndMult=1.25
				OffMult=1.25
				DefMult=1.25
				passives = list("GodKi" = 1)
				GodKi=1
				ActiveMessage="ascends into martial and spiritual perfection!"
				OffMessage="releases their unearthly focus..."
				verb/Sacred_Energy()
					set category="Skills"
					src.Trigger(usr)
			Sacred_Energy_Armor
				SignatureTechnique=4
				GodKi=1
				verb/Sacred_Energy_Armor_Offense()
					set category="Skills"
					set name="Sacred Energy Armor: Offense"
					if(!usr.BuffOn(src))
						passives = list("GodKi" = 1, "Instinct" = 2, "NoWhiff" = 1, "Flicker" = 2, "Pursuer" = 2, "Steady" = 9)
						src.Instinct=2
						src.NoWhiff=1
						src.Flicker=2
						src.Pursuer=2
						src.Steady=9
						src.StrMult=1.5
						src.EndMult=1
						src.OffMult=1.5
						src.DefMult=1
						src.FluidForm=0
						src.GiantForm=0
						src.Flow=0
						src.Reversal=0
						src.ActiveMessage="manifests regalia of offense: Sacred Energy Armor!"
						src.OffMessage="casts away the power to change the world..."
						src.IconLock=usr.SEAOffense
						src.LockX=0
						src.LockY=0
					src.Trigger(usr)
				verb/Sacred_Energy_Armor_Defense()
					set category="Skills"
					set name="Sacred Energy Armor: Defense"
					if(!usr.BuffOn(src))
						passives = list("FluidForm" = 1, "GiantForm" = 1, "Flow" = 2, "Reversal" = 1)
						src.Instinct=0
						src.NoWhiff=0
						src.Flicker=0
						src.Pursuer=0
						src.Steady=0
						src.StrMult=1
						src.EndMult=1.5
						src.OffMult=1
						src.DefMult=1.5
						src.FluidForm=1
						src.GiantForm=1
						src.Flow=2
						src.Reversal=1
						src.ActiveMessage="manifests regalia of defense: Sacred Energy Armor!"
						src.OffMessage="casts away the power to change the world..."
						src.IconLock=usr.SEADefense
						src.LockX=0
						src.LockY=0
					src.Trigger(usr)
		Sword
			NeedsSword=1
			SwordSaint
				SignatureTechnique=3
				SagaSignature=1
				StrMult=1.3
				OffMult=1.3
				DefMult=1.3
				passives = list("CriticalChance" = 10, "BlockChance" = 10, "CriticalDamage" = 0.5, "CriticalBlock" = 0.5, "Flicker" = 1, "Reversal" = 0.5, "SwordAscension" = 1)
				IconLock='EyeFlameC.dmi'
				ActiveMessage="begins to handle their weapon with endless dedication!"
				OffMessage="loses their extreme focus..."
				verb/Sword_Saint()
					set category="Skills"
					if(!altered)
						if(!usr.BuffOn(src))
							passives = list("CriticalChance" = usr.Potential/10, "BlockChance" = usr.Potential/10, "CriticalDamage" = 0.075 * usr.Potential/10, "CriticalBlock" = 0.075 * usr.Potential/10, "Flicker" = 1, "Reversal" = 0.5, "SwordAscension" = 1)
					src.Trigger(usr)
			PranaBurst
				SignatureTechnique=3
				SagaSignature=1
				ManaThreshold=2
				passives = list("ManaLeak" = 2, "SpiritSword" = 0.5, "Extend" = 1, "SwordAscension" = 1, "SuperDash" = 1, "HybridStrike" = 1)
				SpdMult=1.3
				StrMult=1.3
				ForMult=1.3
				IconLock='GentleDivine.dmi'
				IconLockBlend=2
				LockX=-32
				LockY=-34
				HitSpark='Slash - Power.dmi'
				HitSize=1.2
				HitX=-32
				HitY=-32
				HitTurn=1
				ActiveMessage="begins to pour immense energy into every strike of their blade!"
				OffMessage="seals their immense output..."
				verb/Prana_Burst()
					set category="Skills"
					if(!altered)
						passives = list("ManaLeak" = 2, "SpiritSword" = 0.5, "Extend" = 1, "SwordAscension" = 1, "SuperDash" = 1, "HybridStrike" = 0.5)
					src.Trigger(usr)
			Final_Getsuga_Tenshou
				SignatureTechnique=4
				TimerLimit=600
				EnergyCut=0.99
				ManaCut=0.99
				StrCut=0.5
				EndCut=0.5
				ForCut=0.5
				OffMult=1.5
				DefMult=1.5
				SpdMult=2
				SureDodgeTimerLimit=10
				SureHitTimerLimit=10
				passives = list("CriticalChance" = 50, "BlockChance" = 50, "CriticalDamage" = 1, "CriticalBlock" = 1, "Flicker" = 2, "Reversal" =1, "SuperDash" = 2, "SwordAscension" = 2, "SwordDamage" = 2, "SwordAccuracy" = 2, "SwordDelay" = 2, "Extend" = 2, "SpiritHand" = 1, "Steady" = 9, "GiantForm" = 1, "FluidForm" = 1, "GodKi" = 1)
				IconLock='DarknessFlame.dmi'
				HitSpark='Slash - Black.dmi'
				HitSize=1.5
				HitX=-32
				HitY=-32
				HitTurn=1
				KenWave=4
				KenWaveIcon='DarkKiai.dmi'
				ActiveMessage="dedicates their entire existence to their blade!"
				OffMessage="sacrifices their potential completely..."
				verb/Final_Getsuga_Tenshou()
					set category="Skills"
					src.Trigger(usr)
					if(usr.BuffOn(src))
						usr.AddSkill(new/obj/Skills/AutoHit/Mugetsu)
					if(!usr.BuffOn(src))//once you turn it off
						for(var/obj/Skills/AutoHit/Mugetsu/MGS in usr.contents)
							del MGS
						for(var/obj/Skills/Buffs/SpecialBuffs/Sword/Final_Getsuga_Tenshou/FGT in usr.contents)
							del FGT
//Cybernetics and Enchantment
		MilitaryFrames
			Overdrive
				SignatureTechnique=3
				KiControl=1
				ManaThreshold=0.001
				passives = list("KiControl" = 1, "ManaLeak" = 1, "AllOutPU" = 1, "Overdrive" = 1)
				SpdMult=1.2
				RecovMult=1.2
				OverClock=0.2
				AuraLock=1
				LockX=0
				LockY=0
				TextColor=rgb(0, 200, 0)
				ActiveMessage="overloads their cybernetics!"
				OffMessage="suffers a circuitry breakdown!"
				adjust(mob/p)
					if(altered) return
					var/totalPot = round(glob.progress.totalPotentialToDate,10)
					SpdMult = 1.3 + totalPot/150
					StrMult = 1.3 + totalPot/150
					EndMult = 0.6 + clamp(totalPot/150, 0.1, 0.4)
					DefMult = 0.6 + clamp(totalPot/150, 0.1, 0.4)
					var/reducedPot = totalPot/10
					ManaDrain = 0.008 - (0.001 * reducedPot)
					passives = list("ManaLeak" = 1 - totalPot/200 )


				verb/Overdrive()
					set category="Skills"
					adjust(usr)
					src.Trigger(usr)
			Ripper_Mode
				SignatureTechnique=3
				ManaThreshold=0.001
				passives = list("ManaLeak" = 1, "Steady" = 2, "Godspeed" = 1, "Pursuer" = 1, "Flicker" = 1)
				ManaLeak=1
				SpdMult=1.2
				OffMult=1.3
				DefMult=0.8
				Steady=2
				Godspeed=1
				Pursuer=1
				Flicker=1
				IconLock='RipperMode.dmi'
				IconLockBlend=2
				LockX=0
				LockY=0
				BuffTechniques = list("/obj/Skills/Buffs/SlotlessBuffs/CyberPunk/Sandevistan")
				ActiveMessage="is overtaken by a more sadistic personality as they overclock their cybernetics!"
				OffMessage="falters as their cyber-sadism is repressed..."
				var/sandevistanUsages = 0
				adjust(mob/p)
					if(altered) return
					var/totalPot = round(glob.progress.totalPotentialToDate,10)
					SpdMult = 1 + totalPot/150
					OffMult = 1.1 + totalPot/150
					DefMult = 0.4 + clamp(totalPot/150, 0.1, 0.4)
					var/reducedPot = totalPot/10
					SureHitTimerLimit = 30 + (100-totalPot)
					passives = list("ManaLeak" = 1 - totalPot/200, "HardStyle" = 0.3 * reducedPot, \
					"Flicker" = clamp(round(reducedPot/5,1), 1, 2), "Pursuer" = clamp(round(reducedPot/5,1), 1, 2), \
					"Instinct" = reducedPot * 0.5, "Godspeed" = round(reducedPot/2.5, 1), "Steady" = reducedPot * 0.5)

				verb/Ripper_Mode()
					set category="Skills"
					if(!usr.BuffOn(src))
						adjust(usr)
					src.Trigger(usr)

			Armstrong_Augmentation
				SignatureTechnique=3
				ManaThreshold=0.001
				ManaLeak=1
				StrMult=1.2
				EndMult=1.3
				passives = list ("ManaLeak" = 1, "WeaponBreaker" = 1, "Juggernaut" = 1,\
				 "Hardening" = 2, "CriticalDamage" = 0.5, "CriticalChance" = 5)
				DefMult=0.5
				IconLock='BusoKoka.dmi'
				LockX=0
				LockY=0
				BuffTechniques = list("/obj/Skills/Buffs/SlotlessBuffs/CyberPunk/GorillaArms")
				ActiveMessage="laughs haughtily as they bolster their defenses with the best technology in the world!"
				OffMessage="stumbles as their arrogant bulwark fades away..."
				adjust(mob/p)
					if(altered) return
					var/totalPot = round(glob.progress.totalPotentialToDate,10)
					EndMult = 1.2 + totalPot/150
					StrMult = 1.1 + totalPot/150
					DefMult = 0.1 + clamp(totalPot/150, 0.1, 0.4)
					var/reducedPot = totalPot/10
					passives = list("ManaLeak" = 1 - totalPot/200, "WeaponBreaker" = 0.3 * reducedPot, \
					"BlockChance" = round(reducedPot/10,1), "CriticalBlock" = round(reducedPot/15), \
					"Hardening" = reducedPot * 0.5, "Juggernaut" = 1, "DemonicDurability" = reducedPot * 0.3)
				verb/Armstrong_Augmentation()
					set category="Skills"
					adjust(usr)
					src.Trigger(usr)

			Ray_Gear
				SignatureTechnique=3
				ManaThreshold=0.001
				ManaLeak=1
				ForMult=1.3
				OffMult=1.2
				SpdMult=0.7
				passives = list("ManaLeak" = 1, "Instinct" = 1, "QuickCast" = 3, "SpecialStrike" = 1)
				SureHitTimerLimit=30
				ActiveMessage="arms themselves with enormous firepower, a weapon to surpass all!"
				OffMessage="ditches the excess weaponry..."
				adjust(mob/p)
					if(altered) return
					var/totalPot = round(glob.progress.totalPotentialToDate,10)
					ForMult = 1.2 + totalPot/150
					OffMult = 1.1 + totalPot/150
					SpdMult = 0.7 + clamp(totalPot/150, 0.1, 0.4)
					var/reducedPot = totalPot/10
					passives = list("ManaLeak" = 1 - totalPot/200, "Instinct" = 0.5 * reducedPot, \
					"QuickCast" = round(reducedPot/10,1), "SpecialStrike" = 1, "MovingCharge" = 1, "SpiritHand" = round(totalPot/4,1))

				verb/Ray_Gear()
					set category="Skills"
					adjust(usr)
					src.Trigger(usr)


//Tier S
		Saint_Cloth
			HairLock='BLANK.dmi'
			FlashChange=1
			MakesArmor=1
			StripEquip=2
			Cooldown=-1
			proc/adjustments(mob/player)
				if(altered)
					return
			verb/Toggle_Helmet()
				set category="Roleplay"
				var/image/im=image(icon=src.TopOverlayLock, pixel_x=src.TopOverlayX, pixel_y=src.TopOverlayY, layer=FLOAT_LAYER-1)
				im.blend_mode=src.IconLockBlend
				im.transform*=src.OverlaySize
				if(src.OverlaySize>=2)
					im.appearance_flags+=512

				var/image/im2=image(icon='goldsaintlibra_staff.dmi', layer=FLOAT_LAYER)
				if(usr.BuffOn(src))
					if(!src.NoTopOverlay)
						if(usr.CheckSpecial("Libra Cloth"))
							usr.overlays-=im2
						if(usr.HairLocked)
							usr.HairLock=null
							usr.HairLocked=null
						usr.overlays-=im
						usr.Hairz("Add")
						if(usr.CheckSpecial("Libra Cloth"))
							usr.overlays+=im2
						usr << "You remove your helmet!"
						src.NoTopOverlay=1
					else
						if(usr.CheckSpecial("Libra Cloth"))
							usr.overlays-=im2
						if(src.HairLock!=1)
							usr.HairLock=src.HairLock
							usr.HairLocked=1
						usr.Hairz("Add")
						usr.overlays+=im
						if(usr.CheckSpecial("Libra Cloth"))
							usr.overlays+=im2
						usr << "You put your helmet back on!"
						src.NoTopOverlay=0
			Bronze_Cloth
				PUSpeedModifier=0.5
				MovementMastery=5
				ArmorClass="Light"
				ArmorAscension=1
				adjustments(mob/player)
					if(!altered)
						MovementMastery = player.SagaLevel * 1.25
				Pegasus_Cloth
					StrMult=1.25
					SpdMult=1.5
					ArmorIcon='saintpegasus_armor.dmi'
					TopOverlayLock='saintpegasus_helmet.dmi'
					ActiveMessage="dons the Cloth of the Pegasus, embracing its rebelious ascent!"
					OffMessage="discards the Cloth..."
					adjustments(mob/player)
						..()
						if(!altered)
							passives = list("MovementMastery" =  player.SagaLevel * 1.25, "ArmorAscension" = 1, "Tenacity" = 0.4 + (player.SagaLevel * 0.3), "Persistence" = 0.4 + (player.SagaLevel * 0.3), "UnderDog" = 0.4 + (player.SagaLevel * 0.3), "Godspeed" = 1 + (player.SagaLevel * 0.4))
							StrMult = 1 + (player.SagaLevel * 0.1)
							SpdMult = 1 + (player.SagaLevel * 0.1)
					verb/Don_Cloth()
						set category="Skills"
						adjustments(usr)
						src.NoTopOverlay=0
						src.Trigger(usr)

				Dragon_Cloth
					StrMult=1.2
					EndMult=1.6
					DefMult=1.2
					ArmorIcon='saintdragon_armor.dmi'
					TopOverlayLock='saintdragon_helmet.dmi'
					ActiveMessage="dons the Cloth of the Dragon, embracing its unflinching pride!"
					OffMessage="discards the Cloth..."
					adjustments(mob/player)
						..()
						if(!altered)
							StrMult = 1 + (player.SagaLevel * 0.1)
							EndMult = 1.1 + (player.SagaLevel * 0.1)
							DefMult = 1 + (player.SagaLevel * 0.1)
							passives = list("MovementMastery" =  player.SagaLevel * 1.25, "ArmorAscension" = 1, "Reversal" = player.SagaLevel * 0.1, "CriticalBlock" = player.SagaLevel / 6, "BlockChance" = 5 + (player.SagaLevel * 1.5))
					verb/Don_Cloth()
						set category="Skills"
						adjustments(usr)
						src.NoTopOverlay=0
						src.Trigger(usr)

				Cygnus_Cloth
					ForMult=1.7
					OffMult=1.1
					DefMult=1.2
					HairLock=1
					passives = list("MovementMastery" =  3, "ArmorAscension" = 1, "VenomImmune" = 1, "WalkThroughHell" = 1, "Chilling" = 1, "SpiritStrike" = 1)
					ArmorIcon='saintcygnus_armor.dmi'
					TopOverlayLock='saintcygnus_helmet.dmi'
					ActiveMessage="dons the Cloth of the Swan, embracing its stoic and cold grace!"
					OffMessage="discards the Cloth..."
					adjustments(mob/player)
						..()
						if(!altered)
							ForMult = 1.2 + (player.SagaLevel * 0.1)
							OffMult = 1 + (player.SagaLevel * 0.1)
							DefMult = 1 + (player.SagaLevel * 0.1)
							EndMult = 0.9 + (player.SagaLevel * 0.1)
							passives = list("MovementMastery" =  player.SagaLevel * 1.25, "SpiritStrike" = 1,  "ArmorAscension" = 1, "Chilling" = 1 + round(player.SagaLevel / 2,0.5), "VenomImmune" = 2 + (player.SagaLevel / 6), \
							 "WalkThroughHell" = 1)
					verb/Don_Cloth()
						set category="Skills"
						src.NoTopOverlay=0
						adjustments(usr)
						src.Trigger(usr)

				Andromeda_Cloth
					EndMult=1.4
					SpdMult=1.1
					OffMult=1.2
					DefMult=1.3
					BladeFisting = 1
					passives = list("BladeFisting" = 1)
					BuffTechniques=list("/obj/Skills/Buffs/SlotlessBuffs/Andromeda_Chain")
					ArmorIcon='saintandromeda_armor.dmi'
					TopOverlayLock='saintandromeda_helmet.dmi'
					ActiveMessage="dons the Cloth of Andromeda, embracing its gentle sacrifice..."
					OffMessage="discards the Cloth..."
					adjustments(mob/player)
						..()
						EndMult = 1 + (player.SagaLevel * 0.1)
						SpdMult = 1 + (player.SagaLevel * 0.1)
						OffMult = 1 + (player.SagaLevel * 0.1)
						DefMult = 1.1 + (player.SagaLevel * 0.1)
						passives = list("MovementMastery" =  player.SagaLevel * 1.25, "ArmorAscension" = 1, "BladeFisting" = 1)
					verb/Don_Cloth()
						set category="Skills"
						adjustments(usr)
						src.NoTopOverlay=0
						src.Trigger(usr)
				Phoenix_Cloth
					ArmorAscension=2
					BuffTechniques=list("/obj/Skills/Projectile/Phoenix_Feathers")
					ArmorIcon='saintphoenix_armor.dmi'
					TopOverlayLock='saintphoenix_helmet.dmi'
					ActiveMessage="dons the Cloth of the Phoenix, embracing its inextinguishable passion!"
					OffMessage="discards the Cloth..."
					adjustments(mob/player)
						..()
						passives = list("MovementMastery" =  player.SagaLevel * 1.5, "ArmorAscension" = 2, "SpiritHand" = player.SagaLevel)
						StrMult = 1.1 + (player.SagaLevel * 0.1)
						ForMult = 1.1 + (player.SagaLevel * 0.1)
						OffMult = 1 + (player.SagaLevel * 0.1)

					verb/Don_Cloth()
						set category="Skills"
						adjustments(usr)
						src.NoTopOverlay=0
						src.Trigger(usr)
				Unicorn_Cloth
					SpdMult = 1.3
					OffMult = 1.1
					DefMult = 1.3
					ArmorIcon='Unicorn_Cloth.dmi'
					TopOverlayLock='Unicorn_Cloth_Helmet.dmi'
					ActiveMessage="dons the Cloth of the Unicorn, embracing its brilliant speed!"
					adjustments(mob/player)
						..()
						passives = list("MovementMastery" =  player.SagaLevel * 1.25, "ArmorAscension" = 2, "Pursuer" = 1.2 + (player.SagaLevel*0.2), "Flicker" = max(1,player.SagaLevel*0.5))
						SpdMult = 1.2 + (player.SagaLevel * 0.1)
						OffMult = 1 + (player.SagaLevel * 0.1)
						DefMult = 1.1 + (player.SagaLevel * 0.1)

					verb/Don_Cloth()
						set category="Skills"
						adjustments(usr)
						src.NoTopOverlay=0
						src.Trigger(usr)

			Bronze_Cloth_V2
				MovementMastery=10
				ArmorClass="Medium"
				ArmorAscension=2
				HairLock=1
				adjustments(mob/player)
					MovementMastery = player.SagaLevel * 2
					// Hustle = 1 + (player.SagaLevel * 0.25)
				Pegasus_Cloth
					StrMult=1.5
					SpdMult=1.5
					Desperation=1
					Godspeed=1
					ArmorElement="Light"
					ArmorIcon='saintpegasusv3_armor.dmi'
					TopOverlayLock='saintpegasusv3_helmet.dmi'
					ActiveMessage="dons the renewed Cloth of the Pegasus, embracing its rebelious ascent!"
					OffMessage="discards the Cloth..."
					adjustments(mob/player)
						..()
						var/newLevel = clamp(player.SagaLevel - 2, 1,4)
						passives = list("MovementMastery" = player.SagaLevel * 2, "ArmorAscension" = 2, "Tenacity" = 1 + (player.SagaLevel * 1), "Persistence" = 1 + (player.SagaLevel * 1), \
									 "UnderDog" = 1 + (player.SagaLevel * 1), "Godspeed" = 1+ (player.SagaLevel*0.5) )
						StrMult = 1.3 + (newLevel * 0.1)
						SpdMult = 1.3 + (newLevel * 0.1)
						Desperation = 1 + (player.SagaLevel * 0.5)
						Godspeed = 1 + (player.SagaLevel * 0.2)
					verb/Don_Cloth()
						set category="Skills"
						adjustments(usr)
						src.NoTopOverlay=0
						src.Trigger(usr)
				Dragon_Cloth
					StrMult=1.2
					EndMult=1.6
					DefMult=1.2
					ArmorIcon='saintdragonv3_armor.dmi'
					TopOverlayLock='saintdragonv3_helmet.dmi'
					ActiveMessage="dons the renewed Cloth of the Dragon, embracing its unflinching pride!"
					OffMessage="discards the Cloth..."
					adjustments(mob/player)
						..()
						var/newLevel = clamp(player.SagaLevel - 2, 1,4)
						StrMult = 1.3 + (newLevel * 0.1)
						EndMult = 1.5 + (newLevel * 0.1)
						DefMult = 1.3 + (newLevel * 0.1)
						passives = list("MovementMastery" = player.SagaLevel * 2, "ArmorAscension" = 2, "Reversal" = player.SagaLevel * 0.1,\
						"CriticalBlock" = player.SagaLevel / 6, "BlockChance" = 10 + (player.SagaLevel * 1.5))
					verb/Don_Cloth()
						set category="Skills"
						adjustments(usr)
						src.NoTopOverlay=0
						src.Trigger(usr)

				Cygnus_Cloth
					ForMult=1.7
					OffMult=1.1
					DefMult=1.2
					HairLock=1
					passives = list("VenomImmune" = 1, "WalkThroughHell" = 1, "Freezing" = 1)
					VenomImmune=1
					WalkThroughHell=1
					Freezing=1
					ArmorIcon='saintcygnusv3_armor.dmi'
					TopOverlayLock='saintcygnusv3_helmet.dmi'
					ActiveMessage="dons the renewed Cloth of the Swan, embracing its stoic and cold grace!"
					OffMessage="discards the Cloth..."
					adjustments(mob/player)
						..()
						var/newLevel = clamp(player.SagaLevel - 2, 1,4)
						if(!altered)
							ForMult = 1.5 + (newLevel * 0.1)
							OffMult = 1.3 + (newLevel * 0.1)
							DefMult = 1.3 + (newLevel * 0.1)
							EndMult = 1.2 + (newLevel * 0.1)
							passives = list("MovementMastery" =  player.SagaLevel * 2, "SpiritStrike" = 1, "ArmorAscension" = 2, "Freezing" = 1 + player.SagaLevel, "VenomImmune" = 1, \
							 "WalkThroughHell" = 1, "Erosion" = 0.05 * newLevel)
					verb/Don_Cloth()
						set category="Skills"
						adjustments(usr)
						src.NoTopOverlay=0
						src.Trigger(usr)

				Andromeda_Cloth
					EndMult=1.4
					SpdMult=1.1
					OffMult=1.2
					DefMult=1.3
					BladeFisting = 1
					BuffTechniques=list("/obj/Skills/Buffs/SlotlessBuffs/Andromeda_Chain", "/obj/Skills/Buffs/SlotlessBuffs/Andromeda/Rolling_Defense")
					ArmorIcon='saintandromedav3_armor.dmi'
					TopOverlayLock='saintandromedav3_helmet.dmi'
					ActiveMessage="dons the renewed Cloth of Andromeda, embracing its gentle sacrifice..."
					OffMessage="discards the Cloth..."
					adjustments(mob/player)
						..()
						var/newLevel = clamp(player.SagaLevel - 2, 1,4)
						passives = list("MovementMastery" = player.SagaLevel * 2, "ArmorAscension" = 2, "BladeFisting" = 1)
						SpdMult = 1.2 + (newLevel * 0.1)
						EndMult = 1.1 + (newLevel * 0.1)
						StrMult = 1.1 + (newLevel * 0.1)
						OffMult = 1.2 + (newLevel * 0.1)
						DefMult = 1.3 + (newLevel * 0.1)

					verb/Don_Cloth()
						set category="Skills"
						adjustments(usr)
						src.NoTopOverlay=0
						src.Trigger(usr)
				Phoenix_Cloth
					ArmorClass="Medium"
					ArmorAscension=3
					StrMult=1.4
					ForMult=1.4
					OffMult=1.2
					BuffTechniques=list("/obj/Skills/Projectile/Phoenix_Feathers")
					ArmorIcon='saintphoenixv3_armor.dmi'
					TopOverlayLock='saintphoenixv3_helmet.dmi'
					ActiveMessage="dons the reborn Cloth of the Phoenix, embracing its inextinguishable passion!"
					OffMessage="discards the Cloth..."
					adjustments(mob/player)
						..()
						var/newLevel = clamp(player.SagaLevel - 2, 1,4)
						passives = list("MovementMastery" = player.SagaLevel * 2.25, "ArmorAscension" = 2, "SpiritHand" = player.SagaLevel*1.5)
						StrMult = 1.4 + (newLevel * 0.1)
						ForMult = 1.4 + (newLevel * 0.1)
						OffMult = 1.3 + (newLevel * 0.1)
					verb/Don_Cloth()
						set category="Skills"
						adjustments(usr)
						src.NoTopOverlay=0
						src.Trigger(usr)
				Unicorn_Cloth
					SpdMult = 1.4
					OffMult = 1.2
					DefMult = 1.3
					ArmorIcon='Unicorn_ClothV3.dmi'
					TopOverlayLock='Unicorn_cloth_V2_Helmet.dmi'
					ActiveMessage="dons the reborn Cloth of the Unicorn, embracing its unbreakable speed!"
					OffMessage="discards the Cloth..."
					adjustments(mob/player)
						..()
						passives = list("MovementMastery" =  player.SagaLevel * 2, "ArmorAscension" = 2, "Pursuer" = 1 + (player.SagaLevel * 0.3), "Flicker" = max(1,player.SagaLevel))
						SpdMult = 1.3 + (player.SagaLevel * 0.1)
						OffMult = 1.1 + (player.SagaLevel * 0.1)
						DefMult = 1.2 + (player.SagaLevel * 0.1)
					verb/Don_Cloth()
						set category="Skills"
						adjustments(usr)
						src.NoTopOverlay=0
						src.Trigger(usr)
			Gold_Cloth
				MovementMastery=20
				DebuffResistance=1
				SpaceWalk=1//gold
				StaticWalk=1
				ArmorClass="Heavy"
				ArmorElement="Light"
				ArmorAscension=3
				var/NoExtraOverlay=1
				var/temporaryTime = 0
				var/timeLimit
				var/startTime = 0
				GainLoop(mob/source)
					..()
					checkForEnd(source)
				proc/setRandomTime(mob/p)
					var/bonus = p.SagaLevel * 1000
					var/roll = rand(1000, 1200) // between 20 seconds and 2 minutes
					timeLimit = roll + bonus
					temporaryTime = 1
					startTime = 1
				proc/checkForEnd(mob/p)
					if(temporaryTime)
						if(!p.PureRPMode)
							startTime++
							if(startTime >= timeLimit)
								temporaryTime = 0
								p << "Your Gold Cloth has expired!"
								src.Trigger(p, TRUE)
								Cape(p)
								sleep(3)
								del src

				adjustments(mob/player)
					..()
					passives = list("DebuffResistance" = 1, "SpaceWalk" =1, "StaticWalk" = 1,"MovementMastery" = 10+player.SagaLevel, "ArmorAscension" = 3, "Godspeed" = 1+(player.SagaLevel*0.25))
					if(!timeLimit&&player.SagaLevel < 5)
						setRandomTime(player)
				verb/Toggle_Cape()
					set category="Roleplay"
					Cape(usr)

				proc/Cape(mob/user)
					var/image/im=image(icon='goldsaint_cape.dmi', layer=FLOAT_LAYER-3)
					if(user.SagaLevel<5)
						user << "You're not worthy of a cape yet!"
						return
					if(user.BuffOn(src))
						if(!src.NoExtraOverlay)
							user.overlays-=im
							user << "You remove your cape!"
							src.NoExtraOverlay=1
						else
							user.overlays+=im
							user.Hairz("Add")
							user << "You put your cape on!"
							src.NoExtraOverlay=0
				Aries_Cloth
					ForMult=1.3
					EndMult=1.3
					DefMult=1.4
					SpiritFlow=1
					SpiritHand=1
					TechniqueMastery=5
					ArmorIcon='goldsaintaries_armor.dmi'
					TopOverlayLock='goldsaintaries_helmet.dmi'
					TopOverlayX=-32
					TopOverlayY=-32
					ActiveMessage="dons the Gold Cloth of Aries, embracing its elusive wisdom!"
					OffMessage="discards the Cloth..."
					adjustments(mob/player)
						..()
						ForMult = 1.4 + ((player.SagaLevel-2) * 0.1)
						EndMult = 1.4 + ((player.SagaLevel-2) * 0.1)
						DefMult = 1.5 + ((player.SagaLevel-2) * 0.1)
						passives = list("DebuffResistance" = 1, "SpaceWalk" =1, "StaticWalk" = 1,"MovementMastery" = 10+player.SagaLevel, "ArmorAscension" = 3, "Godspeed" = 1+(player.SagaLevel*0.25), "SpiritFlow" = player.SagaLevel*1.5, "SpiritHand" = player.SagaLevel*1.5, "TechniqueMastery" = 3 + (player.SagaLevel/1.5))

					verb/Don_Cloth()
						set category="Skills"
						src.NoTopOverlay=0
						adjustments(usr)
						src.Trigger(usr)
						Cape(usr)
				Gemini_Cloth
					StrMult=1.2
					ForMult=1.2
					EndMult=1.2
					OffMult=1.2
					DefMult=1.2
					BuffMastery=1
					HolyMod=2
					AbyssMod=2
					ArmorIcon='goldsaintgemini_armor.dmi'
					TopOverlayLock='goldsaintgemini_helmet.dmi'
					ActiveMessage="dons the Gold Cloth of Gemini, embracing its mystic duality!"
					OffMessage="discards the Cloth..."
					adjustments(mob/player)
						..()
						StrMult = 1.2 + ((player.SagaLevel-3) * 0.1)
						ForMult = 1.2 + ((player.SagaLevel-3) * 0.1)
						EndMult = 1.2 + ((player.SagaLevel-3) * 0.1)
						OffMult = 1.2 + ((player.SagaLevel-3) * 0.1)
						DefMult = 1.1 + ((player.SagaLevel-3) * 0.1)
						passives = list("DebuffResistance" = 1, "SpaceWalk" =1, "StaticWalk" = 1,"MovementMastery" = 8+player.SagaLevel, "ArmorAscension" = 3, "Godspeed" = 1+(player.SagaLevel*0.25), "HolyMod" = 2 + player.SagaLevel, "AbyssMod" = 2 + player.SagaLevel, "BuffMastery" = 1 + (player.SagaLevel/1.5), "SpiritPower" = player.SagaLevel*0.25)
					verb/Don_Cloth()
						set category="Skills"
						adjustments(usr)
						src.NoTopOverlay=0
						src.Trigger(usr)
						Cape(usr)
				Cancer_Cloth
					ForMult=1.4
					OffMult=1.4
					DefMult=1.2
					HairLock=1
					ArmorIcon='goldsaintcancer_armor.dmi'
					TopOverlayLock='goldsaintcancer_helmet.dmi'
					ActiveMessage="dons the Gold Cloth of Cancer, embracing its cunning tenacity!"
					OffMessage="discards the Cloth..."
					adjustments(mob/player)
						..()
						ForMult = 1.3 + ((player.SagaLevel-3) * 0.1)
						OffMult = 1.3 + ((player.SagaLevel-3) * 0.1)
						DefMult = 1.2 + ((player.SagaLevel-3) * 0.1)
						passives = list("DebuffResistance" = 1, "SpaceWalk" =1, "StaticWalk" = 1,"MovementMastery" = 8+player.SagaLevel, "ArmorAscension" = 3, \
						"Godspeed" = 1+(player.SagaLevel*0.25), "MartialMagic" = 1, "AbyssMod" = player.SagaLevel*2, "SlayerMod" = 3+(player.SagaLevel/2), "FavoredPrey" = "Races", "SpiritPower" = player.SagaLevel*0.25)

					verb/Don_Cloth()
						set category="Skills"
						adjustments(usr)
						src.NoTopOverlay=0
						src.Trigger(usr)
						Cape(usr)
				Leo_Cloth
					StrMult=1.2
					ForMult=1.1
					SpdMult=1.7
					HairLock=1
					Intimidation=0.25
					ArmorIcon='goldsaintleo_armor.dmi'
					TopOverlayLock='goldsaintleo_helmet.dmi'
					ActiveMessage="dons the Gold Cloth of Leo, embracing its intimidating ferocity!"
					OffMessage="discards the Cloth..."
					adjustments(mob/player)
						..()
						StrMult = 1.3 + ((player.SagaLevel-3) * 0.1)
						ForMult = 1.3 + ((player.SagaLevel-3) * 0.1)
						SpdMult = 1.5 + ((player.SagaLevel-3) * 0.1)
						passives = list("DebuffResistance" = 1, "SpaceWalk" =1, "StaticWalk" = 1,"MovementMastery" = 10+player.SagaLevel, "ArmorAscension" = 3, "Godspeed" = 1+(player.SagaLevel*0.75), "DoubleStrike" = 1 +(player.SagaLevel/2), "TripleStrike" = 1 + (player.SagaLevel/3))
						Intimidation = (player.SagaLevel * 0.25)
					verb/Don_Cloth()
						set category="Skills"
						adjustments(usr)
						src.NoTopOverlay=0
						src.Trigger(usr)
						Cape(usr)
				Virgo_Cloth
					ForMult=1.4
					OffMult=1.2
					DefMult=1.4
					ArmorIcon='goldsaintvirgo_armor.dmi'
					TopOverlayLock='goldsaintvirgo_helmet.dmi'
					ActiveMessage="dons the Gold Cloth of Virgo, embracing its unapproachable purity!"
					OffMessage="discards the Cloth..."
					adjustments(mob/player)
						..()
						ForMult = 1.4 + ((player.SagaLevel-3) * 0.1)
						OffMult = 1.2 + ((player.SagaLevel-3) * 0.1)
						DefMult = 1.4 + ((player.SagaLevel-3) * 0.1)
						passives = list("DebuffResistance" = 1, "SpaceWalk" =1, "StaticWalk" = 1,"MovementMastery" = 8+player.SagaLevel, "ArmorAscension" = 3, "Godspeed" = 1+(player.SagaLevel*0.25), "FluidForm" = 1 + (player.SagaLevel*0.25), "HolyMod" = player.SagaLevel * 2, "HybridStrike" = player.SagaLevel*0.4)

					verb/Don_Cloth()
						set category="Skills"
						adjustments(usr)
						src.NoTopOverlay=0
						src.Trigger(usr)
						Cape(usr)
				Libra_Cloth
					OffMult=1.3
					DefMult=1.3
					SpdMult=1.4
					BuffTechniques=list("/obj/Skills/Buffs/SlotlessBuffs/Libra_Armory","/obj/Skills/Projectile/Beams/Big/Saint_Seiya/Beam_of_Libra")
					ArmorIcon='goldsaintlibra_armor.dmi'
					TopOverlayLock='goldsaintlibra_helmet.dmi'
					ActiveMessage="dons the Gold Cloth of Libra, embracing its fluid equilibrium!"
					OffMessage="discards the Cloth..."
					adjustments(mob/player)
						..()
						OffMult = 1.3 + ((player.SagaLevel-3) * 0.1)
						DefMult = 1.3 + ((player.SagaLevel-3) * 0.1)
						SpdMult = 1.4 + ((player.SagaLevel-3) * 0.1)
						passives = list("DebuffResistance" = 1, "SpaceWalk" =1, "StaticWalk" = 1, "MovementMastery" = 8+player.SagaLevel, "ArmorAscension" = 3, "Godspeed" = 1+(player.SagaLevel*0.25), "BlockChance" = 20 + (player.SagaLevel*5), "CriticalBlock" = 1 + (player.SagaLevel/3), "Deflection" = 2+(player.SagaLevel/3))

					verb/Don_Cloth()
						set category="Skills"
						src.NoTopOverlay=0
						adjustments(usr)
						src.Trigger(usr)
						if(usr.BuffOn(src))
							var/image/st=image(icon='goldsaintlibra_staff.dmi', layer=FLOAT_LAYER)
							usr.overlays+=st

				Scorpio_Cloth
					ForMult=1.5
					OffMult=1.3
					SpdMult=1.2
					HairLock=1
					ArmorIcon='goldsaintscorpio_armor.dmi'
					TopOverlayLock='goldsaintscorpio_helmet.dmi'
					ActiveMessage="dons the Gold Cloth of Scorpio, embracing its cruel precision!"
					OffMessage="discards the Cloth..."
					adjustments(mob/player)
						..()
						passives = list("DebuffResistance" = 1, "SpaceWalk" =1, "StaticWalk" = 1,"MovementMastery" = 8+player.SagaLevel, "ArmorAscension" = 3, "Godspeed" = 1+(player.SagaLevel*0.25), "HardStyle" = 1 + player.SagaLevel, "Curse" = 1, "Shearing" = 1 + player.SagaLevel)
						ForMult = 1.4 + ((player.SagaLevel-3) * 0.1)
						SpdMult = 1.2 + ((player.SagaLevel-3) * 0.1)
						OffMult = 1.3 + ((player.SagaLevel-3) * 0.1)
					verb/Don_Cloth()
						set category="Skills"
						src.NoTopOverlay=0
						adjustments(usr)
						src.Trigger(usr)
						Cape(usr)

				Capricorn_Cloth
					StrMult=1.3
					ForMult=1.3
					OffMult=1.4
					SureDodgeTimerLimit=10
					SureHitTimerLimit=10
					ArmorIcon='goldsaintcapricorn_armor.dmi'
					TopOverlayLock='goldsaintcapricorn_helmet.dmi'
					TopOverlayX=-32
					TopOverlayY=-32
					ActiveMessage="dons the Gold Cloth of Capricorn, embracing its boundless chivalry!"
					OffMessage="discards the Cloth..."
					adjustments(mob/player)
						..()
						passives = list("DebuffResistance" = 1, "SpaceWalk" =1, "StaticWalk" = 1, "MovementMastery" = 10+player.SagaLevel, "ArmorAscension" = 3, \
						"Godspeed" = 1+(player.SagaLevel*0.25), "SwordAscension" = player.SagaLevel, "BladeFisting" = 1)
						StrMult = 1.3 + ((player.SagaLevel-2) * 0.1)
						ForMult = 1.3 + ((player.SagaLevel-2) * 0.1)
						OffMult = 1.3 + ((player.SagaLevel-2) * 0.1)
					verb/Don_Cloth()
						set category="Skills"
						src.NoTopOverlay=0
						adjustments(usr)
						src.Trigger(usr)
						Cape(usr)
				Aquarius_Cloth
					ForMult=1.7
					OffMult=1.1
					DefMult=1.2
					HairLock=1
					ArmorIcon='goldsaintaquarius_armor.dmi'
					TopOverlayLock='goldsaintaquarius_helmet.dmi'
					ActiveMessage="dons the Gold Cloth of Aquarius, embracing its overflowing calmness!"
					OffMessage="discards the Cloth..."
					adjustments(mob/player)
						..()
						DefMult = 1.1 + ((player.SagaLevel-3) * 0.1)
						ForMult = 1.5 + ((player.SagaLevel-3) * 0.1)
						OffMult = 1.1 + ((player.SagaLevel-3) * 0.1)
						passives = list("DebuffResistance" = 1, "SpaceWalk" =1, "StaticWalk" = 1, "SpiritStrike" = 1, "MovementMastery" = 8+player.SagaLevel, \
						 "ArmorAscension" = 3, "Godspeed" = 1+(player.SagaLevel*0.25),"SoftStyle" = 1 + player.SagaLevel, "AbsoluteZero"= 1, "Freezing" = 1, "Erosion" = clamp(0.2 * (player.SagaLevel-3), 0.2, 0.75))
					verb/Don_Cloth()
						set category="Skills"
						src.NoTopOverlay=0
						adjustments(usr)
						src.Trigger(usr)
						Cape(usr)
				Pisces_Cloth
					ForMult=1.2
					OffMult=1.1
					DefMult=1.5
					ArmorElement="Poison"
					ArmorIcon='goldsaintpisces_armor.dmi'
					TopOverlayLock='goldsaintpisces_helmet.dmi'
					ActiveMessage="dons the Gold Cloth of Pisces, embracing its deceptive gleam!"
					OffMessage="discards the Cloth..."
					adjustments(mob/player)
						..()
						passives = list("DebuffResistance" = 1, "SpaceWalk" =1, "StaticWalk" = 1,"MovementMastery" = 8+player.SagaLevel, "ArmorAscension" = 3, \
						"Godspeed" = 1+(player.SagaLevel*0.25), "Toxic" = 1, "DeathField" = 5 + player.SagaLevel, "VoidField" = 5 + player.SagaLevel)
						DefMult = 1.4 + ((player.SagaLevel-3) * 0.1)
						ForMult = 1.1 + ((player.SagaLevel-3) * 0.1)
						OffMult = 1.1 + ((player.SagaLevel-3) * 0.1)
					verb/Don_Cloth()
						set category="Skills"
						src.NoTopOverlay=0
						adjustments(usr)
						src.Trigger(usr)
						Cape(usr)

				Sagittarius_Cloth
					ArmorIcon='goldsaintsagittarius_armor.dmi'
					TopOverlayLock='goldsaintsagittarius_helmet.dmi'
					IconLock = 'goldsaintsagittarius_wings.dmi'
					LockX = -32
					LockY = -32
					ActiveMessage="dons the Gold Cloth of Sagittarius, embracing its brilliant hope!"
					OffMessage="discards the Cloth..."
					adjustments(mob/player)
						..()
						passives = list("DebuffResistance" = 1, "SpaceWalk" = 1, "StaticWalk" = 1, "MovementMastery" = 8+player.SagaLevel, "ArmorAscension" = 3, "MovingCharge" = 1, \
										"Godspeed" = 1+(player.SagaLevel*0.5), "BlurringStrikes" = player.SagaLevel*0.2, "Flow" = player.SagaLevel-3, "Skimming" = 1, "SpiritFlow" = player.SagaLevel-2)
						SpdMult = 1.4 + ((player.SagaLevel-3) * 0.1)
						StrMult = 1.1 + ((player.SagaLevel-3) * 0.1)
						OffMult = 1.1 + ((player.SagaLevel-3) * 0.1)
					verb/Don_Cloth()
						set category="Skills"
						src.NoTopOverlay=0
						adjustments(usr)
						src.Trigger(usr)
						Cape(usr)

		Valor_Form
			FlashChange=1
			ABuffNeeded=list("Keyblade")
			MakesSecondSword=1
			SwordClassSecond="Medium"
			SwordAscensionSecond=2
			SwordIconSecond='KingdomKey.dmi'
			SwordXSecond=-32
			SwordYSecond=-32
			ManaThreshold=1
			StrMult=1.5
			OffMult=1.5
			KenWave=1
			KenWaveIcon='SparkleRed.dmi'
			KenWaveSize=3
			KenWaveX=105
			KenWaveY=105
			ActiveMessage="glows with limitless valor!"
			OffMessage="de-syncs their keyblades..."
			Cooldown=60
			verb/Valor_Form()
				set category="Skills"
				if(!usr.BuffOn(src))
					if(usr.CheckActive("Keyblade"))
						if(!src.Using)
							if(prob(7.5*usr.LimitCounter) && usr.SagaLevel < 8)
								usr.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/AntiForm)
								usr.LimitCounter=0
								return
							src.SwordClassSecond=GetKeychainClass(usr.SyncAttached)
							src.SwordDamageSecond=GetKeychainDamage(usr.SyncAttached)
							src.SwordAccuracySecond=GetKeychainAccuracy(usr.SyncAttached)
							src.SwordDelaySecond=GetKeychainDelay(usr.SyncAttached)
							src.SwordElementSecond=GetKeychainElement(usr.SyncAttached)
							src.SwordIconSecond=GetKeychainIconReversed(usr.SyncAttached)
							passives = list("ManaLeak" = 2, "Pursuer" = 1, "Flicker" = 1, "StunningStrike" = 1, "DoubleStrike" = 1 + usr.SagaLevel/3, "MasterfulCasting" = 1)
							if(usr.SyncAttached=="Way To Dawn")
								passives["HolyMod"] = 3 + (usr.SagaLevel/2)
								passives["AbyssMod"] = 3 + (usr.SagaLevel/2)

							if(usr.SyncAttached=="Fenrir")
								passives["SlayerMod"] = 3 + (usr.SagaLevel/2)
								passives["FavoredPrey"] = "Races"

							if(usr.SyncAttached=="Chaos Ripper")
								passives["Burning"] = 3
								passives["Scorching"] = 3
								passives["DarknessFlame"] = 3

							if(usr.SyncAttached=="No Name")
								passives["StealsStats"] = 1

							usr.LimitCounter+=1
				src.Trigger(usr)
		Wisdom_Form
			FlashChange=1
			ABuffNeeded=list("Keyblade")
			ManaLeak=1
			ManaThreshold=1
			passives = list("ManaLeak"= 1, "QuickCast"= 2, "TechniqueMastery" = 5, "Skimming" = 1, "DualCast" = 1, "SpecialStrike" = 1)
			ForMult=1.5
			DefMult=1.5
			KenWave=1
			KenWaveIcon='SparkleBlue.dmi'
			KenWaveSize=3
			KenWaveX=105
			KenWaveY=105
			ActiveMessage="glows with limitless wisdom!"
			OffMessage="de-syncs their keyblade..."

			Cooldown=60
			verb/Wisdom_Form()
				set category="Skills"
				if(!usr.BuffOn(src))
					if(usr.CheckActive("Keyblade"))
						if(!src.Using)
							if(prob(5*usr.LimitCounter) && usr.SagaLevel < 8)
								usr.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/AntiForm)
								usr.LimitCounter=0
								return
							usr.LimitCounter+=1
				src.Trigger(usr)
		Master_Form
			FlashChange=1
			ABuffNeeded=list("Keyblade")
			ManaLeak=2
			ManaThreshold=1
			MakesSecondSword=1
			SwordClassSecond="Bokken"
			SwordAscensionSecond=2
			SwordIconSecond='KingdomKey.dmi'
			SwordXSecond=-32
			SwordYSecond=-32
			PowerMult=1.5
			TechniqueMastery=5
			Pursuer=1
			QuickCast=1
			Flicker=1
			DoubleStrike=1
			MovingCharge=1
			StrMult=1.25
			ForMult=1.25
			OffMult=1.25
			DefMult=1.25
			KenWave=1
			KenWaveIcon='SparkleYellow.dmi'
			KenWaveSize=3
			KenWaveX=105
			KenWaveY=105
			ActiveMessage="glows with limitless unity!"
			OffMessage="de-syncs their keyblades..."
			Cooldown=60
			verb/Master_Form()
				set category="Skills"
				if(!usr.BuffOn(src))
					if(usr.CheckActive("Keyblade"))
						if(!src.Using)
							if(prob(7.5*usr.LimitCounter) && usr.SagaLevel < 8)
								usr.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/AntiForm)
								usr.LimitCounter=0
								return
							src.SwordClassSecond=GetKeychainClass(usr.SyncAttached)
							src.SwordDamageSecond=GetKeychainDamage(usr.SyncAttached)
							src.SwordAccuracySecond=GetKeychainAccuracy(usr.SyncAttached)
							src.SwordDelaySecond=GetKeychainDelay(usr.SyncAttached)
							src.SwordElementSecond=GetKeychainElement(usr.SyncAttached)
							src.SwordIconSecond=GetKeychainIconReversed(usr.SyncAttached)
							passives = list("ManaLeak" = 2, "SwordAscensionSecond" = 2, "TechniqueMastery" = 10, "Pursuer" = 1, "QuickCast" = 4, "Flicker" = 1, "DoubleStrike" = 3, "DualCast" = 1, "MovementMastery" = 8, "MovingCharge" = 1)
							if(usr.SyncAttached=="Way To Dawn")
								passives["HolyMod"] = 3
								passives["AbyssMod"] = 3
								src.HolyMod=3
								src.AbyssMod=3
							else
								src.HolyMod=0
								src.AbyssMod=0
							if(usr.SyncAttached=="Fenrir")
								passives["SlayerMod"] = 1.5
								passives["FavoredPrey"] = "Races"
								src.Steady=8
							else
								src.Steady=0
							if(usr.SyncAttached=="Chaos Ripper")
								passives["Burning"] = 1
								passives["Scorching"] = 1
								passives["DarknessFlame"] = 1
								src.Burning=1
								src.Scorching=1
								src.DarknessFlame=1
							else
								src.Burning=0
								src.Scorching=0
								src.DarknessFlame=0
							if(usr.SyncAttached=="No Name")
								passives["StealsStats"] = 1
								src.StealsStats=0
							else
								src.StealsStats=0
							usr.LimitCounter+=2
				src.Trigger(usr)

		Final_Form
			FlashChange=1
			ABuffNeeded=list("Keyblade")
			ManaLeak=0.5
			ManaThreshold=1
			MakesSecondSword=1
			SwordClassSecond="Bokken"
			SwordAscensionSecond=2
			SwordIconSecond='KingdomKey.dmi'
			SwordXSecond=-32
			SwordYSecond=-32
			TechniqueMastery=10
			GodKi=0.25
			Intimidation=2
			AngerMult=2
			QuickCast=2
			Godspeed=2
			Pursuer=2
			Flicker=2
			Skimming=2
			DoubleStrike=1
			TripleStrike=1
			MovingCharge=1
			CalmAnger=1
			StrMult=1.25
			ForMult=1.25
			OffMult=1.25
			DefMult=1.25
			KenWave=1
			KenWaveIcon='SparkleFinal.dmi'
			KenWaveSize=3
			KenWaveX=105
			KenWaveY=105
			ActiveMessage="glows with limitless heart!"
			OffMessage="de-syncs with their heart..."
			Cooldown=10800
			verb/Final_Form()
				set category="Skills"
				if(!usr.BuffOn(src))
					if(usr.CheckActive("Keyblade"))
						if(!src.Using)
							src.SwordClassSecond=GetKeychainClass(usr.SyncAttached)
							src.SwordDamageSecond=GetKeychainDamage(usr.SyncAttached)
							src.SwordAccuracySecond=GetKeychainAccuracy(usr.SyncAttached)
							src.SwordDelaySecond=GetKeychainDelay(usr.SyncAttached)
							src.SwordElementSecond=GetKeychainElement(usr.SyncAttached)
							src.SwordIconSecond=GetKeychainIconReversed(usr.SyncAttached)
							passives = list("ManaLeak" = 0.5, "SwordAscensionSecond" = 2, "TechniqueMastery" = 10, "Pursuer" = 1, "QuickCast" = 2, "Flicker" = 1, "DualCast" = 1, "DoubleStrike" = 3, "MovingCharge" = 1, "TripleStrike" = 1, "CalmAnger" = 1, "GodKi" = 1)
							if(usr.SyncAttached=="Way To Dawn")
								passives["HolyMod"] = 3
								passives["AbyssMod"] = 3
								src.HolyMod=3
								src.AbyssMod=3
							else
								src.HolyMod=0
								src.AbyssMod=0
							if(usr.SyncAttached=="Fenrir")
								passives["SlayerMod"] = 1.5
								passives["FavoredPrey"] = "Races"
								src.Steady=8
							else
								src.Steady=0
							if(usr.SyncAttached=="Chaos Ripper")
								passives["Burning"] = 1
								passives["Scorching"] = 1
								passives["DarknessFlame"] = 1
								src.Burning=1
								src.Scorching=1
								src.DarknessFlame=1
							else
								src.Burning=0
								src.Scorching=0
								src.DarknessFlame=0
							if(usr.SyncAttached=="No Name")
								passives["StealsStats"] = 1
								src.StealsStats=0
							else
								src.StealsStats=0
							usr.LimitCounter+=3
				src.Trigger(usr)
		Denjin_Renki
			ForMult=2
			passives = list("SoftStyle" = 2, "StunningStrike" = 1, "SpiritHand" = 2, "Paralyzing" = 1)
			IconLock='Ripple Arms.dmi'
			LockX=0
			LockY=0
			TimerLimit=60
			Cooldown=120
			ActiveMessage="projects a disciplined aura as their fists crackle with lightning!"
			OffMessage="releases their tremendous focus..."
			adjust(mob/p)
				passives = list("SoftStyle" = p.SagaLevel, "StunningStrike" = p.SagaLevel/2, "SpiritHand" = p.SagaLevel / 1.25, "Paralyzing" = p.SagaLevel/2)
			verb/Denjin_Renki()
				set category="Skills"
				if(!usr.BuffOn(src))
					adjust(usr)
				src.Trigger(User=usr, Override=TRUE)

		King_Of_Braves
			Cooldown = 1
			PowerGlows=list(1,0.8,0.8, 0,1,0, 0.8,0.8,1, 0,0,0)
			passives = list("Tenacity" = 1, "UnderDog" = 0.5, "Persistence" = 1)
			ActiveMessage="surrounds their body in a faint green aura!"
			OffMessage="deactivates the green energy..."
			var/list/pu_stats = list()
			proc/setupVars(mob/player)
				src.ActiveMessage="surrounds their body in a faint green aura!"
				passives = list("Tenacity" = player.SagaLevel, "UnderDog" = player.SagaLevel/2, "Persistence" = player.SagaLevel)
				if(player.SagaLevel>=1)
					ActiveMessage="draws power from their courage as they pulse with green light!"
				if(player.SagaLevel>=2)
					AutoAnger=1
					passives = list("Tenacity" = player.SagaLevel, "UnderDog" = player.SagaLevel/2, "Persistence" = player.SagaLevel, "AngerThreshold" = 1.75)
				if(player.SagaLevel>=5)
					ActiveMessage="roars with a heart full of courage, they are the embodiement of courage itself!"
					AngerMult=2
				if(!player.BuffOn(src))
					StrMult = 1.15 + (0.05 * usr.SagaLevel)
					EndMult = 1.15 + (0.05 * usr.SagaLevel)
					ForMult= 1.05 + (0.025 * usr.SagaLevel)
					if(BuffName == "Genesic Brave")
						StrMult=1.1 + (0.1 * usr.SagaLevel) // gives 1.4 @ t3 which is .1 more than above
						EndMult=1.1 + (0.1 * usr.SagaLevel)
						ForMult=1.1 + (0.1 * usr.SagaLevel)
						passives["PureReduction"] = usr.SagaLevel-2
						passives["PureDamage"] = usr.SagaLevel/3
			verb/Bravery()
				set category="Skills"
				setupVars(usr)
				ExhaustedMessage = " begins fighting for their life!"
				DesperateMessage = " calls upon the of bravery for one final push!"
				Trigger(usr, TRUE)


			// verb/Broken_Brave()
			// 	set category="Skills"
			// 	if(istype(usr.SpecialBuff, type) && usr.SpecialBuff.BuffName!="Broken Brave")
			// 		Trigger(usr, TRUE)
			// 		usr<<"You swap to Broken Brave!"
			// 		BuffName="Broken Brave"
			// 		setupVars(usr)
			// 		TimerLimit = 0
			// 		StrMult=1.15 + (0.05 * usr.SagaLevel)
			// 		EndMult=1 + (0.025 * usr.SagaLevel)
			// 		ForMult=1.15 + (0.05 * usr.SagaLevel)
			// 		ExhaustedMessage = " begins fighting fiercely like a lion!"
			// 		DesperateMessage = " calls upon the power of Destruction for one final push!"
			// 		Trigger(usr, TRUE)
			// 	else
			// 		setupVars(usr)
			// 		Trigger(usr)
			// verb/Protect_Brave()
			// 	set category="Skills"
			// 	if(istype(usr.SpecialBuff, type) && usr.SpecialBuff.BuffName!="Protect Brave")
			// 		Trigger(usr, TRUE)
			// 		usr<<"You swap to Protect Brave!"
			// 		BuffName="Protect Brave"
			// 		setupVars(usr)
			// 		StrMult=1 + (0.025 * usr.SagaLevel)
			// 		EndMult=1.15 + (0.05 * usr.SagaLevel)
			// 		ForMult=1 + (0.025 * usr.SagaLevel)
			// 		DefMult=1.15 + (0.05 * usr.SagaLevel)
			// 		ExhaustedMessage = " begins fighting defensively like a machine!"
			// 		DesperateMessage = " calls upon the power of Protection for one final push!"
			// 		Trigger(usr, TRUE)
			// 	else
			// 		setupVars(usr)
			// 		Trigger(usr)
			verb/Genesic_Brave()
				set category="Skills"
				if(usr.SagaLevel<3 && usr.Health>25)
					return
				if(usr.SagaLevel<6 && usr.Health>50)
					return
				if(usr.SpecialBuff&&usr.SpecialBuff.BuffName!="Genesic Brave")
					Trigger(usr, TRUE)
					BuffName="Genesic Brave"
					setupVars(usr)
					ExhaustedMessage = " begins fighting with the power of a god!"
					DesperateMessage = " calls upon the power of Creation for one final push!"
					Trigger(usr, TRUE)
				else
					setupVars(usr)
					Trigger(usr)

		OverSoul
			Cooldown=-1
			NeedsSword=1
			StrMult=1.5
			OffMult=1.3
			DefMult=1.2
			SpdMult=2
			Transform="Weapon"
			Slotless = TRUE
			SpecialSlot = FALSE
			ABuffNeeded=list("Soul Resonance")
			verb/OverSoul()
				set category="Skills"
				if(usr.BoundLegend=="Caledfwlch")
					HealthHeal=0.25
					WoundHeal=1
					EnergyHeal=1
					FatigueHeal=1
					ManaHeal=1
					StableHeal=1
					OffMessage="loses the sheath once again..."
				else
					OffMessage="seals the blade once again..."
				if(!usr.BuffOn(src) && !src.Using)
					usr.Stasis=7
				src.Trigger(usr)

		Sharingan
			OffMult=1.2
			DefMult=1.3
			passives = list("Maki" = 1, "PUSpike" = 10)
			Maki = 1
			// CalmAnger = 1
			AngerPoint = 10
			PUSpike=10
			IconLock='SharinganEyes.dmi'
			LockX=0
			LockY=0
			ActiveMessage="is filled with cold rage as their eyes turn red and one tomoe appears in their iris!"
			OffMessage="relaxes their hatred as their eyes return to a normal coloration..."
			verb/Sharingan()
				set category="Skills"
				if(!usr.BuffOn(src))
					switch(usr.SagaLevel)
						if(1)
							src.OffMult=1.2
							src.DefMult=1.3
							src.SureDodgeTimerLimit=40
							passives = list("Maki" = 1, "PUSpike" = 10, "Flow" = 1, "FatigueDrain"  = 0.1)
							src.Instinct=0
							src.Flow=1
							src.FatigueDrain=0.1
							AngerPoint = 15
							ActiveMessage="is filled with cold rage as their eyes turn red and one tomoe appears in their iris!"
						if(2)
							src.OffMult=1.2
							src.DefMult=1.3
							src.SureDodgeTimerLimit=35
							passives = list("Maki" = 1, "PUSpike" = 20, "Flow" = 1, "Instinct" = 1, "FatigueDrain"  = 0.05)
							src.Instinct=1
							src.Flow=1
							src.FatigueDrain=0.05
							PUSpike=20
							AngerPoint = 20
							ActiveMessage="is filled with cold rage as their eyes turn red and two tomoe appear in their iris!"
					if(usr.SagaLevel>=3)
						if(usr.SharinganEvolution=="Resolve")
							OffMult=1.4
							DefMult=1.4
							SureDodgeTimerLimit=25
							passives = list("Maki" = 1, "PUSpike" = 20, "Flow" = 2, "Instinct" = 2, "LikeWater" = 2)
							LikeWater=2
							Instinct=2
							Flow=2
							src.FatigueDrain=0
							PUSpike=20
						else
							src.OffMult=1.3
							src.DefMult=1.3
							src.SureDodgeTimerLimit=30
							passives = list("Maki" = 1, "PUSpike" = 15, "Flow" = 2, "Instinct" = 2)
							src.Instinct=2
							src.Flow=1
							src.FatigueDrain=0
						AngerPoint = 25
						ActiveMessage="is filled with blinding hatred as their eyes turn red and three tomoe appear in their iris!"
				src.Trigger(usr)

		Symbiote_Evolution
			EnergyMult=1.5
			RegenMult=1.25
			RecovMult=1.25
			passives = list("Flow" = 2)
			BuffTechniques = list("/obj/Skills/Buffs/SlotlessBuffs/Regeneration")
			ActiveMessage="forces their symbiote out!"
			OffMessage="restrains their symbiotic companion..."
			verb/Total_Symbiosis()
				set category="Skills"
				src.Trigger(usr)
				if(usr.BuffOn(src))
					for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Symbiote_Infection/s in usr)
						s.NeedsHealth=101
						s.NeedsVary=0
						s.TooMuchHealth=0
						s.VaizardShatter=0
						s.Curse=0
				else
					for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Symbiote_Infection/s in usr)
						s.NeedsHealth=25
						s.NeedsVary=1
						s.TooMuchHealth=75
						s.VaizardShatter=1
						if(usr.AscensionsAcquired>=2)
							s.Curse=1

	SlotlessBuffs
		Slotless=1
//Racials
		blobBuff
			Cooldown = 150
			UnrestrictedBuff = 1
			ActiveMessage="begins to absorb their fallen pieces!"
			OffMessage="stops absorbing their fallen pieces..."
			DeleteOnRemove = TRUE
			New(mob/Players/p, val, buff)
				..()
				if(!val)
					world.log<<"Error in blobBuff/New() || [src],[p], [val], [buff], [loc], [x],[y],[z]"
					del src
					return
				var/asc = p.AscensionsAcquired
				var/time = 8 + asc
				if(buff)
					passives = list("[buff]" = 1)
					current_passives = passives
				else
					buff = "Super"
				HealthHeal = (val / time)* world.tick_lag
				StableHeal = 1
				TimerLimit = time
				name = "Temp [buff] Buff"
				BuffName = "[buff] Blob [rand(1,20)]"





		Regeneration
			UnrestrictedBuff=1
			Cooldown=-1
			CooldownStatic=1
			CooldownScaling=1
			FatigueCost = 15
			HealthHeal = 0.5
			StableHeal = 1 // don't take recov into account
			TimerLimit = 20
			ActiveMessage="begins to regenerate rapidly!"
			OffMessage="stops regenerating..."
			proc/getRaceModifier(mob/p)
				. = 1
				switch(p.race.name)
					if("Majin")
						switch(p.Class)
							if("Super")
								return 1
							if("Innocent")
								return 1.15
							if("Unhinged")
								return 1.25
						return 1
					if("Demon")
						return 1.25
					if("Namekian")
						return 0.8
				if(p.Secret == "Werewolf" || p.Secret == "Vampire")
					return 1.1

			proc/getRegenRate(mob/p)
				var/baseHeal = 5
				var/perMissing = 0.05
				var/missingPerAsc = 0.03
				var/raceDivisor = 30
				StableHeal=1


				if(!altered)
					if(p.Potential <= ASCENSION_ONE_POTENTIAL)
						var/raceModifier = getRaceModifier(p)
						HealthHeal = ((glob.REGEN_ASC_ONE_HEAL * raceModifier)/TimerLimit)
					else
						var/raceModifier = getRaceModifier(p)
						var/asc = p.AscensionsAcquired
						var/amt = (baseHeal + raceModifier) + ( (((perMissing + (missingPerAsc * asc)) + (raceModifier/raceDivisor))) * (100 - p.Health))
						var/divider = asc * raceModifier > 0 ? asc * raceModifier : 1
						var/time = 10 / divider
						HealthHeal = (amt / time) * world.tick_lag
						WoundHeal = HealthHeal/2
						TimerLimit = time             // ticks per regen
						EnergyCost = amt / 4
						FatigueCost = amt / 4
			verb/Regenerate()
				set category="Skills"
				if(!usr.BuffOn(src))
					getRegenRate(usr)
				src.Trigger(usr)
				if(usr.BuffOn(src))
					if(!usr.Sheared)
						if(usr.BPPoisonTimer>1&&usr.BPPoison<1)
							usr.BPPoison=1
							usr.BPPoisonTimer=1
							OMsg(usr, "[usr] regenerates all serious injury!")
						if(usr.MortallyWounded)
							usr.MortallyWounded-=1
							if(usr.MortallyWounded<0)
								usr.MortallyWounded=0
							OMsg(usr, "[usr] forces their bleeding to slow down!")
						if(usr.SenseRobbed)
							usr.SenseRobbed=0
							usr.TsukiyomiTime=1
							OMsg(usr, "[usr] regains use of their senses!")
						if(src.RegenerateLimbs)
							if(usr.Maimed)
								usr.Maimed-=1
								if(usr.Maimed<0)
									usr.Maimed=0
								OMsg(usr, "[usr] recovers from being maimed!")

		Elemental_Infusion
			ActiveMessage="infuses their weaponry with elemental energy!"
			EndYourself=1
			Cooldown=10800
			verb/Elemental_Infusion()
				set category="Skills"
				if(!usr.EquippedSword()&&!usr.EquippedStaff())
					usr << "There's nothing to infuse."
					return
				if(!usr.Attunement)
					usr << "You aren't attuned to any element to infuse into your weapon."
					return
				if(!usr.BuffOn(src))
					var/obj/Items/Sword/s
					var/obj/Items/Enchantment/Staff/s2
					if(usr.EquippedSword())
						NeedsSword=1
						s=usr.EquippedSword()
					else
						NeedsSword=0
					if(usr.EquippedStaff())
						NeedsStaff=1
						s2=usr.EquippedStaff()
					else
						NeedsStaff=0

					if(s && s.Element!="Ultima")
						s.Element=usr.Attunement
					if(s2 && s2.Element!= "Ultima")
						s2.Element=usr.Attunement
				src.Trigger(usr)

		Camouflage
			PULock=1
			passives = list("PULock" = 1)
			AllowedPower=0.5
			Invisible=20
			Cooldown=150
			ActiveMessage="blends in with their surroundings..."
			OffMessage="reveals themselves!"
			verb/Camouflage()
				set category="Skills"
				src.Trigger(usr)
		SaiyanBeyondGod
			BuffName = "Beyond God"
			SignatureTechnique=3
			Mastery=-1
			UnrestrictedBuff=1
			StrMult=1.2
			ForMult=1.2
			EndMult=1.2
			SpdMult=1.4
			DefMult=1.4
			passives = list("GodKi" = 0.5, "EnergyGeneration" = 5, "Godspeed" = 4, "Flow" = 5,  "BuffMastery" = 5, "PureDamage" = 1, "PureReduction" = 2, \
								"BackTrack" = 2 , "StunningStrike" = 3, "Sunyata" = 5)
			PUSpeedModifier=2
			FlashChange=1
			KenWave=5
			KenWaveSize=1
			KenWaveIcon='KenShockwaveDivine.dmi'
			ActiveMessage="channels their divinity!"
			OffMessage="releases their divine form..."
			verb/Beyond_God()
				set category="Skills"
				if(!usr.BuffOn(src))
					if(usr.transActive>0)
						src << "You can't handle transforming while using divinity."
						return
					usr.transActive = 3
				src.Trigger(usr)
				if(!usr.BuffOn(src) && usr.transActive != 4)
					usr.transActive = 0
		Saiyan_Dominance
			AutoAnger=1
			passives = list("PridefulRage" = 1)
			PridefulRage=1
			TextColor=rgb(230, 230, 100)
			Cooldown=300
			NeedsHealth = 75
			StrTax=0.1
			SpdTax=0.05
			EndTax=0.1
			ActiveMessage="displays their superiority by crushing those who rose their hand at them!"
			OffMessage="ends their ruthless display of superiority..."
			adjust(mob/user)
				var/zenkaiLevel = user.AscensionsAcquired
				EnergyThreshold = 25-(5*zenkaiLevel)
				TimerLimit = 50 + (5 * zenkaiLevel)
				var/healthDiff = 0
				//scales off how bad your losing
				if(user.Target && ismob(user.Target))
					healthDiff = user.Target.Health-user.Health
				switch(healthDiff)
					if(-100 to 2)
						PowerMult = 1
					if(3 to 15)
						PowerMult = 1.05
					if(16 to 25)
						PowerMult = 1.1
					if(26 to 50)
						PowerMult = 1.15
					if(51 to 75)
						PowerMult = 1.2
					if(76 to 100)
						PowerMult = 1.3
			verb/Saiyan_Dominance()
				set category="Skills"
				if(!usr.BuffOn(src))
					if(usr.CheckSlotless("Great Ape"))
						usr << "Your precision is lacking in beastly form!"
						return
					src.adjust(usr)
				src.Trigger(usr)

		Saiyan_Grit
			TextColor=rgb(230, 230, 100)
			Cooldown=300
			EndTax=0.25
			ActiveMessage="decides to stand their ground under the rain of attacks!!"
			OffMessage="finally gives in to the pain..."
			adjust(mob/user)
				var/zenkaiLevel = user.AscensionsAcquired/10
				passives = list("Adrenaline" = 1)
				//scales off how low hp is
				PowerMult = clamp((1+(zenkaiLevel/2))/user.Health,1, 1.5)
			verb/Saiyan_Grit()
				set category="Skills"
				if(!usr.BuffOn(src))
					if(usr.CheckSlotless("Great Ape"))
						usr << "Your precision is lacking in beastly form!"
						return
					if(usr.DefianceCounter<6)
						usr << "Your rage hasn't spiked high enough yet!"
						return
					else
						src.VaizardHealth=(usr.DefianceCounter)
						src.VaizardShatter=1
						src.FINISHINGMOVE=1
						src.DefianceRetaliate=1
						adjust(usr)
				src.Trigger(usr)

		Saiyan_Soul
			EnergyThreshold=30
			TextColor=rgb(230, 230, 100)
			Cooldown=300
			StrTax=0.05
			RecovTax=0.1
			passives = list("TechniqueMastery" = 1)
			ActiveMessage="pushes themselves even further to overwhelm their opponent!!"
			OffMessage="releases their power spike, incredibly exhausted..."
			adjust(mob/user)
				var/zenkaiLevel = user.AscensionsAcquired
				passives = list()
				passives["TechniqueMastery"] = 0.5*zenkaiLevel
				passives["MovementMastery"] = 2*zenkaiLevel
				var/passiveLimit = zenkaiLevel
				var/passiveNumber = 0
				for(var/x in user.Target.StyleBuff.passives)
					if(passiveNumber>=passiveLimit+1)
						continue
					// passives
					passives[x] += clamp(user.Target.StyleBuff.passives[x], 0.0001, passiveLimit)
					passiveNumber++
			verb/Saiyan_Soul()
				set category="Skills"
				if(!usr.BuffOn(src))
					if(usr.CheckSlotless("Great Ape"))
						usr << "Your precision is lacking in beastly form!"
						return
					if(usr.AdaptationCounter<1)
						usr << "You didn't get a good enough of a read on your opponent yet!"
						return
					src.adjust(usr)
				src.Trigger(usr)


		Spirit_Form
			SpiritForm=1
			ActiveMessage="shifts into their spiritual body!"
			OffMessage="becomes fully physical once more..."
			ManaDrain = 0.1
			passives = list("ManaLeak" = 2, "SpiritForm" = 1, "MovementMastery" = 1, "ManaStats" = 0.25, "TechniqueMastery" = -2, "MartialMagic" = 1, "ManaGeneration" = -2, "FatigueLeak" = 3, "Cryokenesis" = 1)
			ManaLeak = 2
			ManaThreshold = 40
			Cooldown=1
			adjust(mob/p)
				passives["Cryokenesis"] = 1 + p.AscensionsAcquired
			verb/Spirit_Form()
				set category="Skills"
				if(!usr.BuffOn(src))
					if(usr.Form1Base)
						src.IconReplace=1
						src.icon=usr.Form1Base
					if(usr.Form1Hair)
						src.HairLock=usr.Form1Hair
						src.HairX=usr.Form1HairX
						src.HairY=usr.Form1HairY
					if(usr.Form1Overlay)
						src.IconLock=usr.Form1Overlay
						src.LockX=usr.Form1OverlayX
						src.LockY=usr.Form1OverlayY
					if(usr.Form1TopOverlay)
						src.TopOverlayLock=usr.Form1TopOverlay
						src.TopOverlayX=usr.Form1TopOverlayX
						src.TopOverlayY=usr.Form1TopOverlayY
					if(usr.Form1Aura)
						src.AuraLock=usr.Form1Aura
						src.AuraX=usr.Form1AuraX
						src.AuraY=usr.Form1AuraY
					if(usr.Form1ActiveText)
						if(src.ActiveMessage!=usr.Form1ActiveText)
							src.ActiveMessage=usr.Form1ActiveText
					if(usr.Form1RevertText)
						if(src.OffMessage!=usr.Form1RevertText)
							src.OffMessage=usr.Form1RevertText
				src.Trigger(usr)

//Skill Tree
		Ki_Armanent
			Copyable=3
			SkillCost=0
			NoSword=1
			NoStaff=1
			passives = list("HybridStrike" = 0.5)
			HybridStrike = 0.5
			EnergyLeak=2
			Cooldown=5
			IconLock='Ki-Blade.dmi'
			OffMessage="dispels their Ki armanent..."
			TextColor="#FF66CC"
			verb/Customize_Ki_Armanent()
				set category="Other"
				set name="Customize: Ki Armanent"
				if(usr.BuffOn(src))
					usr << "You can't customize ki armanent while using it!"
					return
				src.IconLock=input(usr, "What armanent icon do you want to use?", "Customize Ki Armanent") as icon|null
				src.LockX=input(usr, "What pixel x offset do you want to use?", "Customize Ki Armanent") as num|null
				src.LockY=input(usr, "What pixel y offset do you want to use?", "Customize Ki Armanent") as num|null
				if(src.IconLock==null)
					src.IconLock='Ki-Blade.dmi'
					src.LockX=0
					src.LockY=0
			verb/Ki_Armanent()
				set category="Skills"
				src.ActiveMessage="makes a shell of Ki around their hand!"
				if(usr.StyleActive=="Black Leg" || usr.StyleActive=="Devil Leg")
					src.ActiveMessage="makes a shell of Ki around their foot!"
				src.Trigger(usr)


		Ki_Blade
			Copyable=3
			SkillCost=0
			NoSword=1
			NoStaff=1
			KiBlade=1
			passives = list("KiBlade" = 1, "SpiritSword" = 0.25, "EnergyLeak" = 2)
			SpiritSword=0.5
			EnergyLeak=2
			Cooldown=5
			IconLock='Ki-Blade.dmi'
			OffMessage="dispels their Ki blade..."
			TextColor="#FF66CC"
			verb/Customize_Ki_Blade()
				set category="Other"
				set name="Customize: Ki Blade"
				if(usr.BuffOn(src))
					usr << "You can't customize ki blade while using it!"
					return
				src.IconLock=input(usr, "What blade icon do you want to use?", "Customize Ki Blade") as icon|null
				src.LockX=input(usr, "What pixel x offset do you want to use?", "Customize Ki Blade") as num|null
				src.LockY=input(usr, "What pixel y offset do you want to use?", "Customize Ki Blade") as num|null
				if(src.IconLock==null)
					src.IconLock='Ki-Blade.dmi'
					src.LockX=0
					src.LockY=0
			verb/Ki_Blade()
				set category="Skills"
				src.ActiveMessage="sharpens a shell of Ki around their hand!"
				if(usr.StyleActive=="Black Leg" || usr.StyleActive=="Devil Leg")
					src.ActiveMessage="sharpens a shell of Ki around their foot!"
				src.Trigger(usr)
		//TODO ADD KI ARMANENT

		Ki_Shield
			Copyable=3
			SkillCost=0
			passives = list("Deflection" = 1, "NoDodge" = 1)
			Deflection=1
			NoDodge=1
			TimerLimit=10
			EnergyCost = 10
			Cooldown=90
			IconLock='Android Shield.dmi'
			IconLockBlend=2
			IconLayer=-1
			IconApart=1
			OverlaySize=1.2
			ActiveMessage="creates a shell of Ki around their body!"
			OffMessage="lowers their shield..."
			verb/Customize_Ki_Shield()
				set category="Other"
				set name="Customize: Ki Shield"
				if(usr.BuffOn(src))
					usr << "You can't customize ki shield while using it!"
					return
				src.IconLock=input(usr, "What shield icon do you want to use?", "Customize Ki Shield") as icon|null
				src.LockX=input(usr, "What pixel x offset do you want to use?", "Customize Ki Shield") as num|null
				src.LockY=input(usr, "What pixel y offset do you want to use?", "Customize Ki Shield") as num|null
			verb/Ki_Shield()
				set category="Skills"
				src.Trigger(usr)
		Ki_Armor

//TODO LOOK OVER MAGIC
//TODO ADD A MAGIC LEVEL VARIABLE
		Magic
			MagicNeeded=1

			Magic_Barrier
				SkillCost=0
				passives = list("Deflection" = 1)
				Deflection=1
				DefMult = 0.4
				TimerLimit=0
				Cooldown=30
				ManaCost = 8
				IconLock='zekkai.dmi'
				IconLockBlend=2
				IconLayer=-1
				IconApart=1
				OverlaySize=1.4
				ActiveMessage="makes a shield of magic!"
				OffMessage="lowers their shield..."
				adjust(mob/p)
					var/magicLevel = p.getTotalMagicLevel()
					ManaDrain = 1.2 - (0.04 * magicLevel)
					passives["Deflection"] = 1 + round(magicLevel / 10)
					if(magicLevel >= 10)
						passives["BulletKill"] = 1
				verb/Ki_Shield()
					set category="Skills"
					src.Trigger(usr)

			Hold_PersonApply
				MagicNeeded = 0
				CrippleAffected = 1
				StunAffected = 4
				InstantAffect = 1
				TimerLimit = 15
				ActiveMessage="is held in place by magic!"
				OffMessage="has been released by their magical restraints!"
				adjust(mob/p)
					var/magicLevel = p.getTotalMagicLevel()
					StunAffected = round(1 + (magicLevel / 4))
					CrippleAffected = round(magicLevel * 2)
					TimerLimit = round(5 + (magicLevel / 2))
			Hold_Person
				Copyable=0
				ManaCost=15
				TimerLimit = 15
				AffectTarget=1
				Range = 25
				Cooldown = 120
				applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/Magic/Hold_PersonApply
				ActiveMessage="casts a great magic to hold their target in place!"
				OffMessage="releases the magic!!"
				adjust(mob/p)
					var/magicLevel = p.getTotalMagicLevel()
					Range = 10 + magicLevel
					// StunAffected = round(1 + (magicLevel / 4))
					// CrippleAffected = round(magicLevel * 2)
					TimerLimit = round(5 + (magicLevel / 2))
				verb/Hold_Person()
					set category="Skills"
					if(!altered)
						adjust(usr)
						applyToTarget?:adjust(usr)
					src.Trigger(usr)

			Haste
				Cooldown = 120
				Copyable = 0
				ManaCost = 10
				TimerLimit = 10
				ActiveMessage = "uses magic to push themselves through time!"
				OffMessage = "slows down to a normal pace..."
				adjust(mob/p)
					NoForcedWhiff = 1 // make it so people cant force whiff u
					var/magicLevel = p.getTotalMagicLevel()
					passives = list("NoForcedWhiff" = 1, "FluidForm" = 1, "Godspeed" = clamp(round(magicLevel/10), 1, 2), "DoubleStrike" = 1, \
					"BlurringStrikes" = 1)
					TimerLimit = round(15 + (magicLevel * 1.5))
					FluidForm = 1
					SpdMult = 1 + (magicLevel * 0.01)
					Godspeed = round(magicLevel / 10)
					DoubleStrike = 1
					ManaDrain = 0.01
					SpdTax = 0.03
				verb/Haste()
					set category="Skills"
					if(!altered)
						adjust(usr)
					src.Trigger(usr)

			Reverse_Wounds
				Copyable = 0
				ManaCost = 10
				TimerLimit = 25
				ActiveMessage = "uses magic to reverse their wounds!"
				OffMessage = "'s wounds stop healing backwards..."
				StableHeal = 1
				Cooldown = -1
				// this is just regen bro LOL!
				adjust(mob/p)
					var/magicLevel = 1 + p.getTotalMagicLevel()
					var/base = round(magicLevel / 8)
					var/perMissing = 0.01
					var/amount = round(base + (abs(p.Health-100) * perMissing))
					TimerLimit = 25 * (1 - magicLevel / 40)
					HealthHeal = (amount / (TimerLimit * world.tick_lag))

				verb/Reverse_Wounds()
					set category="Skills"
					if(!altered)
						adjust(usr)
					src.Trigger(usr)



			Reinforce_Object
				ElementalClass="Earth"
				SkillCost=TIER_1_COST
				Copyable=1
				ManaCost=5
				TimerLimit=30
				Cooldown=70
				verb/Reinforce_Weapon()
					set category="Skills"
					var/magicLevel = usr.getTotalMagicLevel()
					if(magicLevel >= 1)
						magicLevel = 1
					if(!usr.BuffOn(src))
						if(usr.Saga=="Unlimited Blade Works")
							if(!usr.getAriaCount())
								usr << "You need your circuits on to use this!"
								return
							TimerLimit = 20 * usr.SagaLevel
							ManaCost = usr.getUBWCost(0.5)
							if(usr.EquippedSword()&&usr.EquippedStaff())
								passives = list("SwordAscension" = usr.getAriaCount()/8, "StaffAscension" = usr.getAriaCount()/8)
								ActiveMessage="feeds mana into their sword and staff at once!"
								OffMessage="cuts off the flow of mana to their weapons..."
							else if(usr.EquippedSword())
								passives = list("SwordAscension" = usr.getAriaCount()/4, "StaffAscension" = 0)
								ActiveMessage="feeds mana into their sword to reinforce it!"
								OffMessage="cuts off the flow of mana to their sword..."
							else if(usr.EquippedStaff())
								passives = list("StaffAscension" = usr.getAriaCount()/4,"SwordAscension" = 0)
								ActiveMessage="feeds mana into their magic focus to reinforce it!"
								OffMessage="stops focusing their mana flow..."
							else
								src << "You can't use this without anything to reinforce!"
								return
						else
							if(usr.EquippedSword()&&usr.EquippedStaff())
								passives = list("SwordAscension" = 0.5, "StaffAscension" = 0.5)
								src.SwordAscension=0.5
								src.StaffAscension=0.5
								src.ManaCost=10
								ActiveMessage="feeds mana into their sword and staff at once!"
								OffMessage="cuts off the flow of mana to their weapons..."
							else if(usr.EquippedSword())
								passives = list("SwordAscension" = 1)
								src.SwordAscension=1
								src.StaffAscension=0
								src.ManaCost=10
								ActiveMessage="feeds mana into their sword to reinforce it!"
								OffMessage="cuts off the flow of mana to their sword..."
							else if(usr.EquippedStaff())
								passives = list("StaffAscension" = 1)
								src.SwordAscension=0
								src.StaffAscension=1
								src.ManaCost=10
								ActiveMessage="feeds mana into their magic focus to reinforce it!"
								OffMessage="stops focusing their mana flow..."
							else
								src << "You can't use this without anything to reinforce!"
								return
					src.Trigger(usr)
			Broken_Phantasm
				ElementalClass="Earth"
				SkillCost=TIER_1_COST
				PreRequisite=list("/obj/Skills/Buffs/SlotlessBuffs/Magic/Reinforce_Object")
				Copyable=2
				passives = list("SwordAscension" = 1, "StaffAscension" = 1, "PureDamage" = 10)
				SwordAscension=1
				StaffAscension=1
				KillSword=1
				PureDamage=10
				ExplosiveFinish=3
				Destructive=-1
				ExplosiveFinishIntensity=10
				ManaCost=10
				PhysicalHitsLimit=1
				SpiritHitsLimit=1
				TextColor=rgb(180, 120, 60)
				Cooldown=30
				ActiveMessage="overcharges their weapon with a ridiculous amount of mana!"
				OffMessage="can hold their weapon no longer; it explodes!"
				verb/Broken_Phantasm()
					set category="Skills"
					if(!usr.EquippedSword()&&!usr.EquippedStaff())
						usr << "There's nothing to infuse."
						return
					else
						if(usr.EquippedSword())
							NeedsSword=1
						else
							NeedsSword=0
						if(usr.EquippedStaff())
							NeedsStaff=1
						else
							NeedsStaff=0
					if(!usr.BuffOn(src))
						if(usr.Attunement)
							src.ElementalEnchantment=usr.Attunement
						if(usr.Saga == "Unlimited Blade Works")
							Cooldown = 30-usr.SagaLevel
							PhysicalHitsLimit = max(1, usr.getAriaCount()/2)
							SpiritHitsLimit = max(1, usr.getAriaCount()/2)
							passives["ManaGeneration"] = 4
							passives["PureDamage"] = 10/PhysicalHitsLimit
					src.Trigger(usr)
			Reinforce_Self
				ElementalClass="Earth"
				SkillCost=TIER_1_COST
				Copyable=3
				PreRequisite=list("/obj/Skills/Buffs/SlotlessBuffs/Magic/Broken_Phantasm")
				PureDamage=1
				PureReduction=1
				PhysicalHitsLimit = 10
				ManaCost=15
				ManaLeak=2
				TimerLimit=30
				Cooldown=90
				ActiveMessage="feeds mana into their limbs to reinforce them!"
				OffMessage="stops overloading their limbs with mana..."
				verb/Reinforce_Self()
					set category="Skills"
					if(!altered)
						if(usr.Saga == "Unlimited Blade Works")
							ManaCost = usr.getUBWCost(0.8)
							passives = list("PureDamage" = max(1,usr.getAriaCount()/3), "PureReduction" = max(1,usr.getAriaCount()/3))
							PhysicalHitsLimit = 1 + (usr.getAriaCount() * usr.SagaLevel)
							SpiritHitsLimit = 1 + (usr.getAriaCount() * usr.SagaLevel)
							TimerLimit = 15 * usr.SagaLevel
						else
							ManaCost = 15
							var/magicLevel = usr.getTotalMagicLevel()
							if(magicLevel >= 10)
								magicLevel = 10
							passives = list("PureDamage" = 1, "PureReduction" = 1)
							PhysicalHitsLimit = 5 + magicLevel/2
							SpiritHitsLimit = 5 + magicLevel/2
							TimerLimit = 10 + magicLevel

					src.Trigger(usr)

			Water_Walk
				ElementalClass="Wind"
				SkillCost=TIER_1_COST
				Copyable=1
				ManaCost=5
				TimerLimit=15
				passives = list("WaterWalk" = 1)
				WaterWalk=1
				TextColor=rgb(0, 255, 255)
				ActiveMessage="uses a spell to grant themselves the miracle of waterwalk!"
				OffMessage="dissipates their miraculous walk..."
				Cooldown=30
				verb/Water_Walk()
					set category="Utility"
					var/magicLevel = usr.getTotalMagicLevel()
					if(magicLevel >= 10)
						magicLevel = 10
					TimerLimit = 15+magicLevel
					src.Trigger(usr)
			Swift_Walk
				ElementalClass="Wind"
				SkillCost=TIER_1_COST
				Copyable=2
				PreRequisite=list("/obj/Skills/Buffs/SlotlessBuffs/Magic/Water_Walk")
				ManaCost=3
				passives = list("WaterWalk" = 1, "Godspeed" = 1)
				WaterWalk=1
				Godspeed=1
				TimerLimit=20
				KenWave=1
				KenWaveIcon='Magic Time circle.dmi'
				KenWaveSize=5
				KenWaveX=105
				KenWaveY=105
				ActiveMessage="casts a spell to become fleet on foot!"
				OffMessage="dissipates their enchanted speed..."
				Cooldown=45
				verb/Swift_Walk()
					set category="Utility"
					var/magicLevel = usr.getTotalMagicLevel()
					if(magicLevel >= 10)
						magicLevel = 10
					TimerLimit = 20+magicLevel
					src.Trigger(usr)
			Wind_Walk
				ElementalClass="Wind"
				SkillCost=TIER_1_COST
				Copyable=3
				PreRequisite=list("/obj/Skills/Buffs/SlotlessBuffs/Magic/Swift_Walk")
				ManaCost=8
				TimerLimit=30
				passives = list("Skimming" = 1, "Godspeed" = 3)
				Skimming=1
				Godspeed=3
				TextColor=rgb(140, 255, 140)
				KenWave=1
				KenWaveIcon='Magic Time circle.dmi'
				KenWaveSize=5
				KenWaveX=105
				KenWaveY=105
				ActiveMessage="uses a spell to give themselves the alacrity of the wind!"
				OffMessage="dissipates their aerial speed..."
				Cooldown=60
				verb/Wind_Walk()
					set category="Utility"
					var/magicLevel = usr.getTotalMagicLevel()
					if(magicLevel >= 10)
						magicLevel = 10
					TimerLimit = 25+magicLevel
					src.Trigger(usr)

			Magic_Trick
				ElementalClass="Water"
				SkillCost=TIER_1_COST
				Copyable=1
				EndYourself=1
				ActiveMessage="performs a stunning magic trick!"
				ManaCost=5
				Cooldown=30
				verb/Magic_Trick()
					set category="Utility"
					if(!src.Using)
						for(var/mob/Players/m in oviewers(5,usr))
							if(prob(20))
								m.AddConfusing(20)
								OMsg(m, "[m] tries to work out the logistics of the trick! How can this be?!")
							else if(prob(10))
								Stun(m,5)
								OMsg(m, "[m] is stunned by the trick!")
							/*else if(prob(5))
								m.AddPacifying(5)
								OMsg(m, "[m] is rendered stupified by the trick!")*/
							else
								usr << "[m] didn't appear impressed by your trick."
					src.Trigger(usr)
			Magic_Act
				ElementalClass="Water"
				SkillCost=TIER_1_COST
				Copyable=2
				PreRequisite=list("/obj/Skills/Buffs/SlotlessBuffs/Magic/Magic_Trick")
				ManaCost=10
				Cooldown=30
				verb/Confusing_Act()
					set hidden=1
					if(!usr.BuffOn(src))
						src.PhysicalHitsLimit=0
						src.SpiritHitsLimit=0
						src.EndYourself=1
						src.ActiveMessage="performs a confusing act!"
						src.OffMessage=0
						src.FakePeace=0
						for(var/mob/Players/m in oviewers(5,usr))
							if(prob(30))
								m.AddConfusing(20)
								OMsg(m, "[m] tries to work out the logstics of the act! How can this be?!")
							else
								OMsg(m, "[m] isn't impressed by [usr]'s act.")
					src.Trigger(usr)
				verb/Stunning_Act()
					set hidden=1
					if(!usr.BuffOn(src))
						src.PhysicalHitsLimit=0
						src.SpiritHitsLimit=0
						src.EndYourself=1
						src.ActiveMessage="performs a stunning act!"
						src.OffMessage=0
						src.FakePeace=0
						for(var/mob/Players/m in oviewers(5,usr))
							if(prob(20))
								Stun(m, 5)
								OMsg(m, "[m] is stunned by the act!")
							else
								OMsg(m, "[m] isn't impressed by [usr]'s act.")
					src.Trigger(usr)
				verb/Magic_Act()
					set category="Utility"
					if(!usr.BuffOn(src))
						var/Choices=list("Cancel", "Confuse", "Stun")
						var/Mode=input(usr, "What act do you perform?", "Magic Act") in Choices
						switch(Mode)
							if("Cancel")
								return
							if("Confuse")
								src.PhysicalHitsLimit=0
								src.SpiritHitsLimit=0
								src.EndYourself=1
								src.ActiveMessage="performs a confusing act!"
								src.OffMessage=0
								src.FakePeace=0
								for(var/mob/Players/m in oviewers(5,usr))
									if(prob(30))
										m.AddConfusing(20)
										OMsg(m, "[m] tries to work out the logistics of the act! How can this be?!")
									else
										OMsg(m, "[m] isn't impressed by [usr]'s act.")
							if("Stun")
								src.PhysicalHitsLimit=0
								src.SpiritHitsLimit=0
								src.EndYourself=1
								src.ActiveMessage="performs a stunning act!"
								src.OffMessage=0
								src.FakePeace=0
								for(var/mob/Players/m in oviewers(5,usr))
									if(prob(20))
										Stun(m, 5)
										OMsg(m, "[m] is stunned by the act!")
									else
										OMsg(m, "[m] isn't impressed by [usr]'s act.")
					src.Trigger(usr)

			Magic_Show
				ElementalClass="Water"
				SkillCost=TIER_1_COST
				Copyable=3
				PreRequisite=list("/obj/Skills/Buffs/SlotlessBuffs/Magic/Magic_Act")
				ManaCost=15
				TextColor=rgb(153, 51, 0)
				Cooldown=30
				verb/Disappear()
					set hidden=1
					if(!usr.BuffOn(src))
						src.BuffName="Invisibility"

						src.PhysicalHitsLimit=0
						src.SpiritHitsLimit=0
						src.EndYourself=0
						src.Invisible=20
						src.AllowedPower=0.2
						src.FakePeace=0
						ActiveMessage="uses a spell to hide their existence!"
						OffMessage="dissipates their invisibility..."
					src.Trigger(usr)
				verb/Confusing_Show()
					set hidden=1
					if(!usr.BuffOn(src))

						src.PhysicalHitsLimit=0
						src.SpiritHitsLimit=0
						src.EndYourself=1
						src.Invisible=0
						src.AllowedPower=0
						src.FakePeace=0
						src.ActiveMessage="performs a confusing show!"
						src.OffMessage=0
						for(var/mob/Players/m in oviewers(5,usr))
							if(prob(50))
								m.AddConfusing(20)
								OMsg(m, "[m] tries to work out the logistics of the show! How could this be?!")
							else
								OMsg(m, "[m] isn't impressed by [usr]'s show.")
					src.Trigger(usr)
				verb/Stunning_Show()
					set hidden=1
					if(!usr.BuffOn(src))

						src.PhysicalHitsLimit=0
						src.SpiritHitsLimit=0
						src.EndYourself=1
						src.Invisible=0
						src.AllowedPower=0
						src.FakePeace=0
						src.ActiveMessage="performs a stunning show!"
						src.OffMessage=0
						for(var/mob/Players/m in oviewers(5,usr))
							if(prob(40))
								Stun(m, 5)
								OMsg(m, "[m] is stunned by the show!")
							else
								OMsg(m, "[m] isn't impressed by [usr]'s show.")
					src.Trigger(usr)
/*				verb/Pacifying_Show()
					set hidden=1
					if(!usr.BuffOn(src))

						src.PhysicalHitsLimit=0
						src.SpiritHitsLimit=0
						src.EndYourself=1
						src.Invisible=0
						src.AllowedPower=0
						src.FakePeace=0
						src.ActiveMessage="performs a pacifying show!"
						src.OffMessage=0
						for(var/mob/Players/m in oviewers(5,usr))
							if(prob(30))
								m.AddPacifying(5)
								OMsg(m, "[m] is rendered stupified by the show!")
							else
								OMsg(m, "[m] isn't impressed by [usr]'s show.")
					src.Trigger(usr)*/
				verb/Magic_Show()
					set category="Utility"
					if(!usr.BuffOn(src))
						var/Choices=list("Cancel", "Disappear", "Confuse", "Stun")
						var/Mode=input(usr, "What show do you perform?", "Magic Show") in Choices
						switch(Mode)
							if("Cancel")
								return
							if("Disappear")
								src.BuffName="Invisibility"

								src.PhysicalHitsLimit=0
								src.SpiritHitsLimit=0
								src.EndYourself=0
								src.Invisible=20
								src.AllowedPower=0.2
								src.FakePeace=0
								src.ActiveMessage="uses a spell to hide their existence!"
								src.OffMessage="dissipates their invisibility..."
							if("Confuse")

								src.PhysicalHitsLimit=0
								src.SpiritHitsLimit=0
								src.EndYourself=1
								src.Invisible=0
								src.AllowedPower=0
								src.ActiveMessage="performs a confusing show!"
								src.OffMessage=0
								src.FakePeace=0
								for(var/mob/Players/m in oviewers(5,usr))
									if(prob(50))
										m.AddConfusing(20)
										OMsg(m, "[m] tries to work out the logistics of the show the show! How could this be?!")
									else
										OMsg(m, "[m] isn't impressed by [usr]'s show.")
							if("Stun")

								src.PhysicalHitsLimit=0
								src.SpiritHitsLimit=0
								src.EndYourself=1
								src.Invisible=0
								src.AllowedPower=0
								src.ActiveMessage="performs a stunning show!"
								src.OffMessage=0
								src.FakePeace=0
								for(var/mob/Players/m in oviewers(5,usr))
									if(prob(40))
										Stun(m, 5)
										OMsg(m, "[m] is stunned by the show!")
									else
										OMsg(m, "[m] isn't impressed by [usr]'s show.")
							if("Pacify")

								src.PhysicalHitsLimit=0
								src.SpiritHitsLimit=0
								src.EndYourself=1
								src.Invisible=0
								src.AllowedPower=0
								src.ActiveMessage="performs a pacifying show!"
								src.OffMessage=0
								src.FakePeace=0
								for(var/mob/Players/m in oviewers(5,usr))
									if(prob(30))
										m.AddPacifying(5)
										OMsg(m, "[m] is rendered stupified by the show!")
									else
										OMsg(m, "[m] isn't impressed by [usr]'s show.")
					src.Trigger(usr)

			Stone_Skin
				ElementalClass="Earth"
				SkillCost=TIER_3_COST
				Copyable=3
				ManaCost=3
				passives = list("Hardening" = 0.5)
				Hardening=0.5
				ActiveMessage="uses a spell to give themselves the endurance of the earth!"
				OffMessage="dissipates their earth protection..."
				TextColor=rgb(153, 51, 0)
				TimerLimit=15
				Cooldown=60
				verb/Stone_Skin()
					set category="Skills"
					var/magicLevel = usr.getTotalMagicLevel()
					if(magicLevel >= 10)
						magicLevel = 10
					TimerLimit = 15+magicLevel
					src.Trigger(usr)
			True_Effort
				ElementalClass="Earth"
				SkillCost=TIER_3_COST
				Copyable=4
				PreRequisite=list("/obj/Skills/Buffs/SlotlessBuffs/Magic/Stone_Skin")
				ManaCost=12
				passives = list("Hardening" = 1, "Pursuer" = 1, "Instinct" = 1)
				Instinct=1
				Pursuer=1
				Hardening=3
				TextColor=rgb(255, 0, 0)
				ActiveMessage="uses a spell to draw out their highest effort!"
				OffMessage="dissipates their extra effort..."
				TimerLimit=30
				Cooldown=100
				verb/True_Effort()
					set category="Skills"
					var/magicLevel = usr.getTotalMagicLevel()
					if(magicLevel >= 10)
						magicLevel = 10
					TimerLimit = 30+magicLevel
					src.Trigger(usr)
			Heroic_Will
				ElementalClass="Earth"
				SkillCost=TIER_3_COST
				Copyable=5
				PreRequisite=list("/obj/Skills/Buffs/SlotlessBuffs/Magic/True_Effort")
				ManaCost=10
				TimerLimit=30
				passives = list("Hardening" = 1.5, "Flow" = 1, "Instinct" = 1, "Pursuer" = 1)
				Flow=1
				Instinct=1
				Pursuer=1
				Hardening=3
				TextColor=rgb(255, 0, 0)
				ActiveMessage="uses a spell to mimic the will of a hero!"
				OffMessage="dissipates their heroic will..."
				Cooldown=180
				verb/Heroic_Will()
					set category="Skills"
					var/magicLevel = usr.getTotalMagicLevel()
					if(magicLevel >= 10)
						magicLevel = 10
					TimerLimit = 30+magicLevel
					src.Trigger(usr)

			Mage_Armor
				ElementalClass="Earth"
				SkillCost=TIER_3_COST
				Copyable=3
				MakesArmor=1
				ArmorAscension=1 // maybe somehow a way to make this scale?
				ArmorIcon='LancelotArmor.dmi'
				ArmorClass="Light"
				CastingTime=3
				ActiveMessage="weaves an aetheric armor around themselves!"
				OffMessage="releases the invoked armor..."
				TimerLimit=30
				ManaCost=10
				Cooldown=120
				verb/Mage_Armor()
					set category="Skills"
					if(!altered)
						passives = list("ArmorAscension" = 1)
						ArmorAscension = 1
						var/magicLevel = usr.getTotalMagicLevel()
						if(magicLevel >= 10)
							magicLevel = 10
						TimerLimit = 30+magicLevel
					src.Trigger(usr)
				verb/Customize_Mage_Armor()
					set category="Utility"
					var/Choice
					if(!usr.BuffOn(src))
						var/Lock=alert(usr, "Do you wish to alter the icon used?", "Weapon Icon", "No", "Yes")
						if(Lock=="Yes")
							src.ArmorIcon=input(usr, "What icon will your Mage Armor use?", "Mage Armor Icon") as icon|null
							src.ArmorX=input(usr, "Pixel X offset.", "Mage Armor Icon") as num
							src.ArmorY=input(usr, "Pixel Y offset.", "Mage Armor Icon") as num
						Choice=input(usr, "What class of armor do you want your Mage Armor to be?", "Customize Mage Armor") in list("Light", "Medium", "Heavy")
						switch(Choice)
							if("Light")
								src.ArmorClass="Light"
							if("Medium")
								src.ArmorClass="Medium"
							if("Heavy")
								src.ArmorClass="Heavy"
						usr << "Mage Armor class set as [Choice]!"
					else
						usr << "You can't set this while using Mage Armor."
			Perfect_Warrior
				ElementalClass="Earth"
				SkillCost=TIER_3_COST
				Copyable=4
				PreRequisite=list("/obj/Skills/Buffs/SlotlessBuffs/Magic/Mage_Armor")
				StrMult=1
				EndMult=1
				DefMult=1 // 0.3
				passives = list("CriticalChance" = 2, "BlockChance" = 2, "CriticalDamage" = 0.25, "CriticalBlock" = 0.25, "ArmorAscension" = 0.5, \
				 "NoDodge" = 1)
				MakesArmor=1
				ActiveMessage="enters a martial trance, sacrificing their magical abilities!"
				OffMessage="regains their magicality..."
				TimerLimit=60
				ManaCost=15
				Cooldown=-1
				verb/Perfect_Warrior()
					set category="Skills"
					if(!altered)
						var/magicLevel = usr.getTotalMagicLevel()
						if(magicLevel >= 16)
							DefMult = 0.5
							StrMult = 1 + (magicLevel * 0.015)
							EndMult = 1 + (magicLevel * 0.015)
							passives = list("CriticalChance" = 5, "BlockChance" = 5, "CriticalDamage" = 0.5, "CriticalBlock" = 0.5, "ArmorAscension" = 1)
							Cooldown = 240
							TimerLimit = 60 + magicLevel
						else
							passives = list("CriticalChance" = 2, "BlockChance" = 2, "CriticalDamage" = 0.25, "CriticalBlock" = 0.25, "ArmorAscension" = 0.5, \
							 "NoDodge" = 1)
							NoDodge = 1
							DefMult = 1
							StrMult = 1
							EndMult = 1
							TimerLimit = 60 + magicLevel
					if(!usr.BuffOn(src))
						src.ManaAdd=(-1)*(usr.ManaAmount*0.75)
					for(var/obj/Skills/Buffs/SlotlessBuffs/Magic/Mage_Armor/MA in usr)
						src.ArmorIcon=MA.ArmorIcon
						src.ArmorClass=MA.ArmorClass
						src.ArmorX=MA.ArmorX
						src.ArmorY=MA.ArmorY
					src.Trigger(usr)
			Golem_Form
				ElementalClass="Earth"
				SkillCost=TIER_3_COST
				Copyable=5
				PreRequisite=list("/obj/Skills/Buffs/SlotlessBuffs/Magic/Perfect_Warrior")
				Enlarge=2
				Mechanized=1
				Xenobiology=1
				StrMult=1 //1.2
				EndMult=1 //1.3
				SpdMult=1 //0.8
				DefMult=1 //0.3
				CriticalChance=5
				BlockChance=5
				SweepingStrike=1
				MakesArmor=1
				ArmorAscension=1
				IconTint=list(0.3,0.3,0.3, 0.59,0.59,0.59, 0.11,0.11,0.11, 0,0,0)
				ActiveMessage="channels magic power to force their body to transform into an artifical fighter!"
				OffMessage="releases the magical transformation..."
				TimerLimit=90
				ManaCost=30
				Cooldown=-1
				verb/Golem_Form()
					set category="Skills"
					set name="Golem Form"
					if(!altered)
						var/magicLevel = usr.getTotalMagicLevel()
						if(magicLevel>=20) // max magic
							passives = list("Mechanized" = 1, "Xenobiology" = 1, "GiantForm" = 1, \
						 "SweepingStrike" = 1, "CriticalChance" = 5, "BlockChance" = 5, "CriticalDamage" = 0.25, "CriticalBlock" = 0.25, "ArmorAscension" = 2)
							StrMult = 1 + (magicLevel * 0.015)
							EndMult = 1 + (magicLevel * 0.015)
							SpdMult = 1 - (magicLevel * 0.015)
							DefMult = 0.6 - (magicLevel * 0.015)
							TimerLimit = 120 + magicLevel
						else
							passives = list("Mechanized" = 1, "Xenobiology" = 1, \
						 "SweepingStrike" = 1, "CriticalChance" = 5, "BlockChance" = 5, "CriticalDamage" = 0.15, "CriticalBlock" = 0.15, "ArmorAscension" = 1, "NoDodge" = 1)
							TimerLimit = 120 + magicLevel
					if(!usr.BuffOn(src))
						src.ManaAdd=(-1)*(usr.ManaAmount*1)
					for(var/obj/Skills/Buffs/SlotlessBuffs/Magic/Mage_Armor/MA in usr)
						src.ArmorIcon=MA.ArmorIcon
						src.ArmorClass=MA.ArmorClass
						src.ArmorX=MA.ArmorX
						src.ArmorY=MA.ArmorY
					src.Trigger(usr)

			Binding
				ElementalClass="Poison"
				SkillCost=TIER_3_COST
				Copyable=3
				CastingTime=2
				ManaCost=10
				EndYourself=1
				AffectTarget=1
				Range=10
				SlowAffected=10
				CrippleAffected=10
				TargetOverlay='StormArmor 2.dmi'
				ActiveMessage="restrains their target's movements with binding magic!"
				OffMessage="completes their bind..."
				Cooldown=90
				verb/Binding()
					set category="Skills"
					src.Trigger(usr)
			Infect
				ElementalClass="Poison"
				SkillCost=TIER_3_COST
				PreRequisite=list("/obj/Skills/Buffs/SlotlessBuffs/Magic/Binding")
				Copyable=4
				CastingTime=5
				ManaCost=20
				EndYourself=1
				AffectTarget=1
				Range=10
				PoisonAffected=2
				ShearAffected=2
				SlowAffected=10
				CrippleAffected=10
				TargetOverlay='Overdrive.dmi'
				ActiveMessage="fills their target's veins with a venomous curse!"
				OffMessage="completes their curse..."
				Cooldown=120
				verb/Infect()
					set category="Skills"
					src.Trigger(usr)
			Curse
				ElementalClass="Poison"
				SkillCost=TIER_3_COST
				PreRequisite=list("/obj/Skills/Buffs/SlotlessBuffs/Magic/Infect")
				Copyable=5
				ManaCost=30
				CastingTime=10
				EndYourself=1
				AffectTarget=1
				// SpdTaxDrain=0.03
				// RecovTaxDrain=0.03
				HealthHeal= -0.5
				TimerLimit = 5
				PoisonAffected=2
				ShearAffected=2
				SlowAffected=5
				CrippleAffected=5
				Range=5
				TargetOverlay='StormArmor.dmi'
				ActiveMessage="saps their target's lifeforce with a malicious curse!"
				OffMessage="finishes the cursing ritual..."
				Cooldown=120
				verb/Curse()
					set category="Skills"
					if(usr.Target.SpdTax||usr.Target.RecovTax)
						return
					src.Trigger(usr)




			/*
				Protect - > Protega
				Shell - > Barrier - > Resilient Sphere

				Move RS to Signature

			*/

			ShellApply
				VaizardHealth = 3
				MagicNeeded = 0
				name = "Shell"
				IconLock='Android Shield.dmi'
				IconLockBlend=2
				IconLayer=-1
				OverlaySize=1.2
				TimerLimit=30
				OffMessage="feels the magic protecting them fade away..."
			Shell
				ElementalClass = "Earth"
				SkillCost = 120
				Copyable = 3
				CastingTime = 2
				ActiveMessage="invokes: <font size=+1>SHELL!</font size>"
				applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/Magic/ShellApply
				EndYourself = 1
				ManaCost=15
				Cooldown=120
				AffectTarget = 1
				Range = 12
				verb/Disable_Innovate()
					set category = "Other"
					disableInnovation(usr)
				adjust(mob/p)
					if(!altered)
						if(p.isInnovative(ELF, "Any") && !isInnovationDisable(p))
							VaizardHealth=1.5
							AffectTarget = 0
							passives = list("Hardening" = p.getTotalMagicLevel()/10)
							applyToTarget=0
							TimerLimit= 30 + p.getTotalMagicLevel()
							VaizardShatter=1
							IconLock='Android Shield.dmi'
							IconLockBlend=2
							IconLayer=-1
							EndYourself= 0
							OverlaySize=1.2
							Range = 0
						else
							applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/Magic/ShellApply
							IconLock=null
							EndYourself= 1
							IconLockBlend=0
							IconLayer=0
							OverlaySize=0
							VaizardHealth=0
							AffectTarget = 1
							passives = list()
							TimerLimit=initial(TimerLimit)
							VaizardShatter=0
							Range = 12
				verb/Shell()
					set category="Skills"
					if(usr.Target==usr&&!altered)
						if(!(usr.isInnovative(ELF, "Any") && !isInnovationDisable(usr)))
							usr << "You can't use [name] on yourself!"
							return
					adjust(usr)
					src.Trigger(usr)
			BarrierApply
				name = "Barrier"
				VaizardHealth = 5
				MagicNeeded = 0
				IconLock='Android Shield.dmi'
				IconLockBlend=2
				IconLayer=-1
				OverlaySize=1.2
				OffMessage="feels the magic protecting them fade away..."
				TimerLimit=60
			Barrier
				ElementalClass="Earth"
				SkillCost=160
				Copyable=4
				PreRequisite=list("/obj/Skills/Buffs/SlotlessBuffs/Magic/Shell")
				applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/Magic/BarrierApply
				CastingTime=3
				ActiveMessage="invokes: <font size=+1>BARRIER!</font size>"
				ManaCost=20
				Cooldown=160
				EndYourself = 1
				AffectTarget = 1
				Range = 12
				verb/Disable_Innovate()
					set category = "Other"
					disableInnovation(usr)
				adjust(mob/p)
					if(!altered)
						if(p.isInnovative(ELF, "Any") && !isInnovationDisable(p))
							VaizardHealth=3
							AffectTarget = 0
							passives = list("Hardening" = p.getTotalMagicLevel()/5)
							TimerLimit=30 + p.getTotalMagicLevel()
							VaizardShatter=1
							applyToTarget = 0
							IconLock='Android Shield.dmi'
							IconLockBlend=2
							IconLayer=-1
							EndYourself = 0
							OverlaySize=1.2
							Range = 0
						else
							applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/Magic/BarrierApply
							IconLock=null
							IconLockBlend=0
							IconLayer=0
							OverlaySize=0
							EndYourself = 1
							VaizardHealth=0
							TimerLimit= initial(TimerLimit)
							VaizardShatter=0
							AffectTarget = 1
							passives = list()
							Range = 12
				verb/Barrier()
					set category="Skills"
					if(usr.Target==usr&&!altered)
						if(!(usr.isInnovative(ELF, "Any") && !isInnovationDisable(usr)))
							usr << "You can't use [name] on yourself!"
							return
					adjust(usr)
					src.Trigger(usr)
			ProtectApply
				name = "Protect"
				passives = list("PureReduction" = 2, "DebuffResistance" = 0.5)
				PureReduction = 2
				DebuffResistance = 0.5
				MagicNeeded = 0
				IconLock='Bubble Shield.dmi'
				IconLockBlend=4
				IconLayer=-1
				OverlaySize=1.2
				OffMessage="feels the magic protecting them fade away..."
				TimerLimit=30
			Protect
				ElementalClass="Earth"
				SkillCost=160
				Copyable=5
				CastingTime=4
				applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/Magic/ProtectApply
				ActiveMessage="invokes: <font size=+1>PROTECT!</font size>"
				EndYourself = 1
				ManaCost=30
				Cooldown=160
				AffectTarget = 1
				Range = 12
				verb/Disable_Innovate()
					set category = "Other"
					disableInnovation(usr)
				adjust(mob/p)
					if(!altered)
						if(p.isInnovative(ELF, "Any") && !isInnovationDisable(p))
							passives = list("PureReduction" = round(p.getTotalMagicLevel()/10,0.1), "DebuffResistance" = p.getTotalMagicLevel()/20, "Sunyata" = round(p.Potential/10,0.5)) // 5% per 10 pot to negate queues
							TimerLimit = 15 + p.getTotalMagicLevel()
							AffectTarget = 0
							CastingTime = 1
							applyToTarget = 0
							IconLock='Bubble Shield.dmi'
							IconLockBlend=4
							IconLayer=-1
							OverlaySize=1.2
							EndYourself = 0
							Range = 0
						else
							applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/Magic/ProtectApply
							IconLock=null
							IconLockBlend=0
							IconLayer=0
							OverlaySize=0
							AffectTarget = 1
							CastingTime = 4
							EndYourself = 1
							passives = list()
							TimerLimit = initial(TimerLimit)
							Range = 12


				verb/Protect()
					set category="Skills"
					if(usr.Target==usr&&!altered)
						if(!(usr.isInnovative(ELF, "Any") && !isInnovationDisable(usr)))
							usr << "You can't use [name] on yourself!"
							return
					adjust(usr)
					src.Trigger(usr)
			Resilient_SphereApply
				name = "Resilient Sphere"
				VaizardHealth = 10
				VaizardShatter=1
				MagicNeeded = 0
				IconLock='zekkai.dmi'
				IconLayer=-1
				IconLockBlend=2
				IconApart=1
				OverlaySize=1.3
				OffMessage="feels the magic protecting them fade away..."
			Resilient_Sphere
				ElementalClass="Earth"
				SignatureTechnique=2
				SignatureName="Advanced Shell Magic"
				applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/Magic/Resilient_SphereApply
				CastingTime = 4
				PreRequisite=list("/obj/Skills/Buffs/SlotlessBuffs/Magic/Barrier")
				ActiveMessage="invokes: <font size=+1>SHELL!</font size>"
				EndYourself = 1
				ManaCost=40
				Cooldown=-1
				AffectTarget = 1
				Range = 12
				verb/Disable_Innovate()
					set category = "Other"
					disableInnovation(usr)
				adjust(mob/p)
					if(!altered)
						if(p.isInnovative(ELF, "Any")&& !isInnovationDisable(p))
							VaizardHealth=5
							AffectTarget = 0
							passives = list("Hardening" = p.getTotalMagicLevel()/5)
							TimerLimit= 60 + p.getTotalMagicLevel() * 2
							VaizardShatter=1
							applyToTarget = 0
							EndYourself = 0
							IconLock='zekkai.dmi'
							IconLayer=-1
							IconLockBlend=2
							IconApart=1
							OverlaySize=1.3
							Range = 0
						else
							IconLock=null
							IconLayer=0
							EndYourself = 1
							IconLockBlend=0
							IconApart=0
							applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/Magic/Resilient_SphereApply
							OverlaySize=1.3
							VaizardHealth=0
							AffectTarget = 1
							passives = list()
							TimerLimit=initial(TimerLimit)
							VaizardShatter=0
							Range = 12
				verb/Resilient_Sphere()
					set category="Skills"
					if(usr.Target==usr&&!altered)
						if(!(usr.isInnovative(ELF, "Any") && !isInnovationDisable(usr)))
							usr << "You can't use [name] on yourself!"
							return
					adjust(usr)
					src.Trigger(usr)



//Appable

			ProtegaApply
				name = "Protega"
				MagicNeeded = 0
				passives = list("PureReduction" = 5, "DebuffResistance" = 1)
				PureReduction=5
				DebuffResistance=1
				MagicNeeded = 0
				IconLock='Bubble Shield.dmi'
				IconLockBlend=2
				IconLayer=-1
				IconApart=1
				OverlaySize=1.2
				TimerLimit=40
				OffMessage="feels the magic protecting them fade away..."
			Protega
				ElementalClass="Earth"
				SignatureTechnique=2
				SignatureName="Advanced Defense Magic"
				PreRequisite=list("/obj/Skills/Buffs/SlotlessBuffs/Magic/Protect")
				CastingTime=3
				ActiveMessage="invokes: <font size=+1>PROTEGA!</font size>"
				ManaCost=60
				Cooldown=-1
				AffectTarget = 1
				EndYourself=1
				applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/Magic/ProtegaApply
				Range = 10
				verb/Disable_Innovate()
					set category = "Other"
					disableInnovation(usr)
				adjust(mob/p)
					if(!altered)
						if(p.isInnovative(ELF, "Any") && !isInnovationDisable(p))
							passives = list("PureReduction" = round(p.getTotalMagicLevel()/5,0.1), "DebuffResistance" = p.getTotalMagicLevel()/10, "Sunyata" = round(p.Potential/5,0.5)) // 5% per 10 pot to negate queues
							TimerLimit = 20 + p.getTotalMagicLevel()
							AffectTarget = 0
							CastingTime = 1
							EndYourself = 0
							applyToTarget = 0
							IconLock='Bubble Shield.dmi'
							IconLockBlend=2
							IconLayer=-1
							IconApart=1
							OverlaySize=1.2
							Range = 0
						else
							applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/Magic/ProtegaApply
							IconLock=null
							IconLockBlend=0
							IconLayer=0
							IconApart=0
							OverlaySize=0
							EndYourself = 1
							passives = list()
							AffectTarget = 1
							CastingTime = 3
							Range = 12
				verb/Protega()
					set category="Skills"
					if(usr.Target==usr&&!altered)
						if(!(usr.isInnovative(ELF, "Any")&& !isInnovationDisable(usr)))
							usr << "You can't use [name] on yourself!"
							return
					adjust(usr)
					src.Trigger(usr)

			EsunaApply
				StableHeal=1
				FatigueHeal=20
				BurnAffected=-10
				SlowAffected=-10
				ShockAffected=-10
				ShatterAffected=-10
				PoisonAffected=-10
				ShearAffected=-10
				TimerLimit=4
				MagicNeeded = 0
			Esuna
				ElementalClass="Water"
				SignatureTechnique=1
				SagaSignature=1
				SignatureName="White Magic"
				AffectTarget=1
				CastingTime=4
				EndYourself=1
				applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/Magic/EsunaApply
				Range=7
				KenWave=1
				KenWaveIcon='SparkleGreen.dmi'
				KenWaveSize=3
				KenWaveX=105
				KenWaveY=105
				ActiveMessage="invokes: <font size=+1>ESUNA!</font size>"
				TimerLimit = 4
				OffMessage="releases the cure magic..."
				ManaCost=15
				Cooldown=150
				verb/Esuna()
					set category="Skills"
					if(usr.Target==usr&&!altered)
						usr << "You can't use [name] on yourself!"
						return
					src.Trigger(usr)

			EsunagaApply
				StableHeal=1
				FatigueHeal=35
				BurnAffected=-20
				SlowAffected=-20
				ShockAffected=-20
				ShatterAffected=-20
				PoisonAffected=-20
				ShearAffected=-20
				TimerLimit=4
				MagicNeeded = 0
			Esunaga
				ElementalClass="Water"
				SignatureTechnique=2
				SagaSignature=1
				SignatureName="Advanced White Magic"
				PreRequisite=list("/obj/Skills/Buffs/SlotlessBuffs/Magic/Esuna")
				EndYourself=1
				AffectTarget=1
				CastingTime=8
				applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/Magic/EsunagaApply
				Range=12
				KenWave=1
				KenWaveIcon='SparkleGreen.dmi'
				KenWaveSize=5
				KenWaveX=105
				KenWaveY=105
				ActiveMessage="invokes: <font size=+1>ESUNAGA!</font size>"
				OffMessage="releases the potent cure magic..."
				ManaCost=20
				TimerLimit=4
				Cooldown=180
				verb/Esunaga()
					set category="Skills"
					if(usr.Target==usr&&!altered)
						usr << "You can't use [name] on yourself!"
						return
					src.Trigger(usr)

			CureApply
				StableHeal=1
				HealthHeal=0.19
				TimerLimit=10
				MagicNeeded = 0
			Cure
				ElementalClass="Water"
				SignatureTechnique=1
				SagaSignature=1
				SignatureTechnique="White Magic"
				AffectTarget=1
				CastingTime=5
				EndYourself = 1
				applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/Magic/CureApply
				Range=7
				KenWave=1
				KenWaveIcon='SparkleYellow.dmi'
				KenWaveSize=3
				KenWaveX=105
				KenWaveY=105
				ActiveMessage="invokes: <font size=+1>CURE!</font size>"
				OffMessage="completes their spell..."
				ManaCost=30
				TimerLimit=10
				Cooldown=-1
				verb/Cure()
					set category="Skills"
					if(usr.Target==usr&&!altered)
						usr << "You can't use [name] on yourself!"
						return
					src.Trigger(usr)

			CuragaApply
				StableHeal=1
				HealthHeal=0.25
				TimerLimit=10
				MagicNeeded = 0
			Curaga
				ElementalClass="Water"
				SignatureTechnique=2
				SagaSignature=1
				SignatureName="Advanced White Magic"
				PreRequisite=list("/obj/Skills/Buffs/SlotlessBuffs/Magic/Cure")
				AffectTarget=1
				CastingTime=8
				applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/Magic/CuragaApply
				Range=7
				KenWave=1
				KenWaveIcon='SparkleYellow.dmi'
				KenWaveSize=5
				KenWaveX=105
				KenWaveY=105
				ActiveMessage="invokes: <font size=+1>CURAGA!</font size>"
				OffMessage="completes their spell..."
				ManaCost=40
				TimerLimit=10
				Cooldown=-1
				verb/Curaga()
					set category="Skills"
					if(usr.Target==usr&&!altered)
						usr << "You can't use [name] on yourself!"
						return
					src.Trigger(usr)


//NOT MAGIC BUT STILL APPABLE


//TECHNOLOGY
		Gear
			Hazard_Suit
				passives = list("VenomImmune" = 1, "WalkThroughHell" = 1)
				VenomImmune=1
				WalkThroughHell=1
				TimerLimit=3600
				ActiveMessage="engages their all-terrain environment suit!"
				OffMessage="burns out a power cell on their suit..."
				verb/Hazard_Suit()
					set category="Skills"
					src.Trigger(usr)
			Sealed_Suit
				passives = list("StaticWalk" = 1, "SpaceWalk" = 1, "VenomImmune" = 1, "WalkThroughHell" = 1)
				StaticWalk=1
				SpaceWalk=1
				VenomImmune=1
				WalkThroughHell=1
				TimerLimit=3600
				HairLock='BLANK.dmi'
				IconLock='SealedHelmet.dmi'
				ActiveMessage="engages their perfect containment unit!"
				OffMessage="removes the sealed suit..."
				verb/Sealed_Suit()
					set category="Skills"
					src.Trigger(usr)
			Deflector_Shield
				passives = list("Deflection" = 1)
				Deflection=1
				TimerLimit=20
				Cooldown=120
				ActiveMessage="activates a tactical shield!"
				OffMessage="overloads their shield..."
				verb/Deflector_Shield()
					set category="Skills"
					src.Trigger(usr)
			Bubble_Shield
				passives = list("NoDodge" = 1)
				NoDodge=1
				VaizardHealth=5
				VaizardShatter=1
				TimerLimit=5
				Cooldown=300
				IconLock='Bubble Shield.dmi'
				IconLockBlend=2
				IconLayer=-1
				OverlaySize=1.2
				ActiveMessage="protects their body in a technological bubble!"
				OffMessage="exceeds the capacity of their shield..."
				verb/Bubble_Shield()
					set category="Skills"
					src.Trigger(usr)
			Jet_Boots
				passives = list("SuperDash" = 1, "Skimmming " = 1, "Pursuer" = 1)
				SuperDash=1
				Skimming=1
				Pursuer=1
				ActiveMessage="engages their jet boots!"
				OffMessage="disengages their jet boots..."
				TimerLimit=150
				HealthThreshold=0.01
				verb/Jet_Boots()
					set category="Skills"
					src.Trigger(usr)
			Jet_Pack
				passives = list("SuperDash" = 1, "Skimming" = 2, "Pursuer" = 2)
				SuperDash=1
				Skimming=2
				Pursuer=2
				ActiveMessage="engages their jet pack!"
				OffMessage="disengages their jet pack..."
				TimerLimit=150
				verb/Jet_Pack()
					set category="Skills"
					src.Trigger(usr)
			Progressive_Blade
				passives = list("SpiritSword" = 0.15)
				MakesSword=1
				FlashDraw=1
				SwordClass="Light"
				SwordIcon='ProgressiveBlade.dmi'
				SwordX=-32
				SwordY=-32
				TimerLimit=180
				ActiveMessage="swings forth a Progressive Blade made from energy!"
				OffMessage="runs out of energy for their Progressive Blade..."
				verb/Progressive_Blade()
					set category="Skills"
					src.Trigger(usr)
			Blast_Fist
				NoSword=1
				NoStaff=1
				PhysicalHitsLimit=6
				passives = list("SpiritHand" = 1, "Scorching" = 1)
				SpiritHand=1
				Scorching=1
				HitSpark='fevExplosion.dmi'
				HitX=-32
				HitY=-32
				HitSize=0.5
				Cooldown=60
				ActiveMessage="loads up their Blast Fists; punches will now discharge shotgun blasts!"
				OffMessage="runs their Blast Fists empty..."
				verb/Blast_Fist()
					set category="Skills"
					src.Trigger(usr)
			Chainsaw
				NoSword=1
				NoStaff=1
				PhysicalHitsLimit=12
				passives = list("SpiritHand" = 1, "Shearing" = 1)
				SpiritHand=1
				Shearing=1
				Cooldown=60
				IconLock='Chainsaw.dmi'
				ActiveMessage="deploys a chainsaw blade and revs it to life!"
				OffMessage="runs out of fuel in the chainsaw..."
				verb/Chainsaw()
					set category="Skills"
					src.Trigger(usr)
			Integrated
				Integrated=1
				Integrated_Deflector_Shield
					passives = list("Deflection" = 1)
					Deflection=1
					TimerLimit=20
					Cooldown=120
					ActiveMessage="activates a tactical shield!"
					OffMessage="overloads their shield..."
					verb/Deflector_Shield()
						set category="Skills"
						src.Trigger(usr)
				Integrated_Bubble_Shield
					passives = list("NoDodge" = 1)
					NoDodge=1
					VaizardHealth=5
					VaizardShatter=1
					TimerLimit=5
					Cooldown=240
					IconLock='Bubble Shield.dmi'
					IconLayer=-1
					OverlaySize=1.2
					ActiveMessage="protects their body in a technological bubble!"
					OffMessage="exceeds the capacity of their shield..."
					verb/Bubble_Shield()
						set category="Skills"
						src.Trigger(usr)
				Integrated_Jet_Boots
					passives = list("SuperDash" = 1, "Skimming" = 1, "Pursuer" = 1)
					SuperDash=1
					Skimming=1
					Pursuer=1
					ActiveMessage="engages their jet boots!"
					OffMessage="disengages their jet boots..."
					TimerLimit=150
					HealthThreshold=0.01
					verb/Jet_Boots()
						set category="Skills"
						src.Trigger(usr)
				Integrated_Jet_Pack
					passives = list("SuperDash" = 1, "Skimming" = 2, "Pursuer" = 2)
					SuperDash=1
					Skimming=2
					Pursuer=2
					ActiveMessage="engages their jet pack!"
					OffMessage="disengages their jet pack..."
					TimerLimit=150
					verb/Jet_Pack()
						set category="Skills"
						src.Trigger(usr)
				Integrated_Progressive_Blade
					passives = list("SpiritSword" = 0.25)
					SpiritSword=0.25
					MakesSword=1
					FlashDraw=1
					SwordClass="Light"
					SwordIcon='ProgressiveBlade.dmi'
					SwordX=-32
					SwordY=-32
					TimerLimit=180
					ActiveMessage="swings forth a Progressive Blade made from energy!"
					OffMessage="runs out of energy for their Progressive Blade..."
					verb/Progressive_Blade()
						set category="Skills"
						src.Trigger(usr)
				Integrated_Lightsaber
					passives = list("SpiritSword" = 0.5, "Deflection" = 1, "SwordAscension" = 1)
					SpiritSword=0.5
					MakesSword=1
					FlashDraw=1
					Deflection=1
					SwordAscension=1
					SwordClass="Light"
					SwordIcon='LightsaberBlue.dmi'
					SwordX=-32
					SwordY=-32
					Cooldown=30
					ActiveMessage="ignites an elegant lightsaber!"
					OffMessage="extinguishes the plasma of their lightsaber..."
					verb/Lightsaber_Color()
						if(!usr.BuffOn(src))
							var/Choice=input(usr, "What color would you like for your lightsaber?", "Set Color") in list("Blue", "Green", "Purple", "Red")
							switch(Choice)
								if("Blue")
									SwordIcon='LightsaberBlue.dmi'
								if("Green")
									SwordIcon='LightsaberGreen.dmi'
								if("Purple")
									SwordIcon='LightsaberPurple.dmi'
								if("Red")
									SwordIcon='LightsaberRed.dmi'
					verb/Lightsaber()
						set category="Skills"
						src.Trigger(usr)
				Integrated_Blast_Fist
					NoSword=1
					NoStaff=1
					PhysicalHitsLimit=6
					passives = list("SpiritHand" = 1, "Scorching" = 1)
					SpiritHand=1
					Scorching=1
					HitSpark='fevExplosion.dmi'
					HitX=-32
					HitY=-32
					HitSize=0.5
					Cooldown=60
					ActiveMessage="loads up their Blast Fists; punches will now discharge shotgun blasts!"
					OffMessage="runs their Blast Fists empty..."
					verb/Blast_Fist()
						set category="Skills"
						src.Trigger(usr)
				Integrated_Chainsaw
					NoSword=1
					NoStaff=1
					PhysicalHitsLimit=12
					passives = list("SpiritHand" = 1, "Shearing" = 1)
					SpiritHand=1
					Shearing=1
					Cooldown=60
					ActiveMessage="deploys a chainsaw blade and revs it to life!"
					OffMessage="runs out of fuel in the chainsaw..."
					verb/Chainsaw()
						set category="Skills"
						src.Trigger(usr)




//Cybernetics and Enchantment
		Implants
			Stun_Chip
				TimerLimit=1
				FlashChange=1
				StunAffected=5
				CrippleAffected=50
				ShockAffected=50
				Cooldown=200
				TextColor=rgb(255, 0, 0)
				OffMessage="is jolted by an internal electric shock!"
			Failsafe_Chip
				EndYourself=1
				FINISHINGMOVE=1
				Cooldown=20000
				TextColor=rgb(255, 0, 0)
				OffMessage="suddenly falls over motionlessly!"
			Internal_Explosive
				TimerLimit=10
				Curse=1
				FlashChange=1
				ExplosiveFinish=30
				ExplosiveFinishIntensity=50
				Cooldown=20000
				TextColor=rgb(255, 0, 0)
				ActiveMessage="has had their internal explosive triggered! They'll explode soon!"
				OffMessage="explodes with violent force!"

		WeaponSystems

			Decapitation_Mode
				TooMuchHealth = 99
				NeedsHealth = 75
				NeedsSword=1
				passives = list("Extend" = 1)
				Extend=1
				TextColor=rgb(255, 0, 0)
				ActiveMessage="transforms their weapon into a deadlier form!"
				OffMessage="restores their weapon to its previous form!"
				adjust(mob/user)
					var/lifeSteal
					var/extend
					if(user.Saga=="Kamui")
						lifeSteal = user.SagaLevel*5
						extend = max(1,ceil(user.SagaLevel/3))
					else
						HealthCost = 25
						lifeSteal = 20
						extend = 1
					passives = list("LifeSteal" = lifeSteal, "Extend" = extend)
				verb/Decapitation_Mode()
					set category="Skills"
					if(!usr.BuffOn(src))
						var/obj/Items/Sword/s=usr.EquippedSword()
						src.SwordIcon=s.iconAlt
						src.SwordX=s.iconAltX
						src.SwordY=s.iconAltY
						src.SwordClass=s.ClassAlt
						src.adjust(usr)
					src.Trigger(usr)
			Alternate_Mode
				NeedsSword=1
				TextColor=rgb(255, 0, 0)
				ActiveMessage="transforms their weapon into an alternate form!"
				OffMessage="restores their weapon to its previous form!"
				verb/Alternate_Mode()
					set category="Skills"
					if(!usr.BuffOn(src))
						var/obj/Items/Sword/s=usr.EquippedSword()
						src.SwordIcon=s.iconAlt
						src.SwordX=s.iconAltX
						src.SwordY=s.iconAltY
						src.SwordClass=s.ClassAlt
					src.Trigger(usr)
			Skim
				TimerLimit=120
				passives = list("Skimming" = 2)
				Skimming=2
				KKTWave=2
				TextColor=rgb(140, 255, 140)
				ActiveMessage="activates jet thrusters to skim!"
				OffMessage="hits the brakes..."
				Cooldown=60
				verb/Skim()
					set category="Mecha"
					src.Trigger(usr)
			Fortress_Mode
				TimerLimit = 10
				passives = list("BetterAim" = 3, "PureReduction" = 1)
				Engrain = 1 // Unable to be knocked back + Frozen
				MissleSystem = 1 // Turn projectiles into homings
				PureReduction = 1
				VaizardHealth = 1
				TextColor=rgb(140, 255, 140)
				ActiveMessage="activates Fortress Mode!"
				OffMessage="deactivates Fortress Mode..."
				Cooldown=120
				proc/init(obj/Items/Gear/Mobile_Suit/mecha)
					if(!mecha) return
					passives = list("BetterAim" = 3, "PureReduction" = mecha.Level/2)
					PureReduction = mecha.Level/2
					VaizardHealth = mecha.Level * 1.5
					TimerLimit = 10 + (mecha.Level * 5)
					Cooldown = 120 - (mecha.Level * 10)
				verb/Fortress_Mode()
					set category="Mecha"
					src.Trigger(usr)

			Unbreakable_Mode
				TimerLimit = 15
				MissleSystem = 1
				Juggernaut = 2
				PureReduction = 1
				VaizardHealth = 1
				Godspeed = -3
				TextColor=rgb(140, 255, 140)
				ActiveMessage="activates Destroyer Mode!"
				OffMessage="deactivates Destroyer Mode..."
				Cooldown=120
				proc/init(obj/Items/Gear/Mobile_Suit/mecha)
					if(!mecha) return
					passives = list("Juggernaut" = mecha.Level/2, "PureReduction" = mecha.Level)
					PureReduction = mecha.Level
					VaizardHealth = mecha.Level * 2.5
					Juggernaut = mecha.Level / 2
					TimerLimit = 5 + (mecha.Level * 5)
				verb/Unbreakable_Mode()
					set category="Mecha"
					src.Trigger(usr)

			Trans_Am
				TimerLimit=30
				NeedsHealth = 50
				HealthCost = 15
				Warping=1
				PhysicalHitsLimit = 1
				ExplosiveFinish=1
				ExplosiveFinishIntensity = 0.55
				TextColor=rgb(140, 255, 140)
				ActiveMessage="activates their Trans Am!"
				OffMessage="deactivates their Trans Am..."
				Cooldown=120
				proc/init(obj/Items/Gear/Mobile_Suit/mecha)
					if(!mecha) return
					ManaGlow = "#770303"
					ManaGlowSize = 1
					NeedsHealth = 50 + (mecha.Level * 5)
					HealthCost = 15 - (mecha.Level * 2)
					ManaCost = 25 - (mecha.Level * 2)
					PhysicalHitsLimit = mecha.Level * 3
					passives = list("Warping" = mecha.Level, "HotHundred" = 1, "Godspeed" = mecha.Level, "PureDamage" = - (5 - mecha.Level))
					Warping = mecha.Level
					HotHundred = 1
					Godspeed = mecha.Level
					PureDamage = - (5 - mecha.Level)
					TimerLimit = 10 + mecha.Level * 10
					Cooldown = 120 - (mecha.Level * 10)
				verb/Warp_Drive()
					set category="Skills"
					init(usr.findMecha())
					src.Trigger(usr)
			Twin_Drive
				TimerLimit = 15
				NeedsHealth = 50
				StableHeal = 1
				Warping = 1
				ExplosiveFinish = 1
				ExplosiveFinishIntensity = 0.75
				HotHundred = 1
				Flow = 1
				Instinct = 1
				Godspeed = 1
				TextColor = rgb(140, 255, 140)
				ActiveMessage = "activates twin drive!"
				OffMessage = "deactivates twin drive..."
				Cooldown = -1
				proc/init(obj/Items/Gear/Mobile_Suit/mecha)
					if(!mecha) return
					ManaGlow = "#770303"
					ManaGlowSize = 1
					TimerLimit = mecha.Level * 5
					HealthHeal = -((10 * mecha.Level)/TimerLimit) * world.tick_lag
					ManaCost = 25 - (mecha.Level * 2)
					PhysicalHitsLimit = mecha.Level * 5
					passives = list("Warping" = mecha.Level, "HotHundred" = 1, "Godspeed" = mecha.Level, "PureDamage" = -4, "Flow" = mecha.Level, "Instinct" = mecha.Level)
					Warping = mecha.Level
					HotHundred = 1
					PureDamage = -4
					Godspeed = mecha.Level
					Flow = mecha.Level
					Instinct = mecha.Level
				verb/Twin_Drive()
					set category="Skills"
					init(usr.findMecha())
					src.Trigger(usr)

			Destroyer_Mode
				TimerLimit = 15
				Extend = 1
				Steady = 1
				Paralyzing = 1
				Shattering = 1
				PhysicalHitsLimit = 1
				TextColor=rgb(140, 255, 140)
				ActiveMessage="activates Destroyer Mode!"
				OffMessage="deactivates Destroyer Mode..."
				Cooldown=120
				proc/init(obj/Items/Gear/Mobile_Suit/mecha)
					if(!mecha) return
					ManaGlow = "#2bd9f8"
					ManaGlowSize = 1
					TimerLimit = 10 + (mecha.Level * 10)
					PhysicalHitsLimit = mecha.Level * 8
					passives = list("Shattering" = mecha.Level/2, "Paralyzing" = mecha.Level/2, "Steady" = mecha.Level/2, "Extend" = round(1 + (mecha.Level/2),1))
					Shattering = mecha.Level/2
					Paralyzing = mecha.Level/2
					Steady = mecha.Level/2
					Extend = round(1 + (mecha.Level/2),1)
					Cooldown = 120 - (mecha.Level * 10)
				verb/Destroyer_Mode()
					set category="Mecha"
					init(usr.findMecha())
					src.Trigger(usr)
			Annihilation_Mode
				TimerLimit = 15
				Extend = 1
				Steady = 1
				Shearing = 1
				CursedWounds = 1
				SlayerMod = 1
				PhysicalHitsLimit = 1
				ExplosiveFinish = 1
				ExplosiveFinishIntensity = 0.25
				TextColor=rgb(140, 255, 140)
				ActiveMessage="activates Annihilation Mode!"
				OffMessage="deactivates Annihilation Mode..."
				Cooldown=120
				proc/init(obj/Items/Gear/Mobile_Suit/mecha)
					if(!mecha) return
					ManaGlow = "#2bd9f8"
					ManaGlowSize = 1
					TimerLimit = 10 + (mecha.Level * 10)
					PhysicalHitsLimit = mecha.Level * 5
					passives = list("Shearing" = mecha.Level/2, "SlayerMod" = mecha.Level/2, "FavoredPrey" = "Races", "Steady" = mecha.Level/2, "Extend" = mecha.Level/2 + 1)
					Shearing = mecha.Level/2
					SlayerMod = mecha.Level/2
					Steady = mecha.Level/2
					Extend = mecha.Level/2 + 1

				verb/Annihilation_Mode()
					set category="Mecha"
					init(usr.findMecha())
					src.Trigger(usr)



			Turbo_Drive
				TimerLimit=30
				HotHundred=1
				PhysicalHitsLimit = 1
				ExplosiveFinish=1
				ExplosiveFinishIntensity = 1.5
				TextColor=rgb(140, 255, 140)
				ActiveMessage="activates turbo drive!"
				OffMessage="deactivates turbo drive..."
				Cooldown=120
				proc/init(obj/Items/Gear/Mobile_Suit/mecha)
					if(!mecha) return
					PhysicalHitsLimit = mecha.Level * 3
					passives = list("HotHundred" = 1, "Shattering" = mecha.Level)
					Shattering = mecha.Level
					TimerLimit = mecha.Level * 5
					Cooldown = 120 - (mecha.Level * 5)
				verb/Turbo_Drive()
					set category="Skills"
					init(usr.findMecha())
					src.Trigger(usr)



			Beam_Saber
				MakesSword=1
				Extend=1
				KillSword = 1
				SwordAscension = 1
				Burning = 0.25
				SpiritSword = 0.5
				TextColor=rgb(255, 0, 0)
				ActiveMessage="activates a beam saber!"
				OffMessage="deactivates the beam saber..."
				proc/init(mob/player)
					var/obj/Items/Gear/Mobile_Suit/mecha = player.findMecha()
					if(!mecha) return
					passives = list("Extend" = 1, "SwordAscension" = mecha.Level, "SpiritSword" = mecha.Level * 0.125, "Burning" = mecha.Level*0.25)
					SwordAscension = mecha.Level
					SpiritSword = mecha.Level * 0.125
					if(SpiritSword >= 0.5)
						SpiritSword = 0.5
					Burning = mecha.Level * 0.25
				proc/beamSaberSetUp(mob/player)
					var/obj/Items/Gear/Mobile_Suit/mecha = player.findMecha()
					if(!mecha) return
					if(!player.CheckActive("Mobile Suit")) return
					var/obj/Skills/Buffs/ActiveBuffs/Gear/Mobile_Suit/MSBuff = player.ActiveBuff
					MSBuff.SwordClass = input(player, "Class?") in list("Light", "Medium", "Heavy")
					switch(input(player, "Custom Icon?") in list("Yes", "No"))
						if("Yes")
							MSBuff.SwordIcon = input(player, "Icon?") as icon
							MSBuff.SwordX = input(player, "X?")
							MSBuff.SwordY = input(player, "Y?")
						if("No")
							MSBuff.SwordIcon = 'LightsaberRed.dmi'
							MSBuff.SwordX=-32
							MSBuff.SwordY=-32
					init(player)
					mecha.beamSaberSetUp = TRUE
				verb/Beam_Saber_Options()
					set name = "Beam Saber Options"
					set category = "Mecha"
					beamSaberSetUp(usr)
				verb/Beam_Saber()
					set category="Skills"
					init(usr)
					var/obj/Items/Gear/Mobile_Suit/mecha = usr.findMecha()
					if(!mecha.beamSaberSetUp)
						beamSaberSetUp(usr)
						mecha.beamSaberSetUp = TRUE
					if(usr.ActiveBuff)
						SwordIcon = usr.ActiveBuff.SwordIcon
						SwordX = usr.ActiveBuff.SwordX
						SwordY = usr.ActiveBuff.SwordY
						SwordClass = usr.ActiveBuff.SwordClass
					src.Trigger(usr)


		Grimoire
			UnrestrictedBuff=1
			MagicNeeded=1
			NoTransplant=1
			Time_Skip
				Cooldown=10
				desc="Manipulate time for everyone in view."
				verb/Time_Skip()
					set category="Skills"
					usr.SkillX("Time Skip",src)
			Time_Stop
				Cooldown=40
				Mastery=1
				var/tmp/TimeStopped=0//holds how long TW has been active for in this usage
				desc="Freeze time for everyone in view."
				verb/Time_Stop()
					set category="Utility"
					usr.SkillX("Time Stop",src)
			Time_Alter
				SignatureTechnique=3
				SpecialSlot=1
				ManaCost=5
				Afterimages=1
				ClientTint=1
				OffMessage="releases their time magic..."
				IconTint=list(0.75,0.3,0, 0.4,0.3,0, 0.25,0.15,0, 0,0,0)
				verb/Time_Alter_Double_Accel()
					set name="Time Alter: Double Accel"
					set category="Skills"
					if(!usr.BuffOn(src))
						passives = list("BleedHit" = 0.75/src.Mastery, "Instinct" = 2, "Flow" = 2, "BlurringStrikes" = 1, "Warping" = 1)
						SpdMult=1.5
						ActiveMessage="yells: <b>Time Alter: Double Accel!</b>"
					src.Trigger(usr)
					if(usr.BuffOn(src))
						animate(usr.client, color = list(0.7,0.7,0.71, 0.79,0.79,0.8, 0.31,0.31,0.32, 0,0,0), time = 3)
				verb/Time_Alter_Triple_Accel()
					set name="Time Alter: Triple Accel"
					set category="Skills"
					if(!usr.BuffOn(src))
						passives = list("BleedHit" = 1.5/Mastery, "Instinct" = 3, "Flow" = 3, "BlurringStrikes" = 2, "Warping" = 2)
						SpdMult=2
						ActiveMessage="yells: <b>Time Alter: Triple Accel!</b>"
					src.Trigger(usr)
					if(usr.BuffOn(src))
						animate(usr.client, color = list(0.7,0.7,0.71, 0.79,0.79,0.8, 0.31,0.31,0.32, 0,0,0), time = 3)
				verb/Time_Alter_Square_Accel()
					set name="Time Alter: Square Accel"
					set category="Skills"
					if(!usr.BuffOn(src))
						SpdMult=3
						passives = list("BleedHit" = 3/Mastery, "Instinct" = 4, "Flow" = 4, "EnergyExpenditure" = 4, "BlurringStrikes" = 3, "Warping" = 3)
						ActiveMessage="yells: <b>Time Alter: Square Accel!</b>"
					src.Trigger(usr)
					if(usr.BuffOn(src))
						animate(usr.client, color = list(0.7,0.7,0.71, 0.79,0.79,0.8, 0.31,0.31,0.32, 0,0,0), time = 3)
			Azure_Grimoire//increases mana amount over cap, artifical SageMode? drains HP
				SignatureTechnique=3
				SpecialSlot=1
				OffMult=2
				passives = list("DrainlessMana" = 1, "ManaStats" = 0.5, "BleedHit" = 1, "LifeSteal" = 20, "MagicFocus" = 1)
				DrainlessMana=1
				ManaStats=0.5
				BleedHit=1
				LifeSteal=20
				MagicFocus=1
				IconLock='DarknessGlow.dmi'
				IconUnder=1
				IconLockBlend=2
				LockX=-32
				LockY=-32
				KenWave=1
				KenWaveIcon='Azure Crest.dmi'
				KenWaveSize=0.2
				KenWaveX=-785
				KenWaveY=-389
				TextColor=rgb(22, 149, 255)
				ActiveMessage="releases the restrictions on their Grimoire, tapping into a limitless font of mana!"
				OffMessage="seals their Grimoire to prevent it from consuming them..."
				Cooldown=-1
				verb/Azure_Grimoire()
					set category="Skills"
					src.Trigger(usr)
			Azure_Grimoire_True//as above but gives life drain instead of draining life, weaker Sage boost
				SignatureTechnique=3
				SpecialSlot=1
				DefMult=2
				passives = list("DrainlessMana" = 1, "ManaStats" = 0.5, "LifeSteal" = 20, "MagicFocus" = 1)
				DrainlessMana=1
				ManaStats=0.5
				MagicFocus=1
				LifeSteal=20//healed for a fifth of damage.
				KenWave=1
				KenWaveIcon='Azure Crest.dmi'
				KenWaveSize=0.2
				KenWaveX=-785
				KenWaveY=-389
				TextColor=rgb(0, 233, 115)
				ActiveMessage="releases the restrictions on their Grimoire, tapping into a perfect font of mana!"
				OffMessage="seals their Grimoire to prevent it from consuming everything..."
				Cooldown=-1
				verb/Azure_Grimoire()
					set category="Skills"
					src.Trigger(usr)
			Azure_Flame_Grimoire
				SignatureTechnique=4
				SpecialSlot=1
				OffMult=2
				DefMult=2
				passives = list("DrainlessMana" = 1, "ManaStats" = 1, "LifeSteal" = 20, "MagicFocus" = 1, "GodKi" = 1)
				DrainlessMana=1
				MagicFocus=1
				ManaStats=1
				Cooldown=-1
				GodKi=1
				KenWave=1
				KenWaveIcon='Azure Crest.dmi'
				KenWaveSize=0.3
				KenWaveX=-785
				KenWaveY=-389
				TextColor=rgb(22, 233, 255)
				ActiveMessage="releases the restrictions on the True Grimoire, tapping into an omnipotent font of mana!"
				OffMessage="seals their Grimoire to prevent reality from shattering..."
				verb/Azure_Flame_Grimoire()
					set category="Skills"
					src.Trigger(usr)
			Mafuba
				WarpZone=1
				EndYourself=1
				FINISHINGMOVE=1
				IconLock='TornadoDirectedBrave.dmi'
				LockX=-8
				LockY=0
				OverlaySize=5
				HealthDrain=15
				WoundDrain=15
				CastingTime=5
				Range=5
				Cooldown=-1
				ActiveMessage="conjures an evil-sealing wave!!"
				OffMessage="collapses from the strain of the evil-sealing wave..."
				verb/Mafuba()
					set category="Skills"
					if(!usr.Target)
						usr << "You need a target to seal demons!"
						return
					if(usr.Target==usr)
						usr << "PLEASE DO NOT SEAL YOURSELF WITH THE MAFUBA..."
						return
					if(!src.WarpX||!src.WarpY||!src.WarpZ)
						usr << "Your demon containment area is not set..."
						return
					src.Trigger(usr)
					if(src.Using)
						src.Mastery++
						if(usr.EraBody=="Elder"||usr.EraBody=="Senile"||src.Mastery>=3)
							if(!usr.EraDeathClock)
								var/DeathClock=Minute(30)
								usr.EraDeathClock=world.realtime+DeathClock
								usr << "You will die from overexertion soon. Use your remaining time well."
			Crimson_Grimoire
				passives = list("LimitlessMagic" = 1, "MagicFocus" = 1, "Crimson Grimoire" = 1)
				LimitlessMagic=1
				TimerLimit=90
				Cooldown=180
				MagicFocus=1
				TextColor=rgb(255, 0, 127)
				ActiveMessage="no longer requires mana to access true magic!"
				OffMessage="blocks out the limitless knowledge of the Grimoire..."
				var/tmp/database_synced = 0
				verb/Crimson_Grimoire()
					set category="Skills"
					BuffTechniques = general_magic_database
					src.Trigger(usr)
			Pure_Grimoire
				passives = list("BuffMastery" = 3, "StyleMastery" = 3)
				StrMult = 1.15
				SpdMult = 1.15
				OffMult = 1.15
				DefMult = 1.15
				EndMult = 1.15
				Cooldown=4
				TextColor=rgb(255, 240, 245)
				ActiveMessage="fills their blank Grimoire with their power, greatly enhancing it!"
				OffMessage="seals their Grimoire..."
				adjust(mob/p)
					if(PURE_GRIM_SCALING)
						if(p.key in glob.WILL_NOT_TARP_LIST)
							if(!altered)
								var/typeOfDamage
								if(p.usingStyle("SwordStyle"))
									typeOfDamage = "Sword"
								else if(p.usingStyle("UnarmedStyle"))
									typeOfDamage = "Unarmed"
								else if(p.usingStyle("FreeStyle"))
									typeOfDamage = "Free"
								else if(p.usingStyle("Mystic"))
									typeOfDamage = "Spiritual"
								var/pot = p.Potential
								if(typeOfDamage == "Free")
									passives["SwordDamage"] = 1 + (round(pot/20, 0.25))
									passives["UnarmedDamage"] = 1 + (round(pot/20, 0.25))
								else
									passives["[typeOfDamage]Damage"] = 1 + (round(pot/10, 0.5))
								passives["Godspeed"] = 2 + (round(pot/25))
								passives["BuffMastery"] = 2 + (round(pot/10, 0.5))
								passives["TechniqueMastery"] = 2 +( round(pot/10, 0.5))
								passives["BlurringStrikes"] = 1 +( round(pot/50))
								passives["CallousedHands"] = 0.15 +( round(pot/100, 0.1))
								passives["HybridStrike"] = ( round(pot/100, 0.1))
								StrMult = 1 + (pot/100)
								SpdMult = 1 + (pot/100)
								OffMult = 1 + (pot/100)
								DefMult = 1 + (pot/100)
								EndMult = 1 + (pot/100)
				verb/Pure_Grimoire()
					set category="Skills"
					if(!usr.StyleBuff)
						usr << "You need a style active to use this."
						return
					if(!usr.BuffOn(src))
						adjust(usr)
					src.Trigger(usr)
			Blood_Grimoire
				IconLock='Demon_Blood_Talismans Active.dmi'
				LockX=0
				LockY=0
				passives = list("ManaCapMult" = 1, "MagicFocus" = 1)
				ManaAdd=100
				ForMult=1.5
				MagicFocus=1
				TimerLimit=15
				Cooldown=60
				TextColor=rgb(127, 0, 0)
				ActiveMessage="draws on the power of Old Blood to enhance their spellcasting!"
				OffMessage="releases their demonic blessing..."
				verb/Blood_Grimoire()
					set category="Skills"
					src.Trigger(usr)
			OverDrive
				MagicNeeded=0
				Frost_End
					TimerLimit=30
					Cooldown=-1
					passives = list("StunningStrike" = 2, "Freezing" = 1, "Chilling" = 1)
					StunningStrike=2
					Freezing=1
					Chilling=1
					ActiveMessage="overloads their Drive, turning their swordsmanship into a slicing blizzard - <b>Frost End</b>!"
					OffMessage="seals the frost of Yukianesa..."
					verb/Frost_End()
						set category="Skills"
						src.Trigger(usr)
				Chain_Quasar
					TimerLimit=30
					Cooldown=120
					passives = list("Godspeed" = 2, "SweepingStrike" = 1, "Warp" = 1, "SpiritStrike" = 1)
					Godspeed=2
					Afterimages=1
					SweepingStrike=1
					Warp=1
					SpiritStrike=1
					HitSpark='Hit Effect Ripple.dmi'
					HitX=-32
					HitY=-32
					ActiveMessage="overloads their Drive, turning their movement into a dancelike flow - <b>Chain Quasar</b>!"
					OffMessage="seals the accuracy of Bolverk..."
					verb/Chain_Quasar()
						set category="Skills"
						src.Trigger(usr)
				Fierce_God
					TimerLimit=30
					Cooldown=-1
					passives = list("TechniqueMastery" = 10)
					TechniqueMastery=10
					EnergyHeal=3
					ManaHeal=3
					ActiveMessage="overloads their Drive, entering a tireless frenzy - <b>Kishin</b>!"
					OffMessage="seals the justice of Ookami..."
					verb/Fierce_God()
						set category="Skills"
						src.Trigger(usr)

			Slaying_God
				MagicNeeded = FALSE
				Cooldown=30
				PhysicalHitsLimit=1
				passives = list("CounterMaster" = 10)
				CounterMaster=10
				KenWave=2
				KenWaveIcon='KenShockwaveGold.dmi'
				KenWaveSize=0.2
				KenWaveTime=5
				ActiveMessage="prepares to counter attacks with divine clarity - <b>Zanshin</b>!"
				verb/Slaying_God()
					set category="Skills"
					src.Trigger(usr)

		Necromorph
			IconLock = 'Necromorph.dmi'
			LockX = -16
			LockY = -16
			passives = list("BladeFisting" = 1, "PureDamage" = -1, "PureReduction" = 10, "NoDodge" = 1, "Instinct" = 1)
			ActiveMessage = "is taken over by sprawling masses of flesh and necrotization!"
			OffMessage = "'s fleshy overgrowth recedes..."
			var/forceZombie = 1
			verb/Necromorphization()
				set category = "Skills"
				if(forceZombie)
					if(!Using)
						usr.Secret = "Zombie"
					else
						usr.Secret = null
				src.Trigger(usr)
//General
		Posture//for custom shit
			verb/Posture()
				set category="Skills"
				src.Trigger(usr)

		Posture_2
			verb/Posture_2()
				set category="Skills"
				src.Trigger(usr)
		Posture_3
			verb/Posture_3()
				set category="Skills"
				src.Trigger(usr)
		Posture_3
			verb/Posture_4()
				set category="Skills"
				src.Trigger(usr)
		Unbound_Mode
			SignatureTechnique=3
			SpecialSlot=1
			passives = list("MovementMastery" = 5, "TechniqueMastery" = 5, "BuffMastery" = 5, "ManaLeak" = 1)
			MovementMastery=5
			TechniqueMastery=5
			BuffMastery=5
			ManaThreshold=1
			ManaLeak=1
			FlashChange=1
			KenWaveIcon='Unbound.dmi'
			KenWave=1
			KenWaveSize=1
			KenWaveX=72
			KenWaveY=72
			KenWaveBlend=2
			KenWaveTime=5
			ActiveMessage="unleashes their complete self!"
			OffMessage="returns to their old self..."
			Cooldown=-1
			verb/Unbound_Mode()
				set category="Skills"
				src.Trigger(usr)
		Sparking_Blast
			SignatureTechnique=3
			SpecialSlot=1
			passives = list("LifeGeneration"=1, "EnergyGeneration" = 5, "ManaGeneration" = 55, "Pursuer" = 3, "PureDamage" = 2, "Instinct" = 2, "Flicker" = 2)
			LifeGeneration=5
			EnergyGeneration=5
			ManaGeneration=5
			Pursuer=3
			PureDamage=2
			Instinct=2
			Flicker=2
			IconLock='SparkingBlastSparks.dmi'
			IconLockBlend=2
			OverlaySize=0.7
			LockY=-4
			FlashChange=1
			KenWaveIcon='SparkingBlast.dmi'
			KenWave=1
			KenWaveSize=1
			KenWaveX=72
			KenWaveY=72
			KenWaveBlend=2
			KenWaveTime=5
			Cooldown=-1
			verb/Sparking_Blast()
				set category="Skills"
				if(!usr.BuffOn(src))
					if(usr.Health>50)
						src.TimerLimit=10
					if(usr.Health<=50)
						src.TimerLimit=20
					if(usr.Health<=25)
						src.TimerLimit=30
					if(!src.Using)
						usr.Activate(new/obj/Skills/AutoHit/Knockoff_Wave)
				src.Trigger(usr)

		God_Ki
			SignatureTechnique=4
			Cooldown=10
			Transform="God"
			ActiveMessage="unleashes their godly power!"
			OffMessage="restrains their godly power..."
			verb/God_Ki()
				set category="Skills"
				src.Trigger(usr)
		Embrace_Legend
			passives = list("Mythical" = 1)
			Mythical=1
			ActiveMessage="roars as they embrace their legendary power!"
			OffMessage="regains their senses..."
			verb/Embrace_Legend()
				set category="Skills"
				src.Trigger(usr)
		Shatter_Sanity
			passives = list("HellPower" = 1)
			HellPower=1
			ActiveMessage="screams as their sanity shatters!"
			OffMessage="simmers back down..."
			verb/Shatter_Sanity()
				set category="Skills"
				src.Trigger(usr)

		Devil_Arm
			SignatureTechnique=3
			Mastery=0
			Copyable=0
			MakesSword=1
			FlashDraw=1
			SwordName="Demon Blade"
			SwordIcon='SwordBroad.dmi'
			StaffName="Demon Rod"
			StaffIcon='MageStaff.dmi'
			ArmorName="Demon Scales"
			StaffIcon='DevilScale.dmi'
			TextColor="#adf0ff"
			ActiveMessage=null
			OffMessage=null
			var/secondDevilArmPick
			verb/Devil_Arm_Evolution()
				set category="Utility"
				var/Choice
				if(src.Mastery>usr.AscensionsAcquired)
					usr << "Your Devil Arm is fully evolved currently!"
					return
				if(Mastery < 1)
					Mastery = 1
				if(!usr.BuffOn(src))
					while(src.Mastery<usr.AscensionsAcquired)
						if(src.Mastery<=1)
							switch(input("What type of armament would you like your Devil Arm ([src.Mastery]) to be?") in list("Sword","Staff","Armor"))
								if("Sword")
									MakesSword=1
									MakesArmor=0
									MakesStaff=0
									SwordName=input(usr, "What will it be named?", "Transfigure Devil Arm") as text|null
									Choice=input(usr, "What class of weapon do you want your Devil Arm to be?", "Transfigure Devil Arm") in list("Saber", "Longsword", "Greatsword")
									switch(Choice)
										if("Saber")
											src.SwordClass="Light"
										if("Longsword")
											src.SwordClass="Medium"
										if("Greatsword")
											src.SwordClass="Heavy"
									usr << "Devil Arm sword class set as [Choice]!"
								if("Staff")
									MakesStaff=1
									MakesArmor=0
									MakesSword=0
									StaffName=input(usr, "What will it be named?", "Transfigure Devil Arm") as text|null
									Choice=input(usr, "What class of staff do you want your Devil Arm to be?", "Transfigure Devil Arm") in list("Wand", "Rod", "Staff")
									switch(Choice)
										if("Wand")
											src.StaffClass="Wand"
										if("Rod")
											src.StaffClass="Rod"
										if("Staff")
											src.StaffClass="Staff"
									usr << "Devil Arm staff class set as [Choice]!"
								if("Armor")
									MakesArmor=1
									MakesSword=0
									MakesStaff=0
									ArmorName=input(usr, "What will it be named?", "Transfigure Devil Arm") as text|null
									Choice=input(usr, "What class of armor do you want your Devil Arm to be?", "Transfigure Devil Arm") in list("Light", "Medium", "Heavy")
									switch(Choice)
										if("Light")
											src.ArmorClass="Light"
										if("Medium")
											src.ArmorClass="Medium"
										if("Heavy")
											src.ArmorClass="Heavy"
									usr << "Devil Arm armor class set as [Choice]!"
							var/Element=input("What element would you like your Devil Arm to use?") in list("Water","Fire","Wind","Earth")
							if(MakesSword)
								SwordElement = Element
							else if(MakesStaff)
								StaffElement = Element
							else if(MakesArmor)
								ArmorElement = Element
							usr << "Devil Armor element set as [Element]"
							var/Lock=alert(usr, "Do you wish to alter the icon used?", "Devil Arm Icon", "No", "Yes")
							if(Lock=="Yes")
								var dIcon=input(usr, "What icon will your Devil Arm uses?", "Devil Arm Icon") as icon|null
								var dX=input(usr, "Pixel X offset.", "Devil Arm Icon") as num
								var dY=input(usr, "Pixel Y offset.", "Devil Arm Icon") as num
								if(MakesSword)
									SwordIcon = dIcon
									SwordX= dX
									SwordY = dY
								else if(MakesStaff)
									StaffIcon = dIcon
									StaffX= dX
									StaffY = dY
								else if(MakesArmor)
									ArmorIcon = dIcon
									ArmorX= dX
									ArmorY = dY
							else
								if(MakesSword)
									SwordIcon='SwordBroad.dmi'
								else if(MakesStaff)
									StaffIcon='MageStaff.dmi'
								else if(MakesArmor)
									StaffIcon='DevilScale.dmi'
						src.Mastery++
						if(src.Mastery==2)
							if(src.MakesSword)
								var/Enhancement=alert(usr, "You can now coat your weapon with your demonic miasma, either empowering its reach or infusing its slices with your mystic power.", "Devil Arm", "Extend", "Emit")
								if(Enhancement=="Extend")
									passives["Extend"] = 1
									src.Extend=1
								if(Enhancement=="Emit")
									passives["SpiritSword"] = 1
									src.SpiritSword=1
							if(src.MakesStaff)
								var/Enhancement=alert(usr, "You can now coat your weapon with your demonic miasma, either reinforcing its casting speed or making it an inexhaustible source of mana.", "Devil Arm", "Speed", "Sustain")
								if(Enhancement=="Speed")
									passives["QuickCast"] = 2
									passives["TechniqueMastery"] = 5
									src.QuickCast=2
									src.TechniqueMastery=5
								if(Enhancement=="Sustain")
									passives["ManaHeal"] = 2
									passives["CapacityHeal"] = 0.02
									src.ManaHeal=2
									src.CapacityHeal=0.02
							if(src.MakesArmor)
								var/Enhancement=alert(usr, "You can now coat your weapon with your demonic miasma, either turning yourself into an wicked juggernaut or a frenzied striker.", "Devil Arm", "Fortress", "Fierce")
								if(Enhancement=="Fortress")
									passives["Juggernaut"] = 1
									passives["DebuffResistance"] = 1
									src.Juggernaut=1
									src.DebuffResistance=1
								if(Enhancement=="Fierce")
									passives["DoubleStrike"] = 1
									passives["Godspeed"] = 1
									src.DoubleStrike=1
									src.Godspeed=1
						if(src.Mastery==3)
							if(src.MakesSword)
								var/Enhancement=alert(usr, "The miasma infusing your weapon thickens, allowing you to deal even more pain to your opponent's body or spirit.", "Devil Arm", "Carve", "Corrupt")
								if(Enhancement=="Carve")
									passives["HardStyle"] = 2
									src.HardStyle=2
								if(Enhancement=="Corrupt")
									passives["SoftStyle"] = 2
									src.SoftStyle=2
							if(src.MakesStaff)
								var/Enhancement=alert(usr, "The miasma infusing your weapon thickens, allowing you to burn away lifeforce from people you strike or dismantle and absorb their own spiritual attacks.", "Devil Arm", "Soulfire", "Siphon")
								if(Enhancement=="Soulfire")
									passives["SoulFire"] = 1
									src.SoulFire=1
								if(Enhancement=="Siphon")
									passives["Siphon"] = 4
									src.Siphon=4
							if(src.MakesArmor)
								var/Enhancement=alert(usr, "The miasma infusing your weapon thickens, allowing you to swiftly counter all manner of attacks or simply march through weaker ones.", "Devil Arm", "Riposte", "Repel")
								if(Enhancement=="Riposte")
									passives["CounterMaster"] = 2
									passives["Flow"] = 2
									src.CounterMaster=2
									src.Flow=2
								if(Enhancement=="Repel")
									passives["Deflection"] = 1
									passives["Reversal"] = 1
									src.Deflection=1
									src.Reversal=1
						if(Mastery==4)
							var/list/optionsList = list("Sword","Staff","Armor")
							if(MakesSword) optionsList -= "Sword"
							if(MakesArmor) optionsList -= "Armor"
							if(MakesStaff) optionsList -= "Staff"
							switch(input("What type of armament would you like your second Devil Arm to be?") in optionsList)
								if("Sword")
									MakesSword=1
									secondDevilArmPick = "Sword"
									SwordName=input(usr, "What will it be named?", "Transfigure Devil Arm") as text|null
									Choice=input(usr, "What class of weapon do you want your Devil Arm to be?", "Transfigure Devil Arm") in list("Saber", "Longsword", "Greatsword")
									switch(Choice)
										if("Saber")
											src.SwordClass="Light"
										if("Longsword")
											src.SwordClass="Medium"
										if("Greatsword")
											src.SwordClass="Heavy"
									usr << "Devil Arm sword class set as [Choice]!"
								if("Staff")
									MakesStaff=1
									secondDevilArmPick = "Staff"
									StaffName=input(usr, "What will it be named?", "Transfigure Devil Arm") as text|null
									Choice=input(usr, "What class of staff do you want your Devil Arm to be?", "Transfigure Devil Arm") in list("Wand", "Rod", "Staff")
									switch(Choice)
										if("Wand")
											src.StaffClass="Wand"
										if("Rod")
											src.StaffClass="Rod"
										if("Staff")
											src.StaffClass="Staff"
									usr << "Devil Arm staff class set as [Choice]!"
								if("Armor")
									MakesArmor=1
									secondDevilArmPick = "Armor"
									ArmorName=input(usr, "What will it be named?", "Transfigure Devil Arm") as text|null
									Choice=input(usr, "What class of armor do you want your Devil Arm to be?", "Transfigure Devil Arm") in list("Light", "Medium", "Heavy")
									switch(Choice)
										if("Light")
											src.ArmorClass="Light"
										if("Medium")
											src.ArmorClass="Medium"
										if("Heavy")
											src.ArmorClass="Heavy"
									usr << "Devil Arm armor class set as [Choice]!"
							if(secondDevilArmPick=="Sword")
								var/Enhancement=alert(usr, "You can now coat your weapon with your demonic miasma, either empowering its reach or infusing its slices with your mystic power.", "Devil Arm", "Extend", "Emit")
								if(Enhancement=="Extend")
									passives["Extend"] = 1
									src.Extend=1
								if(Enhancement=="Emit")
									passives["SpiritSword"] = 1
									src.SpiritSword=1
							if(secondDevilArmPick=="Staff")
								var/Enhancement=alert(usr, "You can now coat your weapon with your demonic miasma, either reinforcing its casting speed or making it an inexhaustible source of mana.", "Devil Arm", "Speed", "Sustain")
								if(Enhancement=="Speed")
									passives["QuickCast"] = 2
									passives["TechniqueMastery"] = 5
									src.QuickCast=2
									src.TechniqueMastery=5
								if(Enhancement=="Sustain")
									passives["ManaHeal"] = 2
									passives["CapacityHeal"] = 0.02
									src.ManaHeal=2
									src.CapacityHeal=0.02
							if(secondDevilArmPick=="Armor")
								var/Enhancement=alert(usr, "You can now coat your weapon with your demonic miasma, either turning yourself into an wicked juggernaut or a frenzied striker.", "Devil Arm", "Fortress", "Fierce")
								if(Enhancement=="Fortress")
									passives["Juggernaut"] = 1
									passives["DebuffResistance"] = 1
									src.Juggernaut=1
									src.DebuffResistance=1
								if(Enhancement=="Fierce")
									passives["DoubleStrike"] = 1
									passives["Godspeed"] = 1
									src.DoubleStrike=1
									src.Godspeed=1
						if(Mastery==5)
							if(secondDevilArmPick=="Sword")
								var/Enhancement=alert(usr, "The miasma infusing your weapon thickens, allowing you to deal even more pain to your opponent's body or spirit.", "Devil Arm", "Carve", "Corrupt")
								if(Enhancement=="Carve")
									passives["HardStyle"] = 2
									src.HardStyle=2
								if(Enhancement=="Corrupt")
									passives["SoftStyle"] = 2
									src.SoftStyle=2
							if(secondDevilArmPick=="Staff")
								var/Enhancement=alert(usr, "The miasma infusing your weapon thickens, allowing you to burn away lifeforce from people you strike or dismantle and absorb their own spiritual attacks.", "Devil Arm", "Soulfire", "Siphon")
								if(Enhancement=="Soulfire")
									passives["SoulFire"] = 1
									src.SoulFire=1
								if(Enhancement=="Siphon")
									passives["Siphon"] = 4
									src.Siphon=4
							if(secondDevilArmPick=="Armor")
								var/Enhancement=alert(usr, "The miasma infusing your weapon thickens, allowing you to swiftly counter all manner of attacks or simply march through weaker ones.", "Devil Arm", "Riposte", "Repel")
								if(Enhancement=="Riposte")
									passives["CounterMaster"] = 2
									passives["Flow"] = 2
									src.CounterMaster=2
									src.Flow=2
								if(Enhancement=="Repel")
									passives["Deflection"] = 1
									passives["Reversal"] = 1
									src.Deflection=1
									src.Reversal=1
						if(MakesSword)
							passives["SwordAscension"] = min(src.Mastery,5)
							SwordAscension=min(src.Mastery,5)
						if(MakesStaff)
							passives["StaffAscension"] = min(src.Mastery,5)
							StaffAscension=min(src.Mastery,5)
						if(MakesArmor)
							passives["ArmorAscension"] = min(src.Mastery,5)
							ArmorAscension=min(src.Mastery,5)
				else
					usr << "You can't set this while using Devil Arm."
			verb/Summon_Arm()
				set category="Skills"
				src.Trigger(usr)

///racial slotless
		The_Crown
			TextColor="#adf0ff"
			TopOverlayLock='Elf_Crown.dmi'
			ActiveMessage=null
			OffMessage=null
			passives = list("Deicide" = 1, "TechniqueMastery" = 1, "Flicker" = 1)

			verb/Don_Crown()
				set category="Skills"
				src.Trigger(usr)

		Sacrifice
			passives = list("ManaStats" = 1, "Anaerobic" = 1, "Tenacity" = 4, "CursedWounds" = 1)
			Cooldown = -1
			HealthCost = 25
			verb/Sacrifice()
				set category = "Skills"
				src.Trigger(usr)

		Golden_Form /// simple, sweet, just a straight fuckin boost. Could in theory be thrown at a Changeling at any point in the wipe if their deserving
			FlashChange = 1
			PowerMult = 2
			Intimidation = 25
			ActiveMessage="begins to glow with Golden power that mocks the very power of the God's.."
			OffMessage="ceases their Golden glow; as they lower themselves once more."
			verb/Golden_Form()
				set category = "Skills"
				src.Trigger(usr)

		Black_Form /// Admins have to willingly hand this out, okay?
			DarkChange = 1
			PowerMult = 10
			Intimidation = 100
			ActiveMessage="ascends abruptly in a black void shell; cackling with dimension-warping levels of power.."
			OffMessage ="releases the universe-shattering power, as the black void upon their flesh evaporates..."
			verb/Black_Form()
				set category = "Skills"
				src.Trigger(usr)

		Soar
			TimerLimit = 25
			Godspeed = 3
			Skimming = 2
			passives = list("Godspeed" = 1, "Skimming" = 1)
			Cooldown = 60
			ActiveMessage = "spreads their wings and takes flight!"
			OffMessage = "descends from the skies above..."
			verb/Soar()
				set category = "Skills"
				src.Trigger(usr)

		Majin
			SignatureTechnique=3
			AutoAnger=1
			AngerThreshold=2
			IconLock='DarknessGlow.dmi'
			LockX=-32
			LockY=-32
			FlashChange=1
			KenWave=2
			KenWaveIcon='KenShockwaveBloodlust.dmi'
			KenWaveSize=0.2
			KenWaveTime=5
			KenWaveBlend=2
			NeedsHealth=50
			TooMuchHealth=75
			Cooldown=-1
			ActiveMessage="begins channeling the dreadful power of Makai!"
			verb/Majin_Form()
				set category="Skills"
				if(!usr.BuffOn(src))
					passives = list("HellPower" = 1, "AngerMult" = 1.5, "PowerReplacement" = glob.progress.totalPotentialToDate+5)
				src.Trigger(usr)

		Duel
			WarpZone=1
			Duel=1
			ActiveMessage="declares a duel!"
			OffMessage="accepts the outcome of the duel..."
			verb/Duel()
				set category="Skills"
				if(usr.Target==usr)
					usr << "Can't duel yourself."
					return
				if(src.WarpTarget)
					var/found=0
					for(var/mob/Players/m in players)
						if(m==src.WarpTarget)
							usr.SetTarget(m)
							found=1
					if(!found)
						usr << "Your duel opponent isn't in the world...So you're stuck here for now."
						return
				src.Trigger(usr)

		Spirit_Bow
			SignatureTechnique=2
			MakesStaff=1
			FlashDraw=1
			StaffName="Spirit Bow"
			StaffIcon='Aether Bow.dmi'
			ActiveMessage="draws spirit energy into their hand to form a bow!"
			OffMessage="dispels their Spirit Bow!"
			passives = list("SpecialStrike" = 1, "StaffAscension" = 2)
			SpecialStrike=1
			StaffAscension=2
			verb/Transfigure_Spirit_Bow()
				set category="Utility"
				var/Choice
				if(!usr.BuffOn(src))
					var/Lock=alert(usr, "Do you wish to alter the icon used?", "Weapon Icon", "No", "Yes")
					if(Lock=="Yes")
						src.StaffIcon=input(usr, "What icon will your Spirit Bow use?", "Spirit Bow Icon") as icon|null
						src.StaffX=input(usr, "Pixel X offset.", "Spirit Bow Icon") as num
						src.StaffY=input(usr, "Pixel Y offset.", "Spirit Bow Icon") as num
					Choice=input(usr, "What class of bow do you want your Spirit Bow to be?", "Transfigure Spirit Bow") in list("Short", "Recurve", "Long")
					switch(Choice)
						if("Short")
							src.StaffClass="Wand"
						if("Recurve")
							src.StaffClass="Rod"
						if("Long")
							src.StaffClass="Staff"
					usr << "Spirit Bow class set as [Choice]!"
				else
					usr << "You can't set this while using Spirit Bow."
			verb/Spirit_Bow()
				set category="Skills"
				src.Trigger(usr)

		Spirit_Sword//t2
			MakesSword=3
			FlashDraw=1
			SwordName="Spirit Sword"
			SwordIcon='Aether Blade.dmi'
			SwordX=-32
			SwordY=-32
			passives = list("SpiritSword" = 0.25, "SwordAscension" = 2, "SwordAscensionSecond" = 2, "SwordAscensionThird" = 2)
			SwordAscension=2
			SwordNameSecond="Spirit Sword"
			SwordIconSecond='Aether Blade Alternate.dmi'
			SwordAscensionSecond=2
			SwordXSecond=-32
			SwordYSecond=-32
			SwordNameThird="Spirit Sword"
			SwordAscensionThird=2
			ActiveMessage="draws spirit energy into their hand to form a blade!"
			OffMessage="dispels their Spirit Sword!"
			adjust(mob/p)
				passives = list("SpiritSword" = 0.25, "SwordAscension" = 2, "SwordAscensionSecond" = 2, "SwordAscensionThird" = 2)
			verb/Transfigure_Spirit_Sword()
				set category="Utility"
				var/Choice
				if(!usr.BuffOn(src))
					var/modify_sword_num = 1
					if((locate(/obj/Skills/Buffs/NuStyle/SwordStyle/Nito_Ichi_Style) in usr) || (locate(/obj/Skills/Buffs/NuStyle/SwordStyle/Santoryu) in usr))
						var/list/options = list("Primary","Secondary")
						if((locate(/obj/Skills/Buffs/NuStyle/SwordStyle/Santoryu) in usr)) options += "Tertiary"
						switch(input("Which sword would you like to modify?") in options)
							if("Secondary") modify_sword_num=2
							if("Tertiary") modify_sword_num=3
					var/Lock=alert(usr, "Do you wish to alter the icon used?", "Weapon Icon", "No", "Yes")
					if(Lock=="Yes")
						switch(modify_sword_num)
							if(1)
								src.SwordIcon=input(usr, "What icon will your Spirit Sword use?", "Spirit Sword Icon") as icon|null
								src.SwordX=input(usr, "Pixel X offset.", "Spirit Sword Icon") as num
								src.SwordY=input(usr, "Pixel Y offset.", "Spirit Sword Icon") as num
							if(2)
								src.SwordIconSecond=input(usr, "What icon will your Spirit Sword use?", "Spirit Sword Icon") as icon|null
								src.SwordXSecond=input(usr, "Pixel X offset.", "Spirit Sword Icon") as num
								src.SwordYSecond=input(usr, "Pixel Y offset.", "Spirit Sword Icon") as num
							if(3)
								src.SwordIconThird=input(usr, "What icon will your Spirit Sword use?", "Spirit Sword Icon") as icon|null
								src.SwordXThird=input(usr, "Pixel X offset.", "Spirit Sword Icon") as num
								src.SwordYThird=input(usr, "Pixel Y offset.", "Spirit Sword Icon") as num
					Choice=input(usr, "What class of blade do you want your Spirit Sword to be?", "Transfigure Spirit Sword") in list("Blunt", "Saber", "Longsword", "Greatsword")
					switch(Choice)
						if("Blunt")
							switch(modify_sword_num)
								if(1) src.SwordClass="Wooden"
								if(2) src.SwordClassSecond="Wooden"
								if(3) src.SwordClassThird="Wooden"
						if("Saber")
							switch(modify_sword_num)
								if(1) src.SwordClass="Light"
								if(2) src.SwordClassSecond="Light"
								if(3) src.SwordClassThird="Light"
						if("Longsword")
							switch(modify_sword_num)
								if(1) src.SwordClass="Medium"
								if(2) src.SwordClassSecond="Medium"
								if(3) src.SwordClassThird="Medium"
						if("Greatsword")
							switch(modify_sword_num)
								if(1) src.SwordClass="Heavy"
								if(2) src.SwordClassSecond="Heavy"
								if(3) src.SwordClassThird="Heavy"
					usr << "Spirit Sword class set as [Choice]!"
				else
					usr << "You can't set this while using Spirit Sword."
			verb/Spirit_Sword()
				set category="Skills"
				src.Trigger(usr)
		Dimension_Sword//t4
			MakesSword=3
			FlashDraw=1
			SwordName="Dimension Sword"
			SwordIcon='Aether Blade.dmi'
			passives = list("SpiritSword" = 1, "PridefulRage" = 1, "BulletKill" = 1, "Extend" = 1, "SwordAscension" = 4)
			SpiritSword=1
			PridefulRage=1
			BulletKill=1
			Extend=1
			SwordAscension=4
			ActiveMessage="draws spirit energy into their hand to form a spacetime-rending blade!"
			OffMessage="dispels their Dimension Sword!"
			verb/Transfigure_Dimension_Sword()
				set category="Utility"
				var/Choice
				if(!usr.BuffOn(src))
					var/modify_sword_num = 1
					if((locate(/obj/Skills/Buffs/NuStyle/SwordStyle/Nito_Ichi_Style) in src) || (locate(/obj/Skills/Buffs/NuStyle/SwordStyle/Santoryu) in src))
						var/list/options = list("Primary","Secondary")
						if((locate(/obj/Skills/Buffs/NuStyle/SwordStyle/Santoryu) in src)) options += "Tertiary"
						switch(input("Which sword would you like to modify?") in options)
							if("Secondary") modify_sword_num=2
							if("Tertiary") modify_sword_num=3
					var/Lock=alert(usr, "Do you wish to alter the icon used?", "Weapon Icon", "No", "Yes")
					if(Lock=="Yes")
						switch(modify_sword_num)
							if(1)
								src.SwordIcon=input(usr, "What icon will your Spirit Sword use?", "Spirit Sword Icon") as icon|null
								src.SwordX=input(usr, "Pixel X offset.", "Spirit Sword Icon") as num
								src.SwordY=input(usr, "Pixel Y offset.", "Spirit Sword Icon") as num
							if(2)
								src.SwordIconSecond=input(usr, "What icon will your Spirit Sword use?", "Spirit Sword Icon") as icon|null
								src.SwordXSecond=input(usr, "Pixel X offset.", "Spirit Sword Icon") as num
								src.SwordYSecond=input(usr, "Pixel Y offset.", "Spirit Sword Icon") as num
							if(3)
								src.SwordIconThird=input(usr, "What icon will your Spirit Sword use?", "Spirit Sword Icon") as icon|null
								src.SwordXThird=input(usr, "Pixel X offset.", "Spirit Sword Icon") as num
								src.SwordYThird=input(usr, "Pixel Y offset.", "Spirit Sword Icon") as num
					Choice=input(usr, "What class of blade do you want your Spirit Sword to be?", "Transfigure Spirit Sword") in list("Blunt", "Saber", "Longsword", "Greatsword")
					switch(Choice)
						if("Blunt")
							switch(modify_sword_num)
								if(1) src.SwordClass="Wooden"
								if(2) src.SwordClassSecond="Wooden"
								if(3) src.SwordClassThird="Wooden"
						if("Saber")
							switch(modify_sword_num)
								if(1) src.SwordClass="Light"
								if(2) src.SwordClassSecond="Light"
								if(3) src.SwordClassThird="Light"
						if("Longsword")
							switch(modify_sword_num)
								if(1) src.SwordClass="Medium"
								if(2) src.SwordClassSecond="Medium"
								if(3) src.SwordClassThird="Medium"
						if("Greatsword")
							switch(modify_sword_num)
								if(1) src.SwordClass="Heavy"
								if(2) src.SwordClassSecond="Heavy"
								if(3) src.SwordClassThird="Heavy"
					usr << "Spirit Sword class set as [Choice]!"
				else
					usr << "You can't set this while using Spirit Sword."
			verb/Dimension_Sword()
				set category="Skills"
				src.Trigger(usr)

		Legend_of_Black_Heaven
			SignatureTechnique=3
			SwordName="Richtenbacher"
			BuffTechniques=list("/obj/Skills/Projectile/Sword/Bard/Bardic_Riff", "/obj/Skills/Projectile/Sword/Bard/Bardic_Scream", "/obj/Skills/Queue/Bad_Luck")
			MakesSword=1
			NeedsSword=0
			MagicSword=1
			passives = list("SpiritStrike" = 1, "SwordAscension" = 3, "TechniqueMastery" = 10)
			SpiritStrike=1
			SwordAscension=3
			TechniqueMastery=10
			SwordClass="Medium"
			SwordIcon='Bass.dmi'
			SwordX=-3
			SwordY=0
			ActiveMessage="strikes a pose with their Richtenbacher bass to the adoration of millions!"
			OffMessage="drops the bass..."
			verb/Pick_Instrument()
				set category="Skills"
				var/Lock=alert(usr, "Do you wish to alter the icon used?", "Weapon Icon", "No", "Yes")
				if(Lock=="Yes")
					src.SwordIcon=input(usr, "What icon will your instrument use?", "Instrument Icon") as icon|null
					src.SwordX=input(usr, "Pixel X offset.", "Instrument Icon") as num
					src.SwordY=input(usr, "Pixel Y offset.", "Instrument Icon") as num
				var/Choice
				var/Confirm
				while(Confirm!="Yes")
					Choice=input("Pick a type.") in list ("Acoustic", "Electric", "Bass")
					switch(Choice)
						if("Acoustic")
							Confirm=alert(usr, "Riffs from an acoustic guitar are subtle, but precise in reaching the crowd. Is it your choice?", "Instrument Type", "Yes", "No")
						if("Electric")
							Confirm=alert(usr, "Riffs from an electric guitar are powerful and quick, but harder to control. Is it your choice?", "Instrument Type", "Yes", "No")
						if("Bass")
							Confirm=alert(usr, "Riffs from a bass guitar are heavy, but easy to miss by most audiences. Is it your choice?", "Instrument Type", "Yes", "No")
				switch(Choice)
					if("Acoustic")
						src.SwordClass="Light"
					if("Electric")
						src.SwordClass="Medium"
					if("Bass")
						src.SwordClass="Heavy"
				usr << "Done."
			verb/Legend_Of_Black_Heaven()
				set category="Skills"
				src.Trigger(usr)

		SwordOfDarknessFlame
			NeedsSword=1
			ElementalOffense="Fire"
			passives = list("DarknessFlame" = 1, "SpiritSword" = 0.75)
			DarknessFlame=1
			SpiritSword=0.75
			KenWave=1
			KenWaveIcon='fevExplosion - Hellfire.dmi'
			KenWaveSize=2
			KenWaveX=73
			KenWaveY=73
			HitSpark='Slash - Hellfire.dmi'
			HitX=-32
			HitY=-32
			HitSize=1
			HitTurn=1
			TextColor=rgb(102, 102, 102)
			ActiveMessage="wraps their weapon with the flames of Hell!"
			OffMessage="releases the dark flames..."
			proc/init(mob/p)
				if(altered) return
				passives = list("DarknessFlame" = 1, "SpiritSword" = (0.25 * p.secretDatum.currentTier) + p.Potential/100)


			verb/Sword_of_Darkness_Flame()
				set category="Skills"
				init(usr)
				src.Trigger(usr)
		Jagan_Expert
			SBuffNeeded="Jagan Eye"
			Cooldown=-1
			TimerLimit=0
			FINISHINGMOVE=1
			Intimidation=2
			KenWave=4
			KenWaveIcon='DarkKiai.dmi'
			IconTransform='Jagan Transformation.dmi'
			Transform="Jagan"
			TextColor=rgb(102, 102, 102)
			ActiveMessage="utilizes their mastery of Jagan to warp their flesh and sprout countless eyes!!!"
			OffMessage="is overwhelmed by the strain of otherworldly power..."


			proc/init(mob/p)
				if(altered) return
				var/secretLevel = p.secretDatum.currentTier
				Intimidation = 1 + secretLevel/4
				passives = list("PUSpike" = 5 + (5 * secretLevel), "SpiritHand" = 0.25 * secretLevel, "FatigueLeak" = 5 - secretLevel)

			verb/Jagan_Expert_Mode()
				set category="Skills"
				init(usr)
				src.Trigger(usr)
		Darkness_Dragon_Master
			SBuffNeeded="Jagan Eye"
			Cooldown=-1
			NeedsHealth=25
			passives = list("FatigueLeak" = 1, "SpiritSword" = 0.25, "Flow" = 1, "Instinct" =1)
			FatigueLeak=1
			FatigueThreshold=95
			KenWave=4
			KenWaveIcon='DarkKiai.dmi'
			SpiritSword=0.25
			EndMult=1.1//remove end nerfs from jagan
			Flow=1
			Instinct=1
			Intimidation=2
			PowerInvisible=2
			IconLock='DarknessFlame.dmi'
			IconLockBlend=2
			LockX=-32
			LockY=-34
			ActiveMessage="unites perfectly with the Dragon of Darkness Flame!"
			OffMessage="releases the shackles on the Dragon..."
			proc/init(mob/p)
				if(altered) return
				var/currentPot = p.Potential
				Intimidation = 1.75 + (currentPot/100)
				passives = list("FatigueLeak" = 1, "SpiritSword" = 0.25  , "Flow" = 1 + currentPot/100, "Instinct" = 1 + currentPot/100)
				ForMult = 1 + round(currentPot/150, 0.01)
				StrMult = 1 + round(currentPot/150, 0.01)
				EndMult = 1 + round(currentPot/200, 0.01)
			verb/Darkness_Dragon_Master()
				set category="Skills"
				init(usr)
				src.Trigger(usr)



//Tier S

///Saint Seiya

		Andromeda_Chain
			MakesSword=2
			FlashDraw=1
			SwordClass="Light"
			passives = list("SwordAscension" = 2, "Extend" = 1, "Deflection" = 1)
			SwordAscension=2
			SwordUnbreakable=1
			Extend=1
			Deflection=1
			SBuffNeeded="Andromeda Cloth"
			SwordName="Andromeda's Chains"
			SwordIcon='saintandromeda_chains.dmi'
			HitSpark='Slash - Zero.dmi'
			HitX=-32
			HitY=-32
			HitTurn=1
			HitSize=0.9
			BuffTechniques=list("/obj/Skills/Projectile/Beams/Saint_Seiya/Nebula_Chain","/obj/Skills/Queue/Thunder_Wave")
			Cooldown=150
			adjust(mob/p)
				passives = list("SwordAscension" = max(p.SagaLevel, 1), "Extend" = 1, "Deflection" = max(p.SagaLevel-2,1), "Paralyzing" = p.SagaLevel, "Crippling" = p.SagaLevel/2)
			verb/Andromeda_Chain()
				set category="Skills"
				adjust(usr)
				src.Trigger(usr)
		Andromeda
			Rolling_Defense
				passives = list("Flow" = 1, "LikeWater" = 1, "BackTrack" = 1)
				SBuffNeeded="Andromeda Cloth"
				Cooldown=60
				adjust(mob/p)
					passives = list("Flow" = max(p.SagaLevel/2, 1), "LikeWater" = p.SagaLevel, "BackTrack" = max(p.SagaLevel-3, 1))
				verb/Rolling_Defense()
					set category="Skills"
					adjust(usr)
					src.Trigger(usr)

////Gold Cloth
		Crystal_Wall
			FlashChange=1
			TimerLimit=5
			passives = list("Juggernaut" = 5)
			Juggernaut=5
			IconLock='CrystalWall.dmi'
			OverlaySize=5
			ActiveMessage="unleashes their full might, separating the space between them and their enemies!"
			OffMessage="calms their invincible Cosmo..."
			Cooldown=-1
			verb/Crystal_Wall()
				set category="Skills"
				src.Trigger(usr)
		Heavenly_Ring_Dance
			NeedsHealth=50
			FatigueDrain=0.75
			passives = list("CastingTime" = 2, "FatigueDrain" = 0.75, "SpecialStrike" = 1)
			CastingTime=2
			TurfShift='Mandala.dmi'
			KenWave=1
			SpecialStrike=1
			KenWaveIcon='KenShockwaveGold.dmi'
			KenWaveSize=5
			ActiveMessage="unleashes their full might, trapping the opponents in their grasp!"
			OffMessage="calms their godlike Cosmo..."
			Cooldown=-1
			verb/Heavenly_Ring_Dance()
				set category="Skills"
				set name="Tenbu Horin"
				src.Trigger(usr)
		Libra_Armory
			FlashDraw=1
			verb/Libra_Sword()
				set hidden=1
				if(usr.BuffOn(src))
					src.Trigger(usr)
					src.Using=0
				if(!usr.BuffOn(src))
					MakesSword=1
					SwordClass="Medium"
					SwordAscension=3
					SwordElement="Light"
					MakesSecondSword=0
					SwordClassSecond=0
					SwordAccuracySecond=0
					SwordDamageSecond=0
					SwordDelaySecond=0
					SwordAscensionSecond=0
					DoubleStrike=0
					Extend=0
					passives = list("SwordAscension" = 3, "MagicSword" = 1, "SpecialStrike" = 1)
					MagicSword=1
					SpecialStrike=1
					SwordIcon='goldsaintlibra_sword_r.dmi'
					SwordX=-32
					SwordY=-32
					SwordIconSecond=null
					SwordXSecond=null
					SwordYSecond=null
					ActiveMessage="draws a legendary longsword from their armory!"
					OffMessage="sheathes their blade..."
				src.Trigger(usr)
			verb/Libra_Dual()
				set hidden=1
				if(usr.BuffOn(src))
					src.Trigger(usr)
					src.Using=0
				if(!usr.BuffOn(src))
					MakesSword=1
					MakesSecondSword=1
					SwordClass="Light"
					SwordElement="Light"
					SwordClassSecond="Light"
					SwordElementSecond="Light"
					passives = list("SwordAscension" = 3, "SwordAscensionSecond" = 3, "DoubleStrike" = 1)
					SwordAscension=3
					SwordAscensionSecond=3
					DoubleStrike=1
					Extend=0
					MagicSword=0
					SpecialStrike=0
					SwordIcon='goldsaintlibra_sword_r.dmi'
					SwordX=-32
					SwordY=-32
					SwordIconSecond='goldsaintlibra_sword_l.dmi'
					SwordXSecond=-32
					SwordYSecond=-32
					ActiveMessage="draws a pair of legendary blades from their armory!"
					OffMessage="sheathes their dual blades..."
				src.Trigger(usr)
			verb/Libra_Spear()
				set hidden=1
				if(usr.BuffOn(src))
					src.Trigger(usr)
					src.Using=0
				if(!usr.BuffOn(src))
					MakesSword=1
					SwordAscension=3
					SwordClass="Heavy"
					passives = list("Extend" = 1, "SwordAscension" = 3)
					Extend=1
					MagicSword=0
					MakesSecondSword=0
					SwordClassSecond=0
					SwordAccuracySecond=0
					SwordDamageSecond=0
					SwordDelaySecond=0
					SwordAscensionSecond=0
					SwordElement="Light"
					DoubleStrike=0
					SpecialStrike=0
					SwordIcon='goldsaintlibra_trident.dmi'
					SwordX=-32
					SwordY=-32
					SwordIconSecond=null
					SwordXSecond=null
					SwordYSecond=null
					ActiveMessage="draws a legendary spear from their armory!"
					OffMessage="compacts their spear..."
				src.Trigger(usr)
			verb/Libra_Armory()
				set category="Skills"
				if(!usr.BuffOn(src))
					var/list/Options=list("Sword", "Dual Swords", "Spear")
					var/Choice=input(usr, "What legendary artifact do you draw?", "Libra Armory") in Options
					switch(Choice)
						if("Sword")
							MakesSword=1
							SwordClass="Medium"
							SwordAscension=3
							SwordElement="Light"
							passives = list("SwordAscension" = 3, "MagicSword" = 1, "SpecialStrike" = 1)
							MakesSecondSword=0
							SwordClassSecond=0
							SwordAccuracySecond=0
							SwordDamageSecond=0
							SwordDelaySecond=0
							SwordAscensionSecond=0
							DoubleStrike=0
							Extend=0
							MagicSword=1
							SpecialStrike=1
							SwordIcon='goldsaintlibra_sword_r.dmi'
							SwordX=-32
							SwordY=-32
							SwordIconSecond=null
							SwordXSecond=null
							SwordYSecond=null
							ActiveMessage="draws a legendary longsword from their armory!"
							OffMessage="sheathes their blade..."
						if("Dual Swords")
							MakesSword=1
							MakesSecondSword=1
							SwordClass="Light"
							SwordClassSecond="Light"
							passives = list("SwordAscension" = 3, "SwordAscensionSecond" = 3, "DoubleStrike" = 1)
							SwordAscension=3
							SwordAscensionSecond=3
							SwordElement="Light"
							SwordElementSecond="Light"
							DoubleStrike=1
							Extend=0
							MagicSword=0
							SpecialStrike=0
							SwordIcon='goldsaintlibra_sword_r.dmi'
							SwordX=-32
							SwordY=-32
							SwordIconSecond='goldsaintlibra_sword_l.dmi'
							SwordXSecond=-32
							SwordYSecond=-32
							ActiveMessage="draws a pair of legendary blades from their armory!"
							OffMessage="sheathes their short swords..."
						if("Spear")
							MakesSword=1
							SwordAscension=3
							SwordClass="Heavy"
							passives = list("Extend" = 1, "SwordAscension" = 3)
							Extend=1
							MagicSword=0
							MakesSecondSword=0
							SwordClassSecond=0
							SwordAccuracySecond=0
							SwordDamageSecond=0
							SwordDelaySecond=0
							SwordAscensionSecond=0
							SwordElement="Light"
							DoubleStrike=0
							SpecialStrike=0
							SwordIcon='goldsaintlibra_trident.dmi'
							SwordX=-32
							SwordY=-32
							SwordIconSecond=null
							SwordXSecond=null
							SwordYSecond=null
							ActiveMessage="draws a legendary spear from their armory!"
							OffMessage="sheathes their spear..."
				src.Trigger(usr)
		Excalibur
			NoSword=1
			NoStaff=1
			KiBlade=1
			passives = list("KiBlade" = 1, "SwordAscension" = 2, "HybridStrike" = 1)
			SwordAscension=3
			HybridStrike=1
			IconLock='LightningArm.dmi'
			IconLockBlend=2
			IconLayer=1
			IconApart=1
			HitSpark='Slash - Zan.dmi'
			HitX=-16
			HitY=-16
			HitTurn=1
			ActiveMessage="imbues their arm with the power of the legendary Excalibur!"
			OffMessage="dulls their sharpened Cosmo..."
			verb/Excalibur()
				set category="Skills"
				src.Trigger(usr)
		Kolco
			TimerLimit=25
			AffectTarget=1
			AbsoluteZero=1
			Range=10
			SlowAffected=5
			TargetOverlay='SnowRing.dmi'
			ActiveMessage="entraps their opponent with a ring of frigid air!"
			OffMessage="calms their freezing Cosmo..."
			Cooldown=-1
			verb/Kolco()
				set category="Skills"
				set name="Kol'co"
				src.Trigger(usr)


		Sagittarius_Bow
			MakesStaff=1
			FlashDraw=1
			StaffName="Sagittarius Bow"
			StaffIcon='goldsaintsagittarius_bow.dmi'
			StaffX = -32
			StaffY = -32
			ActiveMessage="burns their Cosmos to manifest a bow!"
			OffMessage="dispels their Cosmos-powered bow!"
			passives = list("SpecialStrike" = 1, "StaffAscension" = 4)
			verb/Sagittarius_Bow()
				set category="Skills"
				src.Trigger(usr)

		Attach_Keychain
			verb/Attach_Keychain()
				set category="Skills"
				if(!usr.CheckActive("Keyblade"))
					var/list/Chains=list()
					if(usr.KeybladeColor=="Light")
						Chains.Add("Kingdom Key")
					if(usr.KeybladeColor=="Darkness")
						Chains.Add("Kingdom Key D")
					if(usr.Keychains.len>0)
						Chains.Add(usr.Keychains)
					if(Chains.len<2)
						return
					var/Choice=input(usr, "What keychain are you equipping?", "Attach Keychain") in Chains
					var/KeySlot="Main"
					if(locate(/obj/Skills/Buffs/SpecialBuffs/Valor_Form, usr))
						KeySlot=alert(usr, "Which Keyblade are you setting this keychain to?", "Attach Keychain", "Main", "Sync")
					if(KeySlot=="Main")
						usr.KeychainAttached=Choice
						usr << "[Choice] set to keyblade!"
					else if(KeySlot=="Sync")
						usr.SyncAttached=Choice
						usr << "[Choice] set to sync blade!"
					if(usr.KeychainAttached==usr.SyncAttached)
						if(usr.KeybladeColor=="Light")
							usr.SyncAttached="Kingdom Key"
						else
							usr.SyncAttached="Kingdom Key D"
						usr << "You can't equip the same keyblade in both hands, so your sync blade has been reset to the default."

		Totsuka_no_Tsurugi//t2
			NeedsSword=1
			FlashDraw=1
			MakesSecondSword=1
			ABuffNeeded=list("Soul Resonance")
			SwordNameSecond="Totsuka"
			SwordIconSecond='Totsuka.dmi'
			SwordAscensionSecond=3
			SwordXSecond=-32
			SwordYSecond=-32
			SwordElementSecond="Fire"
			passives = list("SwordAscensionSecond" = 3, "SoulFire" = 1, "DoubleStrike" = 1)
			SoulFire=1
			DoubleStrike=1
			ActiveMessage="manifests the spiritual form of the predecesor of Kusanagi!"
			OffMessage="releases the blade of Totsuka back into the legend!"
			Cooldown=-1
			verb/Manifest_Totsuka()
				set category="Skills"
				src.Trigger(usr)
		Eye_of_Chaos
			NeedsSword=1
			TaxThreshold=0.5
			EndTaxDrain=0.0025
			SpdTaxDrain=0.0025
			RecovTaxDrain=0.0025
			FatigueDrain=0.005
			ABuffNeeded=list("Soul Resonance")
			NeedsHealth=50
			FINISHINGMOVE=1
			passives = list("TaxThreshold" = 0.5, "Curse" = 1, "PureDamage" = 4, "Pursuer" = 2, "Flicker" = 2)
			Curse=1
			PureDamage=4
			Pursuer=2
			Flicker=2
			TextColor="#FF3333"
			ActiveMessage="becomes a living nightmare, twisted by the destructive might of chaos!"
			OffMessage="can no longer sustain the true power of Soul Edge..."
			Cooldown=-1
			verb/Eye_of_Chaos()
				set category="Skills"
				src.Trigger(usr)
		Fate_of_Blood
			NeedsSword=1
			ABuffNeeded=list("Soul Resonance")
			LifeStealTrue=1//But you can steal it from others
			// NoDodge=1
			Instinct=3//never
			// SureHitTimerLimit=5
			passives = list("Instinct" = 3, "LifeStealTrue" = 1, "PureDamage" = -1)
			PureDamage = -1
			TimerLimit=60
			KenWave=5
			KenWaveSize=4
			KenWaveBlend=2
			KenWaveIcon='KenShockwaveBloodlust.dmi'
			TextColor="#FF6666"
			ActiveMessage="unseals the <font size=+2>grim fate of their blade</font size>..."
			OffMessage="has satisfied Dainsleif's cruel thirst for life..."
			Cooldown=-1
			verb/Fate_of_Blood()
				set category="Skills"
				//This has to happen when the buff turns ON, otherwise I'd use the built in variable.
				if(usr.CheckActive("Soul Resonance"))
					if(!src.Using)//If this weren't here, you could nerf yourself even if it didn't activate...
						if(!usr.BuffOn(src))
							usr.AddHealthCut(0.1)//lose 10% health permanently but it can be stolen back by true lifesteal.
				src.Trigger(usr)

		Aria_Chant
			Cooldown=1

			var/list/Aria

			verb/Aria_Chant()
				set category = "Skills"
				if(usr.AriaCount-2 == usr.SagaLevel && usr.UBWPath != "Feeble")
					usr << "You try to speak more of your aria, but you don't know any more lines..."
					return
				usr.AriaCount++
				if(usr.UBWPath == "Feeble")
					if(usr.AriaCount-2 > usr.SagaLevel)
						var/mult = 0.04 * max(1,(usr.AriaCount-usr.SagaLevel))
						usr.AddStrTax(mult)
						usr.AddEndTax(mult)
						usr.AddSpdTax(mult)
						usr.AddForTax(mult)
						usr.AddOffTax(mult)
						usr.AddDefTax(mult)
				for(var/mob/E in hearers(12,usr))
					E << output("<font color=[usr.Text_Color]>[usr][E.Controlz(usr)] says: [html_encode(Aria[usr.AriaCount])]", "icchat")
					E << output("<font color=[usr.Text_Color]>[usr][E.Controlz(usr)] says: [html_encode(Aria[usr.AriaCount])]", "output")
				if(usr.AriaCount == 8)
					usr.UnlimitedBladeWorks()

			verb/Shut_Circuits()
				set category = "Skills"
				if(!usr.AriaCount)
					usr << "Your circuits aren't fired up yet...!"
					return
				if(usr.AriaCount == 8 && usr.usingUBW)
					usr.stopUnlimitedBladeWorks()
				usr.AriaCount--
				usr << "You drop down an aria verse."

		Copy_Blade
			MakesSword = 1
			SwordName="Projected Blade"
			SwordAscension = 0
			SwordClass="Medium"
			SwordRefinement = 0
			ActiveMessage="'s hand grips out at air, before projecting a blade forth!"
			OffMessage = "'s conjured blade shatters in the air!"
			var/SlotsUsed = 0
			var/list/copiedBlades = list()
			var/obj/Items/Sword/currentBlade = null
			var/obj/Items/Sword/swordref
			var/projected = FALSE
			// verb/Copy_Blade()
			// 	set category = "Skills"
			// 	if(!usr.Target || usr.Target == usr)
			// 		usr << "You need a target."
			// 		return
			// 	if(!usr.Target.EquippedSword())
			// 		usr << "Your opponent isn't using a sword!"
			// 		return
			// 	if(usr.Target.EquippedSword().Conjured && usr.Target.EquippedSword().noHistory)
			// 		usr << "This blade has no history, it evades your attempt to copy it!"
			// 		return
			// 	if(length(copiedBlades)>=(usr.SagaLevel))
			// 		usr << "Your head feels close to bursting, you can't fit anything more...!!"
			// 		return
			// 	usr.OMessage(10, "[usr.name] seems to focus intently on [usr.Target.name]'s [usr.Target.EquippedSword()]...")
			// 	var/obj/Items/Sword/s = usr.Target.EquippedSword()

			// 	s.Update_Description()
			// 	var/confirm = alert("Do you want to copy this sword?\n[s.desc]",, "Yes", "No")
			// 	if(confirm == "Yes")
			// 		s = copyatom(s)
			// 		s.NoSaga = FALSE
			// 		s.Conjured = TRUE
			// 		s.suffix = null
			// 		s.Destructable = TRUE
			// 		s.ShatterCounter = s.ShatterMax
			// 		copiedBlades += s

			// verb/Remove_Blade()
			// 	set category = "Skills"
			// 	var/list/tempList = list("Cancel")
			// 	for(var/obj/i in copiedBlades)
			// 		tempList += i.name
			// 	var/removeThis = input("What blade do you want to remove?") in tempList
			// 	if(removeThis=="Cancel")
			// 		return

			// 	for(var/obj/j in copiedBlades)
			// 		if(j.name == removeThis)
			// 			if(currentBlade == j)
			// 				currentBlade = null
			// 			copiedBlades.Remove(j)
			// 			break
/*
			verb/Set_Projection_Name(swordName as text)
				set hidden = 1
				var/found = FALSE
				for(var/obj/Items/Sword/s in copiedBlades)
					if(s.name == swordName)
						usr << "Current projection set to [s.name]"
						found = TRUE
						currentBlade = s
						break
				if(!found)
					usr << "[swordName] not found in viable projections!"*/
			// verb/Set_Projection()
			// 	set category = "Skills"
			// 	var/list/tempList = list("Cancel")
			// 	for(var/obj/i in copiedBlades)
			// 		tempList += i.name
			// 	var/useThis = input("What blade do you want to use?") in tempList
			// 	if(useThis=="Cancel")
			// 		return
			// 	for(var/obj/j in copiedBlades)
			// 		if(j.name == useThis)
			// 			currentBlade = j
			// 			break
			// 	usr << "Current projection set to [currentBlade]."
			// 	currentBlade.Update_Description()
			// 	usr << "[currentBlade.desc]"


			// verb/True_Projection()
			// 	set category="Skills"
			// 	if(!usr.getAriaCount())
			// 		usr << "You can't project without your circuits active!"
			// 		return
			// 	if(!currentBlade && !projected)
			// 		usr << "You don't have a blade selected!"
			// 		return
			// 	if(usr.EquippedSword()&&!projected)
			// 		usr << "You can't have a blade out to project a new one!"
			// 		return
			// 	if(!projected)
			// 		var/costCalculation = (length(currentBlade.Techniques) + length(currentBlade.passives) + currentBlade.Ascended + currentBlade.InnatelyAscended)/usr.SagaLevel
			// 		if(usr.UBWPath == "Feeble")
			// 			costCalculation /= 1 + usr.SagaLevel/6
			// 		costCalculation = clamp(1, costCalculation, 10)
			// 		costCalculation *= glob.UBW_COPY_COST
			// 		if(usr.ManaAmount < costCalculation)
			// 			usr << "You don't have the mana to project [currentBlade.name]!"
			// 			return
			// 		usr.OMessage(10, "[usr.name] projects a specific blade to their hand; [currentBlade.name]!")
			// 		usr.LoseMana(costCalculation)
			// 		var/obj/Items/Sword/s = copyatom(currentBlade)
			// 		s.Conjured = TRUE
			// 		s.suffix = null
			// 		s.NoSaga = FALSE
			// 		s.Destructable = TRUE
			// 		s.ShatterTier = 2
			// 		if(usr.UBWPath == "Firm")
			// 			s.ShatterTier -= 1
			// 			if(usr.SagaLevel >=5)
			// 				s.ShatterTier -= 1
			// 		usr.contents += s
			// 		s.ObjectUse(usr)
			// 		swordref = s
			// 		projected = TRUE
			// 	else
			// 		for(var/obj/Items/Sword/s in usr.contents)
			// 			if(s == swordref)
			// 				usr.OMessage(10, "[usr.name]'s current projection shatters!")
			// 				s.ObjectUse(usr)
			// 				del s
			// 		projected = FALSE

		Projection
			MakesSword=1
			SwordName="Projected Blade"
			SwordAscension = 0
			SwordClass="Medium"
			SwordRefinement = 0
			ActiveMessage="'s hand grips out at air, before projecting a blade forth!"
			OffMessage = "'s conjured blade shatters in the air!"
			var/icon/wooden_icon
			var/wooden_x = 0
			var/wooden_y = 0
			var/icon/light_icon
			var/light_x = 0
			var/light_y = 0
			var/icon/med_icon
			var/med_x = 0
			var/med_y = 0
			var/icon/heavy_icon
			var/heavy_x = 0
			var/heavy_y = 0
			verb/Customize_Projects()
				set category = "Other"
				var/choice = input(usr, "What icon?") in list("wooden","light","med","heavy")
				vars["[choice]_icon"] = input(usr, "selecting icon for [choice]") as icon|null
				vars["[choice]_x"] = input(usr, "WHAT X") as num
				vars["[choice]_y"] = input(usr, "WHAT Y") as num
			verb/Projection()
				set category="Skills"
				if(!usr.getAriaCount())
					usr << "You can't project without your circuits active!"
					return

				ManaCost = usr.getUBWCost(1)

				SwordShatterTier = rand(4,8) - (ceil(usr.SagaLevel/3))
				if(!usr.BuffOn(src))
					switch(usr.getAriaCount())
						if(1)
							SwordAscension = 1
						if(2)
							SwordAscension = 2
						if(3)
							SwordAscension = 3
						if(4)
							SwordAscension = 4
						if(5)
							SwordAscension = 4
						if(6)
							SwordAscension = 5
						if(7)
							SwordAscension = 6
						if(8 to 9)
							SwordAscension = 7
				passives = list("SwordDamage" = SwordAscension/2) // so it can go over 6
				var/classRNG = rand(1,4)
				switch(classRNG)
					if(1)
						if(wooden_icon)
							SwordIcon = wooden_icon
							SwordX = wooden_x
							SwordY = wooden_y
						else
							SwordIcon = 'Bokken.dmi'
						SwordClass = "Wooden"
					if(2)
						if(light_icon)
							SwordIcon = light_icon
							SwordX = light_x
							SwordY = light_y
						else
							SwordIcon = 'LightSword.dmi'
						SwordClass = "Light"
					if(3)
						if(med_icon)
							SwordIcon = med_icon
							SwordX = med_x
							SwordY = med_y
						else
							SwordIcon = 'MediumSword.dmi'
						SwordClass = "Medium"
					if(4)
						if(heavy_icon)
							SwordIcon = heavy_icon
							SwordX = heavy_x
							SwordY = heavy_y
						else
							SwordIcon = 'HeavySword.dmi'
						SwordClass = "Heavy"
				if(usr.getAriaCount() < 4)
					var/RefinementRNG = rand(1,2)
					switch(RefinementRNG)
						if(1)
							SwordRefinement = 1
						if(2)
							SwordRefinement = 0
				else
					SwordRefinement = 1
				var/upperLimit = 13-floor((usr.getAriaCount()/2))
				var/ElementRNG = rand(1,upperLimit)
				switch(ElementRNG)
					if(1)
						SwordElement = "Fire"
					if(2)
						SwordElement = "Wind"
					if(3)
						SwordElement = "Earth"
					if(4)
						SwordElement = "Water"
					if(5)
						SwordElement = "Poison"
					if(6)
						SwordElement = "Silver"
					if(7)
						SwordElement = "Dark"
					if(8)
						SwordElement = "Light"
					if(9)
						SwordElement = "Chaos"
					if(10 to 13)
						SwordElement = ""
				src.Trigger(usr)
				if(usr.BuffOn(src))
					usr << "[SwordElement] [SwordClass] Sword with [SwordAscension]([passives["SwordDamage"]]) Damage"

		Avalon
			StableHeal=1
			HealthHeal=1.2
			KenWave=1
			KenWaveIcon='SparkleYellow.dmi'
			KenWaveSize=3
			KenWaveX=105
			KenWaveY=105
			ActiveMessage="taps into their greatest Noble Phantasm: <b>Avalon</b>."
			OffMessage="lets the Fae artifact fade back into slumber."
			DrainAll=0.5
			// TimerLimit=10
			Cooldown=0
			var/tmp/last_avalon = 0
			adjust(mob/p)
				DrainAll = 1-(p.SagaLevel*0.1)
				HealthHeal = 0.3+(p.SagaLevel*0.01)
			verb/Avalon()
				set category="Skills"
				src.Trigger(usr)
			verb/Stitch_Wounds()
				set category="Skills"
				if(usr.ManaAmount >= 25)
					if(last_avalon + glob.AVALON_COOLDOWN < world.time)
						if(usr.BPPoison<1)
							usr.BPPoison=1
							usr.BPPoisonTimer=0
						if(usr.Maimed>0)
							usr.Maimed--
							OMsg(usr, "[src] regrows a maiming as the Fae magics course through them!")
						last_avalon = world.time
						usr << "Avalon maim heal will be back in [glob.AVALON_COOLDOWN/10] seconds."
						usr.LoseMana(25)
				else
					usr << "You need 25 mana."

		GaeBolg
			MakesSword=1
			SwordName="Gae Bolg"
			SwordIcon='Gae Bolg.dmi'
			SwordX=-8
			SwordY=-8
			SwordClass="Medium"
			ManaCost = 10
			Cooldown = 30
			ActiveMessage="calls forth the Cursed Spear: <b>Gae Bolg</b>!"
			OffMessage = "'s cursed spear shatters apart!"
			verb/Gae_Bolg()
				set category="Skills"
				if(!usr.getAriaCount())
					usr << "You can't project without your circuits active!"
					return
				SwordShatterTier = rand(7,8) - (ceil(usr.SagaLevel/3))
				ManaCost = usr.getUBWCost(2)
				if(usr.getAriaCount() < 4)
					var/RefinementRNG = rand(1,2)
					switch(RefinementRNG)
						if(1)
							SwordRefinement = 1
						if(2)
							SwordRefinement = 0
				else
					SwordRefinement = 1
				var/upperLimit = 13-floor((usr.getAriaCount()/2))
				var/ElementRNG = rand(1,upperLimit)
				switch(ElementRNG)
					if(1)
						SwordElement = "Fire"
					if(2)
						SwordElement = "Wind"
					if(3)
						SwordElement = "Earth"
					if(4)
						SwordElement = "Water"
					if(5)
						SwordElement = "Poison"
					if(6)
						SwordElement = "Silver"
					if(7)
						SwordElement = "Dark"
					if(8)
						SwordElement = "Light"
					if(9)
						SwordElement = "Chaos"
					if(10 to 13)
						SwordElement = null
				SwordAscension = max(0, usr.getAriaCount() / 2)
				PureDamage = max(0, ceil(usr.getAriaCount() / 2))
				Instinct = max(0, usr.getAriaCount() / 3)
				CursedWounds = 0
				if(usr.getAriaCount()>=3)
					CursedWounds = 1
				/*
				switch(usr.getAriaCount())
					if(1)
						SwordAscension = 2
						CursedWounds = 0
						PureDamage = 1
						Instinct = 0
					if(2)
						SwordAscension = 2
						CursedWounds = 0
						PureDamage = 1
						Instinct = 1
					if(3)
						SwordAscension = 3
						CursedWounds = 1
						PureDamage = 2
						Instinct = 1
					if(4)
						SwordAscension = 3
						CursedWounds = 1
						PureDamage = 2
						Instinct = 2
					if(5)
						SwordAscension = 4
						CursedWounds = 1
						PureDamage = 2
						Instinct = 2
					if(6)
						SwordAscension = 4
						CursedWounds = 1
						PureDamage = 3
						Instinct = 2
					if(7)
						SwordAscension = 5
						CursedWounds = 1
						PureDamage = 3
						Instinct = 3
					if(8 to 9)
						SwordAscension = 6
						CursedWounds = 1
						PureDamage = 4
						Instinct = 4*/
				TimerLimit = 60 * (clamp(1,usr.SagaLevel/2,4))
				passives = list("PureDamage" = PureDamage, "CursedWounds" = CursedWounds, "Instinct" = Instinct)
				if(usr.UBWPath=="Feeble"&&usr.SagaLevel>=4)
					src.VaizardHealth = 2.5*(max(1,usr.SagaLevel-4))
					WoundCost = 5 - (max(1,usr.SagaLevel-4))
				else
					src.VaizardHealth = 0
					WoundCost = 0
				src.Trigger(usr)

		KanshouByakuya
			MakesSword=1
			SwordClass="Light"
			SwordX = -32
			SwordY = -32
			SwordIcon='Kanshakuya.dmi'
			ManaCost = 10
			Cooldown = 1
			ActiveMessage="calls forth the married blades: <b>Kanshou & Byakuya</b>!"
			OffMessage = "'s married blades shatter apart!"
			verb/Kanshou_Byakuya()
				set name = "Kanshou & Byakuya"
				set category="Skills"
				if(!usr.getAriaCount())
					usr << "You can't project without your circuits active!"
					return
				ManaCost = usr.getUBWCost(0.75)
				SwordShatterTier = 4 - (ceil(usr.SagaLevel/3))
				if(usr.getAriaCount() < 4)
					var/RefinementRNG = rand(1,2)
					switch(RefinementRNG)
						if(1)
							SwordRefinement = 1
						if(2)
							SwordRefinement = 0
				else
					SwordRefinement = 1
				var/upperLimit = 13-floor((usr.getAriaCount()/2))
				var/ElementRNG = rand(1,upperLimit)
				switch(ElementRNG)
					if(1)
						SwordElement = "Fire"
					if(2)
						SwordElement = "Wind"
					if(3)
						SwordElement = "Earth"
					if(4)
						SwordElement = "Water"
					if(5)
						SwordElement = "Poison"
					if(6)
						SwordElement = "Silver"
					if(7)
						SwordElement = "Dark"
					if(8)
						SwordElement = "Light"
					if(9)
						SwordElement = "Chaos"
					if(10)
						SwordElement = "HellFire"
					if(11 to 13)
						SwordElement = null
				SwordAscension = max(0, usr.getAriaCount() / 2)
				Flow = max(0, ceil(usr.getAriaCount() / 3))
				Deflection = max(0, usr.getAriaCount() / 2)
				DoubleStrike = max(0, ceil(usr.getAriaCount() / 2.5))
/*				switch(usr.getAriaCount())
					if(1)
						SwordAscension = 2
						Flow = 0
						Deflection = 1
					if(2)
						SwordAscension = 2
						Flow = 1
						Deflection = 1
					if(3)
						SwordAscension = 3
						Flow = 2
						Deflection = 2
					if(4)
						SwordAscension = 3
						Flow = 3
						Deflection = 2
					if(5)
						SwordAscension = 4
						Flow = 3
						Deflection = 2
					if(6)
						SwordAscension = 4
						Flow = 3
						Deflection = 3
					if(7)
						SwordAscension = 5
						Flow = 3
						Deflection = 4
					if(8 to 9)
						SwordAscension = 6
						Flow = 4
						Deflection = 4
				switch(usr.getAriaCount())
					if(1 to 3)
						DoubleStrike = 1
					if(4 to 6)
						DoubleStrike = 2
					if(7 to 9)
						DoubleStrike = 3*/
				passives = list("DoubleStrike" = DoubleStrike, "Flow" = Flow, "Deflection" = Deflection)
				if(usr.UBWPath=="Feeble"&&usr.SagaLevel>=4)
					src.VaizardHealth = 2.5*(max(1,usr.SagaLevel-4))
					WoundCost = 5 - (max(1,usr.SagaLevel-4))
				else
					src.VaizardHealth = 0
					WoundCost = 0
				src.Trigger(usr)

		RuleBreaker
			MakesSword=1
			SwordName="Rule Breaker"
			SwordIcon='RuleBreaker.dmi'
			SwordX=-32
			SwordY=-32
			SwordClass="Light"
			ManaCost = 10
			Cooldown = 1
			ActiveMessage="calls forth the ultimate anti-magic Noble Phantasm: <b>Rule Breaker</b>!"
			OffMessage = "'s Rule Breaker shatters apart!"
			verb/Rule_Breaker()
				set category="Skills"
				if(!usr.getAriaCount())
					usr << "You can't project without your circuits active!"
					return
				ManaCost = usr.getUBWCost(1.5)
				SwordShatterTier = rand(6,8) - (ceil(usr.SagaLevel/3))
				if(usr.getAriaCount() < 4)
					var/RefinementRNG = rand(1,2)
					switch(RefinementRNG)
						if(1)
							SwordRefinement = 1
						if(2)
							SwordRefinement = 0
				else
					SwordRefinement = 1
				var/upperLimit = 13-floor((usr.getAriaCount()/2))
				var/ElementRNG = rand(1,upperLimit)
				switch(ElementRNG)
					if(1)
						SwordElement = "Fire"
					if(2)
						SwordElement = "Wind"
					if(3)
						SwordElement = "Earth"
					if(4)
						SwordElement = "Water"
					if(5)
						SwordElement = "Poison"
					if(6)
						SwordElement = "Silver"
					if(7)
						SwordElement = "Dark"
					if(8)
						SwordElement = "Light"
					if(9)
						SwordElement = "Chaos"
					if(10)
						SwordElement = "HellFire"
					if(11 to 13)
						SwordElement = null
				SwordAscension = max(0, usr.getAriaCount() / 2)
				ManaSeal = max(0, ceil(usr.getAriaCount() / 2))
				SoftStyle = max(0, usr.getAriaCount() / 3)
				BulletKill = 0
				if(usr.getAriaCount() >= 3)
					BulletKill = 1
				/*
				switch(usr.getAriaCount())
					if(1)
						SwordAscension = 1
						BulletKill = 0
						ManaSeal = 1
						SoftStyle = 2
					if(2)
						SwordAscension = 1
						BulletKill = 0
						ManaSeal = 1
						SoftStyle = 2
					if(3)
						SwordAscension = 2
						BulletKill = 1
						ManaSeal = 1
						SoftStyle = 3
					if(4)
						SwordAscension = 2
						BulletKill = 1
						ManaSeal = 2
						SoftStyle = 3
					if(5)
						SwordAscension = 3
						BulletKill = 1
						ManaSeal = 3
						SoftStyle = 4
					if(6)
						SwordAscension = 3
						BulletKill = 1
						ManaSeal = 3
						SoftStyle = 4
					if(7)
						SwordAscension = 4
						BulletKill = 1
						ManaSeal = 3
						SoftStyle = 4
					if(8 to 9)
						SwordAscension = 5
						BulletKill = 1
						ManaSeal = 4
						SoftStyle = 5*/
				passives = list("BulletKill" = BulletKill, "SoulFire" = ManaSeal, "SoftStyle" = SoftStyle)
				if(usr.UBWPath=="Feeble"&&usr.SagaLevel>=4)
					src.VaizardHealth = 2.5*(max(1,usr.SagaLevel-4))
					WoundCost = 5 - (max(1,usr.SagaLevel-4))
				else
					src.VaizardHealth = 0
					WoundCost = 0
				src.Trigger(usr)

		Rho_Aias
			TimerLimit=100
			VaizardHealth=5
			VaizardShatter=1
			IconLock='RhoAias.dmi'
			LockX = -48
			LockY = -48
			IconLockBlend=2
			IconLayer=-1
			IconApart=1
			OverlaySize=0.5
			ActiveMessage="projects the unbreakable Noble Phantasm: <b>Rho Aias</b>!"
			OffMessage="lets the many petals fall away..."
			Cooldown=-1
			verb/Rho_Aias()
				set category="Skills"
				if(!usr.getAriaCount())
					usr << "You can't project without your circuits active!"
					return
				ManaCost = usr.getUBWCost(1.5)
				VaizardHealth = usr.getAriaCount()*2.5
				WoundCost = usr.getAriaCount() / 3
				src.Trigger(usr)

		Will_Knife
			MakesSword=1
			SwordName="Will Knife"
			SwordIcon='willKnifev2.dmi'
			SwordX=-6
			SwordY=-13
			passives = list("SwordAscension" = 1, "SpiritSword" = 0.5)
			SwordClass="Wooden"
			ActiveMessage="condenses their bravery!"
			var/saved_icon = 'GaoGaoFists.dmi'
			verb/Modify_Armament()
				set category="Skills"
				src.SwordIcon=input(usr, "What icon will your Will Knife use?", "Will Knife Icon") as icon|null
				src.SwordX=input(usr, "Pixel X offset.", "Will Knife Icon") as num
				src.SwordY=input(usr, "Pixel Y offset.", "Will Knife Icon") as num
				src.SwordClass=input(usr, "What class will your Will Knife be?", "Will Knife Icon") in list("Heavy", "Medium", "Light", "Wooden")
				saved_icon = input(usr, "What do you want your unarmed variant icon to be?") as icon|null
				LockX = input(usr, "Pixel X offset.", "Unarmed Variant Icon") as num
				LockY = input(usr, "Pixel Y offset.", "Unarmed Variant Icon") as num
			adjust(mob/p)
				if(p.usingStyle("UnarmedStyle"))
					MakesSword = 0
					passives = list("UnarmedDamage" = clamp(usr.SagaLevel/2, 1,6), "SpiritHand" = 0.8 * (usr.SagaLevel), "BladeFisting" = 1)
					IconLock = saved_icon
				else
					passives = list("SwordAscension" = clamp(usr.SagaLevel - 1,1,6), "SpiritSword" = 0.2 * (usr.SagaLevel), "BladeFisting" = 1)
					MakesSword = 1
					IconLock = null
			verb/Audacious_Bravery_Armament()
				set category="Skills"
				src.Trigger(usr)

		Protect_Shade
			TimerLimit=5
			IconLock='Android Shield.dmi'
			IconLockBlend=2
			IconLayer=-1
			IconApart=1
			OverlaySize=1.2
			ActiveMessage="projects an unbreakable barrier!"
			OffMessage="collapses their barrier..."
			Cooldown=180
			SBuffNeeded="Protect Brave"
			verb/Protect_Shade()
				set category="Skills"
				if(!usr.BuffOn(src))
					passives = list("Deflection" = usr.SagaLevel/2, "Reversal" = 0.1 * usr.SagaLevel)
					TimerLimit = 10 * usr.SagaLevel
					Cooldown = 180 - (15 * usr.SagaLevel)
				src.Trigger(usr)
		Protect_Wall
			TimerLimit=5
			VaizardHealth=10
			VaizardShatter=1
			IconLock='wall.dmi'
			IconLayer=-1
			IconLockBlend=2
			IconApart=1
			OverlaySize=2
			ActiveMessage="projects an absolutely unbreakable barrier!"
			OffMessage="collapses their barrier..."
			Cooldown=600
			SBuffNeeded="Protect Brave"
			verb/Protect_Wall()
				set category="Skills"
				if(!usr.BuffOn(src))
					VaizardHealth = (1.5 * usr.SagaLevel)
					TimerLimit = 5 * usr.SagaLevel
					Cooldown = 300
				if(usr.SpecialBuff)
					if(usr.SpecialBuff.BuffName!="Genesic Brave"&&src.SBuffNeeded!="Protect Brave")
						src.SBuffNeeded="Protect Brave"
					else if(usr.SpecialBuff.BuffName=="Genesic Brave")
						src.SBuffNeeded="Genesic Brave"
				src.Trigger(usr)
		Plasma_Hold
			TimerLimit=2
			TargetOverlay='Overdrive.dmi'
			TargetOverlayX=0
			TargetOverlayY=0
			Connector='BE.dmi'
			StunAffected=1
			AffectTarget=1
			Range=14
			ActiveMessage="shoots crackling plasma at their target!"
			OffMessage="releases their hold..."
			Cooldown=30
			SBuffNeeded="Protect Brave"
			verb/Plasma_Hold()
				set category="Skills"
				if(usr.SpecialBuff)
					if(usr.SpecialBuff.BuffName!="Genesic Brave"&&src.SBuffNeeded!="Protect Brave")
						src.SBuffNeeded="Protect Brave"
					else if(usr.SpecialBuff.BuffName=="Genesic Brave")
						src.SBuffNeeded="Genesic Brave"
				src.Trigger(usr)
		Domain_Expansion
			var/tmp/effected = list()
			var/range = 10
			var/identifier = null
			Cooldown = -1
			ActiveMessage="releases their Domain!"
			OffMessage="conceals their Domain...."
			proc/animation(mob/p, range)
				if(!range) range = 8
				for(var/atom/M in range(range, p))
					spawn()animate(M, color = list(-1,0,0, 0,-1,0, 0,0,-1, 1,1,1), time = 7)
					effected += M
				sleep(3)
				for(var/atom/M in effected)
					spawn()animate(M, color = null, time = 3)
					spawn()animate(M, color = list(0.6,0,0.1, 0,0.6,0.1, 0,0,0.7, 0,0,0), time = 3)
				sleep(6)
				for(var/atom/M in effected)
					spawn()animate(M, color = null, time = 3)
			verb/Domain_Expansion_Target()
				set category = "Skills"
				if(usr.Target==usr || !usr.Target)
					usr << "Can't target [usr.Target == usr ? " yourself" : " not have a target"]."
					return
				src.Trigger(usr)
				if(usr.BuffOn(src)) // this means it worked and its on
					animation(usr)
					usr.DomainExpansion(identifier, 0, 1)
				else
					usr.stopDomainExapansion()
			verb/Domain_Expansion_Wide()
				set category = "Skills"
				src.Trigger(usr)
				if(usr.BuffOn(src)) // this means it worked and its on
					animation(usr, range)
					usr.DomainExpansion(identifier, range, 0)
				else
					usr.stopDomainExapansion()
		Dividing_Driver
			WarpZone=1
			Duel=1
			passives = list("Duelist" = 1, "CoolerAfterImages" = 3)
			CastingTime=2
			KenWave=3
			KenWaveSize=3
			Range=15
			KenWaveIcon='KenShockwaveLegend.dmi'
			TurfShift='StarPixel.dmi'
			Cooldown=-1
			SendBack = TRUE
			ActiveMessage="drives away the space between them and their target, drawing the fight into a secured dimension!"
			OffMessage="allows the divided space to collapse upon itself..."
			verb/Dividing_Driver()
				set category="Skills"
				if(usr.Target==usr || !usr.Target)
					usr << "Can't target [usr.Target == usr ? " yourself" : " not have a target"]."
					return
				if(src.WarpTarget)
					var/found=0
					for(var/mob/Players/m in players)
						if(m==src.WarpTarget)
							usr.SetTarget(m)
							found=1
					if(!found)
						usr << "You can't seal the target inside the divide."
						return
				src.Trigger(usr)

		Mangekyou_Sharingan
			TaxThreshold=0.7
			OffTaxDrain=0.0002
			DefTaxDrain=0.0002
			SBuffNeeded="Sharingan"
			passives = list("AutoAnger" = 1,"BuffMastery" = 5, "Deflection" = 1, "Flow" = 1)
			BuffMastery=5
			AutoAnger = 1
			Cooldown=-1
			Deflection=1
			Flow=1
			ActiveMessage="gives into hatred; their tomoe twist into a kaleidoscope pattern!"
			OffMessage="closes their eyes with a pained look..."
			verb/Mangekyou_Sharingan()
				set category="Skills"
				passives = list("BuffMastery" = 1 + usr.SagaLevel/2, "Deflection" = 1, "Flow" = 1, "AutoAnger" = 1, "PUSpike" = -15)
				if(!usr.BuffOn(src))
					if(usr.SagaLevel>=5)
						src.OffTaxDrain=0
						src.DefTaxDrain=0
						if(usr.OffTax)
							usr.OffTax=0
						if(usr.OffCut)
							usr.OffCut=0
						if(usr.DefTax)
							usr.DefTax=0
						if(usr.DefCut)
							usr.DefCut=0
						src.OffMessage="unravels the kaleidoscope form of their tomoe..."
					switch(usr.SharinganEvolution)
						if("Sacrifice")
							src.BuffTechniques=list("/obj/Skills/AutoHit/Tsukiyomi","/obj/Skills/AutoHit/Amaterasu", "/obj/Skills/AutoHit/Sharingan_Genjutsu")
						if("Hatred")
							src.BuffTechniques=list("/obj/Skills/AutoHit/Amaterasu2","/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Kagutsuchi", "/obj/Skills/AutoHit/Sharingan_Genjutsu")
							passives["Instinct"] = 1
							src.Instinct=1
						if("Resolve")
							BuffTechniques = list("/obj/Skills/AutoHit/Sharingan_Genjutsu")
							passives = list("BuffMastery" = 1 + usr.SagaLevel/2, "Deflection" = 1 + usr.SagaLevel/4, "Flow" = 1, "Instinct" = 1, "FluidForm" = 1, "Godspeed" = usr.SagaLevel/4,
							"LikeWater" = usr.SagaLevel/2,  "PUSpike" = -20)
							src.LikeWater=usr.SagaLevel / 2
							src.Flow=1
							src.Instinct=1
							src.Deflection= 1 + usr.SagaLevel / 4
							Godspeed= usr.SagaLevel / 4
							if(OffTaxDrain||DefTaxDrain)
								OffTaxDrain=0.004
								DefTaxDrain=0.004
				src.Trigger(usr)
		Susanoo
			DarkChange=1
			FlashChange=1
			VaizardShatter=1
			Cooldown=-1
			passives = list("GiantForm" = 1, "HybridStrike" = 1)
			IconLockBlend=2
			LockX=-32
			LockY=-32
			ForMult = 1.2
			EndMult = 1.1
			DefMult = 0.6
			ActiveMessage="summons an etheral ribcage around them!"
			OffMessage="dissipates the etheral protection..."
			proc/init(mob/p)
				if(altered) return
				switch(usr.SharinganEvolution)
					if("Sacrifice")
						src.IconLock='Susano-I.dmi'
						if(usr.SagaLevel>=7)
							src.OverlaySize=3
							src.IconLock='Susano Itachi.dmi'
							src.LockX=-5
							src.LockY=-5
					if("Hatred")
						src.IconLock='Susano-S.dmi'
						if(usr.SagaLevel>=7)
							src.OverlaySize=3
							src.IconLock='Susano Sasuke.dmi'
							src.LockX=-5
							src.LockY=-5
					if("Resolve")
						src.IconLock='Susano-M.dmi'
						if(usr.SagaLevel>=7)
							src.OverlaySize=3
							src.IconLock='Susano Madara.dmi'
							src.LockX=-5
							src.LockY=-5
			verb/Susanoo()
				set category="Skills"
				init(usr)
				if(!usr.BuffOn(src))
					passives = list("GiantForm" = 1, "HybridStrike" = 1, "PureReduction" = 1, "Flow" = -1)
					VaizardHealth = 6 * (usr.SagaLevel-3)
					EnergyCost = 10 - (usr.SagaLevel-4)
					FatigueCost = 6 - (usr.SagaLevel-4)
					switch(usr.SharinganEvolution)
						if("Resolve")
							passives = list("NoDodge" = 0, "GiantForm" = 1,\
							"HybridStrike" = 1, "SweepingStrike" = 1, "Flow" = -1, "Instinct" = -1, "PureDamage" = 2, "PureReduction" = 2)
							VaizardHealth += 2 * (usr.SagaLevel-3)
					if(usr.SagaLevel>=5)
						DefMult = 0.8
						src.ActiveMessage="conjures a partially humanoid figure around them!"
						src.OffMessage="dissipates the mighty avatar..."
					if(usr.SagaLevel>=6)
						DefMult = 1
						Cooldown = 240
						src.ActiveMessage="conjures a fully humanoid, titanic figure around them!"
						src.OffMessage="dissipates the divine avatar..."
				src.Trigger(usr)
		// Rinnegan
		// 	SBuffNeeded="Sharingan"
		// 	WoundDrain=0.05
		// 	GodKi=0.5
		// 	Cooldown=-1
		// 	IconLock='RinneganEyes.dmi'
		// 	BuffTechniques=list("/obj/Skills/Six_Paths_of_Pain")
		// 	ActiveMessage="ascends into enlightment as their eyes perceive all six paths of Samsara!"
		// 	OffMessage="closes their eyes to the truth of the world..."
		// 	verb/Rinnegan()
		// 		set category="Skills"
		// 		src.Trigger(usr)

		Dance_Of_The_Full_Moon
			StyleNeeded="Hiten Mitsurugi"
			SpecialBuffLock=1
			NeedsSecondSword=1
			StrMult = 1.2
			SpdMult = 1.3
			OffMult = 1.3
			passives = list("SpecialBuffLock" = 1,"DoubleStrike" = 2, "Reversal" = 0.5, "Deflection" = 2, "Godspeed" = 2, "Flow" = 1)
			DoubleStrike=2
			Reversal=1
			Deflection=2
			Godspeed=2
			Flow=1
			ActiveMessage="draws a second blade in display of mastery of their style!"
			OffMessage="sheathes their second blade..."
			verb/Dance_Of_The_Full_Moon()
				set category="Skills"
				src.Trigger(usr)

		Celestial_Ascension
			passives = list("Purity" = 1, "BeyondPurity" = 1)
			Purity=1
			BeyondPurity=1
			ActiveMessage="reveals their true celestial nature!"
			OffMessage="represses their celestial nature..."
			verb/Celestial_Ascension()
				set category="Skills"
				src.Trigger(usr)

		Boss_Form
			passives = list("GiantForm" = 1, "CallousedHands" = 0.1, "SweepingStrike" = 1, "KBRes" = 2)
			GiantForm=1
			Enlarge=2
			SpdMult = 0.8
			DefMult = 0.8
			ActiveMessage="expands to become the monster they are meant to be!"
			OffMessage="represses their monstrous size..."
			verb/Boss_Form()
				set category="Skills"
				if(!altered)
					passives = list("GiantForm" = 1, "CallousedHands" = 0.1, "SweepingStrike" = 1, "KBRes" = 2)
				src.Trigger(usr)

//Secrets
		Haki
			Cooldown=0
			Haki_Armament
				Hardening=1
				NoForcedWhiff=1
				adjust(mob/p)
					if(altered) return
					var/secretLevel = p.secretDatum.currentTier
					passives = list("Hardening" = clamp(secretLevel,1,2), "NoForcedWhiff" = 1, "UnarmedDamage" = secretLevel/2, "SwordDamage" = secretLevel/2 )
					strAdd = 0.1 * secretLevel
					endAdd = 0.05 * secretLevel
				Trigger(mob/User, Override = 1)
					if(!User.BuffOn(src))
						adjust(User)
					..()

			Haki_Armor//Specialized
				TimerLimit=15
				Hardening=2
				KBRes=2
				KBMult=2
				ActiveMessage="darkens their entire body with indomitable willpower!"
				adjust(mob/p)
					if(altered) return
					var/secretLevel = p.secretDatum.currentTier
					passives = list("Hardening" = clamp(secretLevel,1,4), "KBRes" = secretLevel, "KBMult" = secretLevel)
					StrMult = 1.05 + (0.05 * secretLevel)
					EndMult = 1.05 + (0.05 * secretLevel)
					TimerLimit = 20 + (10 * secretLevel)
				Trigger(mob/User, Override = 1)
					if(!User.BuffOn(src))
						adjust(User)
					..()
			Haki_Armor_Lite//Not specialized
				TimerLimit=15
				StrMult=1.25
				EndMult=1.25
				ActiveMessage="bolsters their entire body with willpower!"
				adjust(mob/p)
					if(altered) return
					var/secretLevel = p.secretDatum.currentTier
					passives = list("Hardening" = secretLevel/2)
					StrMult = 1 + (0.05 * secretLevel)
					EndMult = 1 + (0.05 * secretLevel)
					TimerLimit = 15 + (5 * secretLevel)
				Trigger(mob/User, Override = 1)
					if(!User.BuffOn(src))
						adjust(User)
					..()
			Haki_Shield//Specialized
				TimerLimit=15
				PureReduction=2
				Deflection=1
				CounterMaster=3
				KBAdd=3
				ActiveMessage="reflects every attack against them with enormous willpower!"
				adjust(mob/p)
					if(altered) return
					var/secretLevel = p.secretDatum.currentTier
					passives = list("PureReduction" = clamp(secretLevel/2,1,3), "Deflection" = clamp(secretLevel,1,3), "CounterMaster" = clamp(secretLevel,2,5), "KBAdd" = 3)
					TimerLimit = 15 + (10 * secretLevel)
				Trigger(mob/User, Override = 1)
					if(!User.BuffOn(src))
						adjust(User)
					..()
			Haki_Shield_Lite//Not specialized
				TimerLimit=7
				passives = list("PureReduction" = 1, "Deflection" = 1)
				ActiveMessage="shields their body from attack with their willpower!"
				adjust(mob/p)
					if(altered) return
					var/secretLevel = p.secretDatum.currentTier
					passives = list("PureReduction" = clamp(secretLevel/2,0.5,1.5), "Deflection" = 1)
					TimerLimit = 10 + (5 * secretLevel)
				Trigger(mob/User, Override = 1)
					if(!User.BuffOn(src))
						adjust(User)
					..()
			Haki_Observation
				adjust(mob/p)
					if(altered) return
					var/secretLevel = p.secretDatum.currentTier
					passives = list("Instinct" = clamp(secretLevel, 1, 5), "Flow" = clamp(secretLevel, 1, 5), "NoWhiff" = 1, "CheapShot" = secretLevel/3)

				Trigger(mob/User, Override = 1)
					if(!User.BuffOn(src))
						adjust(User)
					..()
			Haki_Future_Flash
				TimerLimit=50
				SureHitTimerLimit=15
				SureDodgeTimerLimit=15
				Cooldown = 40
				ActiveMessage="peers into the future to grasp their ambitions!"
				adjust(mob/p)
					if(altered) return
					var/secretLevel = p.secretDatum.currentTier
					TimerLimit = 40 + (5 * secretLevel)
					OffMult = 1.15 + (0.05 * secretLevel)
					DefMult = 1.2 + (0.1 * secretLevel)
					SureHitTimerLimit = 35 - (5 * secretLevel)
					SureDodgeTimerLimit = 35 - (5 * secretLevel)
					Cooldown = 60 + (2 * secretLevel)
				Trigger(mob/User, Override = 1)
					if(!User.BuffOn(src))
						adjust(User)
					..()
			Haki_Future_Flash_Lite
				TimerLimit=25
				OffMult=1.25
				DefMult=1.25
				SureHitTimerLimit=20
				SureDodgeTimerLimit=20
				ActiveMessage="gains a small glimpse of their future!"
				adjust(mob/p)
					if(altered) return
					var/secretLevel = p.secretDatum.currentTier
					TimerLimit = 20 + (5 * secretLevel)
					OffMult = 1.1 + (0.05 * secretLevel)
					DefMult = 1.1 + (0.05 * secretLevel)
					SureHitTimerLimit = 45 - (5 * secretLevel)
					SureDodgeTimerLimit = 45 - (5 * secretLevel)
					Cooldown = 40 + (2.5 * secretLevel)
				Trigger(mob/User, Override = 1)
					if(!User.BuffOn(src))
						adjust(User)
					..()
			Haki_Relax
				TimerLimit=30
				passives = list("Flow" = 2)
				Flow=2
				ActiveMessage="weaves through every incoming attacks!"
				adjust(mob/p)
					if(altered) return
					var/secretLevel = p.secretDatum.currentTier
					TimerLimit = 10 + (5 * secretLevel)
					passives = list("Flow" = secretLevel)
				Trigger(mob/User, Override = 1)
					if(!User.BuffOn(src))
						adjust(User)
					..()
			Haki_Relax_Lite
				TimerLimit=15
				passives = list("Flow" = 1)
				Flow=1
				ActiveMessage="determines trajectories of incoming strikes at a glance!"
				adjust(mob/p)
					if(altered) return
					var/secretLevel = p.secretDatum.currentTier
					TimerLimit = 5 + (5 * secretLevel)
					passives = list("Flow" = secretLevel/2)
				Trigger(mob/User, Override = 1)
					if(!User.BuffOn(src))
						adjust(User)
					..()

		Senjutsu
			Senjutsu_Focus
				BuffName="Senjutsu Focus"//Used to gain mana beyond 100 while medding
				ActiveMessage="extends their focus outward, drawing on the natural power of the world!"
				OffMessage="cuts off their perception of the world's energy..."
				verb/Senjutsu_Focus()
					set category="Skills"
					if(usr.BuffOn(src))
						if(usr.ManaDeath)
							usr << "You can't stop focusing when you're overloaded with natural energy!"
							return
					src.Trigger(usr)

		Ripple
			Ripple_Breathing
				passives = list("HolyMod" = 2, "PUDrainReduction" = 2, "Ripple" = 1)
				HolyMod=2
				PUDrainReduction=2
				ActiveMessage="begins to channel the power of the Sun!"
				OffMessage="relaxes their breathing..."
				TextColor=rgb(255, 250, 120)
				HitSpark='Hit Effect Ripple.dmi'
				HitX=-32
				HitY=-32
				Ripple=1//SO NO CHI* NO SADAME...
				verb/Ripple_Breathing()
					set category="Skills"
					src.Trigger(usr)
			Life_Magnetism_Overdrive
				VaizardHealth=2.5
				VaizardShatter=1
				TimerLimit=10//lasts for 10 seconds.
				IconLock='Ripple Barrier.dmi'
				ActiveMessage="throws a handful of Ripple-conductive debris to form a barrier <b>Life Magnetism Overdrive</b>!"
				OffMessage="stops channeling the Ripple through the debris..."
		Werewolf
			New_Moon_Form
				HairLock=1
				AutoAnger=1
				passives = list("Pursuer" = 1)
				Pursuer=1
				ActiveMessage="discards their humanity, their jaws stretching into a bloodthirsty maw!"
				OffMessage="conceals their bloodthirsty nature..."
				TextColor=rgb(153, 0, 0)
				IconLock='NewMoon.dmi'
				verb/New_Moon_Frenzy()
					set category="Skills"
					src.Trigger(usr)
					if(usr.BuffOn(src))
						winshow(usr, "HungerLabel", 1)
						winshow(usr, "Hunger", 1)
					else
						winshow(usr, "HungerLabel", 0)
						winshow(usr, "Hunger", 0)
			Half_Moon_Form
				HealthThreshold=0.1
				StrMult=1.25
				EndMult=1.25
				SpdMult=1.75
				ForMult=0.2
				OffMult=1.25
				DefMult=0.75
				// RegenMult=0.1
				// RecovMult=0.1
				passives = list("Curse" = 1, "Godspeed" = 1, "TechniqueMastery" = 1)
				Curse=1
				Godspeed=1
				TechniqueMastery = 1
				Intimidation = 1.5
				HairLock='BLANK.dmi'
				HitSpark='WolfFF.dmi'
				HitX=0
				HitY=0
				HitTurn=1
				HitSize=0.8
				ActiveMessage="abandons rationality and transforms into a hulking beast of prey!"
				OffMessage="restrains their inner beast..."
				TextColor=rgb(153, 0, 0)
				IconTransform='HalfMoon.dmi'
				adjust(mob/p)
					if(!altered)
						if(p.Secret == "Werewolf")
							passives = list("Curse" = 1, "Godspeed" =  p.secretDatum.currentTier, "TechniqueMastery" = 1, "MovementMastery" = p.secretDatum.currentTier * 1.5)
							MovementMastery = p.secretDatum.currentTier * 1.5
							Godspeed = p.secretDatum.currentTier
							StrMult = 1 + (p.secretDatum.currentTier * 0.25)
							EndMult = 1 + (p.secretDatum.currentTier * 0.25)
							SpdMult = 1.5 + (p.secretDatum.currentTier * 0.25)
							OffMult = 1 + (p.secretDatum.currentTier * 0.25)
				Trigger(mob/p, Override = 0 )
					adjust(p)
					..()
			Full_Moon_Form
				adjust(mob/p)
					if(!altered)
						if(p.Secret == "Werewolf")
							passives = list("SpecialBuffLock" = 1,"Curse" = 1, "Godspeed" =  p.secretDatum.currentTier*2, "MovementMastery" = p.secretDatum.currentTier * 2,\
							 "Pursuer" = 2, "BlurringStrikes" = p.secretDatum.currentTier)
							MovementMastery = p.secretDatum.currentTier * 2
							Godspeed = p.secretDatum.currentTier * 2
							StrMult = 1.25 + (p.secretDatum.currentTier * 0.25)
							EndMult = 1.25 + (p.secretDatum.currentTier * 0.25)
							SpdMult = 2 + (p.secretDatum.currentTier * 0.25)
							OffMult = 1.25 + (p.secretDatum.currentTier * 0.25)
							DefMult = 1.25 + (p.secretDatum.currentTier * 0.25)

				HealthThreshold=0.1
				RegenMult=2
				AutoAnger=1
				Pursuer=2
				Godspeed=2
				Intimidation=1.75
				Curse=1
				KenWave=4
				KenWaveIcon='DarkKiai.dmi'
				HairLock='BLANK.dmi'
				HitSpark='Hit Effect Vampire.dmi'
				HitX=-32
				HitY=-32
				TimerLimit=60
				NameFake="Wolf"
				ActiveMessage="becomes the incarnation of wild nature itself!"
				OffMessage="retains their humanity..."
				TextColor=rgb(153, 0, 0)
				IconTransform='FullMoon.dmi'
				TransformX=-7
				TransformY=-4
				SpecialBuffLock=1
				verb/Customize_Full_Moon()
					set category = "Other"
					IconTransform=input(usr, "What icon will your Full Moon Form use?", "Full Moon Form Icon") as icon|null
					TransformX=input(usr, "Pixel X offset.", "Full Moon Form Icon") as num
					TransformY=input(usr, "Pixel Y offset.", "Full Moon Form Icon") as num
					NameFake = input(usr, "What will your name be while in Full Moon Form?", "Full Moon Form Icon") as text
					HairLock = input(usr, "What will your hair look like while in Full Moon Form?", "Full Moon Form Icon") as icon|null


				verb/Full_Moon_Frenzy()
					set category="Skills"
					if(usr.Secret=="Werewolf")
						if(usr.secretDatum.secretVariable["Hunger Satiation"] >= usr.secretDatum?:getHungerLimit())
							if(usr.CheckSlotless("Half Moon Form"))
								for(var/obj/Skills/Buffs/SlotlessBuffs/Werewolf/Half_Moon_Form/hmf in usr)
									if(usr.BuffOn(hmf))
										hmf.Trigger(usr, 1)
							adjust(usr)
							src.Trigger(usr)
							if(usr.BuffOn(src))
								usr.secretDatum.secretVariable["Hunger Active"] = 1
						else
							usr << "You are too hungry to transform!"
					else
						usr << "You are not a werewolf!"

		Eldritch
			True_Form
				adjust(mob/p)
					if(!altered)
						passives = list("Curse" = 1, "Godspeed" =  1+p.AscensionsAcquired, \
						 				"Pursuer" = 2,
										"CallousedHands" = ROUND_DIVIDE(p.secretDatum.secretVariable["Madness"],250), \
						  				"Hardening" = ROUND_DIVIDE(p.secretDatum.secretVariable["Madness"],50), \
										"Flicker" = ROUND_DIVIDE(p.secretDatum.secretVariable["Madness"],25), \
										"AngerThreshold" = 1.125 + (0.125 * p.AscensionsAcquired))
						PowerMult=1+(0.05+(0.05*ROUND_DIVIDE(p.secretDatum.secretVariable["Madness"],25)))
						// passives["PureReduction"] = p.AscensionsAcquired
						TimerLimit = 55 + (p.secretDatum.secretVariable["Madness"]/5)

				HealthThreshold=0.1
				KenWave=4
				KenWaveIcon='DarkKiai.dmi'
				HitSpark='Hit Effect Vampire.dmi'
				IconLock='tenacles_underlay.dmi'
				IconUnder = 1
				TopOverlayLock = 'tentacles_overlay.dmi'
				TopOverlayX = -32
				TopOverlayY = -32
				LockX = -32
				LockY = -32
				HitX=-32
				HitY=-32
				TimerLimit=55
				Cooldown = 1
				ActiveMessage="unravels into a mind-rending series of shapes and textures!"
				OffMessage="slowly becomes 3D once again..."
				TextColor=rgb(153, 0, 0)
				verb/Customize_True_Form()
					set category = "Other"
					IconTransform=input(usr, "What icon will your True Form use?", "True Form Icon") as icon|null
					if(IconTransform)
						TransformX=input(usr, "Pixel X offset.", "True Form Icon") as num
						TransformY=input(usr, "Pixel Y offset.", "True Form Icon") as num
					NameFake = input(usr, "What will your name be while in True Form?", "True Form Icon") as text
					HairLock = input(usr, "What will your hair look like while in True Form?", "True Form Icon") as icon|null

				Trigger(mob/User, Override = 0)
					if(!User.BuffOn(src))
						adjust(User)
					if(User.Secret == "Eldritch")
						if(!User.BuffOn(src))
							var/SecretInfomation/Eldritch/s = User.secretDatum
							s.secretVariable["Madness Active"] = TRUE
						else
							var/SecretInfomation/Eldritch/s = User.secretDatum
							s.secretVariable["Madness Active"] = FALSE
					..()
//Self Triggering Buffs
		Autonomous
			Autonomous=1
			UnrestrictedBuff=1
			AllOutAttack=1

//General (?)
			Two
			Three
			Four
			Five
			Six
			Curse
				NeedsPassword=1
				MagicNeeded=1
			Infection
				NeedsPassword=1
			Dragon_Clash
				passives = list("PureDamage" = 2, "HotHundred" = 1, "Warping" = 3)
				HotHundred=1
				Warping=3
				TimerLimit=3
			Dragon_Clash_Defensive
				passives = list("PureDamage" = 1, "HotHundred" = 1, "Warping" = 3)
				HotHundred=1
				Warping=3
				TimerLimit=3
			Transcendant
				//this will add god ki for a few seconds for a special attack ; )
				TimerLimit=5
				passives = list("GodKi" = 0.25)
				GodKi=0.25//usually its 0.25 for seint seiya stuff
			Vanish
				passives = list("HotHundred" = 1, "Warping" = 3, "Steady" = 3)
				HotHundred=1
				Warping=3
				Steady=3
				TimerLimit=3
				Incorporeal=1
				ActiveMessage="vanishes in the wake of their attack!"
//QUEUE FINISHERS
			QueueBuff/*All triggered by queues*/
				NeedsPassword=1//all triggered by buffself queues
				TimerLimit=30
				AlwaysOn=1
				Cooldown=4

				Finisher
					Cooldown = -1
					IconLock='AuraSlowTensionBlue.dmi'
					LockX=0
					LockY=0
					TensionLock=1
					NoWhiff=1
					Generic_Finisher
						OffMult=1.5
						DefMult=1.5
						ActiveMessage="is getting fired up!"
						OffMessage="falls back in sync with the fight..."
						//no verb to activate




					Heavenly_Dragon_Ascendant_Zenith
						passives = list("HardenedFrame" = 1, "Steady" = 1, "WeaponBreaker" = 1, "Disorienting" = 1)
						OffMult = 1.1
						EndMult = 1.3
						StrMult = 1.2
						ActiveMessage="is grasping for their next breakthrough..!"
						OffMessage="has failed their tribulation..."



					Potemkin_Buster
						StyleNeeded = "Ubermensch"
						VaizardHealth = 2
						DefMult = 0.75
						SpdMult = 0.75
						StrMult = 1.5
						EndMult = 1.5
						passives = list("Muscle Power" = 2, "TechniqueMastery" = 3, "DeathField" = 7, "Juggernaut"= 5, "KBRes"= 5, "TensionLock" = 1)
					Turtle_Martial_Mastery
						StyleNeeded="Turtle"
						StrMult=1.1
						EndMult=1.3
						DefMult=1.2
						passives = list("TensionLock" = 1, "KiControlMastery" = 1, "Void" = 1, "FluidForm" = 1)
						ActiveMessage="begins a flawless Turtle Kata!"
						OffMessage="completes the Turtle Kata..."
					Crane_Martial_Mastery
						StyleNeeded="Crane"
						ForMult=1.3
						SpdMult=1.2
						OffMult=1.1
						passives = list("TensionLock" = 1, "PureDamage" = 1, "Skimming" = 1, "Flow" = 1, "SpiritFlow" = 1)
						ActiveMessage="begins a flawless Crane Kata!"
						OffMessage="completes the Crane Kata..."
					Snake_Martial_Mastery
						StyleNeeded="Snake"
						ForMult=1.1
						SpdMult=1.2
						DefMult=1.1
						passives = list("TensionLock" = 1, "SoftStyle" = 1, "CounterMaster" = 10, "SpiritHand" = 1, "Deflection" = 1)
						ActiveMessage="begins a flawless Snake Kata!"
						OffMessage="completes the Snake Kata..."
					Cat_Martial_Mastery
						StyleNeeded="Cat"
						StrMult=1.2
						SpdMult=1.1
						OffMult=1.2
						passives = list("TensionLock" = 1, "HardStyle" = 1, "Pursuer" = 1, "Flicker" = 1)
						ActiveMessage="begins a flawless Cat Kata!"
						OffMessage="completes the Cat Kata..."

					//t1 sig styles
					Ki_Flow_Mastery
						StyleNeeded="Gentle Fist"
						ForMult=1.5
						EndMult=1.5
						passives = list("TensionLock" = 1, "SoftStyle" = 2, "KiControlMastery" = 1, "FluidForm" = 1, "Flow" = 1, "SpiritFlow" = 1)
						Erosion=0.5

						ActiveMessage="perceives the flow of ki perfectly!"
						OffMessage="finds their perception clouded once more..."
					Body_Mastery
						StyleNeeded="Strong Fist"
						HardStyle=2
						StrMult=1.5
						EndMult=1.25
						OffMult=1.25
						passives = list("TensionLock" = 1, "Pursuer" = 1, "Flicker" = 1, "KiControlMastery" = 1, "FluidForm" = 1)
						ActiveMessage="circulates blood throughout their body perfectly!"
						OffMessage="loses their intense focus..."

					Spirit_Mastery
						StyleNeeded="Black Leg"
						StrMult=1.25
						ForMult=1.25
						SpdMult=1.5
						passives = list("TensionLock" = 1, "Pursuer" = 3, "QuickCast" = 3, "CounterMaster" = 10, "SpiritHand" = 1, "SpiritFlow" = 1, "Deflection" = 2)
						ActiveMessage="ignites their chivalrous spirit!"
						OffMessage="burns out their manly spirit..."

					Rush_Mastery
						StyleNeeded="Lightning Kickboxing"
						passives = list("TensionLock" = 1, "MovementMastery" = 3, "Flicker" = 3, "PureDamage" = 0.5, "Flow" = 2, "CounterMaster" = 10, "Deflection" = 2)
						ForMult=1.5
						SpdMult=1.5
						OffMult=1.25
						DefMult=1.25
						ActiveMessage="chases their enemy down with rapid kicks and punches!"
						OffMessage="runs out of energy..."

					//t2 signature martial
					Drunken_Mastery
						StyleNeeded="Drunken Fist"
						ForMult=1.5
						SpdMult=1.25
						EndMult=1.25
						passives = list("TensionLock" = 1, "SoftStyle" = 3, "MovementMastery" = 3, "PureDamage" = 1, "Flow" = 2, "Deflection" = 2)
						ActiveMessage="stumbles around drunkenly..."
						OffMessage="resumes normal motion..."

					Strength_Mastery
						StyleNeeded="Golden Kirin"
						StrMult=1.25
						OffMult=1.25
						ForMult=1.25
						SpdMult=1.15
						passives = list("TensionLock" = 1, "HardStyle" = 2, "UnarmedDamage" = 2, "Pursuer" = 3, "CounterMaster" = 10, "Deflection" = 2)
						ActiveMessage="enters the ultimate hard-style martial arts stance!"
						OffMessage="drops their stance..."

					Dire_Empowerment
						StyleNeeded="Dire Wolf"
						ManaGlow="#c66"
						ManaGlowSize=2
						StrMult=1.25
						EndMult=1.25
						ForMult=1.25
						DefMult=1.25
						ElementalOffense="Dark"
						ElementalDefense="Dark"
						passives = list("TensionLock" = 1, "SpiritHand" = 1, "SpiritFlow" = 1, "PureReduction" = 2, "TechniqueMastery" = 5, "Hardening" = 1, "SpiritualDamage" = 2, "DeathField" = 2)
						ActiveMessage="enters a Dire Trance!!"
						OffMessage="loses their magical rage..."
					Astral_Empowerment
						StyleNeeded="Moonlight"
						ManaGlow="#66c"
						ManaGlowSize=2
						passives = list("TensionLock" = 1, "LifeSteal" = 25, "EnergySteal" = 25, "SoulFire" = 1.5)
						StrMult=1.5
						ForMult=1.5
						ElementalOffense="Water"
						ElementalDefense="Void"
						ActiveMessage="draws command over their foe's energy!"
						OffMessage="blocks out their astral ascension..."
					Chaos_Empowerment
						StyleNeeded="Entropy"
						ManaGlow="#cc6"
						ManaGlowSize=2
						ElementalOffense="Ultima"
						ElementalDefense="Ultima"
						passives = list("TensionLock" = 1, "Confusing" = 1)
						StrMult=1.25
						EndMult=1.25
						ForMult=1.25
						SpdMult=1.25
						ActiveMessage="divines the ultimate energy through the nous of chaos!"
						OffMessage="forgets how to access to the ultimate energy?!"
					Devil_Luck
						StyleNeeded="Devil Leg"
						ManaGlow="#F00"
						ManaGlowSize=2
						passives = list("TensionLock" = 1, "PureDamage" = 1, "Attracting" = 3)
						StrMult=1.25
						OffMult=1.5
						ActiveMessage="beckons their luckless foe into an inescapable showdown!"
						OffMessage="runs out of their Devil's Luck..."
					Reversal_Mastery
						StyleNeeded="Flow Reversal"
						ManaGlow="#369"
						ManaGlowSize=2
						passives = list("TensionLock" = 1, "CyberStigma" = 2, "PureReduction" = 1, "CounterMaster" = 10, "Attracting" = 3)
						DefMult=2
						ActiveMessage="reads the flow of the fight perfectly, ready to counter!"
						OffMessage="loses their absolute clarity..."
					Death_Mastery
						StyleNeeded="Phage"
						ManaGlow="#000"
						ManaGlowSize=2
						passives = list("TensionLock" = 1, "Toxic" = 3, "MortalStrike" = 0.25, "Curse" = 1, "VoidField" = 2, "DeathField" = 2)
						StrMult=1.25
						ForMult=1.5
						ActiveMessage="radiates a miasma of death!"
						OffMessage="represses their deathly aura..."


					Mystic_Empowerment
						StrMult=1.25
						ForMult=1.5
						ActiveMessage="channels mystic forces through their Elemental Kata!"
						OffMessage="completes the Elemental Kata..."
						passives = list("TensionLock" = 1)

					Cyber_Crusher
						StyleNeeded="Circuit Break"
						ManaGlow="#6cc"
						ManaGlowSize=2
						IconLock=null
						passives = list("CyberStigma" = 2, "TensionLock" = 1)
						StrMult=1.4
						ActiveMessage="is ready to destroy all machines!"
						OffMessage="runs out of brainpower to destroy machines..."
					Toxic_Crash
						StyleNeeded="Inverse Poison"
						ManaGlow="#c6c"
						ManaGlowSize=2
						IconLock=null
						SpdMult=1.6
						passives = list("TensionLock" = 1, "Toxic" = 5)
						ActiveMessage="accelerates their poison flow!"
						OffMessage="relaxes their toxic nature..."
					Corona_Splash
						StyleNeeded="Sunlight"
						ManaGlow="#cc6"
						ManaGlowSize=2
						IconLock=null
						StrMult=1.4
						ForMult=1.4
						passives = list("TensionLock" = 1,"PureDamage" = 1, "Burning" = 5 )
						ActiveMessage="suffuses their arm with radiant sunlight!"
						OffMessage="relaxes their brilliance..."
					Stillness
						StyleNeeded="Tranquil Dove"
						ManaGlow="#66c"
						EndMult=1.4
						DefMult=1.4
						passives = list("TensionLock" = 1,"PureReduction" = 1)
						ActiveMessage="radiates a peaceful stillness!"
						OffMessage="loses their vibe..."

					//t3 signature martial
					North_Strength
						StyleNeeded="North Star"
						ManaGlow="#fff"
						ManaGlowSize=2
						passives = list("TensionLock" = 1,"PureDamage" = 2.5, "PureReduction" = 2.5, "MovementMastery" = 10, "Pursuer" = 2, "Curse" = 1, "HardStyle" = 2, "SoftStyle" = 2)
						StrMult=1.5
						OffMult=1.5
						ActiveMessage="taps into all of their latent strength!"
						OffMessage="releases their gathered strength..."
					East_Strength
						StyleNeeded="East Star"
						ManaGlow="#fff"
						ManaGlowSize=2
						passives = list("TensionLock" = 1,"SoftStyle" = 2, "PureDamage" = 5, "PureReduction" = -5, "SuperDash" = 1, "Pursuer" = 5)
						StrMult=1.5
						ForMult=1.5
						SuperDash=1
						DashCountLimit=4
						ActiveMessage="abandons all defensive posturing! You're in for a wild ride now!"
						OffMessage="disperses their immense wind pressure..."

					Battle_Strength //North Star / South Star
						passives = list("TensionLock" = 1,"PureDamage" = 2.5, "PureReduction" = 2.5, "MovementMastery" = 10)
						EnergyHeal=3
						FatigueHeal=1
						ManaGlow="#ffffff"
						ManaGlowSize=2
						ActiveMessage="taps into all of their latent strength!"
						OffMessage="releases their gathered strength..."
					Battle_Focus //East Star / West Star
						passives = list("TensionLock" = 1,"Instinct" = 2, "Flow" = 2, "MovementMastery" = 10)
						EnergyHeal=3
						FatigueHeal=1
						ManaGlow="#ffffff"
						ManaGlowSize=2
						ActiveMessage="attains perfect focus through battle!"
						OffMessage="loses their perfect battle focus..."

					//ansatsuken
					Hado_Kakusei
						StyleNeeded="Ansatsuken"
						ManaGlow=rgb(102, 153, 204)
						ManaGlowSize=2
						StrMult=1.5
						ForMult=1.5
						passives = list("TensionLock" = 1,"MovementMastery" = 10, "TechniqueMastery" = 5)
						ManaHeal=2.5
					Heat_Rush
						StyleNeeded="Ansatsuken"
						ManaGlow=rgb(204, 153, 102)
						ManaGlowSize=2
						StrMult=1.5
						ForMult=1.5
						passives = list("TensionLock" = 1,"MovementMastery" = 10, "TechniqueMastery" = 5)
						ManaHeal=2.5
					Violent_Personality
						StyleNeeded="Ansatsuken"
						ManaGlow=rgb(153, 51, 153)
						ManaGlowSize=2
						StrMult=1.5
						ForMult=1.5
						passives = list("TensionLock" = 1,"MovementMastery" = 10, "TechniqueMastery" = 5)
						ManaHeal=2.5

					//hiten
					Shunshin
						SpdMult=1.6
						passives = list("TensionLock" = 1,"Warping" = 4, "HotHundred" = 1, "Godspeed" = 3, "BlurringStrikes" = 1)
						TimerLimit=12
						Afterimages=1
						ActiveMessage="moves at godspeed for a rapid attack!"
						OffMessage="restrains their godspeed..."
					Shunshin_Shin
						SpdMult=2
						passives = list("TensionLock" = 1,"Warping" = 3, "HotHundred" = 2, "PureDamage" = 2, "Steady" = 3, "BlurringStrikes" = 2)
						TimerLimit=15
						Afterimages=1
						ActiveMessage="unleashes their godspeed for a short burst!"
						OffMessage="falls back in step..."

					//keyblades
					Fever_Pitch
						StrMult=1.5
						OffMult=1.5
						SpdMult=3
						HotHundred = 1
						Warping = 6
						passives = list("TensionLock" = 1, "Steady" = 2, "BlurringStrikes" = 2)
						TimerLimit = 10
						Trigger(mob/User, Override)
							if(!User.BuffOn(src))
								User.StunImmune = TRUE // cutscene mode
								User.LaunchImmune = TRUE
							else
								User.StunImmune = FALSE
								User.LaunchImmune = FALSE
							..()
					Fatal_Mode
						StrMult=2
						passives = list("TensionLock" = 1,"Steady" = 6, "CriticalChance" = 100)
						FlashChange=1
						ManaGlow=rgb(255, 255, 204)
						ManaGlowSize=2
						PhysicalHits=0
						UnarmedHits=0
						SwordHits=0
						SpiritHits=0
						Trigger(mob/User, Override)
							if(!User.BuffOn(src))
								passives["CriticalDamage"] = randValue(0.1, 0.2 + User.SagaLevel/10)
								var/limit = rand(3, 6) + User.SagaLevel
								PhysicalHits=limit
								UnarmedHits=limit
								SwordHits=limit
								SpiritHits=limit
							..()

					Magic_Wish
						ForMult=1.25
						OffMult=1.25
						SpdMult=1.25
						DefMult=1.25
						passives = list("TensionLock" = 1,"BetterAim" = 1, "SpiritualDamage" = 2)
					Fire_Storm
						FlashChange=1
						ManaGlow=rgb(255, 204, 204)
						ManaGlowSize=2
						passives = list("TensionLock" = 1,"SpiritHand" = 1)
						StrMult=1.5
						ForMult=1.5
					Diamond_Dust
						FlashChange=1
						ManaGlow=rgb(204, 204, 255)
						ManaGlowSize=2
						passives = list("TensionLock" = 1,"AbsoluteZero" = 1, "Freezing" = 1)
						ForMult=1.5
						OffMult=1.5
					Thunderbolt
						FlashChange=1
						ManaGlow=rgb(255, 255, 204)
						ManaGlowSize=2
						passives = list("TensionLock" = 1,"Paralyzing" = 1, "StunningStrike" = 2, "Warping" = 2, "HotHundred" = 1, "Steady" = 2)
						SpdMult=1.5
						OffMult=1.5
					Wing_Blade
						FlashChange=1
						ManaGlow=rgb(255, 255, 255)
						ManaGlowSize=2
						passives = list("TensionLock" = 1,"SwordDamage" = 2, "Steady" = 4)
						SureHitTimerLimit = 15
						OffMult=1.5
					Cyclone
						FlashChange=1
						ManaGlow=rgb(153, 255, 153)
						ManaGlowSize=2
						passives = list("TensionLock" = 1,"SweepingStrike" = 1, "Shocking" = 10, "Paralyzing" = 10, "DeathField" = 1)
						StrMult=1.25
					Rock_Breaker
						FlashChange=1
						ManaGlow=rgb(153, 102, 51)
						ManaGlowSize=2
						passives = list("TensionLock" = 1,"PureDamage" = 3, "Shattering" = 15, "Warping" = 2, "HotHundred" = 1)
						StrMult = 1.2
						ForMult = 1.2
						ElementalDefense="Void"
						TimerLimit=5
					Dark_Impulse
						FlashChange=1
						ManaGlow=rgb(153, 102, 51)
						ManaGlowSize=2
						ElementalOffense="Void"
						passives = list("TensionLock" = 1,"DemonicDurability" = 1)
						AngerMult=1.5
						AutoAnger=1
						TimerLimit=60
					Ghost_Drive
						FlashChange=1
						ManaGlow=rgb(153, 153, 153)
						ManaGlowSize=2
						passives = list("TensionLock" = 1,"Godspeed" = 3, "Flicker" = 2, "SuperDash" = 2, )
						SpdMult = 1.5
					Blade_Charge
						FlashChange=1
						ManaGlow=rgb(255, 0, 255)
						ManaGlowSize=2
						passives = list("TensionLock" = 1,"SpiritHand" = 1, "SpiritSword" = 0.25, "Extend" = 1)


					Machine_Gun_Slash
						SwordHitsLimit=3
						OffMult=2
						passives = list("TensionLock" = 1,"HotHundred" = 1, "SlayerMod" = 5)
						ActiveMessage="readies an Iaido Kata: Machine Gun Slash!"
						OffMessage="flicks their blade to clean it of blood before resheathing it..."
					Flurry_Fleur
						passives = list("TensionLock" = 1,"Crippling" = 5)
						SureHitTimerLimit=2
						SureDodgeTimerLimit=2
						ActiveMessage="begins to move through a cruel and beautiful duelling form!"
						OffMessage="finishes their form with a flourish..."
					Overbearing_Strength
						passives = list("TensionLock" = 1,"StunningStrike" = 2)
						Intimidation=1.5
						ActiveMessage="continues their adrenaline high, throwing all of their strength into each attack!"
						OffMessage="overexerts their strength, returning to their baseline..."
					Artificial_Sword_God
						StrMult=1.25
						EndMult=1.25
						OffMult=1.25
						DefMult=1.25
						passives = list("TensionLock" = 1)
						ActiveMessage="sharpens the edges of their limbs to become more swordlike!"
						OffMessage="releases their concentrated edge..."

					//tier 1 sig style
					Dual_Mastery
						passives = list("TensionLock" = 1,"DoubleStrike" = 2)
						SwordHits=6
						ActiveMessage="flows through a Dual Wielding Kata!"
						OffMessage="finishes their kata..."
					Flowing_Slash_Follow_Up
						passives = list("TensionLock" = 1,"Warping" = 2, "PureDamage" = 10, "Instinct" = 2, "KBAdd" = 5, "KBMult" = 10)
						ActiveMessage="brings their sword back..."
						OffMessage="strikes through their opponent suddenly!"
					Crippling_Blows
						passives = list("TensionLock" = 1,"Crippling" = 5)
						PhysicalHitsLimit=3
						ActiveMessage="whips a knife in a crippling butterfly pattern!"
						OffMessage="finishes their cuts and hides the knife again..."
					Unhinged_Ferocity
						Intimidation=1.5
						StrMult=1.5
						SpdMult=1.5
						passives = list("TensionLock" = 1)
						ActiveMessage="cast away any restrictions to their style!"
						OffMessage="slows their pace up and begins regular motions..."

					//t2 sig styles
					Mortal_Will
						passives= list("Mortal Will" = 1, "MortalStacks" = 1, "BlockChance" = 33, "CriticalBlock" = 0.3, "StunningStrike" = 3, "ComboMaster" = 1, "Deflection" = 1, "Reversal" = 0.25 )
						ActiveMessage = "channels the will of a Phalanx!"
						OffMessage = "falls out of flow..."
					Trinity_Mastery
						passives = list("TensionLock" = 1,"DoubleStrike" = 1, "TripleStrike" = 1)
						ActiveMessage="flows through a Tri Wielding Kata!"
						OffMessage="finishes their kata..."
					Maim_Mastery
						passives = list("TensionLock" = 1,"MortalStrike" = 0.5, "CursedWounds" = 1)
						ActiveMessage="embraces their murderous nature!"
						OffMessage="calms down from their murderous high..."
					Mana_Blitz
						passives = list("TensionLock" = 1,"BetterAim" = 3)
						ForMult=2
						SpiritHitsLimit=10
						ActiveMessage="radiates potent mana!"
						OffMessage="runs dry their surplus of mana..."
					Endurance_Negation
						passives = list("TensionLock" = 1,"PridefulRage" = 1)
						PhysicalHitsLimit=1
						SpiritHitsLimit=1
						ActiveMessage="scythes through any resistance with keenly honed wisdom!"
						OffMessage="reels from their magical expenditure..."

					War_God
						StyleNeeded="Five Rings"
						ManaGlow=rgb(255, 0, 0)
						ManaGlowSize=2
						passives = list("TensionLock" = 1,"CursedWounds" = 1, "PureDamage" = 5, "Instinct" = 4, "SpiritFlow" = 1)
						HitSpark='Slash - Ragna.dmi'
						HitX=-32
						HitY=-32
						HitTurn=1
						OffMessage="represses their destructive instinct..."


					Bashing
						passives = list("HardenedFrame" = 1, "StunningStrike" = 3, "ComboMaster" = 1)
						EndMult = 1.3
						OffMult = 1.2
						ActiveMessage="starts using their shield as a weapon!"
						OffMessage="retracts their shield."

					Bestial_Accuracy
						StrMult=1.3
						EndMult=0.8
						passives = list("TensionLock" = 1,"NoDodge" = 1, "NoMiss" = 1)
						ActiveMessage="becomes empowered by instinct!"
						OffMessage="regains reason..."
					Martial_Flow
						passives = list("TensionLock" = 1,"Flow" = 1, "Instinct" = 1, "Steady" = 3)
						OffMult=1.2
						DefMult=1.2
						ActiveMessage="enters a flow state!"
						OffMessage="loses their flow state..."
					Anti_Material_Augment
						BuffName="Anti-Material Augment"
						StrMult=1.5
						passives = list("TensionLock" = 1,"WeaponBreaker" = 2)
						ActiveMessage="focuses their power to destroy any material!"
						OffMessage="loses their focus..."
					Speed_Break
						SpdMult=1.5
						passives = list("TensionLock" = 1,"Pursuer" = 2)
						ActiveMessage="removes the limits on their speed!"
						OffMessage="remembers their speed limit..."

					//t1 sig styles
					Sure_Shot
						StyleNeeded="Soul Crushing"
						passives = list("TensionLock" = 1,"PureDamage" = 1, "NoDodge" = 1)
						ForMult=1.4
						ActiveMessage="focuses their power into a precise line!"
						OffMessage="releases their aim..."
					Seeking_Spirits
						StyleNeeded="Spirit"
						passives = list("TensionLock" = 1,"BetterAim" = 2, "NoDodge" = 1 )
						ForMult=1.4
						OffMult=1.4
						ActiveMessage="converses with their energy to track down their target!"
						OffMessage="disables the tracking spirits..."
					Fortunate_Fate
						StyleNeeded="Balance"
						OffMult=1.4
						DefMult=1.2
						EndMult=1.2
						passives = list("TensionLock" = 1,"Steady" = 2, "CriticalChance" = 5, "CrticalDamage" = 0.25)
						ActiveMessage="is blessed by a turn of fortune!"
						OffMessage="uses up their karma..."
					Speed_of_Sound
						StyleNeeded="Resonance"
						SpdMult=1.4
						passives = list("TensionLock" = 1,"Disorienting" = 1, "Godspeed" = 2, "Warping" = 2, "Steady" = 1)
						ActiveMessage="resonates with the speed of sound!"
						OffMessage="stops vibrating..."

					//t2 style
					Flash_Cry
						StyleNeeded="Shunko"
						Afterimages=1
						StrMult=1.5
						ForMult=1.5
						passives = list("TensionLock" = 1,"PureDamage" = 1, "PureReduction" = -2)
						ActiveMessage="enhances every movement with ki to allow for rapid destruction!!"
						OffMessage="exhausts their ki enhancement..."
					What_Must_Be_Done
						StyleNeeded="Metta Sutra"
						TensionLock=0
						Mastery=0//will immediately be incremented
						TimerLimit=600
						OffMessage="dissipates their spiritual intensity..."
						Cooldown=0
					Self_Mastery
						StyleNeeded="Shaolin"
						StrMult=1.25
						EndMult=1.25
						OffMult=1.25
						DefMult=1.25
						passives = list("TensionLock" = 1,"WeaponBreaker" = 3, "SoftStyle" = 3, "HardStyle" = 3)
						ActiveMessage="becomes the perfect weapon!"
						OffMessage="relaxes their martial frenzy..."
					Dance_Mastery
						StyleNeeded="Blade Singing"
						SpdMult=1.5
						OffMult=1.25
						StrMult=1.25
						passives = list("TensionLock" = 1,"Warping" = 1, "HotHundred" = 1, "Steady" = 2, "Flow" = 2, "Instinct" = 2, "Godspeed" = 2)
						ActiveMessage="steps between attacks and counters with effortless grace!"
						OffMessage="quiets their rhythmic dance..."

					Flowing_River
						StyleNeeded="West Star"
						ManaGlow=rgb(0, 0, 255)
						ManaGlowSize=2
						StrMult=1.25
						EndMult=1.25
						SpdMult=2
						OffMult=1.25
						DefMult=1.25
						passives = list("TensionLock" = 1,"WeaponBreaker" = 6, "SoftStyle" = 2, "HardStyle" = 2, "Warping" = 1, "HotHundred" = 1, "Flow" = 2,"Instinct" = 2, "Godspeed" = 2, "CounterMaster" = 10)
						ActiveMessage="flows through every defense with calm precision!"
						OffMessage="runs dry their well of fluidity..."







				Brolic_Grip
					ActiveMessage="flexes their arm with brolic strength!"
					OffMessage="relaxes their vicious power..."
					passives = list("Grippy" = 6, "Muscle Power" = 1)
				//these last for 10 seconds so they will stack about 30 of their elemental debuffs.

				Astral_Drain
					IconTint=rgb(0, 75, 153)
					SlowAffected=3
					ShatterAffected=3
					ShockAffected=3
					RecovMult=0.5
				Ultima_Break
					IconTint=rgb(153, 153, 75)
					StrMult=0.6
					EndMult=0.6
					SpdMult=0.6
				Devil_Fire
					KenWave=1
					KenWaveIcon='fevExplosion - Hellfire.dmi'
					KenWaveSize=5
					KenWaveX=76
					KenWaveY=76
					BurnAffected=5
					PoisonAffected=5
					DebuffCrash=list("Fire", "Poison")
				Bio_Break
					IconTint=rgb(51, 204, 102)
					RegenMult=0.1
					PoisonAffected=5
					DebuffCrash="Poison"

				//sword finisher debuffs



				Off_Balance
					IconLock='Stun.dmi'
					IconApart=1
					SpdMult=0.8
					DefMult=0.8
					ActiveMessage="can't get into the rhythm of combat!"
					OffMessage="regains their combat sense!"
				Attack_Break
					IconLock='Stun.dmi'
					IconApart=1
					StrMult=0.8
					OffMult=0.8
					ActiveMessage="can't mount a counter attack!"
					OffMessage="shakes off their anxiety!"
				Overwhelmed
					IconLock='Stun.dmi'
					IconApart=1
					StrMult=0.8
					EndMult=0.8
					ActiveMessage="feels their attacks aren't doing anything!"
					OffMessage="regains confidence!"
				Debilitated
					IconLock='Stun.dmi'
					IconApart=1
					SpdMult=0.8
					OffMult=0.8
					ActiveMessage="is shook down to their bones!"
					OffMessage="regains their vitality!"
				Impaled
					IconLock='SweatDrop.dmi'
					IconApart=1
					DefMult=0.6
					EndMult=0.6
					WoundDrain = 0.01
					ActiveMessage="has been impaled!"
					OffMessage="regains their composure!"
				Tri_Break
					IconLock='SweatDrop.dmi'
					IconApart=1
					DefMult=0.6
					EndMult=0.6
					ActiveMessage="has lost all offensive potential!"
					OffMessage="regains their aggression!"
				Mana_Break
					IconTint=rgb(51, 102, 204)
					StrMult=0.6
					ForMult=0.6
					passives = list("ManaDrain" = 1)
					ActiveMessage="has had their mana flow inverted!"
					OffMessage="regains control of their magical reserves..."
				Evasion_Negation
					IconLock='SweatDrop.dmi'
					IconApart=1
					SpdMult=0.6
					DefMult=0.6
					ActiveMessage="feels their body locked in time!..."
					OffMessage="shakes off the evasion negation spell!"

				South_Break
					IconLock='SweatDrop.dmi'
					IconApart=1
					StrMult=0.5
					EndMult=0.5
					SpdMult=0.5
					ForMult=0.5
					OffMult=0.5
					DefMult=0.5
					ActiveMessage="feels their body betray them!"
					OffMessage="regains control of their body..."
				Useless
					IconTint=list(0.15,0,0, 0.05,0.25,0.15, 0.05,0.05,0.35, 0,0,0)
					IconLock='SweatDrop.dmi'
					IconApart=1
					passives = list("NoDodge" = 1, "PureDamage" = -2.5, "BleedHit" = 1)
					FatigueDrain=3.5
					ManaDrain=2.5
					BurnAffected=2
					SlowAffected=2
					ShatterAffected=2
					PoisonAffected=2
					ShockAffected=2
					ShearAffected=2
					CrippleAffected=2
					ActiveMessage="knows that they are absolute trash..."
					OffMessage="remembers that they are a garbage can, not a garbage cannot!"
				Radioactive
					IconTint=rgb(0, 255, 0)
					ManaGlow=rgb(0, 255, 0)
					ManaGlowSize=2
					passives = list("BleedHit" = 1)
					BurnAffected=10
					PoisonAffected=10
					ShearAffected=10
					CrippleAffected=10
					DebuffCrash=list("Fire", "Poison")
					ActiveMessage="is sickened by their radioactive exposure!"
					OffMessage="shakes off their radiation sickness!"
				Moelach_Weezing
					IconTint=list(0.15,0,0, 0.05,0.25,0.15, 0.05,0.05,0.35, 0,0,0)
					IconLock='SweatDrop.dmi'
					IconApart=1
					passives = list("NoDodge" = 1, "PureReduction" = -5)
					Afterimages=1
					SpdMult=0.25
					ActiveMessage="feels the wheezing breath of Moelach tickling at their mind..."
					OffMessage="doesn't know what that was all about!!"

				Godspeed_Assaulted
					IconLock='SweatDrop.dmi'
					IconApart=1
					Afterimages=1
					SpdMult=0.5
					DefMult=0.5
					EndMult=0.8
					passives = list("NoDodge" = 1)
					ActiveMessage="fears for their life against a hyperspeed opponent!"
					OffMessage="regains courage!"

				Arena_Champion
					BuffName = "Champion of The Arena"
					passives = list("DoubleStrike" = 1, "Deflection" = 0.5, "Duelist" = 0.5, "StunningStrike" = 1.5, "ComboMaster" = 1)
					EndMult = 1.2
					OffMult = 1.2
					DefMult = 0.4
					StrMult = 1.2
					SpdMult = 0.8
					ActiveMessage="proclaims this arena for their own!"
					OffMessage="falls out of their champion lull."

				Dual_Break
					IconLock='SweatDrop.dmi'
					IconApart=1
					StrMult=0.8
					EndMult=0.8
					DefMult=0.8
					ActiveMessage="feels overwhelmed! They can't muster an attack or a defense!"
					OffMessage="regains their sense!"
				Technique_Break
					IconLock='SweatDrop.dmi'
					IconApart=1
					OffMult=0.6
					DefMult=0.6
					ActiveMessage="knows that they have been beat!"
					OffMessage="shakes off the feeling of being outclassed!"
				Desiccated
					IconLock='SweatDrop.dmi'
					IconApart=1
					EndMult=0.8
					SpdMult=0.6
					ActiveMessage="grasps for their torso ... They've been torn to shreds..."
					OffMessage="steels themselves for more battle!"
				Feral_Fear
					IconLock='SweatDrop.dmi'
					IconApart=1
					StrMult=0.8
					EndMult=0.8
					SpdMult=0.8
					ActiveMessage="can't even begin to think about how to deal with their opponent!"
					OffMessage="comes to the realization their opponent is probably just a moron!"


				//universal finisher debuffs
				Stumbling
					IconLock='SweatDrop.dmi'
					IconApart=1
					SpdMult=0.7
					DefMult=0.7
					ConfuseAffected = 5
					ActiveMessage="can't regain their footing!"
					OffMessage="regains focus!"



				Locked_On
					IconLock='SweatDrop.dmi'
					IconApart=1
					EndMult=0.8
					passives = list("NoMiss" =  1, "NoDodge" = 1)
					NoMiss=1
					NoDodge=1
					ActiveMessage="knows they are being hunted!"
					OffMessage="shakes off their pursuer!"
				Disoriented
					IconLock='Stun.dmi'
					IconApart=1
					SpdMult=0.8
					DefMult=0.8
					OffMult=0.8
					passives = list("FatigueLeak" = 1, "EnergyLeak" = 1)
					ActiveMessage="can't get their bearings on their opponent!"
					OffMessage="regains focus!"
				Broken_Bones
					IconLock='SweatDrop.dmi'
					IconApart=1
					StrMult=0.8
					EndMult=0.6
					DefMult=0.8
					passives = list("FatigueLeak" = 1, "EnergyLeak" = 1)
					ActiveMessage="yelps as a blow shatters their bones!"
					OffMessage="manages the pain of the shattered bones..."
				Slow_Motion
					IconLock='SweatDrop.dmi'
					IconApart=1
					Afterimages=1
					DefMult=0.6
					SpdMult=0.6
					ActiveMessage="can't...get...moving..."
					OffMessage="regains their speed!"

				Traced
					IconLock='SweatDrop.dmi'
					IconApart=1
					passives = list("NoDodge" = 1)
					NoDodge=1
					ShatterAffected=10
					SlowAffected=10
					CrippleAffected=10
					ActiveMessage="knows that they're in for some pain! They have to escape!"
					OffMessage="stands their ground!"
				Ineffective_Fate
					IconLock='SweatDrop.dmi'
					IconApart=1
					StrMult=0.8
					OffMult=0.8
					passives = list("Flow" = -1)
					ActiveMessage="knows that karma is against them!"
					OffMessage="feels more sure of their luck!"
				Shattered
					IconLock='SweatDrop.dmi'
					IconApart=1
					EndMult=0.6
					passives = list("BleedHit" = 1)
					ActiveMessage="feels their internals shatter under the sonic assault!"
					OffMessage="regains their vitality!"

				Self_Shattered
					EnergyDrain=10
					passives = list("BleedHit" = 1, "FatigueLeak" = 1, "ManaLeak" = 1)
					BleedHit=1
					FatigueLeak=1
					ManaLeak=1
					HardStyle=1
					SoftStyle=1
					SpdMult=0.6
					ActiveMessage="has had their sense of self destroyed!"
					OffMessage="regains their ego!"



				Forced_Mechanize
					Mechanized=1
					passives = list("ManaDrain" = 2, "Mechanized" = 1)
					ManaDrain=2
					IconTint=list(0.3,0.3,0.3, 0.59,0.59,0.59, 0.11,0.11,0.11, 0,0,0)
					OffMessage="breaks through the mechanization!"
				Venom_Break
					DebuffCrash="Poison"
					IconTint=rgb(153, 0, 153)
					TimerLimit=5
					PoisonAffected=10
					OffMessage="feels the poison boil through their body in an instant!"
				Solar_Break
					DebuffCrash="Fire"
					IconTint=rgb(153, 153, 0)
					TimerLimit=5
					BurnAffected=10
					passives = list("PureReduction" = -1)
					OffMessage="is consumed by flames!!"
				Anger_Break
					IconTint=rgb(153, 153, 153)
					passives = list("NoAnger" = 1)
					NoAnger=1
					OffMessage="regains their conscienceness!"




//Augmented Gears
			CursedGear

				Calamity_Gear
				Berserk_Gear
				Atrocity_Gear
				Sinister_Gear
				Atavism_of_the_Maou


//Meant for NPC only
			Turns_Red
				NeedsHealth=50
				TooMuchHealth=75
				PowerInvisible=1.5
				TechniqueMastery=10
				TextColor=rgb(255, 0, 0)
				IconTint=list(0.8,0,0, 0.2,0.55,0.05, 0.2,0.02,0.58, 0,0,0)
				Cooldown=-1
				ActiveMessage="turns red!!"
			Swell_Up
				NeedsHealth=50
				TooMuchHealth=75
				passives = list("GiantForm" = 1, "FluidForm" = 1, "DebuffResistance" = 1)
				GiantForm=1
				FluidForm=1
				DebuffResistance=1
				Enlarge=2
				TextColor=rgb(255, 255, 0)
				Cooldown=-1
				ActiveMessage="swells up!!"
			Round_Two
				NeedsHealth=10
				TooMuchHealth=100
				FlashChange=1
				StableHeal=1
				TimerLimit=10
				HealthHeal=5
				TextColor=rgb(255, 0, 255)
				Cooldown=-1
				ActiveMessage="catches a second wind!!"
			Metal_Coat
				NeedsHealth=10
				TooMuchHealth=100
				DarkChange=1
				VaizardHealth=5
				passives = list("PureDamage" = 1, "PureReduction" = 1)
				PureDamage=1
				PureReduction=1
				TextColor=rgb(0, 255, 255)
				IconTint=list(0.3,0.3,0.3, 0.39,0.39,0.39, 0.11,0.11,0.11, 0,0,0)
				Cooldown=-1
				ActiveMessage="grows out a metallic coat!!"
			Heartless
				SignatureTechnique=3
				DarkChange=1
				AlwaysOn=1
				SpdMult=2
				OffMult=2
				PowerMult=2
				AngerMult=2
				AutoAnger=1
				passives = list("ActiveBuffLock" = 1,"SpecialBuffLock" = 1)
				AuraLock='AntiAura.dmi'
				AuraX=-18
				AuraY=-22
				KenWave=3
				KenWaveIcon='DarkKiai.dmi'
				ActiveBuffLock=1
				SpecialBuffLock=1
				IconTint=list(0.15,0,0, 0.05,0.25,0.15, 0.05,0.05,0.35, 0,0,0)
				IconLock='AntiEyes.dmi'
				IconApart=1
				ActiveMessage="is transformed by their inner darkness!"
				OffMessage="exhausts the dark energy..."
				Cooldown=-1

//Cybernetic
			Blade_Mode
				passives = list("Warping" = 2, "Steady" = 3, "HotHundred" = 1, "PureDamage" = 1)
				Warping=2
				HotHundred=1
				TimerLimit=6
				ClientTint=1
				Cooldown=10

//Enchant
			Sensing
				AlwaysOn=1
				TimerLimit=300
				SeeInvisible=20
				KenWaveIcon='KenShockwaveGod.dmi'
				KenWave=1
				KenWaveSize=1
				KenWaveBlend=2
				KenWaveTime=6
				Cooldown=1
			Potion_Power
				MagicNeeded=1
				ActiveMessage="quaffs a mysterious potion!"
				TextColor=rgb(0, 153, 255)
				AlwaysOn=1
				Cooldown=1
			Empowered
				AlwaysOn=1
				TimerLimit=90
				WoundHeal=0.1
				FatigueHeal=1
				PowerMult=1.5
				passives = list("LifeGeneration" = 4, "EnergyGeneration"=4, "ManaGeneration" = 4, "Steady" = 9, "Flicker" = 1, "Pursuer" = 1, "Godspeed" = 1)
				Steady=9
				Pursuer=1
				Flicker=1
				Godspeed=1
				IconLock='CommandSparks.dmi'
				IconLockBlend=2
				OverlaySize=0.7
				LockY=-4
				ActiveMessage="is miraculously empowered by the Command Seal! Almost nothing seems impossible anymore!"
				OffMessage="feels the effects of the Seal fade..."
				KenWave=3
				KenWaveBlend=2
				KenWaveIcon='KenShockwaveDivine.dmi'
				Cooldown=1
			Shackled
				AlwaysOn=1
				TimerLimit=180000
				passives = list("Infatuated" = 100)
				Infatuated=100
				ActiveMessage="is forced into complete obedience by the Command Seal! They cannot harm their master anymore!"
				OffMessage="feels the effects of the Seal fade..."
				KenWave=3
				KenWaveBlend=2
				KenWaveIcon='KenShockwaveBloodlust.dmi'
				Cooldown=1
			Disturbed
				AlwaysOn=1
				TimerLimit=3600
				HealthDrain=0.025
				EnergyDrain=0.025
				ManaDrain=0.025
				IconLock='BraveSparks.dmi'
				IconLockBlend=2
				OverlaySize=0.7
				ActiveMessage="feels the energies animating their body rebel against it!"
				OffMessage="feels their necrotic energy stabilize..."
				Cooldown=1

//Racial
			Dragon_Rage
				NeedsHealth = 50
				TooMuchHealth = 75
				TextColor=rgb(95, 60, 95)
				ActiveMessage="is consumed by a dragon's rage!!"
				OffMessage = "calms their draconic fury..."
				adjust(mob/p)

				Dragons_Tenacity
					NeedsHealth = 50
					TooMuchHealth = 75

					ActiveMessage = "forms a draconic shell!!"
					OffMessage = "loses their draconic shell..."
					adjust(mob/p)
						if(altered) return
						var/asc = p.AscensionsAcquired
						ElementalOffense = "Earth"
						ElementalDefense = "Earth"
						endAdd = 0.05 * asc
						passives = list("DeathField" = asc+1, "PureReduction" = 0.25 + (0.25 * asc), "BlockChance" = 5 + ( 5 * asc ), "CriticalBlock" = 0.05 + (0.05 * asc) ,\
										"CallousedHands" = 0.15 + (asc * 0.15), "Hardening" = 0.5 + (0.25 * asc), "LifeGeneration" = 0.5 * asc)
					Trigger(mob/User, Override = FALSE)
						if(!User.BuffOn(src))
							adjust(User)
						..()

				Heat_Of_Passion
					// Fire Dragon Racial, mimics Berserk
					BurnAffected = 1
					NeedsHealth = 50
					TooMuchHealth = 75
					ActiveMessage = "ignites themselves in a blaze of passion!!"
					OffMessage = "calms their fiery passion..."
					Cooldown = 120
					adjust(mob/p)
						if(altered) return
						var/asc = p.AscensionsAcquired
						AngerMult = 1.15 + (0.15 * asc)
						ElementalOffense = "Fire"
						ElementalDefense = "Fire"
						passives = list("SpiritHand" = asc * 0.25, "Scorching" = 8 * asc,  "SoulFire" = asc * 0.75, "HybridStrike" = asc * 0.1, \
										"Steady" = asc/2)
						Intimidation = 1.25 + (0.25 * asc)
					Trigger(mob/User, Override = FALSE)
						if(!User.BuffOn(src))
							adjust(User)
						..()

				Wind_Supremacy
					// Wind Dragon Racial
					NeedsHealth = 50
					TooMuchHealth = 75
					ActiveMessage = "takes to the skies as the very winds heed their call!"
					OffMessage = "finally graces the earth once again with their presence..."
					Cooldown = 120
					adjust(mob/p)
						if(altered) return
						var/asc = p.AscensionsAcquired
						spdAdd = 0.15 * asc
						Shocking = 8 * asc
						EnergySteal = 10 + (asc * 10)
						ElementalOffense = "Wind"
						ElementalDefense = "Wind"
						passives = list("DoubleStrike" = asc/4, "Godspeed" = 1 + asc/1.5, \
							"Pursuer" = 1 + asc/2, "Flicker" = 1+asc/2, "BlurringStrikes" = asc/4, "EnergySteal" = 5 * asc, \
							"Shocking" = 8 * asc)
					Trigger(mob/User, Override = FALSE)
						if(!User.BuffOn(src))
							adjust(User)
						..()
				Hoarders_Riches
					// Gold Dragon Racial. Have money? Be OP.
					ActiveMessage = "gains the faint glitter of gold in their hues!"
					OffMessage = "loses some of that sinner's greed..."
					Cooldown = 120
					adjust(mob/p)
						if(altered) return
						var/asc = p.AscensionsAcquired
						var/money
						for(var/obj/Money/m in p.contents)
							money = m.Level
						NeedsHealth = 10 + (5 * asc)
						TooMuchHealth = 20 + (5 * asc)

						var/baseMultMod = 1 + max(0,money/glob.racials.GOLD_DRAGON_FORMULA)
						PowerMult = baseMultMod
						SpdMult = baseMultMod
						StrMult = baseMultMod
						OffMult = baseMultMod
						DefMult = baseMultMod
						EndMult = baseMultMod
						ForMult = baseMultMod

					Trigger(mob/User, Override = FALSE)
						if(!User.BuffOn(src))
							adjust(User)
						..()


				Melt_Down
					// Poison Dragon Racial.
					ActiveMessage = "begins bubbling"
					OffMessage = "loses some of that sinner's greed..."
					Cooldown = 120
					adjust(mob/p)
			Berserk
				NeedsHealth=10
				TooMuchHealth=15
				AngerMult=1.2
				passives = list("Brutalize" = 0.5)
				TextColor=rgb(255, 0, 0)
				Cooldown=180
				ActiveMessage="enters a berserk fury!!"
				OffMessage="calms their bestial rage..."

			Dragon_Force
				NeedsHealth=50
				TooMuchHealth=75
				TextColor=rgb(95, 60, 95)
				IconLock='EyesDragon.dmi'
				KenWave=5
				KenWaveSize=3
				KenWaveIcon='DarkKiai.dmi'
				ActiveMessage="unleashes their ceaseless anger..."
				OffMessage="calms the rage of the eons..."
				Cooldown=10800
				//doubles god ki values
			Symbiote_Infection
				NeedsHealth=25
				NeedsVary=1
				TooMuchHealth=75
				VaizardHealth=2
				VaizardShatter=1
				Unstoppable=1
				Possessive=1
				TextColor=rgb(75, 0, 85)
				IconLock='RaginPart.dmi'
				IconApart=1
				IconTint=list(0.15,0.11,0.3, 0.15,0.11,0.3, 0.15,0.11,0.3, 0,0,0)
				DarkChange=1
				HitSpark='Slash - Hellfire.dmi'
				HitX=-32
				HitY=-32
				HitSize=1
				HitTurn=1
				Cooldown=-1
				ActiveMessage="is coated by a frenzied symbiotic organism!!"
				adjust(mob/p)
					if(altered) return
					var/asc = p.AscensionsAcquired
					passives = list("Unstoppable" = 1, "Hardening" = 1 + (0.5 * asc), "LifeSteal" = 1.5*asc, "Godspeed" = 1+(asc), "SweepingStrike" = 1)
					VaizardHealth = 1.5 + p.GetEnd() + (p.TotalInjury/25) + (asc)
					// this was 17.5% guys lol
					if(asc>=1)
						if(!locate(/obj/Skills/AutoHit/Symbiote_Tendril_Wave, p.AutoHits))
							p.AddSkill(new/obj/Skills/AutoHit/Symbiote_Tendril_Wave)
						if(!locate(/obj/Skills/Queue/Symbiote_Hammer, p.Queues))
							p.AddSkill(new/obj/Skills/Queue/Symbiote_Hammer)

				Trigger(mob/User, Override = FALSE)
					if(!User.BuffOn(src))
						adjust(User)
					..()
			Rage_Form
				DarkChange=1
				StrMult=1.5
				SpdMult=1.5
				AutoAnger=1
				passives = list("SpecialBuffLock" = 1, "Curse" = 1, "Pursuer" = 1, "Flicker" = 1, "StunningStrike" = 1, "DoubleStrike" = 3, "TechniqueMastery" = 5, "MovementMastery" = 5, "QuickCast" = 2, "Godspeed" = 1)
				Intimidation=1.25
				Curse=1
				Pursuer=1
				Flicker=1
				StunningStrike=1
				DoubleStrike=1
				NeedsHealth=75
				TooMuchHealth=90
				AuraLock='AntiAura.dmi'
				AuraX=-18
				AuraY=-22
				KenWave=3
				KenWaveIcon='DarkKiai.dmi'
				SpecialBuffLock=1
				IconTint=list(0.15,0,0, 0.05,0.25,0.15, 0.05,0.05,0.35, 0,0,0)
				IconLock='AntiEyes.dmi'
				IconApart=1
				ActiveMessage="draws on the full force of darkness!"
				OffMessage="runs dry their dark power..."
				Cooldown=-1
			Devil_Arm_Refinement
				NeedsTrans=1


//Skill Tree...from knowledge side.
			Unburdened
				AlwaysOn=1
				PowerInvisible=1.15
				passives = list("Pursuer" = 1, "Godspeed" = 1)
				Pursuer=1
				Godspeed=1
				TimerLimit=10800
				ActiveMessage="drops their weights to the ground with a heavy impact!"
				KenWave=1
				DustWave=1
				Cooldown=1
			Unrestrained
				AlwaysOn=1
				PowerInvisible=1.15
				passives = list("Pursuer" = 1, "Godspeed" = 1, "Flicker" = 1)
				Flicker=1
				Pursuer=1
				Godspeed=1
				TimerLimit=10800
				ActiveMessage="drops their immensely heavy weights to the ground with a shattering impact!"
				KenWave=2
				DustWave=2
				Cooldown=1
//TS
			Demon_Illusion
				AlwaysOn=1
				NeedsPassword=1
				OffMult=0.8
				SpdMult=0.8
				EndMult=0.8
				ActiveMessage="finds their mind gripped by a demonic illusion!"
				OffMessage="feels the effects of the nightmare fading away..."
				KenWave=1
				KenWaveSize=0.7
				KenWaveBlend=2
				KenWaveTime=3
				KenWaveIcon='KenShockwaveFocus.dmi'
				TimerLimit=80
				Cooldown=1
			Demon_Grasp
				AlwaysOn=1
				NeedsPassword=1
				passives = list("Infatuated" = 1.5)
				Infatuated=1
				ActiveMessage="has their mind trapped by a demonic illusion! They need to witness death to regain freedom!"
				OffMessage="feels the effects of the curse fading away..."
				FadeByDeath = 1
				KenWave=3
				KenWaveSize=0.7
				KenWaveBlend=2
				KenWaveTime=3
				KenWaveIcon='KenShockwavePurple.dmi'
				Cooldown=1
			Punishment_of_Hell
				AlwaysOn=1
				KenWave=1
				WoundDrain=0.1
				ActiveMessage="experiences the suffering of Hell Realm - constant pain and injury!"
				KenWaveSize=1
				KenWaveBlend=2
				KenWaveTime=3
				KenWaveIcon='KenShockwavePurple.dmi'
				TimerLimit=30
				Cooldown=1
			Punishment_of_Spectres
				AlwaysOn=1
				KenWave=1
				FatigueDrain=0.2
				ActiveMessage="experiences the suffering of Specter Realm - nagging emptiness and hunger!"
				KenWaveSize=1
				KenWaveBlend=2
				KenWaveTime=3
				KenWaveIcon='KenShockwaveDivine.dmi'
				TimerLimit=30
				Cooldown=1
			Punishment_of_Beasts
				AlwaysOn=1
				passives = list("TechniqueMastery" = -3)
				TechniqueMastery=-3
				ActiveMessage="experiences the suffering of Beast Realm - instincts taking away from developing reason!"
				KenWave=1
				KenWaveSize=1
				KenWaveBlend=2
				KenWaveTime=3
				KenWaveIcon='KenShockwaveFocus.dmi'
				TimerLimit=30
				Cooldown=1
			Punishment_of_Humans
				AlwaysOn=1
				PowerMult=0.75
				ActiveMessage="experiences the suffering of Human Realm - lack of power to fulfil ones ambition!"
				KenWave=1
				KenWaveSize=1
				KenWaveBlend=2
				KenWaveTime=3
				KenWaveIcon='KenShockwaveLegend.dmi'
				TimerLimit=30
				Cooldown=1
			Punishment_of_Demons
				AlwaysOn=1
				AutoAnger=1
				passives = list("MovementMastery" = -3)
				MovementMastery=-3
				ActiveMessage="experiences the suffering of Demon Realm - boundless fury leading into peril!"
				KenWave=1
				KenWaveSize=1
				KenWaveBlend=2
				KenWaveTime=3
				KenWaveIcon='KenShockwaveBloodlust.dmi'
				TimerLimit=30
				Cooldown=1
			Punishment_of_Heaven
				AlwaysOn=1
				FlashChange=1
				ExplosiveFinish=-1
				ExplosiveFinishIntensity=5
				ActiveMessage="experiences the suffering of Heavenly Realm - inevitability of death!"
				OffMessage="feels their death approaching!"
				KenWave=1
				KenWaveSize=1
				KenWaveBlend=2
				KenWaveTime=3
				KenWaveIcon='KenShockwaveGold.dmi'
				TimerLimit=30
				Cooldown=1

			AntiForm
				DarkChange=1
				AlwaysOn=1
				PowerMult=1.25
				StrMult=1.5
				EndMult = 1.5
				SpdMult=1.5
				RecovMult=1.5
				passives = list("ActiveBuffLock" = 1,"SpecialBuffLock" = 1,"Godspeed" = 1, "Curse" = 1, "ManaLeak" = 2, "MartialMagic" = 1, "BladeFisting" = 1)
				Intimidation=2
				AutoAnger=1
				TooLittleMana=1
				AuraLock='AntiAura.dmi'
				VaizardHealth = 1
				VaizardShatter = 1
				AuraX=-18
				AuraY=-22
				KenWave=3
				KenWaveIcon='DarkKiai.dmi'
				ActiveBuffLock=1
				SpecialBuffLock=1
				IconTint=list(0.15,0,0, 0.05,0.25,0.15, 0.05,0.05,0.35, 0,0,0)
				IconLock='AntiEyes.dmi'
				IconApart=1
				ActiveMessage="is overwhelmed by their inner darkness!"
				OffMessage="exhausts the dark energy..."
				Cooldown = 1

			Minds_Eye
				TooMuchHealth = 99.8
				NeedsHealth = 99
				WoundIntentRequired = 1
				LockX=0
				LockY=0
				ActiveMessage="takes a deep breath, tapping into the insight of a weapon wielded by none other than a mortal, gained through tenacious training."
				OffMessage="seems to snap out of their haze."
				Cooldown=4//Just in case
				Trigger(mob/player, Override)
					if(!altered)
						passives = list("Godspeed" = floor(player.SagaLevel/2), "Pursuer" = floor(player.SagaLevel/2), "BlockChance" = player.SagaLevel*3, "CriticalBlock" = 0.2, "CriticalChance" = player.SagaLevel*3, "CriticalDamage" = 0.1)
						if(player.UBWPath=="Firm")
							passives["FakePeace"] = 1
					..()

			WillofAlaya
				NeedsHealth = 75
				TooMuchHealth = 90
				Godspeed = 1
				PowerMult=1.25
				Intimidation=2
				AutoAnger=1
				ManaLeak=0.5
				TooLittleMana=1
				Pursuer = 1
				WoundIntentRequired = 1
				IconLock='SlayerEyes.dmi'
				LockX=0
				LockY=0
				OffMessage="snaps out of their haze."
				ActiveMessage="is forced to lock up. <font color='yellow'>OVERRIDE: THREAT TO HUMANITY DETECTED - COUNTER GUARDIAN DEPLOYED.</b></font color>"

				Cooldown=1//Just in case
				Trigger(mob/player, Override)
					if(!altered)
						passives = list("SlayerMod" = player.SagaLevel * 0.25, "FavoredPrey" = "All", "Godspeed" = floor(player.SagaLevel/2), "Pursuer" = floor(player.SagaLevel/2))
						SlayerMod = player.SagaLevel * 0.25
						Godspeed = floor(player.SagaLevel / 2)
						Pursuer = floor(player.SagaLevel / 2)
					..()

			Satsui_Infected
				name="Satsui no Hado"
				NeedsHealth = 15
				TooMuchHealth = 16
				SpecialBuffLock=1
				StrMult=1.25
				ForMult=1.15
				VaizardHealth=2
				HitSpark='Hit Effect Satsui.dmi'
				HitX=-32
				HitY=-32
				Cooldown=-1
				ManaGlow="#911919"
				ManaGlowSize=4
				TextColor=rgb(215, 0, 0)
				ActiveMessage="has fallen victim to their demonic impulse to win at any cost!"
				OffMessage="manages to repress their demonic powers..."
				adjust(mob/p)
					passives = list("SpecialBuffLock" = 1,"KillerInstinct" = 0.1 * p.SagaLevel, "Curse" = 1, "Enraged" = p.SagaLevel, \
					"SlayerMod" = p.SagaLevel*0.25, "HardStyle" = 0.25 + (p.SagaLevel*0.25), "TechniqueMastery" = p.SagaLevel*0.75)
					NeedsHealth = 15 + (2.5 * p.SagaLevel)
					TooMuchHealth = NeedsHealth + p.SagaLevel
					VaizardHealth = 1 * p.SagaLevel

			Kyoi_no_Hado
				// like water, sunyata (% chance to negate queues, maybe not finishers)
				name = "Kyoi no Hado"
				NeedsHealth = 50
				TooMuchHealth = 75
				SpecialBuffLock = 1
				StrMult = 1.2
				ForMult = 1.2
				SpdMult = 1.2
				OffMult = 1.2
				DefMult = 1.2
				ManaGlow="#3bf2ff"
				ManaGlowSize=2
				Void=1
				Cooldown=-1
				TextColor=rgb(0, 0, 255)
				ActiveMessage="has harnessed the power of the Kyoi no Hado!"
				OffMessage="loses their connection to the Kyoi no Hado..."
				Trigger(mob/player, Override)
					if(!altered)
						passives = list("TechniqueMastery" = player.SagaLevel, "BuffMastery" = player.SagaLevel/2, "LikeWater" = player.SagaLevel-2, "Sunyata" = player.SagaLevel-2, \
						"FluidForm" = 1)
					..()

			Satsui_no_Hado
				name = "Satsui no Hado"
				NeedsHealth = 50
				TooMuchHealth = 75
				SpecialBuffLock=1
				StrMult=1.5
				ForMult=1.3
				KillerInstinct = 1
				VaizardHealth=1
				Curse=1
				Pursuer=2
				HardStyle=1.5
				HitSpark='Hit Effect Satsui.dmi'
				HitX=-32
				HitY=-32
				Cooldown=0
				ManaGlow="#911919"
				ManaGlowSize=4
				TextColor=rgb(215, 0, 0)
				ActiveMessage="is overcome by a demonic impulse to win at any cost!"
				OffMessage="manages to repress their urges..."
				Trigger(mob/player, Override)
					if(!altered)
						passives = list("SpecialBuffLock" = 1,"KillerInstinct" = clamp(player.SagaLevel/8, 0.1, 1), "Curse" = 1, "Enraged" =  2 + player.SagaLevel, "SlayerMod" = player.SagaLevel*0.75, \
						"HardStyle" = 1 + (player.SagaLevel*0.5), "TechniqueMastery" = player.SagaLevel)
						SlayerMod = player.SagaLevel * 0.5
						HardStyle = 1 + (player.SagaLevel * 0.25)
						TechniqueMastery = player.SagaLevel
					..()
			Hitokiri_Battosai
				StyleNeeded="Hiten Mitsurugi"
				SpecialBuffLock=1
				NeedsHealth=50
				TooMuchHealth=75
				StrMult = 1.15
				SpdMult = 1.15
				TechniqueMastery=5
				MovementMastery=5
				passives = list("SpecialBuffLock" = 1,"TechniqueMastery" = 2, "MovementMastery" = 3, "Instinct" = 2, "Flicker" = 2, "Curse" = 1)
				Instinct=2
				Flicker=2
				Curse=1
				IconLock='SlayerEyes.dmi'
				LockX=0
				LockY=0
				Cooldown=-1
				TextColor=rgb(215, 0, 0)
				BuffName="Battosai"
				ActiveMessage="becomes the embodiment of battoujutsu, an unstoppable manslayer Battosai!"
				OffMessage="restrains their nature as a killer..."
				Trigger(mob/User, Override = FALSE)
					if(!User.BuffOn(src))
						if(!altered)
							passives = list("SpecialBuffLock" = 1,"TechniqueMastery" = 2, "MovementMastery" = 3, "Instinct" = 2, "Flicker" = 2, "Curse" = 1)
					..()
			Kagutsuchi
				NeedsHealth=50
				TooMuchHealth=75
				ElementalOffense="Fire"
				ElementalDefense="Fire"
				OffTaxDrain=0.0002
				DefTaxDrain=0.0002
				passives = list("DarknessFlame" = 1, "DeathField" = 5)
				DarknessFlame=1
				DeathField=5
				DarkChange=1
				IconLock='DarknessFlameAura.dmi'
				LockX=-32
				LockY=-32
				IconLayer=-1
				HitSpark='fevExplosion - Hellfire.dmi'
				HitX=-32
				HitY=-32
				HitSize=1
				HitTurn=1
				TextColor=rgb(102, 102, 102)
				ActiveMessage="shapes the dark flames into a protective cage!"
				OffMessage="releases the dark flames..."
				adjust(mob/p)
					if(altered) return
					if(p.SagaLevel>=5)
						OffTaxDrain = 0
						DefTaxDrain = 0
					if(p.equippedSword)
						passives = list("DarknessFlame" = 1, "DeathField" = p.SagaLevel, "SpiritSword" =  p.SagaLevel * 0.25)
					else
						passives = list("DarknessFlame" = 1, "DeathField" = p.SagaLevel, "SpiritHand" =  p.SagaLevel * 0.25)
				Trigger(mob/User, Override = FALSE)
					if(!User.BuffOn(src))
						adjust(User)
					..()
			Absorbtion_Shield
				AlwaysOn=1
				passives = list("Siphon" = 1)
				Siphon=1
				FlashChange=1
				IconLock='preta.dmi'
				IconLayer=-1
				IconLockBlend=2
				IconApart=1
				OverlaySize=1.3
				TimerLimit=30
				ActiveMessage="begins consuming all types of energy!"
				Cooldown=1
			Godly_Empowerment
				AlwaysOn=1
				passives = list("GiantForm" = 1, "Juggernaut" = 1, "DebuffResistance" = 3)
				GiantForm=1
				Juggernaut=1
				DebuffResistance=1
				Enlarge=3
				Cooldown=1

//Secret
			Ripple_Enhancement
				AlwaysOn=1
				BuffName="Sparkling Ripple"
				IconLock='Ripple Aura.dmi'
				IconLockBlend=2
				PoseEnhancement=1
				TimerLimit=30
			Senjutsu_Imbued
				AlwaysOn=1
				BuffName="Senjutsu Focus"//Used to gain mana beyond 100 while medding
				TimerLimit=180
			Restraint_Release
				AlwaysOn=1
				DarkChange=1
				passives = list("FluidForm" = 1)
				PoseEnhancement=1
				FluidForm=1
				IconTint=list(0.08,0,0, 0,0,0, 0.06,0,0, 0,0,0)
				IconLock='Vampire Transformation.dmi'
				IconApart=1
				TimerLimit=90
				ActiveMessage="momentarily releases their restraints and becomes a creature of darkness!"
			Sennin_Mode
				BuffName="Sage Mode"
				ManaThreshold=125
				TooLittleMana=50
				passives = list("ManaLeak" = 2, "ManaStats" = 1, "DrainlessMana" = 1, "MagicFocus" = 1, "AllOutAttack" = 1, "SuperDash" = 1)
				ManaLeak=2
				ManaStats=1
				DrainlessMana=1
				MagicFocus=1
				PoseEnhancement=1
				AllOutAttack=1
				SuperDash=1
				TextColor=rgb(235, 230, 40)
				IconLock='EyesSage.dmi'
				IconLayer=4
				ActiveMessage="integrates the natural energy in their body; subtle markings appear around their eyes!"
				OffMessage="loses their markings as the natural energy runs dry..."
mob
	proc
		UseBuff(var/obj/Skills/Buffs/B, var/Override)
			. = TRUE
			if(src.BuffOn(B))
				if(B.MakesArmor)
					if(src.ActiveBuff)
						if(src.ActiveBuff.NeedsArmor)
							src << "[src.ActiveBuff] can no longer be used without armor!"
							src.ActiveBuff.Trigger(src, Override=1)
					if(src.SpecialBuff)
						if(src.SpecialBuff.NeedsArmor)
							src << "[src.SpecialBuff] can no longer be used without armor!"
							src.SpecialBuff.Trigger(src, Override=1)
					if(src.SlotlessBuffs.len>0)
						for(var/b in src.SlotlessBuffs)
							var/obj/Skills/Buffs/SlotlessBuffs/sb = SlotlessBuffs[b]
							if(sb)
								if(sb.NeedsArmor)
									src << "[sb] can no longer be used without armor!"
									sb.Trigger(src, Override=1)
					if(src.StanceBuff)
						if(src.StanceBuff.NeedsArmor)
							src << "[src.StanceBuff] can no longer be used without armor!"
							src.StanceBuff.Trigger(src, Override=1)
					if(src.StyleBuff)
						if(src.StyleBuff.NeedsArmor)
							src << "[src.StyleBuff] can no longer be used without armor!"
							src.StyleBuff.Trigger(src, Override=1)
				if(B.MakesStaff)
					if(src.ActiveBuff)
						if(src.ActiveBuff.NeedsStaff)
							src << "[src.ActiveBuff] can no longer be used without a staff!"
							src.ActiveBuff.Trigger(src, Override=1)
					if(src.SpecialBuff)
						if(src.SpecialBuff.NeedsStaff)
							src << "[src.SpecialBuff] can no longer be used without a staff!"
							src.SpecialBuff.Trigger(src, Override=1)
					if(src.SlotlessBuffs.len>0)
						for(var/b in src.SlotlessBuffs)
							var/obj/Skills/Buffs/SlotlessBuffs/sb = SlotlessBuffs[b]
							if(sb)
								if(sb.NeedsStaff)
									src << "[sb] can no longer be used without a staff!"
									sb.Trigger(src, Override=1)
					if(src.StanceBuff)
						if(src.StanceBuff.NeedsStaff)
							src << "[src.StanceBuff] can no longer be used without a staff!"
							src.StanceBuff.Trigger(src, Override=1)
					if(src.StyleBuff)
						if(src.StyleBuff.NeedsStaff)
							src << "[src.StyleBuff] can no longer be used without a staff!"
							src.StyleBuff.Trigger(src, Override=1)
				if(B.MakesSword || B.KiBlade)
					if(src.ActiveBuff)
						if(src.ActiveBuff.NeedsSword)
							src << "[src.ActiveBuff] can no longer be used without a sword!"
							src.ActiveBuff.Trigger(src, Override=1)
					if(src.SpecialBuff)
						if(src.SpecialBuff.NeedsSword)
							src << "[src.SpecialBuff] can no longer be used without a sword!"
							src.SpecialBuff.Trigger(src, Override=1)
					if(src.SlotlessBuffs.len>0)
						for(var/b in src.SlotlessBuffs)
							var/obj/Skills/Buffs/SlotlessBuffs/sb = SlotlessBuffs[b]
							if(sb)
								if(sb.NeedsSword)
									src << "[sb] can no longer be used without a sword!"
									sb.Trigger(src, Override=1)
					if(src.StanceBuff)
						if(src.StanceBuff.NeedsSword)
							src << "[src.StanceBuff] can no longer be used without a sword!"
							src.StanceBuff.Trigger(src, Override=1)
					if(src.StyleBuff)
						if(src.StyleBuff.NeedsSword)
							src << "[src.StyleBuff] can no longer be used without a sword!"
							src.StyleBuff.Trigger(src, Override=1)
				if(B.type==/obj/Skills/Buffs/NuStyle/SwordStyle)
					if(src.ActiveBuff)
						if(!src.ActiveBuff.KiBlade && (src.ActiveBuff.NoSword||src.ActiveBuff.UsesStance))
							src << "[src.ActiveBuff] cannot be used with a sword and no Champloo Style."
							src.ActiveBuff.Trigger(src, Override=1)
					if(src.SpecialBuff)
						if(!src.SpecialBuff.KiBlade && (src.SpecialBuff.NoSword||src.SpecialBuff.UsesStance))
							src << "[src.SpecialBuff] cannot be used with a sword and no Champloo Style."
							src.SpecialBuff.Trigger(src, Override=1)
					if(src.SlotlessBuffs.len>0)
						for(var/b in src.SlotlessBuffs)
							var/obj/Skills/Buffs/SlotlessBuffs/sb = SlotlessBuffs[b]
							if(sb)
								if(!sb.KiBlade && (sb.NoSword||sb.UsesStance))
									src << "[sb] cannot be used with a sword and no Champloo Style."
									sb.Trigger(src, Override=1)
					if(src.StanceBuff)
						src << "[src.StanceBuff] cannot be used with a sword and no Champloo Style."
						src.StanceBuff.Trigger(src)
				if(B.type==/obj/Skills/Buffs/NuStyle/SwordStyle/Battle_Mage_Style)
					if(src.ActiveBuff)
						if(src.ActiveBuff.NoStaff&&src.HasStaff())
							src << "[src.ActiveBuff] cannot be used with a staff and no Battle Mage."
							src.ActiveBuff.Trigger(src, Override=1)
					if(src.SpecialBuff)
						if(src.SpecialBuff.NoStaff&&src.HasStaff())
							src << "[src.SpecialBuff] cannot be used with a staff and no Battle Mage."
							src.SpecialBuff.Trigger(src, Override=1)
					if(src.SlotlessBuffs.len>0)
						for(var/b in src.SlotlessBuffs)
							var/obj/Skills/Buffs/SlotlessBuffs/sb = SlotlessBuffs[b]
							if(sb.NoStaff&&src.HasStaff())
								src << "[sb] cannot be used with a staff and no Battle Mage."
								sb.Trigger(src)
					if(src.StanceBuff)
						if(src.StanceBuff.NoStaff&&src.HasStaff())
							src << "[src.StanceBuff] cannot be used with a staff and no Battle Mage."
							src.StanceBuff.Trigger(src, Override=1)
				if(B.type==/obj/Skills/Buffs/NuStyle/SwordStyle/Fist_of_Khonshu)
					if(src.ActiveBuff)
						if(src.ActiveBuff.NeedsSword)
							src << "[src.ActiveBuff] cannot be used without a sword and no Living Weapon stance."
							src.ActiveBuff.Trigger(src, Override=1)
					if(src.SpecialBuff)
						if(src.SpecialBuff.NeedsSword)
							src << "[src.SpecialBuff] cannot be used without a sword and no Living Weapon stance."
							src.SpecialBuff.Trigger(src, Override=1)
					if(src.SlotlessBuffs.len>0)
						for(var/b in src.SlotlessBuffs)
							var/obj/Skills/Buffs/SlotlessBuffs/sb = SlotlessBuffs[b]
							if(sb)
								if(sb.NeedsSword)
									src << "[sb] cannot be used without a sword and no Living Weapon stance."
									sb.Trigger(src, Override=1)
					if(src.StyleBuff)
						if(src.StyleBuff.NeedsSword)
							src << "[src.StyleBuff] cannot be used without a sword and no Living Weapon stance."
							src.StyleBuff.Trigger(src, Override=1)

			if(!src.BuffOn(B))
				if(B.AssociatedGear)
					if(!B.AssociatedGear.InfiniteUses)
						if(B.Integrated)
							if(B.AssociatedGear.IntegratedUses<=0)
								src << "Your [B.AssociatedGear] doesn't have any power!"
								if(src.ManaAmount>=10)
									src << "Your [B] automatically draws on new power to reload!"
									src.LoseMana(10)
									B.AssociatedGear.IntegratedUses=B.AssociatedGear.IntegratedMaxUses
								return
						else
							if(B.AssociatedGear.Uses<=0)
								src << "Your [B.AssociatedGear] doesn't have any power!"
								return
				if(B.Range)//This one doesn't apply to rushes.
					if(!src.Target)
						src << "You need a target to use this skill!"
						if(B.AffectTarget)
							return FALSE
						if(!B.Using)
							B.Trigger(src, Override=1)
						return FALSE
					if(B.ForcedRange)
						if(get_dist(src,src.Target)!=B.Range)
							src << "They're not in range!"
							return FALSE
					else
						if(get_dist(src,src.Target)>B.Range||src.z!=src.Target.z)
							src << "They're out of range!"
							return FALSE
				if(B.AffectTarget)
					if(!src.Target)
						src << "You don't have a target to capture!"
						return FALSE

				if(B.MagicNeeded&&!B.LimitlessMagic&&!src.HasLimitlessMagic())
					if(src.HasMechanized()&&src.HasLimitlessMagic()!=1)
						src << "You lack the ability to use magic!"
						if(istype(B, /obj/Skills/Buffs/SlotlessBuffs/Autonomous))
							del B
						return FALSE
					if((B.Copyable>=3||!B.Copyable)&&!(istype(B, /obj/Skills/Buffs/SlotlessBuffs/Autonomous)))
						if(!src.HasSpellFocus(B) && !B.MagicFocus)
							src << "You need a spell focus to use [B]."
							return FALSE
				if(!B.heavenlyRestrictionIgnore&&B.MagicNeeded && Secret=="Heavenly Restriction" && secretDatum?:hasRestriction("Magic"))
					return
				if(!B.heavenlyRestrictionIgnore&&B.MakesSword && Secret=="Heavenly Restriction" && secretDatum?:hasRestriction("Sword"))
					return
				if(!B.heavenlyRestrictionIgnore&&B.MakesArmor && Secret=="Heavenly Restriction" && secretDatum?:hasRestriction("Armor"))
					return
				if(!B.heavenlyRestrictionIgnore&&B.MakesStaff && Secret=="Heavenly Restriction" && secretDatum?:hasRestriction("Staff"))
					return
				if(B.StyleNeeded)
					if(src.StyleActive!=B.StyleNeeded)
						src << "You can't trigger [B] without [B.StyleNeeded] active!"
						return
				if(B.ActiveSlot)
					if(src.HasActiveBuffLock()||src.KamuiBuffLock)
						src << "Your active buffs are locked out!"
						return
				if(B.SpecialSlot)
					if(src.HasSpecialBuffLock()||src.KamuiBuffLock||!B.heavenlyRestrictionIgnore&& Secret=="Heavenly Restriction" && secretDatum?:hasRestriction("Special Slotter"))
						src << "Your special buffs are locked out!"
						return
				if(B.ActiveBuffLock)
					if(src.ActiveBuff)
						if(src.CheckActive("Eight Gates"))
							src.ActiveBuff:Stop_Cultivation()
						else
							src.ActiveBuff.Trigger(src, Override=1)
				if(B.SpecialBuffLock)
					if(src.SpecialBuff)
						src.SpecialBuff.Trigger(src, Override=1)
				if(src.CheckSlotless("Great Ape"))
					if(!B.StanceSlot&&!B.StyleSlot&&!B.Autonomous)
						if(!B.BuffName == "Great Ape")
							src << "You can't use buffs in Great Ape Mode!"
							return
				if(src.CheckSlotless("Full Moon Form")&&!B.UnrestrictedBuff)
					if(!B.StanceSlot&&!B.StyleSlot&&!B.Autonomous)
						src << "You can't use buffs in Full Moon Frenzy!"
						return
				if(B.Using&&!Override)
					if(!(src.CheckSlotless("Libra Armory")&&istype(B, /obj/Skills/Buffs/NuStyle)))
						src << "It's too soon to use [B] yet!"
						return
				if(B.NeedsStaff)
					var/obj/Items/Enchantment/Staff/st=src.EquippedStaff()
					if(!st)
						src << "You need a staff to use [B]."
						return
				if(B.ClassNeeded)
					var/obj/Items/Sword/s=src.EquippedSword()
					if(s&&s.Class == 0)  // 0 is the default class
						src << "You need a classed weapon to use this technique."
						return
					if(!s||s.Class!=B.ClassNeeded && (istype(B.ClassNeeded, /list) && !(s.Class in B.ClassNeeded)))
						src << "You need a [istype(B.ClassNeeded, /list) ? B.ClassNeeded[1] : B.ClassNeeded]-class weapon to use this technique."
						return
				if(B.NeedsSword)
					var/obj/Items/Sword/s=src.EquippedSword()
					if(!s)
						if(!HasBladeFisting())
							src << "You must be using a sword to use [B]."
							return
					if(B.HeavyOnly)
						if(s.Class != "Heavy")
							src << "You must use a Heavy Sword with [B]."
							return
				if(B.NeedsSecondSword)
					var/found=0
					for(var/obj/Items/Sword/s in src)
						if(s.suffix=="*Equipped*")
							continue
						else
							found=1
					if(!found)
						var/obj/Skills/Buffs/make_another
						if(ActiveBuff && ActiveBuff.MakesSword == 3) make_another = ActiveBuff
						if(SpecialBuff && SpecialBuff.MakesSword == 3) make_another = SpecialBuff
						if(StanceBuff && StanceBuff.MakesSword == 3) make_another = StanceBuff
						if(StyleBuff && StyleBuff.MakesSword == 3) make_another = StyleBuff
						for(var/sb in src.SlotlessBuffs)
							var/obj/Skills/Buffs/b = SlotlessBuffs[sb]
							if(b.MakesSword == 3)
								make_another = b
						if(make_another)
							var/obj/Items/Sword/s
							if(make_another.SwordClassSecond) switch(make_another.SwordClassSecond)
								if("Wooden")
									s=new/obj/Items/Sword/Wooden
								if("Light")
									s=new/obj/Items/Sword/Light
								if("Medium")
									s=new/obj/Items/Sword/Medium
								if("Heavy")
									s=new/obj/Items/Sword/Heavy
								else
									s=new/obj/Items/Sword/Medium
							else switch(make_another.SwordClass)
								if("Wooden")
									s=new/obj/Items/Sword/Wooden
								if("Light")
									s=new/obj/Items/Sword/Light
								if("Medium")
									s=new/obj/Items/Sword/Medium
								if("Heavy")
									s=new/obj/Items/Sword/Heavy
								else
									s=new/obj/Items/Sword/Medium
							//no need to stack icons if they don't have 2nd/3rd icons
							if(make_another.SwordIconSecond)
								s.icon=make_another.SwordIconSecond
								if(make_another.SwordXSecond)
									s.pixel_x=make_another.SwordXSecond
								if(make_another.SwordYSecond)
									s.pixel_y=make_another.SwordYSecond
							if(make_another.SwordNameSecond)
								s.name=make_another.SwordNameSecond
							src.contents+=s
							if(make_another.SwordAscension)
								s.InnatelyAscended=make_another.SwordAscensionSecond ? make_another.SwordAscensionSecond : make_another.SwordAscension
							if(make_another.MagicSword)
								s.MagicSword+=make_another.MagicSwordSecond ? make_another.MagicSwordSecond : make_another.MagicSword
							if(make_another.SpiritSword)
								s.SpiritSword+=make_another.SpiritSword
							if(make_another.Extend)
								s.Extend+=make_another.Extend
							s.Conjured=1
							s.Cost=0
							s.Stealable=0
							if(make_another.FlashDraw)
								var/image/si=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, loc=src)
								if(src.CheckActive("Mobile Suit")&&B.BuffName!="Mobile Suit")
									si.transform*=3
								animate(si, alpha=255, color = list(1,0,0, 0,1,0, 0,0,1, 1,1,1))
								world << si
								spawn()
									animate(si, alpha=0, time=3)
									sleep(3)
									del si
							s.AlignEquip(src)
						//	s.suffix="*Equipped (Second)*"
						else
							src << "You need another sword in order to use [B]!"
							return
				if(B.NeedsThirdSword)
					var/found2=0
					var/found3=0
					for(var/obj/Items/Sword/s in src)
						if(s.suffix=="*Equipped*")
							continue
						if(!found2)
							found2=s
							continue
						if(!found3)
							if(s==found2)
								continue
							else
								found3=s
					if(!found2||!found3)
						var/obj/Skills/Buffs/make_another
						if(ActiveBuff && ActiveBuff.MakesSword == 3) make_another = ActiveBuff
						if(SpecialBuff && SpecialBuff.MakesSword == 3) make_another = SpecialBuff
						if(StanceBuff && StanceBuff.MakesSword == 3) make_another = StanceBuff
						if(StyleBuff && StyleBuff.MakesSword == 3) make_another = StyleBuff
						for(var/sb in src.SlotlessBuffs)
							var/obj/Skills/Buffs/b = SlotlessBuffs[sb]
							if(b.MakesSword == 3)
								make_another = b
						if(make_another)
							if(!found2)
								var/obj/Items/Sword/s
								if(make_another.SwordClassSecond) switch(make_another.SwordClassSecond)
									if("Wooden")
										s=new/obj/Items/Sword/Wooden
									if("Light")
										s=new/obj/Items/Sword/Light
									if("Medium")
										s=new/obj/Items/Sword/Medium
									if("Heavy")
										s=new/obj/Items/Sword/Heavy
									else
										s=new/obj/Items/Sword/Medium
								else switch(make_another.SwordClass)
									if("Wooden")
										s=new/obj/Items/Sword/Wooden
									if("Light")
										s=new/obj/Items/Sword/Light
									if("Medium")
										s=new/obj/Items/Sword/Medium
									if("Heavy")
										s=new/obj/Items/Sword/Heavy
									else
										s=new/obj/Items/Sword/Medium
								//no need to stack icons if they don't have 2nd/3rd icons
								if(make_another.SwordIconSecond)
									s.icon=make_another.SwordIconSecond
									if(make_another.SwordXSecond)
										s.pixel_x=make_another.SwordXSecond
									if(make_another.SwordYSecond)
										s.pixel_y=make_another.SwordYSecond
								if(make_another.SwordNameSecond)
									s.name=make_another.SwordNameSecond
								src.contents+=s
								if(make_another.SwordAscension)
									s.InnatelyAscended=make_another.SwordAscensionSecond ? make_another.SwordAscensionSecond : make_another.SwordAscension
								if(make_another.MagicSword)
									s.MagicSword+=make_another.MagicSwordSecond ? make_another.MagicSwordSecond : make_another.MagicSword
								if(make_another.SpiritSword)
									s.SpiritSword+=make_another.SpiritSword
								if(make_another.Extend)
									s.Extend+=make_another.Extend
								s.Conjured=1
								s.Cost=0
								s.Stealable=0
								s.AlignEquip(src)
							//	s.suffix="*Equipped (Second)*"


							var/obj/Items/Sword/s
							if(make_another.SwordClassThird) switch(make_another.SwordClassThird)
								if("Wooden")
									s=new/obj/Items/Sword/Wooden
								if("Light")
									s=new/obj/Items/Sword/Light
								if("Medium")
									s=new/obj/Items/Sword/Medium
								if("Heavy")
									s=new/obj/Items/Sword/Heavy
							else switch(make_another.SwordClass)
								if("Wooden")
									s=new/obj/Items/Sword/Wooden
								if("Light")
									s=new/obj/Items/Sword/Light
								if("Medium")
									s=new/obj/Items/Sword/Medium
								if("Heavy")
									s=new/obj/Items/Sword/Heavy
								else
									s=new/obj/Items/Sword/Medium
							//no need to stack icons if they don't have 2nd/3rd icons
							if(make_another.SwordIconThird)
								s.icon=make_another.SwordIconThird
								if(make_another.SwordXThird)
									s.pixel_x=make_another.SwordXThird
								if(make_another.SwordYThird)
									s.pixel_y=make_another.SwordYThird
							if(make_another.SwordNameThird)
								s.name=make_another.SwordNameThird
							src.contents+=s
							if(make_another.SwordAscension)
								s.InnatelyAscended=make_another.SwordAscensionThird ? make_another.SwordAscensionThird : make_another.SwordAscension
							if(make_another.MagicSword)
								s.MagicSword+=make_another.MagicSwordThird ? make_another.MagicSwordThird : make_another.MagicSword
							if(make_another.SpiritSword)
								s.SpiritSword+=make_another.SpiritSword
							if(make_another.Extend)
								s.Extend+=make_another.Extend
							s.Conjured=1
							s.Cost=0
							s.Stealable=0
							if(make_another.FlashDraw)
								var/image/si=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, loc=src)
								if(src.CheckActive("Mobile Suit")&&B.BuffName!="Mobile Suit")
									si.transform*=3
								animate(si, alpha=255, color = list(1,0,0, 0,1,0, 0,0,1, 1,1,1))
								world << si
								spawn()
									animate(si, alpha=0, time=3)
									sleep(3)
									del si
							s.AlignEquip(src)
						//	s.suffix="*Equipped (Third)*"

						else
							src << "You need two unequipped swords in order to use [B]!"
							return
				if(B.ABuffNeeded)
					if(B.ABuffNeeded.len>0)
						if(!src.ActiveBuff||!(src.ActiveBuff.BuffName in B.ABuffNeeded))
							var/List="("
							var/Place=0
							for(var/x in B.ABuffNeeded)
								Place++
								if(Place!=B.ABuffNeeded.len)
									List+="[x], "
								else
									List+="[x])"
							src << "You don't have the proper active buff active! [List]"
							return
				if(B.UBuffNeeded)
					if(src.SlotlessBuffs.len!=0)
						for(var/buff in B.UBuffNeeded)
							if(!CheckSlotless(buff))
								src << "You need [buff] enabled to use [src.name]!"
								return
					else
						var/buffsRequired = ""
						for(var/buff in B.UBuffNeeded)
							buffsRequired += "[buff],"
						buffsRequired = replacetext(buffsRequired, ",", "", length(buffsRequired)-2, 0)
						src << "You have to be using [buffsRequired] to turn [src.name] on!"
						return
				if(B.CantHaveTheseBuffs)
					if(src.SlotlessBuffs.len!=0)
						for(var/buff in B.CantHaveTheseBuffs)
							if(CheckSlotless(buff))
								src << "You can't have [buff] enabled to use [src.name]!"
								return
				if(B.SBuffNeeded)
					if(!src.SpecialBuff||src.SpecialBuff.BuffName!=B.SBuffNeeded)
						src << "You have to be in [B.SBuffNeeded] state!"
						return
				if(B.NeedsSSJ)
					if(B.NeedsSSJ<0)
						if(isRace(SAIYAN)&&src.transActive)
							src << "You need to be in base form to use this!"
							return
					else
						if(isRace(SAIYAN)&&src.transActive!=B.NeedsSSJ)
							src << "You need to be in Super Saiyan [B.NeedsSSJ] to use this!"
							return
				if(B.NeedsTrans)
					if(B.NeedsTrans<0)
						if(transActive)
							src << "You need to be in base form to use this!"
							return
					else
						if(.transActive!=B.NeedsTrans)
							src << "You need to be in Super Form [B.NeedsTrans] to use this!"
							return
				if(B.NeedsTier)
					if(src.SagaLevel<B.NeedsTier)
						src << "You are not advanced enough to use this!"
						return
				if(!B.AllOutAttack)
					if(B.ResourceCost)
						var/resourceName = B.ResourceCost[1]
						var/storage = 0
						var/cost = B.ResourceCost[2]
						if(resourceName in vars) //AHAHAHA!
							// the cost associated exists
							storage = vars[resourceName]
						else
							if(passive_handler[resourceName])
								storage = passive_handler[resourceName]
						if(cost == 999)
							cost = storage
						else if(cost == 0.5)
							cost = storage/2
						else
							if(storage - cost < 0)
								src << " you need more [resourceName]"
								return FALSE
					if(B.ResourceThreshold)
						var/resourceName = B.ResourceThreshold[1]
						if(vars[resourceName])
							// the cost associated exists
							var/storage = vars[resourceName]
							var/threshold = B.ResourceThreshold[2]
							if(resourceName in list("Health","Energy"))
								if(storage<threshold*(1-vars["[resourceName]Cut"]))
									if(!B.Autonomous)
										src << "You don't have enough [resourceName] to use [B]"
									return FALSE



					if(B.CorruptionCost)
						if(src.Corruption - B.CorruptionCost < 0)
							src << "You need more corruption"
							return FALSE
					if(B.HealthThreshold)
						if(src.Health<B.HealthThreshold*(1-src.HealthCut))
							if(!B.Autonomous)
								src << "You don't have enough health to use [B]."
							return
					if(B.WoundDrain&&B.WoundThreshold)
						if(src.TotalInjury>=B.WoundThreshold)
							if(!B.Autonomous)
								src << "You have too many wounds to use [B] right now."
							return
					if(B.EnergyThreshold)
						if(src.Energy<B.EnergyThreshold*(1-src.EnergyCut))
							if(!B.Autonomous)
								src << "You don't have enough energy to use [B]."
							return
					if(B.FatigueDrain&&B.FatigueThreshold)
						if(src.TotalFatigue>=B.FatigueThreshold)
							if(!B.Autonomous)
								src << "You are too fatigued to use [B] right now."
							return
					if(B.ManaThreshold)
						if(src.ManaAmount<B.ManaThreshold)
							if(!B.Autonomous)
								src << "You don't have enough mana to use [B]."
							return
					if(B.CapacityDrain&&B.CapacityThreshold)
						if(src.TotalCapacity>=B.CapacityThreshold)
							if(!B.Autonomous)
								src << "You don't have enough mana capacity to use [B] right now."
							return
					if(B.HealthCost)
						if(src.Health<B.HealthCost)
							if(!B.Autonomous)
								src << "You don't have enough health to activate [B]."
							return
					if(B.EnergyCost)
						var/drain = passive_handler["Drained"] ? B.EnergyCost * (1 + passive_handler["Drained"]/10) : B.EnergyCost
						if(src.Energy<drain)
							if(!B.Autonomous)
								src << "You don't have enough energy to activate [B]."
							return
					if(B.ManaCost && !src.HasDrainlessMana())
						if(!src.TomeSpell(B))
							if(src.ManaAmount<B.ManaCost)
								if(!B.Autonomous)
									src << "You don't have enough mana to activate [B]."
								return FALSE
						else
							if(src.ManaAmount<B.ManaCost*(1-(0.45*src.TomeSpell(B))))
								if(!B.Autonomous)
									src << "You don't have enough mana to activate [B]."
								return FALSE
					if(B.WoundCost)
						if(src.TotalInjury+B.WoundCost>100)
							if(!B.Autonomous)
								src << "You have too many wounds to activate [B]."
							return
					if(B.FatigueCost)
						if(src.TotalFatigue+B.FatigueCost>100)
							if(!B.Autonomous)
								src << "You have too much fatigue to activate [B]."
							return
					if(B.CapacityCost)
						if(src.TotalCapacity+B.CapacityCost>100)
							if(!B.Autonomous)
								src << "You don't have enough mana capacity to activate [B]."
							return
				if(B.MakesArmor)
					var/obj/Items/Armor/S=src.EquippedArmor()
					if(S)
						src << "You can't use this while wearing armor because it makes a set!"
						return
				if(B.MakesSword)
					var/obj/Items/Sword/S=src.EquippedSword()
					var/obj/Items/Enchantment/Staff/T=src.EquippedStaff()
					if(S)
						src << "You can't use this while using a sword because it makes one!"
						return
					if(T)
						if(!src.ArcaneBladework&&!isRace(DEMON))
							src <<"You cannot create a blade while holding a staff!"
							return
					if(src.HasNoSword())
						if(!HasBladeFisting()|| !B.Piloting)
							src << "You cannot create a sword while using something that requires you to have no sword!"
							return
				if(B.MakesStaff)
					var/obj/Items/Sword/sord=src.EquippedSword()
					var/obj/Items/Enchantment/Staff/staf=src.EquippedStaff()
					if(sord)
						if(!src.ArcaneBladework&&!isRace(DEMON))
							src << "You can't use [B] to make a staff while wielding a sword!"
							return
					if(staf)
						src << "You can't use [B] to make a staff while already using one!"
						return
					if(src.StanceActive)
						if(!src.ArcaneBladework && (!src.StyleBuff||src.StyleBuff.type!=/obj/Skills/Buffs/NuStyle/SwordStyle/Battle_Mage_Style&&!src.HasMovingCharge()))
							src << "You can't use [B] to make a staff while using a stance!"
							return
				if(B.NoSword)
					var/obj/Items/Sword/S=src.EquippedSword()
					if(S)
						// if(!HasBladeFisting())
						if(src.HasNeedsSword())
							src << "You cannot use [B] while using something that requires you to have a sword!"
							return
						src << "You can't use [B] while using a sword."
						return
				if(B.NoStaff)
					var/obj/Items/Enchantment/Staff/St=src.EquippedStaff()
					if(St)
						if(src.NotUsingBattleMage())
							if(src.HasNeedsStaff())
								src << "You cannot use [B] while using something that requires you to have a staff!"
								return
							src << "You can't use [B] while using a staff."
							return
				if(B.NeedsAnger)
					if(!src.Anger)
						src << "You can't use [B] before you're angry!"
						return
				if(B.NeedsHealth)
					if(src.Health>B.NeedsHealth*(1-src.HealthCut))
						src << "You can't use [B] before you're below [B.NeedsHealth*(1-src.HealthCut)]% health!"
						return
				if(length(B.passives) > 0)
					if(B.passives["PULock"])
						if(src.PowerControl>100)
							src << "You can't use this buff right now because it seals your power up."
							return
					if(B.passives["PUSpike"])
						if(src.passive_handler.Get("PULock"))
							src << "You can't use this buff right now because your power up is sealed."
							return
				if(B.Ripple)
					if(isRace(ANDROID))
						src <<"You do not breathe."
						return
					if(src.IsEvil())
						if(!src.HasGodKi())
							src.Death(null, "suicidal stupidity!", SuperDead=1)
							return
				if(B.WarpZone)
					if(!B.WarpX||!B.WarpY||!B.WarpZ)
						src << "Your duel location hasn't been set!"
						return
					if(!locate(B.WarpX, B.WarpY, B.WarpZ))
						src << "Your assigned duel location doesn't exist!"
						return
						if(src.Target==null)
							src << "You don't have a target to warp with!"
							return
				if(B.AssociatedGear)
					if(!B.AssociatedGear.InfiniteUses)
						if(B.Integrated)
							B.AssociatedGear.IntegratedUses--
							if(B.AssociatedGear.IntegratedUses<=0)
								src << "Your [B] is out of power!"
								if(src.ManaAmount>=10)
									src << "Your [B] automatically draws on new power to reload!"
									src.LoseMana(10)
									B.AssociatedGear.IntegratedUses=B.AssociatedGear.IntegratedMaxUses
						else
							B.AssociatedGear.Uses--
							if(B.AssociatedGear.Uses<=0)
								src << "[B] is out of power!"
				if(B.Transform)
					if(!(B.Transform in list("Force","Strong","Weak")))
						if(transActive)
							src <<"You are already transformed!"
							return

			if(B.applyToTarget&&ismob(src.Target))
				if(B.CastingTime)
					spawn(B.CastingTime)
						B.applyToTarget.Trigger(src.Target, Override = 1)
				else
					B.applyToTarget.Trigger(src.Target, Override=1)
			if(B.StyleSlot)
				var/obj/Items/Sword/S=src.EquippedSword()
				if(S)
					if(B.NoSword)
						src << "You can't use [B] while having a sword equipped!"
						return
				if(src.StyleBuff)
					if(src.BuffOn(B))
						src.RemoveStyleBuff()
						passive_handler.decreaseList(B.current_passives)
						return
					else
						src.StyleBuff.Trigger(src, Override=1)
						return

				if(B.Copyable)
					spawn() for(var/mob/m in view(10, src))
						if(m.CheckSpecial("Sharingan"))
							var/copy = B.Copyable
							var/copyLevel = getSharCopyLevel(m.SagaLevel)
							if(m.client&&m.client.address==src.client.address)
								continue
							if(B.NewCopyable)
								copy = B.NewCopyable
							else
								copy = B.Copyable
							if(glob.SHAR_COPY_EQUAL_OR_LOWER)
								if(copyLevel < copy)
									continue
							else
								if(copyLevel <= copy)
									continue
							if(!locate(B.type, m))
								var/obj/Skills/copiedSkill = new B.type
								m.AddSkill(copiedSkill)
								copiedSkill.Copied = TRUE
								copiedSkill.copiedBy = "Sharingan"
								m << "Your Sharingan analyzes and stores the [B.StyleActive] style you've just viewed."
					spawn()
						for(var/obj/Items/Tech/Security_Camera/SC in view(10, src))
							if(IsList(B.PreRequisite))
								SC.ObservedTechniques["[B.type]"]=B.Copyable

				src.StyleBuff=B
				if(src.Secret=="Ripple")
					src << "You channel the graceful motions of the Ripple through your style!"
				if(src.Secret=="Senjutsu")
					src << "You surround your body with a nimbus of natural energy, becoming able to strike targets without physical contact!"
				if(src.Secret=="Werewolf")
					src << "You channel the shifting phases of the Moon through your style!"
				if(src.Secret=="Vampire")
					src << "You channel the haziness of Shadow through your style!"
				if(src.Secret=="Zombie")
					src << "You channel the stillness of the Underworld through your style!"
				src.AddStyleBuff()
				B.current_passives = B.passives
				passive_handler.increaseList(B.passives)
			if(B.ActiveSlot)//If the buff you pressed the button for is active slots...
				if(src.ActiveBuff)//And you already have an active buff...
					if(!src.BuffOn(B))//Check if it is the buff that is active.
						src << "You're already using an active buff."
						return//If not, post this message.
					else//Buf if it's the same...
						src.RemoveActiveBuff()//Remove the buff
						passive_handler.decreaseList(B.current_passives)
				else//If there is no buff active...
					src.ActiveBuff=B//Set the buff.
					src.AddActiveBuff()//Then add boosts.
					B.current_passives = B.passives
					passive_handler.increaseList(B.passives)
				return

			if(B.SpecialSlot)
				/*
				if(src.isRace(SAIYAN)&&src.transActive()&&!B.UnrestrictedBuff)
					src << "No buffs as a saiyan in transformations."
					return*/
				if(src.SpecialBuff)
					if(!src.BuffOn(B))
						src << "You're already using a special buff."
						return
					else
						src.RemoveSpecialBuff()
						passive_handler.decreaseList(B.current_passives)
				else
					src.SpecialBuff=B
					src.AddSpecialBuff()
					B.current_passives = B.passives
					passive_handler.increaseList(B.passives)
				return

			if(B.Slotless)//If a buff is designated as slotless...
				if(B.SlotlessOn)//And it's marked as on...
					passive_handler.decreaseList(B.current_passives)
					if(B.Counter && B.CounterHit)
						if(B.WarpOnCounter && Target)
							DashTo(Target,B.WarpOnCounter, 0.1, 0)
						if(B.ThrowOnCounter) // this generally always has to b this tho
							if(B.FollowUp)
								spawn(B.FollowUpDelay)
									throwFollowUp(B.FollowUp)
						B.CounterHit=0
					src.RemoveSlotlessBuff(B)//Remove it.
				else//But if it's not on...
					src.AddSlotlessBuff(B)//Add it.
					B.current_passives = B.passives
					passive_handler.increaseList(B.passives)
					if(isplayer(src))
						src:move_speed = MovementSpeed()
				return

			if(!B.ActiveSlot&&!B.SpecialSlot&&!B.Slotless&&!B.StanceSlot&&!B.StyleSlot)
				src << "[B] is an incomplete buff which doesn't know what slot it takes."
				return
			if(B.AssociatedGear)
				if(!B.AssociatedGear.InfiniteUses)
					if(B.Integrated)
						B.AssociatedGear.IntegratedUses--
						if(B.AssociatedGear.IntegratedUses<=0)
							src << "Your [B.AssociatedGear] is out of power!"
						if(src.ManaAmount>=10)
							src.LoseMana(10)
							src << "Your integrated [B.AssociatedGear] automatically replenishes power!"
							B.AssociatedGear.IntegratedUses=B.AssociatedGear.IntegratedMaxUses
					else
						B.AssociatedGear.Uses--
						if(B.AssociatedGear.Uses==0)
							src << "Your [B.AssociatedGear] is out of power!"
			if(B.Engrain)
				src.Frozen = 1

		AddStyleBuff()

			if(src.StyleBuff.StyleActive=="Dark Flame")
				if(src.HasJagan())
					src.StyleBuff.HitSpark='fevExplosion - Hellfire.dmi'
					src.StyleBuff.HitX=-32
					src.StyleBuff.HitY=-32
					src.StyleBuff.HitSize=0.5

			if(src.StyleBuff.StyleActive=="Hiten Mitsurugi")
				StyleBuff.passives["Godspeed"] = SagaLevel/2
				StyleBuff.passives["Flicker"] = SagaLevel/2
				StyleBuff.passives["BlurringStrikes"] = round(SagaLevel/6,0.05)

				src.StyleBuff.Mastery=4

			if(src.StyleBuff.StyleActive=="Ansatsuken")
				var/unarmed = glob.UNARMED_DAMAGE_DIVISOR/6
				src.StyleBuff.passives["CheapShot"] = 0.25 * SagaLevel
				src.StyleBuff.passives["UnarmedDamage"] = round(unarmed * SagaLevel,0.5)
				src.StyleBuff.passives["Duelist"] = 0.5 * SagaLevel
				switch(src.AnsatsukenPath)
					if("Hadoken")
						StyleBuff.Finisher="/obj/Skills/Queue/Finisher/Isshin"
					if("Shoryuken")
						StyleBuff.Finisher="/obj/Skills/Queue/Finisher/Shin_Shoryuken"
					if("Tatsumaki")
						StyleBuff.Finisher="/obj/Skills/Queue/Finisher/Shippu_Jinraikyaku"
				if(src.SagaLevel>=5)
					src.StyleBuff.AngerThreshold=2
					switch(src.AnsatsukenAscension)
						if("Chikara")
							src.StyleBuff.StyleStr=1.5
							src.StyleBuff.StyleEnd=1.5
							src.StyleBuff.StyleFor=1.5
							src.StyleBuff.StyleDef=1.5
							src.StyleBuff.StyleOff=1.5
							src.StyleBuff.passives["CalmAnger"] = 1
							src.StyleBuff.CalmAnger=1
							if(src.SagaLevel==6)
								src.StyleBuff.passives["Unstoppable"] = 1
								src.StyleBuff.Unstoppable=1
								src.StyleBuff.passives["LifeGeneration"] = 2.5
								src.StyleBuff.LifeGeneration=2.5
								src.StyleBuff.passives["EnergyGeneration"] = 5
								src.StyleBuff.passives["ManaGeneration"] = 5
						if("Satsui")
							src.StyleBuff.AutoAnger=1
							src.StyleBuff.StyleStr=1.5
							src.StyleBuff.StyleFor=1.4
							src.StyleBuff.StyleOff=1.4



					src.StyleBuff.Mastery=4

			src.Power_Multiplier+=(src.StyleBuff.PowerMult-1)
			src.StrMultTotal+=(src.StyleBuff.StrMult-1)
			src.EndMultTotal+=(src.StyleBuff.EndMult-1)
			src.SpdMultTotal+=(src.StyleBuff.SpdMult-1)
			src.ForMultTotal+=(src.StyleBuff.ForMult-1)
			src.OffMultTotal+=(src.StyleBuff.OffMult-1)
			src.DefMultTotal+=(src.StyleBuff.DefMult-1)
			src.RecovMultTotal+=(src.StyleBuff.RecovMult-1)
			src.AllSkillsAdd(src.StyleBuff)
			if(isplayer(src))
				src:move_speed = MovementSpeed()
			OMsg(src, "[src] takes up the [src.StyleBuff]!")

		RemoveStyleBuff()

			src.Power_Multiplier-=(src.StyleBuff.PowerMult-1)
			src.StrMultTotal-=(src.StyleBuff.StrMult-1)
			src.EndMultTotal-=(src.StyleBuff.EndMult-1)
			src.SpdMultTotal-=(src.StyleBuff.SpdMult-1)
			src.ForMultTotal-=(src.StyleBuff.ForMult-1)
			src.OffMultTotal-=(src.StyleBuff.OffMult-1)
			src.DefMultTotal-=(src.StyleBuff.DefMult-1)
			src.RecovMultTotal-=(src.StyleBuff.RecovMult-1)
			src.AllSkillsRemove(src.StyleBuff)
			if(StyleBuff.BuffSelf)
				var/obj/Skills/Buffs/s = FindSkill(StyleBuff.BuffSelf)
				if(s)
					var/name2remove = s.name
					AllSkillsRemove(s)
					SlotlessBuffs -= name2remove //TODO: this may still not work
			OMsg(src, "[src] relaxes their [src.StyleBuff]...")
			src.Tension=0
			src.StanceActive=0
			src.StyleBuff=null

			if(isplayer(src))
				src:move_speed = MovementSpeed()

		AddActiveBuff()

			if(src.ActiveBuff.BuffName=="Ki Control")
				if(src.passive_handler.Get("Anaerobic"))
					src.ActiveBuff.passives["PUSpike"] = 25
					src.ActiveBuff.PUSpike=25

				if(src.transActive())
					src.ActiveBuff.OverlayTransLock=1
					if(src.isRace(SAIYAN))
						if((race.transformations[transActive].mastery==100))
							if(src.transActive()==1&&(!src.HasGodKi()&&!src.Anger))
								Anger=Anger
				else
					src.ActiveBuff.OverlayTransLock=0

				if(src.isRace(MAKYO))
					src.ActiveBuff.IconReplace=1
					src.ActiveBuff.icon=src.ExpandBase
					src.ActiveBuff.passives["BleedHit"] = 0
					src.ActiveBuff.passives["EnergyLeak"] = max(6-AscensionsAcquired,1)
					src.ActiveBuff.passives["ManaLeak"] = 0
					src.ActiveBuff.passives["GiantForm"] = round(AscensionsAcquired/2)
					src.ActiveBuff.passives["Godspeed"] = AscensionsAcquired
					src.ActiveBuff.AutoAnger=0
					src.ActiveBuff.AngerStorage=0
					if(src.passive_handler.Get("HellPower")||src.StarPowered)
						src.ActiveBuff.AutoAnger=1
						src.ActiveBuff.AngerMult=2
						src.ActiveBuff.passives["PUSpike"] = 50
						src.ActiveBuff.passives["Pursuer"] = 2 * AscensionsAcquired

					else if(passive_handler.Get("ArtificalStar"))
						src.ActiveBuff.AutoAnger=1
						src.ActiveBuff.AngerMult=1.5
						src.ActiveBuff.passives["PUSpike"] = 25
						src.ActiveBuff.passives["Pursuer"] = 1.5 * AscensionsAcquired
					else
						if(AscensionsAcquired)
							src.ActiveBuff.AngerPoint = 5 * AscensionsAcquired
						src.ActiveBuff.passives["Pursuer"] = 0.5 * AscensionsAcquired
						src.ActiveBuff.AngerMult = round(2/(8-AscensionsAcquired), 0.01)
						src.ActiveBuff.passives["PUSpike"] = round(25/(5-AscensionsAcquired))
						src.ActiveBuff.PUSpike=round(25/(5-AscensionsAcquired))
				if(src.Saga=="Spiral")
					src.ActiveBuff.ActiveMessage="channels their evolution with full strength!!!"
					src.ActiveBuff.OffMessage="calms their evolution..."
					src.ActiveBuff.OverlayTransLock=1
					src.ActiveBuff.AuraLock=1
				if(src.Saga=="Cosmo")
					src.ActiveBuff.ActiveMessage="burns their Cosmo with full strength!!!"
					src.ActiveBuff.OffMessage="calms their Cosmo..."
					src.ActiveBuff.OverlayTransLock=1
					src.ActiveBuff.AuraLock=1
					// src.ActiveBuff.SenseUnlocked=1
					if(src.SagaLevel==4)
						switch(src.ClothGold)
							if("Aries")
								if(!locate(/obj/Skills/Projectile/Stardust_Revolution, src))
									src.AddSkill(new/obj/Skills/Projectile/Stardust_Revolution)
							if("Sagittarius")
								if(!locate(/obj/Skills/Projectile/Light_Impulse, src))
									src.AddSkill(new/obj/Skills/Projectile/Light_Impulse)
							if("Gemini")
								if(!locate(/obj/Skills/Projectile/Galaxian_Explosion, src))
									src.AddSkill(new/obj/Skills/Projectile/Galaxian_Explosion)
							if("Cancer")
								if(!locate(/obj/Skills/Projectile/Praesepe_Demonic_Blue_Flames, src))
									src.AddSkill(new/obj/Skills/Projectile/Praesepe_Demonic_Blue_Flames)
							if("Leo")
								if(!locate(/obj/Skills/Queue/Lightning_Plasma_Strike, src))
									src.AddSkill(new/obj/Skills/Queue/Lightning_Plasma_Strike)
							if("Virgo")
								if(!locate(/obj/Skills/AutoHit/Demon_Pacifier, src))
									src.AddSkill(new/obj/Skills/AutoHit/Demon_Pacifier)
							if("Libra")
								if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Libra_Armory, src))
									src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Libra_Armory)
							if("Scorpio")
								if(!locate(/obj/Skills/Projectile/Scarlet_Needle, src))
									src.AddSkill(new/obj/Skills/Projectile/Scarlet_Needle)
							if("Capricorn")
								if(!locate(/obj/Skills/AutoHit/Sacred_Sword_Excalibur, src))
									src.AddSkill(new/obj/Skills/AutoHit/Sacred_Sword_Excalibur)
							if("Aquarius")
								if(!locate(/obj/Skills/Projectile/Beams/Big/Saint_Seiya/Aurora_Execution, src))
									src.AddSkill(new/obj/Skills/Projectile/Beams/Big/Saint_Seiya/Aurora_Execution)
							if("Pisces")
								if(!locate(/obj/Skills/Projectile/Royal_Demon_Rose, src))
									src.AddSkill(new/obj/Skills/Projectile/Royal_Demon_Rose)
					if(FightingSeriously(src,0))
						if(src.SagaLevel>=5 && src.SagaLevel < 7)
							if(src.Health<=15 || src.InjuryAnnounce)
								src.ActiveBuff.ActiveMessage="burns their Cosmo with full strength and attains the Seventh Sense!!!"
						if(src.SagaLevel==7)
							src.ActiveBuff.ActiveMessage="burns their Cosmo with full strength and attains the Seventh Sense!!!"
						if(src.SagaLevel>=8)
							src.ActiveBuff.ActiveMessage="burns their Cosmo with full strength and attains the Seventh Sense!!!"
						if(src.SagaLevel==8&&src.Dead)
							src.ActiveBuff.ActiveMessage="burns their Cosmo with full strength and attains the Eighth Sense!!!"
						if(src.SagaLevel==8&&src.SenseUnlocked>=7)
							src.ActiveBuff.ActiveMessage="burns their Cosmo with full strength and reaches the Ninth Sense, realm of the Gods!!!"

			src.StrAdded += ActiveBuff.strAdd
			src.EndAdded += ActiveBuff.endAdd
			src.SpdAdded += ActiveBuff.spdAdd
			src.ForAdded += ActiveBuff.forAdd
			src.OffAdded += ActiveBuff.offAdd
			src.DefAdded += ActiveBuff.defAdd

			src.Power_Multiplier+=(src.ActiveBuff.PowerMult-1)
			src.StrMultTotal+=(src.ActiveBuff.StrMult-1)
			src.EndMultTotal+=(src.ActiveBuff.EndMult-1)
			src.SpdMultTotal+=(src.ActiveBuff.SpdMult-1)
			src.ForMultTotal+=(src.ActiveBuff.ForMult-1)
			src.OffMultTotal+=(src.ActiveBuff.OffMult-1)
			src.DefMultTotal+=(src.ActiveBuff.DefMult-1)
			src.RecovMultTotal+=(src.ActiveBuff.RecovMult-1)
			src.AllSkillsAdd(src.ActiveBuff)
			if(isplayer(src))
				src:move_speed = MovementSpeed()

		RemoveActiveBuff()

			src.StrAdded -= ActiveBuff.strAdd
			src.EndAdded -= ActiveBuff.endAdd
			src.SpdAdded -= ActiveBuff.spdAdd
			src.ForAdded -= ActiveBuff.forAdd
			src.OffAdded -= ActiveBuff.offAdd
			src.DefAdded -= ActiveBuff.defAdd

			src.Power_Multiplier-=(src.ActiveBuff.PowerMult-1)
			src.StrMultTotal-=(src.ActiveBuff.StrMult-1)
			src.EndMultTotal-=(src.ActiveBuff.EndMult-1)
			src.SpdMultTotal-=(src.ActiveBuff.SpdMult-1)
			src.ForMultTotal-=(src.ActiveBuff.ForMult-1)
			src.OffMultTotal-=(src.ActiveBuff.OffMult-1)
			src.DefMultTotal-=(src.ActiveBuff.DefMult-1)
			src.RecovMultTotal-=(src.ActiveBuff.RecovMult-1)
			if(src.SpecialBuff)
				if(src.SpecialBuff.ABuffNeeded)
					if(src.SpecialBuff.ABuffNeeded.len>0)
						if(src.ActiveBuff.BuffName in src.SpecialBuff.ABuffNeeded)
							src.SpecialBuff.Trigger(src, Override=1)
			for(var/b in src.SlotlessBuffs)
				var/obj/Skills/Buffs/SlotlessBuffs/sb = SlotlessBuffs[b]
				if(sb)
					if(sb.ABuffNeeded)
						if(sb.ABuffNeeded.len>0)
							if(src.ActiveBuff.BuffName in sb.ABuffNeeded)
								sb.Trigger(src, Override=1)
			if(src.StanceBuff)
				if(src.StanceBuff.ABuffNeeded)
					if(src.StanceBuff.ABuffNeeded.len>0)
						if(src.ActiveBuff.BuffName in src.StanceBuff.ABuffNeeded)
							src.StanceBuff.Trigger(src, Override=1)
			if(src.StyleBuff)
				if(src.StyleBuff.ABuffNeeded)
					if(src.StyleBuff.ABuffNeeded.len>0)
						if(src.ActiveBuff.BuffName in src.StyleBuff.ABuffNeeded)
							src.StyleBuff.Trigger(src, Override=1)
			if(src.transActive()||src.Saga=="Cosmo")
				if(src.ActiveBuff.BuffName=="Ki Control")
					src.ActiveBuff.OverlayTransLock=1
			else
				if(src.ActiveBuff.BuffName=="Ki Control")
					src.ActiveBuff.OverlayTransLock=0
			src.AllSkillsRemove(src.ActiveBuff)
			src.ActiveBuff=null
			if(isplayer(src))
				src:move_speed = MovementSpeed()

		AddSpecialBuff()
			//TODO redo these
			if(src.SpecialBuff.BuffName=="Jinchuuriki")
				if(!SpecialBuff.altered)
					src.SpecialBuff.passives["BleedHit"] = 4-src.SpecialBuff.Mastery
					src.SpecialBuff.passives["PureReduction"] = (src.SpecialBuff.Mastery*1.25)
					src.SpecialBuff.BleedHit=4-src.SpecialBuff.Mastery
					src.SpecialBuff.PureReduction=(src.SpecialBuff.Mastery*1.25)
					if(src.SpecialBuff.Mastery==1)
						src.SpecialBuff.passives["BleedHit"] = 0
						src.SpecialBuff.BleedHit=0
					if(src.SpecialBuff.Mastery>1)
						if(src.SpecialBuff.ActiveMessage=="overflows with berserk demon chakra!")
							src.SpecialBuff.ActiveMessage="cloaks their form with demon chakra!"
						if(src.SpecialBuff.OffMessage=="can no longer bear the strain of channelling demon chakra...")
							src.SpecialBuff.OffMessage="quells the inner rage of their demon..."
					src.SpecialBuff.passives["LifeGeneration"] = src.SpecialBuff.Mastery*0.25
					src.SpecialBuff.PureReduction=(src.SpecialBuff.Mastery*1.25)
					src.SpecialBuff.LifeGeneration=(src.SpecialBuff.Mastery*0.25)
					if(src.SpecialBuff.Mastery==2)
						src.SpecialBuff.Intimidation=1.5
					if(src.SpecialBuff.Mastery==3)
						src.SpecialBuff.Intimidation=2
					if(src.SpecialBuff.Mastery==4)
						src.SpecialBuff.Intimidation=3
					if(!src.JinchuuType)
						src.JinchuuType=input(src,"Choose your Jinchuuriki type!","Jinchuuriki Type") in list("Tyrant", "Catastrophe", "Dominator", "Juggernaut")
					switch(JinchuuType)
						if("Tyrant")
							src.SpecialBuff.StrMult=2
						if("Catastrophe")
							SpecialBuff.ForMult=2
						if("Dominator")
							SpecialBuff.OffMult=2
						if("Juggernaut")
							SpecialBuff.EndMult=2

			if(src.SpecialBuff.BuffName=="Vaizard Mask")
				if(!SpecialBuff.altered)
					if(src.SpecialBuff.Mastery>1)
						if(src.SpecialBuff.ActiveMessage=="is taken over by a violent rage as a mask forms on their face!")
							src.SpecialBuff.ActiveMessage="dons a mask of dark energy!"
						if(src.SpecialBuff.OffMessage=="violently rips off their mask as it shatters into fragments...")
							src.SpecialBuff.OffMessage="tears off their mask as it shatters into fragments..."
						if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Regeneration) in src)
							src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Regeneration)
							for(var/obj/Skills/Buffs/SlotlessBuffs/Regeneration/R in src)
								R.RegenerateLimbs=1
						if(!locate(/obj/Skills/Projectile/Beams/Big/Vaizard/Cero) in src)
							src.AddSkill(new/obj/Skills/Projectile/Beams/Big/Vaizard/Cero)
						while(src.Maimed>0)//regen happens automagically because regeneration wouldnt be in mob's contents yet
							src.Maimed--
							OMsg(src, "[src] regrows a maiming at the pleasure of their inner passenger!")
					if(!src.VaizardType)
						src.VaizardType=pick(list("Berserker", "Manipulator", "Hellion", "Phantasm"))
					if(!src.VaizardIcon)
						src.GetVaizardIcon()

			if(src.SpecialBuff.BuffName=="One Hundred Percent Power")
				src.SpecialBuff.IconReplace=1
				src.SpecialBuff.icon=src.Form4Base
			if(src.SpecialBuff.BuffName=="Fifth Form")
				src.SpecialBuff.IconReplace=1
				src.SpecialBuff.icon=src.Form4Base

			src.StrAdded += SpecialBuff.strAdd
			src.EndAdded += SpecialBuff.endAdd
			src.SpdAdded += SpecialBuff.spdAdd
			src.ForAdded += SpecialBuff.forAdd
			src.OffAdded += SpecialBuff.offAdd
			src.DefAdded += SpecialBuff.defAdd

			src.Power_Multiplier+=(src.SpecialBuff.PowerMult-1)
			src.StrMultTotal+=(src.SpecialBuff.StrMult-1)
			src.EndMultTotal+=(src.SpecialBuff.EndMult-1)
			src.SpdMultTotal+=(src.SpecialBuff.SpdMult-1)
			src.ForMultTotal+=(src.SpecialBuff.ForMult-1)
			src.OffMultTotal+=(src.SpecialBuff.OffMult-1)
			src.DefMultTotal+=(src.SpecialBuff.DefMult-1)
			src.RecovMultTotal+=(src.SpecialBuff.RecovMult-1)
			src.AllSkillsAdd(src.SpecialBuff)
			if(isplayer(src))
				src:move_speed = MovementSpeed()

		RemoveSpecialBuff()

			src.StrAdded -= SpecialBuff.strAdd
			src.EndAdded -= SpecialBuff.endAdd
			src.SpdAdded -= SpecialBuff.spdAdd
			src.ForAdded -= SpecialBuff.forAdd
			src.OffAdded -= SpecialBuff.offAdd
			src.DefAdded -= SpecialBuff.defAdd

			src.Power_Multiplier-=(src.SpecialBuff.PowerMult-1)
			src.StrMultTotal-=(src.SpecialBuff.StrMult-1)
			src.EndMultTotal-=(src.SpecialBuff.EndMult-1)
			src.SpdMultTotal-=(src.SpecialBuff.SpdMult-1)
			src.ForMultTotal-=(src.SpecialBuff.ForMult-1)
			src.OffMultTotal-=(src.SpecialBuff.OffMult-1)
			src.DefMultTotal-=(src.SpecialBuff.DefMult-1)
			src.RecovMultTotal-=(src.SpecialBuff.RecovMult-1)
			if(src.ActiveBuff)
				if(src.ActiveBuff.SBuffNeeded)
					if(src.ActiveBuff.SBuffNeeded==src.SpecialBuff.BuffName)
						src.ActiveBuff.Trigger(src, Override=1)
			for(var/b in src.SlotlessBuffs)
				var/obj/Skills/Buffs/SlotlessBuffs/sb = SlotlessBuffs[b]
				if(sb)
					if(sb.SBuffNeeded)
						if(sb.SBuffNeeded==src.SpecialBuff.BuffName)
							sb.Trigger(src, Override=1)
			if(src.StanceBuff)
				if(src.StanceBuff.SBuffNeeded)
					if(src.StanceBuff.SBuffNeeded==src.SpecialBuff.BuffName)
						src.StanceBuff.Trigger(src, Override=1)
			if(src.StyleBuff)
				if(src.StyleBuff.SBuffNeeded)
					if(src.StyleBuff.SBuffNeeded==src.SpecialBuff.BuffName)
						src.StyleBuff.Trigger(src, Override=1)
			src.AllSkillsRemove(src.SpecialBuff)

			if(src.SpecialBuff.BuffName=="Vaizard Mask")
				src.SpecialBuff.Cooldown = max(20, round(60 * (1/max(1,min(20,max(1,VaizardHealth)))), 1))
				ForceCancelBeam()

			var/list/Gold=list("Aries Cloth", /* "Taurus Cloth" */, "Gemini Cloth", "Cancer Cloth", "Leo Cloth", "Virgo Cloth", "Libra Cloth", "Scorpio Cloth", /* "Sagittarius Cloth" */, "Capricorn Cloth", "Aquarius Cloth", "Pisces Cloth")
			if(src.SpecialBuff.BuffName in Gold)
				if(src.SpecialBuff.BuffName!="[src.ClothGold] Cloth")
					for(var/obj/Items/Symbiotic/Saint_Cloth/Gold_Cloth/GC in src)
						if(GC.suffix)
							src.SpecialBuff=FALSE
							GC.ObjectUse(src)
							GC.loc=locate(GC.ReturnX,GC.ReturnY,GC.ReturnZ)
							OMsg(src, "[src] isn't aligned with [GC] so it abandons them!")
							KenShockwave(src, icon='KenShockwaveGold.dmi', Size=1, Blend=2, Time=3)
							src.LoseEnergy(100)
							src.GainFatigue(30)
					if(src.HasKiControl())
						src.Auraz("Add")
				else if(src.SagaLevel<5||src.Saga!="Cosmo")
					for(var/obj/Items/Symbiotic/Saint_Cloth/Gold_Cloth/GC in src)
						if(GC.suffix)
							src.SpecialBuff=FALSE
							GC.ObjectUse(src)
							GC.loc=locate(GC.ReturnX,GC.ReturnY,GC.ReturnZ)
							OMsg(src, "[src] isn't powerful enough to control the [GC] so it abandons them!")
							KenShockwave(src, icon='KenShockwaveGold.dmi', Size=1, Blend=2, Time=3)
					if(src.HasKiControl())
						src.Auraz("Add")
			src.SpecialBuff=FALSE
			if(isplayer(src))
				src:move_speed = MovementSpeed()

		AddSlotlessBuff(var/obj/Skills/Buffs/B)
			if(B.BuffName=="Regeneration")
				if(src.HasHellPower())
					B.RegenerateLimbs=1
			if(B.HitScanIcon)
				HitScanIcon = B.HitScanIcon
			if(B.HitScanHitSpark)
				HitScanHitSpark = B.HitScanHitSpark
				HitScanHitSparkX = B.HitScanHitSparkX
				HitScanHitSparkY = B.HitScanHitSparkY
			// HERE
			src.StrAdded += B.strAdd
			src.EndAdded += B.endAdd
			src.SpdAdded += B.spdAdd
			src.ForAdded += B.forAdd
			src.OffAdded += B.offAdd
			src.DefAdded += B.defAdd


			src.Power_Multiplier+=(B.PowerMult-1)
			src.StrMultTotal+=(B.StrMult-1)
			src.EndMultTotal+=(B.EndMult-1)
			src.SpdMultTotal+=(B.SpdMult-1)
			src.ForMultTotal+=(B.ForMult-1)
			src.OffMultTotal+=(B.OffMult-1)
			src.DefMultTotal+=(B.DefMult-1)
			src.RecovMultTotal+=(B.RecovMult-1)
			B.SlotlessOn=1
			if(B.BuffName)
				src.SlotlessBuffs["[B.BuffName]"] = B
			else
				src.SlotlessBuffs["[B.name]"] = B
			src.AllSkillsAdd(B)
			if(isplayer(src))
				src:move_speed = MovementSpeed()

		RemoveSlotlessBuff(var/obj/Skills/Buffs/B)
			if(B.HitScanIcon)
				HitScanIcon = null
			if(B.HitScanHitSpark)
				HitScanHitSpark = null
				HitScanHitSparkX = null
				HitScanHitSparkY = null
			src.StrAdded -= B.strAdd
			src.EndAdded -= B.endAdd
			src.SpdAdded -= B.spdAdd
			src.ForAdded -= B.forAdd
			src.OffAdded -= B.offAdd
			src.DefAdded -= B.defAdd


			src.Power_Multiplier-=(B.PowerMult-1)
			src.StrMultTotal-=(B.StrMult-1)
			src.EndMultTotal-=(B.EndMult-1)
			src.SpdMultTotal-=(B.SpdMult-1)
			src.ForMultTotal-=(B.ForMult-1)
			src.OffMultTotal-=(B.OffMult-1)
			src.DefMultTotal-=(B.DefMult-1)
			src.RecovMultTotal-=(B.RecovMult-1)
			B.SlotlessOn=0
			if(B.BuffName)
				src.SlotlessBuffs.Remove("[B.BuffName]")
			else
				src.SlotlessBuffs.Remove("[B.name]")

			src.AllSkillsRemove(B)
			if(isplayer(src))
				src:move_speed = MovementSpeed()

		AllSkillsAdd(var/obj/Skills/Buffs/B)

			if(B.BuffSelf)
				buffSelf(B.BuffSelf)

			if(B.Transform)
				if(B.Transform=="Force")
					transUnlocked=min(transUnlocked+1,4)
					src.Transform()
				else if(B.Transform=="Strong")
					src.Intimidation*=1.5
				else if(B.Transform=="Weak")
					src.PowerBoost*=0.25
				else
					src.Transform(B.Transform)

			if(B.ClientTint)
				src.appearance_flags+=16

			if(B.FlashChange)
				animate(src, color = list(1,0,0, 0,1,0, 0,0,1, 1,1,1))
			if(B.DarkChange)
				animate(src, color = list(0,0,0, 0,0,0, 0,0,0, 0,0,0))

			if(B.StrReplace)
				src.StrReplace=B.StrReplace
			if(B.EndReplace)
				src.EndReplace=B.EndReplace
			if(B.ForReplace)
				src.ForReplace=B.ForReplace
			if(B.SpdReplace)
				src.SpdReplace=B.SpdReplace
			if(B.RecovReplace)
				src.RecovReplace=B.RecovReplace


			if(B.StripEquip)
				if(B.AssociatedGear)
					src.overlays-=image(B.AssociatedGear.icon, pixel_x=B.AssociatedGear.pixel_x, pixel_y=B.AssociatedGear.pixel_y, layer=FLOAT_LAYER-3)
				if(B.AssociatedLegend)
					src.overlays-=image(B.AssociatedLegend.icon, pixel_x=B.AssociatedLegend.pixel_x, pixel_y=B.AssociatedLegend.pixel_y, layer=FLOAT_LAYER-3)
			if(B.Earthshaking)
				src.Quake(B.Earthshaking)
			if(B.StanceActive)
				src.StanceActive=B.StanceActive
			if(B.StyleActive)
				src.StyleActive=B.StyleActive

			if(B.TurfShift)
				if(!B.TurfShiftLayer)
					B.TurfShiftLayer=MOB_LAYER-0.5
				for(var/turf/t in Turf_Circle(src, 6))
					sleep(-1)
					TurfShift(B.TurfShift, t, 30+(B.CastingTime*30), src, B.TurfShiftLayer)

			if(B.TargetOverlay)
				var/image/im=image(icon=B.TargetOverlay, pixel_x=B.TargetOverlayX, pixel_y=B.TargetOverlayY)
				im.blend_mode=B.IconLockBlend
				im.transform*=B.OverlaySize
				if(B.OverlaySize>=2)
					im.appearance_flags+=512
				src.Target.overlays+=im

			if(B.CastingTime)
				src.Frozen=2
				src.OMessage(15,"<font color=red>[src] focuses their power!","Skill Cast: [B.BuffName].")
				sleep(10*B.CastingTime)
				src.Frozen=0
				if(B.Range)//This one doesn't apply to rushes.
					if(!src.Target)
						src << "You need a target to use this skill!"
						B.Trigger(usr, Override=1)
						return
					if(B.ForcedRange)
						if(get_dist(src,src.Target)!=B.Range)
							src << "They're not in range!"
							B.Trigger(usr, Override=1)
							return
					else
						if(get_dist(src,src.Target)>B.Range||src.z!=src.Target.z)
							src << "They've moved out of range!"
							B.Trigger(usr, Override=1)
							return

			if(B.IconTransform)
				var/image/T=image(B.IconTransform, pixel_x=B.TransformX, pixel_y=B.TransformY, loc = src)
				T.appearance_flags=68
				world << T
				spawn()
					animate(T, alpha=0)
					animate(T, alpha=255, time=3)
				spawn()
					animate(src, alpha=0, time=3)
				spawn(3)
					B.icon=src.icon
					B.pixel_x=src.pixel_x
					B.pixel_y=src.pixel_y
					src.Transformed=1
					src.AppearanceOff()
					src.icon=B.IconTransform
					src.pixel_x=B.TransformX
					src.pixel_y=B.TransformY
					src.alpha=255
					del T
				sleep(3)

			if(B.DropOverlays)
				src.AppearanceOff()

			if(B.KenWave)
				var/Wave=B.KenWave
				for(var/wav=Wave, wav>0, wav--)
					KenShockwave(src, icon=B.KenWaveIcon, Size=Wave*B.KenWaveSize, PixelX=B.KenWaveX, PixelY=B.KenWaveY, Blend=B.KenWaveBlend, Time=B.KenWaveTime)
					Wave/=2

			if(B.KKTWave)
				var/Wave=B.KKTWave
				for(var/wav=Wave, wav>0, wav--)
					KKTShockwave(src, icon=B.KKTWaveIcon, Size=Wave*B.KKTWaveSize, PixelX=B.KKTWaveX, PixelY=B.KKTWaveY)
					Wave/=2

			if(B.alphaChange)
				src.alpha = B.alphaChange

			if(B.DustWave)
				Dust(src.loc, B.DustWave)

			if(B.MakesArmor)
				var/obj/Items/Armor/s
				switch(B.ArmorClass)
					if("Light")
						s=new/obj/Items/Armor/Mobile_Armor
					if("Medium")
						s=new/obj/Items/Armor/Balanced_Armor
					if("Heavy")
						s=new/obj/Items/Armor/Plated_Armor
					else
						s=new/obj/Items/Armor/Balanced_Armor
				if(B.ArmorIcon)
					s.icon=B.ArmorIcon
					if(B.ArmorX)
						s.pixel_x=B.ArmorX
					if(B.ArmorY)
						s.pixel_y=B.ArmorY
				if(B.ArmorName)
					s.name=B.ArmorName
				if(B.ArmorAscension)
					s.InnatelyAscended=B.ArmorAscension
				if(B.ArmorElement)
					s.Element=B.ArmorElement
				src.contents+=s
				s.Conjured=1
				s.Cost=0
				s.Stealable=0
				if(B.FlashDraw)
					var/image/si=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, loc=src)
					if(src.CheckActive("Mobile Suit")&&B.BuffName!="Mobile Suit")
						si.transform*=3
					animate(si, alpha=255, color = list(1,0,0, 0,1,0, 0,0,1, 1,1,1))
					world << si
					spawn()
						animate(si, alpha=0, time=3)
						sleep(3)
						del si
				s.AlignEquip(src)

			if(B.MakesStaff)
				var/obj/Items/Enchantment/Staff/s
				switch(B.StaffClass)
					if("Wand")
						s=new/obj/Items/Enchantment/Staff/NonElemental/Wand
					if("Rod")
						s=new/obj/Items/Enchantment/Staff/NonElemental/Rod
					if("Staff")
						s=new/obj/Items/Enchantment/Staff/NonElemental/Staff
					else
						s=new/obj/Items/Enchantment/Staff/NonElemental/Staff
				if(B.StaffIcon)
					s.icon=B.StaffIcon
					if(B.StaffX)
						s.pixel_x=B.StaffX
					if(B.StaffY)
						s.pixel_y=B.StaffY
				if(B.StaffName)
					s.name=B.StaffName
				if(B.StaffAscension)
					s.InnatelyAscended=B.StaffAscension
				if(B.StaffElement)
					s.Element=B.StaffElement
				s.Conjured=1
				src.contents+=s
				if(B.FlashDraw)
					var/image/si=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, loc=src)
					if(src.CheckActive("Mobile Suit")&&B.BuffName!="Mobile Suit")
						si.transform*=3
					animate(si, alpha=255, color = list(1,0,0, 0,1,0, 0,0,1, 1,1,1))
					world << si
					spawn()
						animate(si, alpha=0, time=3)
						sleep(3)
						del si
				s.AlignEquip(src)

			if(B.MakesSword==1 || B.MakesSword==3)
				var/obj/Items/Sword/s
				switch(B.SwordClass)
					if("Wooden")
						s=new/obj/Items/Sword/Wooden
					if("Light")
						s=new/obj/Items/Sword/Light
					if("Medium")
						s=new/obj/Items/Sword/Medium
					if("Heavy")
						s=new/obj/Items/Sword/Heavy
					if("Double")
						s=new/obj/Items/Sword/Light
					else
						s=new/obj/Items/Sword/Medium
				if(B.SwordIcon)
					s.icon=B.SwordIcon
					if(B.SwordX)
						s.pixel_x=B.SwordX
					if(B.SwordY)
						s.pixel_y=B.SwordY
					s.UnderlayIcon=B.SwordIconUnder
					s.UnderlayX=B.SwordXUnder
					s.UnderlayY=B.SwordYUnder
				if(B.SwordName)
					s.name=B.SwordName
				if(B.SwordUnbreakable)
					s.Destructable=0
					s.ShatterTier=0
				if(B.SwordShatterTier)
					s.ShatterTier = B.SwordShatterTier
				src.contents+=s
				if(B.SwordRefinement)
					s.ExtraClass = B.SwordRefinement
				if(B.SwordClass=="Double")
					//light sword damage, heavy sword accuracy, and 1.5x faster swing
					s.DamageEffectiveness=1.3
					s.AccuracyEffectiveness=0.7
					s.SpeedEffectiveness=1.5
				if(B.SwordAscension)
					s.InnatelyAscended=B.SwordAscension
				if(B.MagicSword)
					s.MagicSword+=B.MagicSword
				if(B.SwordElement)
					s.Element = B.SwordElement
				if(B.SpiritSword)
					s.SpiritSword+=B.SpiritSword
				if(B.Extend)
					s.Extend+=B.Extend
				if(B.swordHasHistory)
					s.noHistory = FALSE
				s.Conjured=1
				s.Cost=0
				s.Stealable=0
				if(B.FlashDraw)
					var/image/si=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, loc=src)
					if(src.CheckActive("Mobile Suit")&&B.BuffName!="Mobile Suit")
						si.transform*=3
					animate(si, alpha=255, color = list(1,0,0, 0,1,0, 0,0,1, 1,1,1))
					world << si
					spawn()
						animate(si, alpha=0, time=3)
						sleep(3)
						del si
				s.AlignEquip(src)

			if(B.MakesSecondSword==1)
				var/obj/Items/Sword/s
				switch(B.SwordClassSecond)
					if("Wooden")
						s=new/obj/Items/Sword/Wooden
					if("Light")
						s=new/obj/Items/Sword/Light
					if("Medium")
						s=new/obj/Items/Sword/Medium
					if("Heavy")
						s=new/obj/Items/Sword/Heavy
					else
						s=new/obj/Items/Sword/Medium
				if(B.SwordIconSecond)
					s.icon=B.SwordIconSecond
					if(B.SwordXSecond)
						s.pixel_x=B.SwordXSecond
					if(B.SwordYSecond)
						s.pixel_y=B.SwordYSecond
				if(B.SwordNameSecond)
					s.name=B.SwordNameSecond
				src.contents+=s
				if(B.SwordShatterTier)
					s.ShatterTier = B.SwordShatterTier
				if(B.SwordRefinement)
					s.ExtraClass = B.SwordRefinement
				if(B.SwordAscensionSecond)
					s.InnatelyAscended=B.SwordAscensionSecond
				if(B.MagicSwordSecond)
					s.MagicSword+=B.MagicSwordSecond
				if(B.SwordElementSecond)
					s.Element=B.SwordElementSecond
				if(B.SpiritSword)
					s.SpiritSword+=B.SpiritSword
				if(B.Extend)
					s.Extend+=B.Extend
				s.Conjured=1
				s.Cost=0
				s.Stealable=0
				if(B.FlashDraw)
					var/image/si=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, loc=src)
					if(src.CheckActive("Mobile Suit")&&B.BuffName!="Mobile Suit")
						si.transform*=3
					animate(si, alpha=255, color = list(1,0,0, 0,1,0, 0,0,1, 1,1,1))
					world << si
					spawn()
						animate(si, alpha=0, time=3)
						sleep(3)
						del si
				s.AlignEquip(src)
				s.suffix="*Equipped (Second)*"

			if(B.MakesThirdSword==1)
				var/obj/Items/Sword/s
				switch(B.SwordClassThird)
					if("Wooden")
						s=new/obj/Items/Sword/Wooden
					if("Light")
						s=new/obj/Items/Sword/Light
					if("Medium")
						s=new/obj/Items/Sword/Medium
					if("Heavy")
						s=new/obj/Items/Sword/Heavy
					else
						s=new/obj/Items/Sword/Medium
				if(B.SwordIconThird)
					s.icon=B.SwordIconThird
					if(B.SwordXThird)
						s.pixel_x=B.SwordXThird
					if(B.SwordYThird)
						s.pixel_y=B.SwordYThird
				if(B.SwordNameThird)
					s.name=B.SwordNameThird
				src.contents+=s
				if(B.SwordAscension)
					s.InnatelyAscended=B.SwordAscensionThird
				if(B.MagicSword)
					s.MagicSword+=B.MagicSwordThird
				if(B.SwordElementThird)
					s.Element=B.SwordElementThird
				if(B.SpiritSword)
					s.SpiritSword+=B.SpiritSword
				if(B.Extend)
					s.Extend+=B.Extend
				s.Conjured=1
				s.Cost=0
				s.Stealable=0
				if(B.FlashDraw)
					var/image/si=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y, loc=src)
					if(src.CheckActive("Mobile Suit")&&B.BuffName!="Mobile Suit")
						si.transform*=3
					animate(si, alpha=255, color = list(1,0,0, 0,1,0, 0,0,1, 1,1,1))
					world << si
					spawn()
						animate(si, alpha=0, time=3)
						sleep(3)
						del si
				s.AlignEquip(src)
				s.suffix="*Equipped (Third)*"

			if(B.SwordIcon&&!B.MakesSword)
				var/obj/Items/Sword/s = src.EquippedSword()
				if(s)
					s.AlignEquip(src)
					B.SwordIconOld=s.icon
					s.icon=B.SwordIcon
					if(B.SwordX)
						B.SwordXOld=s.pixel_x
						s.pixel_x=B.SwordX
					if(B.SwordY)
						B.SwordYOld=s.pixel_y
						s.pixel_y=B.SwordY
					s.UnderlayIcon=B.SwordIconUnder
					s.UnderlayX=B.SwordXUnder
					s.UnderlayY=B.SwordYUnder
					s.AlignEquip(src)
			if(B.SwordClass&&!B.MakesSword)
				var/obj/Items/Sword/s = src.EquippedSword()
				if(s)
					B.SwordClassOld=s.Class
					s.Class=B.SwordClass
					s.setStatLine()
			if(B.SwordName&&!B.MakesSword)
				var/obj/Items/Sword/s = src.EquippedSword()
				if(s)
					s.Password=s.name
					s.name=B.SwordName

			if(B.LoseDurability)
				var/obj/Items/Sword/s = src.EquippedSword()
				s.ShatterCounter-=B.LoseDurability

			if(B.NeedsSecondSword && !B.NeedsThirdSword && B.MakesSword != 3)
				for(var/obj/Items/Sword/s in src)
					if(s.suffix=="*Equipped*"||(s.suffix=="*Broken*" && !passive_handler["Sword Master"]))
						continue
					s.AlignEquip(src)
					s.suffix="*Equipped (Second)*"
					break

			if(B.NeedsThirdSword && B.MakesSword != 3)
				var/src2=0
				var/src3=0
				for(var/obj/Items/Sword/s in src)
					if(s.suffix=="*Equipped*"||(s.suffix=="*Broken*" && !passive_handler["Sword Master"]))
						continue
					if(!src2)
						s.AlignEquip(src)
						s.suffix="*Equipped (Second)*"
						src2=s
						continue
					if(!src3)
						if(s==src2)
							continue
						else
							s.AlignEquip(src)
							s.suffix="*Equipped (Third)*"
							src3=s
							break

			if(B.HairLock&&B.HairLock!=1)
				if(B.BuffName=="Ki Control")
					if(B.OverlayTransLock)
						goto IgnoreHair
				src.HairLocked=1
				src.HairLock=B.HairLock
				src.HairX=B.HairX
				src.HairY=B.HairY
				src.Hairz("Add")
			IgnoreHair

			if(B.IconReplace&&B.icon)
				if(B.BuffName=="Ki Control")
					if(B.OverlayTransLock)
						goto IgnoreReplace
				B.OldIcon=src.icon
				B.OldX=src.pixel_x
				B.OldY=src.pixel_y
				src.icon=image(icon=B.icon, pixel_x=B.pixel_x, pixel_y=B.pixel_y)
			IgnoreReplace

			if(B.IconLock)
				if(B.BuffName=="Ki Control")
					if(B.OverlayTransLock)
						goto IgnoreIcon

				var/image/im=image(icon=B.IconLock, pixel_x=B.LockX, pixel_y=B.LockY, icon_state = B.IconState, layer=FLOAT_LAYER-B.IconLayer)
				im.blend_mode=B.IconLockBlend
				im.transform*=B.OverlaySize
				if(B.OverlaySize>=2)
					im.appearance_flags+=512
				if(src.CheckActive("Mobile Suit")&&B.BuffName!="Mobile Suit")
					im.transform*=3
				if(B.IconApart)
					im.appearance_flags+=70
				if(B.IconUnder)
					src.underlays+=im
				else
					src.overlays+=im
			IgnoreIcon

			if(B.HairLock==1)
				src.Hairz("Add")

			if(B.TopOverlayLock)//subs out the aura
				if(B.BuffName=="Ki Control")
					if(B.OverlayTransLock)
						goto IgnoreHead
				if(istype(B.TopOverlayLock, /list))
					for(var/index in B.TopOverlayLock)
						if(istype(B.TopOverlayLock[index], /list))
							var/list/l = B.TopOverlayLock[index]
							var/image/im = image(icon=l["icon"], pixel_x=l["pixel_x"], pixel_y=l["pixel_y"], layer=FLOAT_LAYER-1)
							im.blend_mode=B.IconLockBlend
							im.transform*=B.OverlaySize
							if(B.OverlaySize>=2)
								im.appearance_flags+=512
							src.overlays+=im
						else
							var/image/im = image(icon=B.TopOverlayLock[index], pixel_x=B.TopOverlayX, pixel_y=B.TopOverlayY, layer=FLOAT_LAYER-1)
							im.blend_mode=B.IconLockBlend
							im.transform*=B.OverlaySize
							if(B.OverlaySize>=2)
								im.appearance_flags+=512
							src.overlays+=im
				else
					var/image/im=image(icon=B.TopOverlayLock, pixel_x=B.TopOverlayX, pixel_y=B.TopOverlayY, layer=FLOAT_LAYER-1)
					im.blend_mode=B.IconLockBlend
					im.transform*=B.OverlaySize
					if(B.OverlaySize>=2)
						im.appearance_flags+=512
					src.overlays+=im
			IgnoreHead

			if(B.IconLock&&B.IconRelayer)
				if(B.BuffName=="Ki Control")
					if(B.OverlayTransLock)
						goto IgnoreRelayer
				var/image/im=image(icon=B.IconLock, pixel_x=B.LockX, pixel_y=B.LockY, layer=FLOAT_LAYER-B.IconLayer)
				im.blend_mode=B.IconLockBlend
				im.transform*=B.OverlaySize
				if(B.OverlaySize>=2)
					im.appearance_flags+=512
				if(src.CheckActive("Mobile Suit")&&B.BuffName!="Mobile Suit")
					im.transform*=3
				if(B.IconApart)
					im.appearance_flags+=70
				if(B.IconUnder)
					src.underlays-=im
					src.underlays+=im
				else
					src.overlays-=im
					src.overlays+=im
			IgnoreRelayer

			if(B.MakesSword==2)
				var/obj/Items/Sword/s
				switch(B.SwordClass)
					if("Wooden")
						s=new/obj/Items/Sword/Wooden
					if("Light")
						s=new/obj/Items/Sword/Light
					if("Medium")
						s=new/obj/Items/Sword/Medium
					if("Heavy")
						s=new/obj/Items/Sword/Heavy
					else
						s=new/obj/Items/Sword/Medium
				if(B.SwordIcon)
					s.icon=B.SwordIcon
					if(B.SwordX)
						s.pixel_x=B.SwordX
					if(B.SwordY)
						s.pixel_y=B.SwordY
					s.UnderlayIcon=B.SwordIconUnder
					s.UnderlayX=B.SwordXUnder
					s.UnderlayY=B.SwordYUnder
				if(B.SwordName)
					s.name=B.SwordName
				src.contents+=s
				if(B.SwordAscension)
					s.InnatelyAscended=B.SwordAscension
				if(B.MagicSword)
					s.MagicSword+=B.MagicSword
				if(B.SpiritSword)
					s.SpiritSword+=B.SpiritSword
				if(B.Extend)
					s.Extend+=B.Extend
				if(B.FlashDraw)
					var/image/si=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y)
					if(src.CheckActive("Mobile Suit")&&B.BuffName!="Mobile Suit")
						si.transform*=3
					animate(si, alpha=255, color = list(1,0,0, 0,1,0, 0,0,1, 1,1,1))
					world << si
					spawn()
						animate(si, alpha=0, time=3)
						sleep(3)
						del si
				s.Conjured=1
				s.Stealable=0
				s.AlignEquip(src)

			if(B.BuffName=="Ki Control"&&B.OverlayTransLock)
				src.Auraz("Remove")
				src.Auraz("Add")

			else if(B.AuraLock&&B.AuraLock!=1&&!src.AuraLocked)
				src.Auraz("Remove")
				src.AuraLocked+=1
				src.AuraLock=B.AuraLock
				src.AuraX=B.AuraX
				src.AuraY=B.AuraY
				if(B.AuraUnder)
					src.AuraLockedUnder+=1
				src.Auraz("Add")

			else if(B.AuraLock==1)
				src.Auraz("Remove")
				src.Auraz("Add")

			if(B.Enlarge)
				animate(src, transform = matrix()*B.Enlarge, time=10)
				spawn(10)
					if(src.appearance_flags<512)
						src.appearance_flags+=512

			if(B.ProportionShift)
				animate(src, transform = src.transform*B.ProportionShift, time=10)
				spawn(10)
					if(src.appearance_flags<512)
						src.appearance_flags+=512

			if(B.CustomActive)
				OMsg(src, "[B.CustomActive]")
			else
				if(B.ActiveMessage)
					if(B.TextColor)
						OMsg(src, "<font color='[B.TextColor]'>[src] [B.ActiveMessage]</font color>")
					else
						OMsg(src, "[src] [B.ActiveMessage]")

			if(B.Imitate)
				B.OldName=src.name
				B.OldOverlays+=src.overlays
				B.OldBase=src.icon
				B.OldProfile=src.Profile
				B.OldTextColor=src.Text_Color
				if(src.Target)
					src.icon=src.Target.icon
					src.overlays=src.Target.overlays
					src.name=src.Target.name
					src.Profile=src.Target.Profile
					src.Text_Color=src.Target.Text_Color
				else
					src.icon=B.ImitateBase
					src.overlays=B.ImitateOverlays
					src.name=B.ImitateName
					src.Profile=B.ImitateProfile
					src.Text_Color=B.ImitateTextColor
				if(B.ImitateBadly)
					spawn()
						animate(src, color = list(0.35,0.2,0.2, 0.25,0.45,0.35, 0.25,0.25,0.55, 0,0,0), time = 3)

			if(B.NameFake)
				B.NameTrue=src.name
				src.name=B.NameFake

			if(B.FakeTextColor)
				B.OldTextColor = src.Text_Color
				Text_Color = B.FakeTextColor

			if(B.ProfileFake)
				B.OldProfile = src.Profile
				src.Profile = B.ProfileFake

			if(B.FakeInformationEnabled)
				if(!B.FakeInformation)
					B.FakeInformation = new()
				B.OldInformation = information
				information = B.FakeInformation

			if(B.FlashChange||B.DarkChange)
				if(B.IconTint)
					src.MobColor=B.IconTint
					spawn()
						animate(src, color = src.MobColor, time = 10, flags=ANIMATION_PARALLEL)
				else if(B.PowerGlows)
					spawn()
						src.FlickeringGlow(src, B.PowerGlows)
				else
					spawn()
						animate(src, color = null, time=10, flags=ANIMATION_PARALLEL)
			else
				if(B.IconTint)
					src.MobColor=B.IconTint
					spawn()
						animate(src, color = src.MobColor, time = 2, flags=ANIMATION_PARALLEL)
				else if(B.PowerGlows)
					spawn()
						src.FlickeringGlow(src, B.PowerGlows)

			if(B.VanishImage)
				src.VanishPersonal=B.VanishImage

			if(B.ManaGlow)
				filters = null
				filters += filter(type="drop_shadow",x=0,y=0,size=B.ManaGlowSize, offset=B.ManaGlowSize/2, color=B.ManaGlow)
				GlowFilter = filters[filters.len]
				filters += filter(type="motion_blur", x=0,y=0)

			if(B.ArmamentGlow)
				src.ArmamentGlow = filter(type="drop_shadow",x=0,y=0,size=B.ArmamentGlowSize, offset=B.ArmamentGlowSize/2, color=B.ArmamentGlow)
				AppearanceOff()
				AppearanceOn()

			if(B.TimerLimit)
				B.Timer=0
			if(B.Warp)
				src.Warp+=B.Warp
			if(B.SenseUnlocked)
				src.SenseUnlocked+=B.SenseUnlocked
			if(B.Afterimages)
				src.Afterimages+=1
			if(B.AutoAnger)
				Anger()
				passive_handler.Increase("EndlessAnger")
			if(B.CalmAnger)
				src.Anger=0
			if(B.AngerMult)
				src.AngerMult+=B.AngerMult
			// if(B.AngerThreshold)
			// 	src.AngerThreshold=B.AngerThreshold
			if(B.AngerPoint)
				src.AngerPoint += B.AngerPoint
			if(B.WaveringAngerLimit)
				B.WaveringAnger=0
				B.NoAnger=0
			if(B.AngerMessage)
				B.OldAngerMessage=src.AngerMessage
				src.AngerMessage=B.AngerMessage
			if(B.PoseEnhancement)
				src.PoseEnhancement+=B.PoseEnhancement
			if(B.BioArmor)
				src.BioArmor+=B.BioArmor
			if(B.VaizardHealth)
				src.VaizardHealth+=B.VaizardHealth
			if(B.KiControlMastery)
				src.KiControlMastery+=B.KiControlMastery
			if(B.GatesLevel)
				switch(B.GatesLevel)
					if(2)
						if(src.GatesNerfPerc<=20)
							src.GatesNerfPerc=0
							src.GatesNerf=0
							usr.SubStrTax(0.05)
							usr.SubEndTax(0.05)
							usr.SubSpdTax(0.05)
					if(3)
						if(src.GatesNerfPerc<=25)
							src.GatesNerfPerc=0
							src.GatesNerf=0
							usr.SubStrTax(0.1)
							usr.SubEndTax(0.1)
							usr.SubSpdTax(0.1)
					if(4)
						if(src.GatesNerfPerc<=30)
							src.GatesNerfPerc=0
							src.GatesNerf=0
							usr.SubStrTax(0.15)
							usr.SubEndTax(0.15)
							usr.SubSpdTax(0.15)
					if(5)
						if(src.GatesNerfPerc<=35)
							src.GatesNerfPerc=0
							src.GatesNerf=0
							usr.SubStrTax(0.2)
							usr.SubEndTax(0.2)
							usr.SubSpdTax(0.2)
					if(6)
						if(src.GatesNerfPerc<=40)
							src.GatesNerfPerc=0
							src.GatesNerf=0
							usr.SubStrTax(0.25)
							usr.SubEndTax(0.25)
							usr.SubSpdTax(0.25)
					if(7)
						if(src.GatesNerfPerc<=45)
							src.GatesNerfPerc=0
							src.GatesNerf=0
							usr.SubStrTax(0.3)
							usr.SubEndTax(0.3)
							usr.SubSpdTax(0.3)
					if(8)
						if(src.GatesNerfPerc)
							src.GatesNerfPerc=0
							src.GatesNerf=0
							usr.SubStrTax(1)
							usr.SubEndTax(1)
							usr.SubSpdTax(1)
				src.GatesMessage(B.GatesLevel)
				src.GatesActive=B.GatesLevel
				B.FatigueThreshold=20+(10*src.GatesActive)
			if(B.MagicSword&&!B.MakesSword)
				var/obj/Items/Sword/s=src.EquippedSword()
				if(s)
					s.MagicSword+=B.MagicSword
			if(B.SpiritSword&&!B.MakesSword)
				var/obj/Items/Sword/s=src.EquippedSword()
				if(s)
					s.SpiritSword+=B.SpiritSword
			if(B.Extend&&!B.MakesSword)
				var/obj/Items/Sword/s=src.EquippedSword()
				if(s)
					s.Extend+=B.Extend
			if(B.PowerInvisible)
				src.PowerInvisible*=B.PowerInvisible
			if(B.PURestrictionRemove)
				src.PURestrictionRemove+=B.PURestrictionRemove
			if(B.UnlimitedPU)
				src.PUUnlimited+=1
			if(B.EffortlessPU)
				B.OldEffortlessPU=src.PUEffortless
				src.PUEffortless=B.EffortlessPU
			if(B.SureHitTimerLimit)
				src.SureHitTimerLimit=B.SureHitTimerLimit
			if(B.SureHitTimerLimit)
				src.SureHitTimerLimit=B.SureHitTimerLimit
			if(B.SureDodgeTimerLimit)
				src.SureDodgeTimerLimit=B.SureDodgeTimerLimit
			if(B.Incorporeal)
				src.density=0
				src.invisibility=98
				src.AdminInviso=1
				src.Incorporeal=1
			if(B.ElementalOffense)
				src.ElementalOffense=B.ElementalOffense
			if(B.ElementalDefense)
				src.ElementalDefense=B.ElementalDefense
			if(B.ElementalEnchantment)
				var/obj/Items/Sword/s=src.EquippedSword()
				var/obj/Items/Sword/s2=src.EquippedStaff()
				if(s&&!s.Element)
					s.Element=B.ElementalEnchantment
					s.ElementallyInfused=1
				if(s2&&!s2.Element)
					s2.Element=B.ElementalEnchantment
					s2.ElementallyInfused=1
			if(B.PUDrainReduction)
				src.PUDrainReduction+=(B.PUDrainReduction-1)
			if(B.PUSpeedModifier)
				src.PUSpeedModifier*=B.PUSpeedModifier
			if(B.ArcaneBladework)
				src.ArcaneBladework=1
			if(B.WarpZone)
				B.WarpTarget=src.Target
				if(src.KO||src.Health<15)
					src.RemoveSlotlessBuff(B)
					return
				else
					B.WarpTarget.OldLoc = list(B.WarpTarget.x, B.WarpTarget.y, B.WarpTarget.z)
					B.OldLocX=src.x
					B.OldLocY=src.y
					B.OldLocZ=src.z
					if(B.Duel)
						src.loc=locate(B.WarpX, B.WarpY, B.WarpZ)
					B.WarpTarget.loc=locate(B.WarpX, B.WarpY-5, B.WarpZ)
			if(B.EnergyExpenditure)
				src.EnergyExpenditure+=B.EnergyExpenditure
			if(B.Warping)
				src.Warping=B.Warping
			if(B.Siphon)
				src.EnergySiphon+=(0.1*B.Siphon)
			if(B.Intimidation)
				src.Intimidation*=B.Intimidation
			if(B.PridefulRage)
				src.PridefulRage+=1
			if(B.DefianceRetaliate)
				src.DefianceRetaliate+=B.DefianceRetaliate
			if(B.FusionPowered)
				src.FusionPowered+=1
			if(B.Overdrive)
				if(src.MeditateModule)
					if(isRace(ANDROID))
						src.HealHealth(10)
					else
						src.HealWounds(15)
						src.HealHealth(15)
			if(B.Skimming||B.Flight)
				if(B.Flight)
					src.Flying=1
				Flight(src, Start=1)
			if(B.HealthCost)
				src.DoDamage(src, TrueDamage(B.HealthCost))
			if(B.EnergyCost)
				var/drain = passive_handler["Drained"] ? B.EnergyCost * (1 + passive_handler["Drained"]/10) : B.EnergyCost
				src.LoseEnergy(drain)
			if(B.ManaCost)
				if(!src.TomeSpell(B))
					src.LoseMana(B.ManaCost)
				else
					src.LoseMana(B.ManaCost*(1-(0.45*src.TomeSpell(B))))
				if(B.CorruptionGain)
					gainCorruption((B.ManaCost / 1.5) * glob.CORRUPTION_GAIN)
			if(B.ResourceCost)
				var/resourceName = B.ResourceCost[1]
				var/cost = B.ResourceCost[2]
				if(resourceName in vars)
					// the cost associated exists
					vars[resourceName] -= cost
					if(vars[resourceName] < 0)
						vars[resourceName] = 0
				else
					if(passive_handler[resourceName])
						passive_handler.Decrease(resourceName, cost)
						if(passive_handler[resourceName] < 0)
							passive_handler.Set(resourceName, 0 )// shouldnt b possible


			if(B.CorruptionCost)
				gainCorruption(-B.CorruptionCost)
			if(B.CapacityCost)
				src.LoseCapacity(B.CapacityCost)
			if(B.WoundCost)
				src.WoundSelf(B.WoundCost)
			if(B.FatigueCost)
				src.GainFatigue(B.FatigueCost)
			if(B.Kaioken)
				src.Kaioken=1
			if(B.HitSpark)
				src.SetHitSpark(B.HitSpark, B.HitX, B.HitY, B.HitTurn, B.HitSize)
			if(B.SeeInvisible)
				src.see_invisible+=B.SeeInvisible+1
			if(B.Invisible)
				spawn()
					animate(src,alpha=50,time=10)
				sleep(10)
				src.invisibility+=B.Invisible
				src.see_invisible+=B.Invisible+1
			if(B.ManaAdd)
				src.HealMana(B.ManaAdd)
			if(B.PhysicalHitsLimit)
				B.PhysicalHits=0
			if(B.UnarmedHitsLimit)
				B.UnarmedHits=0
			if(B.SwordHitsLimit)
				B.SwordHits=0
			if(B.SpiritHitsLimit)
				B.SpiritHits=0
			if(B.InstantAffect)
				B.InstantAffected=0
			if(B.SpiritForm)
				src.SpiritShift()
			if(B.BuffTechniques.len>0)
				for(var/x=1, x<=B.BuffTechniques.len, x++)
					var/path=text2path("[B.BuffTechniques[x]]")
					var/obj/o = new path
					if(!locate(o, src))
						src.AddSkill(o)
			if(B.IconOutline)
				src.filters += B.IconOutline
			if(B.BuffName=="Kyoukaken")
				if(src.Target&&src.Target!=src&&!src.Target.HasMirrorStats()&&istype(src.Target, /mob/Players))
					src.Kyoukaken("On")
			if(B.EndYourself)
				src.RemoveSlotlessBuff(B)

			src.BuffingUp=0

		AllSkillsRemove(obj/Skills/Buffs/B)

			if(B.ClientTint)
				if(src.SenseRobbed>=5)
					animate(src.client, color = list(-1,0,0, 0,-1,0, 0,0,-1, 1,1,1), time=3)
				else
					animate(src.client, color = null, time = 3)
				src.appearance_flags-=16
			if(B.StanceActive)
				src.StanceActive=null
			if(B.StyleActive)
				src.StyleActive=null
			if(B.IconTransform)
				var/image/T=image(B.IconTransform, pixel_x=B.TransformX, pixel_y=B.TransformY, loc = src)
				T.appearance_flags=68
				world << T
				spawn()
					animate(T, alpha=255)
					animate(T, alpha=0, time=3)
				spawn()
					src.icon=B.icon
					src.pixel_x=B.pixel_x
					src.pixel_y=B.pixel_y
					src.Transformed=0
					src.AppearanceOn()
					B.icon=null
					B.pixel_x=null
					B.pixel_y=null
					animate(src, alpha=0)
					animate(src, alpha=255, time=3)
				spawn(3)
					del T
				sleep(3)

			if(B.FlashChange)
				animate(src, color = list(1,0,0, 0,1,0, 0,0,1, 1,1,1))

			if(B.StrReplace)
				src.StrReplace=0
			if(B.EndReplace)
				src.EndReplace=0
			if(B.ForReplace)
				src.ForReplace=0
			if(B.SpdReplace)
				src.SpdReplace=0
			if(B.RecovReplace)
				src.RecovReplace=0

			if(B.TopOverlayLock)//subs out the aura
				if(istype(B.TopOverlayLock, /list))
					for(var/index in B.TopOverlayLock)
						if(istype(B.TopOverlayLock[index], /list))
							var/list/l = B.TopOverlayLock[index]
							src.overlays -= image(icon=l["icon"], pixel_x=l["pixel_x"], pixel_y=l["pixel_y"], layer=FLOAT_LAYER-1)
						else
							src.overlays -= image(icon=B.TopOverlayLock[index], pixel_x=B.TopOverlayX, pixel_y=B.TopOverlayY, layer=FLOAT_LAYER-1)
				else
					var/image/im=image(icon=B.TopOverlayLock, pixel_x=B.TopOverlayX, pixel_y=B.TopOverlayY, layer=FLOAT_LAYER-1)
					im.blend_mode=B.IconLockBlend
					im.transform*=B.OverlaySize
					if(B.OverlaySize>=2)
						im.appearance_flags+=512
					src.overlays-=im


			if(B.StripEquip==1)
				if(B.AssociatedGear)
					src.overlays+=image(B.AssociatedGear.icon, pixel_x=B.AssociatedGear.pixel_x, pixel_y=B.AssociatedGear.pixel_y, layer=FLOAT_LAYER-3)
				if(B.AssociatedLegend)
					src.overlays+=image(B.AssociatedLegend.icon, pixel_x=B.AssociatedLegend.pixel_x, pixel_y=B.AssociatedLegend.pixel_y, layer=FLOAT_LAYER-3)
			if(B.HairLock)
				if(B.HairLock==1)
					src.Hairz("Add")
				else
					src.HairLocked=0
					src.Hairz("Add")
			if(B.IconReplace&&B.OldIcon)
				src.icon=B.OldIcon
				src.pixel_x=B.OldX
				src.pixel_y=B.OldY
			if(B.IconLock)
				var/image/im=image(icon=B.IconLock, pixel_x=B.LockX, pixel_y=B.LockY, icon_state = B.IconState,layer=FLOAT_LAYER-B.IconLayer)
				im.blend_mode=B.IconLockBlend
				im.transform*=B.OverlaySize
				if(B.OverlaySize>=2)
					im.appearance_flags+=512
				if(src.CheckActive("Mobile Suit")&&B.BuffName!="Mobile Suit")
					im.transform*=3
				if(B.IconApart)
					im.appearance_flags+=70
				if(B.IconUnder)
					src.underlays-=im
				else
					src.overlays-=im
			if(B.StripEquip==2)
				if(B.AssociatedGear)
					src.overlays+=image(B.AssociatedGear.icon, pixel_x=B.AssociatedGear.pixel_x, pixel_y=B.AssociatedGear.pixel_y, layer=FLOAT_LAYER-3)
				if(B.AssociatedLegend)
					src.overlays+=image(B.AssociatedLegend.icon, pixel_x=B.AssociatedLegend.pixel_x, pixel_y=B.AssociatedLegend.pixel_y, layer=FLOAT_LAYER-3)

			if(B.AuraLock||B.OverlayTransLock)
				if(B.AuraLock)
					if(src.AuraLocked)
						src.AuraLocked-=1
						if(B.AuraUnder)
							src.AuraLockedUnder-=1
				src.Auraz("Remove")

			if(B.TargetOverlay)
				var/image/im=image(icon=B.TargetOverlay, pixel_x=B.TargetOverlayX, pixel_y=B.TargetOverlayY)
				im.blend_mode=B.IconLockBlend
				im.transform*=B.OverlaySize
				if(B.OverlaySize>=2)
					im.appearance_flags+=512
				src.overlays-=im
				if(src.Target)
					src.Target.overlays-=im

			if(B.MakesStaff)
				var/obj/Items/Enchantment/Staff/s=src.EquippedStaff()
				if(s.Conjured)
					s.AlignEquip(src)
					del s
			if(B.MakesSecondSword)
				var/obj/Items/Sword/s=src.EquippedSecondSword()
				if(s.Conjured)
					s.AlignEquip(src)
					del s
			if(B.MakesArmor)
				var/obj/Items/Sword/s=src.EquippedArmor()
				if(s.Conjured)
					s.AlignEquip(src)
					del s
				var/image/im=image(icon='goldsaint_cape.dmi', layer=FLOAT_LAYER-3)
				src.overlays-=im
			if(B.MakesSword)
				var/obj/Items/Sword/s=src.EquippedSword()
				if(s.Conjured)
					s.AlignEquip(src)
					del s
				if(B.MakesSword==3)
					for(s in src)
						if(s.Conjured)
							if(s.suffix) s.AlignEquip(src)
							del s
			if(B.SwordIconOld)
				var/obj/Items/Sword/s = src.EquippedSword()
				if(s)
					s.AlignEquip(src)
					s.icon=B.SwordIconOld
					if(B.SwordXOld)
						s.pixel_x=B.SwordXOld
					if(B.SwordYOld)
						s.pixel_y=B.SwordYOld
					s.AlignEquip(src)
			if(B.SwordClassOld)
				var/obj/Items/Sword/s = src.EquippedSword()
				if(s)
					s.Class=B.SwordClassOld
					s.setStatLine()
			if(B.SwordName)
				var/obj/Items/Sword/s = src.EquippedSword()
				if(s&&s.Password)
					s.name=s.Password
			if(B.SwordRefinement)
				var/obj/Items/Sword/s = src.EquippedSword()
				if(s)
					s.ExtraClass = B.SwordRefinement
			if(B.NeedsSecondSword)
				for(var/obj/Items/Sword/s in src)
					if(s.suffix=="*Equipped*"||(s.suffix=="*Broken*" && !passive_handler["Sword Master"]))
						continue
					src.overlays-=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y)
					s.AlignEquip(src)
					break
			if(B.NeedsThirdSword)
				var/src2=0
				var/src3=0

				for(var/obj/Items/Sword/s in src)
					if(s.suffix=="*Equipped*"||(s.suffix=="*Broken*" && !passive_handler["Sword Master"]))
						continue
					if(!src2)
						src.overlays-=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y)
						s.AlignEquip(src)
						src2=s
						continue
					if(!src3)
						if(s==src2)
							continue
						else
							src.overlays-=image(icon=s.icon, pixel_x=s.pixel_x, pixel_y=s.pixel_y)
							s.AlignEquip(src)
							src3=s
							break

			if(B.Enlarge)
				if(src.appearance_flags>=512)
					src.appearance_flags-=512
				animate(src, transform = matrix(), time = 10)

			if(B.ProportionShift)
				if(src.appearance_flags>=512)
					src.appearance_flags-=512
				animate(src, transform = src.transform/B.ProportionShift, time=10)

			if(B.IconTint&&!B.FlashChange)
				src.MobColor=list(1,0,0, 0,1,0, 0,0,1, 0,0,0)
				spawn()
					animate(src, color = src.MobColor, time = 2, flags=ANIMATION_PARALLEL)

			if(B.alphaChange)
				src.alpha = 255

			if(B.DropOverlays)
				spawn(1)src.AppearanceOn()

			if(B.FlashChange)
				src.MobColor=list(1,0,0, 0,1,0, 0,0,1, 0,0,0)
				animate(src, color = src.MobColor, time=10)
			if(B.PowerGlows)
				FlickeringGlow=0

			if(B.VanishImage)
				src.VanishPersonal=null

			if(B.TimerLimit)
				B.Timer=0
			if(B.Warp)
				src.Warp-=B.Warp
			if(B.SpiritSword)
				if(src.HasSword())
					var/obj/Items/Sword/s=src.EquippedSword()
					s.SpiritSword-=B.SpiritSword
			if(B.Extend)
				if(src.HasSword())
					var/obj/Items/Sword/s=src.EquippedSword()
					s.Extend-=B.Extend
			if(B.MagicSword)
				if(src.HasSword())
					var/obj/Items/Sword/s=src.EquippedSword()
					s.MagicSword-=B.MagicSword
			if(B.SenseUnlocked)
				src.SenseUnlocked-=B.SenseUnlocked
			if(B.Afterimages)
				src.Afterimages-=B.Afterimages
			if(B.AutoAnger)
				if(passive_handler.Get("EndlessAnger"))
					passive_handler.Decrease("EndlessAnger")
				src.Calm()
			// if(B.AngerThreshold)
			// 	src.AngerThreshold-=B.AngerThreshold
			if(B.AngerPoint)
				src.AngerPoint -= B.AngerPoint
			if(B.AngerMult)
				src.AngerMult-=B.AngerMult
			if(B.AngerMessage)
				src.AngerMessage=B.OldAngerMessage
			if(B.PoseEnhancement)
				src.PoseEnhancement-=B.PoseEnhancement
			if(B.BioArmor)
				src.BioArmor-=B.BioArmor
				if(src.BioArmor<0)
					src.BioArmor=0
			if(B.VaizardHealth)
				src.VaizardHealth-=B.VaizardHealth
				if(src.VaizardHealth<0)
					src.VaizardHealth=0
			if(B.KiControlMastery)
				src.KiControlMastery-=B.KiControlMastery

			if(B.ManaGlow)
				filters -= GlowFilter
				GlowFilter = null
			if(B.ArmamentGlow)
				src.ArmamentGlow = null
				AppearanceOff()
				AppearanceOn()
			if(B.GatesLevel)
				if(B.ShuttingGates)
					usr.GatesActive=0
					if(B.GatesLevel >= usr.SagaLevel)
						switch(B.GatesLevel)//It only cares about what the highest gate you used was
							if(1)
								if(src.GatesNerfPerc<=20)
									src.GatesNerfPerc=20
									src.GatesNerf=RawMinutes(1)
								usr.AddStrTax(0.05)
								usr.AddEndTax(0.05)
								usr.AddSpdTax(0.05)
							if(2)
								if(src.GatesNerfPerc<=25)
									src.GatesNerfPerc=25
									src.GatesNerf=RawMinutes(4)
								usr.AddStrTax(0.1)
								usr.AddEndTax(0.1)
								usr.AddSpdTax(0.1)
							if(3)
								if(src.GatesNerfPerc<=30)
									src.GatesNerfPerc=30
									src.GatesNerf=RawHours(1)
								usr.AddStrTax(0.15)
								usr.AddEndTax(0.15)
								usr.AddSpdTax(0.15)
							if(4)
								if(src.GatesNerfPerc<=35)
									src.GatesNerfPerc=35
									src.GatesNerf=RawHours(4)
								usr.AddStrTax(0.2)
								usr.AddEndTax(0.2)
								usr.AddSpdTax(0.2)
							if(5)
								if(src.GatesNerfPerc<=40)
									src.GatesNerfPerc=40
									src.GatesNerf=RawHours(6)
								usr.AddStrTax(0.25)
								usr.AddEndTax(0.25)
								usr.AddSpdTax(0.25)
							if(6)
								if(src.GatesNerfPerc<=45)
									src.GatesNerfPerc=45
									src.GatesNerf=RawHours(1)
								usr.AddStrTax(0.3)
								usr.AddEndTax(0.3)
								usr.AddSpdTax(0.3)
							if(7)
								if(src.GatesNerfPerc<=50)
									src.GatesNerfPerc=50
									src.GatesNerf=RawHours(4)
								usr.AddStrTax(0.5)
								usr.AddEndTax(0.5)
								usr.AddSpdTax(0.5)
							if(8)
								src.GatesNerfPerc=90
								src.GatesNerf=-1
								src.TotalInjury+=90
								src.Unconscious()
								src.Burn=100
								src.HealthCut=0.5
								src.EnergyCut=0.5
								src.StrCut=0.5
								src.EndCut=0.5
								src.SpdCut=0.5
								src.RecovCut=0.5
					B.GatesLevel=0
			if(B.WoundNerf)
				switch(B.WoundNerf)
					if(1)
						var/Time=RawHours(12)
						Time/=src.GetRecov()
						src.BPPoisonTimer=Time
						src.BPPoison=0.9
					if(2)
						var/Time=RawHours(12)
						Time/=src.GetRecov()
						src.BPPoisonTimer=Time
						src.BPPoison=0.7
					if(3)
						var/Time=RawHours(6)
						Time/=src.GetRecov()
						src.BPPoisonTimer=Time
						src.BPPoison=0.5
			if(B.OverClock)
				src.OverClockNerf+=B.OverClock
				if(src.OverClockNerf>=1)
					src.OverClockNerf=0.99
				src.OverClockTime+=RawHours(10*B.OverClock)
			if(B.PotionCD)
				src.PotionCD+=B.PotionCD

			if(B.AngerStorage)
				src.AngerMax=B.AngerStorage
			if(B.PowerInvisible)
				src.PowerInvisible/=B.PowerInvisible
			if(B.PURestrictionRemove)
				src.PURestrictionRemove-=B.PURestrictionRemove
			if(B.UnlimitedPU)
				src.PUUnlimited-=1
			if(B.EffortlessPU)
				src.PUEffortless=B.OldEffortlessPU
			if("StealsStats" in B.passives)
				src.StrStolen=0
				src.EndStolen=0
				src.SpdStolen=0
				src.ForStolen=0
				src.OffStolen=0
				src.DefStolen=0
			if(B.SureHitTimerLimit)
				src.SureHitTimerLimit=0
				src.SureHitTimer=0
				src.SureHit=0
			if(B.SureDodgeTimerLimit)
				src.SureDodgeTimerLimit=0
				src.SureDodgeTimer=0
				src.SureDodge=0
			if(B.Incorporeal)
				src.density=1
				src.invisibility=0
				src.AdminInviso=0
				src.Incorporeal=0
			if(B.ElementalOffense)
				src.ElementalOffense=null
			if(B.ElementalDefense)
				src.ElementalDefense=null
			if(B.ElementalEnchantment)
				var/obj/Items/Sword/s=src.EquippedSword()
				var/obj/Items/Sword/s2=src.EquippedStaff()
				if(s&&s.ElementallyInfused)
					s.Element=null
					s.ElementallyInfused=null
				if(s2&&s2.ElementallyInfused)
					s2.Element=null
					s2.ElementallyInfused=null
			if(B.PUDrainReduction)
				src.PUDrainReduction-=(B.PUDrainReduction-1)
			if(B.PUSpeedModifier)
				src.PUSpeedModifier/=B.PUSpeedModifier
			if(B.ArcaneBladework)
				src.ArcaneBladework=0
			if(B.WarpZone)
				if(B.Duel)
					src.loc=locate(B.OldLocX, B.OldLocY, B.OldLocZ)
					if(B.SendBack)
						B.WarpTarget.loc = locate(B.WarpTarget.OldLoc[1], B.WarpTarget.OldLoc[2], B.WarpTarget.OldLoc[3])
					else
						B.WarpTarget.loc=locate(B.OldLocX+pick(-1,1), B.OldLocY+pick(-1,1), B.OldLocZ)

				B.OldLocX=0
				B.OldLocY=0
				B.OldLocZ=0
				B.WarpTarget=0
			if(B.EnergyExpenditure)
				src.EnergyExpenditure-=B.EnergyExpenditure
			/*if(B.Desperation)
				world.log<<"What called? [src] [B]"*/
			if(B.Warping)
				src.Warping=0
			if(B.Siphon)
				src.EnergySiphon-=(0.1*B.Siphon)
			if(B.Intimidation)
				src.Intimidation/=B.Intimidation
			if(B.PridefulRage)
				src.PridefulRage-=1
			if(B.DefianceRetaliate)
				src.DefianceRetaliate-=B.DefianceRetaliate
				src.DefianceCounter=0
			if(B.FusionPowered)
				src.FusionPowered-=1
			if(B.Overdrive)
				if(src.MeditateModule)
					if(isRace(ANDROID))
						src.DoDamage(src, TrueDamage(15))
					else
						src.WoundSelf(20)
						src.DoDamage(src, TrueDamage(20))
				if(src.FusionPowered)
					src.PowerControl=100

			if(B.Skimming||B.Flight)
				Flight(src, Land=1)
			if(B.Kaioken)
				src.Kaioken=0
			if(B.HitSpark)
				src.ClearHitSpark()
			if(B.ExplosiveFinish)
				src.Activate(new/obj/Skills/AutoHit/Explosive_Finish)
			if(B.FINISHINGMOVE)
				src.Unconscious()
			if(B.HealthCut)
				src.AddHealthCut(B.HealthCut)
			if(B.EnergyCut)
				src.AddEnergyCut(B.EnergyCut)
			if(B.ManaCut)
				src.AddManaCut(B.ManaCut)
			if(B.StrCut)
				src.AddStrCut(B.StrCut)
			if(B.EndCut)
				src.AddEndCut(B.EndCut)
			if(B.SpdCut)
				src.AddSpdCut(B.SpdCut)
			if(B.ForCut)
				src.AddForCut(B.ForCut)
			if(B.OffCut)
				src.AddOffCut(B.OffCut)
			if(B.DefCut)
				src.AddDefCut(B.DefCut)

			if(B.RecovCut)
				src.AddRecovCut(B.RecovCut)
			if(B.StrTax)
				src.AddStrTax(B.StrTax)
			if(B.EndTax)
				src.AddEndTax(B.EndTax)
			if(B.SpdTax)
				src.AddSpdTax(B.SpdTax)
			if(B.ForTax)
				src.AddForTax(B.ForTax)
			if(B.OffTax)
				src.AddOffTax(B.OffTax)
			if(B.DefTax)
				src.AddDefTax(B.DefTax)
			if(B.RecovTax)
				src.AddRecovTax(B.RecovTax)
			if(B.WaveringAngerLimit)
				B.WaveringAnger=0
			if(B.SeeInvisible)
				src.see_invisible-=(B.SeeInvisible+1)
			if(B.Invisible)
				spawn()
					animate(src,alpha=255,time=10)
				src.invisibility-=B.Invisible
				src.see_invisible-=(B.Invisible+1)
			if(B.ManaAdd)
				src.LoseMana(B.ManaAdd)
			if(B.PhysicalHitsLimit)
				B.PhysicalHits=0
			if(B.UnarmedHitsLimit)
				B.UnarmedHits=0
			if(B.SwordHitsLimit)
				B.SwordHits=0
			if(B.SpiritHitsLimit)
				B.SpiritHits=0
			if(B.SpiritForm)
				src.SpiritShiftBack()
			if(B.IconOutline)
				src.filters -= B.IconOutline
			if(B.InstantAffect)
				B.InstantAffected=0
			if(B.BuffName=="Kyoukaken")
				src.Kyoukaken("Off")

			if(B.KillSword&&src.EquippedSword())
				var/obj/Items/Sword/s=src.EquippedSword()
				src.SwordShatter(s)
			else if(B.KillSword&&src.EquippedStaff())
				var/obj/Items/Enchantment/Staff/st=src.EquippedStaff()
				src.StaffShatter(st)

			if(B.CustomOff)
				OMsg(src, "[B.CustomOff]")
			else
				if(B.OffMessage)
					if(B.TextColor)
						OMsg(src, "<font color='[B.TextColor]'>[src] [B.OffMessage]</font color>")
					else
						OMsg(src, "[src] [B.OffMessage]")

			if(B.DebuffCrash)
				var/list/debuffs=list()
				debuffs.Add(B.DebuffCrash)
				for(var/d in debuffs)
					if(d=="Poison")
						src.LoseHealth(src.Poison * 0.05)//5% at 100% poison
						src.WoundSelf(src.Poison/20)
						src.Poison=0
					if(d=="Fire")
						src.LoseHealth(src.Burn/20)//5% at 100% burn
						src.Burn=0

			if(B.MaimCost)
				src.Maimed+=B.MaimCost
				src << "You have been maimed by using the overwhelming power of [B]!"

			if(B.Imitate)
				src.name=B.OldName
				src.overlays=null
				src.icon=B.OldBase
				src.overlays+=B.OldOverlays
				src.Profile=B.OldProfile
				src.Text_Color=B.OldTextColor
				B.OldName=null
				B.OldBase=null
				B.OldOverlays=list()
				B.OldProfile=null
				B.OldTextColor=null
				if(src.color)
					spawn()
						animate(src, color = null, time = 3)

			if(B.NameFake)
				src.name=B.NameTrue

			if(B.FakeTextColor)
				Text_Color = B.OldTextColor

			if(B.ProfileFake)
				src.Profile = B.OldProfile
				B.ProfileFake = null

			if(B.FakeInformation&&B.FakeInformationEnabled)
				information = B.OldInformation
				B.OldInformation = null
			if(B.Transform)
				if(B.Transform=="Strong")
					src.Intimidation/=1.5
				else if(B.Transform=="Weak")
					src.PowerBoost/=0.25
				else if(B.Transform=="Force")
					transUnlocked=max(transUnlocked-1,0)
					src.Revert()
				else
					src.Revert(B.Transform)

			if(B.AllOutPU)
				if(src.CheckActive("Ki Control"))
					for(var/obj/Skills/Buffs/ActiveBuffs/Ki_Control/KC in Buffs)
						src.UseBuff(KC, Override=1)

			if(B.type==/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/What_Must_Be_Done)
				B.StrMult=1
				B.EndMult=1
				B.SpdMult=1
				B.ForMult=1

			if(B.Cooldown)
				if(src.TomeSpell(B))
					B.Cooldown()
				else
					B.Cooldown(p = src)

			if(B.BuffTechniques.len>0)
				for(var/x=1, x<=B.BuffTechniques.len, x++)
					var/path=text2path("[B.BuffTechniques[x]]")
					for(var/obj/Skills/o in usr)
						if(o.type == path)
							if(istype(o, /obj/Skills/Buffs) && BuffOn(o))
								var/obj/Skills/Buffs/b = o
								if(b.Trigger(src, Override=1))
									del b
							else
								del o

			src.BuffingUp=0
			if(B.DeleteOnRemove) // DELETE ON REMOVE
				if(B in src.SlotlessBuffs)
					src.SlotlessBuffs.Remove(B) // diouble time ?
				DeleteSkill(B, TRUE)
				return
			if(B.AlwaysOn && !B.doNotDelete)
				if(B.NeedsPassword)
					if(B.Password)
						if(B in src.SlotlessBuffs)
							src.SlotlessBuffs.Remove(B)
						del B
				else
					if(B in src.SlotlessBuffs)
						src.SlotlessBuffs.Remove(B)
					del B


mob
	proc
		BuffOn(var/obj/Skills/Buffs/B)
			if(src.StanceBuff)
				if(src.StanceBuff.type==B.type)
					return 1
			if(src.StyleBuff)
				if(src.StyleBuff.type==B.type)
					return 1
			if(src.ActiveBuff)
				if(src.ActiveBuff.type==B.type)
					return 1
			if(src.SpecialBuff)
				if(src.SpecialBuff.type==B.type)
					return 1
			if(src.SlotlessBuffs.len>0)
				if(istext(B))
					if(SlotlessBuffs[B])
						return 1
				if(SlotlessBuffs["[B.BuffName]"])
					return 1
			return 0