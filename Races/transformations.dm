#define TRANS_ONE_POTENTIAL 20
#define TRANS_TWO_POTENTIAL 40
#define TRANS_THREE_POTENTIAL 60
#define TRANS_FOUR_POTENTIAL 80
#define TRANS_FIVE_POTENTIAL 100

globalTracker
	var/lockTransAutomation = TRUE
	var/list/transLocked = list()///transformation/saiyan/super_saiyan,/transformation/saiyan/hellspawn_super_saiyan,/transformation/saiyan/super_saiyan_2,/transformation/saiyan/super_saiyan_3)

mob/var/transActive = 0
mob/var/bypassTransAutomation = 0
mob/var/transUnlocked = 0

mob/proc/Transform(type)
	if(type)
		//old stuff; high chance its wonky. its mainly hotwired in here as a legacy from the old transform/revert
		switch(type)
			if("Tension")
				for(var/obj/Skills/Buffs/SpecialBuffs/High_Tension/T in src)
					src.HighTension(T.Tension)
					T.Tension=0

			if("Jagan")
				src.Jaganshi()

			if("Weapon")
				src.WeaponSoul()
		return
	race.transformations[transActive+1].transform(src)

mob/proc/Revert(type)
	if(type)
		//old stuff; high chance its wonky. its mainly hotwired in here as a legacy from the old transform/revert
		switch(type)
			if("Tension")
				src.RevertHT()
			if("Jagan")
				src.RevertJaganshi()
			if("Weapon")
				src.RevertWS()
		return

	race.transformations[transActive].revert(src)

