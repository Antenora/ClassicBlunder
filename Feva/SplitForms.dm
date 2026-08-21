mob/Player
	FevaSplits
		var
			OneHitWonder = 0
			mob/Creator
			PowerCheck = 0.75
			HostileNPC
		Del()
			animate(src, alpha = 0, time = 5)
			if(Creator)
				Creator.Splits.Remove(src)
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
				for(var/mob/Players/P in ohearers(src))
					if(P.Target == Creator)
						continue
					Target = P
					return
			Chase_Target()
				if(get_dist(src, src.Target) >= 12)
					Target = null
				if(Knockbacked)
					if(prob(45))
						for(var/obj/Skills/Aerial_Recovery/P in contents)
							if(!P.Using)
								src.SkillX("Aerial Recovery", P)
					else
						return
				if(Target && (world.time > NextAttack))
					if(Target.KO)
						Target = null
					walk_to(src, Target, 1, 1)
			Attack_Target()
				if(Target in get_step(src, src.dir))
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
mob/proc/SpawnHostileCopy(var/ClOwner, var/CloneHP=50, var/ClonePower=1, var/CloneTarget, var/CopySkills)
	var/mob/Player/AI/FS=new
//		FS.Creator=usr
	FS.loc=src.loc
	FS.dir=src.dir
	FS.ai_owner=ClOwner
	step_away(FS,src)
	FS.name=src.name
	FS.icon=src.icon
	FS.overlays=src.overlays
	FS.NextAttack=0

	FS.Power=(usr.Power/usr.GetPowerUpRatio())*ClonePower

	FS.EnergyMax=100
	FS.Energy=100

	FS.StrMod=src.GetStr()

	FS.EndMod=src.GetEnd()

	FS.VitMod=src.GetVit()
	FS.SetHealthPct(CloneHP)
	FS.SpdMod=src.GetSpd()

	FS.ForMod=src.GetFor()

	FS.OffMod=src.GetOff()

	FS.DefMod=src.GetDef()

	FS.Target=CloneTarget
	FS.hostile=2
	FS.ai_hostility=2
	FS.Update()
obj/Skills/Feva
	Splitform
		Cooldown=120
		var/SplitHealth=5
		var/SplitPower=0.1

		verb/SplitForm()
			set category="Skills"
			set hidden = 1
			if(usr.KO)return
			if(src.Using)
				return
			var/Splits=2
			Cooldown()
			while(Splits>0)
				Splits--
			//	var/mob/Player/FevaSplits/FS = new
				var/mob/Player/AI/FS=new
		//		FS.Creator=usr
				FS.loc=usr.loc
				FS.dir=usr.dir
				step_away(FS,usr)
				FS.name=usr.name
				FS.icon=usr.icon
				FS.overlays=usr.overlays
				FS.NextAttack=0

				FS.Power=usr.Power*src.SplitPower

				FS.EnergyMax=usr.EnergyMax
				FS.Energy=usr.EnergyMax

				FS.StrMod=usr.GetStr()

				FS.EndMod=usr.GetEnd()

				FS.VitMod=usr.GetVit()
				FS.SetHealthPct(src.SplitHealth)
				FS.SpdMod=usr.GetSpd()

				FS.ForMod=usr.GetFor()

				FS.OffMod=usr.GetOff()

				FS.DefMod=usr.GetDef()

				FS.Target=usr.Target
				FS.hostile=2
				FS.ai_hostility=2
				FS.ai_owner=usr
				usr.Splits.Add(FS)
				for(var/obj/Skills/S in usr.contents)
					var/X = new S.type
					//usr<<"[FS] Split was given [X]."
					FS.contents+=X
				spawn(1)
					FS.Update()
			//		initial_aize(FS)
			//		ai_active.Add(FS)

obj/Skills/Feva
	MassSplitform
		Cooldown=240

		verb/MassSplitForm()
			set category="Skills"
			set hidden = 1
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

				FS.Power=(usr.Power/usr.GetPowerUpRatio())*0.1

				FS.EnergyMax=usr.EnergyMax
				FS.Energy=usr.EnergyMax

				FS.StrMod=usr.GetStr()

				FS.EndMod=usr.GetEnd()

				FS.VitMod=usr.GetVit()
				FS.SetHealthPct(10)
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
			set hidden = 1
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

				FS.Power=(usr.Power/usr.GetPowerUpRatio())*0.05

				FS.EnergyMax=usr.EnergyMax
				FS.Energy=usr.EnergyMax

				FS.StrMod=usr.GetStr()

				FS.EndMod=usr.GetEnd()

				FS.VitMod=usr.GetVit()
				FS.SetHealthPct(5)
				FS.SpdMod=usr.GetSpd()

				FS.ForMod=usr.GetFor()

				FS.OffMod=usr.GetOff()

				FS.DefMod=usr.GetDef()

				FS.Target=usr.Target
				usr.Splits.Add(FS)
				for(var/obj/Skills/S in usr.contents)
					var/X = new S.type
					//usr<<"[FS] Split was given [X]."
					FS.contents+=X
				spawn(1)
					FS.Ai_Start()
				spawn(1200)
					del FS
