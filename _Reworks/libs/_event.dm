/*
#define EVENT(EVENT, ARGS...)
	(Requires BYOND 511 and above; see demo for alternative)

	Define an event for a datum.
	This automatically defines an event and a proc that you can call to fire it.

	The same arguments given to this are expected from all callbacks.

	e.g.
		```
		Listener
			proc
				ListenTo(MyDatum/MyDatum)
					EVENT_ADD(MyDatum.OnMyEvent, src, .proc/HandleMyEvent)
					// .proc/HandleMyEvent is shorthand
					// for /Listener/proc/HandleMyEvent

				HandleMyEvent(MyDatum/MyDatum, X, Y)
					world << "[src].OnMyEvent([MyDatum], [X], [Y])"
					// When MyDatum.SomethingHappened() is called, this outputs
					// "/Listener.OnMyEvent(/MyDatum, 123, 456)" to the world.

		MyDatum
			// BYOND 511 and above:

			EVENT(OnMyEvent, MyDatum/MyDatum, X, Y)

			proc
				SomethingHappened()
					OnMyEvent(src, 123, 456)

			// Before BYOND 511:

			var/tmp/event/OnMyEvent // (MyDatum/MyDatum, X, Y)

			proc
				SomethingHappened()
					if(OnMyEvent)
						OnMyEvent.Fire(src, 123, 456)
		```

#define EVENT_ADD(Event, Object, Callback)
	Add the Callback (as a path to a proc) of Object (as an object or \ref text)
	to be called by Event.Fire().

#define EVENT_REMOVE(Event, Object, Callback)
	Remove Object.Callback() from event handlers.
	If Callback is null, then all of Object's callbacks are removed from Event.

#define EVENT_REMOVE_OBJECT(Event, Object)
	Remove all handlers of Object for Event.

event
	proc
		Fire(...)
			The same arguments given to this are passed to all callbacks.
			This only needs to be used for pre-BYOND 511 projects.
			Events don't exist if they don't have any listeners, so
			check for the existence of an event before calling this.

*/

// Implementation below.


#define EVENT_ADD(EVENT, OBJECT, CALLBACK) \
	if(!EVENT) EVENT = new; \
	EVENT.Add(OBJECT, CALLBACK)

#define EVENT_REMOVE(EVENT, OBJECT, CALLBACK) if(EVENT) { \
		EVENT.Remove(OBJECT, CALLBACK); \
		if(!EVENT.handlers) EVENT = null; \
	}

#define EVENT_REMOVE_OBJECT(EVENT, OBJECT) if(EVENT) { \
		EVENT.RemoveObject(OBJECT); \
		if(!EVENT.handlers) EVENT = null; \
	}

#if DM_VERSION >= 511
#define EVENT(EVENT, ARGS...) \
	var/tmp/event/EVENT; \
	proc/EVENT(ARGS) if(EVENT) { \
		EVENT.Fire(arglist(args)); \
		if(!EVENT.handlers) EVENT = null \
	}
#endif

event
	var
		handlers[]

	proc
		Add(Object, Callback)
			if(!handlers) handlers = new
			if(!handlers[Object]) handlers[Object] = list()
			handlers[Object] |= Callback

		Remove(Object, Callback)
			if(handlers)
				if(Callback)
					var callbacks[] = handlers[Object]
					if(callbacks)
						callbacks -= Callback
						if(!callbacks.len) RemoveObject(Object)
					else RemoveObject(Object)
				else RemoveObject(Object)

		RemoveObject(Object)
			if(handlers) handlers -= Object
			if(handlers && !handlers.len) handlers = null

		Fire()
			var handler, object, callbacks[], callback

			for(handler in handlers)
				object = istext(handler) ? locate(handler) : handler
				if(!object) continue
				callbacks = handlers[handler]
				if(!(callbacks && callbacks.len))
					RemoveObject(handler)
					continue
				for(callback in callbacks)
					call(object, callback)(arglist(args))
					if(!object) break

			// Clean up null handlers that were deleted at some point
			if(handlers) while(handlers.Remove(null))
			if(handlers && !handlers.len) handlers = null
