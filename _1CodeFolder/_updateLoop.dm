
/*
a rough copy of Kaio's update loop lib, without the comments, find it for a reference
*/

game_loop

/game_loop/var/default_callback = "Update"
/game_loop/var/tick_lag
/game_loop/var/tmp/list/_updaters

/game_loop/New(tick_lag, default_callback)
    ..()
    src.tick_lag = tick_lag || world.tick_lag
    if(default_callback)
        src.default_callback = default_callback
    Loop()

/game_loop/proc/Add(updater, callback)
    if(!_updaters) _updaters = new
    _updaters[updater] = callback || default_callback

/game_loop/proc/Remove(updater)
    if(_updaters)
        _updaters -= updater
        if(!_updaters.len)
            _updaters = null

/game_loop/proc/UpdateAll()
    for(var/updater in _updaters)
        Update(updater)

/game_loop/Update(updater)
    var callback = CallbackFor(updater)
    if(callback)
        call(updater, callback)()

/game_loop/proc/Loop()
    set waitfor = FALSE
    set background = TRUE

    for()
        if(_updaters) UpdateAll()

        if(_updaters)
            while(_updaters.Remove(null))
            if(!_updaters.len) _updaters = null
        sleep(tick_lag)

/game_loop/proc/Updates(updater)
    return CallbackFor(updater) != null

/game_loop/proc/CallbackFor(updater)
    return _updaters && _updaters[updater] || null

/game_loop/proc/operator+=(updater)
    Add(updater)

/game_loop/proc/operator-=(updater)
    Remove(updater)

/game_loop/proc/operator|=(updater)
    Add(updater)

/game_loop/proc/operator[]=(updater, callback)
    if(callback)
        Add(updater, callback)
    else
        Remove(updater)


var/ticker
var/list/ticking_ai = list()
var/list/companion_ais = list()
var/list/ticking_turfs = list()
var/list/ticking_generic = list()

/mob/Admin4/verb/view_ai_list()
    src << jointext(ticking_ai, ", ")
    src << length(ticking_ai)

/mob/Admin4/verb/removeAllfromTicking()
    for(var/datum/i in ticking_ai)
        ticking_ai -= i



world
    Tick()
        ..()
        if(ticker++ > 10)
            ticker = 1

        if(ticker % 2 == 0)
            try
                companion_tick()
                turf_tick()
            catch()

        if(ticker % 5 == 0)
            try
                ai_tick()
            catch()

        try
            general_tick()
        catch()


proc/general_tick()
    for(var/atom/a in ticking_generic)
        a.Update()

proc/turf_tick()
    for(var/turf/t in ticking_turfs)
        t.Update()


proc/ai_tick()
    for(var/datum/i in ticking_ai)
        i.Update()


// im sorry niezan
proc/companion_tick()
    for(var/datum/i in companion_ais)
        i.Update()