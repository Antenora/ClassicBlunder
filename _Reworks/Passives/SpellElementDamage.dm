// Per-element spell damage bonus passives.
// Each pinnacle mage_passive (Alight/Awash/Aerde/Aloft for the basic elements,
// Mender/Survivor/Future/Kinematics for the advanced elements) binds a single
// numeric bonus into the matching <Element>SpellDamage key. The hook in
// _AutoHitX.dm and _ProjectileX.dm reads the value via getSpellElementDamageBonus
// and applies it as a multiplier on top of the calculated atk for any spell
// (an autohitter or projectile whose SpellElement is set).
//
// The stored value is the cumulative decimal bonus (e.g. 0.10 = +10% damage).
// Selecting the same pinnacle on two nodes adds the bind a second time, so
// two ticks of Alight = 0.20 = +20% damage on Fire spells.

mob/proc/
    getSpellElementDamageBonus(element)
        // Returns the cumulative decimal damage bonus for spells of the
        // given element. 0 means no bonus. Callers should apply this as
        // atk *= (1 + bonus). Safe to call with a null/empty element.
        // Clamped at 1.0 (+100% max) to prevent any future stacking from
        // producing extreme damage multipliers on element spells.
        . = 0
        if(!element) return 0
        var/prefix = "[element]"
        if(element == "Wind")
            prefix = "Air"
        var/value = passive_handler.Get("[prefix] Magic Mastery")/glob.CASTING_PASSIVE_DIVISOR
        if(!value) return 0
        if(value > 1.0)
            value = 1.0
        . = value
