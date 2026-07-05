obj
	MysticArms
		Grabbable=0


		name="Mystic Arms"
		icon='MysticArm.dmi'
		icon_state="Arm"

		var
			mob/Master
			mob/Target
			list/Arms = new/list()
			Priority = "Grab"
			Max_Steps = 0
			Return = 0
			mob/Holding
			Initial_Loc

	//	step_size=16
	/*	bound_height=4
		bound_width=4
		bound_x=16
		bound_y=16*/
		proc
			SanityCheck()
				if(Owner.loc == Initial_Loc && !Owner.Grab)
					return 1
			Chase_Target()
				flick("Blast", Owner)
				spawn(1)
					if(!SanityCheck())
						del src
						return
					icon_state = Priority

					if(Target && Target in get_step(src, src.dir))
						if(Priority == "Grab")
							Max_Steps = 1
							walk(src, get_dir(Owner, Target))
							ExtendoGrab()
							Hold()
							if(Target in get_step(Owner, Owner.dir))
								Owner.Grab()
								del src
						else if(Priority == "Attack")
							Max_Steps = 0
							walk(src, get_dir(Owner, Target))
							Priority = "Retract"
							if(Target in get_step(Owner, Owner.dir))
								spawn(1)
									del src
							Owner.Melee1(MeleeTarget = Target, ExtendoAttack = 1)

					else
						if(!Target)
							walk(src, src.dir, 1)
							var/mob/Tag
							for(var/mob/m in get_step(src, src.dir))
								if(m != Master)
									if(!Tag)
										Tag = m
							if(Tag)
								Target = Tag

					Max_Steps--
					if(Max_Steps > 0)
						Chase_Target()
					else
						GoToMaster()
			ExtendoGrab()
				Priority = "Retract"
				Holding = Target
			Hold()
				if(Holding)
					Holding.loc = loc

			GoToMaster()
				spawn(1)
					walk(src, 0)
					density = 0
					Return = 1
					density = 0
					Hold()
					sleep(2)
					Gogogo
					spawn(1)
						if(!SanityCheck())
							del src
							return
						flick("Blast", Owner)
						walk_to(src, Owner, 0, 1)

						if(Master && src in get_step(Master, Master.dir))
							spawn(1)
								del src
								return
							if(Holding)
								Master.Grab()
						else
							goto Gogogo
		Head
			layer = MOB_LAYER + 0.1
			density = 1
			Del()
				Owner.Beaming = 0
				for(var/obj/A in Arms)
					del A
				..()
			Move()
				var/obj/MysticArms/NewlyCreated
				var/Startingloc = loc
				if(Return == 0)
					var/obj/MysticArms/A = new
					A.loc = loc
					A.dir = dir
					if(A.loc == Master.loc)
						del A
					else
						Arms.Add(A)
						NewlyCreated = A
				else
					var/obj/MysticArms/Delete
					for(var/obj/MysticArms/X in Arms)
						Delete = X
					if(Delete && loc == Delete.loc)
						Arms.Remove(Delete)
						del Delete

				..()
				if(Return == 0)
					if(loc == Startingloc)
						Arms.Remove(NewlyCreated)
						del NewlyCreated
						Max_Steps = 0
						walk(src, 0)
				dir = Owner.dir
				Hold()


