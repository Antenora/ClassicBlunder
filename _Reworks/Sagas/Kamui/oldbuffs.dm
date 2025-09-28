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
				LockX = 0
				LockY = 0
				TopOverlayLock = 'senketsu_kisaragi_headpiece.dmi'
				TopOverlayX = 0
				TopOverlayY = 0
				ActiveMessage="feeds blood into their Kamui, taking up the mantle of a God with every drop of blood fed in for but a moment! <br><center><font color='red'>Life Fiber Synchronize: Senketsu Kisaragi!</font color></center>"

			else if(usr.KamuiType == "Junketsu")
				src.ABuffNeeded=list("Life Fiber Override")
				IconLock = 'junketsu_shinzui.dmi'
				LockX = 0
				LockY = 0
				TopOverlayLock = 'junketsu_shinzui_headpiece.dmi'
				TopOverlayX = 0
				TopOverlayY = 0
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