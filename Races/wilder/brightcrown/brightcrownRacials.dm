/mob/proc/isBrightcrown()
    if(!isRace(WILDER)) return 0;
    if(Class != "Brightcrown") return 0;
    return 1;

/mob/proc/preForm()
    if(SlotlessBuffs["Pheonix Form"] || SlotlessBuffs["Ram Form"] || SlotlessBuffs["Bear Form"] || SlotlessBuffs["Turtle Form"])
        for(var/index in SlotlessBuffs)
            if(istype(SlotlessBuffs[index], /obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Spirit_Walker))
                SlotlessBuffs[index].Trigger(src, TRUE)


/obj/Skills/AutoHit/Crown_Radiation//called by swapping into phoenix form
    Area="Circle"
    ElementalClass="Light"
    AdaptRate=1
    Rounds=1
    TurfDirt=1
    TurfErupt=1
    ShockIcon='KenShockwave.dmi'
    Shockwave=4
    Shockwaves=1
    PostShockwave=1
    PreShockwave=0
    Earthshaking=20
    Instinct=1
    ComboMaster = 1
    Distance = 8;
    DamageMult = 1;
    BuffAffected ="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Blinded_by_the_Light"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Blinded_by_the_Light//but not literally
    NeedsPassword = 1
    Cooldown = 4
    AlwaysOn = 1
    CrippleAffected = 3.5;//should generate around 20 cripple over its duration, unmodified
    StrMult = 0.8
    ForMult = 0.8
    OffMult = 0.5
    passives = list("FatigueLeak" = 1, "PureDamage" = -2)
    TimerLimit = 6;

/obj/Skills/Buffs/SlotlessBuffs/Wilder/BrightcrownStance
    TimerLimit = 15;
    Cooldown = 90;
    adjust(mob/p)
        var/asc = p.AscensionsAcquired;
        ElementalOffense = "Light";
        endAdd = (0.5 + (1/3*asc) / 2);
        spdAdd = (0.5 + (1/3*asc) / 2);
        offAdd = (0.5 + (1/3*asc) / 2);
        defAdd = (0.5 + (1/3*asc) / 2);
        passives = list("Wrathful Tenacity" = 0.25, "HardenedFrame" = 1);
        passives["HolyMod"] = 0.2 + (asc * 0.1);
        passives["CallousedFeet"] = 2 + asc;
        passives["SoftStyle"] = asc;
        TimerLimit = 15 + (asc * 5);

/obj/Skills/Buffs/SlotlessBuffs/Wilder/BrightcrownStance/Pheonix_Form//extended attacks, disables hardened frame so that spirit strike can be used instead
    FollowUp = "/obj/Skills/AutoHit/Crown_Radiation";//triggers light dragon roar
    passives = list("Scorching" = 5, "SweepingStrike" = 1, "Extend" = 1, "Gum Gum" = 1, "HardenedFrame" = -1, "SpiritStrike" = 1);
    endAdd = -0.5;
    strAdd = -0.5;
    forAdd = 1;
    defAdd = 1;
    ActiveMessage = "takes up the radiance of the Phoenix!"
    verb/Pheonix_Form()//these will be modified once the official Style Switching verb is implemented
        set category = "Stances"
        usr.preForm()
        if(!usr.BuffOn(src)) adjust(usr);
        Trigger(usr)

/obj/Skills/AutoHit/Dragon_Whirlwind//called rfom using Dragon Form
    NoAttackLock = 1;
    Rounds = 4;
    DamageMult = 1.5;
    AdaptRate = 1;
    Area = "Circle"
    Size=4;
    Distance = 4;
    Icon='SweepingKick.dmi'
    IconX=-32
    IconY=-32
    FlickSpin=1
    Cooldown = 15;

/obj/Skills/Buffs/SlotlessBuffs/Wilder/BrightcrownStance/Dragon_Form//stunning strikes and combomaster. god save me
    FollowUp = "/obj/Skills/AutoHit/Dragon_Whirlwind";
    strAdd = -0.25;
    endAdd = -0.25;
    forAdd = -0.25;
    spdAdd = 0.5;
    offAdd = 1;
    defAdd = 1;
    passives = list("StunningStrike" = 3, "ComboMaster" = 1, "TechniqueMastery" = 3, "Flow" = 2);
    ActiveMessage = "takes up the technique of the Dragon!"
    verb/Ram_Form()
        set category = "Stances"
        usr.preForm()
        if(!usr.BuffOn(src)) adjust(usr);
        Trigger(usr)

/obj/Skills/Buffs/SlotlessBuffs/Wilder/BrightcrownStance/Tiger_Form
    strAdd = 0.25
    defAdd = -0.5
    forAdd = 0.25
    ActiveMessage = "takes up the ferocity of the Tiger!"
    adjust(mob/p)
        var/asc = p.AscensionsAcquired
        passives = list("Godspeed" = 1 + (asc/2), "BlurringStrikes" = clamp(asc/4, 0.25, 1))
        Cooldown = 90 - (10 *p.AscensionsAcquired)
        TimerLimit = 30 + (6 *p.AscensionsAcquired)
    verb/Bear_Form()
        set category = "Stances"
        usr.preForm()
        if(!usr.BuffOn(src)) adjust(usr);
        Trigger(usr)

