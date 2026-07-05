

mob/Player/AI/proc/aiGain()
    set waitfor = 0
    var/mob/owner = ai_owner

    if(owner)
        // lets just have 2 different gain looks for ai owner functions and not
        if(owner.PureRPMode)
            return
        WoundIntent = owner.WoundIntent
        Lethal = owner.Lethal
    if(world.time >= last_powercheck+300)
        AIAvailablePower()
        last_powercheck=world.time
    if(KO)
        if(icon_state != "KO")
            icon_state = "KO"
        if(ko_death)
            Death(null, "dies suddenly!")
            return
    if(MovementCharges < GetMaxMovementCharges())
        MovementChargeBuildUp()
    Energy+=rand(0,3)

    // MOVE power avalible to update? i dont think its causing lag, its a simple proc (?)
    // given eery mob procs it, but only when pot is different...

    // Move meditating to Rest proc vs in update

    if(Health < 10 && !HealthAnnounce10)
        HealthAnnounce10 = 1
        OMessage(10, "[src] is barely standing!" )

    // move calm to rest proc vs in update

    // ai dont grab so ignore it

    // Stasis just stops u from doing things, i don't think its even needed

    if(Dead)
        // what the hell?
        Savable = 0
        animate(src, alpha=0, time=3, easing = ELASTIC_EASING)
        loc = null // should del it
        if(src)
            del src // this is stupid, but i think it has other refs and as such won't get deelted
        return
    //TODO find where actual death happens and clean del it there

    if(KOTimer)
        if(KOTimer--<=0)
            Conscious()

    // TODO move this to a proc that ticks everything down

    // im not adding beams, ai will not beam, idc

    Debuffs()

    scrollSlotless()
    // ai unironically dont dran anything on buffs so just ignore it too


    MaxHealth()
    MaxEnergy()
    MaxMana()
    MaxOxygen()
    var/turf/Q=src.loc
    if(!src.loc)
        EndLife(0)
        return // strange
    if(isturf(Q))
        if(!Flying)
            var/grabbed

            for(var/mob/P in range(1,src))
            //TODO surely we can make a is grabbed check or something vs doing it this way
                if(P.Grab==src)
                    grabbed = 1
                    break
            if(passive_handler.Get("Skimming") || is_dashing || src.Flying || src.HasWaterWalk() || src.HasGodspeed() >= 2)
                grabbed=1
                if(Swim)
                    Swim=0
                    RemoveWaterOverlay()
            if(!grabbed)
                if(Q.Deluged||istype(Q,/turf/Waters)||istype(Q,/turf/Special/Ichor_Water)||istype(Q,/turf/Special/Midgar_Ichor))
                    if(Swim==0)
                        src.RemoveWaterOverlay()
                        spawn()
                            if(Q.Deluged)
                                src.overlays+=image('WaterOverlay.dmi',"Deluged")
                            else if(Q.type==/turf/Waters/Water7/LavaTile)
                                src.overlays+=image('LavaTileOverlay.dmi')
                            else
                                src.overlays+=image('WaterOverlay.dmi',"[Q.icon_state]")
                    Swim=1
                    if(!src.KO)
                        var/amounttaken=1
                        if(amounttaken<0)
                            amounttaken=0
                        if(Q.Shallow==1)
                            amounttaken=0
                        if(Q.Deluged==1)
                            amounttaken=4
                        if(isRace(MAJIN)||isRace(DRAGON)||passive_handler.Get("SpaceWalk")||passive_handler.Get("Fishman")||src.FusionPowered)
                            amounttaken=0
                        src.Oxygen-=amounttaken
                        if(src.Oxygen<0)
                            src.Oxygen=0
                        if(src.Oxygen<10)
                            src.LoseEnergy(5)
                            if(src.TotalFatigue>=95)
                                src.Unconscious(null,"fatigue due to swimming! They will drown if not rescued!")
            else
                if(Swim==1)
                    src.RemoveWaterOverlay()
                    Swim=0


mob/Player/AI/proc/scrollSlotless()
    for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/A in src)
        if(!A.SlotlessOn)
            if(A.NeedsHealth && !A.Using && !KO)
                if(Health<=A.NeedsHealth*(1-HealthCut))
                    A.Trigger(src)
            if(A.AlwaysOn)
                if(!A.Using)
                    A.Trigger(src)
        else
            if(A.TooMuchHealth)
                if(Health>A.TooMuchHealth)
                    A.Trigger(src)
            if(KO)
                A.Trigger(src, Override=1)




mob/Player/AI/proc/DecrementTicker()
    if(KOTimer)
        if(KOTimer--<=0)
            Conscious()
    if(Harden)
        if(Harden--<=0)
            Harden = 0
    // ai dont need countermaster

    if(SureHitTimerLimit)
        if(!SureHit)
            SureHitTimer--
            if(SureHitTimer<=0)
                SureHit = 0
                SureHitTimer = SureHitTimerLimit

    if(SureDodgeTimerLimit)
        if(!SureDodge)
            SureDodgeTimer--
            if(SureDodgeTimer<=0)
                SureDodge = 0
                SureDodgeTimer = SureDodgeTimerLimit





    // ai dont use styles so ignore that

    // ai unironically dont dran anything on buffs so just ignore it too