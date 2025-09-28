/obj/Skills/AutoHit/Counter
    UnarmedOnly=1
    FlickAttack=1
    Area="Strike"
    StrOffense=1
    DamageMult=1.5
    EndDefense=0.75
    Rush=1
    ControlledRush=1
    Knockback=0
    Quaking=1
    PreShockwave=1
    PreShockwaveDelay=1
    PostShockwave=0
    Shockwaves=1
    Shockwave=0.5
    ShockIcon='KenShockwaveFocus.dmi'
    ShockBlend=2
    ShockDiminish=1.15
    ShockTime=4
    ActiveMessage="counters the incoming attack!"
    adjust(mob/p, stacks)
        DamageMult = 1.5 + (0.5 * stacks)
        Crippling = 15 * stacks

