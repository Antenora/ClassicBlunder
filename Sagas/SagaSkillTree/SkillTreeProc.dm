mob/verb/Open_Saga_Skill_Tree()
	set name = "Saga Skill Tree"
	set category = "Character Custom"

	if(src.client)
		src.client.OpenSagaSkillTree()


client/proc/OpenSagaSkillTree(tree_id = null)
	if(!mob) return

	RegisterSagaSkillTrees()

	// without an explicit ID, find the tree for this character's saga
	if(!tree_id)
		for(var/id in SagaSkillTrees)
			var/datum/saga_skill_tree/candidate = SagaSkillTrees[id]
			if(candidate.required_saga && candidate.required_saga == mob.Saga)
				tree_id = id
				break

	var/datum/saga_skill_tree/T
	if(tree_id)
		T = SagaSkillTrees[tree_id]

	if(!T)
		src << "No Saga Skill Tree is available for your Saga."
		return

	if(!T.CanAccess(mob))
		src << "This skill tree requires [T.required_saga]."
		return

	if(sagaSkillTreePanel)
		del sagaSkillTreePanel
	sagaSkillTreePanel = new(src, tree_id)

	var/panel_ref = "\ref[sagaSkillTreePanel]"

	var/background_css = "none"

	if(T.background_icon)
		var/icon/background = icon(T.background_icon, T.background_state, SOUTH, 1)
		var/background_name = "saga_tree_[ckey(T.id)]_background.png"

		src << browse_rsc(background, background_name)
		background_css = "url('[background_name]')"

	var/font_css = ""
	var/font_family = "monospace"

	if(T.font_file)
		var/extension = lowertext(copytext("[T.font_file]", -4))
		if(extension != ".ttf" && extension != ".otf")
			extension = ".ttf"

		var/font_name = "saga_tree_[ckey(T.id)]_font[extension]"
		src << browse_rsc(T.font_file, font_name)

		font_css = "@font-face { font-family: 'SagaTreeFont'; src: url('[font_name]'); font-weight: normal; font-style: normal; }"
		font_family = "'SagaTreeFont', monospace"

	var/html = {"
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Saga Skill Tree</title>
<style>

	[font_css]

	:root {
		--tree-font: [font_family];
		--text: [T.text_color];
		--muted: [T.muted_color];
		--accent: [T.accent_color];
		--panel: [T.panel_color];
		--panel-border: [T.panel_border_color];
		--node: [T.node_color];
		--node-border: [T.node_border_color];
		--node-available-border: [T.node_available_border_color];
		--node-learned: [T.node_learned_color];
		--line: [T.line_color];
		--line-learned: [T.line_learned_color];
		--button: [T.button_color];
		--button-border: [T.button_border_color];
		--refund-button: [T.refund_button_color];
	}

	html, body {
		margin: 0;
		width: 100%;
		height: 100%;
		overflow: hidden;
		background: #000;
		color: #fff;
		font-family: monospace;
	}

	* { box-sizing: border-box; }

	#viewport {
		position: absolute;
		top: 0;
		right: 0;
		bottom: 0;
		left: 0;
		overflow: auto;
		background: #000 url('saga_skill_tree_background.png') repeat-y center top;
		background-size: 1344px auto;
		image-rendering: pixelated;
	}

	#tree {
		position: relative;
		width: 1344px;
		height: 900px;
		margin: 0 auto;
	}

	#connections {
		position: absolute;
		top: 0;
		left: 0;
		pointer-events: none;
	}

	#connections line {
		stroke: #77809e;
		stroke-width: 1;
	}

	#connections line.learned {
		stroke: #9eb4ff;
	}

	.node {
		position: absolute;
		width: 34px;
		height: 34px;
		padding: 0;
		border: 1px solid #788099;
		border-radius: 0;
		background: #131321;
		color: #aab2cc;
		font: bold 12px monospace;
		transform: translate(-50%, -50%);
		cursor: pointer;
	}

	.node-icon {
		display: block;
		width: 100%;
		height: 100%;
		object-fit: contain;
		image-rendering: pixelated;
		pointer-events: none;
	}

	.node .node-icon {
		opacity: 0.35;
	}

	.node.learned .node-icon {
		opacity: 1;
	}

	.node.available {
		border-color: #e1e6ff;
		color: #fff;
	}

	.node.learned {
		background: #3c51af;
		border-color: #e1e6ff;
		color: #fff;
	}

	.node:hover {
		outline: 1px solid #fff;
	}

	.node.selected {
		outline: 2px solid #91caff;
		outline-offset: 3px;
	}

	#heading, #details {
		position: fixed;
		z-index: 10;
		background: #111322;
		border: 1px solid #6674a7;
		padding: 14px;
	}

	#heading {
		top: 14px;
		left: 16px;
	}

	#tree-title {
		margin-top: 8px;
		color: #fff;
		font-size: 16px;
	}

	#points {
		margin-top: 8px;
		color: #a9b5db;
	}

	#message {
		margin-top: 8px;
		max-width: 360px;
		color: #91caff;
	}

	#details {
		display: none;
		right: 16px;
		bottom: 16px;
		width: 280px;
		max-width: calc(100% - 32px);
		max-height: calc(100% - 32px);
		overflow: auto;
	}

	h2 {
		margin: 0 24px 12px 0;
		font-size: 18px;
	}

	#description, #requirements {
		margin: 12px 0;
		color: #ccd4ed;
		line-height: 1.6;
		white-space: pre-line;
	}

	#learn, #refresh, #refund {
		border: 1px solid #9aacec;
		background: #344993;
		color: #fff;
		font: bold 13px monospace;
		padding: 8px;
		cursor: pointer;
	}

	#learn { width: 100%; }

	#refresh { margin-top: 10px; }

	#learn:disabled, #refund:disabled {
		opacity: 0.5;
		cursor: default;
	}

	#close-details {
		position: absolute;
		top: 8px;
		right: 8px;
		border: 0;
		background: transparent;
		color: #fff;
		cursor: pointer;
	}

	#refund {
		width: 100%;
		margin-top: 8px;
		background: #49334c;
	}

	#rank {
		margin: 8px 0;
		color: #91caff;
	}

	.node-rank {
		position: absolute;
		top: 38px;
		left: 50%;
		transform: translateX(-50%);
		white-space: nowrap;
		font: 11px monospace;
		color: #fff;
		pointer-events: none;
	}

	html, body {
		background: [T.background_color];
		color: var(--text);
		font-family: var(--tree-font);
		font-size: [T.font_size]px;
	}

	#viewport {
		background-color: [T.background_color];
		background-image: [background_css];
		background-repeat: repeat-y;
		background-position: center top;
		background-size: [T.background_width]px auto;
	}

	#heading, #details {
		background: var(--panel);
		border-color: var(--panel-border);
	}

	#tree-title, #title {
		color: var(--text);
		font-size: [T.title_font_size]px;
		font-weight: normal;
	}

	#points, #description, #requirements {
		color: var(--muted);
	}

	#message, #rank {
		color: var(--accent);
	}

	#connections line {
		stroke: var(--line);
	}

	#connections line.learned {
		stroke: var(--line-learned);
	}

	.node {
		background: var(--node);
		border-color: var(--node-border);
		color: var(--muted);
		font-family: var(--tree-font);
		font-size: [T.node_font_size]px;
		font-weight: normal;
	}

	.node.available {
		border-color: var(--node-available-border);
		color: var(--text);
	}

	.node.learned {
		background: var(--node-learned);
		border-color: var(--node-available-border);
		color: var(--text);
	}

	.node:hover {
		outline-color: var(--text);
	}

	.node.selected {
		outline-color: var(--accent);
	}

	.node-rank {
		color: var(--text);
		font-family: var(--tree-font);
		font-size: [T.node_font_size]px;
	}

	#learn, #refresh, #refund {
		background: var(--button);
		border-color: var(--button-border);
		color: var(--text);
		font-family: var(--tree-font);
		font-size: [T.font_size]px;
		font-weight: normal;
	}

	#refund {
		background: var(--refund-button);
	}

	#close-details {
		color: var(--text);
		font-family: var(--tree-font);
	}

