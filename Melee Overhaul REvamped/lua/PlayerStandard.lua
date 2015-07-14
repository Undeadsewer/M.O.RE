CloneClass( PlayerStandard )

function MeleeOptions:overwrite_functions()
	function PlayerStandard:_check_action_interact(t, input)
		local new_action, timer, interact_object
		local interaction_wanted = input.btn_interact_press
		if interaction_wanted then
			if GoonBase then
				if GoonBase.PushToInteract then
					if GoonBase.PushToInteract:IsEnabled() then
						if self:_interacting() and not GoonBase.PushToInteract:ShouldUseStopKey() then
							self:_interupt_action_interact()
							return
						end
					end
				end
			end
			if MeleeOptions._opts.interact_fix then
				if self:_interacting() then
					self:_interupt_action_interact()
					return
				end
			end
			local action_forbidden = self:chk_action_forbidden("interact") or self:_interacting() or self._unit:base():stats_screen_visible() or self._ext_movement:has_carry_restriction() or self:is_deploying() or self:_changing_weapon() or self:_is_throwing_grenade() or self:_on_zipline()
			if not action_forbidden then
				new_action, timer, interact_object = managers.interaction:interact(self._unit)
				if new_action then
					self:_play_interact_redirect(t, input)
				end
				if timer then
					new_action = true
					self._ext_camera:camera_unit():base():set_limits(80, 50)
					self:_start_action_interact(t, input, timer, interact_object)
				end
				new_action = new_action or self:_start_action_intimidate(t)
			end
		end
		if input.btn_interact_release then
			if GoonBase then
				if GoonBase.PushToInteract then
					if GoonBase.PushToInteract:IsEnabled() then
						local data = nil
						if managers.interaction and alive( managers.interaction:active_unit() ) then
							data = managers.interaction:active_unit():interaction().tweak_data
						end
						if GoonBase.PushToInteract:ShouldHoldInteraction( data ) then
							return
						end
					end
				else
					self:_interupt_action_interact()
				end
			elseif MeleeOptions._opts.interact_fix then
				return
			else
				self:_interupt_action_interact()
			end
		end
		return new_action
	end

	function PlayerStandard:_check_use_item(t, input)
		local new_action
		local action_wanted = input.btn_use_item_press
		if action_wanted then
			local action_forbidden = self._use_item_expire_t or self:_interacting() or self:_changing_weapon() or self:_is_throwing_grenade()
			if not action_forbidden and managers.player:can_use_selected_equipment(self._unit) then
				self:_start_action_use_item(t)
				new_action = true
			end
		end
		if input.btn_use_item_release then
			self:_interupt_action_use_item()
		end
		return new_action
	end

	function PlayerStandard:_check_action_equip(t, input)
		local new_action
		local selection_wanted = input.btn_primary_choice
		if selection_wanted then
			local action_forbidden = self:chk_action_forbidden("equip")
			action_forbidden = action_forbidden or not self._ext_inventory:is_selection_available(selection_wanted) or self._use_item_expire_t or self:_changing_weapon() or self:_interacting() or self:_is_throwing_grenade()
			if not action_forbidden then
				local new_action = not self._ext_inventory:is_equipped(selection_wanted)
				if new_action then
					if MeleeOptions.in_melee_mode then
						if not self._state_data.melee_repeat_expire_t then
							if t >= MeleeOptions.unequip_weapon_expire_t then
								self:_interupt_action_melee(t)
								self._change_weapon_data = {selection_wanted = selection_wanted}
								self:_start_action_equip_weapon(t)
							end
						else
							self._change_weapon_data = {selection_wanted = selection_wanted}
							MeleeOptions.switch_wanted_data = true
						end
					else
						self:_start_action_unequip_weapon(t, {selection_wanted = selection_wanted})
					end
				elseif not new_action and MeleeOptions.in_melee_mode then
					if not self._state_data.melee_repeat_expire_t then
						if t >= MeleeOptions.unequip_weapon_expire_t then
							self:_interupt_action_melee(t)
						end
					else
						MeleeOptions.switch_wanted = true
					end
				end
			end
		end
		return new_action
	end

	function PlayerStandard:_check_change_weapon(t, input)
		local new_action
		local action_wanted = input.btn_switch_weapon_press
		if action_wanted then
			local action_forbidden = self:chk_action_forbidden("equip")
			action_forbidden = action_forbidden or self._use_item_expire_t or self._change_item_expire_t
			action_forbidden = action_forbidden or self._unit:inventory():num_selections() == 1 or self:_changing_weapon() or self._use_item_expire_t or self:_interacting() or self:_is_throwing_grenade()
			if not action_forbidden then
				local data = {}
				data.next = true
				self._change_weapon_pressed_expire_t = t + 0.33
				if MeleeOptions.in_melee_mode then
					if not self._state_data.melee_repeat_expire_t then
						if t >= MeleeOptions.unequip_weapon_expire_t then
							self:_interupt_action_melee(t)
							self._change_weapon_data = {next = data.next}
							self:_start_action_equip_weapon(t)
						end
					else
						self._change_weapon_data = {next = data.next}
						MeleeOptions.switch_wanted_data = true
					end
				else
					self:_start_action_unequip_weapon(t, data)
				end
				new_action = true
			end
		end
		return new_action
	end
end

