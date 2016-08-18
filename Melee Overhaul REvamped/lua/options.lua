function MeleeOverhaul:ShowMessageOfTheDay()

	if not managers.menu_component then
		return
	end
	
	self._panel = managers.menu_component._ws:panel():panel()
	
	self._motd_t = self._panel:text({
		name 		= "motd_t",
		text 		= managers.localization:text( "more_options_motd" ),
		blend_mode 	= "add",
		w 			= self._panel:w() * 0.35,
		h 			= self._panel:h(),
		font 		= "fonts/font_medium_shadow_mf",
		font_size 	= 30,
		color 		= Color.white,
		vertical 	= "top",
		align 		= "center",
		wrap 		= true,
		word_wrap 	= true,
		layer 		= tweak_data.gui.MOUSE_LAYER - 50
	})
	
	self._motd_d = self._panel:text({
		name 		= "motd_d",
		text 		= managers.localization:text( "more_options_motd_unavailable" ),
		blend_mode 	= "add",
		w 			= self._panel:w() * 0.35 - 10,
		h 			= self._panel:h(),
		font 		= "fonts/font_medium_shadow_mf",
		font_size 	= 22,
		color 		= Color.white,
		vertical 	= "top",
		align 		= "left",
		wrap 		= true,
		word_wrap 	= true,
		layer 		= tweak_data.gui.MOUSE_LAYER - 50
	})
	
	self._motd_bg = self._panel:bitmap({
		name 			= "motd_bg",
		texture 		= "guis/textures/pd2/hud_tabs",
		texture_rect 	= {
							84,
							0,
							44,
							32
						},
		visible 		= true,
		layer 			= tweak_data.gui.MOUSE_LAYER - 51,
		color 			= Color.white / 2,
		w 				= self._panel:w() * 0.35,
		h 				= self._panel:h()
	})
	
	self._motd_bg2 = self._panel:bitmap({
		name 			= "motd_bg2",
		texture 		= "guis/textures/pd2/hud_tabs",
		texture_rect 	= {
							84,
							0,
							44,
							32
						},
		visible 		= true,
		layer 			= tweak_data.gui.MOUSE_LAYER - 51,
		color 			= Color.white / 2,
		w 				= self._panel:w() * 0.35,
		h 				= self._panel:h()
	})
	
	if self.MOTD then
		self._motd_d:set_text( self.MOTD )
	end
	
	local _ , _ , _ , h1 = self._motd_t:text_rect()
	local _ , _ , _ , h2 = self._motd_d:text_rect()
	local divider = 7
	local tab = 0.3
	
	self._motd_t:set_h( h1 )
	self._motd_t:set_right( self._panel:right() )
	self._motd_t:set_top( self._panel:h() * tab )
	self._motd_d:set_h( h2 )
	self._motd_d:set_right( self._panel:right() )
	self._motd_d:set_top( self._motd_t:bottom() + divider )
	
	self._motd_bg:set_h( h1 + h2 + divider + 10 )
	self._motd_bg:set_right( self._panel:right() )
	self._motd_bg:set_top( self._panel:h() * tab )
	self._motd_bg2:set_h( h1 )
	self._motd_bg2:set_right( self._panel:right() )
	self._motd_bg2:set_top( self._panel:h() * tab )

end

function MeleeOverhaul:DestroyMessageOfTheDay()

	if alive( self._panel ) then

		self._panel:remove( self._motd_t )
		self._panel:remove( self._motd_d )
		self._panel:remove( self._motd_bg )
		self._panel:remove( self._motd_bg2 )
		self._panel:remove( self._panel )

		self._motd_t = nil
		self._motd_d = nil
		self._motd_bg = nil
		self._motd_bg2 = nil
		self._panel = nil

	end

end

MeleeOverhaul.DynamicResources = {
	{ "effect" , "effects/payday2/particles/character/flyes_plague" },
	{ "effect" , "effects/payday2/particles/character/overkillpack/chains_eyes" },
	{ "effect" , "effects/payday2/particles/character/overkillpack/hoxton_eyes" }
}

