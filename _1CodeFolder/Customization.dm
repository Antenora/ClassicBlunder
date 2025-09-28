mob/Players/verb
	Customize()
		set category="Other"
		usr.Grid("Blasts","Auras","Charges")
		src.Auraz("Remove")
	Hair()
		set category="Other"
		usr.Hairz("Remove")
		usr.Grid("Hair")
	Clothes()
		set category="Other"
		usr.Grid("Clothes")
	Relayer_Hair()
		set hidden=1//hidden for kkt's ocd
		usr.Hairz("Add")

mob/var
	icon/Eyes
	icon/Ears
	icon/EarsU
	icon/FTail
	icon/FTailU
	image/Hair
	Hair_Base
	Hair_Color
	Hair_SSJ1
	Hair_FPSSJ1
	Hair_SSJ2
	Hair_SSJ3
	Hair_SSJGod
	Hair_SSJBlue
	Hair_SSJ4
	Hair_HT
	Hair_SHT
	KingofBravesHair


mob/proc/Auraz(var/Z)
	var/image/pegasus=image('Cosmo_Pegasus.dmi',pixel_x=-17, pixel_y=-22)
	var/image/dragon=image('Cosmo_Dragon.dmi',pixel_x=-17, pixel_y=-22)
	var/image/cygnus=image('Cosmo_Cygnus.dmi',pixel_x=-17, pixel_y=-22)
	var/image/andromeda=image('Cosmo_Andromeda.dmi',pixel_x=-17, pixel_y=-22)
	var/image/unicorn=image('Cosmo_Unicorn.dmi',pixel_x=-17, pixel_y=-22)
	var/image/phoenix=image('Cosmo_Phoenix.dmi',pixel_x=-17, pixel_y=-22)
	var/image/gold1=image('Cosmo_Seventh.dmi',pixel_x=-17, pixel_y=-22)
	var/image/gold2=image('Ripple Radiance.dmi',pixel_x=-32, pixel_y=-32)
	var/image/spiral=image('Spiral_Aura.dmi',pixel_x=-17, pixel_y=-22)
	gold1.blend_mode=BLEND_ADD
	gold2.blend_mode=BLEND_ADD
	var/image/godaura=image('SSGAura.dmi',pixel_x=-32, pixel_y=-32)
	var/image/godglow=image('SSGGlow.dmi',pixel_x=-32, pixel_y=-32)
	var/image/godaura2=image('SSBAura.dmi',pixel_x=-49, pixel_y=-15)
	var/image/godglow2=image('SSBGlow.dmi',pixel_x=-32, pixel_y=-32)
	var/image/godspark=image('SSBSparks.dmi')
	godaura.blend_mode=BLEND_ADD
	godglow.blend_mode=BLEND_ADD
	godaura2.blend_mode=BLEND_ADD
	godglow2.blend_mode=BLEND_ADD
	godglow2.alpha=150
	var/image/rageaura=image('RageAura.dmi',pixel_x=-49, pixel_y=-15)
	var/image/rageglow=image('GodGlow.dmi',pixel_x=-32,pixel_y=-32)
	var/image/rageglow2=image('SSGGlow.dmi',pixel_x=-32, pixel_y=-32)
	rageaura.blend_mode=BLEND_ADD
	rageglow.color=list(1,0,0, 0,1,0, 0,0,1, 0.17,0.2,0.5)
	rageglow.transform*=1
	rageglow2.blend_mode=BLEND_ADD
	rageglow2.alpha=120
	var/image/supersparks3=image(icon='SS4Sparks.dmi')
	var/image/superglow=image('Ripple Radiance.dmi',pixel_x=-32, pixel_y=-32)
	var/image/superhairglow1=image(src.Hair_SSJ1)
	var/image/superhairglow2=image(src.Hair_SSJ2)
	var/image/superhairglow3=image(src.Hair_SSJ3)
	supersparks3.alpha=200
	superglow.blend_mode=BLEND_ADD
	superglow.alpha=40
	superglow.color=list(1,0,0, 0,0.8,0, 0,0,0, 0.2,0.2,0.2)
	superhairglow1.blend_mode=BLEND_MULTIPLY
	superhairglow1.alpha=125
	superhairglow1.color=list(1,0,0, 0,0.82,0, 0,0,0, -0.26,-0.26,-0.26)
	superhairglow2.blend_mode=BLEND_MULTIPLY
	superhairglow2.alpha=125
	superhairglow2.color=list(1,0,0, 0,0.82,0, 0,0,0, -0.26,-0.26,-0.26)
	superhairglow3.blend_mode=BLEND_MULTIPLY
	superhairglow3.alpha=125
	superhairglow3.color=list(1,0,0, 0,0.82,0, 0,0,0, -0.26,-0.26,-0.26)
	var/image/tensiona=image('AurasBig.dmi',icon_state="HT1",pixel_x=-32)
	var/image/tensionas=image('AurasBig.dmi',icon_state="HT2",pixel_x=-32)
	tensiona.color=list(0.5,0.3,0.7, 0.78,0.59,0.99, 0.3,0.11,0.51, 0,0,0)
	var/image/flameaura=image('FlameAura.dmi',pixel_x=-16,pixel_y=-8)
	flameaura.blend_mode=BLEND_ADD
	if(Z=="Add")

		src.Auraz("Remove")

		if(src.HasRipple())
			src.underlays+=gold2

		if(src.AuraLocked==1)
			if(src.AuraLockedUnder==1)
				src.underlays+=image(icon=src.AuraLock, pixel_x=src.AuraX, pixel_y=src.AuraY)
			else
				src.overlays+=image(icon=src.AuraLock, pixel_x=src.AuraX, pixel_y=src.AuraY)
			return

		else if(src.CheckSpecial("Kamui Unite"))
			src.underlays+=image('BijuuInitial.dmi',pixel_x=-32, pixel_y=-32)
			src.underlays+=image('GCAura.dmi',pixel_x=-49, pixel_y=-15)

		else if(src.tension>=5)
			if(src.tension<100)
				src.overlays+=tensiona
			else
				src.overlays+=tensionas

		else if(src.ClothBronze)
			var/list/Gold=list("Aries Cloth", /* "Taurus Cloth" */, "Gemini Cloth", "Cancer Cloth", "Leo Cloth", "Virgo Cloth", "Libra Cloth", "Sagittarius Cloth", "Scorpio Cloth", "Capricorn Cloth", "Aquarius Cloth", "Pisces Cloth")
			if((src.SpecialBuff&&(src.SpecialBuff.BuffName in Gold))||src.ClothBronze==src.ClothGold)
				src.underlays+=gold2
				src.underlays+=gold1
			else
				switch(src.ClothBronze)
					if("Pegasus")
						src.underlays+=pegasus
					if("Dragon")
						src.underlays+=dragon
					if("Cygnus")
						src.underlays+=cygnus
					if("Andromeda")
						src.underlays+=andromeda
					if("Phoenix")
						src.underlays+=phoenix
					if("Unicorn")
						src.underlays+=unicorn
		else if(src.Saga=="Spiral")
			src.underlays+=spiral

		else if(passive_handler.Get("BurningShot"))
			src.overlays+=flameaura

		else if(transActive)
			race.transformations[transActive].apply_visuals(src,1,0,1)
		else
			for(var/obj/Skills/Power_Control/M in src.contents)
				if(src.AuraLockedUnder==1)
					src.underlays += image(M.sicon,icon_state=M.sicon_state,pixel_x=M.pixel_x,pixel_y=M.pixel_y)
				else
					src.overlays += image(M.sicon,icon_state=M.sicon_state,pixel_x=M.pixel_x,pixel_y=M.pixel_y)


	if(Z=="Remove")
		for(var/obj/Skills/Power_Control/M in src.contents)
			src.overlays-=image(M.sicon,M.sicon_state,pixel_x=M.pixel_x,pixel_y=M.pixel_y)
			src.underlays-=image(M.sicon,M.sicon_state,pixel_x=M.pixel_x,pixel_y=M.pixel_y)

		src.overlays-=image(icon='AuraMystic.dmi', icon_state="1",pixel_x=-32)
		src.overlays-=image(icon='AuraMystic.dmi', icon_state="2",pixel_x=-32)
		src.overlays-=image(icon='AuraMystic.dmi', icon_state="3",pixel_x=-32)
		src.overlays-=image(icon='MajinAura.dmi')
		src.overlays-=image(icon='SparksCoolMystic.dmi')
		src.overlays-=image(icon='AuraMysticBig.dmi', pixel_x=-32)

		src.overlays-=tensiona
		src.overlays-=tensionas

		src.overlays-=flameaura

		src.overlays-=godglow
		src.overlays-=godglow2
		src.overlays-=image('SSBSparkle.dmi')
		src.overlays-=godspark

		src.overlays-=rageglow2

		src.overlays-=image('Amazing SSj Aura.dmi',pixel_x=-32)
		src.overlays-=image('Amazing SSj4 Aura.dmi',pixel_x=-32)
		src.overlays-=image('AurasBig.dmi',icon_state="Demon",pixel_x=-32)
		src.overlays-=image('Amazing Super Namekian Aura.dmi',pixel_x=-32)
		src.overlays-=image('AurasBig.dmi',icon_state="Namekian",pixel_x=-32)
		src.overlays-=image('AurasBig.dmi',icon_state="Changeling",pixel_x=-32)
		src.overlays-=image('AurasBig.dmi',icon_state="HT1",pixel_x=-32)
		src.overlays-=image('AurasBig.dmi',icon_state="HT2",pixel_x=-32)
		src.overlays-=image('Auras.dmi',"Demi",pixel_x=-32)
		src.overlays-=image('SpiralBigAura.dmi',"",pixel_x=-32)
		src.overlays-=image('SpiralAura.dmi',"",pixel_x=-32)
		src.overlays-=image('AuraMystic.dmi',pixel_x=-32)
		src.overlays-=image('BlackFlameAura.dmi')
		if(transActive)
			race.transformations[transActive].remove_visuals(src,1,0,1)
		src.overlays-=image(icon=src.Form1Aura, pixel_x=src.Form1AuraX, pixel_y=src.Form1AuraY)
		src.overlays-=image(icon=src.Form2Aura, pixel_x=src.Form2AuraX, pixel_y=src.Form2AuraY)
		src.overlays-=image(icon=src.Form3Aura, pixel_x=src.Form3AuraX, pixel_y=src.Form3AuraY)
		src.overlays-=image(icon=src.Form4Aura, pixel_x=src.Form4AuraX, pixel_y=src.Form4AuraY)
		src.overlays-=image(icon=src.Form5Aura, pixel_x=src.Form5AuraX, pixel_y=src.Form5AuraY)

		src.overlays-=image('SSGGlow.dmi',pixel_x=-32, pixel_y=-32)
		src.overlays-=image('SSBGlow.dmi',pixel_x=-32, pixel_y=-32)

		src.underlays-=image(icon=src.Form1Aura, pixel_x=src.Form1AuraX, pixel_y=src.Form1AuraY)
		src.underlays-=image(icon=src.Form2Aura, pixel_x=src.Form2AuraX, pixel_y=src.Form2AuraY)
		src.underlays-=image(icon=src.Form3Aura, pixel_x=src.Form3AuraX, pixel_y=src.Form3AuraY)
		src.underlays-=image(icon=src.Form4Aura, pixel_x=src.Form4AuraX, pixel_y=src.Form4AuraY)
		src.underlays-=image(icon=src.Form5Aura, pixel_x=src.Form5AuraX, pixel_y=src.Form5AuraY)

		src.overlays-=image(icon=src.AuraLock, pixel_x=src.AuraX, pixel_y=src.AuraY)
		src.underlays-=image(icon=src.AuraLock, pixel_x=src.AuraX, pixel_y=src.AuraY)

		src.underlays-=image('BijuuInitial.dmi',pixel_x=-32, pixel_y=-32)
		src.underlays-=image('GCAura.dmi',pixel_x=-49, pixel_y=-15)

		src.underlays-=godaura
		src.underlays-=godaura
		src.underlays-=godaura2

		src.underlays-=rageaura
		src.underlays-=rageglow

		src.underlays-=image('DarknessFlameAura.dmi',pixel_x=-32, pixel_y=-32)

		src.underlays-=pegasus
		src.underlays-=dragon
		src.underlays-=cygnus
		src.underlays-=andromeda
		src.underlays-=phoenix
		src.underlays-=unicorn
		src.underlays-=gold1
		src.underlays-=gold2
		src.underlays-=spiral