function PlayerStandard:_check_action_melee(t, input)
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local instant = tweak_data.blackmarket.melee_weapons[melee_entry].instant
	if MeleeOptions.melee_wanted and not self._state_data.melee_repeat_expire_t then
		MeleeOptions.melee_wanted = nil
		MeleeOptions.in_melee_mode = true
		MeleeOptions.unequip_weapon_expire_t = t + (self._equipped_unit:base():weapon_tweak_data().timers.unequip or 0.5) / self:_get_swap_speed_multiplier()
		self:_start_action_melee(t, input, instant)
		return true
	end
	if self._state_data.melee_attack_wanted then
		if not self._state_data.melee_attack_allowed_t then
			self._state_data.melee_attack_wanted = nil
			MeleeOptions.switch_wanted = true
			self:_do_action_melee(t, input)
		end
		return
	end
	if MeleeOptions._opts.push2hold_enabled then
		if input.btn_primary_attack_state then
			MeleeOptions.auto_melee = true
		elseif not input.btn_primary_attack_state then
			MeleeOptions.auto_melee = nil
		end
	end
	if MeleeOptions.in_melee_mode and not self._state_data.melee_repeat_expire_t and instant then
		MeleeOptions.equip_weapon_wanted = true
		MeleeOptions.in_melee_mode = nil
		MeleeOptions.last_melee_t = nil
		MeleeOptions.auto_melee = nil
		MeleeOptions.unequip_weapon_expire_t = nil
		self._state_data.melee_charge_wanted = nil
		self._state_data.melee_expire_t = nil
		self._state_data.melee_repeat_expire_t = nil
		self._state_data.melee_attack_allowed_t = nil
		self._state_data.melee_damage_delay_t = nil
		self._state_data.meleeing = nil
	end
	if MeleeOptions.switch_wanted and MeleeOptions.in_melee_mode and not self._state_data.melee_repeat_expire_t then
		MeleeOptions.switch_wanted = nil
		self:_interupt_action_melee(t)
	elseif MeleeOptions.switch_wanted_data and MeleeOptions.in_melee_mode and not self._state_data.melee_repeat_expire_t then
		MeleeOptions.switch_wanted_data = nil
		self:_interupt_action_melee(t)
		self:_start_action_equip_weapon(t)
	end
	if MeleeOptions.equip_weapon_wanted then
		MeleeOptions.equip_weapon_wanted = nil
		if self._running and not self._end_running_expire_t and not self.RUN_AND_SHOOT then
			self._ext_camera:play_redirect(self.IDS_START_RUNNING)
		end
	end
	if MeleeOptions.in_melee_mode and MeleeOptions.last_melee_t ~= nil then
		if (t >= MeleeOptions.last_melee_t) then
			if not instant then
				MeleeOptions.last_melee_t = nil
				self:_start_action_melee(t, input, instant)
			end
		end
	end
	local action_wanted = input.btn_melee_press or input.btn_melee_release or (input.btn_primary_attack_press and MeleeOptions.in_melee_mode) or (input.btn_primary_attack_state and MeleeOptions.in_melee_mode)
	if not action_wanted then
		return
	end
	if input.btn_melee_release and not MeleeOptions._opts.push2hold_enabled then
		if (MeleeOptions._opts.stamina_drain and managers.player:player_unit():movement()._stamina < ((tweak_data.blackmarket.melee_weapons[managers.blackmarket:equipped_melee_weapon()].stats.charge_time or 1) * 1.5)) then
			return
		end
		if MeleeOptions.melee_wanted and self._state_data.melee_repeat_expire_t  then
			MeleeOptions.melee_wanted = nil
			MeleeOptions.switch_wanted = true
		end
		if MeleeOptions.in_melee_mode and not self._state_data.melee_repeat_expire_t then
			if self._state_data.melee_attack_allowed_t then
				self._state_data.melee_attack_wanted = true
				return
			end
			MeleeOptions.switch_wanted = true
			self:_do_action_melee(t, input)
		end
		return
	end
	local action_forbidden = self:chk_action_forbidden("equip") or self._use_item_expire_t or self:_changing_weapon() or self:_interacting() or self:_is_throwing_grenade()
	if action_forbidden then
		return
	end
	if input.btn_melee_press then
		if not MeleeOptions._opts.push2hold_enabled then
			if (MeleeOptions._opts.stamina_drain and managers.player:player_unit():movement()._stamina < ((tweak_data.blackmarket.melee_weapons[managers.blackmarket:equipped_melee_weapon()].stats.charge_time or 1) * 1.5)) then
				return
			end
			if not MeleeOptions.in_melee_mode and not self._state_data.melee_attack_allowed_t then
				MeleeOptions.in_melee_mode = true
				MeleeOptions.unequip_weapon_expire_t = t + (self._equipped_unit:base():weapon_tweak_data().timers.unequip or 0.5) / self:_get_swap_speed_multiplier()
				self:_start_action_melee(t, input, instant)
				return true
			elseif MeleeOptions.in_melee_mode and self._state_data.melee_repeat_expire_t then
				MeleeOptions.switch_wanted = nil
				MeleeOptions.melee_wanted = true
			end
		end
		if MeleeOptions._opts.push2hold_enabled then
			if not MeleeOptions.in_melee_mode and not self._state_data.melee_repeat_expire_t then
				MeleeOptions.in_melee_mode = true
				MeleeOptions.unequip_weapon_expire_t = t + (self._equipped_unit:base():weapon_tweak_data().timers.unequip or 0.5) / self:_get_swap_speed_multiplier()
				self:_start_action_melee(t, input, instant)
				return true
			else
				if not self._state_data.melee_repeat_expire_t and t >= MeleeOptions.unequip_weapon_expire_t then
					self:_interupt_action_melee(t)
					return false
				elseif self._state_data.melee_repeat_expire_t then
					MeleeOptions.switch_wanted = true
				end
			end
		end
	end
	if not MeleeOptions._opts.push2hold_enabled then
		return
	end
	if (MeleeOptions._opts.stamina_drain and managers.player:player_unit():movement()._stamina < ((tweak_data.blackmarket.melee_weapons[managers.blackmarket:equipped_melee_weapon()].stats.charge_time or 1) * 1.5)) then
		return
	end
	if input.btn_primary_attack_press and MeleeOptions.in_melee_mode then
		MeleeOptions.in_melee_mode = true
		if not self._state_data.melee_repeat_expire_t then
			self:_do_action_melee(t, input)
			if not instant then
				MeleeOptions.last_melee_t = t + math.min(tweak_data.blackmarket.melee_weapons[melee_entry].repeat_expire_t, tweak_data.blackmarket.melee_weapons[melee_entry].expire_t)
			end
		end
	end
	if MeleeOptions.in_melee_mode and MeleeOptions.auto_melee and not self._state_data.melee_repeat_expire_t then
		self:_do_action_melee(t, input)
		if not instant then
			MeleeOptions.last_melee_t = t + math.min(tweak_data.blackmarket.melee_weapons[melee_entry].repeat_expire_t, tweak_data.blackmarket.melee_weapons[melee_entry].expire_t)
		end
	end
