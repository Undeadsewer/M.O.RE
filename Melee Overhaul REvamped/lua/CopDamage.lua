CloneClass( CopDamage )

Hooks:RegisterHook("CopDamagePostDamageMelee")

Hooks:PostHook( CopDamage, "damage_melee" , "MeleeOptionsPostHookCopDamage" , function( self , attack_data )

	Hooks:Call("CopDamagePostDamageMelee", self, attack_data)

end )

Hooks:Add("CopDamagePostDamageMelee", "MeleeOptionsCopExplosion", function(self, attack_data)

	if not MeleeOptions._opts.cop_explode_enabled then
		return
	end

	if self._dead then
		local t
		
		if MeleeOptions._opts.cop_explode_opt ~= 4 then
			t = MeleeOptions._opts.cop_explode_opt or 1
		elseif MeleeOptions._opts.cop_explode_opt == 4 then
			t = math.random(1,3)
		end
		
		if MeleeOptions.cop_explode then
			MeleeOptions.cop_explode.t[self._unit] = Application:time() + t
			if MeleeOptions._opts.explode_contour_enabled then
				self._unit:contour():add("mark_enemy")
				self._unit:contour():flash("mark_enemy", 0.15)
			end
		end
	end

end)

Hooks:Add("CopDamagePostDamageMelee", "MeleeOptionsBluntForceTrauma", function(self, attack_data)

	if not MeleeOptions._opts.blunt_force_enabled then
		return
	end
	
	local head = self._head_body_name and attack_data.col_ray.body and (tostring(attack_data.col_ray.body:name()) == "Idstring(@IDefb9de5ec58709d0@)" or tostring(attack_data.col_ray.body:name()) == "Idstring(@ID103b4a9c4e487706@)")
	
	local blunt_force_opt = MeleeOptions._opts.blunt_force_opt or 1
	local can_blunt_force
	
	if blunt_force_opt == 1 and head then
		can_blunt_force = true
	elseif blunt_force_opt == 2 and not head then
		can_blunt_force = true
	elseif blunt_force_opt == 3 then
		can_blunt_force = true
	end
	
	if self._dead and can_blunt_force and not managers.groupai:state():whisper_mode() then
		local melee_weapon = managers.blackmarket:equipped_melee_weapon()
		local melee_type = tweak_data.blackmarket.melee_weapons[melee_weapon].stats.weapon_type
		if melee_type == "blunt" or melee_weapon == "baseballbat" or melee_weapon == "barbedwire" then
			self._unit:movement():enable_update()
			self._unit:movement()._frozen = nil
			
			local hit_pos = mvector3.copy(self._unit:movement():m_pos())
			local attack_dir
			if MeleeOptions._opts.superman_enabled then
				attack_dir = hit_pos - attack_data.attacker_unit:movement():m_pos()
			else
				attack_dir = attack_data.attacker_unit:movement():m_head_rot():y()
			end
			if self._unit:movement()._active_actions[1] then
				self._unit:movement()._active_actions[1]:force_ragdoll()
			end
			local scale 
			if MeleeOptions._opts.superman_enabled then
				scale = 1
			else
				scale = MeleeOptions._opts.force_mul or 1
			end
			local height = mvector3.distance(hit_pos, self._unit:position()) - 100
			local twist_dir = math.random(2) == 1 and 1 or -1
			local rot_acc = (attack_dir:cross(math.UP) + math.UP * (0.5 * twist_dir)) * (-1000 * math.sign(height))
			local rot_time = 1 + math.rand(2)
			local nr_u_bodies = self._unit:num_bodies()
			local i_u_body = 0
			while nr_u_bodies > i_u_body do
				local u_body = self._unit:body(i_u_body)
				if u_body:enabled() and u_body:dynamic() then
					local body_mass = u_body:mass()
					World:play_physic_effect(Idstring("physic_effects/shotgun_hit"), u_body, Vector3(attack_dir.x, attack_dir.y, attack_dir.z + 0.5) * 600 * scale, 4 * body_mass / math.random(2), rot_acc, rot_time)
				end
				i_u_body = i_u_body + 1
			end
			if MeleeOptions._opts.blunt_force_hit_sound then
				managers.player:player_unit():sound():play("player_armor_gone_stinger")
			end
		end
	end

end)

