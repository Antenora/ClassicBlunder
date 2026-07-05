/obj/Skills/Buffs/ActiveBuffs
	Kamui
		KiControl=1
		HealthPU=1
		passives = list ("KiControl" = 1, "HealthPU" = 1, "BleedHit" = 0.5)
		StripEquip=1
		FlashChange=1
		HairLock=1
		IconLayer=3
		KenWave=1
		KenWaveIcon='SparkleRed.dmi'
		KenWaveSize=5
		KenWaveTime=30
		KenWaveX=105
		KenWaveY=105

// Special Buffs

/obj/Skills/Buffs/SpecialBuffs
	SpecialSlot=1

	Kamui_Unite
		passives = list("HardStyle" = 3, "Juggernaut" = 2, "DeathField" = 3, "Pursuer" = 3, "Flicker" = 2)
		StripEquip = 1
		HairLock = 1
		ActiveMessage="unites with their Kamui!"
		Cooldown=60//just to force using
		verb/Kamui_Unite()
			set category="Skills"
			if(usr.KamuiType=="Senketsu")
				src.ABuffNeeded=list("Life Fiber Synchronize")
				IconLock = 'senketsu_kisaragi.dmi'
				LockX = -14
				LockY = -14
				TopOverlayLock = 'senketsu_kisaragi_headpiece.dmi'
				TopOverlayX = -12
				TopOverlayY = -12
				ActiveMessage="feeds blood into their Kamui, taking up the mantle of a God with every drop of blood fed in for but a moment! <br><center><font color='red'>Life Fiber Synchronize: Senketsu Kisaragi!</font color></center>"

			else if(usr.KamuiType == "Junketsu")
				src.ABuffNeeded=list("Life Fiber Override")
				IconLock = 'junketsu_shinzui.dmi'
				LockX = -14
				LockY = -14
				TopOverlayLock = 'junketsu_shinzui_headpiece.dmi'
				TopOverlayX = -12
				TopOverlayY = -12
				ActiveMessage="forces blood into their Kamui, permitting it to take up the mantle of a God with every drop of blood fed in for but a moment! <br><center><font color='cyan'>Life Fiber Override: Junketsu Shinzui!</font color></center>"

			src.Trigger(usr)
			if(src.Using)
				usr.passive_handler.Set("GodKi", 0)
				if(usr.KamuiType=="Senketsu")
					OMsg(usr, "<font color='red'>Senketsu says: [usr] ... There comes a time when every girl has to put away their sailor suit...</font color>")
					OMsg(usr, "<font color='red'>Senketsu crumbles away due to the immeasure strain on his fibers...")
					usr.KamuiBuffLock=1
				if(usr.KamuiType=="Purity")
					OMsg(usr, "<font color='cyan'>[usr] says: At last ... My empire is fulfilled...</font color>")
					OMsg(usr, "<font color='cyan'>Junketsu screams in pure hatred one last time before its life fibers are completely subjugated and scatter to the wind...")
					usr.KamuiBuffLock=1
				usr.ActiveBuff.Trigger(usr)
				for(var/obj/Items/Symbiotic/Kamui/KamuiSenketsu/ks in usr)
					if(ks.suffix)
						ks.AlignEquip(usr)
					del ks
				for(var/obj/Items/Symbiotic/Kamui/KamuiJunketsu/ks in usr)
					if(ks.suffix)
						ks.AlignEquip(usr)
					del ks

// Admin escape verb for the KamuiBuffLock-stuck bug. The flag is set above
// when Senketsu/Junketsu crumbles at the end of the saga arc but no code path
// resets it, so any character that lost their Kamui is permanently locked out
// of the Special Buff slot. This verb is the manual override.
/mob/Admin1/verb/Clear_Kamui_Buff_Lock(mob/M as mob in world)
	set category = "Admin"
	set desc = "Reset KamuiBuffLock=0 on a target mob. Fixes 'Your special buffs are locked out!' caused by stale Kamui state."
	if(!M)
		return
	if(!M.KamuiBuffLock)
		src << "[M] does not have KamuiBuffLock set."
		return
	M.KamuiBuffLock = 0
	src << "Cleared KamuiBuffLock on [M]."
	M << "<font color=#cc6633>[src] cleared a stale Kamui lock on you. Your Special Buff slot is freed.</font>"


// Auto-clear KamuiBuffLock if the player no longer carries a Kamui item — the
// lock represents a literal lost-Kamui state, so when there's no Kamui obj in
// the player's contents anymore the lock is meaningless. Called from the gain
// loop so existing locked players unstick on their next tick. Cheap, idempotent.
/mob/proc/AutoClearStaleKamuiLock()
	if(!src.KamuiBuffLock)
		return
	for(var/obj/Items/Symbiotic/Kamui/K in src)
		return  // still has a Kamui — lock might be valid
	src.KamuiBuffLock = 0
	src << "<font color=#888888>(Stale Kamui lock cleared automatically — your Special Buff slot is freed.)</font>"
