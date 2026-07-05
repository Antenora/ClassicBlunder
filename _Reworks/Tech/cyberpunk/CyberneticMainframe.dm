//placeholder
/obj/Skills
	Utility
		Cyborg_Integration
			desc="Integrate gear into yourself!"
			verb/Cyborg_Integration()
				set category="Utility"
				set hidden = 1
				if(src.Using)
					return
				if(usr.GetAndroidIntegrated()<3+(usr.AscensionsAcquired*2))
					src.Using=1
					var/obj/Items/Gear/Choice
					var/list/obj/Items/Gear/IG=list("Cancel")
					for(var/obj/Items/Gear/g in usr)
						if(istype(g, /obj/Items/Gear/Prosthetic_Limb))
							continue
						if(!g.Integrateable)
							continue
						IG.Add(g)
					if(IG.len<2)
						usr << "You don't have any gear capable of being integrated into your chasis."
						src.Using=0
						return
					Choice=input(usr, "What gear do you want to integrate into your chasis?", "Integrate") in IG
					if(Choice=="Cancel")
						src.Using=0
						return
					var/obj/Skills/NewS
					switch(Choice.type)
						if(/obj/Items/Gear/Deflector_Shield)
							NewS=new/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Deflector_Shield
						if(/obj/Items/Gear/Bubble_Shield)
							NewS=new/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Bubble_Shield
						if(/obj/Items/Gear/Jet_Boots)
							NewS=new/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Jet_Boots
						if(/obj/Items/Gear/Jet_Pack)
							NewS=new/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Jet_Pack
						if(/obj/Items/Gear/Plasma_Blaster)
							NewS=new/obj/Skills/Projectile/Gear/Integrated/Integrated_Plasma_Blaster
						if(/obj/Items/Gear/Plasma_Rifle)
							NewS=new/obj/Skills/Projectile/Gear/Integrated/Integrated_Plasma_Rifle
						if(/obj/Items/Gear/Plasma_Gatling)
							NewS=new/obj/Skills/Projectile/Gear/Integrated/Integrated_Plasma_Gatling
							NewS:Continuous=0
							NewS:Blasts=100
						if(/obj/Items/Gear/Missile_Launcher)
							NewS=new/obj/Skills/Projectile/Gear/Integrated/Integrated_Missile_Launcher
						if(/obj/Items/Gear/Chemical_Mortar)
							NewS=new/obj/Skills/Projectile/Gear/Integrated/Integrated_Chemical_Mortar
						if(/obj/Items/Gear/Progressive_Blade)
							NewS=new/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Progressive_Blade
						if(/obj/Items/Gear/Lightsaber)
							NewS=new/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Lightsaber
						if(/obj/Items/Gear/Incinerator)
							NewS=new/obj/Skills/AutoHit/Gear/Integrated/Integrated_Incinerator
						if(/obj/Items/Gear/Freeze_Ray)
							NewS=new/obj/Skills/AutoHit/Gear/Integrated/Integrated_Freeze_Ray
						if(/obj/Items/Gear/Pile_Bunker)
							NewS=new/obj/Skills/Queue/Gear/Integrated/Integrated_Pile_Bunker
						if(/obj/Items/Gear/Power_Fist)
							NewS=new/obj/Skills/Queue/Gear/Integrated/Integrated_Power_Fist
						if(/obj/Items/Gear/Blast_Fist)
							NewS=new/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Blast_Fist
						if(/obj/Items/Gear/Chainsaw)
							NewS=new/obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated/Integrated_Chainsaw
						if(/obj/Items/Gear/Power_Claw)
							NewS=new/obj/Skills/Queue/Gear/Integrated/Integrated_Power_Claw
						if(/obj/Items/Gear/Hook_Grip_Claw)
							NewS=new/obj/Skills/Queue/Gear/Integrated/Integrated_Hook_Grip_Claw
						if(/obj/Items/Gear/Missile_Massacre)
							NewS=new/obj/Skills/Projectile/Gear/Integrated/Integrated_Missile_Massacre
						if(/obj/Items/Gear/Ultra_Laser)
							NewS=new/obj/Skills/Projectile/Gear/Integrated/Integrated_Ultra_Laser
						else
							usr << "Ruh roh.  Something went wrong.  Yell at Yan."
							src.Using=0
							return
					usr.AddSkill(NewS)
					usr << "You've integrated [Choice] into your chasis!"
					del Choice
					src.Using=0
					return