mob/proc/Chargez(var/Z, var/image/C=new(ChargeIcon), var/Under=0)
	if(Z=="Add")
		if(!Under)
			src.overlays -= C
			src.overlays += C
		else
			src.underlays -= C
			src.underlays += C
	if(Z=="Remove")
		src.overlays -= C
		src.underlays -= C


mob/proc/Hairz(var/Z)
	if(Z=="Add")
		src.Hairz("Remove")

		var/icon/HairB=icon(src.Hair_Base)


		if(src.StyleActive=="Ultra Instinct")
			src.overlays+=image(icon=src.EyesUI, layer=FLOAT_LAYER-2)

		else if(src.isRace(SAIYAN)&&transActive==4)
			src.overlays+=image(icon=src.EyesSSJ4, layer=FLOAT_LAYER-2)

		else if(!src.HasMystic())
			if(src.isRace(SAIYAN)&&(transActive>=1&&transActive<3))
				if(src.HasGodKi())
					src.overlays+=image(icon=src.EyesSSB, layer=FLOAT_LAYER-2)
				else
					src.overlays+=image(icon=src.EyesSSJ, layer=FLOAT_LAYER-2)
			else if(src.isRace(SAIYAN)&&transActive==3)
				src.overlays+=image(icon=src.EyesSSJ3, layer=FLOAT_LAYER-2)

		if(src.HairLocked==1)
			Hair = image(icon=src.HairLock, pixel_x=HairBX, pixel_y=HairBY)
		else if(src.tension>=5)
			if(src.tension==100)
				Hair = image(icon=src.Hair_SHT)
			else
				if(HairB&&src.Hair_Color)
					HairB.Blend(src.Hair_Color, ICON_ADD)
				Hair = image(icon=HairB)
		else if((src.HasMystic()||src.StyleActive=="Ultra Instinct")&&!isRace(HUMAN))
			if(HairB&&src.Hair_Color)
				HairB.Blend(src.Hair_Color, ICON_ADD)
			Hair = image(icon=HairB)

		else if(transActive)
			race.transformations[transActive].apply_visuals(src,0,1,0)

		else
			if(HairB&&src.Hair_Color)
				HairB.Blend(src.Hair_Color, ICON_ADD)
			Hair = image(icon=HairB)

		if(!transActive)
			Hair.layer=FLOAT_LAYER-2
			src.overlays += image(icon=src.Hair, pixel_x=src.HairX, pixel_y=src.HairY, layer=FLOAT_LAYER-2)
			src.underlays += image(icon=src.HairUnderlay, pixel_x=src.HairUnderlayX, pixel_y=src.HairUnderlayY, layer=FLOAT_LAYER-2)
		else
			src.overlays += Hair

		if(src.SpecialBuff&&(src.SpecialBuff.BuffName=="Broken Brave"||src.SpecialBuff.BuffName=="Protect Brave"||src.SpecialBuff.BuffName=="Genesic Brave"))
			src.overlays +=KingofBravesHair


	if(Z=="Remove")
		src.overlays -= Ears
		src.overlays -= EarsU
		src.overlays -= FTail
		src.overlays -= FTailU
		src.overlays -= image(src.EyesSSJ, layer=FLOAT_LAYER-2)
		src.overlays -= image(src.EyesSSJ3, layer=FLOAT_LAYER-2)
		src.overlays -= image(src.EyesSSJ4, layer=FLOAT_LAYER-2)
		src.overlays -= image(src.EyesSSG, layer=FLOAT_LAYER-2)
		src.overlays -= image(src.EyesSSB, layer=FLOAT_LAYER-2)
		src.overlays -= image(src.EyesUI, layer=FLOAT_LAYER-2)
		src.overlays -= image('EyesHT.dmi', layer=FLOAT_LAYER-2)
		src.overlays -= image(icon=src.Hair, pixel_x=src.HairX, pixel_y=src.HairY, layer=FLOAT_LAYER-2)
		src.overlays -= image(icon=src.Hair_Base, layer=FLOAT_LAYER-2)
		src.overlays -= image(icon=src.Hair_SSJ1, layer=FLOAT_LAYER-2)
		src.overlays -= image(icon=src.Hair_FPSSJ1, layer=FLOAT_LAYER-2)
		src.overlays -= image(icon=src.Hair_SSJ2, layer=FLOAT_LAYER-2)
		src.overlays -= image(icon=src.Hair_SSJ3, layer=FLOAT_LAYER-2)
		src.overlays -= image(icon=src.Hair_SSJGod, layer=FLOAT_LAYER-2)
		src.overlays -= image(icon=src.Hair_SSJBlue, layer=FLOAT_LAYER-2)
		src.overlays -= image(icon=src.Hair_SSJ4, layer=FLOAT_LAYER-2)
		if(transActive)
			race.transformations[transActive].remove_visuals(src,0,1,0)
		src.overlays -= image(icon=src.Form1Hair, pixel_x=Form1HairX, pixel_y=Form1HairY, layer=FLOAT_LAYER-2)
		src.overlays -= image(icon=src.Form2Hair, pixel_x=Form2HairX, pixel_y=Form2HairY, layer=FLOAT_LAYER-2)
		src.overlays -= image(icon=src.Form3Hair, pixel_x=Form3HairX, pixel_y=Form3HairY, layer=FLOAT_LAYER-2)
		src.overlays -= image(icon=src.Form4Hair, pixel_x=Form4HairX, pixel_y=Form4HairY, layer=FLOAT_LAYER-2)
		src.overlays -= image(icon=src.HairLock, pixel_x=HairBX, pixel_y=HairBY, layer=FLOAT_LAYER-2)
		src.underlays -= image(icon=src.HairUnderlay, pixel_x=src.HairUnderlayX, pixel_y=src.HairUnderlayY, layer=FLOAT_LAYER-2)
