mob/verb/EmoteNew()
	set category = "Roleplay"
	if(usr.rping) return

	usr.rping = TRUE
	usr.checkInvisibilityBreaking()
	usr.CheckAFK()
	var/image/em=new('Emoting.dmi')

	em.appearance_flags=66
	em.layer=EFFECTS_LAYER
	em.pixel_x=0
	em.pixel_y=0
	usr.emoteBubble = em
	usr.overlays += usr.emoteBubble

	src.OpenEmoteEditor()
	usr.RPLoopNew()

mob/verb/EmoteEditorClosed()
	set hidden = 1

	src.rping = 0
	winshow(src, "EmoteEditor", FALSE)

	usr.overlays -= usr.emoteBubble
	var/msg = src.current_emote_text

	savedRoleplay = null
	if(length(msg) >= 45)
		if(fexists("Saved Roleplays/[usr.key].txt"))
			fdel("Saved Roleplays/[usr.key].txt")
			text2file(msg, "Saved Roleplays/[usr.key].txt")
		else
			text2file(msg, "Saved Roleplays/[usr.key].txt")

mob/proc/RPLoopNew()
	while(rping)
		sleep(150)
		savedRoleplay = "[src.current_emote_text]"

mob/proc/OpenEmoteEditor()
	var/saved_text = ""
	var/saved_text_html

	if(fexists("Saved Roleplays/[src.key].txt"))
		saved_text = file2text("Saved Roleplays/[src.key].txt")

		saved_text = replacetext(saved_text, "\\'", "'")
		saved_text = replacetext(saved_text, "\\\"", "\"")

		saved_text_html = html_encode(saved_text)

	spawn(5)
		fdel("Saved Roleplays/[usr.key].txt")

	winshow(src, "EmoteEditor", TRUE)

	var/mob_ref = "\ref[src]"

	var/html = {"
	<html>
	<head>
		<style>
			body {
				margin: 0;
				padding: 6px;
				background: #111;
				color: #ddd;
				font-family: Arial;
				overflow: hidden;
			}

			#toolbar {
				margin-bottom: 6px;
				display: flex;
				gap: 4px;
				flex-wrap: wrap;
			}

			button {
				background: #333;
				color: #eee;
				border: 1px solid #777;
				padding: 4px 8px;
				cursor: pointer;
				font-size: 13px;
			}

			button:hover {
				background: #444;
			}

			#emote_text {
				width: 100%;
				height: calc(100vh - 80px);
				box-sizing: border-box;
				background: #1b1b1b;
				color: #eee;
				border: 1px solid #555;
				padding: 8px;
				resize: none;
				font-family: Arial;
				font-size: 14px;
			}
		</style>

		<script>
			function wrapSelection(before, after) {
				var box = document.getElementById('emote_text');

				var start = box.selectionStart;
				var end = box.selectionEnd;
				var selected = box.value.substring(start, end);

				box.value =
					box.value.substring(0, start) +
					before + selected + after +
					box.value.substring(end);

				box.focus();

				box.selectionStart = start + before.length;
				box.selectionEnd = end + before.length;
			}

			function insertAtCursor(text) {
				var box = document.getElementById('emote_text');

				var start = box.selectionStart;
				var end = box.selectionEnd;

				box.value =
					box.value.substring(0, start) +
					text +
					box.value.substring(end);

				box.focus();
				box.selectionStart = start + text.length;
				box.selectionEnd = start + text.length;
			}

			function addColor() {
				var color = document.getElementById('color_picker').value;
				wrapSelection('<font color=' + color + '>', '</font color>');
			}

			function clearText() {
				document.getElementById('emote_text').value = '';
			}

			function sendEmote() {
				var text = document.getElementById('emote_text').value;
				window.location = 'byond://?src=[mob_ref];action=send_emote;text=' + encodeURIComponent(text);
			}

			function previewEmote() {
				var text = document.getElementById('emote_text').value;
				window.location = 'byond://?src=[mob_ref];action=preview_emote;text=' + encodeURIComponent(text);

			}
			var syncTimer = null;

			function queueSyncDraft() {
				if(syncTimer) {
					clearTimeout(syncTimer);
				}

				syncTimer = setTimeout(function() {
					syncDraft();
				}, 500);
			}

			function syncDraft() {
				var text = document.getElementById('emote_text').value;
				window.location = 'byond://?src=[mob_ref];action=sync_emote_text;text=' + encodeURIComponent(text);
			}
			function setupTextarea() {
				var box = document.getElementById('emote_text');

				box.addEventListener('keydown', function(e) {
					if(e.key === 'Tab') {
						e.preventDefault();

						var start = box.selectionStart;
						var end = box.selectionEnd;

						var tabText = '    '; // use 4 spaces instead, if preferred

						box.value =
							box.value.substring(0, start) +
							tabText +
							box.value.substring(end);

						box.selectionStart = start + tabText.length;
						box.selectionEnd = start + tabText.length;

						syncDraft();
					}
				});
			}
		</script>
	</head>

	<body onload='setupTextarea()'>
		<div id='toolbar'>
			<button onclick=\"wrapSelection('<b>', '</b>')\"><b>B</b></button>
			<button onclick=\"wrapSelection('<i>', '</i>')\"><i>I</i></button>
			<button onclick=\"wrapSelection('<u>', '</u>')\"><u>U</u></button>
			<button onclick=\"wrapSelection('<s>', '</s>')\"><s>S</s></button>

			<input id='color_picker' type='color' value='#ff5555'>
			<button onclick='addColor()'>Color</button>

			<button onclick=\"wrapSelection('<font size=3>', '</font size>')\">Size</button>
			<button onclick=\"wrapSelection('<center>', '</center>')\">Center</button>

			<button onclick='clearText()'>Clear</button>
			<button onclick='sendEmote()'>Send</button>
			<button onclick='previewEmote()'>Preview</button>
		</div>

		<textarea id='emote_text' oninput='queueSyncDraft()'>[saved_text_html]</textarea>
	</body>
	</html>
	"}

	src << browse(html, "window=EmoteEditor.EditorBrowser")

mob/Topic(href, href_list[])
	..()
	if(href_list["action"] == "send_emote")
		var/text = href_list["text"]

		if(!text || !length(text))
			return

		src.SubmitRoleplay(text)
		rping=0
		winshow(src, "EmoteEditor", FALSE)
	if(href_list["action"] == "sync_emote_text")
		src.current_emote_text = href_list["text"]
		return

	if(href_list["action"] == "preview_emote")
		var/text = href_list["text"]

		if(!text || !length(text))
			return

		src.previewRoleplay(text)