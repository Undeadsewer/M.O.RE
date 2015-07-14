function MeleeOptions:view_changelog()
	Steam:overlay_activate("url", "http://steamcommunity.com/groups/PD2_MORE")
end

function MeleeOptions:Save(no_check)
	if not no_check and not self._opts.is_member then
		self._opts = {}
		self:DisplayNonMember(tostring(Steam:username()))
		return
	end
	local data = io.open( self._opts_path, "w+" )
	if data then
		data:write( json.encode( self._opts ) )
		data:close()
	end
end

function MeleeOptions:Load()
	local data = io.open( self._opts_path, "r" )
	if data then
		self._opts = json.decode( data:read("*all") )
		data:close()
	end
	
	-- Loads to default value when needed to be true. [[
	if self._opts.push2hold_enabled == nil then
		self._opts.push2hold_enabled = true
	end
	if self._opts.notification_enabled == nil then
		self._opts.notification_enabled = true
	end
	-- ]]
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_MeleeOptions", function(loc)
	loc:add_localized_strings({
		["bm_melee_bat"] = "Baseball Bat []",
		["bm_melee_baseballbat"] = "Lucille Baseball Bat []",
		["bm_melee_dingdong"] = "Ding Dong Breaching Tool []",
		["bm_melee_fireaxe"] = "Fireaxe []",
		["bm_melee_alien_maul"] = "Alpha Mauler []",
		["bm_melee_mining_pick"] = "Gold Fever []",
		["bm_melee_branding_iron"] = "You're Mine []"
	})

	loc:load_localization_file(MeleeOptions._path .. "loc/en.txt")
