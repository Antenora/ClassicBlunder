SoldierTracker// i don't think this object is even necessary. it can literally be a tmp list in the mob
    var/list/monkeySoldiers = list()
/mob/var/tmp/SoldierTracker/MonkeySoldiers = new()


/mob/proc/summonMonkeySoldier(dmg, tier)
    if(length(MonkeySoldiers.monkeySoldiers) < tier)
        MonkeySoldiers.monkeySoldiers += new/mob/MonkeySoldier(src, dmg, tier * 75)
        blobLoop += MonkeySoldiers.monkeySoldiers[length(MonkeySoldiers.monkeySoldiers)]

/mob/MonkeySoldier
    var/damageValue
    var/timeLimit
    var/distanceLimit = 30
    var/spawnTime
    var/lastAttack
    var/attackDelay = 15
    var/tmp/mob/owner;
    var/tmp/mob/target;
    New(mob/p, dmg, timer)
        owner = p
        damageValue = clamp(dmg / 2, 0.01,1)
        timeLimit = timer
        lastAttack = 0
        attackDelay = 10
        SetTarget(p.Target)
        spawnTime = world.time
        icon = p.icon
        x = p.x
        y = p.y
        z = p.z
        appearance = new/mutable_appearance(p)
        alpha = 155
    Update()
        if(src.owner)
            src.setTargetToOwners();
        else
            src.EndMonkey();//If there is no owner, instantly die
        if(InstantKillCriteria())
            src.EndMonkey(owner);
        if(src && src.TimeToAttack())
            src.FlickAttack();

    proc
        setTargetToOwners()
            if(src.owner && src.owner.Target) src.target = src.owner.Target;// it should have an owner at this point, but we make sure

        InstantKillCriteria()
            . = 0;
            if(!src.owner) return 1;// shouldn't ever be true at this point, but might as well
            if(world.time > src.spawnTime + src.timeLimit) return 1; //if time is up, kill
            if(!src.target) return 1; //if there is no target, kill (convenience)
            if(get_dist(src.target, src) > src.distanceLimit) return 1; //if the target is too far away, kill
    
        TimeToAttack()
            if(!src) return 0;//If it died in this iteration, ignore
            if(src.lastAttack + src.attackDelay < world.time)
                return 1;
            return 0;

        FlickAttack()
            src.lastAttack = world.time
            flick("Attack", src)
            if(src.owner) src.owner.HitEffect(Target, 0, 1)//should definitely have an owner, but making sure
            src.target.LoseHealth(src.damageValue)

        EndMonkey(mob/m=null)
            if(m) m.MonkeySoldiers.monkeySoldiers.Remove(src);
            blobLoop.Remove(src);
            del(src);


/obj/Skills/Buffs/SlotlessBuffs
    Marlon_Anti_Job_Buff
        DefMult = 3
        EndMult = 3
        StrMult = 3
        ForMult = 3
        SpdMult = 3
        OffMult = 3
        passives = list("BackTrack" = 1, "Flow" = 1, "Instinct" = 1, "GodKi" = 1, "NoWhiff" = 1, "NoMiss" = 1, "MonkeyKing" = 4)
        FlashChange=1
        HairLock=1
        AuraLock='BLANK.dmi'
        IconLock='UltraInstinct.dmi'
        IconUnder=1
        LockX=-18
        LockY=-21
        TopOverlayLock='UltraInstinctSpark.dmi'
        IconTint=list(1,0.15,0.15, 0.15,1,0.15, 0,0,1, 0,0,0)
        adjust(mob/p)
            passives = list("BackTrack" = clamp(round(p.Potential/10), 1,10), "Flow" = clamp(round(p.Potential/10), 1,10), "Instinct" = clamp(round(p.Potential/10), 1,10), "GodKi" = 1, "NoWhiff" = 1, "NoMiss" = 1)
        verb/Anti_Job()
            set category = "Skills"
            set name = "Anti Job Mode"
            adjust(usr)
            src.Trigger(usr)
    TestBuff1
        MonkeyKing = 2
        Cooldown = 5
        verb/TestBuff1()
            set category = "Skills"
            set name = "Test Buff 1"
            src.Trigger(usr)