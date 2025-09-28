mob/proc/SkillStunX(var/Wut,var/obj/Skills/Z,var/bypass=0, dontTakeStack = FALSE)
	if(Z)
		if(!locate(Z) in src)
			return
	if(bypass||Z)
		switch(Wut)
			if("After Image Strike")
				if(src.KO)return
				if(Z.Using) return
				if(src.TimeFrozen)return
				if(!src.AfterImageStrike)
					KenShockwave(src, icon='KenShockwaveLegend.dmi', Size=0.5, Blend=2, Time=4)
					src.AfterImageStrike=1
					if(Stunned)
						StunClear(src)
					src << "You focus intently on your opponents movements..."
					Z.Cooldown()
					if(!dontTakeStack)
						src.MovementCharges--