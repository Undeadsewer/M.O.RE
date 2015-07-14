Hooks:PostHook(CopBrain, "clbk_alarm_pager", "MeleeOptionsSnatching", function(self, ignore_this, data)

	if not MeleeOptions._opts.extras_enabled and not MeleeOptions._opts.pager_enabled then
		MeleeOptions.cop_pager.units = {}
		return
	end
	
	if not MeleeOptions._opts.pager_sync_enabled and not Global.game_settings.single_player then
		MeleeOptions.cop_pager.units = {}
		return
	end
	
	if managers.groupai:state():get_nr_successful_alarm_pager_bluffs() < 4 then

		for cop_unit, unit in pairs(MeleeOptions.cop_pager.units) do
			MeleeOptions.cop_pager.units[cop_unit] = nil
			unit:interaction():interact(managers.player:player_unit())
			return
		end
	
	else
	
		MeleeOptions.cop_pager.units = {}
		return
	
	end

end)