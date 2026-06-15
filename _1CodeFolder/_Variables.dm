// Multiplier on each beam skill's ChargeRate for max charge level
#define BEAM_CHARGE_CAP_MULT 10

/mob/var/Power = 1

atom/var
	tmp/Using=0
	tmp/mob/Owner
	Health=100
	LastIconChange
	AdminInviso=0
	FlyOverAble=1
	IgnoreFlyOver=0
	UnFlyable=0
	// Current available power, a compilation of many factors. Editing will do nothing
	Level=1
	Speed=1
	Savable
	Builder
	Buildable=1
	Grabbable=1
	Distance=15
	Spawn_Timer=0
	isOutside
	isUnderwater
	PrevX
	PrevY
	PrevZ
	Password
	Password2
	Password3
	PasswordReception
	preventRename = FALSE

area
	mouse_opacity=0
obj
	var/Attackable=1
	var/Destructable=1

mob/Health=100
mob/var
	last_online
	//Mechanical Variables
	KOTimer//moving this over here so mortal wounds aren't so weird.
	KOBrutal//If this is flagged, you won't recover some health when you awaken
	Voiding//void timer, TODO mode
	ScreenSize
	tmp/mob/Target
	tmp/PoseEnhancement//Pose for 3 seconds to get a bonus to rippling.
	tmp/PoseTime//timer
	tmp/LastPose
	tmp/BuffingUp=0//to stop people from pushing through weird buff behaviour
	tmp/WindingUp//new var for autohitsu
	tmp/PoweringUp=0
	tmp/PoweringDown=0
	tmp/Knockback//The distance to be knocked back.
	tmp/previousKnockBack // how far you were knocked back last time
	tmp/Knockbacked//The direction of knockback.
	tmp/Shielding//used for fanciness
	tmp/Beaming=0//If true when a direction is pressed, do not move, but change directions.
	tmp/BeamVolleyHitPlayer=0//Set during Area=="Beam" volley if any other player took beam damage (for miss cooldown refund)
	tmp/BeamFiringVolley=0//True while a beam has reached active fire (Beaming==2) this charge, used to skip refund on charge-only cancel
	tmp/BeamCharging=0.5//Holds the length of time that a beam has been charging for
	tmp/BusterCharging=0//holds the length of time uve been trying to be megaman
	tmp/obj/Skills/Projectile/BusterTech//holds a buster technique, holy fuqq
	tmp/list/mob/BeingObserved=list()//this holds the observer, and sends them messages
	tmp/list/BeingTargetted=list() //list of mobs currently targetting
	tmp/Airborne = 0
	var/AirborneInterrupted = 0
	tmp/is_dashing = 0
	tmp/verb_delay = 0
	tmp/last_autohit
	tmp/last_autohit_used // type path of the last AutoHit skill used (for Envy copy)
	tmp/GlowFilter
	tmp/ArmamentGlow
	tmp/FlickeringGlow
	tmp/MeditateTime
	tmp/Party/party//party party party
	tmp/StunImmune
	tmp/BlindImmune=0
	tmp/GrabTime
	tmp/CloudedHeartActive = FALSE
	tmp/mirror_parry_active   = FALSE
	tmp/mirror_reflect_active = FALSE
	tmp/mirror_hold_slowing   = FALSE
	custom_scent
	custom_powerup
	customPUnameInclude = FALSE
	RPPMult=1
	EconomyMult=1
	Intelligence=1//technology modifier
	Imagination=1//enchantment modifier
	Intimidation=1//Adding this here for ezpz stuff.
	HealthCut=0
	EnergyMax=100
	Energy=100
	EnergyCut=0
	EnergyExpenditure=1//Crank that drain if higher than 1
	EnergyUniqueness=1//EVERYONE'S A SNOWFLAKE
	EnergySignature//holds your unique energy signature
	list/EnergySignaturesKnown=list()//holds signatures you identified
	list/ai_alliances=list()//these classes of ai wont attack you
	HybridChoice
	list/SkillsLocked=list()//paths of skills that have been locked out due to being prerequisites for upgraded versions
	tmp/SignatureSelecting=0//flag that disables checking for more sigs
	list/SignatureSelected=list()//names of signatures that have been selected already, so they can be removed from the global list when signature selection is activated
	list/SignatureStyles=list()//name & path of styles which can be selected from signature selection
	SignatureCheck=1//if 1, try to give signatures. if 0, do not
	tmp/list/obj/Skills/Skills=list()//skills you know
	tmp/list/obj/Skills/Queue/Queues=list()//queues you know
	tmp/list/obj/Skills/Projectile/Projectiles=list()//projectile attacks you know
	tmp/list/obj/Skills/AutoHit/AutoHits=list()//autohits you know
	tmp/list/obj/Skills/Buffs/Buffs=list()//buffs you know
	ManaCut=0

	StrAdded=0
	EndAdded=0
	ForAdded=0
	OffAdded=0
	DefAdded=0
	SpdAdded=0
	StrMultTotal=1
	StrTransMult=1
	StrChaos=1
	StrAscension=0
	StrReplace=0
	StrTax=0
	StrCut=0
	StrStolen=0
	StrEroded=0
	EndMultTotal=1
	EndTransMult=1
	EndChaos=1
	EndAscension=0
	tmp/StaggerMeter=0 // Boss Stun
	StaggerMult=1
	EndReplace=0
	EndTax=0
	EndCut=0
	EndStolen=0
	EndEroded=0
	SpdMultTotal=1
	SpdTransMult=1
	SpdChaos=1
	SpdAscension=0
	SpdReplace=0
	SpdTax=0
	SpdCut=0
	SpdStolen=0
	SpdEroded=0
	ForMultTotal=1
	ForTransMult=1
	ForChaos=1
	ForReplace=0
	ForAscension=0
	ForTax=0
	ForCut=0
	ForStolen=0
	ForEroded=0
	OffMultTotal=1
	OffTransMult=1
	OffChaos=1
	OffAscension=0
	OffTax=0
	OffCut=0
	OffStolen=0
	OffEroded=0
	DefMultTotal=1
	DefTransMult=1
	DefChaos=1
	DefAscension=0
	DefTax=0
	DefCut=0
	DefStolen=0
	DefEroded=0
	RecovMod=1
	RecovMultTotal=1
	RecovChaos=1
	RecovAscension=0
	RecovReplace
	RecovTax=0
	RecovCut=0
	RecovEroded=0
	AngerPoint=50//get angry with this percent of health left
	AngerMessage//custom anger messages
	AngerColor
	HiddenAnger //hide BP from anger
	CalmAnger //Never get angry unless something forces you to.  Like maki.
	ExhaustedMessage
	NanoBoostMessage = "'s nanites respond to their physical trauma, bolstering their cybernetic power!"
	NanoColor = "green"
	ExhaustedColor
	BarelyStandingMessage
	BarelyStandingColor

	Potential=1
	PotentialStatus="Caught Up"
	PotentialRate=1
	PotentialCap=1
	PotentialHeadStart=0
	RPPHeadStart=0
	potential_trans=0//entering trans state sets this
	potential_power_mult=1
	potential_last_checked=0
	PotentialDailyGain=0//how much potential can be obtained from NPCs
	PotentialLastDailyGain//when was the last date that daily gain was refreshed?
	RewardsLastGained = 0 //when was the last time you were rewarded?
	PowerBoost=1//Now it ain't borked!?
	PowerInvisible=1//only used for buffs now
	Shadowbringer=0
	PotentialUnlocked//You need a better UP after a previous one.
	ContractPowered=0//Like UP, but with contracts.
	SummonContract//just for summoning
	SummonReturnTimer//5 minutes then spirit go byebye
	GodKi//When this is active, FUKKEN MAGIC
	Tension//yaaa yeet
	TensionLock//pls dont
	SealPersonal
	VanishPersonal
	VanishFlick
	VanishDuration

	//Battle Variables
	NoAnger //Can't get angry when this is flagged.
	NoRevert=0 //Transformations don't revert.
	NoVoid //YOU THOUGHT YOU WERE GONNA VOID, BITCH?!
	NoDeath=0 //it means no worries...for the rest of your daaaays
	Damned=0


	Warping//You forcewarp.
	SuperDash//Mobs have this too now
	IaidoCounter//Once it hits ten, you get a zoom attack.
	GladiatorCounter = 9999

	MeltyMessage//ppl need to know this shit
	VenomMessage//fuck isroth being unique

	Attunement//Double X effects, double Y effects

	SenseRobbed=0
	tmp/startOfLaunch=0
	Launched=0
	Dunked=0
	tmp/Grounded=0
	tmp/Stunned
	Stasis//Can't take damage but can't take action.
	StasisFrozen//is in iceblock
	StasisSpace//if you're trapped in space prison

	Kaioken//Level of kaioken.
	KaiokenBP=1//Level of Kaioken intimidate.

	DoubleHelix//Kaioken but for humans

	DeathKilled=0//You get one.
	DeathKillerTargets//used for deathkiller
	NoSoul//Immediately delete the character when they are truly dead

	ManaSealed=0//Won't generate capacity due to having their circuits stolen by fake philosopher stone
	ManaDeath=0//TOO MUCH MANA
	list/Binding//Holds the zplane of binding
	BindingTimer//Every time this goes off, the person is returned to their zplane.
	HearThoughts=1
	Phylactery//if 1, make sure their phylactery is in the world
	PhylacteryNerf=0//take this percent out of anger

	Immortal //Not timeless, but won't die from age
	Spiritual//Demons and shinjin and yokai, o mai

	MovementCharges=0//charges of zanzo/AIS currently possessed (which yan thinks should be replaced by ddash and reverse dash entirely)
	Infusion//Getting hit by elemental techs can grant you minor versions for ever seconds.
	InfusionElement

	//Appearance Variables
	MobColor=list(1,0,0, 0,1,0, 0,0,1, 0,0,0)//used to define proper color listing to return to mob wise
	Text_Color="#45fa3f"
	OOC_Color="#666666"
	Emote_Color="#f0fa33"
	tmp/current_emote_text = ""
	Trait_Color//i guess it will be used for furries?!



	EyesSSJ='EyesSSJ.dmi'

	EyesSSJ3='EyesSSJ3.dmi'

	EyesSSJ4='EyesSSJ4.dmi'
	FurSSJ4
	ClothingSSJ4
	TailSSJ4

	EyesSSG='EyesSSG.dmi'

	EyesSSB='EyesSSB.dmi'

	EyesUI='EyesUI.dmi'

	ExpandBase

	SEAOffense='Soxx-Sacred_Armor_Offense.dmi'
	SEADefense='Soxx-Sacred_Armor_Defense.dmi'

	EldritchTrail='StarPixel.dmi'

	tmp/MirrorIcon

	//Knowledge Variables
	list/UnlockedTechnology=list()//this will hold the types of unlocked technology AND enchantment
	list/PotionTypes=list()//determines what herbs you can use

	GrimoiresMade//Holds how many Grimoire types you've made total

	Mechanized
	EnhanceChips
	EnhanceChipsMax=4
	PilotingProwess=0

	PUDrainReduction=1//Reduces PU drain.
	PUSpeedModifier=1
	PURestrictionRemove//NOTHING IS SACRED

	Incorporeal=0

	ArcaneBladework//Allows you to use swords and staves at the same time.
	OverClockNerf//Halves power.
	OverClockTime//duration of overclock.
	SureHit//All melee attacks hit.
	SureHitTimer//The active countdown.
	SureHitTimerLimit//The variable that makes sure that the timer works and resets it.
	SureDodge
	SureDodgeTimer
	SureDodgeTimerLimit
	tmp/CounterMasterTimer
	Afterimages//Jitters effect.
	EnergySiphon//(not) Raiju skill.

	obj/Skills/Buffs/ActiveBuff//New buff variable.
	obj/Skills/Buffs/SpecialBuff//New buff variable.
	list/obj/Skills/Buffs/SlotlessBuffs=list()//New buff variable list.
	obj/Skills/Buffs/StanceBuff//New stance variable.
	obj/Skills/Buffs/NuStyle/StyleBuff//New style variable.

	Maimed=0
	MaimsOutstanding//Maims - cyber limbs
	MaimCooldown //Prevents maims from happening too quickly.

	Timeless//Doesn't give a FUK about era
	EraBirth//keeps track of birth date for future interests
	EraAge//Keeps track of the numbers
	EraBody
	EraDeathClock//when u get too old, this will hold a value that will say when u die
	tmp/EraDeathTrigger
	ModifyBaby=0
	ModifyEarly=0
	ModifyPrime=0
	ModifyLate=0
	ModifyFinal=0

	tmp/obj/Skills/Queue/AttackQueue//This variable holds an object which has queue stats.
	Pursuiting//Chasing people down.
	WoundIntent=0
	RPPTotal//all normal rpp acquired over your character(s) life(s).
	RPPCurrent=0//normal rpp acquired over THIS character life.
	RPPSpendable=0//the actual value you can use of your rpp current
	RPPSpent=0//how much rpp you've spent

	RPPStartingDaysTriggered=0//increments
	RPPDonate=0//Used for elders; can help people hit cap sooner

	LastTeach=0
	Overview=1 //If overview is toggled on or not
	tmp/AFKTimer=24000 // AFK timer stuff
	AFKTimeLimit=24000 // AFK timer stuff
	AFKIcon='afk.dmi' // AFK icon
	CustomObj1Icon=null
	CustomObj1State=null
	CustomObj1X=null
	CustomObj1Y=null
	CustomObj1Density=null
	CustomObj1Opacity=null
	CustomObj1Layer=3
	CustomObjEdge = FALSE
	CustomTurfIcon='ArtificalObj.dmi'
	CustomTurfState="QuestionMark"
	CustomTurfRoof=0
	CustomTurfDensity=0
	CustomTurfOpacity=0
	tmp/mob/Transfering=0
	Warp=0
	tmp/Observing=0
	tmp/SaveDelay
	tmp/SenseCD
	Gender
	DisplayKey
	Oxygen=100
	OxygenMax=100
	PowerUp=0
	PowerDown=0
	image/ChargeIcon
	Class="Fighter"
	KO
	Build=0
	Inside=1
	ShallowMode=0
	UnderwaterMode=0
	Sight_Range=10
	Spawn="True Spawn"
	PureRPMode=0
	CutsceneWatch=0
	ForceHeavyStrike=0
	PCTransToggle=0 //0=on, 1=off
	SpawnArea = "None" //different from Spawn for Reasons

	CyberizeMod = 0
	tmp/IconClicked=0
	tmp/NextAttack		//As world.time
	tmp/ContinuousAttacking
	tmp/WarpStrikeHidingWeapon=0
	tmp/turf/warp_strike_saved_loc = null
	tmp/mob/Grab
	Power_Multiplier=1 //This changes temporarily with the use of power altering abilities.
	PowerEroded=0
	Base=1
	StrMod=1
	EndMod=1
	ForMod=1
	OffMod=1
	DefMod=1
	SpdMod=1

	TrueName//Holds true name for otherworldly beings
	RPPower=1 //Multiplies overall power, edited by admins to increase power when it is suited to do so.
	StealthRPPower=1//Multiplies power...invisibly!!
	Body=1
	//arent all of these useless anyway?
	PUEffortless
	PUUnlimited

	ManaPU=0
	PowerControl=100
	ActiveBuffs=0
	SpecialSlot=0
	Anger=0
	AngerMax=1
	AngerStorage=1

	Tail
	TailIcon='Tail.dmi'
	TailIconWrapped='Tail-Wrapped.dmi'
	TailIconUnderlay
	Golden
	Emitter
	SSJ4Unlocked

	Regenning=0

	Dead=0
	DeadAge=0
	DeadTime
	KeepBody=0
	Flying
	Skimming//pretends you're flying
	Charge_Icon
	MortallyWounded
	TsukiyomiTime
	tmp/CryokenesisTime = 0
	Lethal=0 //Lethality
	Timestamp=0 //Timestamp Setting
	GrabMove //THIS HAND OF MINE IS BURNING RED
	DelayedDamage
	CoinSetting="ZenniBag"
	StatModules=0
	EnhancedStrength=0
	EnhancedEndurance=0
	EnhancedAggression=0
	EnhancedReflexes=0
	EnhancedForce=0
	EnhancedSpeed=0
	InternalScouter=0
	NanoBoost=0
	NanoAnnounce=0
	BladeMode=0
	StealthSystems=0
	CombatCPU=0
	EnergyAssimilators=0
	EnhancedSmell=0
	BioAndroid=0
	PerfectForm=0
	SuperAndroid=0
	CyberneticMainframe
	SampleCollected=0
	list/bio_samples = null      // collected genetic samples, list of "RaceName:Tier" strings
	bio_donated_t1 = 0           // 1 if this player has already willfully donated their tier-1 sample
	Profile=null
	GimmickDesc=""
	GimmickTimer
	NormalIcon

	Meditating
	MeditationCD=0
	StanceActive
	Style
	StyleActive
	Confused//The amount of time you have reversed movement for.
	AngerMult//allows anger multipliers to stack. oh my god
	AngerThreshold//if you're not angry enough, this will make you angry enough
	AngerAdd //just adds anger
	AngerCD=0
	CyberCancel//Basically the same, but for cyber stuffs.
	CyberPowerAngerNerf
	CyberPassiveAngerNerf
	CyberActiveAngerNerf
	CyberStatAngerNerf
	EnhancedHearing=0
	//New variables; Advanced Stances and Staves give offense and defense.  Swords give offense.  Armor gives defense.
	ElementalOffense
	ElementalDefense
	Poison=0
	SilentPoisonAmount=0
	BlindingVenom = 0
	Burn=0
	SilentBurnAmount=0
	Frenzy=0
	Bleed=0
	Slow=0
	Shatter=0
	Harden=0
	Shock=0
	Sheared=0
	Crippled=0
	Attracting=0
	Attracted=0
	tmp/mob/AttractedTo=0
	Terrifying=0
	Terrified=0
	tmp/mob/TerrifiedOf=0
	PotionCD=0
	Satiated=0//fooooood
	Drunk=0//get op in drunk fist
	Aged=0//ignore youth debuffs
	Doped=0//ignore bp wounds
	Antivenomed=0//Makes poison do half damage and reduces it by a much higher rate.
	Cooled=0//Same, but for burn (and chill now)
	Sprayed=0//Reduce cripple/shear
	Stabilized=0//Reduce shock/confuse
	Roided=0//When BP Poison is less than 1, gives you half of the reduced value back
	Doomed
	DownToEarth
	BloodDrain
	ManaAmount=100
	ManaMax=100
	Default_Hair

	movementSealed = FALSE

	KiControlMastery=0

	PULock
	PUForce//overrides override...
	//JJBA vars
	TimeStop
	TimeFrozen

	//Eldritch Reflected state
	ReflectedFrozen = 0
	ReflectedFrozenTimer = 0
	WorldImmune=0

	//gates
	GatesNerf
	GatesNerfPerc

	TranceForm
	TranceCounter
	TranceObtained

	DelayedKB
	tmp/mob/DelayedKBCatalyst

	Transformed=0
	Oozaru=0
	OozaruTimer//7.5 minutes to monkey around
	OozaruBase//Holds old base value.
	OozaruName//Holds old name
	StarPowered=0//Makyo dick on/off
	JaganBase//holds old base mod when using JEM
	AscensionsUnlocked=0
	AscensionsAcquired=0
	unbreakable_tracking=0//Makyo shit
	unbroken_absorbed=0//Makyo shit
	BioArmor//How much extra health you have
	BioArmorMax//The total amount of extra health you can have

	NPCImmune
	BuildGiven
	TurfInvincible=TRUE
	TotalFatigue=0
	TotalInjury=0
	TotalCapacity=0//Philosopher stones are notably harder to meme with

	AerialRecovery
	HealthAnnounce25
	HealthAnnounce10
	InjuryAnnounce
	FatigueImmune
	InjuryImmune

	Secret
	Saga

	ConcealedPower//This hides vampires, werewolves, and makaioshins.
	BPPoison=1//Reduces BP by an amount.
	BPPoisonTimer//Determines how long it lasts.

	RecoilDamage//If this has a value, you'll do damage to yourself.
	FusionPowered//so you can be fatigue immune and regen energy in PU
	CyberLimb=0//The stuff replacing your maims
	AuraLocked
	AuraLockedUnder=0
	AuraLock
	AuraX
	AuraY
	HairLocked
	HairLock
	HairBX
	HairBY
	HairX=0
	HairY=0
	HairUnderlay
	HairUnderlayX=0
	HairUnderlayY=0
	WillPower
	Regenerating
	Judgment
	PridefulRage
	Defiance
	DefianceCounter=0
	DefianceRetaliate
	Adaptation
	AdaptationCounter=0
	tmp/mob/AdaptationTarget
	ShonenCounter
	ShonenAnnounce
	AdaptationAnnounce
	mob/var/tmp/Swim=0
	NextSerum//holds realtime of the next time you can use a revitalization serum
	usedSerums = 0
	magicalMaimRecov = 0
	TarotCooldown//holds realtime of the next time you can use a tarot card
	TarotFate//holds your tartot trump
	AllowObservers//Allows people to observe you fighting!
	list/GlobalCooldowns = list()

	BladeFisting = 0 // can punch with swords

	AriaCount = 0
	UBWPath

	obj/Items/Armor/equippedArmor
	obj/Items/Sword/equippedSword
	obj/Items/WeightedClothing/equippedWeights
	equippedProsthetics = 0

	tmp/emoteBubble
	tmp/rping = FALSE
	tmp/savedRoleplay

	PrayerMute = FALSE

	tension = 0

	ShinjinAscension

	AngelAscension

	CelestialAscension

	moneyGrindedDaily = 0

	HellspawnBerserk
	HellspawnTimer
	tmp/HellspawnBerserking
	ForcedHellspawn=0
	ForcedCalamity=0
	TheCalamity=0
	CalamityCaused

	ArsGoetiaOwner
	GoetiaContacted

	ChosenFPS

	AscendedDivine //for players who can read prayers
	SenseReplacement
	SSJ4FromBase
	LifeStolen=0

	WillYouPersist
	CutsceneMode
	ForcedLethal
	UnstoppableForceCounter
	ObliteratedX
	ObliteratedY
	ObliteratedZ

	list/demon_party = null
	demon_party_cap = 0
	list/demon_compendium = null
	demon_last_pick_potential = 0
	demon_pending_picks = 0
	tmp/demon_soul_dmg_pct = 0
	tmp/demon_soul_transfer_pct = 0 // Multiplier on redirected damage applied to demon_hp
	tmp/demon_active = null         // Live mob ref - would corrupt savefile
	tmp/demon_active_name = ""
	tmp/list/demon_skill_hud = null
	tmp/demon_summon_cooldown = 0
	tmp/demon_call_cooldown = 0
	tmp/demon_fusion_page = 1
	tmp/demon_record_page = 1
	tmp/demon_meditate_start = 0
	tmp/demon_meditate_healed = FALSE
	tmp/demon_fusion_open = FALSE
	tmp/demon_compendium_open = FALSE
	tmp/demon_record_open = FALSE
	tmp/demon_withdraw_open = FALSE
	tmp/demon_inherit_open = FALSE
	tmp/demon_skilllearn_open = FALSE
	tmp/demon_skilllearn_target = ""
	tmp/demon_sensing = FALSE   // TRUE while Sense Demons input dialog is open; prevents re-entry
	tmp/demon_pending_fuse_a = ""
	tmp/demon_pending_fuse_b = ""
	tmp/demon_pending_fuse_result = ""
	tmp/list/demon_pending_fuse_base_skills = null
	tmp/list/demon_pending_fuse_pool = null
	tmp/demon_pending_fuse_open_slots = 0
	tmp/demon_fusion_animating = FALSE
	tmp/list/demon_fusion_anim_images = null

/proc/reduceGodKi(mob/player, num)
	player.GodKi -= num
	if(num < 0)
		player.GodKi = 0