end

function PlayerStandard:_start_action_melee(t, input, instant)
	if not MeleeOptions.overwrite_function then
		MeleeOptions:overwrite_functions()
		MeleeOptions.overwrite_function = true
	end
	
	if self._equipped_unit:base()._has_gadget and not MeleeOptions.not_first_strike then
		MeleeOptions.gadgets[ self._equipped_unit:base()._factory_id ] = self._equipped_unit:base()._gadget_on or 0
	end
	
	for _, effect in ipairs(MeleeOptions.load_fx) do
		managers.dyn_resource:load(Idstring("effect"), Idstring(effect), DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)
	end
	
	self._equipped_unit:base():tweak_data_anim_stop("fire")
	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self._state_data.melee_charge_wanted = nil
	self._state_data.meleeing = true
	self._state_data.melee_start_t = nil
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local primary = managers.blackmarket:equipped_primary()
	local primary_id = primary.weapon_id
	local bayonet_id = managers.blackmarket:equipped_bayonet(primary_id)
	local bayonet_melee = false
	if bayonet_id and melee_entry == "weapon" and self._equipped_unit:base():selection_index() == 2 then
		bayonet_melee = true
	end
	if instant then
		self:_do_action_melee(t, input)
		return
	end
	self:_stance_entered()
	if self._state_data.melee_global_value then
		self._camera_unit:anim_state_machine():set_global(self._state_data.melee_global_value, 0)
	end
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	if not MeleeOptions.effect_t and MeleeOptions._opts.flame_melee_enabled and MeleeOptions.hand_warmers[MeleeOptions._opts.handy_fx or 1][2] ~= 0 then
		MeleeOptions.effect_t = t + MeleeOptions.hand_warmers[MeleeOptions._opts.handy_fx][2]
	end
	self._state_data.melee_global_value = tweak_data.blackmarket.melee_weapons[melee_entry].anim_global_param
	self._camera_unit:anim_state_machine():set_global(self._state_data.melee_global_value, 1)
	local current_state_name = self._camera_unit:anim_state_machine():segment_state(PlayerStandard.IDS_BASE)
	local attack_allowed_expire_t = tweak_data.blackmarket.melee_weapons[melee_entry].attack_allowed_expire_t or 0.15
	self._state_data.melee_attack_allowed_t = t + (current_state_name ~= PlayerStandard.IDS_MELEE_ATTACK_STATE and attack_allowed_expire_t or 0)
	if MeleeOptions.not_first_strike or current_state_name == PlayerStandard.IDS_MELEE_ATTACK_STATE then
		if not MeleeOptions._opts.silly_weapon_enabled then
			self._camera_unit:base():hide_weapon()
			self._camera_unit:base():spawn_melee_item()
		end
		self._ext_camera:play_redirect(PlayerStandard.IDS_MELEE_CHARGE)
		if MeleeOptions.auto_melee then
			if MeleeOptions._opts.loop_fix then
				self._unit:sound():stop()
			end
		end
		return
	end
	local offset
	if current_state_name == PlayerStandard.IDS_MELEE_EXIT_STATE then
		local segment_relative_time = self._camera_unit:anim_state_machine():segment_relative_time(PlayerStandard.IDS_BASE)
		offset = (1 - segment_relative_time) * 0.9
	end
	self._ext_camera:play_redirect(PlayerStandard.IDS_MELEE_ENTER, nil, offset)
end

function PlayerStandard:discharge_melee()
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local instant = tweak_data.blackmarket.melee_weapons[melee_entry].instant
	self:_do_action_melee(managers.player:player_timer():time(), nil, true)
	if not instant then
		MeleeOptions.last_melee_t = managers.player:player_timer():time()
	end
end