/obj/Skills/Buffs/SlotlessBuffs/Wilder/BrightcrownStance/Tortoise_Form
    endAdd = 0.5
    defAdd = -0.5
    ActiveMessage = "takes up the determination of the Tortoise!"
    adjust(mob/p)
        var/asc = p.AscensionsAcquired
        passives = list("Harden" = 2 + asc/2,  "HardenedFrame" = 1, "DeathField" = 2+asc*2, "Brutalize" = 0.5 + (asc/2))
        Cooldown = 90 - (10 *p.AscensionsAcquired)
        TimerLimit = 30 + (6 *p.AscensionsAcquired)
    verb/Turtle_Form()
        set category = "Stances"
        usr.preForm()
        if(!usr.BuffOn(src)) adjust(usr);
        Trigger(usr)


/mob/var/tmp/last_nimbus = -100
/mob/var/nimbus_message = "player_name rides a cloud towards target_name!"
/mob/proc/change_nimbus_message()
    var/inP = input(src, "Use player_name and target_name to swap out for those names.") as text | null
    if(inP >= glob.MAXCATCHLINELENGTH+10 || inP == "" || !inP)
        src << " no too long " 
    else
        nimbus_message = inP

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Wilder
    Nimbus_Rider
        BuffName="Nimbus Rider"
        IconLock='Flying Nimbus.dmi'
        LockY=-10
        UnrestrictedBuff=1
        Steady=1
        passives = list("BlurringStrikes" = 1, "Steady" = 1, "Brutalize" = 0.5)
        TimerLimit=5
        Cooldown=10
        adjust(mob/p)
            if(altered) return
            Steady=p.AscensionsAcquired
            TimerLimit=1+(3*p.AscensionsAcquired)
            passives = list("BlurringStrikes" = p.passive_handler["Nimbus"], "Steady" = p.passive_handler["Nimbus"], "Brutalize" = (p.passive_handler["Nimbus"]/2))

/datum/BuffTrigger
    NeverFall
        trigger = "/obj/Skills/AutoHit/MonkeyKingWhirlwind"
        trigger_when = "EqualOrMore"
        trigger_at = 50
        trigger_ref = "AbsorbingDamage"
        set_to = 1

        init(mob/p, obj/Skills/Buffs/SlotlessBuffs/b)
            if(p)
                parent_buff = b
                owner = p
                trigger_at = 50 - (p.AscensionsAcquired * 5)
                reference_this = p // likely good to make this a .vars otherwise or some sort of list to refernce vars


/obj/Skills/Buffs/SlotlessBuffs/Autonomous
    var/datum/BuffTrigger/Triggers = null

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Beastkin
    Never_Fall
        AlwaysOn = 1
        doNotDelete = 1
        passives = list("AbsorbingDamage" = 1)
        Trigger(mob/User, Override)
            if(!Triggers)
                Triggers = new/datum/BuffTrigger/NeverFall(User, src)
            ..()

/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin
	Monkey_Gourd
		BuffName="Monkey Gourd"
		UnrestrictedBuff=1
		Cooldown=1
		CooldownStatic=1
		TimerLimit=1
		ActiveMessage = "takes a sip from their trusty gourd."
		HealthHeal = 9 //for some reason 3 healed only 1%???
		StableHeal = 1 // don't take recov into account
		EnergyHeal = 25
		var/monkeyUsed = 0
		var/monkeyUsageMax = 1
		adjust(mob/p)
			monkeyUsageMax = p.AscensionsAcquired
		verb/Monkey_Gourd()
			set category="Skills"
			adjust(usr)
			if(!usr.CheckSlotless("Monkey Gourd"))
				if(monkeyUsed < monkeyUsageMax)
					src.Trigger(usr)
					monkeyUsed++
				else
					usr << "Your gourd is empty."



/obj/Skills/Projectile/Consuming_Light
    StrRate=0.5
    EndRate=1.5
    ForRate=0
    Distance=20
    Stream=1
    MultiHit=2
    Knockback=1
    Striking=1
    Delay=1
    IconLock='AvalonLight.dmi'
    Variation=24
    adjust(mob/p)
        var/asc = p.AscensionsAcquired;
        Blasts = 5 + asc
        DamageMult = 3 + (asc * 1.5)
        Radius = clamp(asc, 1, 5)
        Silencing = 5 + clamp(asc*2, 1, 8)
        DamageMult = DamageMult / Blasts
        Cooldown = 60 - ( 5 * asc)
    verb/Consuming_Light()
        set category="Skills"
        if(!altered) adjust(usr);
        usr.UseProjectile(src)