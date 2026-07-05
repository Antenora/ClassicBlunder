//Technically not part of the Ultra Instinct Secret but I put it here for ease of comparison.
//Ultra Ego is meant to be easier to master once obtained, so it only has a T3 and T4 version.
//Ultra Ego is meant to be compatible with Power of Destruction, which is why I didn't want to make too many of the passives overlap.
//I intended to make it the Yin to Ultra Instinct's Yang. So I just replaced the stats and passives of the T3 and T4 versiosn with ones that felt more... destruction-y.
//Some of the passives I picked are based off the fact that the Ultra Ego(Form) increased Vegeta's Power exponentionally the more damage he took.
//I am not sure if these numbers are at all balanced to be comparable to Ultra Instinct but that's kind of the bar that they are meant to clear.
//This is NOT meant to be unlocked without development, this is one of those stances that requires Admin Approval
// WIP, not yet included in the DME, so these styles should not be available i nthe current version.
/obj/Skills/Buffs/NuStyle/UltraEgoOmen
	Ultra_Instinct_Style
		Copyable = 0
		StyleActive = "Ultra Ego (Omen)"
		passives = list("Persistence" = 2, "HardStyle" = 1, "UnderDog" = 3, "Instinct" = 3, "Brutalize" = 2, "Godspeed" = 1,"PureDamage" = 4, "DemonicInfusion" = 1)
		StyleSpd = 1.5
		StyleOff = 1.5
		StyleStr = 1.5
		StyleForce = 1.5
		IconLock='GODAura.dmi'
		IconLockBlend=4
		LockX=-48
		LockY=-16
		SagaSignature = 1
		SignatureTechnique = 3
		Finisher="/obj/Skills/Queue/Finisher/Bauf_Burst" //This is a placeholder until I feel like coding a unique one for this style, so it has something other than the basic finisher.
		verb/UltraEgoOmen()
			set hidden = 1
			adjust(usr)
			src.Trigger(usr)

	Perfected_Ultra_Instinct_Style
		Copyable = 0
		StyleActive = "Perfected Ultra Ego"
		passives = list("Persistence" = 2, "HardStyle" = 2,"UnderDog" = 6, "Instinct" = 3, "Brutalize" = 3, "Godspeed" = 1,"PureDamage" = 5, "DemonicInfusion" = 1, "LikeWater" = 3, "PUSpike" = 25)
		StyleSpd = 1.6
		StyleStr = 1.55
		StyleOff = 1.6
		StyleFor = 1.55
		IconLock='GODAura.dmi'
		IconLockBlend=4
		LockX=-48
		LockY=-16
		SagaSignature = 1
		SignatureTechnique = 4
		Finisher="/obj/Skills/Queue/Finisher/Bauf_Burst" //This is a placeholder until I feel like coding a unique one for this style, so it has something other than the basic finisher.
		PUSpike = 25
		verb/PerfectedUltraEgo()
			set hidden = 1
			adjust(usr)
			src.Trigger(usr)
