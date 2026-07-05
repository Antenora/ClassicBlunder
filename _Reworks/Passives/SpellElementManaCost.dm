// Per-element spell mana cost reduction passives.
// Each Mastery T1 (basic) and each pinnacle T3 (advanced) mage_passive binds
// a single decimal reduction into the matching <Element>SpellManaCost key.
// The hook in _QueueX.dm and _AutoHitX.dm reads the value via
// getSpellElementManaCostReduction and applies it as a multiplier on the
// drain value: drain *= (1 - reduction). The existing drain <= 0 floor
// catches any over-reduction (clamped to 0.5 mana minimum).
//
// Stored value is a cumulative decimal reduction (e.g. 0.15 = 15% cheaper).
// Selecting the same Mastery on two nodes adds the bind a second time, so
// two ticks of BurnMastery = 0.30 = 30% cheaper Fire spells.

passiveInfo/FireSpellManaCost
    setLines()
        lines = list("Reduces the mana cost of every Fire spell you cast.",\
"Stored as a decimal reduction, applied as a multiplier on top of the spell's mana cost.");

passiveInfo/WaterSpellManaCost
    setLines()
        lines = list("Reduces the mana cost of every Water spell you cast.",\
"Stored as a decimal reduction, applied as a multiplier on top of the spell's mana cost.");

passiveInfo/EarthSpellManaCost
    setLines()
        lines = list("Reduces the mana cost of every Earth spell you cast.",\
"Stored as a decimal reduction, applied as a multiplier on top of the spell's mana cost.");

passiveInfo/AirSpellManaCost
    setLines()
        lines = list("Reduces the mana cost of every Wind spell you cast.",\
"Stored as a decimal reduction, applied as a multiplier on top of the spell's mana cost.");

passiveInfo/LightSpellManaCost
    setLines()
        lines = list("Reduces the mana cost of every Light spell you cast.",\
"Stored as a decimal reduction, applied as a multiplier on top of the spell's mana cost.");

passiveInfo/DarkSpellManaCost
    setLines()
        lines = list("Reduces the mana cost of every Dark spell you cast.",\
"Stored as a decimal reduction, applied as a multiplier on top of the spell's mana cost.");

passiveInfo/TimeSpellManaCost
    setLines()
        lines = list("Reduces the mana cost of every Time spell you cast.",\
"Stored as a decimal reduction, applied as a multiplier on top of the spell's mana cost.");

passiveInfo/SpaceSpellManaCost
    setLines()
        lines = list("Reduces the mana cost of every Space spell you cast.",\
"Stored as a decimal reduction, applied as a multiplier on top of the spell's mana cost.");

mob/proc/
    getSpellElementManaCostReduction(element)
        // Returns the cumulative decimal mana cost reduction for spells of the
        // given element. 0 means no reduction. Callers should apply this as
        // drain *= (1 - reduction). Safe to call with a null/empty element.
        // Clamped at 0.95 to prevent free spells (mana cost can never go below
        // 5% of base from this passive alone — the existing drain floor of 0.5
        // catches anything that slips past it).
        . = 0
        if(!element) return 0
        var/value = passive_handler.Get("[element]SpellManaCost")
        if(!value) return 0
        if(value > 0.95)
            value = 0.95
        . = value