end)

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_MeleeOptions", function( menu_manager )
	
	MenuCallbackHandler.clbk_mel_tog_push2hold = function(self, item)
		MeleeOptions._opts.push2hold_enabled = (item:value() == "on" and true or false)
		MeleeOptions:Save(true)
	end
	
	MenuCallbackHandler.clbk_mel_tog_notification = function(self, item)
		MeleeOptions._opts.notification_enabled = (item:value() == "on" and true or false)
		MeleeOptions:Save(true)
	end
	
	MenuCallbackHandler.clbk_mel_tog_effects = function(self, item)
		MeleeOptions._opts.effects_enabled = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_tog_blunt_force = function(self, item)
		MeleeOptions._opts.blunt_force_enabled = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_blunt_force_opt = function(self, item)
		MeleeOptions._opts.blunt_force_opt = item:value()
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_tog_superman = function(self, item)
		MeleeOptions._opts.superman_enabled = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_blunt_force_hit_sound = function(self, item)
		MeleeOptions._opts.blunt_force_hit_sound = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_tog_silly_weapon = function(self, item)
		MeleeOptions._opts.silly_weapon_enabled = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_tog_heat = function(self, item)
		MeleeOptions._opts.heat_enabled = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_heat_opt = function(self, item)
		MeleeOptions._opts.heat_opt = item:value()
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_heat_place_opt = function(self, item)
		MeleeOptions._opts.heat_place_opt = item:value()
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_effect = function(self, item)
		MeleeOptions._opts.effect = item:value()
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_force = function(self, item)
		MeleeOptions._opts.force_mul = item:value()
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_tog_flame_melee = function(self, item)
		MeleeOptions._opts.flame_melee_enabled = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_flame_melee_opt = function(self, item)
		MeleeOptions._opts.flame_melee_opt = item:value()
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_tog_cop_explode = function(self, item)
		MeleeOptions._opts.cop_explode_enabled = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_explode_force = function(self, item)
		MeleeOptions._opts.explode_force_mul = item:value()
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_cop_explode_opt = function(self, item)
		MeleeOptions._opts.cop_explode_opt = item:value()
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_tog_cop_explode_effects = function(self, item)
		MeleeOptions._opts.cop_explode_effects_enabled = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_tog_explode_contour = function(self, item)
		MeleeOptions._opts.explode_contour_enabled = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_tog_decapitation = function(self, item)
		MeleeOptions._opts.decapitation_enabled = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_decapitation_opt = function(self, item)
		MeleeOptions._opts.decapitation_opt = item:value()
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_decapitation_time = function(self, item)
		MeleeOptions._opts.decapitation_time = item:value()
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_decapitation_interval = function(self, item)
		MeleeOptions._opts.decapitation_interval = item:value()
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_tog_decapitation_twitch = function(self, item)
		MeleeOptions._opts.twitch_enabled = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_flame_melee_fx = function(self, item)
		MeleeOptions._opts.handy_fx = item:value()
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_silly_weapon_opt = function(self, item)
		MeleeOptions._opts.silly_weapon_opt = item:value()
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_tog_shake = function(self, item)
		MeleeOptions._opts.shaking_enabled = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_tog_callout = function(self, item)
		MeleeOptions._opts.callout_enabled = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_callout_chance = function(self, item)
		MeleeOptions._opts.callout_chance = item:value()
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_tog_more_extras = function(self, item)
		if item:value() == "on" then
			MeleeOptions:DisplayWarning(tostring(Steam:username()))
		else
			MeleeOptions._opts.extras_enabled = false
			MeleeOptions:Save()
		end
	end
	
	MenuCallbackHandler.clbk_mel_sprint = function(self, item)
		MeleeOptions._opts.sprint = item:value()
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_tog_pager = function(self, item)
		MeleeOptions._opts.pager_enabled = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_tog_headshots = function(self, item)
		MeleeOptions._opts.headshots_enabled = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_tog_repair = function(self, item)
		MeleeOptions._opts.repair_enabled = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_tog_pager_sync = function(self, item)
		MeleeOptions._opts.pager_sync_enabled = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_tog_headshots_sync = function(self, item)
		MeleeOptions._opts.headshots_sync_enabled = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_tog_repair_sync = function(self, item)
		MeleeOptions._opts.repair_sync_enabled = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_tog_buzzer = function(self, item)
		MeleeOptions._opts.buzzer_enabled = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_tog_buzzer_full = function(self, item)
		MeleeOptions._opts.buzzer_full_enabled = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_fix_loop = function(self, item)
		MeleeOptions._opts.loop_fix = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_fix_grinder = function(self, item)
		MeleeOptions._opts.grinder_fix = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_fix_interact = function(self, item)
		MeleeOptions._opts.interact_fix = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_tog_bypass_pager = function(self, item)
		MeleeOptions._opts.bypass_pager = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_tog_bypass_repair = function(self, item)
		MeleeOptions._opts.bypass_repair = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_real_drain = function(self, item)
		MeleeOptions._opts.stamina_drain = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	MenuCallbackHandler.clbk_mel_real_weight = function(self, item)
		MeleeOptions._opts.melee_weight = (item:value() == "on" and true or false)
		MeleeOptions:Save()
	end
	
	
	
	Steam:http_request("http://steamcommunity.com/gid/8773421/memberslistxml/?xml=1", MeleeOptions._on_group_received)
	
	MeleeOptions:Load()
	
	MenuHelper:LoadFromJsonFile(MeleeOptions._path .. "opt/MeleeOptions.txt", MeleeOptions, MeleeOptions._opts)
	MenuHelper:LoadFromJsonFile(MeleeOptions._path .. "opt/MeleeExtras.txt", MeleeOptions, MeleeOptions._opts)
	MenuHelper:LoadFromJsonFile(MeleeOptions._path .. "opt/MeleeBluntForceTrauma.txt", MeleeOptions, MeleeOptions._opts)
	MenuHelper:LoadFromJsonFile(MeleeOptions._path .. "opt/MeleeDecapitations.txt", MeleeOptions, MeleeOptions._opts)
	MenuHelper:LoadFromJsonFile(MeleeOptions._path .. "opt/MeleeEffects.txt", MeleeOptions, MeleeOptions._opts)
	MenuHelper:LoadFromJsonFile(MeleeOptions._path .. "opt/MeleeFixes.txt", MeleeOptions, MeleeOptions._opts)
	MenuHelper:LoadFromJsonFile(MeleeOptions._path .. "opt/MeleeHandyFX.txt", MeleeOptions, MeleeOptions._opts)
	MenuHelper:LoadFromJsonFile(MeleeOptions._path .. "opt/MeleeHeatOfTheMoment.txt", MeleeOptions, MeleeOptions._opts)
	MenuHelper:LoadFromJsonFile(MeleeOptions._path .. "opt/MeleeHumanTimeBombs.txt", MeleeOptions, MeleeOptions._opts)
	MenuHelper:LoadFromJsonFile(MeleeOptions._path .. "opt/MeleeRealism.txt", MeleeOptions, MeleeOptions._opts)
	MenuHelper:LoadFromJsonFile(MeleeOptions._path .. "opt/MeleeSilly.txt", MeleeOptions, MeleeOptions._opts)
	MenuHelper:LoadFromJsonFile(MeleeOptions._path .. "opt/MeleeCallouts.txt", MeleeOptions, MeleeOptions._opts)
	MenuHelper:LoadFromJsonFile(MeleeOptions._path .. "opt/MeleeMisc.txt", MeleeOptions, MeleeOptions._opts)
	