Hooks:Add("CopDamagePostDamageMelee", "MeleeOptionsHotHeaded", function(self, attack_data)

	if not MeleeOptions._opts.heat_enabled then
		return
	end

	local head = self._head_body_name and attack_data.col_ray.body and (tostring(attack_data.col_ray.body:name()) == "Idstring(@IDefb9de5ec58709d0@)" or tostring(attack_data.col_ray.body:name()) == "Idstring(@ID103b4a9c4e487706@)")
	local bone_head = self._unit:get_object(Idstring("Head"))
	local bone_spine = self._unit:get_object(Idstring("Spine"))
	local bone_left_arm = self._unit:get_object(Idstring("LeftArm"))
	local bone_right_arm = self._unit:get_object(Idstring("RightArm"))
	local bone_left_leg = self._unit:get_object(Idstring("LeftLeg"))
	local bone_right_leg = self._unit:get_object(Idstring("RightLeg"))
	
	local heat_opt = MeleeOptions._opts.heat_opt or 1
	local heat_place_opt = MeleeOptions._opts.heat_place_opt or 1
	
	local can_flame
	
	if heat_opt == 1 and head then
		can_flame = true
	elseif heat_opt == 2 and not head then
		can_flame = true
	elseif heat_opt == 3 then
		can_flame = true
	end
	
	if self._dead and can_flame then
		
		managers.fire:start_burn_body_sound({
			enemy_unit = self._unit
		}, 9)
		
		if heat_place_opt == 1 or heat_place_opt == 3 then
			World:effect_manager():spawn({effect = Idstring("effects/payday2/particles/explosions/molotov_grenade_enemy_on_fire_9s"), parent = bone_head})
		end
		if heat_place_opt == 2 or heat_place_opt == 3 then
			World:effect_manager():spawn({effect = Idstring("effects/payday2/particles/explosions/molotov_grenade_enemy_on_fire_9s"), parent = bone_spine})
			World:effect_manager():spawn({effect = Idstring("effects/payday2/particles/explosions/molotov_grenade_enemy_on_fire_9s"), parent = bone_left_arm})
			World:effect_manager():spawn({effect = Idstring("effects/payday2/particles/explosions/molotov_grenade_enemy_on_fire_9s"), parent = bone_right_arm})
			World:effect_manager():spawn({effect = Idstring("effects/payday2/particles/explosions/molotov_grenade_enemy_on_fire_9s"), parent = bone_left_leg})
			World:effect_manager():spawn({effect = Idstring("effects/payday2/particles/explosions/molotov_grenade_enemy_on_fire_9s"), parent = bone_right_leg})
		end
	end

end)