MeleeOverhaul.MenuOptions = MeleeOverhaul.MenuOptions or {}
MeleeOverhaul.MenuOptions.Menu = {

	[ "MeleeOverhaulMenuMainOptions" ] = {
		"more_options_main_options_menu_title",
		"more_options_main_options_menu_desc",
		1
	},
	
	[ "MeleeOverhaulMenuGoreOptions" ] = {
		"more_options_gore_options_menu_title",
		"more_options_gore_options_menu_desc"
	},
	
	[ "MeleeOverhaulMenuCalloutOptions" ] = {
		"more_options_callout_options_menu_title",
		"more_options_callout_options_menu_desc"
	},
	
	[ "MeleeOverhaulMenuEffectsOptions" ] = {
		"more_options_effects_options_menu_title",
		"more_options_effects_options_menu_desc"
	},
	
	[ "MeleeOverhaulMenuMiscellaneousOptions" ] = {
		"more_options_miscellaneous_options_menu_title",
		"more_options_miscellaneous_options_menu_desc"
	}

}
MeleeOverhaul.MenuOptions.Toggle = {

	[ "MeleeHold" ] = {
		"MeleeOverhaulMenuMainOptions",
		"more_options_toggle_melee_hold_title",
		"more_options_toggle_melee_hold_desc",
		true
	},
	
	[ "MeleeHoldTime" ] = {
		"MeleeOverhaulMenuMainOptions",
		"more_options_toggle_melee_hold_timer_title",
		"more_options_toggle_melee_hold_timer_desc",
		false
	},
	
	[ "NoShake" ] = {
		"MeleeOverhaulMenuMiscellaneousOptions",
		"more_options_toggle_melee_shake_title",
		"more_options_toggle_melee_shake_desc",
		false
	},
	
	[ "TaseEffect" ] = {
		"MeleeOverhaulMenuMiscellaneousOptions",
		"more_options_toggle_tase_visual_title",
		"more_options_toggle_tase_visual_desc",
		false
	},
	
	[ "MessageOfTheDay" ] = {
		"MeleeOverhaulMenuMiscellaneousOptions",
		"more_options_toggle_motd_title",
		"more_options_toggle_motd_desc",
		true
	},
	
	[ "Decapitation" ] = {
		"MeleeOverhaulMenuGoreOptions",
		"more_options_toggle_decapitation_title",
		"more_options_toggle_decapitation_desc",
		false
	},
	
	[ "TrueDecapitation" ] = {
		"MeleeOverhaulMenuGoreOptions",
		"more_options_toggle_true_decapitation_title",
		"more_options_toggle_true_decapitation_desc",
		false
	},
	
	[ "RealisticGore" ] = {
		"MeleeOverhaulMenuGoreOptions",
		"more_options_toggle_realistic_gore_title",
		"more_options_toggle_realistic_gore_desc",
		false
	},
	
	[ "BluntForceTrauma" ] = {
		"MeleeOverhaulMenuGoreOptions",
		"more_options_toggle_blunt_force_trauma_title",
		"more_options_toggle_blunt_force_trauma_desc",
		false
	},
	
	[ "KillingCallout" ] = {
		"MeleeOverhaulMenuCalloutOptions",
		"more_options_toggle_killing_callout_title",
		"more_options_toggle_killing_callout_desc",
		false
	},
	
	[ "ChargingCallout" ] = {
		"MeleeOverhaulMenuCalloutOptions",
		"more_options_toggle_charging_callout_title",
		"more_options_toggle_charging_callout_desc",
		false
	}

}
MeleeOverhaul.MenuOptions.Slider = {

	[ "MeleeHoldTimer" ] = {
		"MeleeOverhaulMenuMainOptions",
		"more_options_slider_melee_hold_time_title",
		"more_options_slider_melee_hold_time_desc",
		0,
		5,
		0.5,
		1
	},
	
	[ "BluntForceMultiplier" ] = {
		"MeleeOverhaulMenuGoreOptions",
		"more_options_slider_blunt_force_multiplier_title",
		"more_options_slider_blunt_force_multiplier_desc",
		1,
		10,
		0.5,
		1
	}

}
MeleeOverhaul.MenuOptions.MultipleChoice = {

	[ "HandEffect" ] = {
		"MeleeOverhaulMenuEffectsOptions",
		"more_options_choice_hand_effect_title",
		"more_options_choice_hand_effect_desc",
		{
			{ "more_options_choice_hand_effect_a" },
			{ "more_options_choice_hand_effect_b" , "effects/particles/fire/small_light_fire" },
			{ "more_options_choice_hand_effect_c" , "effects/payday2/particles/character/taser_hittarget" },
			{ "more_options_choice_hand_effect_d" , "effects/payday2/particles/character/taser_stop" },
			{ "more_options_choice_hand_effect_e" , "effects/payday2/particles/character/taser_thread" },
			{ "more_options_choice_hand_effect_f" , "effects/payday2/particles/weapons/saw/sawing" },
			{ "more_options_choice_hand_effect_g" , "effects/payday2/environment/drill" },
			{ "more_options_choice_hand_effect_h" , "effects/payday2/environment/drill_jammed" },
			{ "more_options_choice_hand_effect_i" , "effects/payday2/particles/character/flyes_plague" },
			{ "more_options_choice_hand_effect_j" , "effects/payday2/particles/character/overkillpack/hoxton_eyes" },
			{ "more_options_choice_hand_effect_k" , "effects/payday2/particles/character/overkillpack/chains_eyes" }
		},
		1
	},
	
	[ "ImpactEffect" ] = {
		"MeleeOverhaulMenuEffectsOptions",
		"more_options_choice_impact_effect_title",
		"more_options_choice_impact_effect_desc",
		{
			{ "more_options_choice_impact_effect_a" },
			{ "more_options_choice_impact_effect_b" , "effects/payday2/particles/impacts/blood/blood_impact_a" },
			{ "more_options_choice_impact_effect_c" , "effects/payday2/particles/impacts/shotgun_explosive_round" },
			{ "more_options_choice_impact_effect_d" , "effects/particles/dest/security_camera_dest" }
		},
		1
	},
	
	[ "SpurtEffect" ] = {
		"MeleeOverhaulMenuGoreOptions",
		"more_options_choice_spurt_effect_title",
		"more_options_choice_spurt_effect_desc",
		{
			{ "more_options_choice_spurt_effect_a" },
			{ "more_options_choice_spurt_effect_b" , "effects/payday2/particles/impacts/blood/blood_tendrils" , 1 },
			{ "more_options_choice_spurt_effect_c" , "effects/particles/bullet_hit/flesh/bullet_impact_flesh_04" , 2 }
		},
		1
	}

}

