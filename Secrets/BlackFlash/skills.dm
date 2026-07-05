/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff
	BlackFlash_Potential
		BuffName = "120% Potential"
		Mastery=-1
		UnrestrictedBuff=1
		StrMult=1.20
		ForMult=1.20
		EndMult=1.20
		SpdMult=1.20
		DefMult=1.20
		MakesArmor=0
		TurfShift='WhiteTurfShift.dmi'
		TurfShiftInstant=1
		OffMult=1.20
		IconLock='CE Divergent Fist.dmi'
		TimerLimit=90
		passives = list("TechniqueMastery" = 5, "BuffMastery" = 2, "MovementMastery" = 5)
		DarkChange=1
		ActiveMessage="...!"
		OffMessage="cools down."
		adjust(mob/p)
			if(p.isBlackFlashFirstUse()) spawn() p.BlackFlashGlazing(src)
			else ActiveMessage = "gets in tune with their energy output, unlocking 120% of their potential!"

/obj/Skills/Buffs/SlotlessBuffs
	BlackFlash_SureStrike
		BuffName = "Sure-Strike Black Flash"
		Mastery=-1
		UnrestrictedBuff=1
		TimerLimit=5
		ActiveMessage="focuses and prepares to force a Black Flash!!!"
		passives = list("Sure-Strike Black Flash" = 1)
		Cooldown = 90
		verb/Black_Flash_SureStrike()
			set category="Skills"
			adjust(usr)
			src.Trigger(usr)

#define JJK_NARRATOR_COLOUR "#f7da1b"
/mob/proc/JJKNarrate(txt)
	OMessage(50, Msg = "<font color=[JJK_NARRATOR_COLOUR]>[txt]</font color>");

/mob/proc/BlackFlashGlazing(obj/Skills/Buffs/bfSkill)
	setBlackFlashFirstUse();
	JJKNarrate("It is not a technique you'd be able to see commonly. Not in these parts.");
	sleep(30)
	JJKNarrate("Most would simply use their energy to empower their whole body all at once- But this tends to cause a lag of sort, between your body and your energy.");
	sleep(30)
	JJKNarrate("This, inherently, lessen the impact your own energy has on your body. However...");
	sleep(30)
	JJKNarrate("If one was to infuse their energy, within one millionth of a second from a physical impact...");
	sleep(30)
	JJKNarrate("Space may distort for that moment- Energy sparking dark- And the destructive power of their attack raises to the power of two and a half.");
	sleep(30)
	JJKNarrate("A phenomenon known as a Black Flash. Following this, the user enters a state of awakening to their own energies-");
	sleep(30)
	JJKNarrate("Not too dissimilar to athletes entering 'The Zone', manipulating their power becomes as easy and natural as breathing.");
	if(prob(15))
		sleep(30)
		JJKNarrate("...displaying control over their power matched only by Satoru Gojo.");
	sleep(30)
	JJKNarrate("In other words... For one minute and thirty seconds...");
	sleep(30)
	JJKNarrate("<b>[src] fights at one hundred and twenty percent of their potential.</b>");


/mob/proc/
	getBlackFlashSecret()
		if(hasSecret("Black Flash")) return secretDatum;
		return 0;
	isBlackFlashFirstUse()
		var/SecretInformation/BlackFlash/bf = getBlackFlashSecret();
		if(bf) return bf.BlackFlashFirstTimeUse;
	setBlackFlashFirstUse()
		var/SecretInformation/BlackFlash/bf = getBlackFlashSecret();
		bf.BlackFlashFirstTimeUse=0;
	getBlackFlashChance()
		var/SecretInformation/BlackFlash/bf = getBlackFlashSecret();
		var/force = bf.BlackFlashForcedChance;
		var/sureStrike = passive_handler.Get("Sure-Strike Black Flash")
		if(bf.BlackFlashChance < bf.BlackFlashBaseChance)
			bf.BlackFlashChance = bf.BlackFlashBaseChance
		if(sureStrike == 1) return 100;
		if(force) return force;

		else
			bf.BlackFlashChance += 5
			return clamp(bf.BlackFlashChance-5, bf.BlackFlashBaseChance, 90);