end)

function MeleeOptions:DisplayNonMember(username)
	local menu_title = "[" .. utf8.char(57363) .. "]" .. " ERROR: You're not a M.O.RE Member yet! :("
	local menu_message = "Greetings " .. username .. ",\n\nIt seems that you're not a member of the Melee Overhaul REvamped Steam Group yet. Joining the group gives exclusives to the mod including these cosmetic options!\n\nIf you just recently joined, the member list may take time to update!\n\nWhen you decide to join, please restart your game after joining! Please be patient, the member list takes some time to update before it registers you as a member.\n\nWould you like to join?"
	local menu_options = {
		[1] = {
			text = "Sure, take me to the group page!",
			callback = MeleeOptions.display_group_page,
		},
		[2] = {
			text = "No thanks.",
			is_cancel_button = true,
		},
	}
	local menu = QuickMenu:new( menu_title, menu_message, menu_options )
	menu:Show()
end

function MeleeOptions:DisplayWarning(username)
	local menu_title = "[" .. utf8.char(57364) .. "]" .. " WARNING: M.O.RE. Extras are enabling... " .. "[" .. utf8.char(57364) .. "]"
	local menu_message = "Hello again " .. username .. ",\n\nAs you already know, you are about to enable M.O.RE. extras.\n\nM.O.RE. Extras include the following:\n\n" .. utf8.char(1031) .. " Melee Headshots\n" .. utf8.char(1031) .. " Melee Sprinting (varies on Skill Requirement)\n" .. utf8.char(1031) .. " Pager Snatching (for Hidden Blade Aced and Shinobi Aced)\n" .. utf8.char(1031) .. " Melee Drill Repair (for Hardware Expert, Drill Sergeant, and Silent Drilling)\n\nThese features/mechanics were disabled by default since others might consider it as \"cheating\". When this is enabled, you are in risk of being called one yourself. Though the chances of being labelled a \"cheater\" are VERY low, this is only a fair warning.\n\nIf you decide to disable and re-enable this again, you will be prompted with this message again!\n\nNow with this warning in mind, would you like to enable M.O.RE. extras?"
	local menu_options = {
		[1] = {
			text = "Yes, enable M.O.RE. extras!",
			callback = MeleeOptions.enable_extras,
		},
		[2] = {
			text = "No, disable M.O.RE. extras.",
			is_cancel_button = true,
		},
	}
	local menu = QuickMenu:new( menu_title, menu_message, menu_options )
	menu:Show()
end

function MeleeOptions._on_group_received(success, page)
	if success and string.find(page, "<steamID64>" .. Steam:userid() .. "</steamID64>") then
		MeleeOptions._opts.is_member = true
		MeleeOptions:Save()
		MeleeOptions._notif.message1 = "\n[] Official M.O.RE Member (online)\n" .. MeleeOptions._notif.message1
	else
		MeleeOptions:Load()
		if MeleeOptions._opts.is_member == true then
			MeleeOptions._notif.message1 = "\n[] Official M.O.RE Member (offline)\n" .. MeleeOptions._notif.message1
			return
		else
			MeleeOptions._opts = {}
		end
	end
end

function MeleeOptions.display_group_page()
	Steam:overlay_activate("url", "http://steamcommunity.com/groups/PD2_MORE")
end

function MeleeOptions.enable_extras()
	MeleeOptions._opts.extras_enabled = true
	MeleeOptions:Save()
end

local open_url = open_url or function()
	MeleeOptions:view_changelog()
end

Hooks:Add("MenuManagerOnOpenMenu", "MenuManagerOnOpenMenu_MeleeOptions", function( menu_manager, menu, position )

	Steam:http_request("http://steamcommunity.com/gid/8773421/memberslistxml/?xml=1", MeleeOptions._on_group_received)

	if menu == "menu_main" and MeleeOptions._opts.notification_enabled then
		NotificationsManager:AddNotification( MeleeOptions._notif.id, MeleeOptions._notif.title .. MeleeOptions._notif.version, MeleeOptions._notif.message1 .. MeleeOptions._notif.message2, MeleeOptions._notif.priority, open_url )
	end

end)