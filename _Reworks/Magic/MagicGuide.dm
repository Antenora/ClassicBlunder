// In-game reference guide for the magic system

mob/verb/Magic_Guide()
	set category = "Guide"
	set name = "Magic Guide"
	src.MagicGuide("main")

mob/proc/MagicGuide(var/page)
	if(!page) page = "main"

	var/css = {"<style>
body{background:#0a0a15;color:#c8c8c8;font-family:Calibri,sans-serif;font-size:10pt;padding:8px 12px;margin:0}
h1{color:#fff;text-align:center;font-size:15pt;margin:4px 0 8px 0}
h2{color:#ddd;font-size:11pt;border-bottom:1px solid #333;padding-bottom:3px;margin:12px 0 6px 0}
a{color:#4fc3f7;text-decoration:none}
a:hover{text-decoration:underline}
table{border-collapse:collapse;width:100%;margin:4px 0 8px 0}
th{background:#1a1a2e;color:#fff;padding:4px 6px;text-align:left;font-size:9pt}
td{padding:3px 6px;border-bottom:1px solid #1a1a2e;font-size:9pt}
.nv{background:#111122;padding:5px;text-align:center;margin-bottom:8px}
.nv a{margin:0 3px;font-size:9pt}
.bx{background:#111122;padding:6px;margin:4px 0;border-left:3px solid #444}
.tp{background:#1a1a0a;padding:6px;margin:4px 0;border-left:3px solid #ffd54f;font-size:9pt}
</style>"}

	var/nav = {"<div class='nv'>
<a href='?src=\ref[src];action=magic;page=main'>Home</a> |
<a href='?src=\ref[src];action=magic;page=start'>Getting Started</a> |
<a href='?src=\ref[src];action=magic;page=enchant'>Enchanting</a> |
<a href='?src=\ref[src];action=magic;page=gestalt'>Gestalt</a><br>
<a href='?src=\ref[src];action=magic;page=fire' style='color:#ff6b35'>Fire</a> &middot;
<a href='?src=\ref[src];action=magic;page=water' style='color:#42a5f5'>Water</a> &middot;
<a href='?src=\ref[src];action=magic;page=air' style='color:#ffd54f'>Air</a> &middot;
<a href='?src=\ref[src];action=magic;page=earth' style='color:#66bb6a'>Earth</a> &middot;
<a href='?src=\ref[src];action=magic;page=light' style='color:#fff59d'>Light</a> &middot;
<a href='?src=\ref[src];action=magic;page=dark' style='color:#ce93d8'>Dark</a> &middot;
<a href='?src=\ref[src];action=magic;page=time' style='color:#4dd0e1'>Time</a> &middot;
<a href='?src=\ref[src];action=magic;page=space' style='color:#f48fb1'>Space</a>
</div>"}

	var/content = ""
	switch(page)

		// ===== MAIN PAGE =====
		if("main")
			content = {"
<h1>The Arcane Arts</h1>
<p style='text-align:center;font-style:italic'>A guide to the magic system and its eight elemental paths.</p>

<h2>Overview</h2>
<p>The magic system lets you unlock and master the elements through a node-based progression tree. Invest RPP into nodes to gain combat spells, permanent passive bonuses, spell enchantments, and powerful Gestalt transformations.</p>

<h2>The Eight Elements</h2>
<table>
<tr><th>Tier</th><th>Elements</th><th>Unlock Requirement</th></tr>
<tr><td>Basic</td><td><span style='color:#ff6b35'>Fire</span>, <span style='color:#42a5f5'>Water</span></td><td>None</td></tr>
<tr><td>Secondary</td><td><span style='color:#ffd54f'>Air</span>, <span style='color:#66bb6a'>Earth</span></td><td>None</td></tr>
<tr><td>Advanced</td><td><span style='color:#fff59d'>Light</span>, <span style='color:#ce93d8'>Dark</span>, <span style='color:#4dd0e1'>Time</span>, <span style='color:#f48fb1'>Space</span></td><td>Potential 40+, T3 Mage Status</td></tr>
</table>

<h2>What You Gain</h2>
<div class='bx'>
<b>Spells</b> &mdash; Combat skills earned from spell nodes: AOE, Autohit, Projectile, Line, Buff, and Debuff types.<br><br>
<b>Mage Passives</b> &mdash; Permanent stat bonuses. Acquiring them also unlocks <a href='?src=\ref[src];action=magic;page=gestalt'>Gestalt</a> styles and buffs.<br><br>
<b>Spell Passives</b> &mdash; Enchantments you apply to spells via the <a href='?src=\ref[src];action=magic;page=enchant'>Enchanting</a> system.<br><br>
<b>Gestalt</b> &mdash; Powerful combat styles and togglable buffs that scale with elemental mastery.
</div>

<div class='tp'>Click any element above to view its spells, passives, and Gestalt rewards. New to magic? Start with <a href='?src=\ref[src];action=magic;page=start'>Getting Started</a>.</div>
"}

		// ===== GETTING STARTED =====
		if("start")
			content = {"
<h1>Getting Started</h1>

<h2>Step 1: Unlock Your First Element</h2>
<p>Spend <b>20 RPP</b> to access any element tree. The entry node unlocks automatically. Basic and Secondary elements have no prerequisites for your first tree.</p>

<h2>Step 2: Progress Through the Tree</h2>
<p>Each node costs <b>20 RPP</b>. Unlocking a node reveals adjacent nodes. Each tree has approximately 12 nodes.</p>
<table>
<tr><th>Node Type</th><th>What It Gives</th></tr>
<tr><td>Spell</td><td>A combat spell (AOE, Autohit, Projectile, Line, Buff, or Debuff)</td></tr>
<tr><td>Mage Passive</td><td>Permanent stat bonuses (element resist, mana cost reduction, casting power)</td></tr>
<tr><td>Spell Passive</td><td>An enchantment for your spells. First one also unlocks the Enchant verb.</td></tr>
<tr><td>Pinnacle</td><td>Crown node &mdash; requires all other nodes. Grants the strongest mage passive.</td></tr>
</table>

<h2>Step 3: Expand to More Elements</h2>
<table>
<tr><th>Tree</th><th>Requirements</th></tr>
<tr><td>1st</td><td>None (any Basic or Secondary)</td></tr>
<tr><td>2nd</td><td>Potential >= 20, first tree fully mastered</td></tr>
<tr><td>3rd</td><td>Potential >= 40, T3 Mage Status investment</td></tr>
<tr><td>4th</td><td>Potential >= 40, T4 Mage Status investment</td></tr>
<tr><td>5th (Max)</td><td>All previous requirements met</td></tr>
</table>

<div class='bx'><b>Advanced Elements</b> (Light, Dark, Time, Space) always require <b>Potential >= 40</b> and a <b>T3 Mage Status</b> investment, regardless of tree order.</div>

<h2>Costs</h2>
<p>~12 nodes per tree at 20 RPP each = approximately <b>240 RPP per element</b>. A full 5-element build costs roughly <b>1,200 RPP</b>.</p>

<h2>Passive Stacking</h2>
<p>Multiple nodes in a tree can grant the same mage passive. Each acquisition stacks &mdash; more nodes means deeper bonuses from that passive.</p>

<div class='tp'><b>Tip:</b> Acquiring 3 mage passives in one element unlocks Tier 3 <a href='?src=\ref[src];action=magic;page=gestalt'>Gestalt</a> &mdash; the strongest style and buff for that element.</div>
"}

		// ===== FIRE =====
		if("fire")
			content = {"
<h1 style='color:#ff6b35'>Fire</h1>
<p style='text-align:center;font-style:italic'>The path of destruction and relentless aggression. Fire mages overwhelm enemies with scorching force.</p>

<h2>Spells</h2>
<table>
<tr><th>Spell</th><th>Type</th></tr>
<tr><td>Blazing Whip</td><td>AOE</td></tr>
<tr><td>Dragon Arc</td><td>Line</td></tr>
<tr><td>Fireball</td><td>Projectile</td></tr>
</table>

<h2>Mage Passives</h2>
<table>
<tr><th>Passive</th><th>Effects (per node)</th></tr>
<tr><td><b>Burn Mastery</b></td><td>+1 Burn Resist, Fire Mana Cost -15%</td></tr>
<tr><td><b>Scorched Form</b></td><td>+1 Burn Resist, Fire Cooldown -10%</td></tr>
<tr><td><b>Alight</b> (Crown)</td><td>+3 Mana Gen, +1 Powerful Casting, Fire Damage +10%, Fire Cooldown -10%</td></tr>
</table>

<h2>Spell Passives</h2>
<table>
<tr><th>Passive</th><th>Effects</th></tr>
<tr><td><b>Blaze</b></td><td>+4 Scorching<br>AH: +0.5 Str/For Off, x1.2 Damage<br>Proj: +0.5 Str/For Rate, x1.2 Damage<br>Buff: +2 Pure Damage</td></tr>
<tr><td><b>Magma</b></td><td>+1 Magmic Infusion, +2 Scorching</td></tr>
<tr><td><b>Ashfield</b></td><td>+5 Turf Burn, +2 Scorching<br>AH: +3 Distance | Proj: +10 Distance</td></tr>
<tr><td><b>Nuclear</b></td><td>+1 Darkness Flame, +4 Toxic<br>AH: -0.25 End Defense | Proj: -0.25 End Rate</td></tr>
</table>

<h2>Gestalt (Tier 3)</h2>
<div class='bx'>
<b>Style:</b> Str +90%, For +75%, Off +60%<br>
Passives: Heavy Hitter, Scorching, Momentum, Brutalize, Martial Magic, Pure Damage<br><br>
<b>Buff:</b> For x1.4, Str x1.35, Off x1.3<br>
Passives: Scorching, Momentum, Fire Herald, Brutalize, Critical Damage, Demonic Durability
</div>
"}

		// ===== WATER =====
		if("water")
			content = {"
<h1 style='color:#42a5f5'>Water</h1>
<p style='text-align:center;font-style:italic'>The path of resilience and control. Water mages endure and outlast, turning defense into dominance.</p>

<h2>Spells</h2>
<table>
<tr><th>Spell</th><th>Type</th></tr>
<tr><td>Riptide</td><td>Autohit</td></tr>
<tr><td>Wetten Socks</td><td>Debuff</td></tr>
<tr><td>Frost Shamshir</td><td>Projectile</td></tr>
</table>

<h2>Mage Passives</h2>
<table>
<tr><th>Passive</th><th>Effects (per node)</th></tr>
<tr><td><b>Chill Mastery</b></td><td>+1 Chill Resist, Water Mana Cost -15%</td></tr>
<tr><td><b>Fluid Technique</b></td><td>+1 Chill Resist, Water Cooldown -10%</td></tr>
<tr><td><b>Awash</b> (Crown)</td><td>+3 Mana Gen, +1 Forceful Casting, Water Damage +10%, Water Cooldown -10%</td></tr>
</table>

<h2>Spell Passives</h2>
<table>
<tr><th>Passive</th><th>Effects</th></tr>
<tr><td><b>Barotrauma</b></td><td><i>In development</i></td></tr>
<tr><td><b>Overflow</b></td><td><i>In development</i></td></tr>
<tr><td><b>Flashfreeze</b></td><td><i>In development</i></td></tr>
<tr><td><b>Sublimate</b></td><td><i>In development</i></td></tr>
</table>

<h2>Gestalt (Tier 3)</h2>
<div class='bx'>
<b>Style:</b> For +90%, End +75%, Def +60%<br>
Passives: Fluid Form, Blubber, Like Water, Control Resist, Melee Resist<br><br>
<b>Buff:</b> End x1.4, For x1.35, Def x1.3<br>
Passives: Chilling, Fluid Form, Ice Herald, Control Resist, Blubber, Melee Resist
</div>
"}

		// ===== AIR =====
		if("air")
			content = {"
<h1 style='color:#ffd54f'>Air</h1>
<p style='text-align:center;font-style:italic'>The path of speed and precision. Air mages strike with shocking quickness and leave enemies paralyzed.</p>

<h2>Spells</h2>
<table>
<tr><th>Spell</th><th>Type</th></tr>
<tr><td>Breaking Twister</td><td>Autohit</td></tr>
<tr><td>Evading Zephyr</td><td>Buff</td></tr>
<tr><td>Mentis Imperium</td><td>Line</td></tr>
</table>

<h2>Mage Passives</h2>
<table>
<tr><th>Passive</th><th>Effects (per node)</th></tr>
<tr><td><b>Shock Mastery</b></td><td>+1 Shock Resist, Air Mana Cost -15%</td></tr>
<tr><td><b>Fleet Footed</b></td><td>+1 Shock Resist, Air Cooldown -10%</td></tr>
<tr><td><b>Aloft</b> (Crown)</td><td>+3 Mana Gen, +1 Agile Casting, Air Damage +10%, Air Cooldown -10%</td></tr>
</table>

<h2>Spell Passives</h2>
<table>
<tr><th>Passive</th><th>Effects</th></tr>
<tr><td><b>Paralyzer</b></td><td>+20 Nerve Overload</td></tr>
<tr><td><b>Synapse</b></td><td>+20 Critical Paralyze</td></tr>
<tr><td><b>Pinpoint</b></td><td>+25 Critical Spark</td></tr>
<tr><td><b>Whirlwind</b></td><td>+10 Whirlwind</td></tr>
</table>

<h2>Gestalt (Tier 3)</h2>
<div class='bx'>
<b>Style:</b> Spd +90%, For +75%, Off +60%<br>
Passives: Blurring Strikes, Attack Speed, Fury, Afterimages, Flicker<br><br>
<b>Buff:</b> For x1.4, Spd x1.35, Off x1.3<br>
Passives: Shocking, Afterimages, Thunder Herald, Blurring Strikes, Attack Speed, Godspeed
</div>
"}

		// ===== EARTH =====
		if("earth")
			content = {"
<h1 style='color:#66bb6a'>Earth</h1>
<p style='text-align:center;font-style:italic'>The path of endurance and fortification. Earth mages are immovable walls that grind enemies into dust.</p>

<h2>Spells</h2>
<table>
<tr><th>Spell</th><th>Type</th></tr>
<tr><td>Seismic Entry</td><td>AOE</td></tr>
<tr><td>Ward of Stone</td><td>Buff</td></tr>
<tr><td>Prickly Ballet</td><td>Debuff</td></tr>
</table>

<h2>Mage Passives</h2>
<table>
<tr><th>Passive</th><th>Effects (per node)</th></tr>
<tr><td><b>Shatter Mastery</b></td><td>+1 Shatter Resist, Earth Mana Cost -15%</td></tr>
<tr><td><b>Firm Guard</b></td><td>+1 Shatter Resist, Earth Cooldown -10%</td></tr>
<tr><td><b>Aerde</b> (Crown)</td><td>+3 Mana Gen, +1 Stalwart Casting, Earth Damage +10%, Earth Cooldown -10%</td></tr>
</table>

<h2>Spell Passives</h2>
<table>
<tr><th>Passive</th><th>Effects</th></tr>
<tr><td><b>Toxify</b></td><td>+3 True Toxic</td></tr>
<tr><td><b>Rust</b></td><td>+5 Rust</td></tr>
<tr><td><b>Muddy</b></td><td>+15 Turf Mud</td></tr>
<tr><td><b>Steelize</b></td><td>+2 Reinforcement</td></tr>
</table>

<h2>Gestalt (Tier 3)</h2>
<div class='bx'>
<b>Style:</b> End +90%, For +75%, Def +60%<br>
Passives: Harden, Steady, Grit, Melee Resist, Tenacity, Pure Reduction<br><br>
<b>Buff:</b> For x1.4, End x1.35, Def x1.3<br>
Passives: Shattering, Harden, Earth Herald, Grit, Juggernaut, Critical Block
</div>
"}

		// ===== LIGHT =====
		if("light")
			content = {"
<h1 style='color:#fff59d'>Light</h1>
<p style='text-align:center;font-style:italic'>The path of protection and restoration. Light mages ward their allies and smite the wicked.</p>

<h2>Spells</h2>
<table>
<tr><th>Spell</th><th>Type</th></tr>
<tr><td>Lightspeed</td><td>Line</td></tr>
<tr><td>Bless</td><td>Buff</td></tr>
<tr><td>Solar Burst</td><td>Projectile</td></tr>
</table>

<h2>Mage Passives</h2>
<table>
<tr><th>Passive</th><th>Effects (per node)</th></tr>
<tr><td><b>Warden</b></td><td>+1 Evil Resist, +2 Life Generation</td></tr>
<tr><td><b>Seeker</b></td><td>+1 Spell Range, +1 Stalwart Casting</td></tr>
<tr><td><b>Mender</b> (Crown)</td><td>+5 Mana Gen, Light Damage +15%, Light Mana Cost -15%, Light Cooldown -15%</td></tr>
</table>

<h2>Spell Passives</h2>
<table>
<tr><th>Passive</th><th>Effects</th></tr>
<tr><td><b>Sanctify</b></td><td>+10 Sanctify</td></tr>
<tr><td><b>Enshrine</b></td><td>+5 Enshrine</td></tr>
<tr><td><b>Mirrored</b></td><td>+5 Return to Sender</td></tr>
<tr><td><b>Cleansing</b></td><td>+2 Cleansing</td></tr>
</table>

<h2>Gestalt (Tier 3)</h2>
<div class='bx'>
<b>Style:</b> End +90%, Spd +75%, Def +60%<br>
Passives: Steady, Holy Mod, Buff Mastery, Grit, Fury<br><br>
<b>Buff:</b> Spd x1.4, End x1.35, Def x1.3<br>
Passives: Life Generation, Buff Mastery, Restoration, Debuff Resistance, Angelic Infusion
</div>
"}

		// ===== DARK =====
		if("dark")
			content = {"
<h1 style='color:#ce93d8'>Dark</h1>
<p style='text-align:center;font-style:italic'>The path of hunger and cruelty. Dark mages thrive on pain &mdash; their enemies' and their own.</p>

<h2>Spells</h2>
<table>
<tr><th>Spell</th><th>Type</th></tr>
<tr><td>Shadow Cleave</td><td>Autohit</td></tr>
<tr><td>Arachnae Touch</td><td>Line</td></tr>
<tr><td>Void Blast</td><td>Projectile</td></tr>
</table>

<h2>Mage Passives</h2>
<table>
<tr><th>Passive</th><th>Effects (per node)</th></tr>
<tr><td><b>Shadowbringer</b></td><td>+1 Good Resist</td></tr>
<tr><td><b>Iconoclast</b></td><td>+1 Powerful Casting</td></tr>
<tr><td><b>Survivor</b> (Crown)</td><td>+5 Mana Gen, Dark Damage +20%, Dark Mana Cost -10%, Dark Cooldown -15%</td></tr>
</table>

<h2>Spell Passives</h2>
<table>
<tr><th>Passive</th><th>Effects</th></tr>
<tr><td><b>Disaster</b></td><td>+30 Primordial Invocation</td></tr>
<tr><td><b>Ravenous</b></td><td>+100 Life Steal, +5 Wound Cost</td></tr>
<tr><td><b>Vampyric</b></td><td>+5 Skill Leech</td></tr>
<tr><td><b>Hemomantic</b></td><td>+30 Heal Reverse</td></tr>
<tr><td><b>Anima</b></td><td>+15 Pain Split</td></tr>
</table>

<h2>Gestalt (Tier 3)</h2>
<div class='bx'>
<b>Style:</b> For +90%, Str +75%, Off +60%<br>
Passives: Killer Instinct, Critical Chance, Life Steal, Pressure, Momentum, Sadist<br><br>
<b>Buff:</b> Str x1.4, For x1.35, Off x1.3<br>
Passives: Killer Instinct, Pressure, Critical Chance, Life Steal, Demonic Infusion
</div>
"}

		// ===== TIME =====
		if("time")
			content = {"
<h1 style='color:#4dd0e1'>Time</h1>
<p style='text-align:center;font-style:italic'>The path of mastery over the flow of battle. Time mages control tempo, counter attacks, and erode their foes.</p>

<h2>Spells</h2>
<table>
<tr><th>Spell</th><th>Type</th></tr>
<tr><td>Tempus Cessat</td><td>AOE</td></tr>
<tr><td>Haste</td><td>Buff</td></tr>
<tr><td>Wither</td><td>Debuff</td></tr>
</table>

<h2>Mage Passives</h2>
<table>
<tr><th>Passive</th><th>Effects (per node)</th></tr>
<tr><td><b>Past</b></td><td>Speed boost after casting, damage returned to attackers (special combat effects)</td></tr>
<tr><td><b>Present</b></td><td>+1 Agile Casting</td></tr>
<tr><td><b>Future</b> (Crown)</td><td>+5 Mana Gen, Time Damage +10%, Time Mana Cost -15%, Time Cooldown -20%</td></tr>
</table>

<h2>Spell Passives</h2>
<table>
<tr><th>Passive</th><th>Effects</th></tr>
<tr><td><b>Paradox</b></td><td><i>In development</i></td></tr>
<tr><td><b>Charge Flux</b></td><td>+3 Charge Delay</td></tr>
<tr><td><b>Stasis</b></td><td>+20 Cooldown Drag</td></tr>
<tr><td><b>Passage</b></td><td>+1 Flash DOT</td></tr>
</table>

<h2>Gestalt (Tier 3)</h2>
<div class='bx'>
<b>Style:</b> Spd +90%, For +75%, Def +60%<br>
Passives: Technique Mastery, Counter Master, Fluid Form, Deflection, Godspeed<br><br>
<b>Buff:</b> For x1.4, Spd x1.35, Def x1.3<br>
Passives: Technique Mastery, Debuff Duration Reduction, Blubber, Godspeed, Fluid Form, Entropic
</div>
"}

		// ===== SPACE =====
		if("space")
			content = {"
<h1 style='color:#f48fb1'>Space</h1>
<p style='text-align:center;font-style:italic'>The path of displacement and spatial dominance. Space mages warp the battlefield and control distance.</p>

<h2>Spells</h2>
<table>
<tr><th>Spell</th><th>Type</th></tr>
<tr><td>Flux</td><td>AOE</td></tr>
<tr><td>Flow</td><td>Autohit</td></tr>
<tr><td>Friction</td><td>Debuff</td></tr>
</table>

<h2>Mage Passives</h2>
<table>
<tr><th>Passive</th><th>Effects (per node)</th></tr>
<tr><td><b>Relativity</b></td><td>+1 Shear Resist, +1 Cripple Resist</td></tr>
<tr><td><b>Linearity</b></td><td>+1 Agile Casting</td></tr>
<tr><td><b>Kinematics</b> (Crown)</td><td>+0.5 Mana Cap Mult, +5 Mana Gen, Space Damage +15%, Space Mana Cost -20%, Space Cooldown -10%</td></tr>
</table>

<h2>Spell Passives</h2>
<table>
<tr><th>Passive</th><th>Effects</th></tr>
<tr><td><b>Nebula</b></td><td>+5 Unstable Space</td></tr>
<tr><td><b>Supernova</b></td><td>+10 Force Field (blocks approach from 1 tile)</td></tr>
<tr><td><b>Quasar</b></td><td>+30 Deport (teleport enemy, shred defense)</td></tr>
<tr><td><b>Constellation</b></td><td>+10 Star Crossed (countdown to warp + random buffs)</td></tr>
</table>

<h2>Gestalt (Tier 3)</h2>
<div class='bx'>
<b>Style:</b> For +90%, Spd +75%, Off +60%<br>
Passives: Warping, Super Dash, Flicker, Movement Mastery, Pressure, Unnerve<br><br>
<b>Buff:</b> Spd x1.4, For x1.35, Off x1.3<br>
Passives: Warping, Flicker, Siphon, PU Spike, Steady, Vortex
</div>
"}

		// ===== ENCHANTING =====
		if("enchant")
			content = {"
<h1>Enchanting</h1>
<p style='text-align:center;font-style:italic'>Customize your spells by applying spell passives as enchantments.</p>

<h2>How It Works</h2>
<p>When you unlock your first spell passive node, you receive the <b>Enchant_Spell</b> and <b>Disenchant_Spell</b> verbs under the Utility category.</p>

<h2>Enchanting a Spell</h2>
<div class='bx'>
1. Use <b>Enchant_Spell</b> from your Utility verbs<br>
2. Select a spell from your available spells<br>
3. View what passives are currently on that spell<br>
4. Select an available spell passive to apply<br>
5. The spell gains the passive's bonuses
</div>

<h2>Disenchanting</h2>
<div class='bx'>
1. Use <b>Disenchant_Spell</b><br>
2. Select a spell that has passives equipped<br>
3. Choose a specific passive to remove, or "All"<br>
4. Removed passives become available for use on other spells
</div>

<h2>Rules</h2>
<table>
<tr><th>Rule</th><th>Detail</th></tr>
<tr><td>One spell at a time</td><td>Each spell passive can only be enchanted into one spell at a time</td></tr>
<tr><td>Stacking allowed</td><td>Multiple different passives can be applied to the same spell</td></tr>
<tr><td>Type-specific bonuses</td><td>Some effects only apply to certain spell types (see below)</td></tr>
<tr><td>Cannot enchant while KO'd</td><td>Must be conscious to modify enchantments</td></tr>
</table>

<h2>Reading Spell Passive Effects</h2>
<p>On each element page, spell passive effects are listed by which spell types they apply to:</p>
<table>
<tr><th>Label</th><th>Applies To</th></tr>
<tr><td>(no label)</td><td>All spell types</td></tr>
<tr><td>AH:</td><td>Autohit spells only</td></tr>
<tr><td>Proj:</td><td>Projectile and Line spells only</td></tr>
<tr><td>Buff:</td><td>Buff and Debuff spells only</td></tr>
</table>
"}

		// ===== GESTALT =====
		if("gestalt")
			content = {"
<h1>Gestalt System</h1>
<p style='text-align:center;font-style:italic'>Elemental mastery crystallized into combat power.</p>

<h2>What is Gestalt?</h2>
<p>When you acquire mage passives from an element, you automatically receive two rewards:</p>
<div class='bx'>
<b>Gestalt Style</b> &mdash; A combat style with stat % bonuses and passive effects. Equip it like any other style.<br><br>
<b>Gestalt Buff</b> &mdash; A togglable special buff with stat multipliers and passive effects. Uses the Special Buff slot.
</div>
<p>Both can be active simultaneously (Style slot + Special Buff slot).</p>

<h2>Tier Progression</h2>
<table>
<tr><th>Tier</th><th>Requirement</th><th>Power Level</th></tr>
<tr><td>1</td><td>1 mage passive in the element</td><td>Basic stats and passives</td></tr>
<tr><td>2</td><td>2 mage passives in the element</td><td>Enhanced stats, more passives</td></tr>
<tr><td>3</td><td>3+ mage passives in the element</td><td>Maximum power, full passive suite</td></tr>
</table>
<p>Tiers upgrade automatically as you acquire new mage passives. Active Gestalts refresh instantly with new tier stats.</p>

<h2>Style Comparison (Tier 3)</h2>
<table>
<tr><th>Element</th><th>Primary</th><th>Secondary</th><th>Tertiary</th></tr>
<tr><td style='color:#ff6b35'>Fire</td><td>Str +90%</td><td>For +75%</td><td>Off +60%</td></tr>
<tr><td style='color:#42a5f5'>Water</td><td>For +90%</td><td>End +75%</td><td>Def +60%</td></tr>
<tr><td style='color:#ffd54f'>Air</td><td>Spd +90%</td><td>For +75%</td><td>Off +60%</td></tr>
<tr><td style='color:#66bb6a'>Earth</td><td>End +90%</td><td>For +75%</td><td>Def +60%</td></tr>
<tr><td style='color:#fff59d'>Light</td><td>End +90%</td><td>Spd +75%</td><td>Def +60%</td></tr>
<tr><td style='color:#ce93d8'>Dark</td><td>For +90%</td><td>Str +75%</td><td>Off +60%</td></tr>
<tr><td style='color:#4dd0e1'>Time</td><td>Spd +90%</td><td>For +75%</td><td>Def +60%</td></tr>
<tr><td style='color:#f48fb1'>Space</td><td>For +90%</td><td>Spd +75%</td><td>Off +60%</td></tr>
</table>

<h2>Buff Comparison (Tier 3)</h2>
<table>
<tr><th>Element</th><th>Primary</th><th>Secondary</th><th>Tertiary</th></tr>
<tr><td style='color:#ff6b35'>Fire</td><td>For x1.4</td><td>Str x1.35</td><td>Off x1.3</td></tr>
<tr><td style='color:#42a5f5'>Water</td><td>End x1.4</td><td>For x1.35</td><td>Def x1.3</td></tr>
<tr><td style='color:#ffd54f'>Air</td><td>For x1.4</td><td>Spd x1.35</td><td>Off x1.3</td></tr>
<tr><td style='color:#66bb6a'>Earth</td><td>For x1.4</td><td>End x1.35</td><td>Def x1.3</td></tr>
<tr><td style='color:#fff59d'>Light</td><td>Spd x1.4</td><td>End x1.35</td><td>Def x1.3</td></tr>
<tr><td style='color:#ce93d8'>Dark</td><td>Str x1.4</td><td>For x1.35</td><td>Off x1.3</td></tr>
<tr><td style='color:#4dd0e1'>Time</td><td>For x1.4</td><td>Spd x1.35</td><td>Def x1.3</td></tr>
<tr><td style='color:#f48fb1'>Space</td><td>Spd x1.4</td><td>For x1.35</td><td>Off x1.3</td></tr>
</table>

<div class='tp'>See each element's page for the full list of Gestalt passives at Tier 3.</div>
"}

	src << browse({"<html><head><title>Magic Guide</title>[css]</head><body>[nav][content]</body></html>"}, "window=MagicGuide;size=700x750;can_resize=1")
