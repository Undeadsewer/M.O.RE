function comma_value(amount)
  local formatted = amount
  local k
  while true do
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

Hooks:PostHook( LocalizationManager , "text" , "MeleeOptionsModifySkillDescs" , function( self , string_id , macros )

	local skill_desc = {}
	
	if managers.money then
	
		if MeleeOptions and MeleeOptions._opts and MeleeOptions._opts.extras_enabled then
	
			tweak_data.upgrades.skill_descs.assassin = {multibasic = "25%", multibasic2 = "10%", multipro = "95%", multipro2 = "30%"}
			tweak_data.upgrades.skill_descs.hidden_blade = {multibasic = "2", multipro = "95%", multipro2 = "30%"}
			
			assassin_cost = SkillTreeManager:get_skill_points("assassin", 1)
			assassin_cost_pro = SkillTreeManager:get_skill_points("assassin", 2)
			assassin_money = MoneyManager:get_skillpoint_cost(1, 6, assassin_cost)
			assassin_money_pro = MoneyManager:get_skillpoint_cost(1, 6, assassin_cost_pro)
			
			hidden_blade_cost = SkillTreeManager:get_skill_points("hidden_blade", 1)
			hidden_blade_cost_pro = SkillTreeManager:get_skill_points("hidden_blade", 2)
			hidden_blade_money = MoneyManager:get_skillpoint_cost(1, 6, hidden_blade_cost)
			hidden_blade_money_pro = MoneyManager:get_skillpoint_cost(1, 6, hidden_blade_cost_pro)
			
			juggernaut_cost = SkillTreeManager:get_skill_points("juggernaut", 1)
			juggernaut_cost_pro = SkillTreeManager:get_skill_points("juggernaut", 2)
			juggernaut_money = MoneyManager:get_skillpoint_cost(1, 6, juggernaut_cost)
			juggernaut_money_pro = MoneyManager:get_skillpoint_cost(1, 6, juggernaut_cost_pro)
			
			hardware_expert_cost = SkillTreeManager:get_skill_points("hardware_expert", 1)
			hardware_expert_cost_pro = SkillTreeManager:get_skill_points("hardware_expert", 2)
			hardware_expert_money = MoneyManager:get_skillpoint_cost(1, 6, hardware_expert_cost)
			hardware_expert_money_pro = MoneyManager:get_skillpoint_cost(1, 6, hardware_expert_cost_pro)
			
			drill_expert_cost = SkillTreeManager:get_skill_points("drill_expert", 1)
			drill_expert_cost_pro = SkillTreeManager:get_skill_points("drill_expert", 2)
			drill_expert_money = MoneyManager:get_skillpoint_cost(1, 6, drill_expert_cost)
			drill_expert_money_pro = MoneyManager:get_skillpoint_cost(1, 6, drill_expert_cost_pro)
			
			silent_drilling_cost = SkillTreeManager:get_skill_points("silent_drilling", 1)
			silent_drilling_cost_pro = SkillTreeManager:get_skill_points("silent_drilling", 2)
			silent_drilling_money = MoneyManager:get_skillpoint_cost(1, 6, silent_drilling_cost)
			silent_drilling_money_pro = MoneyManager:get_skillpoint_cost(1, 6, silent_drilling_cost_pro)
			
			if MeleeOptions._opts.pager_enabled and not MeleeOptions._opts.bypass_pager then
				skill_desc["menu_assassin_desc"] = "BASIC: ##" .. (managers.skilltree:skill_step("assassin") >= 1 and "OWNED" or (assassin_cost .. " points / $" .. comma_value(assassin_money))) .. "## ## ##\nYour walk speed is increased by ##" .. tweak_data.upgrades.skill_descs.assassin.multibasic .. "## and your crouch speed is increased by ##" .. tweak_data.upgrades.skill_descs.assassin.multibasic2 .. "##.\n\nACE: ##" .. (managers.skilltree:skill_step("assassin") == 2 and "OWNED" or (assassin_cost_pro .. " points / $" .. comma_value(assassin_money_pro))) .. "##\nEnemies make ##" .. tweak_data.upgrades.skill_descs.assassin.multipro .. "## less noise when shot or meleed to death.\n\nWhen pager counts available, you have a ##" .. tweak_data.upgrades.skill_descs.assassin.multipro2 .. "## chance of answering a pager ##instantly## when meleeing a security guard.\n\nNOTE: This still consumes a pager count. (% chance does NOT stack with ##Hidden Blade Aced##)"
				skill_desc["menu_hidden_blade_desc"] = "BASIC: ##" .. (managers.skilltree:skill_step("hidden_blade") >= 1 and "OWNED" or (hidden_blade_cost .. " points / $" .. comma_value(hidden_blade_money))) .. "## ## ##\nIncreases your melee weapon concealment by ##" .. tweak_data.upgrades.skill_descs.hidden_blade.multibasic .. "##." .. "\n\nACE: ##" .. (managers.skilltree:skill_step("hidden_blade") == 2 and "OWNED" or (hidden_blade_cost_pro .. " points / $" .. comma_value(hidden_blade_money_pro))) .. "##\nEnemies make ##" .. tweak_data.upgrades.skill_descs.hidden_blade.multipro .. "## less noise when shot or meleed to death.\n\nWhen pager counts available, you have a ##" .. tweak_data.upgrades.skill_descs.hidden_blade.multipro2 .. "## chance of answering a pager ##instantly## when meleeing a security guard.\n\nNOTE: This still consumes a pager count. (% chance does NOT stack with ##Shinobi Aced##)"
			end
			
			if MeleeOptions._opts.sprint == 3 then
				skill_desc["menu_juggernaut_desc"] = "BASIC: ##" .. (managers.skilltree:skill_step("juggernaut") >= 1 and "OWNED" or (juggernaut_cost .. " points / $" .. comma_value(juggernaut_money))) .. "##\nUnlocks the ability to wear the Improved Combined Tactical Vest.\n\nACE: ##" .. (managers.skilltree:skill_step("juggernaut") == 2 and "OWNED" or (juggernaut_cost_pro .. " points / $" .. comma_value(juggernaut_money_pro))) .. "##\nWhen you melee Shield enemies, they get knocked back by the sheer force.\n\nRun and shoot - you can now shoot from the hip while sprinting.\nRun and melee - you can now melee while sprinting."
			end
			
			if MeleeOptions._opts.repair_enabled and not MeleeOptions._opts.bypass_repair then
				skill_desc["menu_hardware_expert_desc"] = "BASIC: ##" .. (managers.skilltree:skill_step("hardware_expert") >= 1 and "OWNED" or (hardware_expert_cost .. " points / $" .. comma_value(hardware_expert_money))) .. "##\nYou fix the drill ##25%## faster and you also deploy trip mines ##20%## faster.\n\nYou gain an additional ##4%## chance to repair a drill when meleeing it.\n\nACE: ##" .. (managers.skilltree:skill_step("hardware_expert") == 2 and "OWNED" or (hardware_expert_cost_pro .. " points / $" .. comma_value(hardware_expert_money_pro))) .. "##\nGives your drill a ##30%## chance to autorestart when it breaks down. You also deploy the sentry gun ##50%## faster.\n\nGrants an additional ##6%## chance to repair a drill when meleeing it."
				skill_desc["menu_drill_expert_desc"] = "BASIC: ##" .. (managers.skilltree:skill_step("drill_expert") >= 1 and "OWNED" or (drill_expert_cost .. " points / $" .. comma_value(drill_expert_money))) .. "##\nYour drilling efficiency is increased by ##15%##.\n\nYou gain an additional ##4%## chance to repair a drill when meleeing it.\n\nACE: ##" .. (managers.skilltree:skill_step("drill_expert") == 2 and "OWNED" or (drill_expert_cost_pro .. " points / $" .. comma_value(drill_expert_money_pro))) .. "##\nFurther increases your drilling efficiency by ##15%##.\n\nGrants an additional ##6%## chance to repair a drill when meleeing it."
				skill_desc["menu_silent_drilling_desc"] = "BASIC: ##" .. (managers.skilltree:skill_step("silent_drilling") >= 1 and "OWNED" or (silent_drilling_cost .. " points / $" .. comma_value(silent_drilling_money))) .. "##\nYour drill makes ##65%## less noise. Civilians and guards are less likely to hear your drill and sound the alarm.\n\nYou gain an additional ##4%## chance to repair a drill when meleeing it.\n\nACE: ##" .. (managers.skilltree:skill_step("silent_drilling") == 2 and "OWNED" or (silent_drilling_cost_pro .. " points / $" .. comma_value(silent_drilling_money_pro))) .. "##\nYour drill is silent. Civilians and guards have to see the drill in order to sound the alarm.\n\nGrants an additional ##6%## chance to repair a drill when meleeing it."
			end
			
			if skill_desc[string_id] then return skill_desc[string_id] end
		
		end
		
	end

end )