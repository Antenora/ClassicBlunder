#define ADMINPAGE_CTL "mapwindow.adminoverlay"

var/list/CHATCMD_GROUP = list("(Un)Mute-Admin-Alerts" = "EVENTS", "ADMINSetallRoofsToDense" = "BUILD", "AI-Spawner" = "WORLD", "AObserve" = "PLAYERS", "AddToTesterWhiteList" = "DEBUG", "Admin-Check-AI-Kills" = "PLAYERS", "Admin-Heal" = "PLAYERS", "Admin-Kill/KO" = "PLAYERS", "Admin-Screen-Size" = "DEBUG", "Admin:-Jump-To" = "PLAYERS", "Admin:-Send-Back" = "PLAYERS", "Admin:-Send-to-Spawn" = "WORLD", "Admin:-Summon" = "PLAYERS", "AdminAssess" = "PLAYERS", "AdminChat" = "WORLD", "AdminInviso" = "PLAYERS", "AdminLogs" = "PLAYERS", "AdminLogz" = "PLAYERS", "AdminPM" = "PLAYERS", "AdminRename" = "PLAYERS", "AdminRevive" = "PLAYERS", "Adminize" = "PLAYERS", "Ambient-FX-Toggle" = "ENV", "Announce" = "EVENTS", "Assign-Job" = "PLAYERS", "Assign-Majin-Room" = "WORLD", "Assign-Stat-Redo" = "PLAYERS", "Aura-Light-Debug" = "DEBUG", "Beam-Clash-Toggle" = "DEBUG", "Beam-Damage-Debug" = "DEBUG", "Beam-System-Toggle" = "ENV", "Bloom-Toggle" = "ENV", "Bookmark-Here" = "BUILD", "BreakPact" = "PLAYERS", "Build-Options" = "BUILD", "CC-Damage-Modifier" = "WORLD", "Change-AI-Damage" = "WORLD", "Change-Extra-Potential-Gain" = "WORLD", "Change-Faction" = "PLAYERS", "Change-Global-Base" = "WORLD", "Change-Launch-Lockout" = "WORLD", "Change-Max-Launch-Time" = "WORLD", "Change-Max-Summon" = "PLAYERS", "Change-Nationalities" = "PLAYERS", "Change-World-Settings" = "WORLD", "ChangeWipeStartHour" = "WORLD", "Charge-Lights-Toggle" = "ENV", "Check-AI-Damage" = "DEBUG", "Check-Majin-Rooms" = "DEBUG", "Clash-Debug-Toggle" = "DEBUG", "Clear-Error-Log" = "DEBUG", "Clear-Kamui-Buff-Lock" = "PLAYERS", "Clear-Lights" = "ENV", "Cloud-Shadows-Toggle" = "ENV", "Coat-Test" = "DEBUG", "Color-Grade-Toggle" = "ENV", "Common-Toggle" = "WORLD", "Copy" = "PLAYERS", "Copy-AG" = "PLAYERS", "Corner-Lights-Toggle" = "ENV", "Create-AG" = "PLAYERS", "Create-AI" = "WORLD", "Create-Zone" = "ZONES", "CreateRPFlag" = "PLAYERS", "CreateSwapMap" = "WORLD", "Day-Night-Toggle" = "ENV", "Debuff-Apply" = "WORLD", "Dedup-Turfs-List" = "DEBUG", "Delete" = "PLAYERS", "Delete-Bookmark" = "BUILD", "Delete-Custom-Def" = "BUILD", "Delete-Zone" = "ZONES", "DeleteSave" = "PLAYERS", "Depth-Sorting-Toggle" = "ENV", "Dismiss-Test-Dummy" = "DEBUG", "Distort-Toggle" = "ENV", "Do-Damage" = "PLAYERS", "DownloadSaves" = "WORLD", "Duplicate-Debug" = "DEBUG", "Duplicate-Purge" = "DEBUG", "Duplicate-Scan" = "DEBUG", "Edge-Debug" = "DEBUG", "Edit" = "PLAYERS", "Edit-Archive" = "WORLD", "Edit-Custom-Def" = "BUILD", "Edit-Global-Variables" = "WORLD", "Edit-Technology" = "PLAYERS", "EditAllSpawners" = "PLAYERS", "EditPassiveHandler" = "PLAYERS", "Embers-Toggle" = "ENV", "Emissives-Toggle" = "ENV", "Enable-Power-Clamp" = "WORLD", "Enter-Studio" = "BUILD", "Environment-Profile-Info" = "ENV", "Establish-Archive" = "WORLD", "Event-Character-Setup" = "PLAYERS", "Export-Map-Region" = "PREFABS", "FPSControl" = "WORLD", "Farblur-Toggle" = "ENV", "Fix-SSJ-Transformations" = "PLAYERS", "Flash" = "WORLD", "Force-AI-Spawns" = "EVENTS", "Force-Moon-Event" = "EVENTS", "Force-Weather" = "EVENTS", "ForceCloseSwapMap" = "WORLD", "ForceSaveSwapMap" = "WORLD", "Free-Studio" = "BUILD", "GetExactTime" = "WORLD", "Give-All-Signatures" = "PLAYERS", "Give-All-Skill-Tree" = "WORLD", "Give-Currency" = "PLAYERS", "Give-Demon" = "PLAYERS", "Give-Domain-Expansion" = "PLAYERS", "Give-Exchange-Verb" = "WORLD", "Give-Mapper" = "PLAYERS", "Give-Rare-Race" = "PLAYERS", "Give-Rare-Saiyan" = "PLAYERS", "Give-Register-Verb" = "WORLD", "Give-Sin" = "PLAYERS", "Give-Wound" = "PLAYERS", "Give/Make" = "PLAYERS", "GiveMazoku" = "PLAYERS", "Go-To-Bookmark" = "BUILD", "God-Rays-Toggle" = "ENV", "Graphics-Adaptive-Toggle" = "ENV", "Graphics-Reapply" = "ENV", "Head-Start-Setup" = "PLAYERS", "Impact-Bursts-Toggle" = "ENV", "Impact-Frames-Toggle" = "ENV", "Impact-Ripples-Toggle" = "ENV", "Impact-Test" = "DEBUG", "Import-Map-File" = "PREFABS", "Item-Ascension-Scaling" = "PLAYERS", "Ki-Rays-Toggle" = "ENV", "Leave-Studio" = "BUILD", "Life-Node-Spawns-Toggle" = "WORLD", "Light-Fill-Set" = "ENV", "Light-Shadows-Toggle" = "ENV", "Light-Shafts-Toggle" = "ENV", "Lighting-Toggle" = "ENV", "Lights-Toggle" = "ENV", "LoadSwapMap" = "WORLD", "Lock-Send-Back" = "PLAYERS", "Mage-Admin" = "PLAYERS", "Make-Emissive" = "ENV", "Make-Exchanger" = "WORLD", "Make-Summon" = "PLAYERS", "Make-True-Demon" = "PLAYERS", "Make-Warper-Wizard" = "BUILD", "ManuallyRemoveAdmin" = "PLAYERS", "Mapper-Edit" = "BUILD", "Mapper-Fade-Visibility" = "BUILD", "MasteryUp" = "PLAYERS", "Melee-Debug-Toggle" = "DEBUG", "Message-Global" = "EVENTS", "Message-Z-Plane" = "EVENTS", "Modify-Companion" = "WORLD", "Moon-Event-Toggle" = "ENV", "Moon-Message" = "EVENTS", "Multiply-Reveal-Toggle" = "ENV", "Narrate" = "EVENTS", "New-Character-Setup" = "PLAYERS", "Occluded-Blasts-Toggle" = "ENV", "Offer-Nation-Change" = "PLAYERS", "Overwatch" = "PLAYERS", "Place-Light" = "ENV", "Place-Prefab" = "PREFABS", "PlayerLog" = "PLAYERS", "PlayerLoginLogs" = "PLAYERS", "Potential-Daily-Set" = "WORLD", "Preview-Ascensions" = "PLAYERS", "Preview-Environment-Profile" = "ENV", "PrivateNarrate" = "PLAYERS", "Punish" = "PLAYERS", "RPP" = "WORLD", "Races" = "PLAYERS", "ReMeditate" = "PLAYERS", "Read-All-God-Prayers" = "EVENTS", "Reboot" = "EVENTS", "RedactWord" = "WORLD", "Refund-All-Technology" = "PLAYERS", "Refund-Technology" = "PLAYERS", "Remove-Mapper" = "PLAYERS", "Rename-Money" = "WORLD", "Respec" = "PLAYERS", "Rim-Light-Toggle" = "ENV", "RuntimesView" = "WORLD", "SagaManagement" = "PLAYERS", "SagaRemoval" = "PLAYERS", "Save-Prefab" = "PREFABS", "SaveTurfsObjs" = "WORLD", "SaveWorld" = "WORLD", "Screen-Shatter" = "EVENTS", "SecretManagement" = "PLAYERS", "SecretRemoval" = "PLAYERS", "Send-To-Spawn" = "PLAYERS", "Set-Area-Environment-Profile" = "ZONES", "Set-Base" = "WORLD", "Set-Time-Of-Day" = "EVENTS", "Set-global" = "WORLD", "SetGetUpSpeed" = "WORLD", "SetMadnessToMax" = "PLAYERS", "SetWorldPUDrain" = "WORLD", "SetallRoofsToDense" = "BUILD", "Shadows-Toggle" = "ENV", "Show-Admin-Helps" = "WORLD", "Shutdown" = "WORLD", "Smooth-Region" = "BUILD", "Soft-Clip-Toggle" = "ENV", "Spawn-Delete" = "WORLD", "Spawn-Edit" = "WORLD", "Spawn-New" = "WORLD", "Spawn-Permission-Add" = "WORLD", "Spawn-Permission-Remove" = "WORLD", "Spawn-Race-Add" = "WORLD", "Spawn-Race-Remove" = "WORLD", "Spawn-Swap" = "PLAYERS", "Status-Coats-Toggle" = "ENV", "Styles" = "PLAYERS", "Summon" = "PLAYERS", "Summon-Sandstorm" = "EVENTS", "Summon-Test-Dummy" = "DEBUG", "Surface-Audit-Here" = "DEBUG", "Surface-Clear-Overrides" = "SURFACES", "Surface-Inspect" = "SURFACES", "Surface-Set-Cookie" = "SURFACES", "Surface-Set-Light" = "SURFACES", "Surface-Set-Occlusion" = "SURFACES", "Surface-Set-Profile" = "SURFACES", "Surface-Set-Shaft" = "SURFACES", "Surface-Set-Type-Profile" = "SURFACES", "Surface-Set-Wind" = "SURFACES", "Tech-Unlock" = "PLAYERS", "Teleport" = "PLAYERS", "Test-Mode" = "PLAYERS", "TickLag" = "WORLD", "Toggle-SweetSpot-Held-Skill-Debug" = "DEBUG", "Toggle-Testing" = "DEBUG", "ToggleBuildMode" = "BUILD", "ToggleOOCWorld" = "WORLD", "ToggleOverview" = "WORLD", "TurfFlythru" = "WORLD", "Tweak-Pot-Reqs" = "WORLD", "Tweak-Style/Sig-Var" = "PLAYERS", "Unified-Light-Probe" = "DEBUG", "Unified-Lights-Toggle" = "ENV", "UnlockAscension" = "PLAYERS", "UnlockForm" = "PLAYERS", "Unteleport" = "PLAYERS", "View-AG-Database" = "WORLD", "View-Maim-History" = "PLAYERS", "View-Saga-Database" = "WORLD", "View-Secret-Database" = "WORLD", "View-Style/Sig-Reqs" = "PLAYERS", "ViewPassives" = "PLAYERS", "Vignette-Toggle" = "ENV", "Void" = "WORLD", "Wall-Shadows-Rebuild" = "ENV", "Wall-Shadows-Toggle" = "ENV", "Warper" = "WORLD", "Water-Sparkle-Toggle" = "ENV", "Weather-Toggle" = "ENV", "Whiff-Rate" = "WORLD", "WhosAscended" = "PLAYERS", "Wind-Control" = "ENV", "Wind-Debug" = "DEBUG", "Wipe" = "WORLD", "World-Accuracy" = "WORLD", "World-Bloom-Toggle" = "ENV", "XYZTeleport" = "PLAYERS", "Zone-Settings" = "ZONES", "ahListings" = "WORLD", "ahRemoveListing" = "WORLD", "ahWipe" = "WORLD", "changeStrikeFormula" = "WORLD", "checkworldObjectList" = "DEBUG", "editInformation" = "PLAYERS", "editRace" = "PLAYERS", "editSecretDatum" = "PLAYERS", "farmGiveAllSeeds" = "WORLD", "farmGrowDay" = "WORLD", "farmSpawnSeedStall" = "WORLD", "giveOuroboros" = "PLAYERS", "globallyIndestructable" = "WORLD", "hep" = "DEBUG", "lifeSetRank" = "WORLD", "makeAnvil" = "WORLD", "makeAuctionHouse" = "WORLD", "makeFishingSpot" = "WORLD", "makeForageNode" = "WORLD", "makeForge" = "WORLD", "makeMaterialBuyer" = "WORLD", "makeOreNode" = "WORLD", "makeTree" = "WORLD", "moon-toggle-admin" = "ENV", "openBlobdatum" = "PLAYERS", "oppForceNext" = "WORLD", "oppResetDay" = "WORLD", "refund-all-old-value" = "PLAYERS", "removeAllfromTickingAI" = "DEBUG", "removeAllfromTickingTurf" = "DEBUG", "reseedFishingSpots" = "WORLD", "reseedForageNodes" = "WORLD", "reseedOreNodes" = "WORLD", "reseedTrees" = "WORLD", "restartResourceManager" = "WORLD", "simulateAttacks" = "DEBUG", "test-ref" = "DEBUG", "testDummy" = "DEBUG", "view-ai-list" = "DEBUG", "viewDonators" = "PLAYERS", "viewSupporters" = "PLAYERS")