MeleeOverhaul.BluntWeapons = {
	"weapon",
	"fists",
	"brass_knuckles",
	"moneybundle",
	"barbedwire",
	"boxing_gloves",
	"whiskey",
	"alien_maul",
	"shovel",
	"baton",
	"dingdong",
	"baseballbat",
	"briefcase",
	"model24",
	"shillelagh",
	"hammer",
	"spatula",
	"tenderizer",
	"branding_iron",
	"microphone",
	"oldbaton",
	"detector",
	"micstand",
	"hockey",
	"slot_lever",
	"croupier_rake",
	"taser",
	"fight",
	"buck",
	"morning",
	"cutters",
	"selfie",
	"stick",
	"zeus",
	"road"
}

MeleeOverhaul.SmallBladedWeapons = {
	"kabartanto",
	"toothbrush",
	"chef",
	"kabar",
	"rambo",
	"kampfmesser",
	"gerber",
	"becker",
	"x46",
	"bayonet",
	"bullseye",
	"cleaver",
	"fairbair",
	"meat_cleaver",
	"fork",
	"poker",
	"scalper",
	"bowie",
	"switchblade",
	"tiger",
	"cqc",
	"twins",
	"pugio",
	"boxcutter",
	"shawn",
	"scoutknife",
	"nin",
	"ballistic",
	"wing"
}