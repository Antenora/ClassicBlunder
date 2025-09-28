
//We need to setup so that admins can impend new entries and save them.
var/list/squad_database = list(
	"basic bot" = new/ai_sheet(id="basic bot",properties=list(icon='Android1.dmi',name="Basic Bot",\
		Potential=0.3,\
		StrMod=2,EndMod=2,ForMod=2,OffMod=2,DefMod=2,SpdMod=2,\
		ai_spammer=0.5),\
		techniques=list("/obj/Skills/AutoHit/Focus_Punch","/obj/Skills/AutoHit/Sweeping_Kick","/obj/Skills/Projectile/Gear/Plasma_Blaster")),
	"battle bot" = new/ai_sheet(id="battle bot",properties=list(icon='Android2.dmi',name="Battle Bot",\
		Potential=0.5,\
		StrMod=3,EndMod=2,ForMod=2,OffMod=2,DefMod=2,SpdMod=2,\
		ai_spammer=1),\
		techniques=list("/obj/Skills/AutoHit/Flying_Kick","/obj/Skills/Projectile/Dragon_Nova")),
	"bullet bot" = new/ai_sheet(id="bullet bot",properties=list(icon='Android4.dmi',name="Bullet Bot",\
		Potential=0.5,\
		StrMod=2,EndMod=3,ForMod=2,OffMod=2,DefMod=2,SpdMod=2,\
		ai_spammer=1),\
		techniques=list("/obj/Skills/Projectile/Gear/Plasma_Gatling","/obj/Skills/Projectile/Gear/Plasma_Blaster")),
	"guardian bot" = new/ai_sheet(id="guardian bot",properties=list(icon='Android11.dmi',name="Guardian Bot",\
		Potential=0.6,\
		StrMod=3,EndMod=3,ForMod=3,OffMod=3,DefMod=3,SpdMod=3,\
		ai_spammer=1),\
		techniques=list("/obj/Skills/AutoHit/Flying_Kick","/obj/Skills/AutoHit/Force_Palm","/obj/Skills/Projectile/Dragon_Nova","/obj/Skills/Projectile/Gear/Plasma_Blaster")),\
	"gajalaka" = new/ai_sheet(id="gajalaka",properties=list(icon='GajalakaWild.dmi',name="Gajalaka",\
		Potential=0.3,\
		StrMod=2,EndMod=2,ForMod=2,OffMod=2,DefMod=2,SpdMod=2,\
		ai_spammer=0.5),\
		techniques=list("/obj/Skills/AutoHit/Focus_Punch","/obj/Skills/AutoHit/Sweeping_Kick","/obj/Skills/Projectile/Gear/Plasma_Blaster")),
	"gajalaka warrior" = new/ai_sheet(id="gajalaka warrior",properties=list(icon='GajalakaWild.dmi',name="Gajalaka Warrior",\
		Potential=0.5,\
		StrMod=3,EndMod=2,ForMod=2,OffMod=2,DefMod=2,SpdMod=2,\
		ai_spammer=1),\
		techniques=list("/obj/Skills/AutoHit/Flying_Kick","/obj/Skills/Projectile/Force_Palm")),
	"gajalaka thrower" = new/ai_sheet(id="gajalaka thrower",properties=list(icon='GajalakaWild.dmi',name="Gajalaka Thrower",\
		Potential=0.5,\
		StrMod=2,EndMod=3,ForMod=2,OffMod=2,DefMod=2,SpdMod=2,\
		ai_spammer=1),\
		techniques=list("/obj/Skills/Projectile/Gear/Plasma_Gatling","/obj/Skills/Projectile/Blast")),
	"gajalaka champion" = new/ai_sheet(id="gajalaka champion",properties=list(icon='GajalakaWild.dmi',name="Gajalaka Champion",\
		Potential=0.6,\
		StrMod=3,EndMod=3,ForMod=3,OffMod=3,DefMod=3,SpdMod=3,\
		ai_spammer=1),\
		techniques=list("/obj/Skills/AutoHit/Flying_Kick","/obj/Skills/AutoHit/Force_Palm","/obj/Skills/Projectile/Dragon_Nova","/obj/Skills/Projectile/Blast")),\
	"gajalaka berserker" = new/ai_sheet(id="gajalaka berserker",properties=list(icon='GajalakaWild.dmi',name="Gajalaka Berserker",\
		Potential=0.4,\
		StrMod=3,EndMod=3,ForMod=3,OffMod=3,DefMod=3,SpdMod=3,\
		ai_spammer=1),\
		techniques=list("/obj/Skills/AutoHit/Flying_Kick","/obj/Skills/AutoHit/Force_Palm","/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Turns_Red")),\
	"oliphant spirit" = new/ai_sheet(id="oliphant spirit", properties=list(icon='knight.dmi', name="Oliphant Spirit",\
		Potential = 0.4,\
		StrMod = 3, EndMod = 0.2, ForMod = 3, OffMod = 3, DefMod = 1, SpdMod = 2, Health = 20,\
		ai_spammer=1, ai_movement_type = "ranged"),\
		techniques = list("/obj/Skills/Projectile/Dragon_Nova","/obj/Skills/Projectile/Kienzan", "/obj/Skills/Projectile/Tracking_Bomb")),\
)