client/var/adminpage_open = 0
client/var/adminpage_geom = null
client/var/adminpage_lock = 0
client/var/adminpage_fold = 0
client/var/adminpage_zoom = 1
client/var/adminpage_x0 = 0
client/var/adminpage_y0 = 0
client/var/adminpage_tab = null
client/var/adminpage_favs = null
client/var/adminpage_recent = null
client/var/adminpage_booted = 0
client/var/atom/movable/shud/menubtn/btn_admin
client/var/atom/movable/shud/menulabel/btn_admin_label

client/proc/AdminPageSendAssets()
	ChatPanelSendAssets()
	src << browse_rsc('HUD/chatpanel/lc_tabw.png', "lc_tabw.png")
	src << browse_rsc('HUD/chatpanel/lc_tabw_on.png', "lc_tabw_on.png")
	src << browse_rsc('HUD/chatpanel/lc_chip_a.png', "lc_chip_a.png")
	src << browse_rsc('HUD/chatpanel/lc_chip_b.png', "lc_chip_b.png")
	src << browse_rsc('HUD/chatpanel/lc_btn.png', "lc_btn.png")
	src << browse_rsc('HUD/chatpanel/lc_btn_down.png', "lc_btn_down.png")
	src << browse_rsc('HUD/chatpanel/lc_band.png', "lc_band.png")
	src << browse_rsc('HUD/chatpanel/lc_search.png', "lc_search.png")
	src << browse_rsc('HUD/chatpanel/lc_play.png', "lc_play.png")
	src << browse_rsc('HUD/chatpanel/lc_star.png', "lc_star.png")
	src << browse_rsc('HUD/chatpanel/lc_star_off.png', "lc_star_off.png")