function PlayerStandard:_do_action_melee(t, input, skip_damage)
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local instant_hit = tweak_data.blackmarket.melee_weapons[melee_entry].instant
	local melee_damage_delay = tweak_data.blackmarket.melee_weapons[melee_entry].melee_damage_delay or 0
	local primary = managers.blackmarket:equipped_primary()
	local primary_id = primary.weapon_id
	local bayonet_id = managers.blackmarket:equipped_bayonet(primary_id)
	local bayonet_melee = false
	if instant_hit then
		self._state_data.meleeing = nil
	end
	if bayonet_id and self._equipped_unit:base():selection_index() == 2 then
		bayonet_melee = true
	end
	self._state_data.melee_expire_t = t + tweak_data.blackmarket.melee_weapons[melee_entry].expire_t
	self._state_data.melee_repeat_expire_t = t + math.min(tweak_data.blackmarket.melee_weapons[melee_entry].repeat_expire_t, tweak_data.blackmarket.melee_weapons[melee_entry].expire_t)
	if not instant_hit and not skip_damage then
		self._state_data.melee_damage_delay_t = t + math.min(melee_damage_delay, tweak_data.blackmarket.melee_weapons[melee_entry].repeat_expire_t)
	end
	local send_redirect = instant_hit and (bayonet_melee and "melee_bayonet" or "melee") or "melee_item"
	managers.network:session():send_to_peers_synched("play_distance_interact_redirect", self._unit, send_redirect)
	if self._state_data.melee_charge_shake then
		self._ext_camera:shaker():stop(self._state_data.melee_charge_shake)
		self._state_data.melee_charge_shake = nil
	end
	if instant_hit then
		local hit = skip_damage or self:_do_melee_damage(t, bayonet_melee)
		if hit then
			self._ext_camera:play_redirect(bayonet_melee and self.IDS_MELEE_BAYONET or self.IDS_MELEE)
		else
			self._ext_camera:play_redirect(bayonet_melee and self.IDS_MELEE_MISS_BAYONET or self.IDS_MELEE_MISS)
		end
	else
		self:_play_melee_sound(melee_entry, "hit_air")
		local state = self._ext_camera:play_redirect(PlayerStandard.IDS_MELEE_ATTACK)
		local anim_attack_vars = tweak_data.blackmarket.melee_weapons[melee_entry].anim_attack_vars
		if anim_attack_vars then
			self._camera_unit:anim_state_machine():set_parameter(state, anim_attack_vars[math.random(#anim_attack_vars)], 1)
		end
	end
	
	if MeleeOptions._opts.silly_weapon_enabled then
		self._camera_unit:base():unspawn_melee_item()
	end
	
	MeleeOptions.not_first_strike = true
	
	local can_flame
	local flame_melee_opt = MeleeOptions._opts.flame_melee_opt or 1
	if flame_melee_opt == 1 then
		can_flame = true
	end
	
	if MeleeOptions._opts.flame_melee_enabled and can_flame and MeleeOptions.in_melee_mode and not instant_hit then
		local lbone_hand = self._camera_unit:get_object(Idstring("a_weapon_left"))
		local rbone_hand = self._camera_unit:get_object(Idstring("a_weapon_right"))
		if MeleeOptions.effect_t and t >= MeleeOptions.effect_t then
			if MeleeOptions.hand_warmers[MeleeOptions._opts.handy_fx or 1][2] ~= 0 then
				MeleeOptions.effect_t = t + MeleeOptions.hand_warmers[MeleeOptions._opts.handy_fx or 1][2]
			else MeleeOptions.effect_t = nil end
			MeleeOptions.flame_lhand = World:effect_manager():spawn({effect = MeleeOptions.hand_warmers[MeleeOptions._opts.handy_fx or 1][1], parent = lbone_hand})
			MeleeOptions.flame_rhand = World:effect_manager():spawn({effect = MeleeOptions.hand_warmers[MeleeOptions._opts.handy_fx or 1][1], parent = rbone_hand})
		end
		if not MeleeOptions.flame_lhand then
			MeleeOptions.flame_lhand = World:effect_manager():spawn({effect = MeleeOptions.hand_warmers[MeleeOptions._opts.handy_fx or 1][1], parent = lbone_hand})
		end
		if not MeleeOptions.flame_rhand then
			MeleeOptions.flame_rhand = World:effect_manager():spawn({effect = MeleeOptions.hand_warmers[MeleeOptions._opts.handy_fx or 1][1], parent = rbone_hand})
		end
	end
end

function PlayerStandard:_interupt_action_melee(t)
	MeleeOptions.equip_weapon_wanted = true
	MeleeOptions.in_melee_mode = nil
	MeleeOptions.last_melee_t = nil
	MeleeOptions.unequip_weapon_expire_t = nil
	MeleeOptions.not_first_strike = nil
	self._state_data.melee_charge_wanted = nil
	self._state_data.melee_expire_t = nil
	self._state_data.melee_repeat_expire_t = nil
	self._state_data.melee_attack_allowed_t = nil
	self._state_data.melee_damage_delay_t = nil
	self._state_data.meleeing = nil
	self._unit:sound():play("interupt_melee", nil, false)
	if MeleeOptions._opts.push2hold_enabled then
		local speed_multiplier = self:_get_swap_speed_multiplier()
		local tweak_data = self._equipped_unit:base():weapon_tweak_data()
		self._equip_weapon_expire_t = (t or Application:time()) + (tweak_data.timers.equip or 0.7) / speed_multiplier
		self._ext_camera:play_redirect(self.IDS_EQUIP, speed_multiplier)
	end
	self._camera_unit:base():unspawn_melee_item()
	self._camera_unit:base():unspawn_grenade()
	self._camera_unit:base():unspawn_mask()
	self._camera_unit:base():show_weapon()
	World:effect_manager():fade_kill(MeleeOptions.flame_lhand)
	MeleeOptions.flame_lhand = nil
	World:effect_manager():fade_kill(MeleeOptions.flame_rhand)
	MeleeOptions.flame_rhand = nil
	MeleeOptions.effect_t = nil
	if self._state_data.melee_charge_shake then
		self._ext_camera:stop_shaker(self._state_data.melee_charge_shake)
		self._state_data.melee_charge_shake = nil
	end
	self:_stance_entered()
	
	if self._equipped_unit:base()._has_gadget then
		self._equipped_unit:base():set_gadget_on(MeleeOptions.gadgets[ self._equipped_unit:base()._factory_id ] or 0, true)
	end
end

function PlayerStandard:_update_melee_timers(t, input)
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local instant = tweak_data.blackmarket.melee_weapons[melee_entry].instant
	local lbone_hand = self._camera_unit:get_object(Idstring("a_weapon_left"))
	local rbone_hand = self._camera_unit:get_object(Idstring("a_weapon_right"))
	if MeleeOptions.in_melee_mode then
		local lerp_value = self:_get_melee_charge_lerp_value(t)
		self._camera_unit:anim_state_machine():set_parameter(PlayerStandard.IDS_MELEE_CHARGE_STATE, "charge_lerp", math.bezier({
			0,
			0,
			1,
			1
		}, lerp_value))
		if self._state_data.melee_charge_shake then
			self._ext_camera:shaker():set_parameter(self._state_data.melee_charge_shake, "amplitude", math.bezier({
				0,
				0,
				MeleeOptions._opts.shaking_enabled and 1 or 0,
				MeleeOptions._opts.shaking_enabled and 1 or 0
			}, lerp_value))
		end
		if MeleeOptions._opts.flame_melee_enabled and MeleeOptions._opts.flame_melee_opt == 3 and not instant then
			if lerp_value == 1 then
				if MeleeOptions.effect_t and t >= MeleeOptions.effect_t then
					if MeleeOptions.hand_warmers[MeleeOptions._opts.handy_fx or 1][2] ~= 0 then
						MeleeOptions.effect_t = t + MeleeOptions.hand_warmers[MeleeOptions._opts.handy_fx or 1][2]
					else MeleeOptions.effect_t = nil end
					MeleeOptions.flame_lhand = World:effect_manager():spawn({effect = MeleeOptions.hand_warmers[MeleeOptions._opts.handy_fx or 1][1], parent = lbone_hand})
					MeleeOptions.flame_rhand = World:effect_manager():spawn({effect = MeleeOptions.hand_warmers[MeleeOptions._opts.handy_fx or 1][1], parent = rbone_hand})
				end
				if not MeleeOptions.flame_lhand then
					MeleeOptions.flame_lhand = World:effect_manager():spawn({effect = MeleeOptions.hand_warmers[MeleeOptions._opts.handy_fx or 1][1], parent = lbone_hand})
				end
				if not MeleeOptions.flame_rhand then
					MeleeOptions.flame_rhand = World:effect_manager():spawn({effect = MeleeOptions.hand_warmers[MeleeOptions._opts.handy_fx or 1][1], parent = rbone_hand})
				end
			else
				World:effect_manager():fade_kill(MeleeOptions.flame_lhand)
				MeleeOptions.flame_lhand = nil
				World:effect_manager():fade_kill(MeleeOptions.flame_rhand)
				MeleeOptions.flame_rhand = nil
				MeleeOptions.effect_t = nil
			end
		end
		if MeleeOptions._opts.silly_weapon_enabled then
			self._camera_unit:base():unspawn_melee_item()
			if MeleeOptions._opts.silly_weapon_opt == 1 then
				self._camera_unit:base():show_weapon()
			elseif MeleeOptions._opts.silly_weapon_opt == 2 then
				self._camera_unit:base():spawn_grenade()
			elseif MeleeOptions._opts.silly_weapon_opt == 3 then
				self._camera_unit:base():spawn_mask()
			end
		end
		if MeleeOptions._opts.silly_weapon_enabled and MeleeOptions._opts.silly_weapon_opt ~= 1 then
			self._camera_unit:base():hide_weapon()
		end
	end
	local can_flame
	local flame_melee_opt = MeleeOptions._opts.flame_melee_opt or 1
	if flame_melee_opt == 2 then
		can_flame = true
	end
	if MeleeOptions._opts.flame_melee_enabled and can_flame and not instant and MeleeOptions.in_melee_mode then
		if MeleeOptions.effect_t and t >= MeleeOptions.effect_t then
			if MeleeOptions.hand_warmers[MeleeOptions._opts.handy_fx or 1][2] ~= 0 then
				MeleeOptions.effect_t = t + MeleeOptions.hand_warmers[MeleeOptions._opts.handy_fx or 1][2]
			else MeleeOptions.effect_t = nil end
			MeleeOptions.flame_lhand = World:effect_manager():spawn({effect = MeleeOptions.hand_warmers[MeleeOptions._opts.handy_fx or 1][1], parent = lbone_hand})
			MeleeOptions.flame_rhand = World:effect_manager():spawn({effect = MeleeOptions.hand_warmers[MeleeOptions._opts.handy_fx or 1][1], parent = rbone_hand})
		end
		if not MeleeOptions.flame_lhand then
			MeleeOptions.flame_lhand = World:effect_manager():spawn({effect = MeleeOptions.hand_warmers[MeleeOptions._opts.handy_fx or 1][1], parent = lbone_hand})
		end
		if not MeleeOptions.flame_rhand then
			MeleeOptions.flame_rhand = World:effect_manager():spawn({effect = MeleeOptions.hand_warmers[MeleeOptions._opts.handy_fx or 1][1], parent = rbone_hand})
		end
	end
	if self._state_data.melee_damage_delay_t and t >= self._state_data.melee_damage_delay_t then
		self:_do_melee_damage(t)
		self._state_data.melee_damage_delay_t = nil
	end
	if self._state_data.melee_attack_allowed_t and t >= self._state_data.melee_attack_allowed_t then
		self._state_data.melee_start_t = t
		local melee_entry = managers.blackmarket:equipped_melee_weapon()
		local melee_charge_shaker = tweak_data.blackmarket.melee_weapons[melee_entry].melee_charge_shaker or "player_melee_charge"
		self._state_data.melee_charge_shake = self._ext_camera:play_shaker(melee_charge_shaker, 0)
		self._state_data.melee_attack_allowed_t = nil
	end
	if self._state_data.melee_repeat_expire_t and t >= self._state_data.melee_repeat_expire_t then
		self._state_data.melee_repeat_expire_t = nil
		local melee_entry = managers.blackmarket:equipped_melee_weapon()
		local instant_hit = tweak_data.blackmarket.melee_weapons[melee_entry].instant
		self._state_data.melee_charge_wanted = not instant_hit and true
	end
end

Hooks:PreHook( PlayerStandard , "_update_check_actions" , "MeleeOptionsThrowGrenade" , function( self , t , dt )

	local input = self:_get_input()

	local action_wanted = input.btn_throw_grenade_press
	
	if MeleeOptions.grenade_switch and t >= self._state_data.throw_grenade_expire_t then
		MeleeOptions.grenade_switch = nil
		MeleeOptions.unequip_weapon_expire_t = t + (self._equipped_unit:base():weapon_tweak_data().timers.unequip or 0.5) / self:_get_swap_speed_multiplier()
		MeleeOptions.in_melee_mode = true
		self:_start_action_melee(t, input, tweak_data.blackmarket.melee_weapons[managers.blackmarket:equipped_melee_weapon()].instant)
	end
	
	if not action_wanted then
		return
	end
	if not managers.player:can_throw_grenade() then
		return
	end
	local action_forbidden = not PlayerBase.USE_GRENADES or self:chk_action_forbidden("interact") or self._unit:base():stats_screen_visible() or self:_is_throwing_grenade() or self:_interacting() or self:is_deploying() or self:_changing_weapon() or self:_is_using_bipod()
	if action_forbidden then
		return
	end
	if MeleeOptions.in_melee_mode then
		self:_interupt_action_melee( t )
		self:_start_action_throw_grenade( t, input )
		MeleeOptions.grenade_switch = true
	end
	return action_wanted

end )

Hooks:PostHook( PlayerStandard , "_do_action_melee" , "MeleeOptionsStaminaDrain" , function( self , t , input , skip_damage )

	if not MeleeOptions._opts.stamina_drain then
		return
	end
	
	if not MeleeOptions.in_melee_mode then
		return
	end
	
	local charge_time = tweak_data.blackmarket.melee_weapons[managers.blackmarket:equipped_melee_weapon()].stats.charge_time
	local lerp_value = self:_get_melee_charge_lerp_value(t) + 1
	
	managers.player:player_unit():movement():subtract_stamina(charge_time * lerp_value * 1.5)
	managers.player:player_unit():movement()._regenerate_timer = (tweak_data.player.movement_state.stamina.REGENERATE_TIME or 5) * managers.player:upgrade_value("player", "stamina_regen_timer_multiplier", 1)

end )

Hooks:RegisterHook( "MORE_PlayerStandardPreGetMaxWalkSpeed" )
function PlayerStandard._get_max_walk_speed(self, t)
	local r = Hooks:ReturnCall( "MORE_PlayerStandardPreGetMaxWalkSpeed", self, t )
	if r ~= nil then
		return r
	end
	return self.orig._get_max_walk_speed(self, t)
end

Hooks:Add( "MORE_PlayerStandardPreGetMaxWalkSpeed", "MeleeOptionsMeleeSpeed", function( self , t )

	if not MeleeOptions.in_melee_mode then
		return nil
	end
	
	if not MeleeOptions._opts.melee_weight then
		return nil
	end
	
	local speed_tweak = self._tweak_data.movement.speed
	local movement_speed = speed_tweak.STANDARD_MAX
	local speed_state = "walk"
	if self._state_data.in_steelsight and not managers.player:has_category_upgrade("player", "steelsight_normal_movement_speed") then
		movement_speed = speed_tweak.STEELSIGHT_MAX
		speed_state = "steelsight"
	elseif self:on_ladder() then
		movement_speed = speed_tweak.CLIMBING_MAX
		speed_state = "climb"
	elseif self._state_data.ducking then
		movement_speed = speed_tweak.CROUCHING_MAX
		speed_state = "crouch"
	elseif self._state_data.in_air then
		movement_speed = speed_tweak.INAIR_MAX
		speed_state = nil
	elseif self._running then
		movement_speed = speed_tweak.RUNNING_MAX
		speed_state = "run"
	end
	local morale_boost_bonus = self._ext_movement:morale_boost()
	local multiplier = managers.player:movement_speed_multiplier(speed_state, speed_state and morale_boost_bonus and morale_boost_bonus.move_speed_bonus)
	local apply_weapon_penalty = true
	if MeleeOptions.in_melee_mode then
		local melee_entry = managers.blackmarket:equipped_melee_weapon()
		return movement_speed * (MeleeOptions.melee_penalty[melee_entry] or 1)
	end

end )

Hooks:RegisterHook("PlayerStandardPostDoMeleeDamage")
function PlayerStandard._do_melee_damage(self, t, bayonet_melee)
	self.orig._do_melee_damage(self, t, bayonet_melee)
	Hooks:Call("PlayerStandardPostDoMeleeDamage", self, t, bayonet_melee)
end

Hooks:Add("PlayerStandardPostDoMeleeDamage", "MeleeOptionsBreach", function(self, t, bayonet_melee)

	local melee_entry = managers.blackmarket:equipped_melee_weapon()

	local range = tweak_data.blackmarket.melee_weapons[melee_entry].stats.range or 175
	local from = self._unit:movement():m_head_pos()
	local to = from + self._unit:movement():m_head_rot():y() * range
	local sphere_cast_radius = 20

	local col_ray = self._unit:raycast("ray", from, to, "slot_mask", self._slotmask_bullet_impact_targets, "sphere_cast_radius", sphere_cast_radius, "ray_type", "body melee")
	if col_ray then
		local hit_unit = col_ray.unit
		local breach_unit = hit_unit:name():t()
		--log("[M.O.RE] Unit = " .. breach_unit)
		for _, value in ipairs(MeleeOptions.breaching_tools) do
			if value == melee_entry then
				for _, value in ipairs(MeleeOptions.can_breach) do
					if value == breach_unit then
						InstantBulletBase:on_collision(col_ray, managers.player:player_unit(), managers.player:player_unit(), 1)
						managers.hud:on_hit_confirmed()
					end
				end
			end
		end
		if melee_entry == "weapon" and Utils:IsCurrentWeapon( "saw" ) then
			SawHit:on_collision(col_ray, managers.player:player_unit(), managers.player:player_unit(), 999)
		end
	end
end)

Hooks:Add("PlayerStandardPostDoMeleeDamage", "MeleeOptionsDrillRepair", function(self, t, bayonet_melee)

	if MeleeOptions._opts.extras_enabled and MeleeOptions._opts.repair_enabled then
	
		if not MeleeOptions._opts.repair_sync_enabled and not Global.game_settings.single_player then
			return
		end
		
		if not MeleeOptions._opts.bypass_repair and managers.skilltree:skill_step("hardware_expert") == 0 and managers.skilltree:skill_step("drill_expert") == 0 and managers.skilltree:skill_step("silent_drilling") == 0 then
			return
		end
		
		local hardware_expert = ((managers.skilltree:skill_step("hardware_expert") >= 1 and 0.04) or 0) + ((managers.skilltree:skill_step("hardware_expert") == 2 and 0.06) or 0)
		local drill_expert = ((managers.skilltree:skill_step("drill_expert") >= 1 and 0.04) or 0) + ((managers.skilltree:skill_step("drill_expert") == 2 and 0.06) or 0)
		local silent_drilling = ((managers.skilltree:skill_step("silent_drilling") >= 1 and 0.04) or 0) + ((managers.skilltree:skill_step("silent_drilling") == 2 and 0.06) or 0)
		
		local chance = (hardware_expert + drill_expert + silent_drilling) * ((self:_get_melee_charge_lerp_value(t) or 0) + 1)
		
		if MeleeOptions._opts.bypass_repair then
			chance = 0.3 * ((self:_get_melee_charge_lerp_value(t) or 0) + 1)
		end
		
		if chance == 0 then
			return
		end
		
		if MeleeOptions.drill_t == nil then
			MeleeOptions.drill_t = t
			
			if managers.interaction:active_unit() then
		
				local tweak_data = managers.interaction:active_unit():interaction().tweak_data
				if tweak_data == "drill_jammed" or tweak_data == "lance_jammed" or tweak_data == "huge_lance_jammed" then
					managers.hud:on_hit_confirmed()
					if chance >= math.rand(1) then
						managers.interaction:active_unit():interaction():interact(managers.player:player_unit())
					end
				end
				
			end
			return
		end
		
		if (t - MeleeOptions.drill_t) < 1 then
			return
		end
		
		if managers.interaction:active_unit() then
			MeleeOptions.drill_t = t
		
			local tweak_data = managers.interaction:active_unit():interaction().tweak_data
			if tweak_data == "drill_jammed" or tweak_data == "lance_jammed" or tweak_data == "huge_lance_jammed" then
				managers.hud:on_hit_confirmed()
				if chance >= math.rand(1) then
					managers.interaction:active_unit():interaction():interact(managers.player:player_unit())
				end
			end
			
		end
	
	end

end)

Hooks:Add("PlayerStandardPostDoMeleeDamage", "MeleeOptionsEffects", function(self, t, bayonet_melee)

	if not MeleeOptions._opts.effects_enabled then
		return
	end
	
	local melee_entry = managers.blackmarket:equipped_melee_weapon()

	local range = tweak_data.blackmarket.melee_weapons[melee_entry].stats.range or 175
	local from = self._unit:movement():m_head_pos()
	local to = from + self._unit:movement():m_head_rot():y() * range
	local sphere_cast_radius = 20
	
	local col_ray = self._unit:raycast("ray", from, to, "slot_mask", self._slotmask_bullet_impact_targets, "sphere_cast_radius", sphere_cast_radius, "ray_type", "body melee")
	
	local melee_effect = "effects/payday2/particles/impacts/fallback_impact_pd2"
	
	if MeleeOptions._opts.effect then
		melee_effect = MeleeOptions.effects[MeleeOptions._opts.effect]
	end
	
	if col_ray then
		managers.game_play_central:play_impact_sound_and_effects({
			col_ray = col_ray,
			effect = Idstring(melee_effect),
			no_decal = true,
			no_sound = true
		})
	end

end)

function PlayerStandard:_start_action_use_item(t)
	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self:_interupt_action_running(t)
	local deploy_timer = managers.player:selected_equipment_deploy_timer()
	self._use_item_expire_t = t + deploy_timer
	if not MeleeOptions.in_melee_mode then
		self._ext_camera:play_redirect(self.IDS_UNEQUIP)
		self._equipped_unit:base():tweak_data_anim_play("unequip")
	end
	managers.hud:show_progress_timer_bar(0, deploy_timer)
	local text = managers.player:selected_equipment_deploying_text() or managers.localization:text("hud_deploying_equipment", {
		EQUIPMENT = managers.player:selected_equipment_name()
	})
	managers.hud:show_progress_timer({text = text, icon = nil})
	local post_event = managers.player:selected_equipment_sound_start()
	if post_event then
		self._unit:sound_source():post_event(post_event)
	end
	local equipment_id = managers.player:selected_equipment_id()
	managers.network:session():send_to_peers_synched("sync_teammate_progress", 2, true, equipment_id, deploy_timer, false)
end

function PlayerStandard:_interupt_action_use_item(t, input, complete)
	if self._use_item_expire_t then
		self._use_item_expire_t = nil
		local tweak_data = self._equipped_unit:base():weapon_tweak_data()
		self._equip_weapon_expire_t = managers.player:player_timer():time() + (tweak_data.timers.equip or 0.7)
		if not MeleeOptions.in_melee_mode then
			local result = self._ext_camera:play_redirect(self.IDS_EQUIP)
			self._equipped_unit:base():tweak_data_anim_stop("unequip")
		end
		managers.hud:hide_progress_timer_bar(complete)
		managers.hud:remove_progress_timer()
		local post_event = managers.player:selected_equipment_sound_interupt()
		if not complete and post_event then
			self._unit:sound_source():post_event(post_event)
		end
		self._unit:equipment():on_deploy_interupted()
		managers.network:session():send_to_peers_synched("sync_teammate_progress", 2, false, "", 0, complete and true or false)
	end
end

function PlayerStandard:_start_action_running(t)
	if not self._move_dir then
		self._running_wanted = true
		return
	end
	if self:on_ladder() or self:_on_zipline() then
		return
	end
	if MeleeOptions._opts.extras_enabled and (MeleeOptions._opts.sprint == nil or MeleeOptions._opts.sprint == 1) and MeleeOptions.in_melee_mode then
		self._running_wanted = true
		return
	end
	if MeleeOptions._opts.extras_enabled and MeleeOptions._opts.sprint == 3 and MeleeOptions.in_melee_mode and not self.RUN_AND_SHOOT then
		self._running_wanted = true
		return
	end
	if self._shooting and not self.RUN_AND_SHOOT or self:_changing_weapon() or self._use_item_expire_t or self._state_data.in_air or self:_is_throwing_grenade() then
		self._running_wanted = true
		return
	end
	if self._state_data.ducking and not self:_can_stand() then
		self._running_wanted = true
		return
	end
	if not self:_can_run_directional() then
		return
	end
	self._running_wanted = false
	if managers.player:get_player_rule("no_run") then
		return
	end
	if not self._unit:movement():is_above_stamina_threshold() then
		return
	end
	if (not self._state_data.shake_player_start_running or not self._ext_camera:shaker():is_playing(self._state_data.shake_player_start_running)) and managers.user:get_setting("use_headbob") then
		self._state_data.shake_player_start_running = self._ext_camera:play_shaker("player_start_running", 0.75)
	end
	self:set_running(true)
	self._end_running_expire_t = nil
	self._start_running_t = t
	if not self:_is_reloading() or not self.RUN_AND_RELOAD then
		if not self.RUN_AND_SHOOT then
			if MeleeOptions.in_melee_mode then
			else
				self._ext_camera:play_redirect(self.IDS_START_RUNNING)
			end
		else
			if MeleeOptions.in_melee_mode then
			else
				self._ext_camera:play_redirect(self.IDS_IDLE)
			end
		end
	end
	if not self.RUN_AND_RELOAD then
		self:_interupt_action_reload(t)
	end
	self:_interupt_action_steelsight(t)
	self:_interupt_action_ducking(t)
end

function PlayerStandard:_end_action_running(t)
	if not self._end_running_expire_t then
		local speed_multiplier = self._equipped_unit:base():exit_run_speed_multiplier()
		self._end_running_expire_t = t + 0.4 / speed_multiplier
		if not self.RUN_AND_SHOOT and (not self.RUN_AND_RELOAD or not self:_is_reloading()) then
			if MeleeOptions.in_melee_mode then
			else
				self._ext_camera:play_redirect(self.IDS_STOP_RUNNING, speed_multiplier)
			end
		end
	end
end

function PlayerStandard:_start_action_interact(t, input, timer, interact_object)
	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self:_interupt_action_running(t)
	self._interact_expire_t = t + timer
	self._interact_params = {
		object = interact_object,
		timer = timer,
		tweak_data = interact_object:interaction().tweak_data
	}
	if not MeleeOptions.in_melee_mode then
		self._ext_camera:play_redirect(self.IDS_UNEQUIP)
		self._equipped_unit:base():tweak_data_anim_play("unequip")
	end
	managers.hud:show_interaction_bar(0, timer)
	managers.network:session():send_to_peers_synched("sync_teammate_progress", 1, true, self._interact_params.tweak_data, timer, false)
end

function PlayerStandard:_interupt_action_interact(t, input, complete)
	if self._interact_expire_t then
		self._interact_expire_t = nil
		if alive(self._interact_params.object) then
			self._interact_params.object:interaction():interact_interupt(self._unit, complete)
		end
		self._ext_camera:camera_unit():base():remove_limits()
		managers.interaction:interupt_action_interact(self._unit)
		managers.network:session():send_to_peers_synched("sync_teammate_progress", 1, false, self._interact_params.tweak_data, 0, complete and true or false)
		self._interact_params = nil
		local tweak_data = self._equipped_unit:base():weapon_tweak_data()
		self._equip_weapon_expire_t = managers.player:player_timer():time() + (tweak_data.timers.equip or 0.7)
		local result
		if not MeleeOptions.in_melee_mode then
			result = self._ext_camera:play_redirect(self.IDS_EQUIP)
			self._equipped_unit:base():tweak_data_anim_stop("unequip")
		end
		managers.hud:hide_interaction_bar(complete)
	end
end