/*		for(var/obj/Items/Wearables/w in src)
			if(w.IsHat)
				if(w.suffix)
					var/image/im=image(icon=w.icon, pixel_x=w.pixel_y, pixel_y=w.pixel_y, layer=FLOAT_LAYER-1)
					src.overlays-=im*/

proc/Add_Customizations()
	for(var/A in subtypesof(/obj/Hairs))
		if(A!=/obj/Hairs)
			Hair_List+=new A
	for(var/A in subtypesof(/obj/Items/Wearables))
		var/obj/Items/Wearables/w = new A
		var/icon/newIcon = new(w.icon)
		if(w.type in list(/obj/Items/Wearables/Icon_67,/obj/Items/Wearables/Icon_68,/obj/Items/Wearables/Icon_69,/obj/Items/Wearables/Icon_70))
			w.icon = newIcon // im lazy and dont want to ! the above
		else
			newIcon.MapColors(0.2,0.2,0.2, 0.2,0.2,0.2, 0.2,0.2,0.2, 0,0,0)
		w.icon = newIcon
		var/obj/clothes_grid_visual/gridwear = new(w)
		Clothes_List+=gridwear

	for(var/A in subtypesof(/obj/Charge_Icons)) if(A!=/obj/Charge_Icons) Charge_List+=new A
	for(var/A in subtypesof(/obj/Aura_Icons)) if(A!=/obj/Aura_Icons) Aura_List+=new A
	for(var/A in subtypesof(/obj/Blast_Icons)) if(A!=/obj/Blast_Icons) Blast_List+=new A

var/list/Hair_List=new
obj/Hairs
	proc/Hair_Click(mob/A)
		if(A.IconClicked==0)
			A.IconClicked=1
			var/Color=input(A,"Choose color") as color|null
			if(Color) src.icon+=Color
			A.Hair_Base=initial(icon)
			A.Hair_Color=Color
			A.Hairz("Add")
			A.IconClicked=0
			winshow(usr,"Grid1",0)
			src.icon=initial(icon)
	Click() Hair_Click(usr)
	No_Change
		Click()
			usr.Hairz("Add")
	Bald
		icon='Hair_Bald.dmi'
	Hair_1F
		icon='HairF1.dmi'
	Hair_2F
		icon='HairF2.dmi'
	Hair_3F
		icon='HairF3.dmi'
	Hair_4F
		icon='HairF4.dmi'
	Hair_4FB
		icon='HairF4B.dmi'
	Hair_5F
		icon='HairF5.dmi'
	Hair_5FB
		icon='HairF5B.dmi'
	Hair_6F
		icon='HairF6.dmi'
	Hair_7F
		icon='HairF7.dmi'
	Hair_7FB
		icon='HairF7B.dmi'
	Hair_8F
		icon='HairF8B.dmi'
	Hair_9F
		icon='HairF9B.dmi'
	Hair_10F
		icon='HairHanasia.dmi'
	Hair_11F
		icon='AyameHairblack.dmi'
	Hair_12F
		icon='Amelies_Hair.dmi'
	Hair_13F
		icon='Agnes Hair.dmi'
	Hair_14F
		icon='X-BitGirl Hair.dmi'
	Hair_15F
		icon='Mezu Hair.dmi'
	Hair_16F
		icon='FemaleGenericLongHair.dmi'
	Hair_17F
		icon='FemaleTwinTailsHair.dmi'
	Hair_18F
		icon='FemaleSuperPonytail.dmi'
	Hair_19F
		icon='FemaleFlirtySwoopHair.dmi'
	Hair_20F
		icon='FemalePigtails.dmi'
	Hair_21F
		icon='FemaleFlippedHair.dmi'
	Hair_22F
		icon='FemaleWaifuHair.dmi'
	Hair_23F
		icon='LongMuseHair.dmi'
	Hair_24F
		icon='FemaleButchHair.dmi'
	Hair_25F
		icon='FemaleCabbageHair.dmi'
	Hair_26F
		icon='FemaleSetsunaTailsHair.dmi'
	Hair_27F
		icon='FemalePinnedUpHair.dmi'
	Hair_28F
		icon='FemaleBobTails.dmi'
	Hair_1
		icon='Hair1.dmi'
	Hair_2
		icon='Hair2.dmi'
	Hair_3
		icon='Hair3.dmi'
	Hair_4
		icon='Hair4.dmi'
	Hair_5
		icon='Hair5.dmi'
	Hair_6
		icon='Hair6.dmi'
	Hair_7
		icon='Hair7.dmi'
	Hair_8
		icon='Hair8.dmi'
	Hair_9
		icon='Hair9.dmi'
	Hair_10
		icon='Hair10.dmi'
	Hair_11
		icon='Hair11.dmi'
	Hair_12
		icon='Hair12.dmi'
	Hair_13
		icon='Hair13.dmi'
	Hair_14
		icon='Hair14.dmi'
	Hair_15
		icon='Hair15.dmi'
	Hair_16
		icon='Hair16.dmi'
	Hair_17
		icon='Hair17.dmi'
	Hair_18
		icon='Hair18.dmi'
	Hair_19
		icon='Hair19.dmi'
	Hair_20
		icon='Hair20.dmi'
	Hair_21
		icon='Hair21.dmi'
	Hair_22
		icon='Hair22.dmi'
	Hair_23
		icon='Hair23.dmi'
	Hair_24
		icon='Hair24.dmi'
	Hair_25
		icon='Hair25.dmi'
	Hair_26
		icon='Hair26.dmi'
	Hair_27
		icon='Hair27.dmi'
	Hair_28
		icon='Blackhairreggi.dmi'
	Hair_29
		icon='Zidane Hair.dmi'
	Hair_30
		icon='MaleUltimateEdgeHair.dmi'
	Hair_31
		icon='MaleLancerHair.dmi'
	Hair_31B
		icon='MaleLancerHairPonytail.dmi'
	Hair_32
		icon='MaleShortSpikedHair.dmi'
	Hair_33
		icon='MaleSasukeHair.dmi'
	Hair_34
		icon='MaleSamuraiHair.dmi'
	Hair_35
		icon='MaleNoctisHair.dmi'
	Hair_36
		icon='MaleOldManHair.dmi'
	Hair_37
		icon='MaleSubtleSpikeHair.dmi'
	Hair_38
		icon='MaleElegantHair.dmi'
	Hair_39
		icon='SexyGregHair.dmi'
	Hair_40
		icon='Ponytail.dmi'

