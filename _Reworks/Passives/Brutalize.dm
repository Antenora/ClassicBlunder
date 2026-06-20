/mob/proc/GetBrutalize()
    if(ButouActive) return 0.9
    var/b = passive_handler.Get("Brutalize") //This stores stuff from sources of brutalize... yay.
    if(!b) return 0
    b += GetMangLevel()*0.5
    b += (scalingEldritchPower()*0.5);
    var/raw = b / 10 //legacy scaling
    // Brutalize now ignores endurance linearly up to a soft cap of 30%
    var/soft_cap = 0.3 // fraction of endurance ignored where diminishing returns kick in.
    var/hard_cap = 0.75 // self explanatory
    var/dr_scale = 1.5 // higher = harsher diminishing returns
    if(raw <= soft_cap)
        return clamp(raw, 0, soft_cap)
    var/excess = raw - soft_cap
    return clamp(soft_cap + (hard_cap - soft_cap) * (excess / (excess + dr_scale)), 0, hard_cap)