Hooks:Add("CopDamagePostDamageMelee", "MeleeOptionsDecapitations", function(self, attack_data)

	if not MeleeOptions._opts.decapitation_enabled then
		return
	end
	
	local head = attack_data.col_ray.body and (tostring(attack_data.col_ray.body:name()) == "Idstring(@IDefb9de5ec58709d0@)" or tostring(attack_data.col_ray.body:name()) == "Idstring(@ID103b4a9c4e487706@)")
	local decap_opt = MeleeOptions._opts.decapitation_opt or 1
	
	if decap_opt == 1 and not head then
		return
	end

	if self._dead then
		attack_data.attacker_unit:sound():play(tweak_data.blackmarket.melee_weapons[managers.blackmarket:equipped_melee_weapon()].sounds.equip, nil, true)
		
		self._unit:movement():enable_update()
		self._unit:movement()._frozen = nil
		
		if self._unit:movement()._active_actions[1] then
			self._unit:movement()._active_actions[1]:force_ragdoll()
		end
		
		World:effect_manager():spawn({
			effect = Idstring("effects/payday2/particles/impacts/blood/blood_impact_a"),
			position = self._unit:get_object(Idstring("Head")):position(),
			rotation = self._unit:get_object(Idstring("Head")):rotation():y()
		})
		
		local hit_pos = mvector3.copy(self._unit:movement():m_pos())
		local attack_dir = attack_data.attacker_unit:movement():m_head_rot():y()
		local scale = 0.50
		local height = mvector3.distance(hit_pos, self._unit:position()) - 100
		local twist_dir = math.random(2) == 1 and 1 or -1
		local rot_acc = (attack_dir:cross(math.UP) + math.UP * (0.5 * twist_dir)) * (-1000 * math.sign(height))
		local rot_time = 1 + math.rand(2)
		local nr_u_bodies = self._unit:num_bodies()
		local i_u_body = 0
		while nr_u_bodies > i_u_body do
			local u_body = self._unit:body(i_u_body)
			if u_body:enabled() and u_body:dynamic() then
				local body_mass = u_body:mass()
				World:play_physic_effect(Idstring("physic_effects/shotgun_hit"), u_body, Vector3(attack_dir.x, attack_dir.y, attack_dir.z + 0.5) * 600 * scale, 4 * body_mass / math.random(2), rot_acc, rot_time)
			end
			i_u_body = i_u_body + 1
		end
	
		local bone_head = self._unit:get_object(Idstring("Head"))
		local bone_body = self._unit:get_object(Idstring("Spine1"))
		
		MeleeOptions.cop_decapitation.attack_data[self._unit] = attack_data
		MeleeOptions.cop_decapitation.ragdoll[self._unit] = self._unit
		
		self:_spawn_head_gadget({
			position = bone_head:position(),
			rotation = bone_head:rotation(),
			dir = attack_data.attacker_unit:movement():m_head_rot():y()
		})
		
		self._unit:decal_surface(Idstring("Head")):set_mesh_material(Idstring("Head"), Idstring("flesh"))
			
		bone_head:set_position(bone_body:position())
		bone_head:set_rotation(bone_body:rotation())
		
		MeleeOptions.cop_decapitation.t[self._unit] = Application:time() + (MeleeOptions._opts.decapitation_time or 10)
		MeleeOptions.cop_decapitation.interval[self._unit] = Application:time() + (MeleeOptions._opts.decapitation_interval or 0.5)
	end

end)

Hooks:PreHook(CopDamage, "damage_melee", "MeleeOptionsSnager", function(self, attack_data)

	if MeleeOptions._opts.extras_enabled and MeleeOptions._opts.pager_enabled then
		
		if not MeleeOptions._opts.pager_sync_enabled and not Global.game_settings.single_player then
			return
		end
		
		if not MeleeOptions._opts.bypass_pager and not managers.player:has_category_upgrade("player", "silent_kill") then
			return
		end

		if managers.groupai:state():whisper_mode() and self._unit:unit_data().has_alarm_pager and attack_data.attacker_unit == managers.player:player_unit() and not self._dead and attack_data.damage >= self._health and 0.30 >= math.rand(1) then
			MeleeOptions.cop_pager.units[self._unit] = self._unit
		end
		
	end	

end)

Hooks:PreHook(CopDamage, "damage_melee", "MeleeOptionsHeadshot", function(self, attack_data)

	if MeleeOptions._opts.extras_enabled and MeleeOptions._opts.headshots_enabled then
	
		if not MeleeOptions._opts.headshots_sync_enabled and not Global.game_settings.single_player then
			return
		end

		local head = self._head_body_name and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name

		if head then
			attack_data.damage = attack_data.damage * 1.75
		end
		
	end

end)

Hooks:PreHook(CopDamage, "damage_melee", "MeleeOptionsTaseFullCharge", function(self, attack_data)

	if not MeleeOptions._opts.buzzer_full_enabled then
		return
	end
	
	if managers.blackmarket:equipped_melee_weapon() == "taser" and attack_data.attacker_unit:movement():current_state():_get_melee_charge_lerp_value(Application:time()) ~= 1 then
		attack_data.variant = "melee"
	end

end)