mob/verb/ToggleInt(var/blah as text)
	set name=".ToggleInterface"
	set hidden=1
	switch(blah)
		if("Customization")
			winshow(usr,"Grid2",0)

mob/proc
	Grid(var/Z,var/X,var/E, var/mob/Players/Lootee)
		winshow(src,"Grid2",0)
		sleep()
		winshow(src,"Grid2",1)
		winset(src,"GridZ","cells=0x0")
		sleep()
		winset(src,"GridX","cells=0x0")
		var/Row=0
		if(Z=="SkillSheet")
			src<<output("Fucking skills man!","SelectedCustomize")
			for(var/obj/Skills/A in src.contents)
				Row++
				src<<output(A,"GridX:1,[Row]")
				Row++
				src<<output("<font color=white>[A.Level]%","GridX:1,[Row]")
				Row++
				src<<output("<font color=blue>[A.desc]","GridX:1,[Row]")







		/*if(X=="Auras")
			src<<output("Flashy flashy.","SelectedCustomize")
			if(locate(/obj/Skills/Power_Control,src.contents))
				for(var/A in Aura_List)
					Row++
					src<<output(A,"GridX:1,[Row]")*/
		if(E=="Charges")
			for(var/A in Charge_List)
				Row++
				src<<output(A,"GridX:1,[Row]")

		if(Z=="Clothes")
			src<<output("Use these to not be naked.","SelectedCustomize")
			for(var/A in Clothes_List)
				Row++
				src<<output(A,"GridX:1,[Row]")

		if(Z=="Turfs")
			src<<output("Tiles everywhere!","SelectedCustomize")
			for(var/A in Builds)
				Row++
				src<<output(A,"GridX:1,[Row]")

		if(Z=="Tech")
			src<<output("High tech, low prices.","SelectedCustomize")
			for(var/obj/Money/M in usr)
				Row++
				src<<output(M,"GridX:1,[Row]")
				src<<output("[Commas(M.Level)]","GridX:2,[Row]")

			//This will always be displayed.
			Row++
			src<<output("-Basic Technology-","GridX:1,[Row]")
			for(var/obj/Items/BT in BasicTechnology_List)
				if(BT.Unobtainable)
					continue
				Row++
				src<<output(BT,"GridX:1,[Row]")
				src<<output("[Commas(BT.Cost*glob.progress.EconomyCost)]","GridX:2,[Row]")

			if(usr.ForgingUnlocked)
				Row++
				src<<output("-Forging-","GridX:1,[Row]")
				for(var/obj/Items/WF in Forging_List)
					if(WF.Unobtainable)
						continue
					if(WF.SubType=="Any")
						Row++
						src<<output(WF,"GridX:1,[Row]")
						src<<output("[Commas(WF.Cost*glob.progress.EconomyCost)]","GridX:2,[Row]")
					else if(WF.SubType in usr.knowledgeTracker.learnedKnowledge)
						Row++
						src<<output(WF,"GridX:1,[Row]")
						src<<output("[Commas(WF.Cost*glob.progress.EconomyCost)]","GridX:2,[Row]")

			if(usr.RepairAndConversionUnlocked)
				Row++
				src<<output("-Repair and Conversion-","GridX:1,[Row]")
				for(var/obj/Items/WC in RepairAndConversion_List)
					if(WC.Unobtainable)
						continue
					if(WC.SubType=="Any")
						Row++
						src<<output(WC,"GridX:1,[Row]")
						src<<output("[Commas(WC.Cost*glob.progress.EconomyCost)]","GridX:2,[Row]")
					else if(WC.SubType in usr.knowledgeTracker.learnedKnowledge)
						Row++
						src<<output(WC,"GridX:1,[Row]")
						src<<output("[Commas(WC.Cost*glob.progress.EconomyCost)]","GridX:2,[Row]")

			if(usr.MedicineUnlocked)
				Row++
				src<<output("-Medicine-","GridX:1,[Row]")
				for(var/obj/Items/M in Medicine_List)
					if(M.Unobtainable)
						continue
					if(M.SubType=="Any")
						Row++
						src<<output(M,"GridX:1,[Row]")
						src<<output("[Commas(M.Cost*glob.progress.EconomyCost)]","GridX:2,[Row]")
					else if(M.SubType in usr.knowledgeTracker.learnedKnowledge)
						Row++
						src<<output(M,"GridX:1,[Row]")
						src<<output("[Commas(M.Cost*glob.progress.EconomyCost)]","GridX:2,[Row]")

			if(usr.ImprovedMedicalTechnologyUnlocked)
				Row++
				src<<output("-Improved Medical Technology-","GridX:1,[Row]")
				for(var/obj/Items/IMT in ImprovedMedicalTechnology_List)
					if(IMT.Unobtainable)
						continue
					if(IMT.SubType=="Any")
						Row++
						src<<output(IMT,"GridX:1,[Row]")
						src<<output("[Commas(IMT.Cost*glob.progress.EconomyCost)]","GridX:2,[Row]")
					else if(IMT.SubType in usr.knowledgeTracker.learnedKnowledge)
						Row++
						src<<output(IMT,"GridX:1,[Row]")
						src<<output("[Commas(IMT.Cost*glob.progress.EconomyCost)]","GridX:2,[Row]")

			if(usr.TelecommunicationsUnlocked)
				Row++
				src<<output("-Telecommunications-","GridX:1,[Row]")
				for(var/obj/Items/CT in Telecommunications_List)
					if(CT.Unobtainable)
						continue
					if(CT.SubType=="Any")
						Row++
						src<<output(CT,"GridX:1,[Row]")
						src<<output("[Commas(CT.Cost*glob.progress.EconomyCost)]","GridX:2,[Row]")
					else if(CT.SubType in usr.knowledgeTracker.learnedKnowledge)
						Row++
						src<<output(CT,"GridX:1,[Row]")
						src<<output("[Commas(CT.Cost*glob.progress.EconomyCost)]","GridX:2,[Row]")

			if(usr.AdvancedTransmissionTechnologyUnlocked)
				Row++
				src<<output("-Advanced Transmission Technology-","GridX:1,[Row]")
				for(var/obj/Items/ST in AdvancedTransmissionTechnology_List)
					if(ST.Unobtainable)
						continue
					if(ST.SubType=="Any")
						Row++
						src<<output(ST,"GridX:1,[Row]")
						src<<output("[Commas(ST.Cost*glob.progress.EconomyCost)]","GridX:2,[Row]")
					else if(ST.SubType in usr.knowledgeTracker.learnedKnowledge)
						Row++
						src<<output(ST,"GridX:1,[Row]")
						src<<output("[Commas(ST.Cost*glob.progress.EconomyCost)]","GridX:2,[Row]")

			if(usr.EngineeringUnlocked||usr.MilitaryTechnologyUnlocked)
				Row++
				src<<output("-Power Packs-","GridX:1,[Row]")
				for(var/obj/Items/PP in PowerPack_List)
					if(PP.Unobtainable)
						continue
					else
						Row++
						src<<output(PP,"GridX:1,[Row]")
						src<<output("[Commas(PP.Cost*glob.progress.EconomyCost)]", "GridX:2,[Row]")

			if(usr.EngineeringUnlocked)
				Row++
				src<<output("-Engineering-","GridX:1,[Row]")
				for(var/obj/Items/MS in Engineering_List)
					if(MS.Unobtainable)
						continue
					if(MS.SubType=="Any")
						Row++
						src<<output(MS,"GridX:1,[Row]")
						src<<output("[Commas(MS.Cost*glob.progress.EconomyCost)]","GridX:2,[Row]")
					else if(MS.SubType in usr.knowledgeTracker.learnedKnowledge)
						Row++
						src<<output(MS,"GridX:1,[Row]")
						src<<output("[Commas(MS.Cost*glob.progress.EconomyCost)]","GridX:2,[Row]")

			if(usr.CyberEngineeringUnlocked)
				Row++
				src<<output("-Cyber Engineering-","GridX:1,[Row]")
				for(var/obj/Items/PE in CyberEngineering_List)
					if(PE.Unobtainable)
						continue
					if(PE.SubType=="Any")
						Row++
						src<<output(PE,"GridX:1,[Row]")
						src<<output("[Commas(PE.Cost*glob.progress.EconomyCost)]","GridX:2,[Row]")
					else if(PE.SubType in usr.knowledgeTracker.learnedKnowledge)
						Row++
						src<<output(PE,"GridX:1,[Row]")
						src<<output("[Commas(PE.Cost*glob.progress.EconomyCost)]","GridX:2,[Row]")

			if(usr.MilitaryTechnologyUnlocked)
				Row++
				src<<output("-Military Technology-","GridX:1,[Row]")
				for(var/obj/Items/E2 in MilitaryTechnology_List)
					if(E2.Unobtainable)
						continue
					if(E2.SubType=="Any")
						Row++
						src<<output(E2,"GridX:1,[Row]")
						src<<output("[Commas(E2.Cost*glob.progress.EconomyCost)]","GridX:2,[Row]")
					else if(E2.SubType in usr.knowledgeTracker.learnedKnowledge)
						Row++
						src<<output(E2,"GridX:1,[Row]")
						src<<output("[Commas(E2.Cost*glob.progress.EconomyCost)]","GridX:2,[Row]")

			if(usr.MilitaryEngineeringUnlocked)
				Row++
				src<<output("-Military Engineering-","GridX:1,[Row]")
				for(var/obj/Items/ST in MilitaryEngineering_List)
					if(ST.Unobtainable)
						continue
					if(ST.SubType=="Any")
						Row++
						src<<output(ST,"GridX:1,[Row]")
						src<<output("[Commas(ST.Cost*glob.progress.EconomyCost)]","GridX:2,[Row]")
					else if(ST.SubType in usr.knowledgeTracker.learnedKnowledge)
						Row++
						src<<output(ST,"GridX:1,[Row]")
						src<<output("[Commas(ST.Cost*glob.progress.EconomyCost)]","GridX:2,[Row]")

		if(Z=="Enchant")
			src<<output("Magical goods! Boil and bubble...","SelectedCustomize")
			src<<output("-Basic Enchantment-","GridX:1,[Row]")
			for(var/obj/Items/BT in BasicEnchantment_List)
				if(BT.Unobtainable)
					continue
				Row++
				src<<output(BT,"GridX:1,[Row]")
				src<<output("[Commas(BT.Cost*(glob.progress.EconomyMana/100))]","GridX:2,[Row]")

			if(usr.AlchemyUnlocked)
				Row++
				src<<output("-Alchemy-","GridX:1,[Row]")
				for(var/obj/Items/WF in Alchemy_List)
					if(WF.Unobtainable)
						continue
					if(WF.SubType=="Any")
						Row++
						src<<output(WF,"GridX:1,[Row]")
						src<<output("[Commas(WF.Cost*(glob.progress.EconomyMana/100))]","GridX:2,[Row]")
					else if(WF.SubType in usr.knowledgeTracker.learnedMagic)
						Row++
						src<<output(WF,"GridX:1,[Row]")
						src<<output("[Commas(WF.Cost*(glob.progress.EconomyMana/100))]","GridX:2,[Row]")

			if(usr.ImprovedAlchemyUnlocked)
				Row++
				src<<output("-Improved Alchemy-","GridX:1,[Row]")
				for(var/obj/Items/WC in ImprovedAlchemy_List)
					if(WC.Unobtainable)
						continue
					if(WC.SubType=="Any")
						Row++
						src<<output(WC,"GridX:1,[Row]")
						src<<output("[Commas(WC.Cost*(glob.progress.EconomyMana/100))]","GridX:2,[Row]")
					else if(WC.SubType in usr.knowledgeTracker.learnedMagic)
						Row++
						src<<output(WC,"GridX:1,[Row]")
						src<<output("[Commas(WC.Cost*(glob.progress.EconomyMana/100))]","GridX:2,[Row]")

			if(usr.ToolEnchantmentUnlocked)
				Row++
				src<<output("-Tool Enchantment-","GridX:1,[Row]")
				for(var/obj/Items/M in ToolEnchantment_List)
					if(M.Unobtainable)
						continue
					if(M.SubType=="Any")
						Row++
						src<<output(M,"GridX:1,[Row]")
						src<<output("[Commas(M.Cost*(glob.progress.EconomyMana/100))]","GridX:2,[Row]")
					else if(M.SubType in usr.knowledgeTracker.learnedMagic)
						Row++
						src<<output(M,"GridX:1,[Row]")
						src<<output("[Commas(M.Cost*(glob.progress.EconomyMana/100))]","GridX:2,[Row]")

			if(usr.ArmamentEnchantmentUnlocked)
				Row++
				src<<output("-Armament Enchantment-","GridX:1,[Row]")
				for(var/obj/Items/IMT in ArmamentEnchantment_List)
					if(IMT.Unobtainable)
						continue
					if(IMT.SubType=="Any")
						Row++
						src<<output(IMT,"GridX:1,[Row]")
						src<<output("[Commas(IMT.Cost*(glob.progress.EconomyMana/100))]","GridX:2,[Row]")
					else if(IMT.SubType in usr.knowledgeTracker.learnedMagic)
						Row++
						src<<output(IMT,"GridX:1,[Row]")
						src<<output("[Commas(IMT.Cost*(glob.progress.EconomyMana/100))]","GridX:2,[Row]")

			if(usr.TomeCreationUnlocked)
				Row++
				src<<output("-Tome Creation-","GridX:1,[Row]")
				for(var/obj/Items/CT in TomeCreation_List)
					if(CT.Unobtainable)
						continue
					if(CT.SubType=="Any")
						Row++
						src<<output(CT,"GridX:1,[Row]")
						src<<output("[Commas(CT.Cost*(glob.progress.EconomyMana/100))]","GridX:2,[Row]")
					else if(CT.SubType in usr.knowledgeTracker.learnedMagic)
						Row++
						src<<output(CT,"GridX:1,[Row]")
						src<<output("[Commas(CT.Cost*(glob.progress.EconomyMana/100))]","GridX:2,[Row]")

			if(usr.CrestCreationUnlocked)
				Row++
				src<<output("-Crest Creation-","GridX:1,[Row]")
				for(var/obj/Items/ST in CrestCreation_List)
					if(ST.Unobtainable)
						continue
					if(ST.SubType=="Any")
						Row++
						src<<output(ST,"GridX:1,[Row]")
						src<<output("[Commas(ST.Cost*(glob.progress.EconomyMana/100))]","GridX:2,[Row]")
					else if(ST.SubType in usr.knowledgeTracker.learnedMagic)
						Row++
						src<<output(ST,"GridX:1,[Row]")
						src<<output("[Commas(ST.Cost*(glob.progress.EconomyMana/100))]","GridX:2,[Row]")

			if(usr.SummoningMagicUnlocked)
				Row++
				src<<output("-Summoning Magic-","GridX:1,[Row]")
				for(var/obj/Items/MS in SummoningMagic_List)
					if(MS.Unobtainable)
						continue
					if(MS.SubType=="Any")
						Row++
						src<<output(MS,"GridX:1,[Row]")
						src<<output("[Commas(MS.Cost*(glob.progress.EconomyMana/100))]","GridX:2,[Row]")
					else if(MS.SubType in usr.knowledgeTracker.learnedMagic)
						Row++
						src<<output(MS,"GridX:1,[Row]")
						src<<output("[Commas(MS.Cost*(glob.progress.EconomyMana/100))]","GridX:2,[Row]")

			if(usr.SealingMagicUnlocked)
				Row++
				src<<output("-Sealing Magic-","GridX:1,[Row]")
				for(var/obj/Items/PE in SealingMagic_List)
					if(PE.Unobtainable)
						continue
					if(PE.SubType=="Any")
						Row++
						src<<output(PE,"GridX:1,[Row]")
						src<<output("[Commas(PE.Cost*(glob.progress.EconomyMana/100))]","GridX:2,[Row]")
					else if(PE.SubType in usr.knowledgeTracker.learnedMagic)
						Row++
						src<<output(PE,"GridX:1,[Row]")
						src<<output("[Commas(PE.Cost*(glob.progress.EconomyMana/100))]","GridX:2,[Row]")

			if(usr.SpaceMagicUnlocked)
				Row++
				src<<output("-Space Magic-","GridX:1,[Row]")
				for(var/obj/Items/E2 in SpaceMagic_List)
					if(E2.Unobtainable)
						continue
					if(E2.SubType=="Any")
						Row++
						src<<output(E2,"GridX:1,[Row]")
						src<<output("[Commas(E2.Cost*(glob.progress.EconomyMana/100))]","GridX:2,[Row]")
					else if(E2.SubType in usr.knowledgeTracker.learnedMagic)
						Row++
						if(istype(E2, /obj/Items/Enchantment/PocketDimensionGenerator))
							src<<output(E2,"GridX:1,[Row]")
							src<<output("[Commas(E2.Cost*(glob.progress.EconomyCost))]","GridX:2,[Row]")
						else
							src<<output(E2,"GridX:1,[Row]")
							src<<output("[Commas(E2.Cost*(glob.progress.EconomyMana/100))]","GridX:2,[Row]")

			if(usr.TimeMagicUnlocked)
				Row++
				src<<output("-Time Magic-","GridX:1,[Row]")
				for(var/obj/Items/ST in TimeMagic_List)
					if(ST.Unobtainable)
						continue
					if(ST.SubType=="Any")
						Row++
						src<<output(ST,"GridX:1,[Row]")
						src<<output("[Commas(ST.Cost*(glob.progress.EconomyMana/100))]","GridX:2,[Row]")
					else if(ST.SubType in usr.knowledgeTracker.learnedMagic)
						Row++
						src<<output(ST,"GridX:1,[Row]")
						src<<output("[Commas(ST.Cost*(glob.progress.EconomyMana/100))]","GridX:2,[Row]")

		if(Z=="MaxMana")
			for(var/mob/Players/Q in players)
				Row++
				src<<output(Q,"GridX:1,[Row]")
				src<<output("Max Mana:[Q.ManaMax]","GridX:2,[Row]")

		if(Z=="Hair")
			src<<output("Select an icon!","SelectedCustomize")
			for(var/A in Hair_List)
				Row++
				if(istype(usr,/mob/Creation))
					src<<output(A,"GridZ:1,[Row]")
				else
					src<<output(A,"GridX:1,[Row]")
		if(Z=="Blasts")
			for(var/A in Blast_List)
				Row++
				if(istype(usr,/mob/Creation))
					src<<output(A,"GridZ:1,[Row]")
				else
					src<<output(A,"GridX:1,[Row]")

		if(Z=="BaseIcon")
			var/race/r = GetRaceInstanceFromType(race.type)
			for(var/A in r.icon_male)
				Row++
				src<<output(A,"GridX:1,[Row]")
			for(var/B in r.icon_female)
				Row++
				src<<output(B,"GridX:1,[Row]")
			for(var/C in r.icon_neuter)
				Row++
				src<<output(C,"GridX:1,[Row]")

		if(Z=="Loot")
			src<<output("Steal from others for fun and profit!","SelectedCustomize")
			for(var/obj/Money/m in Lootee)
				Row++
				src << output(m, "GridX:1,[Row]")
				src << output(m.Level, "GridX:2,[Row]")
			for(var/obj/Items/O in Lootee)
				if(O.Stealable)
					Row++
					src << output(O, "GridX:1,[Row]")

