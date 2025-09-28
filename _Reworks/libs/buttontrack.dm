button_tracker
	var
		/*
			Keeps track of what buttons are pressed.
			You shouldn't ever need to use this in your own code.
		*/
		list/is_pressed

	EVENT(OnPressed, button_tracker/buttons, button)
	EVENT(OnReleased, button_tracker/buttons, button)

	proc
		/*
			Returns a list of all buttons pressed.
			Changes to this list won't affect the button tracker,
			and the resulting list is not an associative list.
		*/
		AllPressed()
			var list/a = new
			a.Insert(1, is_pressed)
			return a

		/*
			Press a button.
			Until the button is released, IsButtonPressed returns TRUE.
			Calls ButtonPressed if the button wasn't already pressed.
		*/
		Press(button)
			if(IsReleased(button))
				if(!is_pressed)
					is_pressed = list()
				is_pressed[button] = TRUE
				Pressed(button)

		/*
			Release a button.
			Until the button is pressed, IsButtonPressed returns FALSE.
			Calls ButtonReleased if the button wasn't already released.
		*/
		Release(button)
			if(IsPressed(button))
				is_pressed -= button
				Released(button)
				if(!length(is_pressed))
					is_pressed = null

		/*
			Is the button currently pressed?
			Returns TRUE or FALSE.
		*/
		IsPressed(button)
			return is_pressed ? is_pressed[button] : FALSE

		#if DM_VERSION >= 512
		/*
			Operator form of IsPressed.
		*/
		operator[](button)
			return IsPressed(button)

		/*
			Operator form of Press and Release.
		*/
		operator[]=(button, pressed)
			pressed ? Press(button) : Release(button)
		#endif

		/*
			Is the button currently released (not pressed)?
			Returns TRUE or FALSE.
		*/
		IsReleased(button)
			return !IsPressed(button)

		/*
			Called when a button is pressed.
			Does nothing by default, but handy for overriding.
		*/
		Pressed(button)
			OnPressed(src, button)

		/*
			Called when abutton is released.
			Does nothing by default, but handy for overriding.
		*/
		Released(button)
			OnReleased(src, button)
