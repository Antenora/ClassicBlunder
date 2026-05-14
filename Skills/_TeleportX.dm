obj/Skills
	Teleport
		Cooldown=300
		var
			NoPassengers=1/*Doesn't allow for passengers*/
			PassengerHeal=0/*heals people drawn by the transport*/
			NoCoordinates=1/*Doesn't allow for coordinate based warping*/
			NoFocals=0/*Doesn't allow for focal based warping*/
			ZWarp=0/*allows for z plane warping*/
			NoXY=0/*disallows xy warp*/

			NoReturn=1/*Doesn't set return coordinates*/
			ReturnX=0
			ReturnY=0
			ReturnZ=0

			FocalLock=0//if this is noted, it forces additional conditions to leave the specified zplane
			FocalPassword=0/*if assigned, make sure focal has this password*/
			FocalLocation=0/*if assigned, make sure focal is within FocalLocation spaces in x/y*/
			list/FocalExceptions=list()/*if populated, remove these from the focal list*/
			FocalSummon=0/*if assigned, brings the other person to you instead*/
			MassSummon=0/*if assigned, brings ALL other people to you*/

			FocalArcane=0/*if 1, search for arcane focals*/
			FocalNexus=0/*if 1, search for similarly passworded nexuses*/
			FocalPerson=0/*if 1, just add ppl to list*/
			NoSignature=0/*if 1, you dont need to know their energy signature*/

			UnderworldWarp=0//if 1, traverse underworld is option
			DepthsWarp=0 //Travel to the Depths
			DepthsFocal=0;
			DaatWarp=0//Travel to Da'at
			DiveWarp=0//Dive to the Heart
			FallThrough=0//go to this z plane around your coordinates if you arent on it

			UseableDead=0//if 1, allows use in dead/neardead zones
			UseableArcane=0//if 1, allows use in arcane zone
			//Majin and philosopher stones cannot be TP'd out of or into regardless

			//ManaCost
			//CapacityCost

			WindUp=0/*Sleep this value before triggering the teleport*/
			WindUpIcon/*Display this for the windup*/
			WindUpX=0
			WindUpY=0

			WindDown=0//Display wind down icon for this time after teleport
			WindDownIcon
			WindDownX=0
			WindDownY=0

			TeleportMessage="teleports away!"
			ReturnMessage="returns to whence they came!"
			ArriveMessage="arrives via teleportation!"

		Nexus_Teleport
			NoCoordinates=1
			FocalNexus=1
			ZWarp=1
			CapacityCost=25
			TeleportMessage="teleports through a nearby Nexus!"
			ArriveMessage="arrives through a nearby Nexus!"
			//FocalPassword will be set by using the nexus
			//This will be activated by the object
		Nexus_Summon
			NoCoordinates=1
			ZWarp=1
			FocalNexus=1
			FocalSummon=1
			CapacityCost=25
			TeleportMessage="is summoned away by their Teleport Amulet!"
			ArriveMessage="is summoned forth!"
			//FocalPassword will be set by the nexus
			//This will be activated by the object
			Nexus_Rally
				MassSummon=1
				ZWarp=1
				CapacityCost=50
				//FocalPassword will be set by the nexus
				//This will be activated by the object

		Kai_Kai
			desc="The ultimate warping ability. Transport yourself to any coordinate or any person regardless of if you know them or not."
			//uses people as focals
			//can use coordinate warps
			ZWarp=1
			NoFocals=0
			NoPassengers=0
			NoCoordinates=0
			NoReturn=0
			FocalPerson=1
			NoSignature=1
			UseableDead=1
			UseableArcane=1
			WindUp=2
			WindUpIcon='Icons/Effects/BlackHoleEnter.dmi'
			WindDown=0.7
			WindDownIcon='Icons/Effects/BlackHoleExit.dmi'
			Cooldown=-1
			TeleportMessage="warps away on the wind of gods!"
			ArriveMessage="arrives thanks to godly transmission!"
			verb/Kai_Kai()
				set category="Utility"
				src.Activate(usr)
		Traverse_Void
			NoTransplant=1
			desc="The Empty Grimoire allows you to transport yourself to any location within the Mortal World, assuming you know the coordinates or a nearby person. It requires full mana to use."
			ZWarp=1
			UseableDead=1
			FocalPerson=1
			NoCoordinates=0
			ManaCost=0
			WindUp=2
			WindUpIcon='Icons/Effects/BlackHoleEnter.dmi'
			WindDown=0.7
			WindDownIcon='Icons/Effects/BlackHoleExit.dmi'
			TeleportMessage="taps their Empty Grimoire to traverse the void!"
			ArriveMessage="appears suddenly from the void!"
			verb/Traverse_Void()
				set category="Utility"
				src.Activate(usr)

		Instant_Transmission
			desc="Warp instantly to a known energy signature. You can take people with you!"
			SignatureTechnique=3
			ZWarp=1
			NoFocals=0
			NoPassengers=0
			NoCoordinates=1
			FocalPerson=1
			Cooldown=60
			CooldownStatic=1
			TeleportMessage="focuses on a distant power before vanishing!"
			ArriveMessage="appears instantly!"
			var/ClickTeleportToggle=1
			verb/Instant_Transmission()
				set category="Utility"
				src.Activate(usr)
			verb/Short_Range_Teleport()
				set category="Utility"
				ClickTeleportToggle = !ClickTeleportToggle
				usr << "You will [ClickTeleportToggle ? null : "no longer "]teleport on click."
		Warp
			desc="Use your eldritch nature to shift through space."
			//Gains ZWarp at asc level 5
			NoCoordinates=0
			ZWarp=0
			NoFocals=1
			UseableDead=1
			UseableArcane=1
			Cooldown=10
			TeleportMessage="slides through the vertices of reality!"
			ArriveMessage="oozes in from nowhere!"
			verb/Warp()
				set category="Utility"
				src.Activate(usr)
		Traverse_Arcane
			desc="If you are in the arcane realm, this allows you to use a focal on another plane to escape. Otherwise, it allows you to return to the arcane."
			NoPassengers=0
			NoCoordinates=1
			UseableArcane=1
			/*FocalLock has the global arcane realm z loaded at creation*/
			/*FallThrough is assigned to arcane plane on creation*/
			FocalArcane=1
			FocalLocation=25//be within 25 x/y of focal
			WindUp=1
			WindUpIcon='Icons/Effects/traverse arcane.dmi'
			WindDown=0.5
			WindDownIcon='Icons/Effects/traverse arcane.dmi'
			Cooldown=1800//30 minutes
			TeleportMessage="moves through the endless arcane traverse!"
			ArriveMessage="emerges from the endless arcane traverse!"
			verb/Traverse_Arcane()
				set category="Utility"
				src.Activate(usr)
		Naraku_Path
			desc="Summon the King of Hell to fully restore those adjacent to you as you all warp to the underworld."
			NoPassengers=0
			PassengerHeal=1
			NoReturn=0
			UnderworldWarp=1
			Cooldown=21600//6 hours
			TeleportMessage="is swallowed by the giant King of Hell!"
			ArriveMessage="is spat out by the giant King of Hell with all aches soothed!"
			verb/Naraku_Path()
				set category="Utility"
				src.Activate(usr)
		Traverse_Dimension
			desc="Warp to any dimension without changing your relative position."
			NoCoordinates=0
			ZWarp=1
			NoXY=1
			UseableArcane=1
			UseableDead=1
			ManaCost=25
			WindUp=2
			WindUpIcon='Icons/Effects/BlackHoleEnter.dmi'
			WindDown=0.7
			WindDownIcon='Icons/Effects/BlackHoleExit.dmi'
			TeleportMessage="bends their Cosmo to traverse dimensions!"
			ArriveMessage="arrives with a flux of Cosmo!"
			verb/Traverse_Dimension()
				set category="Utility"
				src.Activate(usr)
		Traverse_Underworld
			desc="Warp to the afterlife and back."
			UseableDead=1
			UnderworldWarp=1
			NoCoordinates=1
			NoReturn=0
			ManaCost=25
			WindUp=2
			WindUpIcon='Icons/Effects/BlackHoleEnter.dmi'
			WindDown=0.7
			WindDownIcon='Icons/Effects/BlackHoleExit.dmi'
			TeleportMessage="bends their Cosmo to traverse mortality!"
			ArriveMessage="arrives with a flux of Cosmo!"
			verb/Traverse_Underworld()
				set category="Utility"
				src.Activate(usr)
		Traverse_Daat
			desc="Warp to Da'at and back."
			UseableDead=1
			DaatWarp=1
			NoCoordinates=1
			NoPassengers=0
			NoReturn=0
			WindUp=2
			WindUpIcon='Icons/Effects/BlackHoleEnter.dmi'
			WindDown=0.7
			WindDownIcon='Icons/Effects/BlackHoleExit.dmi'
			TeleportMessage="rips open a portal to a realm of Light and Darkness."
			ArriveMessage="arrives through a portal."
			verb/Traverse_Daat()
				set category="Utility"
				src.Activate(usr)
		Traverse_Depths
			desc="Warp to the Depths and back."
			UseableDead=1
			DepthsWarp=1
			DepthsFocal=1;
			NoFocals=1;
			NoCoordinates=1
			NoPassengers=0
			NoReturn=0
			WindUp=2
			WindUpIcon='Icons/Effects/BlackHoleEnter.dmi'
			WindDown=0.7
			WindDownIcon='Icons/Effects/BlackHoleExit.dmi'
			TeleportMessage="rips open a portal to a realm of screaming terror."
			ArriveMessage="arrives through a portal."
			var/list/depthsFocals=list();
			verb/Traverse_Depths()
				set category="Utility"
				src.Activate(usr)
			verb/Mark_Focal()
				set category="Utility"
				set name = "Mark Depths Focal"
				if(depthsFocals.len >= usr.AscensionsAcquired)
					usr << "You have already marked the maximum amount of focals for your ascension level.";
					return;
				var/fName = input(usr, "What will you call this focal point?", "Focal Label") as text;
				if(!fName) return;
				for(var/obj/Arcane/ArcaneFocal/f in world)
					if(f.name == fName)
						usr << "A focal named [fName] already exists. Pick a different name."
						return;
				var/confirm = alert(usr, "Do you want to assign one of your focals to the location [usr.x], [usr.y], [usr.z], with the label [fName]?", "Create Personal Focal Point", "No", "Yes");
				if(confirm=="No") return;
				var/obj/Arcane/ArcaneFocal/newFocal = new()
				newFocal.loc = usr.loc;
				newFocal.name = fName;
				newFocal.creator_ckey = usr.ckey;
				depthsFocals.Add(newFocal.name);
			verb/Remove_Focal()
				set category="Utility"
				set name = "Remove Depths Focal"
				if(!depthsFocals.len)
					usr << "You have no marked focals to remove.";
					return;
				var/list/options = list("Cancel") + depthsFocals;
				var/choice = input(usr, "Which of your focals should be removed?", "Remove Personal Focal Point") in options;
				if(!choice || choice == "Cancel") return;
				// Only delete a focal that this player actually owns - guards against
				// stripping a same-named focal another system may have placed.
				for(var/obj/Arcane/ArcaneFocal/f in world)
					if(f.name == choice && f.creator_ckey == usr.ckey)
						del(f)
						break;
				depthsFocals.Remove(choice);
				usr << "Focal [choice] has been unmarked.";
		Dive_To_Heart
			desc="Dive into the station of the heart."
			DiveWarp=1
			NoCoordinates=1
			NoPassengers=1
			NoReturn=0
			WindUp=2
			TeleportMessage="dives into their heart!"
			ArriveMessage="emerges from their heart!"
			verb/Dive_To_Heart()
				set category="Utility"
				src.Activate(usr)

		New()//this proc is called when the object is created
			..()
			if(istype(src, /obj/Skills/Teleport/Traverse_Arcane))
				if(src.FocalLock!=global.ArcaneRealmZ)
					src.FocalLock=global.ArcaneRealmZ
				if(src.FallThrough!=global.ArcaneRealmZ)
					src.FallThrough=global.ArcaneRealmZ

		proc
			Activate(var/mob/User)
				if(User.Suspended)
					return
				if(glob.DISABLE_ALL_TELEPORTS&&!User.passive_handler.Get("FreeTeleport"))
					User<<"The ability to teleport has been sealed off!"
					return
				if(src.type==/obj/Skills/Teleport/Traverse_Underworld&&User.Saga!="Cosmo")
					src.TeleportMessage="bends their demonic energy to traverse mortality!"
					src.ArriveMessage="arrives with a flux of demonic energy!"
				if(src.NoPassengers)
					if(User.Grab)
						User << "You can't use [src] while having someone grabbed!"
						return
				if(User.Dead&&!User.KeepBody)
					User<<"You cannot use a teleportation ability while dead."
					return
				if(User.movementSealed)
					User << "You can't use [src] while your movement is sealed!"
					return
				if(!NoReturn)
					if(src.ReturnX&&src.ReturnY&&src.ReturnZ)
						src.Return(User)
						return//end
				if(src.Using)
					return
				if(User.NoTPZone(src.UseableDead, src.UseableArcane))
					User << "You cannot teleport on this plane!"
					return
				if(src.CapacityCost&&!User.HasManaCapacity(src.CapacityCost))
					User << "You don't have enough mana capacity to use [src]! (It requires [src.CapacityCost])"
					return
				if(src.ManaCost&&User.ManaAmount<src.ManaCost)
					User << "You don't have enough mana to use [src]! (It requires [src.ManaCost])"
					return
				var/Focal=0
				var/list/Focals=list("Cancel")
				var/list/Modes=list("Cancel")
				if(!NoCoordinates)
					Modes.Add("XYZ")
				if(DepthsFocal)
					var/obj/Skills/Teleport/Traverse_Depths/dw = User.findOrAddSkill(/obj/Skills/Teleport/Traverse_Depths)
					if(dw.depthsFocals.len > 0)
						Modes.Add("Depths Focal")
				if(!NoFocals)//If focals are enabled
					var/obj/Arcane/ArcaneFocal/f1
					if(src.FocalArcane)
						if(User.z == src.FocalLock)
							for(f1 in world)
								var/dist=abs(User.x-f1.x) + abs(User.y-f1.y)
								if(dist <= FocalLocation)
									if(!("Focal" in Modes))
										Modes.Add("Focal")
									Focals["[f1.name] [f1.identifier]"]=f1
						else
							if(src.FallThrough)
								Modes.Add("Fall Through")
					if(src.FocalNexus)
						if(!src.FocalSummon)
							for(var/obj/Items/Enchantment/Teleport_Nexus/tn in world)
								if(tn.NoTPZone(src.UseableDead, src.UseableArcane))//do not list teleport nexuses in dead zones
									continue
								if(tn.Password!=src.FocalPassword)//make sure the password is the same
									continue
								if(!tn.Password)//do not link all the unset nexus
									continue
								if(tn in src.FocalExceptions)
									continue
								if(!src.ZWarp)
									if(tn.z != User.z)
										continue
								Focals["[tn.name]"]=tn
						for(var/obj/Items/Enchantment/Teleport_Amulet/ta in world)
							var/atom/a=ta.loc
							if(!ismob(a))
								continue//only warp mobs
							if(ta.NoTPZone(src.UseableDead, src.UseableArcane))//do not list teleport nexuses in dead zones
								continue
							if(ta.Password!=src.FocalPassword)//make sure the password is the same
								continue
							if(!ta.Password)//do not link all the unset necklaces
								continue
							if(ta in src.FocalExceptions)
								continue
							if(!src.ZWarp)
								if(a.z==User.z)
									continue
							Focals["[ta.name]"]=ta
					if(src.FocalPerson)
						for(var/mob/Players/m in players)
							if(m.NoTPZone(src.UseableDead, src.UseableArcane))
								continue//disallow dead / arcane as targets (usually)
							if(m==User)
								continue//do not warp to ... yourself.
							if(!src.NoSignature)
								if(!User.HasSpiritPower())
									if(!(m.EnergySignature in User.EnergySignaturesKnown))
										continue
									if(!m.EnergySignature)
										continue
									if(m.PowerControl<=25)
										continue
							if(!src.ZWarp)
								if(m.z != User.z)
									continue
							Focals["[m.name]"]=m
					if(Focals.len>0)
						Modes.Add("Focal")
				if(src.DiveWarp)
					Modes.Add("Dive to the Heart")
				if(src.UnderworldWarp)
					Modes.Add("Traverse Underworld")
				if(src.DepthsWarp)
					Modes.Add("Traverse Depths")
				if(src.DaatWarp)
					Modes.Add("Traverse Da'at")
				//	Modes.Add("Traverse Underworld")

				if(Modes.len==2)
					Modes.Remove("Cancel")
				var/turf/Destination
				switch(input(User, "What mode of teleport do you want to use?", "[src]") in Modes)
					if("Cancel")
						User << "Cancelling"
						return
					if("XYZ")
						var/tx
						var/ty
						if(src.NoXY)
							tx=User.x
							ty=User.y
						else
							tx=input(User, "X coordinate of destination?", "[src]") as num|null
							if(!tx || tx<0)
								return
							ty=input(User, "Y coordinate of destination?", "[src]") as num|null
							if(!ty || ty<0)
								return
						var/tz
						var/turf/t
						if(src.ZWarp)
							if(!src.NoXY)//if they cant change xy, then z is the only thing TO change
								switch(alert(User, "Do you want to change Z planes?", "[src]", "No", "Yes"))
									if("No")//stay on z plane
										tz=User.z
							if(!tz)
								tz=input(User, "Z coordinate of destination?", "[src]") as num|null
								if(!tz || tz<0)
									return
								if(tz==17)
									var/obj/Skills/Teleport/Traverse_Daat/d = new()
									d = locate() in User
									if(!d)
										User << "You lack the authority to teleport to this place at will."
										return
								if(tz == MAJIN_ABSORB_Z)
									User << "You cannot teleport here."
									return
							t=locate(tx, ty, tz)
							if(t)
								Destination=t
							else
								User << "Target coordinates not found."
								return
						else
							t=locate(tx, ty, User.z)
							if(t)
								Destination=t
							else
								User<< "Target coordinates not found."
								return
					if("Depths Focal")
						var/obj/Skills/Teleport/Traverse_Depths/td = User.findOrAddSkill(/obj/Skills/Teleport/Traverse_Depths);
						var/list/options = list("Nevermind") + td.depthsFocals;
						var/choice = input(User, "What focal do you want to teleport to?", "Personal Focal Teleportation") in options;
						if(choice=="Nevermind") return;
						ReturnX = User.x;
						ReturnY = User.y;
						ReturnZ = User.z;
						for(var/obj/Arcane/ArcaneFocal/f in world)
							if(f.name == choice)
								Destination = locate(f.x, f.y, f.z);
								break;
					if("Focal")
						if(Focals.len<2)
							User << "No focals to teleport to."
							return
						if(src.FocalSummon)
							if(src.MassSummon)
								for(var/atom/x in Focals)
									if(!ismob(x.loc))
										Focals.Remove(x)
								if(Focals.len<2)
									User << "There is no one with an attached focal to mass summon."
									return
								for(var/atom/x in Focals)
									if(ismob(x))
										var/mob/x2=x
										OMsg(x2, "[x2] is summoned away!")
										x2.Move(locate(User.x, User.y, User.z))
							else
								Focal=input(User, "What focal do you want to bring to you?", "[src]") in Focals
								if(Focal=="Cancel")
									return
								if(src.FocalArcane)
									User << "Arcane focals do not have summoning functionality."
									return
								if(src.FocalNexus)
									var/obj/Items/Enchantment/tn=Focals[Focal]
									var/atom/m=tn.loc
									if(ismob(m.loc))
										var/mob/m2=m
										OMsg(m2, "[m2] is summoned away!")
										m2.Move(locate(User.x, max(1, User.y-1), User.z))
									else
										User << "[tn] is not attached to anyone who can be summoned."
										return
						else
							Focal=input(User, "What focal do you want to move to?", "[src]") in Focals
							if(Focal=="Cancel")
								return
							if(src.FocalArcane)
								var/obj/Arcane/ArcaneFocal/f1=Focals[Focal]
								User.Move(locate(f1.x, f1.y, f1.z))
							else if(src.FocalNexus)
								var/obj/Items/Enchantment/nex=Focals[Focal]
								if(ismob(nex.loc))
									Destination=locate(nex.loc.x, nex.loc.y, nex.loc.z)
								else if(isturf(nex.loc))
									Destination=locate(nex.x, nex.y, nex.z)
							else if(src.FocalPerson)
								var/mob/m = Focals["[Focal]"]
								if(m.z==17)
									var/obj/Skills/Teleport/Traverse_Daat/d = new()
									d = locate() in User
									if(!d)
										User << "You lack the authority to teleport to this place at will."
										return
								Destination=locate(m.x,m.y,m.z)
					if("Fall Through")
						Destination=locate(User.x, User.y, src.FallThrough)
					if("Traverse Underworld")
						if(User.HasSpiritPower() && !User.CheckSpecial("Cancer Cloth"))
							src.ReturnX=User.x
							src.ReturnY=User.y
							src.ReturnZ=User.z
							Destination=locate(glob.DEATH_LOCATION[1], glob.DEATH_LOCATION[2], glob.DEATH_LOCATION[3])
						else
							src.ReturnX=User.x
							src.ReturnY=User.y
							src.ReturnZ=User.z
							Destination=locate(glob.VOID_LOCATION[1], glob.VOID_LOCATION[2], glob.VOID_LOCATION[3])
					if("Traverse Depths")
						// Intentionally fully gated for this wipe per cosmology setup.
						// Do not restore the locate(198, 221, 8) destination here without
						// confirming with the wipe lead - the deny is by design, not a
						// missed early-return bug.
						User << "You're already in the Depths, this wipe, love."
						return;
					if("Traverse Da'at")
						src.ReturnX=User.x
						src.ReturnY=User.y
						src.ReturnZ=User.z
						Destination=locate(285, 29, 17)
					if("Dive to the Heart")
						src.ReturnX=User.x
						src.ReturnY=User.y
						src.ReturnZ=User.z
						Destination=locate(25, 477, 16)


				if(src.WindUpIcon)
					spawn()
						LeaveImage(User, src.WindUpIcon, src.WindUpX, src.WindUpY, 0, 1, 1, src.WindUp*10)
				sleep(src.WindUp)
				if(src.WindDownIcon)
					spawn()
						LeaveImage(User, src.WindDownIcon, src.WindDownX, src.WindDownY, 0, 1, 1, src.WindDown*10)

				if(src.FocalSummon)
					OMsg(User, "[User] [src.TeleportMessage]")
				else
					if(src.NoPassengers && User.Grab)
						User << "You can't use [src] while having someone grabbed!"
						return
					OMsg(User, "[User] [src.TeleportMessage]")
					if(!src.NoPassengers)
						for(var/mob/Player/m in view(1, User))
							m.Move(Destination)
							if(src.PassengerHeal)
								if(m.KO)
									m.Conscious()
								m.BPPoison=1
								m.BPPoisonTimer=0
								m.Sheared=0
								m.Maimed=0
								m.MortallyWounded=0
								m.SenseRobbed=0
								m.HealWounds(100)
								m.HealFatigue(100)
								m.HealHealth(100)
								m.HealEnergy(100)
								m.HealMana(100)
							OMsg(m, "[m] [src.ArriveMessage]")
					//User.Move(Destination)
					User.loc = locate(Destination.x, Destination.y, Destination.z)
					OMsg(User, "[User] [src.ArriveMessage]")

				if(src.ManaCost)
					User.LoseMana(src.ManaCost)
				if(src.CapacityCost)
					User.TakeManaCapacity(src.CapacityCost)
				src.Cooldown()

			Return(var/mob/User)
				OMsg(User, "[User] [src.ReturnMessage]")
				if(!src.NoPassengers)
					for(var/mob/Player/m in view(1, User))
						m.Move(locate(src.ReturnX, src.ReturnY, src.ReturnZ))
						OMsg(m, "[m] [src.ArriveMessage]")
				User.Move(locate(src.ReturnX, src.ReturnY, src.ReturnZ))
				src.ReturnX=0
				src.ReturnY=0
				src.ReturnZ=0
				OMsg(User, "[User] [src.ArriveMessage]")