mob
	verb
		Change_Base_Icon()
			usr.Grid("BaseIcon")

var/list
	Human_List=new
	Alien_List=new
	Demon_List=new
	Namekian_List=new
	Makyo_List=new
	Changeling_List=new
	Kaio_List=new
	Android_List=new

obj/Creation_Icons
	proc/Creation_Click(mob/A)
		if(A.IconClicked==0)
			A.IconClicked=1
			A.icon=src
			winshow(A,"Grid1",0)
			A.Grid("Hair")
			icon=initial(icon)
			A.IconClicked=0
	Click() Creation_Click(usr)
	Kaio
		Icon_1
			icon='CustomMale.dmi'
		Icon_2
			icon='CustomFemale.dmi'
	Human
		Icon_1
			icon='MaleLight.dmi'
		Icon_2
			icon='MaleTan.dmi'
		Icon_3
			icon='MaleDark.dmi'
		Icon_1Female
			icon='FemaleLight.dmi'
		Icon_2Female
			icon='FemaleTan.dmi'
		Icon_3Female
			icon='FemaleDark.dmi'
		Gem_Male
			icon='Male Base - Gemini.dmi'
		Gem_Fem_Male
			icon='Male Fem Base - Gemini.dmi'
		Gem_Masc_Male
			icon='Male Masc Base - Gemini.dmi'
		Gem_Fat_Male
			icon='Male Base Fat - Gemini.dmi'
		Gem_Female
			icon='Female Base - Gemini.dmi'
		Gem_Masc_Female
			icon='Female Base Masc - Gemini.dmi'
		Gem_Fat_Female
			icon='Female Base Fat - Gemini.dmi'

	Makyo
		Icon_1
			icon='Makyo1.dmi'
		Icon_2
			icon='Makyo2.dmi'
		Icon_3
			icon='Makyo3.dmi'
		Icon_4
			icon='Makyo4.dmi'
		Gem_Makyo_Fem
			icon = 'Makyo F.dmi'
		Gem_Makyo_Masc
			icon = 'Makyo M.dmi'
	Namekian
		Icon_0
			icon='Standard Namekian.dmi'
		Icon_1
			icon='Standard Namekian - Fat.dmi'
		Icon_2
			icon='Namek1.dmi'
		Icon_3
			icon='Namek2.dmi'
		Icon_3
			icon='Namek3.dmi'
		Icon_5
			icon='Namek4.dmi'
		Icon_6
			icon='Namek5.dmi'

	Demon
		Icon_1
			icon='Demon1.dmi'
		Icon_2
			icon='Demon2.dmi'
		Icon_3
			icon='Demon3.dmi'
		Icon_4
			icon='Demon4.dmi'
		Icon_5
			icon='Demon5.dmi'
	Android
		Icon_1
			icon='Android1.dmi'
		Icon_2
			icon='Android2.dmi'
		Icon_4
			icon='Android4.dmi'
		Icon_5
			icon='Android5.dmi'
		Icon_6
			icon='Android6.dmi'
		Icon_9
			icon='Android9.dmi'
		Icon_11
			icon='Android11.dmi'
	Alien


		Squid
			icon='Squid Type.dmi'

		Octopus
			icon='Octopus Type.dmi'
		Konats
			icon='AlienElf_Male.dmi'
		Konats_Female
			icon='AlienElf_Female.dmi'
		Heran
			icon='AlienHeran_Male.dmi'
		Heran_Female
			icon='AlienHeran_Female.dmi'
		Arlia
			icon='AlienArlian.dmi'
		Arcosia
			icon='AlienAnt.dmi'
		Kanassa
			icon='AlienKanassa.dmi'
		Cui
			icon='AlienKui.dmi'
		Appule
			icon='AlienAppule.dmi'
		Zarbon
			icon='AlienZarbon.dmi'
		Ginyu
			icon='AlienGinyu.dmi'
		Bas
			icon='AlienGuldo.dmi'
		Brench
			icon='AlienJeice.dmi'
		Burter
			icon='AlienBurter.dmi'
		Yardrat
			icon='AlienYardrat.dmi'
		Yuken
			icon='AlienYukeno.dmi'
		Baseno
			icon='AlienBasenio.dmi'
		Pikkon
			icon='AlienPiccon.dmi'
		Zoon
			icon='AlienPui.dmi'
		Alpha
			icon='AlienLime.dmi'
		Beerus
			icon='AlienBeerus.dmi'
		Jaco
			icon='AlienJaco.dmi'
		Hit
			icon='AlienHit.dmi'
		Jiren
			icon='AlienJiren.dmi'
		Ledgic
			icon='AlienLedgic.dmi'
		Blue
			icon='AlienBlue.dmi'
		Brace
			icon='AlienBrace.dmi'
		Xeno
			icon='AlienXeno.dmi'
		Zabrak_Male
			icon='AlienZabrak.dmi'
		Twilek_Female
			icon='AlienTwilek_Female.dmi'
		Bettle
			icon='AlienBeetle.dmi'
		Hive
			icon='AlienHive.dmi'
		Squid
			icon='AlienSquid.dmi'
		Shark
			icon='AlienShark.dmi'
		Ray
			icon='AlienWhiteShark.dmi'
		Frog
			icon='AlienFrog.dmi'
		Bullfrog
			icon='AlienBullfrog.dmi'
		Cheetah
			icon='AlienCheetah.dmi'
		Tigran
			icon='AlienTiger_Male.dmi'
		Tigran_Female
			icon='AlienTiger_Female.dmi'
		Reptile
			icon='AlienLizard_Male.dmi'
		Reptile_Female
			icon='AlienLizard_Female.dmi'
		Avian
			icon='AlienAvian_Male.dmi'
		Avian_Female
			icon='AlienAvian_Female.dmi'
		Lycan
			icon='AlienWolf_Male.dmi'
		Lycan_Female
			icon='AlienWolf_Female.dmi'
	Changeling
		Frieza
			icon='Frieza1.dmi'
		Cooler
			icon='Cooler1.dmi'
		Chilled
			icon='Chilled1.dmi'

