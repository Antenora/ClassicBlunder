/* logging system
 *
 * file:   _main_.dm
 * author: Valekor
 * date:   June 3rd 2014
 * description:
 * EventScheduler by Stephen001 reduces the CPU usage of intensive things that repeatedly trigger.
 * Be they loops (like a weather system) or single events that are the same yet different
 * (write to log file but different in the same that it's not the same text being logged eah time)
*/

//#ifndef EVENT_SCHEDULING_MESSAGE
//#error "Stephen001.EventScheduler is not included, please download it from here: http://www.byond.com/developer/Stephen001/EventScheduling"
//#endif

var/global/tmp/EventScheduler/LOGscheduler = new()

Event/writeToLog
	var/text
	var/destination

	New(var/T, var/D)
		src.text = T
		src.destination = D

	fire()
		..() // let the EventScheduler do its thing first
		file( src.destination ) << src.text