Hooks:PostHook(CopDamage, "damage_melee", "MeleeOptionsFixGrinder", function(self, attack_data)

	if not MeleeOptions._opts.grinder_fix then
		return
	end
	
	if not managers.player:has_category_upgrade("player", "damage_to_hot") then
		return
	end
	
	if self._dead then
		return
	end
	
	if MeleeOptions.grinder_t == nil then
		MeleeOptions.grinder_t = Application:time()
		attack_data.attacker_unit:character_damage():add_damage_to_hot()
	end
	
	if (Application:time() - MeleeOptions.grinder_t) < 1 then
		return
	end
	
	MeleeOptions.grinder_t = Application:time()
	attack_data.attacker_unit:character_damage():add_damage_to_hot()

end)

Hooks:PostHook(CopDamage, "damage_melee", "MeleeOptionsCallouts", function(self, attack_data)

	if not MeleeOptions._opts.callout_enabled then
		return
	end
	
	local shouts = {"f03b_any", "l02x_sin"}

	if self._dead and (MeleeOptions._opts.callout_chance or 0.7) >= math.rand(1) then
		attack_data.attacker_unit:sound():say(shouts[math.random(#shouts)], true, true)
	end

end)

Hooks:PostHook(CopDamage, "damage_melee", "MeleeCopTaseEffect", function(self, attack_data)

	if not MeleeOptions._opts.buzzer_enabled then
		return
	end

	if attack_data.attacker_unit == managers.player:player_unit() and managers.blackmarket:equipped_melee_weapon() == "taser" then
		MeleeOptions.cop_taser[self._unit] = World:effect_manager():spawn({effect = Idstring("effects/payday2/particles/character/taser_hittarget"), parent = self._unit:get_object(Idstring("Spine1"))})
	end

end)

Hooks:PostHook( PlayerManager, "update", "MeleeOptionsCopExplosionUpdate", function(self, t, dt)

	if Utils and Utils:IsInGameState() and Utils:IsInHeist() and not Utils:IsInCustody() then
		if not MeleeOptions._opts.cop_explode_enabled then
			return
		end
		
		if MeleeOptions.cop_explode then
			for unit, val in pairs(MeleeOptions.cop_explode.t) do
				if alive(unit) then
					if Application:time() >= val then
						MeleeOptions.cop_explode.t[unit] = nil
						
						unit:contour():flash("mark_enemy", nil)
						unit:contour():remove("mark_enemy")
						
						if not managers.groupai:state():whisper_mode() then
							local hit_pos = mvector3.copy(unit:movement():m_pos())
							if unit:movement()._active_actions[1] then
								unit:movement()._active_actions[1]:force_ragdoll()
							end
							local attack_dir = -unit:movement():m_head_rot():y()
							local scale = MeleeOptions._opts.explode_force_mul or 2
							local height = mvector3.distance(hit_pos, unit:position()) - 100
							local twist_dir = math.random(2) == 1 and 1 or -1
							local rot_acc = (attack_dir:cross(math.UP) + math.UP * (0.5 * twist_dir)) * (-1000 * math.sign(height))
							local rot_time = 1 + math.rand(2)
							local nr_u_bodies = unit:num_bodies()
							local i_u_body = 0
							while nr_u_bodies > i_u_body do
								local u_body = unit:body(i_u_body)
								if u_body:enabled() and u_body:dynamic() then
									local body_mass = u_body:mass()
									World:play_physic_effect(Idstring("physic_effects/shotgun_hit"), u_body, Vector3(attack_dir.x, attack_dir.y, attack_dir.z + 0.5) * 600 * scale, 4 * body_mass / math.random(2), rot_acc, rot_time)
								end
								i_u_body = i_u_body + 1
							end
						end
					
						local explosion_params = {
							effect = "effects/payday2/particles/explosions/grenade_explosion",
							sound_event = "grenade_explode",
							feedback_range = (MeleeOptions._opts.cop_explode_effects_enabled and 1000 * 2 or 0),
							camera_shake_max_mul = (MeleeOptions._opts.cop_explode_effects_enabled and 4 or 0),
							sound_muffle_effect = (MeleeOptions._opts.cop_explode_effects_enabled and true or false)
						}
						
						managers.explosion:play_sound_and_effects(unit:position(), math.UP, 1000, explosion_params)
					end
				else
					MeleeOptions.cop_explode.t[unit] = nil
				end
			end
		end
	end
	
end )

Hooks:PostHook( PlayerManager, "update", "MeleeOptionsCopDecapitationUpdate", function(self, t, dt)
	
	if Utils and Utils:IsInGameState() and Utils:IsInHeist() and not Utils:IsInCustody() then
		if not MeleeOptions._opts.decapitation_enabled then
			return
		end
	
		if MeleeOptions.cop_decapitation then
			for unit, val in pairs(MeleeOptions.cop_decapitation.ragdoll) do
				if alive(unit) then
					unit:get_object(Idstring("Head")):set_position(unit:get_object(Idstring("Spine1")):position())
					unit:get_object(Idstring("Head")):set_rotation(unit:get_object(Idstring("Spine1")):rotation())
				else
					MeleeOptions.cop_decapitation.ragdoll[unit] = nil
				end
			end
			for unit, val in pairs(MeleeOptions.cop_decapitation.t) do
				if alive(unit) then
					if Application:time() < val then
						if Application:time() >= MeleeOptions.cop_decapitation.interval[unit] then
							MeleeOptions.cop_decapitation.interval[unit] = Application:time() + (MeleeOptions._opts.decapitation_interval or 0.5)
							
							World:effect_manager():spawn({
								effect = Idstring("effects/payday2/particles/impacts/blood/blood_impact_a"),
								position = unit:get_object(Idstring("Neck")):position(),
								rotation = unit:get_object(Idstring("Neck")):rotation():y()
							})
							
							local splatter_from = unit:get_object(Idstring("Neck")):position()
							local splatter_to = splatter_from + unit:get_object(Idstring("Neck")):rotation():y() * 100
							local splatter_ray = unit:raycast("ray", splatter_from, splatter_to, "slot_mask", managers.slot:get_mask("world_geometry"))
							if splatter_ray then
								World:project_decal(Idstring("blood_spatter"), splatter_ray.position, splatter_ray.ray, splatter_ray.unit, nil, splatter_ray.normal)
							end
							
							if unit:movement()._active_actions[1] then
								unit:movement()._active_actions[1]:force_ragdoll()
							end
							local scale = (MeleeOptions._opts.twitch_enabled and 0.075) or 0
							local height = 1
							local twist_dir = math.random(2) == 1 and 1 or -1
							local rot_acc = (math.UP * (0.5 * twist_dir)) * -0.5
							local rot_time = 1 + math.rand(2)
							local nr_u_bodies = unit:num_bodies()
							local i_u_body = 0
							while nr_u_bodies > i_u_body do
								local u_body = unit:body(i_u_body)
								if u_body:enabled() and u_body:dynamic() then
									local body_mass = u_body:mass()
									World:play_physic_effect(Idstring("physic_effects/shotgun_hit"), u_body, math.UP * 600 * scale, 4 * body_mass / math.random(2), rot_acc, rot_time)
								end
								i_u_body = i_u_body + 1
							end
						end
					else
						MeleeOptions.cop_decapitation.t[unit] = nil
						MeleeOptions.cop_decapitation.interval[unit] = nil
						MeleeOptions.cop_decapitation.attack_data[unit] = nil
					end
				else
					MeleeOptions.cop_decapitation.t[unit] = nil
					MeleeOptions.cop_decapitation.interval[unit] = nil
					MeleeOptions.cop_decapitation.attack_data[unit] = nil
				end
			end
		end
	end
	
end )

Hooks:PostHook( CopDamage , "sync_damage_melee" , "MeleeOptionsSyncFeatures" , function( self , attacker_unit , damage_percent , damage_effect_percent , i_body, hit_offset_height , variant , death )

	local attack_data = {
		col_ray = { body = self._unit:body(i_body) },
		attacker_unit = attacker_unit
	}

	Hooks:Call( "CopDamagePostDamageMelee", self, attack_data )
	
end )