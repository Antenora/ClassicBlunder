
proc/getFlowCalc(mob/a, mob/d)
    var/BASE_FLOW_PROB = glob.BASE_FLOW_PROB
    var/flow = d.GetFlow()
    var/instinct = a.HasInstinct()
    var/result = 0
    if(instinct)
        result = flow - instinct
    else
        result = flow
    var/backtrack = d.passive_handler.Get("BackTrack")
    return (BASE_FLOW_PROB*result) + glob.BASE_BACKTRACK_PROB * backtrack

/*
flow gives a % chancce to avoid a blow, and is negated by their instinct
given this if flow is = to instinct, then the chance to avoid is nothing (0.5 - 0.5 = 0)
what we need is something that multiplies the base chance of 6 by the amount of flow they have
this flow that they have should be affected by their instinct
*/			