var/list/Clothes_List=new
var/list/Turfs_List=new

var/list/Aura_List=new
obj/Aura_Icons
	proc/Aura_Click(mob/A)
		if(A.IconClicked==0)
			A.IconClicked=1
			var/Aura_Color=input(A,"Choose color") as color|null
			if(Aura_Color)
				icon+=Aura_Color
			A.Auraz("Remove")
			for(var/obj/Skills/Power_Control/Z in A.contents)
				Z.sicon=src.icon
				Z.sicon_state=src.icon_state
			A.IconClicked=0
			icon=initial(icon)
	Click() Aura_Click(usr)
	Aura_1
		icon='Auras.dmi'
		icon_state="1"
	Aura_2
		icon='Auras.dmi'
		icon_state="2"
	Aura_3
		icon='Auras.dmi'
		icon_state="3"
	Aura_4
		icon='Auras.dmi'
		icon_state="4"
	Aura_5
		icon='Auras.dmi'
		icon_state="5"
	Aura_6
		icon='Auras.dmi'
		icon_state="6"
	Aura_7
		icon='Auras.dmi'
		icon_state="7"


var/list/Charge_List=new
obj/Charge_Icons
	proc/Charge_Click(mob/A)
		if(A.IconClicked==0)
			A.IconClicked=1
			var/Blast_Color=input(A,"Choose color") as color|null
			if(Blast_Color) icon+=Blast_Color
			A.ChargeIcon=image(src.icon,src.icon_state)
			A.IconClicked=0
			icon=initial(icon)
	Click() Charge_Click(usr)
	Charge_1
		icon='BlastCharges.dmi'
		icon_state="1"
	Charge_2
		icon='BlastCharges.dmi'
		icon_state="2"
	Charge_3
		icon='BlastCharges.dmi'
		icon_state="3"
	Charge_4
		icon='BlastCharges.dmi'
		icon_state="4"
	Charge_5
		icon='BlastCharges.dmi'
		icon_state="5"
	Charge_6
		icon='BlastCharges.dmi'
		icon_state="6"
	Charge_7
		icon='BlastCharges.dmi'
		icon_state="7"
	Charge_8
		icon='BlastCharges.dmi'
		icon_state="8"
	Charge_9
		icon='BlastCharges.dmi'
		icon_state="9"


