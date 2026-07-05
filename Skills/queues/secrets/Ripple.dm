obj
	Skills
		Queue
			Rebuff_Overdrive
				DamageMult=2.5
				AccuracyMult=1
				KBAdd=5
				Quaking=5
				Shining='Ripple Barrier.dmi'
				IconLock='Ultima Arm.dmi'
				Duration=2
				Counter=1
				ActiveMessage="rushes in with an elbow counter assault: <b>Rebuff Overdrive!!</b>"
				adjust(mob/p)
					DamageMult=2.5
				//set manually so no verb
			Zoom_Punch
				DamageMult=2.5
				AccuracyMult = 1.1
				Warp=3
				KBAdd=5
				Duration=5
				Instinct=1
				IconLock='Ultima Arm.dmi'
				HitMessage="dislocates their arm to deliver a surprise strike: <b>Zoom Punch!</b>"
				adjust(mob/p)
					DamageMult=2.5
					var/secretlevel= p.getSecretLevel()
					Warp=3 * secretlevel
				//set manually so no verb
			Sunlight_Yellow_Overdrive
				DamageMult=1
				AccuracyMult=20
				Warp=5
				KBAdd=1
				KBMult=0.00001
				Combo=25
				Quaking=10
				Instinct=4
				AntiSunyata=1
				IconLock='Ripple Arms.dmi'
				HitSparkIcon='Hit Effect Ripple.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=2
				Duration=5
				ActiveMessage="settles their hands into a ready position, as they start to burn brightly with the Ripple...</font></b>"
				ComboHitMessages=list("says: How my heart resonates...","says: I'm pulsing with Heat and Life...", "says: My very blood is a symphony within me...", "yells:<b><font color=#FFD700>Sun...</font></b>", "<b><font color=#FFD700>...light...</font>", "<b><font color=#FFD700>yells:Yell... </font>", "yells:ooww...", "<b><font color=#FFD700>Ov...", \
									  "<b><font color=#FFD700>says:er....</font>", "<b><font color=#FFD700>says:..dri...</font>", "<b><font color=#FFD700>..ve!!!</font>")
				adjust(mob/p)
					var/secretlevel = p.getSecretLevel()
					DamageMult= 1 * (secretlevel)
					Combo=25 + (5 * secretlevel)
					HolyMod=2.5 * secretlevel
					Scorching= 5 * secretlevel
				//set manually so no verb