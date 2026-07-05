/obj/Skills/Buffs/SpecialBuffs
	SpecialSlot=1
	Banish_The_ANGELS_HEAVEN
		passives = list("HolyMod" = 30, "SpiritPower" = 5, "EndlessNine" = 3.85, "Shatter Fate"=1, "MovementMastery"=20)
		ActiveMessage="puts pen to paper, undoing the influence of the Gods."
		HealthCut=0.9
		verb/Banish_The_ANGELS_HEAVEN()
			set category="Skills"
			src.Trigger(usr)
		//	if(src.Using)
	Shatter_The_Glass_Of_Fate
		passives = list("DisableGodKi" = 1, "Deicide" = 10, "EndlessNine" = 5, "CallousedHands" = 0.5, "Shatter Fate"=1, "MovementMastery"=20)
		ActiveMessage="focuses the power to change reality within their axe, as the glass of fate shatters..."
		HealthCut=0.9
		verb/Shatter_The_Glass_Of_Fate()
			set category="Skills"
			src.Trigger(usr)
	//		if(src.Using)

	Blanket_The_World_In_Darkness
		passives = list("Heart of Darkness" = 1, "The Roaring" = 1,"HolyMod" = 30, "AbyssMod" = 30, "SpiritPower" = 5)
		verb/Blanket_The_World_In_Darkness()
			set category="Skills"
			if(!usr.BuffOn(src))
				DarknessFlash(usr, SetTime=600)
				world<<"<b>An ocean of black ink washes across the world.</b>"
			src.Trigger(usr)
	Sing_Her_Blessed_Song
		HealthCut=0.9
	All_Hail_The_Crownless_King
		FINISHINGMOVE=1
		StrTax=0.25
		ForTax=0.25
		EndTax=0.25
		SpdTax=0.25
		OffTax=0.25
		DefTax=0.25
		RecovTax=0.25
		ManaDrain=0.25
		FatigueDrain=0.25
		SpecialSlot=0
		Slotless=1
		Cooldown=-1
		passives= list("The Crownless King" = 1, "FatigueLeak" = 3, "ManaLeak" = 3)
		ActiveMessage="becomes a Legendary Fighter with no equal!<font color=#00FFFF> <b>You feel like you are in for a Bad Time...</b>"
		verb/All_Hail_The_Crownless_King()
			set category="Skills"
			set name= "Hail to the King(Final Act)"
			src.Trigger(usr)
	Glory_To_The_Comeback_King
		Cooldown = -1
		FINISHINGMOVE=1
		StrTax=0.1
		EndTax=0.1
		ForTax=0.1
		ActiveMessage="becomes the personification of defiance itself! <font color=red> <b>Nothing will stand between them and victory!!!</b></font>"
		passives = list("The Comeback King" = 1)
		verb/Glory_To_The_King()
			set category="Skills"
			set name= "Glory To The King (Final Act)"
			src.Trigger(usr)
obj/Skills/Buffs/SlotlessBuffs
	Burning_Soul
		ActiveMessage="transforms their passion into fury, their desire to win surpassing all."
		Cooldown = -1
		TimerLimit=300
		StrTax=0.1
		EndTax=0.1
		ForTax=0.1
		NeedsHealth=25
		ActNumber=3
		passives = list("Red Hot Rage" = 1, "Wrathful" = 1)
		verb/Burning_Soul()
			set category="Skills"
			if(!src.Using)
				usr.TriggerAwakeningSkill(ActNumber)
				usr<<"Your unsurpassed passion has reset your cooldowns!"
				for(var/obj/Skills/s in usr)
					s.cooldown_remaining=0
					s.cooldown_start=0
			src.Trigger(usr)
	The_Blue_Experience
		ActiveMessage="burns brighter than they should."
		Cooldown = -1
		SpdMult=1.5
		StrMult=1.5
		ForMult=1.5
		Cooldown = 1
		TimerLimit=300
		HealthDrain = 0.05
		NeedsHealth=50
		passives = list("BuffMastery" = 3,"Pursuer" =2, "Godspeed"=2)
		ActNumber=2
		verb/The_Blue_Experience()
			set category="Skills"
			set name="The Blue Experience (Act 2)"
			usr.TriggerAwakeningSkill(ActNumber)
			src.Trigger(usr)