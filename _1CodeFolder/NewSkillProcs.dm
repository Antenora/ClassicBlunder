//ais window mode helpers
mob/var/tmp/ais_window_until = 0

mob/proc/aisArmed()
	return glob.AIS_WINDOW ? (world.time <= ais_window_until) : (AfterImageStrike > 0)

mob/proc/aisConsume()
	if(glob.AIS_WINDOW)
		ais_window_until = 0
	else
		AfterImageStrike--
		if(AfterImageStrike < 0) AfterImageStrike = 0

mob/proc/SkillStunX(var/Wut,var/obj/Skills/Z,var/bypass=0, dontTakeStack = FALSE)
	if(Z)
		if(!locate(Z) in src)
			return
	if(bypass||Z)
		switch(Wut)
			if("After Image Strike")
				if(src.KO)return
				if(Z.Using) return
				if(src.passive_handler.Get("Staggered!"))
					src << "You can't clear Stagger with AIS!!"
					return
				if(src.TimeFrozen)return
				if(!src.aisArmed())
					KenShockwave(src, icon='KenShockwaveLegend.dmi', Size=0.5, Blend=2, Time=4)
					if(glob.AIS_WINDOW)
						src.ais_window_until = world.time + glob.TIMING_WINDOW
					else
						src.AfterImageStrike=1
					if(Stunned)
						StunClear(src)
					src << "You focus intently on your opponents movements..."
					Z.Cooldown()
					if(!dontTakeStack)
						src.MovementCharges--