mob/Player/AI
	var/tmp/obj/Skills/Companion/PlayerCompanion/Squad/in_squad

obj/Skills/Companion
	PlayerCompanion
		cooldown=10

		Squad

			var
				list/squad = list() //Squad track AI ids. Initial summon associates a name to them, which players may modify.
				max_squad = 5
				list/team = list()
				formation
			proc
				AddNewMember(id)

					var/ai_sheet/a = squad_database[id]
					if(a)
						/* Full sheet allows data about individual squad members to be tracked and modified.
						var/ai_sheet/new_sheet = new //Squad members are modifiable like this. Important for players basically.
						for(var/v in a.vars)
							new_sheet.vars[v] = a.vars[v]
						new_sheet.properties[name] = "[new_sheet.properties[name]] [rand(1,9999)]"
						*/
						var newname
						if(a.properties[name]) newname = a.properties[name]
						else newname = id
						var/index = 1
						while(("[newname] [index]" in squad))
							index++
						squad += "[newname] [index]"
						squad["[newname] [index]"] = id //Soon this should just be ai_sheet datum.
				RemoveMember(id)
					squad -= id
			verb
				PlayerEditSquad()
					var/c = input("Which?") as null|anything in squad
					if(c)
						if(istext(squad[c])) //just a id
							switch(input("Would you like to change [c]'s name?") in list("Yes","No"))
								if("Yes")
									var new_name
									while(!new_name)
										new_name = input("Name") as text
									c = new_name
						else
							return



			Companion_Summon()
				set src in usr
				set category = "Companion"
				if(Using)
					return
				Using=1
				var has_f_out
				for(var/mob/Player/AI/a in active_ai)
					animate(a, alpha=0, time=10)
					usr.ai_followers-=a
					active_ai-=a
					spawn(10)
						del(a)
					has_f_out=1
				if(has_f_out)
					Using=0
					return

				if((world.realtime < last_use + cooldown))
					usr << "You cannot summon any companions right now, it is still on cooldown. ([(world.realtime - last_use)/10] seconds)"
					return
				var/limit = 0
				for(var/index in squad)
					limit++
					if(limit > max_squad) break

					var/mob/Player/AI/a = new
					ticking_ai.Remove(a)
					companion_ais += a
					a.alpha=0
					a.loc = locate(usr.x,usr.y,usr.z)
					animate(a, alpha=255, time=10)
					a.ai_owner = usr
					a.ai_follow= formation ? formation : 1
					a.ai_hostility=0

					a.AI_Database_Sync(index, squad_database)
					a.ai_focus_owner_target = companion_focus_target

					a.ko_death = companion_ko_death
					a.Timeless = 1

					a.ai_team_fire=companion_team_fire
					a.ai_focus_owner_target = companion_focus_target
					a.Potential = usr.Potential * a.Potential
					usr.ai_followers +=a
					a.ai_alliances = list()
					a.ai_alliances += "[usr.ckey]"
					a.in_squad = src
					for(var/alliance in team) a.ai_alliances += alliance
					active_ai+=a
					a.AIGain()
					a.ai_state = "Idle"
				last_use = world.time
				Using=0