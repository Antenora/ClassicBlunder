proc
	Flight(mob/m, var/Start=0, var/Land=0)
		sleep(1)

		if(m)
			if(Start)
				if(m.Flying)
					m.density=0
					m.layer=MOB_LAYER+1.5 //below the day/night blanket, above walk-behind scenery

			if(Land)
				if(m.Flying)
					m.Flying=0
					m.density=1
					m.layer=MOB_LAYER

			if(m.Flying)
				animate(m,pixel_z=48,time=5)
				spawn(5)
					if(m && m.Flying)
						animate(m,pixel_z=43,time=5)
					spawn(5)
						if(m && m.Flying)
							Flight(m)
			else if(m.passive_handler.Get("Skimming"))
				animate(m,pixel_z=8,time=5)
				spawn(5)
					if(m && m.passive_handler && m.passive_handler.Get("Skimming"))
						animate(m,pixel_z=3,time=5)
					spawn(5)
						if(m)
							Flight(m)
			else
				var/drop = m.pixel_z //animate commits the end value instantly, read first
				animate(m,pixel_z=0,time=5)
				spawn(5)
					if(m)
						m.icon_state=""
						if(drop > 8) Landfall(m, 0.2) //real flight only, not a skim settle