-- Defines the Global Function
if not _G.MeleeOptions then
	_G.MeleeOptions = {}
end
-- ]

-- Mod file paths for future references [
MeleeOptions._path = ModPath
MeleeOptions._opts_path = SavePath .. "melee_opts.txt"
MeleeOptions._opts = {}
-- ]

-- Various melee option variables [
MeleeOptions._notif = {
	id = "mel_rev_notif",
	version = "3.96a",
	title = "Melee Overhaul REvamped [ALPHA]  v",
	priority = 1,
	message1 = "\nThank you for installing M.O.RE!\nBugs will be common in the alpha stage!",
	message2 = "\n\n[Click to View M.O.RE Steam Group]"
}

MeleeOptions.effects = {
	"effects/payday2/particles/impacts/fallback_impact_pd2",
	"effects/payday2/particles/impacts/blood/blood_impact_a",
	"effects/payday2/particles/impacts/shotgun_explosive_round",
	"effects/particles/dest/security_camera_dest"
}

MeleeOptions.hand_warmers = {
	[1] = {Idstring("effects/particles/fire/small_light_fire"), 0},
	[2] = {Idstring("effects/payday2/particles/character/taser_hittarget"), 9},
	[3] = {Idstring("effects/payday2/particles/character/taser_stop"), 1},
	[4] = {Idstring("effects/payday2/particles/character/taser_thread"), 9},
	[5] = {Idstring("effects/payday2/particles/weapons/saw/sawing"), 0},
	[6] = {Idstring("effects/payday2/environment/drill"), 0},
	[7] = {Idstring("effects/payday2/environment/drill_jammed"), 0},
	[8] = {Idstring("effects/payday2/particles/character/flyes_plague"), 0},
	[9] = {Idstring("effects/payday2/particles/character/overkillpack/chains_eyes"), 0},
	[10] = {Idstring("effects/payday2/particles/character/overkillpack/hoxton_eyes"), 0}
}

MeleeOptions.load_fx = {
	"effects/payday2/particles/character/flyes_plague",
	"effects/payday2/particles/character/overkillpack/chains_eyes",
	"effects/payday2/particles/character/overkillpack/hoxton_eyes"
}

MeleeOptions.can_breach = {
	-- Doors
	"@ID08a33537c9d0673a@",
	"@ID18a7caca12899b38@",
	"@ID851f3239dec9d210@",
	"@ID622b34ce3cd1d3bb@",
	"@ID1d283db01fc4a72b@",
	"@IDcffcea35596d6b53@",
	
	-- Barricades
	"@IDb55faf1195846400@",
	"@IDb524e472a247f6ff@",
	"@IDb71bf75755b6181b@",
	"@IDe86b68a126c540da@",
	"@ID945dcbc3586178cd@"
}

MeleeOptions.breaching_tools = {
	"baseballbat",
	"barbed_wire",
	"dingdong",
	"fireaxe",
	"alien_maul",
	"mining_pick",
	"branding_iron"
}

MeleeOptions.melee_penalty = {
	["alien_maul"] = 0.95,
	["branding_iron"] = 0.95,
	["briefcase"] = 0.95,
	["croupier_rake"] = 0.9,
	["ding_dong"] = 0.9,
	["fireaxe"] = 0.9,
	["freedom"] = 0.9,
	["micstand"] = 0.9,
	["mining_pick"] = 0.9,
	["shovel"] = 0.95,
	["slot_lever"] = 0.9,
	["tomahawk"] = 0.90,
	["hockey"] = 0.95
}
-- ]

-- M.O.RE's PlayerStandard.lua settings (best not to touch...) [
MeleeOptions.equip_weapon_wanted = MeleeOptions.equip_weapon_wanted
MeleeOptions.switch_wanted = MeleeOptions.switch_wanted
MeleeOptions.switch_wanted_data = MeleeOptions.switch_wanted_data
MeleeOptions.last_melee_t = MeleeOptions.last_melee_t
MeleeOptions.unequip_weapon_expire_t = MeleeOptions.unequip_weapon_expire_t
MeleeOptions.in_melee_mode = MeleeOptions.in_melee_mode
MeleeOptions.auto_melee = MeleeOptions.auto_melee
MeleeOptions.flame_lhand = MeleeOptions.flame_lhand
MeleeOptions.flame_rhand = MeleeOptions.flame_rhand
MeleeOptions.effect_t = MeleeOptions.effect_t
MeleeOptions.not_first_strike = MeleeOptions.not_first_strike
MeleeOptions.gadgets = MeleeOptions.gadgets or {}
MeleeOptions.cop_explode = {t = {}}
MeleeOptions.cop_pager = {units = {}}
MeleeOptions.cop_decapitation = {
	t = {},
	interval = {},
	attack_data = {},
	ragdoll = {}
}
MeleeOptions.cop_taser = {}
MeleeOptions.grinder_t = MeleeOptions.grinder_t
MeleeOptions.drill_t = MeleeOptions.drill_t
-- ]

-- M.O.RE's Post-Required Script Locations [
MeleeOptions.HookFiles = {
	["lib/managers/menumanager"] = "lua/MenuManager.lua",
	["lib/units/enemies/cop/copbrain"] = "lua/CopBrain.lua",
	["lib/units/enemies/cop/copdamage"] = "lua/CopDamage.lua",
	["lib/managers/localizationmanager"] = "lua/LocalizationManager.lua",
	["lib/units/beings/player/states/playerbleedout"] = "lua/PlayerBleedOut.lua",
	["lib/units/beings/player/states/playerstandard"] = "lua/PlayerStandard.lua"
}
-- ]

-- Executes and calls such scripts [
if RequiredScript then
	local requiredScript = RequiredScript:lower()
	if MeleeOptions.HookFiles[requiredScript] then
		dofile( MeleeOptions._path .. MeleeOptions.HookFiles[requiredScript] )	
	end
end
-- ]