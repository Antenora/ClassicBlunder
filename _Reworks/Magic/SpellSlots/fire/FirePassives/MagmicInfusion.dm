/obj/Skills/var
    MagmicInfusion=0;//this will TRIGGER magmic buff 

/obj/Skills/proc/hasMagmicInfusion(mob/p)
    if(MagmicInfusion) p.MagmicShieldOn();

/mob/proc/hasMagmicShield()
    if(passive_handler.Get("Magmic")) return 1;
    return 0;
/mob/proc/MagmicShieldOn()
    var/obj/Skills/Buffs/magShield = findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Magmic_Shield);
    if(!magShield.Using && !SlotlessBuffs["[magShield.name]"]) magShield.Trigger(src, 1);
/mob/proc/MagmicShieldOff()
    var/obj/Skills/Buffs/magShield = findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Magmic_Shield);
    if(magShield.Using && SlotlessBuffs["[magShield.name]"]) magShield.Trigger(src, 1);

/obj/Skills/Buffs/SlotlessBuffs/Magmic_Shield
    passives = list("PureReduction"=2, "Scorching"=2, "Deflection"=2, "Reversal"=0.2)
    //passives = list("Magmic" = 1)//this used to stun the opponent for 3 seconds when they are struck
    Cooldown = 50
    TimerLimit = 10
    BuffName = "Magmic Shield"
    name = "Magmic Shield"
    ActiveMessage = "conjures a magmic shield!"
    OffMessage = "extinguishes the shield..."
    TextColor="#cc3333";
    IconLock = 'Magmic Shield.dmi';
    
    //no active trigger anymore