mob/Player
	FevaSplits
		var
			OneHitWonder=0
			Creator
			PowerCheck=0.75
			HostileNPC
		Del()
			animate(src,alpha=0,time=5)
			Creator:Splits:Remove(src)
			spawn(5)
				..()
		proc
			Ai_Start()
				spawn()
					while(src)
						if(KO)
							del src
						else
							if(!Target)
								Target_Search()
							if(Target)
								Chase_Target()
								if(world.time >= NextAttack)
									Attack_Target()
								Rinse_Repeat()
							if(src.Target in ohearers(src))
								src.dir=get_dir(src,src.Target)
						sleep(2)


			Target_Search()
				if(Target)
					return
				if(!Target)
					for(var/mob/Players/P in ohearers(src))
						if(P.Target==Creator)
							continue
			Chase_Target()
				if(get_dist(src, src.Target) >= 12)
					Target=null
				if(Knockbacked)
					if(prob(45))
						for(var/obj/Skills/Aerial_Recovery/P in contents)
							if(!P.Using)
								src.SkillX("Aerial Recovery",P)
					else
						return
				if(Target&&(world.time > NextAttack))
					if(Target:KO)
						Target=null
					walk_to(src,Target,1,1)
			Attack_Target()
//				var/Sword
				var/Attacked=0

				if(!Attacked)
					if(Target in get_step(src,src.dir))
						Melee1()
						if(OneHitWonder)
							del src


			Rinse_Repeat()
				if(Knockbacked)return
				if(Target&&(world.time > NextAttack))
					if(prob(20))
						step_away(src,Target)
					else if(prob(20))
						step_rand(src,Target)
					else if(prob(30))
						step_towards(src,Target)
					else
						return
atom
	var
		list/Splits=list()
obj/Skills/Feva
	Splitform
		Cooldown=120

		verb/SplitForm()
			set category="Skills"
			if(usr.KO)return
			if(src.Using)
				return
			var/Splits=2
			Cooldown()
			while(Splits>0)
				Splits--
				var/mob/Player/FevaSplits/FS = new
				FS.Creator=usr
				FS.loc=usr.loc
				FS.dir=usr.dir
				step_away(FS,usr)
				FS.name=usr.name
				FS.icon=usr.icon
				FS.overlays=usr.overlays
				FS.NextAttack=0

				FS.Health=33
				FS.Power=(usr.Power/usr.GetPowerUpRatio())*0.33

				FS.EnergyMax=usr.EnergyMax
				FS.Energy=usr.EnergyMax

				FS.StrMod=usr.GetStr()

				FS.EndMod=usr.GetEnd()

				FS.SpdMod=usr.GetSpd()

				FS.ForMod=usr.GetFor()

				FS.OffMod=usr.GetOff()

				FS.DefMod=usr.GetDef()

				FS.Target=usr.Target
				usr.Splits:Add(FS)
				for(var/obj/Skills/S in usr.contents)
					var/X = new S.type
					//usr<<"[FS] Split was given [X]."
					FS.contents+=X
				spawn(1)
					FS.Ai_Start()
				spawn(1200)
					del FS

obj/Skills/Feva
	MassSplitform
		Cooldown=240

		verb/MassSplitForm()
			set category="Skills"
			if(usr.KO)return
			if(src.Using)
				return
			var/Splits=9
			Cooldown()
			while(Splits>0)
				sleep(1)
				Splits--
				var/mob/Player/FevaSplits/FS = new
				FS.Creator=usr

				FS.loc=usr.loc
				FS.dir=usr.dir
				step_away(FS,usr)
				FS.name=usr.name
				FS.icon=usr.icon
				FS.overlays=usr.overlays
				FS.NextAttack=0

				FS.Health=10
				FS.Power=(usr.Power/usr.GetPowerUpRatio())*0.1

				FS.EnergyMax=usr.EnergyMax
				FS.Energy=usr.EnergyMax

				FS.StrMod=usr.GetStr()

				FS.EndMod=usr.GetEnd()

				FS.SpdMod=usr.GetSpd()

				FS.ForMod=usr.GetFor()

				FS.OffMod=usr.GetOff()

				FS.DefMod=usr.GetDef()

				FS.Target=usr.Target
				for(var/obj/Skills/S in usr.contents)
					var/X = new S.type
					//usr<<"[FS] Split was given [X]."
					FS.contents+=X
				spawn(1)
					FS.Ai_Start()
				spawn(1200)
					del FS
obj/Skills/Feva
	SuperMassSplitform
		Cooldown=240

		verb/SuperMassSplitForm()
			set category="Skills"
			if(usr.KO)return
			if(src.Using)
				return
			var/Splits=19
			Cooldown()
			while(Splits>0)
				sleep(1)
				Splits--
				var/mob/Player/FevaSplits/FS = new
				FS.Creator=usr

				FS.loc=usr.loc
				FS.dir=usr.dir
				step_away(FS,usr)
				FS.name=usr.name
				FS.icon=usr.icon
				FS.overlays=usr.overlays
				FS.NextAttack=0

				FS.Health=5
				FS.Power=(usr.Power/usr.GetPowerUpRatio())*0.05

				FS.EnergyMax=usr.EnergyMax
				FS.Energy=usr.EnergyMax

				FS.StrMod=usr.GetStr()

				FS.EndMod=usr.GetEnd()

				FS.SpdMod=usr.GetSpd()

				FS.ForMod=usr.GetFor()

				FS.OffMod=usr.GetOff()

				FS.DefMod=usr.GetDef()

				FS.Target=usr.Target
				usr.Splits:Add(FS)
				for(var/obj/Skills/S in usr.contents)
					var/X = new S.type
					//usr<<"[FS] Split was given [X]."
					FS.contents+=X
				spawn(1)
					FS.Ai_Start()
				spawn(1200)
					del FS
