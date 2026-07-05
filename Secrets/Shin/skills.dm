obj/Skills/Queue/Heavy_Strike/proc/ShinHeavyStrike(mob/m) // This is called in QueueX (FUCK MY STUPID CHUD LIFE)
    src.name="Shin Strike"
    src.DamageMult=2
    src.AccuracyMult=1
    Duration=10
    src.KBAdd=5
    src.KBMult=3
    src.Cooldown=30
    src.ActiveMessage="channels Shin into their next strike."
    src.HitMessage="delivers a blow radiating with power!"
    src.Ooze = 0
    src.CursedWounds=0
    src.Scorching=0
    src.Freezing=0
    src.Paralyzing=0
    src.Shattering=0
    src.Toxic=0
    src.Combo=0
    src.Warp=0
    src.Rapid=0
    src.LifeSteal=0
    src.Crippling=0
    src.Grapple=0
    src.ManaGain= clamp(m.ShinSecretLevel()*5, 10, 30) // Tier 1/2= 10 tier 3 = 15, Tier 4 = 20 Tier 5 = 25 tier 6 = 30
    Dunker = 0
    Launcher = 0
    PushOutWaves = 0
    PushOut = 0
    return

obj/Skills/Queue/Heavy_Strike/proc/MangHeavyStrike(mob/m) // This is also called in QueueX
    src.name="Mang Strike"
    src.DamageMult=clamp(m.GetMangLevel()*3, 6, 15) // yeah this is gonna get out of hand real fucking fast
    src.AccuracyMult=1
    Duration=10
    src.KBAdd=5
    src.KBMult=3
    src.Cooldown=30
    src.ActiveMessage="concentrates their mang."
    src.HitMessage="strikes with the power of [m.GetMangLevel()] Mang."
    src.Ooze = 0
    src.CursedWounds=0
    src.Scorching=0
    src.Freezing=0
    src.Paralyzing=0
    src.Shattering=0
    src.Toxic=0
    src.Combo=0
    src.Warp=0
    src.Rapid=0
    src.LifeSteal=0
    src.Crippling=0
    src.Grapple=0
    src.ManaGain=0
    Dunker = 0
    Launcher = 0
    PushOutWaves = 0
    PushOut = 0
    NoWhiff = 1
    NoDodge = 1
    return