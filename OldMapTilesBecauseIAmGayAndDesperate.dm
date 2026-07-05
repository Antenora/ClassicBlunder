//these are just here so i can easily open old maps.
obj/BoatConsole
obj/BoatEntrance
obj/Items/Tech/PunchingBag
obj/Items/Tech/Log
obj/Items/Tech/CameraProbe
obj/Items/Tech/ConveyorBelt
	var/Active
mob/Animals/Peaceful/Fly

area
	mouse_opacity=0
	var/WeatherOn=0
	var/Temperature=0
	var/TemperatureType
//	var/WeatherOverride=0
	var/WeatherOdds=0
//	icon='Weather.dmi'
	Outside
		layer=5
		PirateColonyOutside
			TemperatureType="ThinAtmo"
		Planet
			var/Drillable=1
			var/Rate
			Earth
				Underwater
					icon='Underwater.dmi'
					Rate=1.5
					layer=5
					WeatherOn=0
					Level=1.5*1000000
				EarthUnderground
					icon='Dark.dmi'
					Rate=3.0
					layer=4
					WeatherOn=0
					Level=3*1000000
				Rate=2.5
				//WeatherOdds=80
				//WeatherOn=1
				Level=2.5*1000000
			Namek
				NamekUnderwater
					icon='NamekUnderwater.dmi'
					Rate=4.0
					layer=6
					WeatherOn=0
				NamekUnderground
					icon='Dark.dmi'
					Rate=5.5
					layer=5
					WeatherOn=0
				Rate=3.0
				//WeatherOdds=0
				//WeatherOn=0
			Vegeta
				VegetaUnderwater
					icon='Underwater.dmi'
					Rate=2.1
					layer=6
					WeatherOn=0
					Level=2.1*1000000
				VegetaUnderground
					icon='Dark.dmi'
					Rate=3.1
					layer=5
					WeatherOn=0
					Level=3.1*1000000
				Rate=2.75
				//WeatherOdds=80
				//WeatherOn=1
				Level=2.75*1000000
			Ice
				TemperatureType="Cold"
				IceUnderwater
					icon='Underwater.dmi'
					layer=6
					Rate=7.0
					WeatherOn=0
					Temperature=0.01
				IceUnderground
					icon='Dark.dmi'
					layer=5
					Rate=6.0
					WeatherOn=0
					Temperature=0.015
				Rate=5.0
				Temperature=0
				//WeatherOdds=80
				//WeatherOn=0
			Arconia
				ArconiaUnderwater
					icon='Underwater.dmi'
					layer=6
					Rate=3.0
					WeatherOn=0
				ArconiaUnderground
					icon='Dark.dmi'
					layer=5
					Rate=3.1
					WeatherOn=0
				Rate=2.5
				//WeatherOdds=70
				//WeatherOn=1
			Sanctuary
				SanctuaryUnderwater
					icon='Underwater.dmi'
					Rate=2.95
					layer=6
					WeatherOn=0
					Level=1000000
				SanctuaryUnderground
					icon='Dark.dmi'
					Rate=5.0
					layer=5
					WeatherOn=0
					Level=1000000
				Rate=2.8
				//WeatherOdds=80
				//WeatherOn=1
				Level=1000000
			Afterlife
				Rate=1.5
				//WeatherOdds=0
				//WeatherOn=1
			Heaven
				Rate=2.0
				//WeatherOdds=0
				//WeatherOn=1
			Hell
				Rate=2.0
				Temperature=0
				TemperatureType="Heat"
				//WeatherOdds=50
				//WeatherOn=1
			Danger
				Void
					icon='Void.dmi'
					layer=6
				BloodRain
					icon='BloodRain.dmi'
					icon_state="storm"
					layer=6

			AlienRuin
				ARUnderground
//					icon_state="Dark"
					Rate=6.0
					Level=1000000
				Rate=3.0
				Level=1000000
			AlienGrassland
				Level=2500000
				AGUnderground
