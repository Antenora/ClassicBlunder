// One key for all life skill work. Default G, rebindable in the Keybinds menu.

client/var/tmp/datum/life_minigame/life_minigame_sink
client/var/tmp/life_interact_down = 0   // raw key state

obj/proc/InteractWith(mob/M)
	return 0

mob/verb/Interact()
	set hidden = 1
	set instant = 1
	if(!client) return
	client.life_interact_down = 1
	if(client.life_minigame_sink)
		var/datum/life_minigame/g = client.life_minigame_sink
		g.HandlePress(src)
		return
	if(Using) return   
	if(KO || Dead) return
	var/turf/T = get_step(src, dir)
	if(T)
		for(var/obj/O in T)
			if(O.InteractWith(src)) return
	for(var/obj/O in loc)
		if(O.InteractWith(src)) return

mob/verb/Interact_Release()
	set name = "Interact Release"
	set hidden = 1
	set instant = 1
	if(!client) return
	client.life_interact_down = 0
	if(!client.life_minigame_sink) return
	var/datum/life_minigame/g = client.life_minigame_sink
	g.HandleRelease(src)

// what the player actually has Interact bound to, for prompts
mob/proc/InteractKeyName()
	var/k = KeybindKey("interact", 1)
	if(!k) k = KeybindKey("interact", 2)
	return k ? k : "G"
