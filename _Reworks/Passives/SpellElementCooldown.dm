// Per-element spell cooldown reduction passives.
// Each basic T2 (Form/Technique/Guard/Footed), each basic T3 pinnacle
// (Alight/Awash/Aerde/Aloft) and each advanced pinnacle (Mender/Survivor/
// Future/Kinematics) mage_passive binds a single decimal reduction into the
// matching <Element>SpellCooldown key. The hook in _1CodeFolder/Skills_.dm
// reads the value via getSpellElementCooldownReduction and applies it as a
// multiplier on the modify value inside the Cooldown() proc:
// modify *= (1 - reduction), which then flows into the final
// Time = src.Cooldown * 10 * modify * (...) calc.
//
// Stored value is a cumulative decimal reduction (e.g. 0.10 = 10% shorter cd).
// T2 and T3 basics bind the same key so unlocking both ScorchedForm and Alight
// on a Fire mage stacks to 0.20 (-20% cd on Fire spells), matching the doc
// spec of "-10% to -20% cd" for a full basic-element vertical. Clamped at
// 0.90 inside the lookup to prevent any future combination from producing
// instant or negative cooldowns.

passiveInfo/FireSpellCooldown
    setLines()
        lines = list("Reduces the cooldown of every Fire spell you cast.",\
"Stored as a decimal reduction, applied as a multiplier on top of the spell's base cooldown.");

passiveInfo/WaterSpellCooldown
    setLines()
        lines = list("Reduces the cooldown of every Water spell you cast.",\
"Stored as a decimal reduction, applied as a multiplier on top of the spell's base cooldown.");

passiveInfo/EarthSpellCooldown
    setLines()
        lines = list("Reduces the cooldown of every Earth spell you cast.",\
"Stored as a decimal reduction, applied as a multiplier on top of the spell's base cooldown.");

passiveInfo/AirSpellCooldown
    setLines()
        lines = list("Reduces the cooldown of every Wind spell you cast.",\
"Stored as a decimal reduction, applied as a multiplier on top of the spell's base cooldown.");

passiveInfo/LightSpellCooldown
    setLines()
        lines = list("Reduces the cooldown of every Light spell you cast.",\
"Stored as a decimal reduction, applied as a multiplier on top of the spell's base cooldown.");

passiveInfo/DarkSpellCooldown
    setLines()
        lines = list("Reduces the cooldown of every Dark spell you cast.",\
"Stored as a decimal reduction, applied as a multiplier on top of the spell's base cooldown.");

passiveInfo/TimeSpellCooldown
    setLines()
        lines = list("Reduces the cooldown of every Time spell you cast.",\
"Stored as a decimal reduction, applied as a multiplier on top of the spell's base cooldown.");

passiveInfo/SpaceSpellCooldown
    setLines()
        lines = list("Reduces the cooldown of every Space spell you cast.",\
"Stored as a decimal reduction, applied as a multiplier on top of the spell's base cooldown.");

mob/proc/
    getSpellElementCooldownReduction(element)
        // Returns the cumulative decimal cooldown reduction for spells of the
        // given element. 0 means no reduction. Callers should apply this as
        // modify *= (1 - reduction). Safe to call with a null/empty element.
        // Clamped at 0.90 to prevent any future stacking from producing a
        // zero or negative cooldown on element spells.
        . = 0
        if(!element) return 0
        var/value = passive_handler.Get("[element]SpellCooldown")
        if(!value) return 0
        if(value > 0.90)
            value = 0.90
        . = value