</style>
</head>
<body>
	<div id="viewport">
		<div id="tree">
			<svg id="connections"></svg>
			<div id="nodes"></div>
		</div>
	</div>

	<div id="heading">
		SAGA SKILL TREE
		<div id="tree-title"></div>
		<div id="points">Loading...</div>
		<div id="message"></div>
		<button id="refresh" type="button">Refresh</button>
	</div>

	<div id="details">
		<button id="close-details" type="button">X</button>
		<h2 id="title"></h2>
		<div id="description"></div>
		<div id="rank"></div>
		<div id="cost"></div>
		<div id="requirements"></div>
		<button id="learn" type="button">Learn</button>
		<button id="refund" type="button">Refund one rank</button>
	</div>

<script>
	var panelRef = '[panel_ref]';
	var nodes = Object.create(null);
	var selected = null;
	var pending = false;
	var firstLoad = true;

	var viewport = document.getElementById('viewport');
	var tree = document.getElementById('tree');
	var svg = document.getElementById('connections');
	var nodeLayer = document.getElementById('nodes');

	function send(action, id) {
		var url = 'byond://?src=' + encodeURIComponent(panelRef)
			+ '&action=' + encodeURIComponent(action);

		if(id) url += '&id=' + encodeURIComponent(id);
		window.location.href = url;
	}

	function showDetails() {
		var details = document.getElementById('details');
		var node = selected ? nodes\[selected] : null;

		if(!node) {
			details.style.display = 'none';
			return;
		}

		details.style.display = 'block';
		document.getElementById('title').textContent = node.title;
		document.getElementById('description').textContent = node.description || '';
		document.getElementById('rank').textContent = 'Rank: ' + node.rank + '/' + node.maxRank;

		document.getElementById('cost').textContent = node.maxed
			? 'Maximum rank reached.'
			: 'Next rank: ' + node.cost + ' RPP';

		var text = 'All requirements met.';

		if(node.maxed) {
			text = 'Fully learned.';
		} else if(node.missing.length) {
			text = node.missing.join(String.fromCharCode(10));
		} else if(!node.canBuy) {
			text = 'Not enough spendable RPP.';
		}

		if(node.rank > 0 && node.refundBlock)
			text += String.fromCharCode(10) + 'Refund: ' + node.refundBlock;

		document.getElementById('requirements').textContent = text;

		var learn = document.getElementById('learn');
		learn.disabled = pending || !node.canBuy;
		learn.textContent = pending
			? 'Please wait...'
			: node.maxed ? 'Maximum rank' : node.rank > 0 ? 'Upgrade' : 'Learn';

		var refund = document.getElementById('refund');
		refund.disabled = pending || !node.canRefund;
		refund.textContent = 'Refund one rank (' + node.refundAmount + ' RPP)';
	}

	function updateSelection() {
		Object.keys(nodes).forEach(function(id) {
			var node = nodes\[id];

			node.button.className = 'node'
				+ (node.canBuy ? ' available' : '')
				+ (node.learned ? ' learned' : '')
				+ (selected === id ? ' selected' : '');
		});

		showDetails();
	}

	window.receiveSagaSkillTree = function(payload) {
		var state;

		try {
			state = JSON.parse(payload);
		} catch(error) {
			pending = false;
			document.getElementById('message').textContent = 'Could not read tree data. Press Refresh.';
			showDetails();
			return;
		}

		pending = false;
		nodes = Object.create(null);

		document.getElementById('tree-title').textContent = state.title;
		document.getElementById('points').textContent = 'Spendable RPP: ' + state.points;
		document.getElementById('message').textContent = state.message || '';

		while(svg.firstChild) svg.removeChild(svg.firstChild);
		while(nodeLayer.firstChild) nodeLayer.removeChild(nodeLayer.firstChild);

		var width = 1344;
		var height = 900;
		var minX = 0;
		var minY = 0;
		var padding = 80;

		// Find the space needed above and to the left of the origin.
		state.nodes.forEach(function(node) {
			minX = Math.min(minX, node.x - padding);
			minY = Math.min(minY, node.y - padding);
		});

		var offsetX = -minX;
		var offsetY = -minY;

		// Shift the entire tree into reachable scroll coordinates.
		state.nodes.forEach(function(node) {
			node.x += offsetX;
			node.y += offsetY;

			nodes\[node.id] = node;
			width = Math.max(width, node.x + padding);
			height = Math.max(height, node.y + padding);
		});

		tree.style.width = width + 'px';
		tree.style.height = height + 'px';

		svg.setAttribute('width', width);
		svg.setAttribute('height', height);
		svg.setAttribute('viewBox', '0 0 ' + width + ' ' + height);

		state.nodes.forEach(function(node) {
			node.requires.forEach(function(parentId) {
				var parent = nodes\[parentId];
				if(!parent) return;

				var line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
				line.setAttribute('x1', parent.x);
				line.setAttribute('y1', parent.y);
				line.setAttribute('x2', node.x);
				line.setAttribute('y2', node.y);

				if(parent.learned && node.learned)
					line.setAttribute('class', 'learned');

				svg.appendChild(line);
			});

			var button = document.createElement('button');
			button.type = 'button';
			button.style.left = node.x + 'px';
			button.style.top = node.y + 'px';
			if(node.icon) {
				var artwork = document.createElement('img');
				artwork.className = 'node-icon';
				artwork.src = node.icon;
				artwork.alt = '';
				artwork.draggable = false;
				button.appendChild(artwork);
			} else {
				button.textContent = node.title.substring(0, 2);
			}
			if(node.maxRank > 1) {
				var rankLabel = document.createElement('span');
				rankLabel.className = 'node-rank';
				rankLabel.textContent = node.rank + '/' + node.maxRank;
				button.appendChild(rankLabel);
			}
			button.title = node.title;

			button.onclick = function() {
				selected = node.id;
				updateSelection();
			};

			node.button = button;
			nodeLayer.appendChild(button);
		});

		updateSelection();

		if(firstLoad) {
			firstLoad = false;
			viewport.scrollLeft = Math.max(
				0,
				Math.round((width - viewport.clientWidth) / 2)
			);
			viewport.scrollTop = Math.max(0, height - viewport.clientHeight);
		}
	};

	document.getElementById('learn').onclick = function() {
		var node = selected ? nodes\[selected] : null;
		if(!node || !node.canBuy || pending) return;

		pending = true;
		showDetails();
		send('buy', selected);
	};

	document.getElementById('refund').onclick = function() {
		var node = selected ? nodes\[selected] : null;
		if(!node || !node.canRefund || pending) return;

		pending = true;
		showDetails();
		send('refund', selected);
	};

	document.getElementById('refresh').onclick = function() {
		send('refresh');
	};

	document.getElementById('close-details').onclick = function() {
		selected = null;
		updateSelection();
	};

	window.addEventListener('load', function() {
		send('ready');
	});
</script>
</body>
</html>
"}

	src << browse(html, "window=sagaskilltree;size=1344x900;can_resize=1")
	winset(src, "sagaskilltree", "is-visible=true;is-minimized=false")