//					icon_state="Dark"
					Rate=3.0
				Rate=2.0
			AlienOcean
				AOUnderwater
					icon='Underwater.dmi'
					Rate=2.1
					Level=6000000
					WeatherOn=0
				AOUnderground
					icon='Dark.dmi'
					Rate=3.5
					Level=10000000
					WeatherOn=0
				Rate=2.0
				Level=5000000
				WeatherOn=1
				WeatherOdds=25
			AlienArctic
				TemperatureType="Cold"
				AAUnderground
//					icon_state="Dark"
					Rate=2.5
					Temperature=0
				Rate=2.0
				Temperature=0
			AlienDesolate
				TemperatureType="Heat"
				ADUnderground
//					icon_state="Dark"
					Rate=5.0
					Temperature=0
				Rate=2.0
				Temperature=0
			HBTC
				Rate=0
				WeatherOdds=0
			Void
				Rate=0
				WeatherOdds=0
			Rave
				Rate=0
				WeatherOdds=100
	Inside
/*	proc/Weather(Timer,Clear_Weather,list/WeathersDay,list/WeathersNight)
//		icon='Weather.dmi'
//		return//no weather
		if(Timer)
			while(src)
				sleep(Timer)
				if(prob(Clear_Weather))
					if(WeatherOn)
						if(Time=="Day")
							icon=null
						else if(Time=="Night")
							icon='Dark.dmi'
				else
					if(WeatherOn&&WeathersDay.len) // Weathers.len checks if the list has any -entries-. It might exist but be empty, and then it derps.
						if(Time=="Day")
							icon=pick(WeathersDay)
						else if(Time=="Night")
							icon=pick(WeathersNight)*/
obj/Items/Tech
	AutoDrill
		Savable=0
		New()
			var/image/A=image(icon='ArtificalObj.dmi',icon_state="1",pixel_y=16,pixel_x=-16)
			var/image/Z=image(icon='ArtificalObj.dmi',icon_state="2",pixel_y=16,pixel_x=16)
			var/image/C=image(icon='ArtificalObj.dmi',icon_state="3",pixel_y=-16,pixel_x=-16)
			var/image/D=image(icon='ArtificalObj.dmi',icon_state="4",pixel_y=-16,pixel_x=16)
			overlays.Remove(A,Z,C,D)
			overlays.Add(A,Z,C,D)
	Regenerator
		TechType="RegenTankTechnology"
		icon='Lab.dmi'
		icon_state="Tube"
		var/OverlayKiller=0
		Pickable=0
		Savable=0
		New()
			var/image/A=image(icon='Lab.dmi',icon_state="TubeTop",layer=5,pixel_y=32)
			overlays-=A
			overlays+=A
	SpaceTravel
obj/PodConsole
	var/Launching
	Health=100000000000000
	LogPEndurance=100000000000000
	var/SpeakerToggle=0
	var/PodID
	Grabbable=0
	icon='Tech.dmi'
	icon_state="ShipConsole"
	verb/ShipSpeakerToggle()
		set src in oview(1)
		if(SpeakerToggle==0)
			SpeakerToggle=1
			usr<<"Ship speakers activated."
		else
			SpeakerToggle=0
			usr<<"Ship speakers deactivated."
obj/ShipConsole
	var/Launching
	var/SpeakerToggle=0
	Health=1.#INF
	Grabbable=0
	icon='Tech.dmi'
	icon_state="ShipConsole"
	verb/Muffin_Button()
		set src in oview(1)
		usr<< "The muffin button is all that remains of this once proud feature."
		sleep(10)
		usr<<"And yet... it does not exist."
		return
/*	verb/Use()

	verb/Leave()

	verb/View()

	verb/Launch()*/


