/obj/Skills/Buffs/SlotlessBuffs/Autonomous
	The_Word_Of_God
		TextColor=rgb(247,218,27)
		NeedsHealth = 75
		TooMuchHealth = 90
		HealthThreshold = 0.001
		ActiveMessage = "is shrouded in a faint angelic spark, heralding the end of their enemies."
		OffMessage = "loses their angelic glow..."
		IconLock='WordOfGodSpark.dmi'
		passives = list("PureDamage" = 0.5, "PureReduction" = 0.25, "Shearing" = 1)


/obj/Skills/Buffs/SpecialBuffs
	The_Ten_Commandments
		TextColor=rgb(247,218,27)
		NeedsHealth = 35
		TooMuchHealth = 60
		HealthThreshold = 0.001
		SpecialSlot=0
		Slotless=1
		passives = list("Deflection" = 1, "Instinct" = 2, "Pursuer" = 2, "Flicker" = 2, "BeyondPurity" = 1, "Godspeed" = 1)
		StrMult = 1.2
		ForMult = 1.2
		SpdMult = 1.2
		RecovMult= 1.2
		Cooldown = 300
		CooldownStatic = 1
		IconUnder = 1
		VaizardHealth=7.5
		TopOverlayLock = 'AngelicGlow.dmi'
		TopOverlayX = -32
		TopOverlayY = -32
		OverlaySize = 1.3
		var/tmp/animating = FALSE
		var/tmp/ActiveState = FALSE
		adjust(mob/p)
			src.VaizardHealth = 7.5 * max(p.AscensionsAcquired, 1)
		verb/The_Ten_Commandments()
			set category = "Skills"
			set name = "The Ten Commandments"
			var/mob/M = usr
			if(!M) return

			var/activating = !src.ActiveState

			if(activating)//if I did this right, this should stop it from doing dumb things!
				if(cooldown_remaining > 0)
					return

				var/hp_percent = (M.Health)
				if(hp_percent > TooMuchHealth)
					M << "<font color='#f7da1b'>Your current health prevents invoking the Ten Commandments. (Try again at 35%!)</font>"
					return

			adjust(usr)
			src.Trigger(usr)
			src.ActiveState = !src.ActiveState
			if(src.animating) return
			src.animating = TRUE

			if(activating)
				var/image/i = image(icon='CaledfwlchAura.dmi', pixel_x=-32, pixel_y=-2, loc=M)
				var/image/w = image(icon=src.icon, pixel_x=src.pixel_x, pixel_y=src.pixel_y, loc=M, layer=EFFECTS_LAYER)
				i.appearance_flags = KEEP_APART | NO_CLIENT_COLOR | RESET_ALPHA | RESET_COLOR
				i.blend_mode = BLEND_ADD
				world << i
				world << w

				animate(i, alpha=0)
				animate(w, alpha=0, color=list(1,0,0, 0,1,0, 0,0,1, 1,1,0.2))
				animate(w, alpha=255, time=10)

				sleep(10)
				Quake(15)
				M.OMessage(10, "<font color='#f7da1b'><b>The light of God parts the clouds, searing away all darkness...</b></font>")

				animate(i, alpha=255, time=20)
				sleep(10)
				Quake(35)
				M.OMessage(10, "<font color='#f7da1b'><b>[M] summons forth the power to topple nations!!!</b></font>", "<font color=#f7da1b>[M]([M.key]) unleashed The Ten Commandments.")
				KenShockwave(M, icon='KenShockwaveGold.dmi', Size=0.5, Blend=2, Time=3)

				del w
				sleep(10)
				Quake(75)
				M.OMessage(10, "<font color='#f7da1b'><b>[M] is enshrouded in angelic power; Salvation belongs to He Who Sits on The Throne!</b></font>")
				animate(i, alpha=0, time=30)
				spawn(30)
					del i
					src.animating = FALSE
			else
				var/image/fade = image(icon='CaledfwlchAura.dmi', pixel_x=-32, pixel_y=-2, loc=M)
				fade.appearance_flags = KEEP_APART | NO_CLIENT_COLOR | RESET_ALPHA | RESET_COLOR
				fade.blend_mode = BLEND_ADD
				world << fade
				M.OMessage(10, "<font color='#f7da1b'><b>The divine radiance fades from [M]...</b></font>")
				animate(fade, alpha=255)
				animate(fade, alpha=0, time=30)
				spawn(30)
					del fade
					src.animating = FALSE
