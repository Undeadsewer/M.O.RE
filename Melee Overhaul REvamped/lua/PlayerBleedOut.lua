function PlayerBleedOut:_update_check_actions(t, dt)
	local input = self:_get_input()
	self._unit:camera():set_shaker_parameter("headbob", "amplitude", 0)
	self:_update_throw_grenade_timers(t, input)
	self:_update_reload_timers(t, dt, input)
	self:_update_melee_timers(t, input)
	self:_update_equip_weapon_timers(t, input)
	if input.btn_stats_screen_press then
		self._unit:base():set_stats_screen_visible(true)
	elseif input.btn_stats_screen_release then
		self._unit:base():set_stats_screen_visible(false)
	end
	self:_update_foley(t, input)
	local new_action
	new_action = new_action or self:_check_action_weapon_gadget(t, input)
	new_action = new_action or self:_check_action_weapon_firemode(t, input)
	new_action = new_action or self:_check_action_melee(t, input)
	new_action = new_action or self:_check_action_reload(t, input)
	new_action = new_action or self:_check_change_weapon(t, input)
	if not new_action then
		new_action = self:_check_action_primary_attack(t, input)
		self._shooting = new_action
	end
	new_action = new_action or self:_check_action_throw_grenade(t, input)
	new_action = new_action or self:_check_action_equip(t, input)
	new_action = new_action or self:_check_action_interact(t, input)
	new_action = new_action or self:_check_action_steelsight(t, input)
	PlayerCarry._check_use_item(self, t, input)
end