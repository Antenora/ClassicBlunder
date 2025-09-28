#define BROADCAST_RANGE 12
#define BROADCAST_COLOR "<font color=green>"
var/tmp/list/globalListeners = list()
globalTracker/var/list/ZBlockedComms = list()

globalListener
	var/tmp/list/connected = list()
	var/freq = 0
	proc/outputToComms(obj/Items/Tech/source, msg)
		for(var/obj/Items/Tech/sendTo in connected)
			if(source == sendTo) continue
			sendTo.recieveBroadcast(msg)

proc/addToGlobalListeners(obj/Items/Tech/listener)
	if(!listener.Frequency) return

	for(var/globalListener/globalL in globalListeners)
		if(globalL.freq == listener.Frequency)
			globalL.connected |= listener
			return
	var/globalListener/newListener = new()
	newListener.freq = listener.Frequency
	newListener.connected += listener
	globalListeners += newListener

proc/removeFromGlobalListeners(obj/Items/Tech/listener)
	if(!listener.Frequency) return

	for(var/globalListener/globalL in globalListeners)
		if(globalL.freq == listener.Frequency)
			if(listener in globalL.connected)
				globalL.connected -= listener
				return

obj/Items/Tech/proc/broadcastToListeners(msg)
//	if(!Active) return
	if(!Frequency) return
	if((z in glob.ZBlockedComms) || (src.loc.z in glob.ZBlockedComms))
		if(ismob(loc))
			var/broadcastFormattingPersonal = "[BROADCAST_COLOR]<b>([name])</b> BZZZZTTT..."
			var/mob/owner = loc
			owner.client.outputToChat(broadcastFormattingPersonal, IC_OUTPUT)
			Log(owner.ChatLog(),broadcastFormattingPersonal)
			Log(owner.sanitizedChatLog(),broadcastFormattingPersonal)
		else
			var/broadcastFormattingAllAround = "[BROADCAST_COLOR]<b>([name]) crackles to life from the floor:</b> BZZZZZTTT..."
			for(var/mob/m in hearers(BROADCAST_RANGE,src))
				m.client.outputToChat(broadcastFormattingAllAround, IC_OUTPUT)
		return
	for(var/globalListener/listener in globalListeners)
		if(listener.freq == Frequency)
			listener.outputToComms(src, msg)

obj/Items/Tech/proc/recieveBroadcast(msg)
//	if(!Active) return
	if(!Frequency) return
	if((z in glob.ZBlockedComms) || (src.loc.z in glob.ZBlockedComms))
		if(ismob(loc))
			var/broadcastFormattingPersonal = "[BROADCAST_COLOR]<b>([name])</b> BZZZZTTT..."
			var/mob/owner = loc
			owner.client.outputToChat(broadcastFormattingPersonal, IC_OUTPUT)
			Log(owner.ChatLog(),broadcastFormattingPersonal)
			Log(owner.sanitizedChatLog(),broadcastFormattingPersonal)
		else
			var/broadcastFormattingAllAround = "[BROADCAST_COLOR]<b>([name]) crackles to life from the floor:</b> BZZZZZTTT..."
			for(var/mob/m in hearers(BROADCAST_RANGE,src))
				m.client.outputToChat(broadcastFormattingAllAround, IC_OUTPUT)
		return
	if(ismob(loc))
		var/broadcastFormattingPersonal = "[BROADCAST_COLOR]<b>([name])</b>[msg]"
		var/mob/owner = loc
		if(owner.client)
			owner.client.outputToChat(broadcastFormattingPersonal, IC_OUTPUT)
			Log(owner.ChatLog(),broadcastFormattingPersonal)
			Log(owner.sanitizedChatLog(),broadcastFormattingPersonal)
	else
		var/broadcastFormattingAllAround = "[BROADCAST_COLOR]<b>([name]) crackles to life from the floor:</b>[msg]"
		for(var/mob/m in hearers(BROADCAST_RANGE,src))
			m.client.outputToChat(broadcastFormattingAllAround, IC_OUTPUT)


mob/Players/
	Login()
		..()
		for(var/obj/Items/Tech/F in contents)
			if(!F.Frequency) continue
			addToGlobalListeners(F)

	Logout()
		..()
		for(var/obj/Items/Tech/F in contents)
			if(!F.Frequency) continue
			removeFromGlobalListeners(F)