var/list/Blast_List=new
obj/Blast_Icons
	proc/Blast_Click(mob/A)
		if(A.IconClicked==0)
			A.IconClicked=1
			var/Blast_Color=input(A,"Choose color") as color|null
			if(Blast_Color) icon+=Blast_Color
			switch(input(A,"Are you sure?") in list("Yes","No"))
				if("Yes")
					var/list/Skills=new
					Skills+="Cancel"
					for(var/obj/Skills/Projectile/B in A) Skills+=B
					var/obj/B=input(A,"Add icon to which skill?") in Skills
					if(istype(B, /obj/Skills/Projectile))
						if(istype(B, /obj/Skills/Projectile/Beams))
							B:IconLock=icon
							B:LockX=0
							B:LockY=0
						else
							var/icon/i=icon(icon, icon_state)
							B:IconLock=i
							B:LockX=0
							B:LockY=0
					A.IconClicked=0
				if("No")
					A.IconClicked=0
			icon=initial(icon)
	Click() Blast_Click(usr)
	Blast_1
		icon='Blasts.dmi'
		icon_state="1"
	Blast_2
		icon='Blasts.dmi'
		icon_state="2"
	Blast_3
		icon='Blasts.dmi'
		icon_state="3"
	Blast_4
		icon='Blasts.dmi'
		icon_state="4"
	Blast_5
		icon='Blasts.dmi'
		icon_state="5"
	Blast_6
		icon='Blasts.dmi'
		icon_state="6"
	Blast_7
		icon='Blasts.dmi'
		icon_state="7"
	Blast_8
		icon='Blasts.dmi'
		icon_state="8"
	Blast_9
		icon='Blasts.dmi'
		icon_state="9"
	Blast_10
		icon='Blasts.dmi'
		icon_state="10"
	Blast_11
		icon='Blasts.dmi'
		icon_state="11"
	Blast_12
		icon='Blasts.dmi'
		icon_state="12"
	Blast_13
		icon='Blasts.dmi'
		icon_state="13"
	Blast_14
		icon='Blasts.dmi'
		icon_state="14"
	Blast_15
		icon='Blasts.dmi'
		icon_state="15"
	Blast_16
		icon='Blasts.dmi'
		icon_state="16"
	Blast_17
		icon='Blasts.dmi'
		icon_state="17"
	Blast_18
		icon='Blasts.dmi'
		icon_state="18"
	Blast_19
		icon='Blasts.dmi'
		icon_state="19"
	Blast_20
		icon='Blasts.dmi'
		icon_state="20"
	Blast_21
		icon='Blasts.dmi'
		icon_state="21"
	Blast_22
		icon='Blasts.dmi'
		icon_state="22"
	Blast_23
		icon='Blasts.dmi'
		icon_state="23"
	Blast_24
		icon='Blasts.dmi'
		icon_state="24"
	Blast_25
		icon='Blasts.dmi'
		icon_state="25"
	Blast_26
		icon='Blasts.dmi'
		icon_state="26"
	Blast_27
		icon='Blasts.dmi'
		icon_state="27"
	Blast_28
		icon='Blasts.dmi'
		icon_state="28"
	Blast_29
		icon='Blasts.dmi'
		icon_state="29"
	Blast_30
		icon='Blasts.dmi'
		icon_state="30"
	Blast_31
		icon='Blasts.dmi'
		icon_state="31"
	Blast_32
		icon='Blasts.dmi'
		icon_state="32"
	Blast_33
		icon='Blasts.dmi'
		icon_state="33"
	Blast_34
		icon='Blasts.dmi'
		icon_state="34"
	Blast_35
		icon='Blasts.dmi'
		icon_state="35"
	Blast_36
		icon='Blasts.dmi'
		icon_state="36"
	Blast_37
		icon='Blasts.dmi'
		icon_state="37"
	Blast_38
		icon='Blasts.dmi'
		icon_state="38"
	Blast_39
		icon='Blasts.dmi'
		icon_state="39"
	Blast_40
		icon='Blasts.dmi'
		icon_state="40"
	Blast_41
		icon='Blasts.dmi'
		icon_state="41"
	Blast_42
		icon='Blasts.dmi'
		icon_state="42"
	Blast_43
		icon='Blasts.dmi'
		icon_state="43"
	Blast_44
		icon='Blasts.dmi'
		icon_state="44"
	Blast_45
		icon='Blasts.dmi'
		icon_state="45"
	Blast_46
		icon='Blasts.dmi'
		icon_state="46"
	Blast_47
		icon='Blasts.dmi'
		icon_state="47"
	Blast_48
		icon='Blasts.dmi'
		icon_state="48"
	Blast_49
		icon='Blasts.dmi'
		icon_state="49"
	Blast_50
		icon='Blasts.dmi'
		icon_state="50"
	Blast_51
		icon='Blasts.dmi'
		icon_state="51"
	Blast_52
		icon='Blasts.dmi'
		icon_state="52"
	Blast_53
		icon='Blasts.dmi'
		icon_state="53"
	Blast_54
		icon='Blasts.dmi'
		icon_state="54"
	Blast_55
		icon='Blasts.dmi'
		icon_state="55"
	Blast_56
		icon='Blasts.dmi'
		icon_state="56"
	Blast_57
		icon='Blasts.dmi'
		icon_state="57"
	Blast_58
		icon='Blasts.dmi'
		icon_state="58"
	Blast_59
		icon='Blasts.dmi'
		icon_state="59"
	Blast_60
		icon='Blasts.dmi'
		icon_state="60"
	Blast_61
		icon='Blasts.dmi'
		icon_state="61"
	Blast_62
		icon='Blasts.dmi'
		icon_state="62"
	Blast_63
		icon='Blasts.dmi'
		icon_state="63"
	Blast_64
		icon='Blasts.dmi'
		icon_state="64"
	Blast_65
		icon='Blasts.dmi'
		icon_state="65"
	Blast_66
		icon='Blasts.dmi'
		icon_state="66"
	Blast_67
		icon='Blasts.dmi'
		icon_state="67"
	Blast_68
		icon='Blasts.dmi'
		icon_state="68"
	Blast_69
		icon='Blasts.dmi'
		icon_state="69"
	Blast_70
		icon='Blasts.dmi'
		icon_state="70"
	Blast_71
		icon='Blasts.dmi'
		icon_state="71"
	Beam_1
		icon='Beam1.dmi'
		icon_state="head"
	Beam_2
		icon='Beam2.dmi'
		icon_state="head"
	Beam_3
		icon='Beam3.dmi'
		icon_state="head"
	Beam_4
		icon='Beam4.dmi'
		icon_state="head"
	Beam_5
		icon='Beam5.dmi'
		icon_state="head"
	Beam_6
		icon='Beam6.dmi'
		icon_state="head"
	Beam_8
		icon='Beam8.dmi'
		icon_state="head"
	Beam_9
		icon='Beam9.dmi'
		icon_state="head"
	Beam_10
		icon='Beam10.dmi'
		icon_state="head"
	Beam_11
		icon='Beam11.dmi'
		icon_state="head"
	Beam_12
		icon='Beam12.dmi'
		icon_state="head"
	Beam_13
		icon='Beam13.dmi'
		icon_state="head"
	Beam_14
		icon='Beam14.dmi'
		icon_state="head"
	Beam_15
		icon='Beam15.dmi'
		icon_state="head"
	Beam_16
		icon='Beam16.dmi'
		icon_state="head"
	Beam_17
		icon='Beam17.dmi'
		icon_state="head"
	Beam_18
		icon='Beam18.dmi'
		icon_state="head"