/*						if(Q.z==14||Q.z==18||Q.z==6)
							var/turf/B=Q.loc
							if(istype(B.loc,/area/Outside/Planet/AlienRuin))
								for(var/obj/Planets/AlienRuin/x in world)
									Q.loc=x.loc
									return
//							else if(istype(B.loc,/area/Outside/Planet/AlienGrassland))
//								for(var/obj/Planets/AlienGrassland/x in world)
//									Q.loc=x.loc
//									return
							else if(istype(B.loc,/area/Outside/Planet/AlienOcean))
								for(var/obj/Planets/AlienOcean/x in world)
									Q.loc=x.loc
									return
//							else if(istype(B.loc,/area/Outside/Planet/AlienArctic))
//								for(var/obj/Planets/AlienArctic/x in world)
//									Q.loc=x.loc
//									return
							else if(istype(B.loc,/area/Outside/Planet/AlienDesolate))
								for(var/obj/Planets/AlienDesolate/x in world)
									Q.loc=x.loc
									return
							else if(istype(B.loc,/area/Outside/Planet/Sanctuary))
								for(var/obj/Planets/Sanctuary/x in world)
									Q.loc=x.loc
									return
//							else if(Q.z==6)
//								for(var/obj/Planets/PirateColony/x in world)
//									Q.loc=x.loc
//									return
*/

//						else
obj/ShipAirlock
	icon='Special.dmi'
	icon_state="Special7"
	Health=1.#INF
	Grabbable=0

obj/Items/ShipAccessories
	Alarm
		icon='shipalarm.dmi'
		icon_state="booting"
		var/active=1


	PodLauncher
		density=1
		icon='Tech.dmi'
		icon_state="PodLauncher"
obj/
	HBTCDoor
		icon='Doors.dmi'
		icon_state="Closed1"
		Health=1.#INF
		Grabbable=0
turf/Special
	DiveSword
		var/typee
		var/antispam
		density=1
		icon='Doors.dmi'
		icon_state="Closed1"
/*		New()
			Open()
			src.antispam=null
			..()*/
		Click()
			usr<<"How do you see this?"
			return
			/*
			..()
			if(usr.DiveLock)
				usr<<"Finish picking or giving up before clicking another one."
				return
			if(!usr.DiveWeapon)
				if(usr in oview(1,src))
					usr.DiveLock=1
					if(usr.Alert("Are you sure you want to pick the sword?"))
						usr.DiveWeapon="Sword"
						usr.ComboPlus=1
						usr << "Your path is set."
						usr << "Now...what will you give up in exchange?"
						usr.StrengthMod*=1.25
						usr.Strength*=1.25
						usr.ForceMod*=1.25
						usr.Force*=1.25
						usr.OffenseMod*=1.25
						usr.Offense*=1.25
						usr.DiveLock=0
						return
					usr.DiveLock=0
			else if(usr.DiveWeapon)
				if(usr.DiveWeapon=="Sword")
					usr << "Can't let you give up what you've got, Riku."
					return
				if(usr.Alert("Are you sure you want to give up the sword?"))
					usr.DiveAbandon="Sword"
					usr << "Your journey begins in the dead of night."
					usr << "Your road won't be easy, but a rising sun awaits you at the end."
					usr.StrengthMod/=1.25
					usr.Strength/=1.25
					usr.ForceMod/=1.25
					usr.Force/=1.25
					usr.OffenseMod/=1.25
					usr.Offense/=1.25
					usr.loc = locate(usr.PrevX, usr.PrevY, usr.PrevZ)
					usr.contents+=new/obj/Skills/Keyblade/CallKeyblade
					usr.contents+=new/obj/Skills/Keyblade/BestowKeyblade*/
	DiveShield
		var/typee
		var/antispam
		density=1
		icon='Doors.dmi'
		icon_state="Closed1"
