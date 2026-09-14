#define LOGDB_PATH "Saves/logs.db"
#define LOGDB_PORTRAITS "Saves/Portraits/"
#define LOGDB_EXPORTS "Saves/Exports/"
#define LOGDB_ROW_CAP 8000

var/database/logdb
var/logdb_ready = 0
var/list/logdb_pending = list()
var/logdb_flush_queued = 0
var/list/logdb_legacy_last = list()
var/list/logdb_alert_words = list()
var/list/logdb_followers = list()
var/list/LOGDB_CHAT_TYPES = list("say", "yell", "ask", "looc", "whisper", "think", "ooc", "emote", "roll", "legacy")
var/list/LOGDB_IC_TYPES = list("say", "yell", "ask", "whisper", "think", "emote", "roll")

proc/LogDbExec(database/query/q, sql, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14)
	switch(args.len)
		if(2) q.Add(sql)
		if(3) q.Add(sql, a1)
		if(4) q.Add(sql, a1, a2)
		if(5) q.Add(sql, a1, a2, a3)
		if(6) q.Add(sql, a1, a2, a3, a4)
		if(7) q.Add(sql, a1, a2, a3, a4, a5)
		if(8) q.Add(sql, a1, a2, a3, a4, a5, a6)
		if(9) q.Add(sql, a1, a2, a3, a4, a5, a6, a7)
		if(10) q.Add(sql, a1, a2, a3, a4, a5, a6, a7, a8)
		if(11) q.Add(sql, a1, a2, a3, a4, a5, a6, a7, a8, a9)
		if(12) q.Add(sql, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
		if(13) q.Add(sql, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11)
		if(14) q.Add(sql, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12)
		if(15) q.Add(sql, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13)
		else q.Add(sql, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14)
	if(!q.Execute(logdb))
		world.log << "logdb: [q.ErrorMsg()] :: [copytext(sql, 1, 120)]"
		return 0
	return 1

proc/LogDbOpen()
	if(logdb_ready) return 1
	logdb = new(LOGDB_PATH)
	var/database/query/q = new
	q.Add("PRAGMA journal_mode=WAL")
	if(q.Execute(logdb)) q.NextRow()
	LogDbExec(q, "CREATE TABLE IF NOT EXISTS events (id INTEGER PRIMARY KEY AUTOINCREMENT, t TEXT NOT NULL, ty TEXT NOT NULL, actor TEXT, name TEXT, color TEXT, font TEXT, pt TEXT, z INTEGER, x INTEGER, y INTEGER, area TEXT, body TEXT, sbody TEXT, meta TEXT)")
	LogDbExec(q, "CREATE INDEX IF NOT EXISTS ix_events_t ON events(t)")
	LogDbExec(q, "CREATE INDEX IF NOT EXISTS ix_events_actor ON events(actor, id)")
	LogDbExec(q, "CREATE INDEX IF NOT EXISTS ix_events_ty ON events(ty, id)")
	LogDbExec(q, "CREATE INDEX IF NOT EXISTS ix_events_area ON events(area, id)")
	LogDbExec(q, "CREATE TABLE IF NOT EXISTS witness (event_id INTEGER NOT NULL, ckey TEXT NOT NULL, muffled INTEGER NOT NULL DEFAULT 0)")
	LogDbExec(q, "CREATE INDEX IF NOT EXISTS ix_witness_ckey ON witness(ckey, event_id)")
	LogDbExec(q, "CREATE INDEX IF NOT EXISTS ix_witness_event ON witness(event_id)")
	LogDbExec(q, "CREATE TABLE IF NOT EXISTS admin_actions (id INTEGER PRIMARY KEY AUTOINCREMENT, t TEXT NOT NULL, actor TEXT, name TEXT, level INTEGER, category TEXT, action TEXT, target TEXT, detail TEXT)")
	LogDbExec(q, "CREATE INDEX IF NOT EXISTS ix_admin_t ON admin_actions(t)")
	LogDbExec(q, "CREATE INDEX IF NOT EXISTS ix_admin_actor ON admin_actions(actor, id)")
	LogDbExec(q, "CREATE TABLE IF NOT EXISTS logins (id INTEGER PRIMARY KEY AUTOINCREMENT, t TEXT NOT NULL, ckey TEXT, name TEXT, ip TEXT, cid TEXT, ev TEXT, reason TEXT)")
	LogDbExec(q, "CREATE INDEX IF NOT EXISTS ix_logins_t ON logins(t)")
	LogDbExec(q, "CREATE INDEX IF NOT EXISTS ix_logins_ckey ON logins(ckey, id)")
	LogDbExec(q, "CREATE INDEX IF NOT EXISTS ix_logins_ip ON logins(ip)")
	LogDbExec(q, "CREATE INDEX IF NOT EXISTS ix_logins_cid ON logins(cid)")
	LogDbExec(q, "CREATE TABLE IF NOT EXISTS notes (id INTEGER PRIMARY KEY AUTOINCREMENT, t TEXT NOT NULL, admin TEXT, ckey TEXT, event_id INTEGER, severity TEXT, body TEXT)")
	LogDbExec(q, "CREATE INDEX IF NOT EXISTS ix_notes_ckey ON notes(ckey, id)")
	LogDbExec(q, "CREATE TABLE IF NOT EXISTS pins (ckey TEXT NOT NULL, event_id INTEGER NOT NULL, t TEXT NOT NULL, PRIMARY KEY (ckey, event_id))")
	LogDbExec(q, "CREATE TABLE IF NOT EXISTS scenes (ckey TEXT NOT NULL, skey TEXT NOT NULL, title TEXT, PRIMARY KEY (ckey, skey))")
	LogDbExec(q, "CREATE TABLE IF NOT EXISTS alerts (word TEXT PRIMARY KEY, added_by TEXT, t TEXT)")
	logdb_ready = 1
	LogDbLoadAlerts()
	return 1

proc/LogDbLoadAlerts()
	logdb_alert_words = list()
	var/database/query/q = new
	if(LogDbExec(q, "SELECT word FROM alerts ORDER BY word"))
		while(q.NextRow())
			var/list/row = q.GetRowData()
			logdb_alert_words += "[row["word"]]"

proc/LogAreaOf(atom/A)
	var/atom/cur = A
	var/n = 0
	while(cur && n < 8)
		if(isarea(cur))
			var/area/ar = cur
			return "[ar.name]"
		cur = cur.loc
		n++
	return ""

proc/LogTurfOf(atom/A)
	var/atom/cur = A
	var/n = 0
	while(cur && n < 8)
		if(isturf(cur)) return cur
		cur = cur.loc
		n++
	return null

proc/LogPortraitFile(mob/M)
	if(!M || !M.ckey) return ""
	var/state = M.PortraitState()
	var/key = "[M.ckey]_[M.chat_portrait_ver]_[M.ChatPortraitKey(state)]"
	var/name = "pt_[key].png"
	var/path = "[LOGDB_PORTRAITS][name]"
	if(!fexists(path))
		var/icon/I = M.ChatPortraitIcon(state)
		if(I) fcopy(I, path)
	return name

proc/LogEvent(ty, mob/actor, body, list/witnesses, list/muffled, list/meta, atom/where)
	var/list/r = list()
	r["table"] = "events"
	r["ty"] = ty
	r["actor"] = ""
	r["name"] = ""
	r["color"] = ""
	r["font"] = ""
	r["pt"] = ""
	r["z"] = 0
	r["x"] = 0
	r["y"] = 0
	r["area"] = ""
	r["body"] = isnull(body) ? "" : "[body]"
	r["sbody"] = ""
	r["meta"] = islist(meta) ? json_encode(meta) : ""
	var/atom/place = where ? where : actor
	if(actor)
		r["actor"] = actor.ckey ? actor.ckey : ""
		r["name"] = "[actor.name]"
		r["color"] = "[actor.Text_Color]"
		if(ty == "emote") r["color"] = "[actor.Emote_Color]"
		r["font"] = actor.RPFont ? "[actor.RPFont]" : ""
		if(actor.ckey && (ty in LOGDB_IC_TYPES)) r["pt"] = LogPortraitFile(actor)
	if(place)
		var/turf/T = LogTurfOf(place)
		if(T)
			r["z"] = T.z
			r["x"] = T.x
			r["y"] = T.y
		r["area"] = LogAreaOf(place)
	var/list/wit = list()
	if(islist(witnesses))
		for(var/w in witnesses)
			var/ck = LogCkeyOf(w)
			if(!ck) continue
			wit[ck] = 0
	if(islist(muffled))
		for(var/w in muffled)
			var/ck = LogCkeyOf(w)
			if(!ck) continue
			if(isnull(wit[ck])) wit[ck] = 1
	if(actor && actor.ckey && isnull(wit[actor.ckey])) wit[actor.ckey] = 0
	r["wit"] = wit
	logdb_pending += list(r)
	LogDbQueueFlush()
	return r

proc/LogCkeyOf(w)
	if(ismob(w))
		var/mob/M = w
		return M.ckey
	if(istype(w, /client))
		var/client/C = w
		return C.ckey
	if(istext(w)) return ckey(w)
	return null

proc/LogWitnessesOnline()
	var/list/out = list()
	for(var/mob/Players/P in players)
		if(P.client) out += P
	return out

proc/LogAdminAction(mob/actor, category, action, target, detail)
	var/list/r = list()
	r["table"] = "admin"
	r["actor"] = actor ? (actor.ckey ? actor.ckey : "") : ""
	r["name"] = actor ? "[actor.name]" : "server"
	r["level"] = actor ? (actor.Admin ? actor.Admin : 0) : 0
	r["category"] = category ? category : "other"
	r["action"] = isnull(action) ? "" : "[action]"
	r["target"] = isnull(target) ? "" : "[target]"
	r["detail"] = isnull(detail) ? "" : "[detail]"
	logdb_pending += list(r)
	LogDbQueueFlush()
	return r

proc/LogLoginEvent(client/C, ev, reason)
	if(!C) return
	var/list/r = list()
	r["table"] = "logins"
	r["ckey"] = C.ckey ? C.ckey : ""
	r["name"] = C.mob ? "[C.mob.name]" : ""
	r["ip"] = "[C.address]"
	r["cid"] = "[C.computer_id]"
	r["ev"] = ev
	r["reason"] = isnull(reason) ? "" : "[reason]"
	logdb_pending += list(r)
	LogDbQueueFlush()
	return r

proc/LogAdminCategory(txt)
	var/t = lowertext(txt)
	if(findtext(t, "ban") || findtext(t, "mute") || findtext(t, "boot") || findtext(t, "kick") || findtext(t, "deleted") || findtext(t, "punish") || findtext(t, "curse")) return "bans"
	if(findtext(t, "edited") || findtext(t, " set ") || findtext(t, "toggled") || findtext(t, "adjusted") || findtext(t, "ajusted") || findtext(t, "changed") || findtext(t, "enabled") || findtext(t, "disabled") || findtext(t, "gave") || findtext(t, "reward")) return "edits"
	if(findtext(t, "teleport") || findtext(t, "summon") || findtext(t, "sent ") || findtext(t, "moved")) return "teleport"
	if(findtext(t, "admin help") || findtext(t, "admin pm") || findtext(t, "ahelp")) return "ahelp"
	if(findtext(t, "placed") || findtext(t, "spawn") || findtext(t, "weather") || findtext(t, "time of day") || findtext(t, "moon") || findtext(t, "lighting") || findtext(t, "light") || findtext(t, "era") || findtext(t, "reboot") || findtext(t, "announce") || findtext(t, "message") || findtext(t, "world")) return "world"
	return "other"

proc/LogAdminProse(mob/actor, Info, category)
	var/action = "[Info]"
	var/key = actor ? actor.key : null
	if(key)
		var/prefix = "[key]([actor.name])"
		if(findtext(action, prefix, 1, length(prefix) + 1))
			action = copytext(action, length(prefix) + 1)
			while(length(action) && copytext(action, 1, 2) == " ") action = copytext(action, 2)
	return LogAdminAction(actor, category ? category : LogAdminCategory(Info), action, "", "")

proc/LogKeyFromPath(path)
	var/p = "[path]"
	var/i = findtext(p, "Saves/PlayerLogs/")
	if(!i) return null
	var/rest = copytext(p, i + length("Saves/PlayerLogs/"))
	var/slash = findtext(rest, "/")
	if(!slash) return null
	return ckey(copytext(rest, 1, slash))

proc/LogLegacy(path, Info)
	var/ck = LogKeyFromPath(path)
	if(!ck) return
	var/sanitized = findtext("[path]", "/sanitized/") ? 1 : 0
	if(sanitized)
		var/list/last = logdb_legacy_last[ck]
		if(last && last["pending"])
			last["sbody"] = "[Info]"
			return
	var/list/r = LogEvent("legacy", null, Info, list(ck), null, null, null)
	r["pending"] = 1
	if(!sanitized) logdb_legacy_last[ck] = r
	else r["sbody"] = "[Info]"

proc/LogDbQueueFlush()
	if(logdb_flush_queued) return
	logdb_flush_queued = 1
	spawn(5) LogDbFlush()

proc/LogDbFlush()
	logdb_flush_queued = 0
	if(!logdb_pending.len) return
	if(!LogDbOpen()) return
	var/list/batch = logdb_pending
	logdb_pending = list()
	logdb_legacy_last = list()
	var/database/query/q = new
	LogDbExec(q, "BEGIN")
	for(var/list/r in batch)
		r["pending"] = 0
		switch(r["table"])
			if("events")
				if(!LogDbExec(q, "INSERT INTO events (t, ty, actor, name, color, font, pt, z, x, y, area, body, sbody, meta) VALUES (datetime('now'),?,?,?,?,?,?,?,?,?,?,?,?,?)", r["ty"], r["actor"], r["name"], r["color"], r["font"], r["pt"], r["z"], r["x"], r["y"], r["area"], r["body"], r["sbody"], r["meta"]))
					continue
				var/id = 0
				if(LogDbExec(q, "SELECT last_insert_rowid() AS id") && q.NextRow())
					var/list/row = q.GetRowData()
					id = row["id"]
				r["id"] = id
				var/list/wit = r["wit"]
				if(id && islist(wit))
					for(var/ck in wit)
						LogDbExec(q, "INSERT INTO witness (event_id, ckey, muffled) VALUES (?,?,?)", id, ck, wit[ck] ? 1 : 0)
			if("admin")
				LogDbExec(q, "INSERT INTO admin_actions (t, actor, name, level, category, action, target, detail) VALUES (datetime('now'),?,?,?,?,?,?,?)", r["actor"], r["name"], r["level"], r["category"], r["action"], r["target"], r["detail"])
			if("logins")
				LogDbExec(q, "INSERT INTO logins (t, ckey, name, ip, cid, ev, reason) VALUES (datetime('now'),?,?,?,?,?,?)", r["ckey"], r["name"], r["ip"], r["cid"], r["ev"], r["reason"])
	LogDbExec(q, "COMMIT")
	LogDbAfterFlush(batch)

proc/LogDbAfterFlush(list/batch)
	if(logdb_alert_words.len)
		for(var/list/r in batch)
			if(r["table"] != "events") continue
			if(!(r["ty"] in LOGDB_CHAT_TYPES)) continue
			var/low = lowertext(r["body"])
			for(var/w in logdb_alert_words)
				if(findtext(low, lowertext(w)))
					AdminMessage("ALERT \"[w]\": [r["name"]] ([r["actor"]]) [r["ty"]]: [copytext(r["body"], 1, 200)]")
					break
	if(logdb_followers.len)
		for(var/client/C in logdb_followers.Copy())
			if(!C || !C.logpage_open || !C.logpage_follow)
				logdb_followers -= C
				continue
			C.LogPageLivePush(batch)

proc/LogDbStripTags(t)
	var/regex/tags = new("<\[^>\]*>", "g")
	var/out = tags.Replace("[t]", "")
	out = replacetext(out, "&nbsp;", " ")
	return html_decode(out)

proc/LogDbLocalDayRange(day, tz)
	var/list/p = splittext("[day]", "-")
	if(p.len != 3) return null
	var/y = text2num(p[1]); var/m = text2num(p[2]); var/d = text2num(p[3])
	if(isnull(y) || isnull(m) || isnull(d)) return null
	if(!LogDbOpen()) return null
	var/delta = -(isnull(tz) ? 0 : tz)
	var/mod = "[delta >= 0 ? "+" : ""][delta] minutes"
	var/database/query/q = new
	var/from = null
	var/upto = null
	if(LogDbExec(q, "SELECT datetime(?, ?) AS f, datetime(?, ?, '+1 day') AS t", "[day] 00:00:00", mod, "[day] 00:00:00", mod) && q.NextRow())
		var/list/row = q.GetRowData()
		from = row["f"]
		upto = row["t"]
	if(!from || !upto) return null
	return list(from, upto)

proc/LogDbAlertAdd(word, mob/by)
	if(!LogDbOpen()) return 0
	var/w = lowertext(ckey(word))
	if(!length(w)) return 0
	var/database/query/q = new
	LogDbExec(q, "INSERT OR REPLACE INTO alerts (word, added_by, t) VALUES (?,?,datetime('now'))", w, by ? by.ckey : "")
	LogDbLoadAlerts()
	return 1

proc/LogDbAlertRemove(word)
	if(!LogDbOpen()) return 0
	var/database/query/q = new
	LogDbExec(q, "DELETE FROM alerts WHERE word=?", lowertext(ckey(word)))
	LogDbLoadAlerts()
	return 1
