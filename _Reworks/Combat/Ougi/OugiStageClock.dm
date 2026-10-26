/datum/ougi_scene
	var
		beat_real = 0
		beat_clock0 = 0
		beat_shift = 0
		beat_op_t0 = 0

proc/OugiBeatTick(real)
	return max(0, ceil(real / world.tick_lag - 0.001)) * world.tick_lag

/datum/ougi_scene/BeatClockStart()
	beat_real = 0
	beat_clock0 = world.time
	beat_shift = 0
	beat_op_t0 = world.time

/datum/ougi_scene/BeatSleep(wait)
	beat_shift += world.time - beat_op_t0
	beat_real += max(0, wait)
	var/due = beat_clock0 + beat_shift + OugiBeatTick(beat_real)
	if(due > world.time) sleep(due - world.time)
	beat_op_t0 = world.time