transformation
	var
		list/passives
		list/class_passives
		strength = 1
		strengthadd = 0
		endurance = 1
		enduranceadd = 0
		force = 1
		forceadd = 0
		offense = 1
		offenseadd = 0
		defense = 1
		defenseadd = 0
		speed = 1
		speedadd=0
		regeneration
		anger
		unlock_potential = -1
		intimidation

		BioArmor
		BioArmorMax

		transformation_message
		detrans_message

		stored_profile
		form_profile

		stored_base
		stored_base_x
		stored_base_y
		icon/form_base
		form_base_x
		form_base_y

		image/form_hair
		form_hair_icon
		form_hair_x
		form_hair_y

		image/form_aura
		form_aura_icon
		form_aura_icon_state
		form_aura_x
		form_aura_y

		image/form_aura_underlay
		form_aura_underlay_icon
		form_aura_underlay_icon_state
		form_aura_underlay_x
		form_aura_underlay_y
		TransClass

		image/form_icon_1
		form_icon_1_icon
		form_icon_1_icon_state
		form_icon_1_x
		form_icon_1_y
		form_icon_1_layer = 3

		image/form_underlay_1
		form_underlay_1_icon
		form_underlay_1_icon_state
		form_underlay_1_x
		form_underlay_1_y

		image/form_icon_2
		form_icon_2_icon
		form_icon_2_icon_state
		form_icon_2_x
		form_icon_2_y

		image/form_underlay_2
		form_underlay_2_icon
		form_underlay_2_icon_state
		form_underlay_2_x
		form_underlay_2_y

		image/form_glow
		form_glow_icon
		form_glow_icon_state
		form_glow_x
		form_glow_y

		pot_trans = 0

		priorAngerPoint
		angerPoint
		autoAnger = FALSE

		PUSpeedModifier = 1

		mastery = 0

		is_active = FALSE

		first_time = TRUE

		revertToTrans = null

	proc
		adjust_transformation_visuals(mob/user)
			form_glow = image(icon=form_glow_icon,icon_state = form_glow_icon_state,pixel_x = form_glow_x, pixel_y = form_glow_y)
			form_aura = image(icon = form_aura_icon, icon_state = form_aura_icon_state, pixel_x = form_aura_x, pixel_y = form_aura_y)
			form_aura_underlay = image(icon = form_aura_underlay_icon, icon_state = form_aura_underlay_icon_state, pixel_x = form_aura_underlay_x, pixel_y = form_aura_underlay_y)
			form_hair = image(icon = form_hair_icon, pixel_x = form_hair_x, pixel_y = form_hair_y, layer = FLOAT_LAYER-2)
			form_icon_1 = image(icon = form_icon_1_icon, icon_state = form_icon_1_icon_state, pixel_x = form_icon_1_x, pixel_y = form_icon_1_y, layer = form_icon_1_layer)
			form_underlay_1 = image(icon = form_underlay_1_icon, icon_state = form_underlay_1_icon_state, pixel_x = form_underlay_1_x, pixel_y = form_underlay_1_y)
			form_icon_2 = image(icon = form_icon_2_icon, icon_state = form_icon_2_icon_state,pixel_x = form_icon_2_x, pixel_y = form_icon_2_y)
			form_underlay_2 = image(icon = form_underlay_2_icon, icon_state = form_underlay_2_icon_state, pixel_x = form_underlay_2_x, pixel_y = form_underlay_2_y)

		transform_animation(mob/user)

		revert_animation(mob/user)

		mastery_boons(mob/user)
		class_boons(mob/user)

		apply_visuals(mob/user, aura = 1, hair = 1, extra = 1)
			adjust_transformation_visuals(user)
			if(extra)
				user.overlays += form_icon_1
				user.overlays += form_icon_2
				user.overlays += form_glow
				user.underlays += form_underlay_1;
				user.underlays += form_underlay_2;
			if(aura)
				user.overlays += form_aura
				user.underlays += form_aura_underlay
			if(hair)
				user.Hair = form_hair

		remove_visuals(mob/user, aura = 1, hair = 1, extra = 1)
			if(hair)
				user.Hair = user.Hair_Base
			if(extra)
				user.overlays -= form_icon_1
				user.overlays -= form_icon_2
				user.overlays -= form_glow
				user.underlays -= form_underlay_1;
				user.underlays -= form_underlay_2;
			if(aura)
				user.overlays -= form_aura
				user.underlays -= form_aura_underlay

		transform(mob/user, forceTrans)
			if(user.passive_handler.Get("Utterly Powerless") >= 1&&!user.passive_handler.Get("Our Future"))
				src<<"<b><font color='red'>You have no fight left to fight. No life left to live.</font color></b>"
				return;
			if(user.passive_handler.Get("SSJRose") >= 1) return;
			if(is_active) return
			if(!forceTrans)
				if(!user.CanTransform()) return

				if(user.transUnlocked < user.transActive+1)
					if(!(user.bypassTransAutomation >= user.transActive+1) && glob.lockTransAutomation && (type in glob.transLocked)) return
					if(unlock_potential >= user.Potential) return
			if(glob.racials.AUTO_SSJ_MASTERY)
				gainMastery()
			mastery_boons(user)
			class_boons(user)

			adjust_transformation_visuals(user)

			user.transActive++
			user.passive_handler.increaseList(passives)
			user.passive_handler.increaseList(class_passives)

			user.StrMultTotal *= strength
			user.EndMultTotal *= endurance
			user.ForMultTotal *= force
			user.SpdMultTotal *= speed
			user.OffMultTotal *= offense
			user.DefMultTotal *= defense
			user.StrTransMult += strengthadd
			user.EndTransMult += enduranceadd
			user.ForTransMult += forceadd
			user.SpdTransMult += speedadd
			user.OffTransMult += offenseadd
			user.DefTransMult += defenseadd

			user.BioArmorMax += BioArmorMax
			if(user.BioArmor > user.BioArmorMax)
				user.BioArmor = user.BioArmorMax

			user.potential_trans = user.Potential+pot_trans
			var/SaiyanTrans=0
			if(user.isRace(SAIYAN)||user.isRace(HALFSAIYAN))
				SaiyanTrans=(unlock_potential)-user.Potential
				if(SaiyanTrans<5*user.transActive)
					SaiyanTrans=5*user.transActive
				user.potential_trans=user.Potential+SaiyanTrans
			if(user.isRace(MAJIN))
				SaiyanTrans=(unlock_potential)-user.Potential
				if(SaiyanTrans<15*user.transActive)
					SaiyanTrans=15*user.transActive
				user.potential_trans=user.Potential+SaiyanTrans
			if(form_base)
				stored_base = user.icon
				stored_base_x = user.pixel_x
				stored_base_y = user.pixel_y
				user.icon = form_base
				user.pixel_x = form_base_x
				user.pixel_y = form_base_y

			if(form_profile)
				stored_profile = user.Profile
				user.Profile = form_profile

			if(angerPoint)
				priorAngerPoint = user.AngerPoint
				user.AngerPoint = angerPoint

			user.PUSpeedModifier *= PUSpeedModifier

			if(autoAnger)
				user.Anger()
				user.passive_handler.Increase("EndlessAnger")

			is_active = TRUE

			transform_animation(user)

			if(first_time)
				first_time = FALSE

			user.Hairz("Add")
			user.Auraz("Add")
			user.AppearanceOn();

			if(transformation_message)
				var/text=replacetext(transformation_message, "usrName", "[user]")
				user << text

		revert(mob/user)
			if(!is_active || !user.CanRevert()) return
			user.HellspawnBerserk=0
			user.HellspawnTimer=0
			if(user.UnstoppableForceCounter>=1)
				if(user.UnstoppableForceCounter>9)
					user.UnstoppableForceCounter=9
				user.AddStrTax(user.UnstoppableForceCounter/10)
				user.AddEndTax(user.UnstoppableForceCounter/10)
				user.AddSpdTax(user.UnstoppableForceCounter/10)
				user.UnstoppableForceCounter=0
			if(user.passive_handler.Get("Full Manifestation"))
				if(user.AscensionsAcquired<5)
					user.AddStrTax((5-user.AscensionsAcquired)/5)
					user.AddEndTax((5-user.AscensionsAcquired)/5)
					user.AddSpdTax((5-user.AscensionsAcquired)/5)
			user.transActive--
			if(!isnull(revertToTrans))
				user.transActive = revertToTrans
			user.passive_handler.decreaseList(passives)
			user.passive_handler.decreaseList(class_passives)

			user.StrMultTotal /= strength
			user.EndMultTotal /= endurance
			user.ForMultTotal /= force
			user.SpdMultTotal /= speed
			user.OffMultTotal /= offense
			user.DefMultTotal /= defense
			user.StrTransMult -= strengthadd
			user.EndTransMult -= enduranceadd
			user.ForTransMult -= forceadd
			user.SpdTransMult -= speedadd
			user.OffTransMult -= offenseadd
			user.DefTransMult -= defenseadd

			user.BioArmorMax -= BioArmorMax
			if(user.BioArmor > user.BioArmorMax)
				user.BioArmor = user.BioArmorMax

			if(stored_base)
				user.icon = stored_base
				user.pixel_x = stored_base_x
				user.pixel_y = stored_base_y
				stored_base = null

			user.potential_trans = 0
			var/SaiyanTrans=0
			if(user.isRace(SAIYAN)||user.isRace(HALFSAIYAN))
				SaiyanTrans=unlock_potential-user.Potential
				if(SaiyanTrans<5*user.transActive)
					SaiyanTrans=5*user.transActive
				user.potential_trans=user.Potential+SaiyanTrans
				if(user.transActive<=0)
					user.potential_trans=0
				if(user.potential_trans<0)
					user.potential_trans=0
			if(priorAngerPoint)
				user.AngerPoint = priorAngerPoint
				priorAngerPoint = null

			user.PUSpeedModifier /= PUSpeedModifier
			user.DoubleHelix=0

			if(autoAnger)
				user.passive_handler.Decrease("EndlessAnger")

			if(stored_profile)
				user.Profile = stored_profile
				stored_profile = null

			is_active = FALSE

			revert_animation(user)

			user.Hairz("Add")

			if((user.HasKiControl()||user.PoweringUp)&&!user.KO)
				user.Auraz("Add")
			else
				user.Auraz("Remove")

			user.AppearanceOff()
			user.AppearanceOn()
			if(detrans_message)
				var/text=replacetext(detrans_message, "usrName", "[usr]")
				user << text

		applyDrain(mob/user)
			var/cut_off = 0
			var/drain = 0

			if(mastery<100)
				drain = glob.racials.SSJ_BASE_DRAIN - (glob.racials.SSJ_BASE_DRAIN * (mastery/100))
				cut_off = glob.racials.SSJ_BASE_CUT_OFF + (glob.racials.SSJ_CUT_OFF_PER_MAST * (mastery/100))

			if(drain>0)
				user.LoseEnergy(drain)

				if(user.Energy < cut_off &&!user.HasNoRevert()&&!user.Dead&&!user.HasMystic())
					user.Revert()
					user.LoseEnergy(30)
					user << "The strain of [src] is too much for you to handle!"

		gainMastery(mob/user)
			if(mastery >= 100) return
			if(user.isRace(SAIYAN)||user.isRace(HALFSAIYAN))
				if(user.transActive==1&&user.oozaru_type!="Demonic")
					if(user.Potential>=22&&mastery<25)
						mastery=25
					if(user.Potential>=27&&mastery<50)
						mastery=50
					if(user.Potential>=30&&mastery<75)
						mastery=75
					if(user.Potential>=35&&mastery<75)
						mastery=100
				if(user.transActive==2||user.transActive==1&&user.oozaru_type=="Demonic")
					if(user.Potential>=37&&mastery<25)
						mastery=25
					if(user.Potential>=39&&mastery<50)
						mastery=50
					if(user.Potential>=41&&mastery<75)
						mastery=75
					if(user.Potential>=43&&mastery<100)
						mastery=100
			if(mastery > 100)
				mastery=100