/*		New()
			Open()
			src.antispam=null
			..()*/
		Click()
			usr<<"How do you see this?"
			return
			/*
			..()
			if(usr.DiveLock)
				usr<<"Finish picking or giving up before clicking another one."
				return
			if(!usr.DiveWeapon)
				if(usr in oview(1,src))
					usr.DiveLock=1
					if(usr.Alert("Are you sure you want to pick the shield?"))
						usr.DiveWeapon="Shield"
						usr.SecondChance=1
						usr << "Your path is set."
						usr << "Now...what will you give up in exchange?"
						usr.EnduranceMod*=1.15
						usr.Endurance*=1.15
						usr.ResistanceMod*=1.15
						usr.Resistance*=1.15
						usr.DefenseMod*=1.15
						usr.Defense*=1.15
						usr.DiveLock=0
						return
					usr.DiveLock=0
			else if(usr.DiveWeapon)
				if(usr.DiveWeapon=="Shield")
					usr << "Can't let you give up what you've got, Kairi."
					return
				if(usr.Alert("Are you sure you want to give up the shield?"))
					usr.DiveAbandon="Shield"
					usr << "Your journey begins at dawn."
					usr << "As long as the sun is shining, your journey should be a pleasant one."
					usr.EnduranceMod/=1.15
					usr.Endurance/=1.15
					usr.ResistanceMod/=1.15
					usr.Resistance/=1.15
					usr.DefenseMod/=1.15
					usr.Defense/=1.15
					usr.loc = locate(usr.PrevX, usr.PrevY, usr.PrevZ)
					usr.contents+=new/obj/Skills/Keyblade/CallKeyblade
					usr.contents+=new/obj/Skills/Keyblade/BestowKeyblade*/
	DiveStaff
		var/typee
		var/antispam
		density=1
		icon='Doors.dmi'
		icon_state="Closed1"
/*		New()
			Open()
			src.antispam=null
			..()*/
		Click()
			usr<<"How do you see this?"
			return
/*			..()
			if(usr.DiveLock)
				usr<<"Finish picking or giving up before clicking another one."
				return
			if(!usr.DiveWeapon)
				if(usr in oview(1,src))
					usr.DiveLock=1
					if(usr.Alert("Are you sure you wish to choose the staff?"))
						usr.DiveWeapon="Staff"
						usr.MPRage=1
						usr << "Your path is set."
						usr << "Now...what will you give up in exchange?"
						usr.Recovery*=1.25
						usr.EnergyMod*=1.5
						usr.EnergyMax*=1.5
						usr.Energy*=1.5
						usr.DiveLock=0
						return
					usr.DiveLock=0
			else if(usr.DiveWeapon)
				if(usr.DiveWeapon=="Staff")
					usr << "Can't let you give up what you've got, Sora."
					return
				if(usr.Alert("Are you sure you want to give up the staff?"))
					usr.DiveAbandon="Staff"
					if(usr.Alert("Are you sure you wish to abandon the staff?"))
						usr.DiveAbandon="Staff"
						usr << "Your journey begins at midday."
						usr << "Keep a steady pace, and you'll come through fine."
						usr.Recovery/=1.25
						usr.EnergyMod/=1.5
						usr.EnergyMax/=1.5
						usr.Energy/=1.5
						usr.loc = locate(usr.PrevX, usr.PrevY, usr.PrevZ)
						usr.contents+=new/obj/Skills/Keyblade/CallKeyblade
						usr.contents+=new/obj/Skills/Keyblade/BestowKeyblade*/
obj/Effects
	FusionCamera
		Lifetime = -1 // Persistent map prop for fusion dance mechanic — opts out of the Effect fade/finalize chain.
obj/Spirit
	icon='NewObjects.dmi'
	icon_state="35"
	Health=1.#INF
	Grabbable=0
	var/list/who=new
/*	verb/Use()
		set src in oview(1)
		if(who.Find(usr.key))
			if(who[usr.key]<=Year)
				usr<<"You cannot use this untl next month."
				return
			else
				if(prob(20))
					who.Remove(usr.key)
					usr<<"...Get out of here."
					usr.loc=locate(236,260,8)

				else
					usr<<"...You're out of luck..try again next month."
					who[usr.key]=Year
		else
			usr<<"..Welcome to The Final Realms! You may train, conversate with others...and enjoy the rest of eternity haha! You may talk to me once every month starting next month to see if I qualify you to get out of this dump!"
			who.Add("[usr.key]"=Year)*/

	verb/Use(var/mob/A in world)
		set src in oview(1)
		set category="Other"
		set hidden = 1
		usr<<"This does nothing right now."