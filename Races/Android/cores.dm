#define ANDROID_CORE_ETERNAL "Eternal"
#define ANDROID_CORE_ABSORPTION "Absorption"
#define ANDROID_CORE_BIO "Bio"
#define ANDROID_CORE_ASC_MAX 6
#define ANDROID_ETERNAL_REGEN_BASE 0.5
#define ANDROID_ETERNAL_REGEN_PER_ASC 0.1
#define ANDROID_ETERNAL_FATIGUE_MULT 0.6
#define ANDROID_ETERNAL_FORCE_BASE 0.9
#define ANDROID_ETERNAL_FORCE_PER_ASC 0.02
#define ANDROID_ABSORB_REGEN_MULT 0.7
#define ANDROID_ABSORB_MAX 3

var/list/ANDROID_CORE_CHOICES = list(
	"Eternal - recovers energy without meditating and tires slowly, with less Force at first" = ANDROID_CORE_ETERNAL,
	"Absorption - starts with Energy Drain and drinks energy blasts from the front from ascension 1, but recovers slowly" = ANDROID_CORE_ABSORPTION,
	"Bio - gathers genetic samples from other races on the road to a Perfect Form" = ANDROID_CORE_BIO)

mob/var/AndroidCore
mob/var/android_core_absorb = 0

passiveInfo/EnergyAbsorb
	setLines()
		lines = list("Energy blasts and beams without an element that hit you from the front feed your frame instead of hurting it: you gain Energy equal to 10% of the hit per level. Spells with an element, Strength-based throws and ballistic gun rounds are not absorbed.")

mob/AndroidCorePick()
	while(client && !AndroidCore)
		var/pick = Ask(src, "Choose the Core your frame is built around.", "Android Core", null, "pick", ANDROID_CORE_CHOICES, 0)
		var/core = pick ? ANDROID_CORE_CHOICES[pick] : null
		if(core)
			AndroidCoreApply(core)
		else
			sleep(1)

mob/AndroidCoreLogin()
	if(!race || !isRace(ANDROID))
		return
	if(!AndroidCore)
		AndroidCoreApply(ANDROID_CORE_ETERNAL)
		world.log << "\[android core] [key] ([name]) logged in with no Core; set to [ANDROID_CORE_ETERNAL]."
	AndroidCoreSync()
	BioPerfectSync()

mob/AndroidCoreSync()
	if(!passive_handler)
		return
	var/want = AndroidCoreAbsorbWant()
	var/delta = want - android_core_absorb
	if(!delta)
		return
	if(delta > 0)
		passive_handler.Increase("EnergyAbsorb", delta)
	else
		passive_handler.Decrease("EnergyAbsorb", -delta)
	android_core_absorb = want

mob/proc/AndroidCoreApply(core)
	if(!(core in list(ANDROID_CORE_ETERNAL, ANDROID_CORE_ABSORPTION, ANDROID_CORE_BIO)))
		return 0
	AndroidCore = core
	if(core == ANDROID_CORE_ABSORPTION)
		AndroidCoreGrant(/obj/Skills/Grapple/Energy_Drain)
	if(core == ANDROID_CORE_BIO)
		BioAndroid = 1
		AndroidCoreGrant(/obj/Skills/Utility/Collect_Sample)
		AndroidCoreGrant(/obj/Skills/Utility/Force_Extract)
		AndroidCoreGrant(/obj/Skills/Utility/Bio_Augmentation)
		BioPerfectSync()
	AndroidCoreSync()
	SetCyberCancel()
	return 1

mob/proc/AndroidCoreGrant(path)
	if(!(locate(path) in src))
		AddSkill(new path)

mob/proc/AndroidCoreAsc()
	return clamp(AscensionsAcquired, 0, ANDROID_CORE_ASC_MAX)

mob/proc/AndroidCoreAbsorbWant()
	if(AndroidCore != ANDROID_CORE_ABSORPTION || !race || !isRace(ANDROID))
		return 0
	return min(AndroidCoreAsc(), ANDROID_ABSORB_MAX)

mob/proc/AndroidEternalRegenMult()
	return ANDROID_ETERNAL_REGEN_BASE + ANDROID_ETERNAL_REGEN_PER_ASC * AndroidCoreAsc()

mob/proc/AndroidEternalForceMult()
	return min(1, ANDROID_ETERNAL_FORCE_BASE + ANDROID_ETERNAL_FORCE_PER_ASC * AndroidCoreAsc())

mob/Available_Power()
	. = ..()
	if(AndroidCore == ANDROID_CORE_ETERNAL && !KO && icon_state != "Meditate" && GetPowerUpRatio() <= 1)
		Recover("Energy", AndroidEternalRegenMult() * getEnergyRegenRate())

mob/Recover(blah, Amount = 1)
	if(blah == "Energy" && AndroidCore == ANDROID_CORE_ABSORPTION)
		Amount *= ANDROID_ABSORB_REGEN_MULT
	return ..(blah, Amount)

mob/GainFatigue(val)
	if(AndroidCore == ANDROID_CORE_ETERNAL)
		val *= ANDROID_ETERNAL_FATIGUE_MULT
	return ..(val)

mob/GetFor(Mult = 1)
	if(AndroidCore == ANDROID_CORE_ETERNAL)
		Mult *= AndroidEternalForceMult()
	return ..(Mult)

race/android/onChangeOut(mob/user)
	..()
	if(user)
		user.AndroidCore = null
		user.AndroidCoreSync()