client/proc/AdminPageHTML()
	return {"<!DOCTYPE html><html><head><meta charset='utf-8'><style>
 @font-face{font-family:'monogram';src:url('monogram.ttf')}
 html,body{margin:0;padding:0;background:transparent;overflow:hidden;width:100%;height:100%}
 body{font:16px/16px 'monogram';color:#eaf5ff;user-select:none;-webkit-user-select:none}
 #shell{position:absolute;left:0;top:0;width:496px;height:352px;image-rendering:pixelated}
 #frame{position:absolute;left:0;top:0;right:0;bottom:0;border:16px solid transparent;border-image:url('lc_cover.png') 16 fill stretch;pointer-events:none}
 #frame.strip{border-image:url('lc_cover_strip.png') 16 fill stretch}
 #hdr{position:absolute;left:0;top:0;right:0;height:44px;cursor:move}
 .tabw{position:absolute;top:8px;width:84px;height:32px;background:url('lc_tabw.png') no-repeat;line-height:32px;text-align:center;color:#cfe3f5;cursor:pointer;display:none}
 .tabw.show{display:block}
 .tabw.on{background-image:url('lc_tabw_on.png');color:#06283b}
 .btn{position:absolute;top:8px;width:32px;height:32px;background:url('lc_slot.png') no-repeat;cursor:pointer}
 .btn img{position:absolute;left:8px;top:8px;width:16px;height:16px}
 #lock{right:52px}
 #fold{right:16px}
 #view{position:absolute;left:0;right:0;top:44px;bottom:32px}
 .pane{position:absolute;left:0;top:0;right:0;bottom:0;display:none}
 .pane.on{display:block}
 .bg{position:absolute;left:0;top:0;right:0;bottom:0;pointer-events:none}
 .sub{border:6px solid transparent;border-image:url('lc_forgesub.png') 6 fill stretch;box-sizing:border-box}
 .fld{border:8px solid transparent;border-image:url('lc_field.png') 8 fill stretch;box-sizing:border-box}
 .plate{border:6px solid transparent;border-image:url('lc_rowplate.png') 6 fill stretch;box-sizing:border-box}
 .search{position:absolute;left:16px;right:16px;top:0;height:30px}
 .search .ico{position:absolute;left:9px;top:7px;width:16px;height:16px}
 .search input{position:absolute;left:30px;top:8px;right:10px;height:16px;margin:0;padding:0;background:transparent;border:0;outline:0;font:16px/16px 'monogram';color:#eaf5ff;caret-color:#eaf5ff}
 .chip{position:absolute;top:36px;width:58px;height:18px;line-height:16px;text-align:center;color:#cfe3f5;cursor:pointer}
 .chip .bg{border:6px solid transparent;border-image:url('lc_chip_a.png') 6 fill stretch;box-sizing:border-box}
 .chip.on{color:#06283b}
 .chip.on .bg{border-image-source:url('lc_chip_b.png')}
 .chip span{position:relative}
 .body{position:absolute;left:16px;right:16px}
 .body .hd{position:absolute;left:14px;top:6px;color:#bfe6ff}
 .list{position:absolute;left:22px;right:26px;overflow-y:scroll;overflow-x:hidden;box-sizing:border-box}
 .list::-webkit-scrollbar{width:14px}
 .list::-webkit-scrollbar-track{background:url('lc_track.png') no-repeat;background-size:100% 100%;margin:6px 0}
 .list::-webkit-scrollbar-thumb{border-left:1px solid transparent;border-right:1px solid transparent;background-clip:padding-box;background-origin:padding-box;background:url('lc_thumb_top.png') left top no-repeat,url('lc_thumb_bot.png') left bottom no-repeat,url('lc_thumb_mid.png') left center no-repeat,url('lc_thumb_col.png') left top repeat-y;background-size:12px 6px,12px 6px,12px 11px,12px 1px;min-height:24px}
 .row{position:relative;height:18px;line-height:16px;cursor:pointer;white-space:nowrap}
 .row .pl{position:absolute;left:0;top:-1px;right:32px;height:18px;display:none}
 .row.sel .pl{display:block}
 .row .nm{position:absolute;left:8px;top:0}
 .row .cat{position:absolute;right:40px;top:0;color:#7ec8f0}
 .row .st{position:absolute;right:8px;top:0;width:18px;height:16px;background:url('lc_star_off.png') center no-repeat;cursor:pointer}
 .row.fav .st{background-image:url('lc_star.png')}
 .row .args{position:absolute;left:0;top:18px;right:32px;display:none}
 .row.sel.x .args{display:block}
 .al{position:absolute;left:8px;color:#7ec8f0}
 .aw{position:absolute;left:56px;width:190px;height:22px}
 .aw input{position:absolute;left:8px;top:3px;right:18px;height:16px;margin:0;padding:0;background:transparent;border:0;outline:0;font:16px/16px 'monogram';color:#eaf5ff;caret-color:#eaf5ff}
 .aw.pick input{right:18px}
 .aw .ar{position:absolute;right:8px;top:9px;width:5px;height:4px;display:none}
 .aw.pick .ar{display:block}
 .use{position:absolute;left:254px;top:0;width:44px;height:24px;line-height:24px;text-align:center;color:#eaf5ff;cursor:pointer}
 .use.solo{left:8px}
 .use .bg{border:8px solid transparent;border-image:url('lc_btn.png') 8 fill stretch;box-sizing:border-box}
 .use:hover{color:#8be9ff}
 .use:hover .bg{filter:brightness(1.2)}
 .use:active{color:#06283b}
 .use:active .bg{border-image-source:url('lc_btn_down.png');filter:none}
 .use span{position:relative;top:1px}
 .use:active span{top:2px}
 .rr{position:relative;height:24px;line-height:16px;white-space:nowrap}
 .rr .nm{position:absolute;left:8px;top:4px}
 .rr .nm .a{color:#7ec8f0}
 .rr .ago{position:absolute;right:54px;top:4px;color:#7ec8f0}
 .rr .play{position:absolute;right:22px;top:0;width:24px;height:24px;background:url('lc_play.png') no-repeat;cursor:pointer}
 .sc{position:absolute;left:16px;right:16px;top:0;bottom:6px;overflow-y:scroll;overflow-x:hidden}
 .sc::-webkit-scrollbar{width:14px}
 .sc::-webkit-scrollbar-track{background:url('lc_track.png') no-repeat;background-size:100% 100%;margin:6px 0}
 .sc::-webkit-scrollbar-thumb{border-left:1px solid transparent;border-right:1px solid transparent;background-clip:padding-box;background-origin:padding-box;background:url('lc_thumb_top.png') left top no-repeat,url('lc_thumb_bot.png') left bottom no-repeat,url('lc_thumb_mid.png') left center no-repeat,url('lc_thumb_col.png') left top repeat-y;background-size:12px 6px,12px 6px,12px 11px,12px 1px;min-height:24px}
 .cols{position:relative;padding-right:10px;display:flex;align-items:flex-start}
 .col{flex:1 1 0;min-width:0}
 .col+.col{margin-left:4px}
 .grp{position:relative;margin-bottom:4px}
 .grp .hd{position:absolute;left:8px;top:6px;color:#bfe6ff}
 .kvs{position:absolute;left:0;right:0;top:22px}
 .kv{position:relative;height:16px;line-height:16px;white-space:nowrap}
 .kv .pl{position:absolute;left:4px;right:4px;top:-1px;height:18px;display:none}
 .kv.ed{cursor:pointer}
 .kv.ed:hover .pl,.kv.editing .pl{display:block}
 .kv .k{position:absolute;left:8px;top:0;color:#7ec8f0}
 .kv .v{position:absolute;right:8px;top:0}
 .kv .v input{width:84px;height:16px;margin:0;padding:0;background:transparent;border:0;outline:0;font:16px/16px 'monogram';color:#eaf5ff;caret-color:#eaf5ff;text-align:right}
 .kv .v .o{color:#7ec8f0;cursor:pointer}
 .kv .v .o.on{color:#eaf5ff}
 .kv .v .o+.o{margin-left:6px}
 #foot{position:absolute;left:16px;right:16px;bottom:14px;height:18px;white-space:nowrap;overflow:hidden}
 #foot .bg{border:6px solid transparent;border-image:url('lc_band.png') 6 fill stretch;box-sizing:border-box}
 #foot .t{position:absolute;left:8px;top:2px}
 #foot .k{color:#7ec8f0}
 #foot .dv{display:inline-block;width:1px;height:8px;background:#344975;margin:0 9px 0 10px;vertical-align:top;position:relative;top:4px}
 #pop{position:absolute;display:none;z-index:6}
 #pop .bg{border:6px solid transparent;border-image:url('lc_forgesub.png') 6 fill stretch;box-sizing:border-box}
 #popl{position:relative;padding:6px 0}
 .dr{position:relative;height:18px;line-height:18px;padding:0 8px;white-space:nowrap;overflow:hidden;cursor:pointer;color:#eaf5ff}
 .dr .pl{position:absolute;left:0;top:0;right:0;bottom:0;display:none}
 .dr.sel .pl{display:block}
 .dr span{position:relative}
 .dr.hint{color:#b8b8d9;cursor:default}
 .empty{position:absolute;left:8px;top:2px;color:#b8b8d9}
 #grip{position:absolute;right:0;bottom:0;width:20px;height:20px;cursor:nwse-resize}
 :root{--cur:url('lc_cur_neutral.png') 2 0, auto;--cur-text:url('lc_cur_ibeam.png') 2 5, text;--cur-drag:url('lc_cur_drag.png') 4 5, move}
 *{cursor:var(--cur) !important}
 input,textarea,\[contenteditable='true'],#log{cursor:var(--cur-text) !important}
 #hdr.dragok,#grip{cursor:var(--cur-drag) !important}
 </style></head><body>
 <div id='shell'>
  <div id='frame'></div>
  <div id='hdr'>
   <div class='tabw' id='t_cmd'>COMMANDS</div>
   <div class='tabw' id='t_fav'>FAVORITES</div>
   <div class='tabw' id='t_status'>STATUS</div>
   <div class='tabw' id='t_map'>MAPPER</div>
   <div class='btn' id='lock'><img src='lc_unlock.png' alt=''></div>
   <div class='btn' id='fold'><img src='lc_down.png' alt=''></div>
  </div>
  <div id='view'>
   <div class='pane' id='p_cmd'></div>
   <div class='pane' id='p_map'></div>
   <div class='pane' id='p_fav'>
    <div class='body' id='favbody' style='top:0;height:152px'><div class='bg sub'></div><div class='hd'>STARRED</div></div>
    <div class='list' id='l_fav' style='top:24px;height:122px'></div>
    <div class='body' id='recbody' style='top:156px;bottom:6px'><div class='bg sub'></div><div class='hd'>RECENT</div></div>
    <div class='list' id='l_rec' style='top:180px;bottom:12px;overflow-y:auto'></div>
   </div>
   <div class='pane' id='p_status'><div class='sc' id='sc'><div class='cols'><div class='col' id='colL'></div><div class='col' id='colR'></div></div></div></div>
  </div>
  <div id='foot'><div class='bg'></div><div class='t' id='foott'></div></div>
  <div id='pop'><div class='bg'></div><div id='popl'></div></div>
  <div id='grip'></div>
 </div>
 <script>
 var shell=document.getElementById('shell'), hdr=document.getElementById('hdr'), grip=document.getElementById('grip'), fold=document.getElementById('fold'), lockBtn=document.getElementById('lock');
 var lockImg=lockBtn.getElementsByTagName('img').item(0), foldImg=fold.getElementsByTagName('img').item(0);
 var frame=document.getElementById('frame'), view=document.getElementById('view'), foot=document.getElementById('foot'), foott=document.getElementById('foott');
 var pop=document.getElementById('pop'), popl=document.getElementById('popl');
 var PREVIEW=false;
 var CTL='mapwindow.adminoverlay', MINW=496, MINH=352;
 function applyCursor(){ var two=(Z>=2); var r=document.documentElement.style; r.setProperty('--cur',two?"url('lc_cur_neutral2.png') 5 1, auto":"url('lc_cur_neutral.png') 2 0, auto"); r.setProperty('--cur-text',two?"url('lc_cur_ibeam2.png') 5 11, text":"url('lc_cur_ibeam.png') 2 5, text"); r.setProperty('--cur-drag',two?"url('lc_cur_drag2.png') 9 11, move":"url('lc_cur_drag.png') 4 5, move"); }


 var Z=2, OP=0.85, G={x:0,y:0,w:992,h:704}, B=null, collapsed=false, live=false, locked=false, tab='cmd';
 var role={admin:0,mapper:0}, cmds=\[], byId={}, favs={}, recent=\[], players=\[], vals={}, sel={cmd:null,map:null,fav:null}, chip={cmd:'ALL',map:'ALL'}, query={cmd:'',map:''};
 var CHIPS={cmd:\['ALL','PLAYERS','WORLD','EVENTS','ENV','DEBUG'],map:\['ALL','BUILD','ZONES','SURFACES','PREFABS','DEBUG']};
 var KLABEL={player:'TARGET',choice:'OPTION',num:'NUMBER',text:'TEXT'};
 var SGROUPS=\[
  {col:0,title:'WORLD',rows:\[\['coords','Coordinates'],\['cpu','CPU'],\['era','Era'],\['days','Days of wipe'],\['daycheck','Day check'],\['potdaily','Potential daily',4,'num']]},
  {col:0,title:'SPAWNS AND VOIDS',rows:\[\['dead','Dead spawn'],\['voidspawn','Void spawn'],\['voids','Voids',4,'bool'],\['voidchance','Void chance',4,'num'],\['getup','Get-up speed',3,'num']]},
  {col:0,title:'ECONOMY',rows:\[\['rppdaily','RPP routine',4,'num'],\['rppstart','RPP start',3,'num'],\['rppdays','RPP start days',3,'num'],\['costincome','Cost / income'],\['mana','Mana cost']]},
  {col:1,title:'DAMAGE',rows:\[\['base','Base power',3,'num'],\['queue','Queue dmg'],\['world','World dmg',3,'num'],\['acc','Accuracy',3,'num'],\['whiff','Whiff rate',3,'num'],\['melee','Melee'],\['item','Item dmg'],\['autohit','Autohit'],\['proj','Projectile'],\['exponent','Power exponent',3,'num'],\['scale','Strike scale',3,'num'],\['kval','Strike K',3,'num'],\['intim','Intim ratio']]},
  {col:1,title:'SERVER',rows:\[\['ticks','Celestial ticks'],\['tickusage','Tick usage']]}
 ];
 var sdata={}, editing=null;
 function clampNum(v,lo,hi){ if(hi<lo) hi=lo; if(v<lo) return lo; if(v>hi) return hi; return v; }
 function esc(x){ return String(x).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/'/g,'&#39;'); }
 function ws(p){ if(window.BYOND) BYOND.winset(CTL,p); }
 function topic(p){ p.adminpage=p.adminpage||''; if(window.BYOND) BYOND.topic(p); }
 function focusMap(){ if(window.BYOND) BYOND.winset('mapwindow.map',{focus:true}); }
 function clampG(){
  if(!B) return;
  var h=collapsed?48*Z:G.h;
  if(G.w>B.x1-B.x0) G.w=B.x1-B.x0;
  if(!collapsed && G.h>B.y1-B.y0){ G.h=B.y1-B.y0; h=G.h; }
  G.x=clampNum(G.x,B.x0,B.x1-G.w); G.y=clampNum(G.y,B.y0,B.y1-h);
 }
 function layout(){
  document.body.style.zoom=Z; applyCursor();
  shell.style.width=Math.round(G.w/Z)+'px';
  shell.style.height=(collapsed?48:Math.round(G.h/Z))+'px';
  frame.style.opacity=OP;
  frame.classList.toggle('strip',collapsed);
  if(!live){ shell.style.left=Math.round(G.x/Z)+'px'; shell.style.top=Math.round(G.y/Z)+'px'; }
  var show=collapsed?'none':'block';
  view.style.display=show; foot.style.display=show; grip.style.display=(collapsed||locked)?'none':'block';
  foldImg.src=collapsed?'lc_up.png':'lc_down.png';
  lockImg.src=locked?'lc_lock.png':'lc_unlock.png'; hdr.classList.toggle('dragok',!locked);
  if(collapsed) popClose();
 }
 function setGeom(x,y,w,h,z,op,bx0,by0,bx1,by1,lk,fd){ G={x:+x,y:+y,w:+w,h:+h}; Z=+z; OP=+op; if(bx1!==undefined){ B={x0:+bx0,y0:+by0,x1:+bx1,y1:+by1}; } locked=(+lk)?true:false; var wantFold=(+fd)?true:false; collapsed=false; if(wantFold){ collapsed=true; G.y+=G.h-48*Z; } clampG(); if(collapsed){ flush(); } else { layout(); } }
 var pending=false;
 function flush(){ pending=false; clampG(); ws({pos:G.x+','+G.y, size:G.w+'x'+(collapsed?48*Z:G.h)}); layout(); }
 function sched(){ if(!pending){ pending=true; requestAnimationFrame(flush); } }
 function report(){ topic({adminpage:'geom', g:G.x+','+G.y+','+G.w+','+G.h}); }
 var drag=null;
 hdr.addEventListener('pointerdown',function(e){ if(e.button!==0||locked) return; if(e.target.closest('.tabw')||e.target.closest('.btn')) return; drag={sx:e.screenX,sy:e.screenY,x:G.x,y:G.y}; try{ hdr.setPointerCapture(e.pointerId); }catch(err){} e.preventDefault(); });
 hdr.addEventListener('pointermove',function(e){ if(!drag) return; G.x=drag.x+(e.screenX-drag.sx); G.y=drag.y+(e.screenY-drag.sy); clampG(); sched(); });
 hdr.addEventListener('pointerup',function(e){ if(!drag) return; drag=null; flush(); report(); focusMap(); });
 var rs=null;
 grip.addEventListener('pointerdown',function(e){ if(e.button!==0||locked) return; rs={sx:e.screenX,sy:e.screenY,w:G.w,h:G.h}; try{ grip.setPointerCapture(e.pointerId); }catch(err){} e.preventDefault(); e.stopPropagation(); });
 grip.addEventListener('pointermove',function(e){ if(!rs) return; var mw=B?B.x1-G.x:1e9, mh=B?B.y1-G.y:1e9; G.w=clampNum(rs.w+(e.screenX-rs.sx),MINW*Z,mw); G.h=clampNum(rs.h+(e.screenY-rs.sy),MINH*Z,mh); sched(); });
 grip.addEventListener('pointerup',function(e){ if(!rs) return; rs=null; flush(); report(); popClose(); focusMap(); });
 fold.addEventListener('click',function(){ var d=G.h-48*Z; if(!collapsed){ collapsed=true; G.y+=d; } else { collapsed=false; G.y=G.y-d; } clampG(); flush(); report(); topic({adminpage:'fold',f:collapsed?1:0}); focusMap(); });
 lockBtn.addEventListener('click',function(){ locked=!locked; layout(); topic({adminpage:'lock',l:locked?1:0}); focusMap(); });
 function tabsLayout(){
  var order=\['cmd','fav','status','map'], x=16;
  for(var i=0;i<order.length;i++){ var t=order\[i], el=document.getElementById('t_'+t); var vis=(t==='map')?(role.mapper?true:false):(role.admin?true:false); el.classList.toggle('show',vis); if(vis){ el.style.left=x+'px'; x+=86; } }
 }
 function setRole(a,m){ role={admin:+a,mapper:+m}; tabsLayout(); if(tab==='map'&&!role.mapper) tab='cmd'; if(tab!=='map'&&!role.admin&&role.mapper) tab='map'; setTab(tab,true); }
 function setTab(t,quiet){
  if(t==='map'&&!role.mapper) t='cmd';
  if(t!=='map'&&!role.admin) t='map';
  tab=t; popClose(); finishEdit(false);
  var order=\['cmd','fav','status','map'];
  for(var i=0;i<order.length;i++){ document.getElementById('t_'+order\[i]).classList.toggle('on',order\[i]===t); document.getElementById('p_'+order\[i]).classList.toggle('on',order\[i]===t); }
  if(t==='fav') renderFav();
  if(t==='status') renderStatus();
  if(!quiet) topic({adminpage:'tab',t:t});
 }
 var tabEls=document.getElementsByClassName('tabw');
 for(var ti=0;ti<tabEls.length;ti++){ (function(el){ el.addEventListener('click',function(){ setTab(el.id.substring(2)); focusMap(); }); })(tabEls.item(ti)); }
 function buildListPane(which){
  var p=document.getElementById('p_'+which); var h='';
  h+="<div class='search'><div class='bg fld'></div><img class='ico' src='lc_search.png' alt=''><input type='text' autocomplete='off' spellcheck='false' data-w='"+which+"'></div>";
  var cs=CHIPS\[which];
  for(var i=0;i<cs.length;i++){ h+="<div class='chip"+(i===0?' on':'')+"' style='left:"+(16+i*62)+"px' data-w='"+which+"' data-c='"+cs\[i]+"'><div class='bg'></div><span>"+cs\[i]+"</span></div>"; }
  h+="<div class='body' style='top:60px;bottom:6px'><div class='bg sub'></div></div>";
  h+="<div class='list' id='l_"+which+"' style='top:66px;bottom:12px;padding-top:2px'></div>";
  p.innerHTML=h;
  var q=p.getElementsByTagName('input').item(0);
  q.addEventListener('input',function(){ query\[which]=q.value; renderList(which); });
  q.addEventListener('keydown',function(e){ if(e.key==='Escape'){ q.value=''; query\[which]=''; renderList(which); q.blur(); focusMap(); e.preventDefault(); } else if(e.key==='Enter'){ var rows=filtered(which); if(rows.length===1){ select(which,rows\[0].id); } e.preventDefault(); } });
  var chips=p.getElementsByClassName('chip');
  for(var c=0;c<chips.length;c++){ (function(el){ el.addEventListener('click',function(){ chip\[which]=el.getAttribute('data-c'); var all=p.getElementsByClassName('chip'); for(var k=0;k<all.length;k++) all.item(k).classList.toggle('on',all.item(k)===el); renderList(which); focusMap(); }); })(chips.item(c)); }
 }
 function norm(s){ return s.toLowerCase().split('-').join(' '); }
 function filtered(which){
  var out=\[], q=norm(query\[which]||''), g=chip\[which];
  for(var i=0;i<cmds.length;i++){ var c=cmds\[i]; if(c.role!==(which==='map'?'mapper':'admin')) continue; if(g!=='ALL'&&c.group!==g) continue; var n=norm(c.id); if(q&&n.indexOf(q)<0) continue; c._rank=(q&&n.indexOf(q)===0)?0:1; out.push(c); }
  out.sort(function(a,b){ if(a._rank!==b._rank) return a._rank-b._rank; return norm(a.id)<norm(b.id)?-1:1; });
  return out;
 }
 function rowHtml(c,which){
  var on=(sel\[which]===c.id);
  var h="<div class='row"+(on?' sel x':'')+(favs\[c.id]?' fav':'')+"' data-id='"+esc(c.id)+"' data-w='"+which+"'"+(on?" style='height:"+rowH(c)+"px'":'')+"><div class='pl plate'"+(on?" style='height:"+(rowH(c)-4)+"px'":'')+"></div><span class='nm'>"+esc(c.id.split('-').join(' '))+"</span><span class='cat'>"+esc(c.group)+"</span><div class='st' title='favorite'></div>";
  if(on) h+=argsHtml(c);
  h+="</div>"; return h;
 }
 function rowH(c){ var n=c.args.length; return n?18+32+(n-1)*26:18+32; }
 function argsHtml(c){
  var h="<div class='args' style='height:"+(rowH(c)-18)+"px'>";
  var v=vals\[c.id]||\[];
  for(var i=0;i<c.args.length;i++){
   var k=c.args\[i], y=i*26, base=k.indexOf('choice')===0?'choice':k; var pick=(k==='player'||base==='choice');
   h+="<span class='al' style='top:"+(y+4)+"px'>"+KLABEL\[base]+"</span>";
   h+="<div class='aw"+(pick?' pick':'')+"' style='top:"+(y+1)+"px'><div class='bg fld'></div><input type='text' autocomplete='off' spellcheck='false' data-i='"+i+"' data-k='"+esc(k)+"' value='"+esc(v\[i]||'')+"'><img class='ar' src='lc_caret.png' alt=''></div>";
  }
  h+="<div class='use"+(c.args.length?'':' solo')+"'><div class='bg'></div><span>USE</span></div></div>";
  return h;
 }
 function renderList(which){
  var l=document.getElementById('l_'+which); var rows=filtered(which); var h='';
  for(var i=0;i<rows.length;i++) h+=rowHtml(rows\[i],which);
  if(!rows.length) h="<div class='empty'>"+(cmds.length?'no commands match':'no commands')+"</div>";
  l.innerHTML=h;
 }
 function renderFav(){
  var l=document.getElementById('l_fav'); var h=''; var ids=\[];
  for(var id in favs){ if(favs\[id]&&byId\[id]) ids.push(id); }
  ids.sort(function(a,b){ return norm(a)<norm(b)?-1:1; });
  for(var i=0;i<ids.length;i++) h+=rowHtml(byId\[ids\[i]],'fav');
  if(!ids.length) h="<div class='empty'>star a command to keep it here</div>";
  l.innerHTML=h;
  var r=document.getElementById('l_rec'); var rh='';
  for(var j=0;j<recent.length;j++){ var e=recent\[j]; rh+="<div class='rr' data-i='"+j+"'><span class='nm'>"+esc(e.id.split('-').join(' '))+(e.arg?"<span class='a'>  "+esc(e.arg)+"</span>":'')+"</span><span class='ago'>"+ago(e.at)+"</span><div class='play' title='run again'></div></div>"; }
  if(!recent.length) rh="<div class='empty'>nothing run yet</div>";
  r.innerHTML=rh;
 }
 function ago(at){ var m=Math.floor((Date.now()-at)/60000); if(m<1) return 'now'; if(m<60) return m+'m'; var h=Math.floor(m/60); if(h<24) return h+'h'; return Math.floor(h/24)+'d'; }
 function select(which,id){ finishEdit(false); popClose(); sel\[which]=(sel\[which]===id)?null:id; if(which==='fav') renderFav(); else renderList(which); }
 function quote(s){ s=String(s); return s.indexOf(' ')>=0?'"'+s+'"':s; }
 function runCmd(c,which){
  var v=vals\[c.id]||\[], parts=\[c.id];
  for(var i=0;i<c.args.length;i++){ var a=(v\[i]||'').trim(); if(!a){ var row=document.querySelector("#l_"+which+" .row\[data-id='"+cssq(c.id)+"']"); if(row){ var inp=row.querySelectorAll('input').item(i); if(inp) inp.focus(); } return; } parts.push(quote(a)); }
  var line=parts.join(' ');
  if(window.BYOND) BYOND.command(line);
  var argText=v.slice(0,c.args.length).join(' ');
  recent.unshift({id:c.id,arg:argText,at:Date.now()}); if(recent.length>12) recent.length=12;
  topic({adminpage:'used',id:c.id,arg:argText});
  popClose(); if(tab==='fav') renderFav(); focusMap();
 }
 function cssq(s){ return s.split("'").join(''); }
 function listClick(e){
  var star=e.target.closest('.st'); var row=e.target.closest('.row'); if(!row) return;
  var id=row.getAttribute('data-id'), which=row.getAttribute('data-w'); var c=byId\[id]; if(!c) return;
  if(star){ favs\[id]=!favs\[id]; row.classList.toggle('fav',favs\[id]); topic({adminpage:'fav',id:id,on:favs\[id]?1:0}); if(tab==='fav'&&!favs\[id]) renderFav(); footer(); e.stopPropagation(); return; }
  if(e.target.closest('.use')){ runCmd(c,which); e.stopPropagation(); return; }
  if(e.target.closest('.aw')){ return; }
  if(e.target.closest('.args')) return;
  select(which,id); focusMap();
 }
 function listInput(e){
  var inp=e.target; if(inp.tagName!=='INPUT'||!inp.closest('.aw')) return;
  var row=inp.closest('.row'); var id=row.getAttribute('data-id'); var i=+inp.getAttribute('data-i');
  if(!vals\[id]) vals\[id]=\[]; vals\[id]\[i]=inp.value;
  popFor(inp);
 }
 function listFocus(e){ var inp=e.target; if(inp.tagName==='INPUT'&&inp.closest('.aw')) popFor(inp); }
 function listKey(e){
  var inp=e.target; if(inp.tagName!=='INPUT'||!inp.closest('.aw')) return;
  if(pop.style.display==='block'){
   if(e.key==='ArrowDown'){ popSel=(popSel+1)%popItems.length; popRender(); e.preventDefault(); return; }
   if(e.key==='ArrowUp'){ popSel=(popSel-1+popItems.length)%popItems.length; popRender(); e.preventDefault(); return; }
   if(e.key==='Tab'){ popAccept(); e.preventDefault(); return; }
   if(e.key==='Enter'){ if(popItems\[popSel]&&!popItems\[popSel].hint&&inp.value.toLowerCase()!==popItems\[popSel].label.toLowerCase()){ popAccept(); e.preventDefault(); return; } }
  }
  if(e.key==='Escape'){ popClose(); inp.blur(); focusMap(); e.preventDefault(); return; }
  if(e.key==='Enter'){ var row=inp.closest('.row'); var c=byId\[row.getAttribute('data-id')]; popClose(); if(c) runCmd(c,row.getAttribute('data-w')); e.preventDefault(); }
 }
 var popInp=null, popItems=\[], popSel=0;
 function popFor(inp){
  popInp=inp; var k=inp.getAttribute('data-k'); var q=inp.value.toLowerCase(); popItems=\[];
  if(k==='player'){ if(!players.length) topic({adminpage:'players'}); for(var i=0;i<players.length&&popItems.length<8;i++){ if(!q||players\[i].toLowerCase().indexOf(q)>=0) popItems.push({label:players\[i]}); } if(!popItems.length) popItems.push({label:players.length?'no player matches':'player name',hint:true}); }
  else if(k.indexOf('choice:')===0){ var ch=k.substring(7).split('/'); for(var m=0;m<ch.length&&popItems.length<8;m++){ if(!q||ch\[m].toLowerCase().indexOf(q)>=0) popItems.push({label:ch\[m]}); } if(!popItems.length) popItems.push({label:'no option matches',hint:true}); }
  else if(k==='choice'){ popItems.push({label:'type the option name',hint:true}); }
  else { popClose(); return; }
  popSel=0; popRender();
  var aw=inp.closest('.aw'), ox=0, oy=0, el=aw;
  while(el&&el!==shell){ ox+=el.offsetLeft; oy+=el.offsetTop-el.scrollTop; el=el.offsetParent; }
  var lst=aw.closest('.list'); if(lst) oy-=lst.scrollTop;
  pop.style.left=ox+'px'; pop.style.top=(oy+aw.offsetHeight)+'px'; pop.style.width=aw.offsetWidth+'px';
  pop.style.display='block';
 }
 function popRender(){ var h=''; for(var r=0;r<popItems.length;r++){ var it=popItems\[r]; h+="<div class='dr"+(r===popSel&&!it.hint?' sel':'')+(it.hint?' hint':'')+"' data-i='"+r+"'><div class='pl plate'></div><span>"+esc(it.label)+"</span></div>"; } popl.innerHTML=h; }
 function popAccept(){ var it=popItems\[popSel]; if(!it||it.hint||!popInp) return; popInp.value=it.label; var row=popInp.closest('.row'); var id=row.getAttribute('data-id'); var i=+popInp.getAttribute('data-i'); if(!vals\[id]) vals\[id]=\[]; vals\[id]\[i]=it.label; popClose(); }
 function popClose(){ pop.style.display='none'; popItems=\[]; popInp=null; }
 popl.addEventListener('pointerdown',function(e){ var r=e.target.closest('.dr'); if(!r||r.classList.contains('hint')) return; popSel=+r.getAttribute('data-i'); var inp=popInp; popAccept(); if(inp) inp.focus(); e.preventDefault(); });
 document.addEventListener('pointerdown',function(e){ if(pop.style.display==='block'&&!e.target.closest('#pop')&&!e.target.closest('.aw')) popClose(); if(editing&&!e.target.closest('.kv.editing')) finishEdit(false); });
 var lists=\['l_cmd','l_map','l_fav'];
 function bindList(id){ var l=document.getElementById(id); l.addEventListener('click',listClick); l.addEventListener('input',listInput); l.addEventListener('focusin',listFocus); l.addEventListener('keydown',listKey); l.addEventListener('scroll',popClose); }
 document.getElementById('l_rec').addEventListener('click',function(e){ var p=e.target.closest('.play'); var rr=e.target.closest('.rr'); if(!rr) return; var en=recent\[+rr.getAttribute('data-i')]; if(!en) return; var c=byId\[en.id]; if(!c) return; if(p){ vals\[en.id]=en.arg?splitArgs(en.arg):\[]; runCmd(c,'fav'); } else { favs\[en.id]=favs\[en.id]; sel.fav=en.id; if(!favs\[en.id]){ setTab(c.role==='mapper'?'map':'cmd'); sel\[c.role==='mapper'?'map':'cmd']=en.id; renderList(c.role==='mapper'?'map':'cmd'); } else renderFav(); } });
 function splitArgs(rest){ var out=\[], cur='', q=false; for(var i=0;i<rest.length;i++){ var c=rest.charAt(i); if(c==='"'){ q=!q; continue; } if(c===' '&&!q){ if(cur.length){ out.push(cur); cur=''; } continue; } cur+=c; } if(cur.length) out.push(cur); return out; }
 function setCommands(s){
  cmds=\[]; byId={}; var parts=(s||'').split(';');
  for(var i=0;i<parts.length;i++){ var f=parts\[i]; if(!f) continue; var a=f.split('|'); var c={id:a\[0],role:a\[1]||'admin',group:a\[2]||'WORLD',args:(a\[3]?a\[3].split(','):\[])}; cmds.push(c); byId\[c.id]=c; }
  renderList('cmd'); renderList('map'); if(tab==='fav') renderFav(); footer();
 }
 function setPlayers(s){ players=(s||'').split('|').filter(function(x){ return x.length>0; }); if(popInp) popFor(popInp); }
 function setFavs(s){ favs={}; var a=(s||'').split('|'); for(var i=0;i<a.length;i++){ if(a\[i]) favs\[a\[i]]=true; } renderList('cmd'); renderList('map'); if(tab==='fav') renderFav(); footer(); }
 function setRecent(s){ recent=\[]; var a=(s||'').split(';'); for(var i=0;i<a.length;i++){ if(!a\[i]) continue; var f=a\[i].split('|'); recent.push({id:f\[0],arg:f\[1]||'',at:Date.now()-(+f\[2]||0)*60000}); } if(tab==='fav') renderFav(); }
 var foot_data={x:'-',y:'-',z:'-',cpu:'-',era:'-',day:'-'};
 function dec(v){ try{ return decodeURIComponent(v.split('+').join(' ')); }catch(e){ return v; } }
 function setFooter(s){ var a=(s||'').split(';'); for(var i=0;i<a.length;i++){ var p=a\[i].indexOf(':'); if(p>0) foot_data\[a\[i].substring(0,p)]=dec(a\[i].substring(p+1)); } footer(); }
 function footer(){
  var nf=0; for(var id in favs){ if(favs\[id]) nf++; }
  var nc=0; for(var i=0;i<cmds.length;i++){ if(cmds\[i].role===(tab==='map'?'mapper':'admin')) nc++; }
  var g=\[\["<span class='k'>X </span>"+esc(foot_data.x)+"<span class='k'>  Y </span>"+esc(foot_data.y)+"<span class='k'>  Z </span>"+esc(foot_data.z)],\["<span class='k'>CPU </span>"+esc(foot_data.cpu)],\["<span class='k'>ERA </span>"+esc(foot_data.era)],\["<span class='k'>DAY </span>"+esc(foot_data.day)],\["<span class='k'>CMDS </span>"+nc+"<span class='k'>  FAV </span>"+nf]];
  var h=''; for(var j=0;j<g.length;j++){ if(j) h+="<span class='dv'></span>"; h+=g\[j]\[0]; }
  foott.innerHTML=h;
 }
 function setStatus(s){ var a=(s||'').split(';'); for(var i=0;i<a.length;i++){ var p=a\[i].indexOf(':'); if(p>0) sdata\[a\[i].substring(0,p)]=dec(a\[i].substring(p+1)); } if(tab==='status') renderStatus(); }
 function renderStatus(){
  var cols=\[document.getElementById('colL'),document.getElementById('colR')]; var hs=\['',''];
  for(var gi=0;gi<SGROUPS.length;gi++){
   var g=SGROUPS\[gi]; var h="<div class='grp' style='height:"+(g.rows.length*16+30)+"px'><div class='bg sub'></div><div class='hd'>"+g.title+"</div><div class='kvs'>";
   for(var r=0;r<g.rows.length;r++){
    var row=g.rows\[r]; var ed=(row\[2]&&role.admin>=row\[2]); var isE=(editing&&editing.key===row\[0]);
    h+="<div class='kv"+(ed?' ed':'')+(isE?' editing':'')+"' data-key='"+row\[0]+"'><div class='pl plate'></div><span class='k'>"+row\[1]+"</span><span class='v'>";
    if(isE){ if(row\[3]==='bool'){ var cur=(sdata\[row\[0]]||'').toLowerCase()==='on'; h+="<span class='o"+(cur?' on':'')+"' data-v='1'>on</span><span class='o"+(cur?'':' on')+"' data-v='0'>off</span>"; } else { h+="<input type='text' autocomplete='off' spellcheck='false' value='"+esc(editing.text)+"'>"; } }
    else h+=esc(sdata\[row\[0]]===undefined?'-':sdata\[row\[0]]);
    h+="</span></div>";
   }
   h+="</div></div>"; hs\[g.col]+=h;
  }
  cols\[0].innerHTML=hs\[0]; cols\[1].innerHTML=hs\[1];
  if(editing&&editing.kind!=='bool'){ var inp=document.querySelector('.kv.editing input'); if(inp){ inp.focus(); inp.select(); } }
 }
 function rowDef(key){ for(var gi=0;gi<SGROUPS.length;gi++){ var rows=SGROUPS\[gi].rows; for(var r=0;r<rows.length;r++){ if(rows\[r]\[0]===key) return rows\[r]; } } return null; }
 function rawOf(text){ return String(text).replace(/\[^0-9.-]/g,''); }
 function startEdit(key){ var d=rowDef(key); if(!d||!d\[2]||role.admin<d\[2]) return; editing={key:key,kind:d\[3],text:rawOf(sdata\[key]||'')}; renderStatus(); }
 function finishEdit(commit,value){
  if(!editing) return; var e=editing; editing=null;
  if(commit){ topic({adminpage:'setglob',k:e.key,v:value}); sdata\[e.key]='...'; }
  if(tab==='status') renderStatus();
 }
 document.getElementById('sc').addEventListener('click',function(e){
  var o=e.target.closest('.o'); if(o&&editing){ finishEdit(true,o.getAttribute('data-v')); focusMap(); return; }
  if(e.target.tagName==='INPUT') return;
  var kv=e.target.closest('.kv'); if(!kv) return; var key=kv.getAttribute('data-key');
  if(editing&&editing.key===key) return;
  if(editing) finishEdit(false);
  startEdit(key);
 });
 document.getElementById('sc').addEventListener('keydown',function(e){
  if(e.target.tagName!=='INPUT'||!editing) return;
  if(e.key==='Enter'){ var v=e.target.value.trim(); if(v.length&&!isNaN(+v)) finishEdit(true,v); else finishEdit(false); focusMap(); e.preventDefault(); }
  else if(e.key==='Escape'){ finishEdit(false); focusMap(); e.preventDefault(); }
 });
 document.addEventListener('contextmenu',function(e){ e.preventDefault(); });
 buildListPane('cmd'); buildListPane('map');
 for(var li=0;li<lists.length;li++) bindList(lists\[li]);
 footer();
 setInterval(function(){ if(live&&!collapsed){ topic({adminpage:'tick',st:(tab==='status')?1:0}); } if(tab==='fav'&&recent.length){ var ags=document.querySelectorAll('#l_rec .ago'); for(var i=0;i<ags.length&&i<recent.length;i++) ags.item(i).textContent=ago(recent\[i].at); } },2000);
 function boot(){ live=true; layout(); topic({adminpage:'ready'}); }
 if(window.BYOND){ boot(); } else { window.addEventListener('byond-ready',boot); }
 if(PREVIEW){
  setRole(4,1);
  setCommands('Admin-Teleport|admin|PLAYERS|player;Teleport-To|admin|PLAYERS|player;Teleport-Home|admin|PLAYERS|player;Summon-Player|admin|PLAYERS|player;Set-Spawn-Point|admin|WORLD|;Telepathy-Toggle|admin|DEBUG|;Reboot-Warning|admin|EVENTS|text;Toggle-Weather|admin|ENV|choice:clear/rain/storm;Set-Era|admin|WORLD|num;Spawn-Item|admin|WORLD|text;Create-Zone|mapper|ZONES|;Zone-Settings|mapper|ZONES|;Surface-Set-Profile|mapper|SURFACES|choice:grass/stone/wood;Export-Map-Region|mapper|PREFABS|;Edge-Debug|mapper|DEBUG|;Enter-Studio|mapper|BUILD|;Bookmark-Here|mapper|BUILD|');
  setPlayers('Seraphine|Kaidos|Valdiel');
  setFavs('Admin-Teleport|Summon-Player|Reboot-Warning|Toggle-Weather|Set-Era|Spawn-Item');
  setRecent('Admin-Teleport|Seraphine|2;Toggle-Weather|storm|9;Summon-Player|Kaidos|14');
  setFooter('x:118;y:64;z:1;cpu:3.2%25;era:4;day:212');
  setStatus('coords:118%2C%2064%2C%201;cpu:3.2%20(11%25);era:4;days:212;daycheck:04%3A00%3A00;potdaily:1;dead:40%2C%2040%2C%203;voidspawn:12%2C%2088%2C%205;voids:on;voidchance:15%25;getup:1x;rppdaily:1%2C200;rppstart:3%2C000;rppdays:3d;costincome:250%20%2F%2080;mana:100;base:1%2C000;queue:1.25x;world:1.0x;acc:85%25;whiff:5%25;melee:1.0x;item:1.0x;autohit:1.0x;proj:1.0x;exponent:0.3;scale:1;kval:10;intim:500x;ticks:4%2C410;tickusage:11%25');
  sel.cmd='Admin-Teleport'; vals\['Admin-Teleport']=\['Seraphine']; renderList('cmd');
  setTimeout(function(){ if(!live){ setGeom(12,240,992,704,2,0.85,0,0,4000,3000); } },300);
 }
 </script></body></html>
"}

client/proc/AdminPageAllowed()
	return mob && (mob.Admin || mob.Mapper)

client/proc/AdminPageBoot()
	if(adminpage_booted) return
	adminpage_booted = 1
	if(prefs)
		var/g = getPref("adminGeom")
		if(istext(g) && length(g)) adminpage_geom = g
		adminpage_lock = getPref("adminLock") ? 1 : 0
		adminpage_fold = getPref("adminFold") ? 1 : 0
		var/t = getPref("adminTab")
		if(istext(t) && length(t)) adminpage_tab = t
		var/f = getPref("adminFavs")
		if(istext(f)) adminpage_favs = f
		var/r = getPref("adminRecent")
		if(istext(r)) adminpage_recent = r

client/proc/AdminPagePlace()
	var/list/r = PanelViewRect()
	if(!r) return
	var/x0 = r[1]
	var/y0 = r[2]
	var/x1 = r[3]
	var/y1 = r[4]
	var/z = r[5]
	adminpage_zoom = z
	adminpage_x0 = x0
	adminpage_y0 = y0
	var/vw = x1 - x0
	var/vh = y1 - y0
	var/x
	var/y
	var/w
	var/h
	if(adminpage_geom)
		var/list/g = splittext(adminpage_geom, ",")
		if(g.len == 4)
			var/gx = text2num(g[1]); var/gy = text2num(g[2]); var/gw = text2num(g[3]); var/gh = text2num(g[4])
			if(!isnull(gx) && !isnull(gy) && gw > 0 && gh > 0)
				x = x0 + round(gx * z); y = y0 + round(gy * z); w = round(gw * z); h = round(gh * z)
	if(!w || !h)
		w = 496 * z
		h = 352 * z
		x = x0 + 8 * z
		y = y1 - h - 84 * z
	if(w > vw) w = vw
	if(h > vh) h = vh
	if(x + w > x1) x = x1 - w
	if(y + h > y1) y = y1 - h
	if(x < x0) x = x0
	if(y < y0) y = y0
	adminpage_geom = "[(x - x0) / z],[(y - y0) / z],[w / z],[h / z]"
	winset(src, ADMINPAGE_CTL, "pos=[x],[y];size=[w]x[h]")
	src << output(list2params(list(x, y, w, h, z, chatpanel_opacity, x0, y0, x1, y1, adminpage_lock, adminpage_fold)), "[ADMINPAGE_CTL]:setGeom")

client/proc/AdminPageStoreGeom(gtext)
	var/list/g = splittext(gtext, ",")
	if(g.len != 4) return
	var/x = text2num(g[1]); var/y = text2num(g[2]); var/w = text2num(g[3]); var/h = text2num(g[4])
	if(isnull(x) || isnull(y) || !(w > 0) || !(h > 0)) return
	var/z = adminpage_zoom ? adminpage_zoom : 1
	adminpage_geom = "[(x - adminpage_x0) / z],[(y - adminpage_y0) / z],[w / z],[h / z]"
	setPref("adminGeom", adminpage_geom)

client/proc/AdminPageShow(tab)
	if(!AdminPageAllowed())
		src << "The admin panel is for admins and mappers."
		return
	AdminPageBoot()
	if(tab == "cmd" || tab == "fav" || tab == "status" || tab == "map") adminpage_tab = tab
	AdminPageSendAssets()
	winset(src, ADMINPAGE_CTL, "inner-background-color=transparent")
	src << browse(AdminPageHTML(), "window=[ADMINPAGE_CTL]")
	adminpage_open = 1
	AdminPagePlace()
	winset(src, ADMINPAGE_CTL, "is-visible=true")
	if(btn_admin) BtnHover(btn_admin, FALSE)

client/proc/AdminPageHide()
	adminpage_open = 0
	winset(src, ADMINPAGE_CTL, "is-visible=false")
	if(btn_admin) BtnHover(btn_admin, FALSE)

client/proc/AdminPageToggle(tab)
	if(adminpage_open) AdminPageHide()
	else AdminPageShow(tab)

client/proc/AdminPagePushAll()
	if(!mob) return
	src << output(list2params(list(mob.Admin, mob.Mapper ? 1 : 0)), "[ADMINPAGE_CTL]:setRole")
	AdminPageBuildCmds()
	ChatPanelPlayers(ADMINPAGE_CTL)
	src << output(list2params(list(adminpage_favs ? adminpage_favs : "")), "[ADMINPAGE_CTL]:setFavs")
	src << output(list2params(list(AdminPageRecentText())), "[ADMINPAGE_CTL]:setRecent")
	if(adminpage_tab) src << output(list2params(list(adminpage_tab, 1)), "[ADMINPAGE_CTL]:setTab")
	AdminPageTick(1)

client/proc/AdminPageBuildCmds()
	if(!mob) return
	var/list/out = list()
	var/list/seen = list()
	for(var/v in (mob.verbs + verbs))
		var/nm = "[v:name]"
		if(!length(nm)) continue
		if(v:hidden) continue
		var/path = "[v]"
		var/cat = "[v:category]"
		var/role = null
		if(findtext(path, "/mob/Mapper/") || cat == "Mapper") role = "mapper"
		else if(findtext(path, "/mob/Admin") || cat == "Admin") role = "admin"
		if(!role) continue
		var/id = replacetext(nm, " ", "-")
		if(seen[id]) continue
		seen[id] = 1
		var/list/a = CHATCMD_ARGS[id]
		var/g = CHATCMD_GROUP[id]
		if(!g) g = (role == "mapper") ? "BUILD" : "WORLD"
		out += "[id]|[role]|[g]|[islist(a) ? jointext(a, ",") : ""]"
	src << output(list2params(list(jointext(out, ";"))), "[ADMINPAGE_CTL]:setCommands")

client/proc/AdminPageFav(id, on)
	if(!istext(id) || !length(id)) return
	var/list/f = list()
	if(adminpage_favs)
		for(var/e in splittext(adminpage_favs, "|"))
			if(length(e) && e != id) f += e
	if(on) f += id
	adminpage_favs = jointext(f, "|")
	setPref("adminFavs", adminpage_favs)

client/proc/AdminPageRecord(id, arg)
	if(!istext(id) || !length(id)) return
	id = replacetext(replacetext(id, ";", " "), "|", " ")
	arg = replacetext(replacetext("[arg]", ";", " "), "|", " ")
	var/list/keep = list("[id]|[arg]|[world.realtime]")
	if(adminpage_recent)
		for(var/e in splittext(adminpage_recent, ";"))
			if(!length(e)) continue
			var/list/f = splittext(e, "|")
			if(f.len >= 2 && f[1] == id && f[2] == arg) continue
			keep += e
			if(keep.len >= 12) break
	adminpage_recent = jointext(keep, ";")
	setPref("adminRecent", adminpage_recent)

client/proc/AdminPageRecentText()
	if(!adminpage_recent) return ""
	var/list/out = list()
	for(var/e in splittext(adminpage_recent, ";"))
		var/list/f = splittext(e, "|")
		if(f.len < 3) continue
		var/t = text2num(f[3])
		var/mins = isnull(t) ? 0 : round((world.realtime - t) / 600)
		if(mins < 0) mins = 0
		out += "[f[1]]|[f[2]]|[mins]"
	return jointext(out, ";")

client/proc/AdminPageTick(st)
	if(!adminpage_open || !mob) return
	var/f = "x:[mob.x];y:[mob.y];z:[mob.z];cpu:[url_encode("[round(world.cpu, 0.1)]%")];era:[glob.progress.Era];day:[glob.progress.DaysOfWipe]"
	src << output(list2params(list(f)), "[ADMINPAGE_CTL]:setFooter")
	if(st) AdminPageStatus()

client/proc/AdminPageStatus()
	if(!adminpage_open || !mob) return
	var/list/s = list()
	s += "coords:" + url_encode("[mob.x], [mob.y], [mob.z]")
	s += "cpu:" + url_encode("[round(world.cpu, 0.1)] ([round(world.tick_usage)]%)")
	s += "era:[glob.progress.Era]"
	s += "days:[glob.progress.DaysOfWipe]"
	s += "daycheck:" + url_encode(time2text(glob.progress.WipeStart, "hh:mm:ss"))
	s += "potdaily:[glob.progress.PotentialDaily]"
	s += "dead:" + url_encode("[glob.DEATH_LOCATION[1]], [glob.DEATH_LOCATION[2]], [glob.DEATH_LOCATION[3]]")
	s += "voidspawn:" + url_encode("[glob.VOID_LOCATION[1]], [glob.VOID_LOCATION[2]], [glob.VOID_LOCATION[3]]")
	s += "voids:[glob.VoidsAllowed ? "on" : "off"]"
	s += "voidchance:" + url_encode("[glob.VoidChance]%")
	s += "getup:[glob.GetUpVar]x"
	s += "rppdaily:" + url_encode("[Commas(glob.progress.RPPDaily)]")
	s += "rppstart:" + url_encode("[Commas(glob.progress.RPPStarting)]")
	s += "rppdays:[glob.progress.RPPStartingDays]d"
	s += "costincome:" + url_encode("[Commas(glob.progress.EconomyCost)] / [Commas(glob.progress.EconomyIncome)]")
	s += "mana:" + url_encode("[Commas(glob.progress.EconomyMana)]")
	s += "base:" + url_encode("[Commas(glob.WorldBaseAmount)]")
	s += "queue:[glob.GLOBAL_QUEUE_DAMAGE]x"
	s += "world:[glob.WorldDamageMult]x"
	s += "acc:" + url_encode("[glob.WorldDefaultAcc]%")
	s += "whiff:" + url_encode("[glob.WorldWhiffRate]%")
	s += "melee:[glob.GLOBAL_MELEE_MULT]x"
	s += "item:[glob.GLOBAL_ITEM_DAMAGE_MULT]x"
	s += "autohit:[glob.AUTOHIT_GLOBAL_DAMAGE]x"
	s += "proj:[glob.PROJ_DAMAGE_MULT]x"
	s += "exponent:[glob.DMG_POWER_EXPONENT]"
	s += "scale:[glob.STRIKE_DAMAGE_SCALE]"
	s += "kval:[glob.STRIKE_MITIGATION_K]"
	s += "intim:[glob.INTIMRATIO]x"
	s += "ticks:" + url_encode("[Commas(glob.celestialObjectTicks)]")
	s += "tickusage:" + url_encode("[round(world.tick_usage)]%")
	src << output(list2params(list(jointext(s, ";"))), "[ADMINPAGE_CTL]:setStatus")

client/proc/AdminPageSetGlob(k, v)
	if(!mob || !mob.Admin) return
	var/n = text2num("[v]")
	if(isnull(n)) return
	var/lvl = mob.Admin
	var/label = null
	switch(k)
		if("potdaily")
			if(lvl < 4) return
			glob.progress.PotentialDaily = n
			label = "the daily potential rate"
		if("voids")
			if(lvl < 4) return
			glob.VoidsAllowed = n ? 1 : 0
			label = "voids allowed"
			if(glob.VoidsAllowed) world << "<font color='green'>Voiding from death has been enabled.</font>"
			else world << "<font color='red'>Voiding from death has been disabled.</font>"
		if("voidchance")
			if(lvl < 4) return
			glob.VoidChance = n
			label = "the void chance"
			world << "<font color='green'>Void Chance set to [n]%!</font color>"
		if("getup")
			if(lvl < 3) return
			glob.GetUpVar = n
			label = "the GetUpVar"
		if("rppdaily")
			if(lvl < 4) return
			glob.progress.RPPDaily = n
			label = "the daily RPP increment"
		if("rppstart")
			if(lvl < 3) return
			glob.progress.RPPStarting = n
			label = "the starting RPP value"
		if("rppdays")
			if(lvl < 3) return
			glob.progress.RPPStartingDays = n
			label = "the starting RPP days"
		if("base")
			if(lvl < 3) return
			glob.WorldBaseAmount = n
			for(var/mob/Players/P in players)
				P.Base = glob.WorldBaseAmount
			label = "the world base power"
		if("world")
			if(lvl < 3) return
			glob.WorldDamageMult = n
			label = "the global damage multiplier"
		if("acc")
			if(lvl < 3) return
			glob.WorldDefaultAcc = n
			label = "the default accuracy"
		if("whiff")
			if(lvl < 3) return
			glob.WorldWhiffRate = n
			label = "the whiff rate"
		if("exponent")
			if(lvl < 3) return
			glob.DMG_POWER_EXPONENT = n
			label = "the damage power exponent"
		if("scale")
			if(lvl < 3) return
			glob.STRIKE_DAMAGE_SCALE = n
			label = "the strike damage scale"
		if("kval")
			if(lvl < 3) return
			glob.STRIKE_MITIGATION_K = n
			label = "the strike mitigation K"
		else
			return
	Log("Admin", "[ExtractInfo(mob)] set [label] to [n] (admin panel).")
	AdminPageStatus()

client/proc/AdminPageInitButton()
	if(!mob || !(mob.Admin || mob.Mapper)) return
	if(btn_admin) return
	btn_admin = new('HUD/chatpanel/lc_admin.png')
	btn_admin.btn_id = "admin"
	shud_parts += btn_admin
	if(!(btn_admin in screen)) screen += btn_admin
	btn_admin_label = new
	btn_admin_label.maptext_width = 48
	btn_admin_label.SetText("Admin")
	btn_admin_label.pixel_x = -54
	btn_admin_label.pixel_y = 8
	btn_admin.label = btn_admin_label
	btn_admin.vis_contents += btn_admin_label
	RepositionTopStrip()

client/proc/AdminPageTopic(list/href_list)
	switch(href_list["adminpage"])
		if("ready")
			AdminPagePlace()
			AdminPagePushAll()
		if("geom")
			AdminPageStoreGeom(href_list["g"])
		if("lock")
			adminpage_lock = text2num(href_list["l"]) ? 1 : 0
			setPref("adminLock", adminpage_lock)
		if("fold")
			adminpage_fold = text2num(href_list["f"]) ? 1 : 0
			setPref("adminFold", adminpage_fold)
		if("tab")
			var/t = href_list["t"]
			if(t == "cmd" || t == "fav" || t == "status" || t == "map")
				adminpage_tab = t
				setPref("adminTab", t)
		if("fav")
			AdminPageFav(href_list["id"], text2num(href_list["on"]))
		if("used")
			AdminPageRecord(href_list["id"], href_list["arg"])
		if("tick")
			AdminPageTick(text2num(href_list["st"]))
		if("setglob")
			AdminPageSetGlob(href_list["k"], href_list["v"])
		if("players")
			ChatPanelPlayers(ADMINPAGE_CTL)
		if("cmds")
			AdminPageBuildCmds()

mob/Players/verb/AdminPage_Panel()
	set name = "Admin Panel"
	set category = "Utility"
	set hidden = 1
	client?.AdminPageToggle()
