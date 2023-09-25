// TODO
// Allow using raw string names of windows for HG_WINDOW
// Default hitbox length to parent window's length
// automatic sfx based on damage
// default hitbox to belonging to most recently defined window
// allow combining parameters like sfx and sfx_frame, or base+kbscaling
// When AG_USES_CUSTOM_GRAVITY, the default gravity for each window is gravity_speed rather than 0
// increasing damage increases other attack attributes
// production mode to disable prototyping defaults?
// get_window_index should default to using the current value of `attack` if not in an attack file and no attack given.

#define easy_hitbox
/// easy_hitbox(_hitbox_index, ...)
    var _hitbox_index = argument[0];
    
    var _attack_index = get_attack_index_from_filename()
    
    // TODO add named hitbox support here?
    
    set_num_hitboxes(_attack_index, get_num_hitboxes(_attack_index) + 1)
    
    var assignments = array_create(100, undefined)
    for(var i=1; i<=argument_count-1; i+=2) {
        var _var_index = argument[i]
        var _value = argument[i+1]
        assignments[_var_index] = _value
    }
    
    // Required
    var requireds = []
    
    // New Defaults
    var special_defaults = [
        [HG_HITBOX_TYPE, HITBOX_TYPE_MELEE],
        [HG_PRIORITY, 5], // Middle value
        [HG_LIFETIME, 3], // TODO make remaining duration of window
        [HG_HITBOX_X, 15],
        [HG_HITBOX_Y, -40],
        [HG_WIDTH, 60],
        [HG_HEIGHT, 60],
        [HG_ANGLE, 361],
        [HG_PROJECTILE_HSPEED, 10],
        [HG_DAMAGE, 6], // TODO The rest of these should correlate based on any supplied value
        [HG_BASE_KNOCKBACK, 6],
        [HG_KNOCKBACK_SCALING, 0.35],
        [HG_BASE_HITPAUSE, 6],
        [HG_HITPAUSE_SCALING, 0.25],
        [HG_SDI_MULTIPLIER, 1], // Because manually setting to 0 reroutes to -1 internally. Jeez.
    ]

    if assignments[HG_PROJECTILE_SPRITE] != undefined {
        array_push(special_defaults, [HG_PROJECTILE_MASK, assignments[HG_PROJECTILE_SPRITE]])
    }

    
    // HG_WINDOW, set to "active" window if it exists
    var index_of_window_named_active = get_window_index("active")
    if index_of_window_named_active != -1 {
        array_push(special_defaults, [HG_WINDOW, index_of_window_named_active])
    } else {
        array_push(requireds, HG_WINDOW)
    }


    // If the window will be 1, increase the default creation frame to 1. You can't have a window 1 frame 1 hitbox.
    if (
        assignments[HG_WINDOW] == 1 
        or (assignments[HG_WINDOW] == undefined and special_defaults[HG_WINDOW] == 1)
    ) {
        array_push(special_defaults, [HG_WINDOW_CREATION_FRAME, 1])         
    }
    


    // Check requireds    
    for (var required_i=0; required_i<array_length(requireds); required_i++) {
        var required = requireds[required_i]
        if assignments[required] == undefined {
            prints("ERROR: easy_hitbox", get_script_name(), _hitbox_index, "didn't set", required)
        } else {
            set_hitbox_value(_attack_index, _hitbox_index, required, assignments[required])
        }
    }


    var default_array = array_create(100, 0)
    for (var default_i=0; default_i<array_length(special_defaults); default_i++) {
        var index = special_defaults[default_i][0]
        var default_value = special_defaults[default_i][1]
        default_array[index] = default_value
    }
    for (var i=0; i<array_length(assignments); i++) {
        if assignments[i] == undefined {
            set_hitbox_value(_attack_index, _hitbox_index, i, default_array[i])
        } else {
            set_hitbox_value(_attack_index, _hitbox_index, i, assignments[i])
        }
    }
    
    
    // New defaults
        // HG_HITBOX_X, defaults 15 (sane vanilla average)
        // HG_HITBOX_Y, defaults -40 (sane vanilla average)
        // HG_WIDTH, defaults to 60 (sane vanilla average)
        // HG_HEIGHT, defaults to 60 (sane vanilla average)
        // HG_ANGLE, defaults to 361 (1/3 of vanilla hitboxes have are 361)
        // HG_PROJECTILE_HSPEED, defaults medium horizontal
    // should be very correlated vvv
    // HG_DAMAGE, defaults to 6 (sane vanilla average)
    // HG_BASE_KNOCKBACK, defaults to 6 (sane vanilla average)
    // HG_KNOCKBACK_SCALING, defaults to 0.35 (sane vanilla average)
    // HG_BASE_HITPAUSE, defaults to 6 (sane vanilla average)
    // HG_HITPAUSE_SCALING, defaults to 0.25 (save vanilla average)
    

    // normal defaults VVV
        // HG_PARENT_HITBOX
        // HG_WINDOW_CREATION_FRAME
        // HG_SHAPE
        // HG_EFFECT
        // HG_VISUAL_EFFECT
        // HG_VISUAL_EFFECT_X_OFFSET
        // HG_VISUAL_EFFECT_Y_OFFSET
        // HG_HIT_PARTICLE_NUM
        // HG_HIT_SFX
        // HG_ANGLE_FLIPPER
        // HG_EXTRA_HITPAUSE
        // HG_GROUNDEDNESS
        // HG_HITSTUN_MULTIPLIER
        // HG_DRIFT_MULTIPLIER
        // HG_SDI_MULTIPLIER
        // HG_TECHABLE
        // HG_FORCE_FLINCH
        // HG_FINAL_BASE_KNOCKBACK
        // HG_THROWS_ROCK
        // HG_PROJECTILE_COLLISION_SPRITE
        // HG_PROJECTILE_ANIM_SPEED
        // HG_PROJECTILE_VSPEED
        // HG_PROJECTILE_GRAVITY
        // HG_PROJECTILE_GROUND_FRICTION
        // HG_PROJECTILE_AIR_FRICTION
        // HG_PROJECTILE_WALL_BEHAVIOR
        // HG_PROJECTILE_GROUND_BEHAVIOR
        // HG_PROJECTILE_ENEMY_BEHAVIOR
        // HG_PROJECTILE_UNBASHABLE
        // HG_PROJECTILE_PARRY_STUN
        // HG_PROJECTILE_DOES_NOT_REFLECT
        // HG_PROJECTILE_IS_TRANSCENDENT
        // HG_PROJECTILE_DESTROY_EFFECT
        // HG_PROJECTILE_PLASMA_SAFE
        // HG_PROJECTILE_MASK

    // normal defaults + special behaviour, processed last, can overwrite other values VVV
        // HG_PROJECTILE_SPRITE, sets HG_PROJECTILE_MASK

#define easy_attack
    // This is called automatically by easy_window if it hadn't been already.
    var _attack_index = get_attack_index_from_filename()
    variable_instance_set(self, "easy_attack_called_"+get_script_name(), true)

    var assignments = array_create(100, undefined)
    for(var i=0; i<=argument_count-1; i+=2) {
        var _var_index = argument[i]
        var _value = argument[i+1]
        assignments[_var_index] = _value
    }
    
    // Special Defaults
    var special_defaults = [
        [AG_CATEGORY, get_default_ag_category()],
        [AG_LANDING_LAG, 4],
        [AG_HAS_LANDING_LAG, true],
    ]
    // Add sprite defaults to special defaults if the default exists
    var sprite_defaults = [
        [AG_SPRITE, get_script_name()],
        [AG_HURTBOX_SPRITE, get_script_name()+"_hurt"],
        [AG_AIR_SPRITE, get_script_name()+"_air"],
        [AG_HURTBOX_AIR_SPRITE, get_script_name()+"_air_hurt"],
    ]
    var SPRITE_NOT_FOUND = sprite_get("kljgalksjglkvoaiwemnfnoiuaganio");
    for (var default_i=0; default_i<array_length(sprite_defaults); default_i++) {
        var index = sprite_defaults[default_i][0]
        var default_sprite_name = sprite_defaults[default_i][1]
        var sprite = sprite_get(default_sprite_name)
        
        if sprite != SPRITE_NOT_FOUND {
            array_push(special_defaults, [index, sprite])
        }
    }


    var default_array = array_create(100, 0)
    for (var default_i=0; default_i<array_length(special_defaults); default_i++) {
        var index = special_defaults[default_i][0]
        var default_value = special_defaults[default_i][1]
        default_array[index] = default_value
    }
    for (var i=0; i<array_length(assignments); i++) {
        if assignments[i] == undefined {
            set_attack_value(_attack_index, i, default_array[i])
        } else {
            set_attack_value(_attack_index, i, assignments[i])
        }
    }
    
    // fancy new default VVV
        // AG_CATEGORY, defaults to ground or air based on filename
        // AG_SPRITE, uses file name
        // AG_HURTBOX_SPRITE, uses file name
        // AG_AIR_SPRITE, uses file name
        // AG_HURTBOX_AIR_SPRITE, uses file name
        // AG_LANDING_LAG, defaults to 4 (most common vanilla value)
        // AG_STRONG_CHARGE_WINDOW, defaults to true if the attack is named "charge" TODO
        // AG_LANDING_LAG, true
    
    
    // normal defaults VVV
        // AG_OFF_LEDGE

    // obsolete, expected to be set indirectly VVV
        // AG_NUM_WINDOWS, this is normally set automatically when easy_window is called. Overwrite by setting it manually last.
        // AG_HAS_LANDING_LAG
    // AG_USES_CUSTOM_GRAVITY, this is set to true if any windows set custom gravity.
    
#define easy_window 
    if not variable_instance_exists(self, "easy_attack_called_"+get_script_name()) {
        easy_attack()
    }

    var _attack_index = get_attack_index_from_filename()
    var _window_name
    var _window_index
    if is_string(argument[0]) {
        _window_name = argument[0]
        _window_index = _get_next_open_window_index(_attack_index)
    } else {
        _window_name = undefined
        _window_index = argument[0]
    }

    if _window_name != undefined {
        set_window_name(_attack_index, _window_index, _window_name)
    }

    // Increases AG_NUM_WINDOWS by 1. Can be overwritten by setting it manually last.
    set_attack_value(_attack_index, AG_NUM_WINDOWS, get_attack_value(_attack_index, AG_NUM_WINDOWS) + 1)
    
    var assignments = array_create(100, undefined)
    for(var i=1; i<=argument_count-2; i+=2) {
        var _var_index = argument[i]
        var _value = argument[i+1]
        assignments[_var_index] = _value
    }
    
    
    // If named charge, set as the default charge window.
    if _window_name == "charge" 
        and string_pos("special", get_script_name()) == 0
    {
        if get_attack_value(_attack_index, AG_STRONG_CHARGE_WINDOW) == 0 {
            set_attack_value(_attack_index, AG_STRONG_CHARGE_WINDOW, _window_index)
        }
    }
    

    // Required
    var requireds = [
        AG_WINDOW_LENGTH
    ]
    // New Defaults
    var special_defaults = [
        [AG_WINDOW_HAS_WHIFFLAG, get_default_whifflag(_window_name)]
    ]
    
    
    if assignments[AG_WINDOW_SFX] != undefined {
        array_push(special_defaults, [AG_WINDOW_HAS_SFX, true])
    }
    if (
        assignments[AG_WINDOW_CUSTOM_AIR_FRICTION] != undefined 
        or assignments[AG_WINDOW_CUSTOM_GROUND_FRICTION] != undefined
    ) {
        array_push(special_defaults, [AG_WINDOW_HAS_CUSTOM_FRICTION, true])
    }
    
    
    
    
    // Set defaults
    if _window_name != undefined {
        var get_frames_script_name = "_get_"+_window_name+"_frames"
        if script_exists(get_frames_script_name) {
            array_push(special_defaults, [AG_WINDOW_ANIM_FRAMES, script_execute(script_get_index(get_frames_script_name))])
        } else {
            array_push(requireds, AG_WINDOW_ANIM_FRAMES)
        }
        
        var get_frame_start_script_name = "_get_"+_window_name+"_frame_start"
        if script_exists(get_frames_script_name) {
            array_push(special_defaults, [AG_WINDOW_ANIM_FRAME_START, script_execute(script_get_index(get_frame_start_script_name))])
        } else if _window_index > 1 {
            array_push(requireds, AG_WINDOW_ANIM_FRAME_START)
        }
        
    }
     
    // Check requireds
    for (var required_i=0; required_i<array_length(requireds); required_i++) {
        var required = requireds[required_i]
        if assignments[required] == undefined {
            prints("ERROR: easy_window", get_script_name(), _window_name, _window_index, "didn't set", get_ag_window_name_from_index(required))
        } else {
            set_window_value(_attack_index, _window_index, required, assignments[required])
        }
    }
    
    // Add new defaults
    var default_array = array_create(100, 0)
    for (var default_i=0; default_i<array_length(special_defaults); default_i++) {
        var index = special_defaults[default_i][0]
        var default_value = special_defaults[default_i][1]
        default_array[index] = default_value
    }
    
    for (var i=0; i<array_length(assignments); i++) {
        if assignments[i] == undefined {
            set_window_value(_attack_index, _window_index, i, default_array[i])
        } else {
            set_window_value(_attack_index, _window_index, i, assignments[i])
        }
    }
    

    
    // sometimes default, sometimes required
        // AG_WINDOW_ANIM_FRAMES, assistant supplies from aseprite, else required
        // AG_WINDOW_ANIM_FRAME_START, assistant supplies from aseprite, else required
    // AG_WINDOW_CUSTOM_GRAVITY, required if any other windows have it set.
    
    // fancy new default VVV
        // AG_WINDOW_HAS_WHIFFLAG, defaults to 1 in final window
        // (nah) AG_WINDOW_VSPEED, defaults to -2(?) for aerials? Look at the stats.
    
    // normal defaults + special behaviour, processed last, can overwrite other values VVV
    // AG_WINDOW_CUSTOM_GRAVITY, if supplied, sets AG_USES_CUSTOM_GRAVITY to true
        // AG_WINDOW_CUSTOM_AIR_FRICTION, if supplied, sets AG_WINDOW_HAS_CUSTOM_FRICTION to true
        // AG_WINDOW_CUSTOM_GROUND_FRICTION, if supplied, sets AG_WINDOW_HAS_CUSTOM_FRICTION to true
        // AG_WINDOW_SFX, if supplied, sets AG_WINDOW_HAS_SFX to true
    
    // normal defaults VVV
        // AG_WINDOW_TYPE
        // AG_WINDOW_HSPEED
        // AG_WINDOW_HSPEED_TYPE
        // AG_WINDOW_VSPEED_TYPE
        // AG_WINDOW_CUSTOM_GRAVITY
        // AG_WINDOW_HITPAUSE_FRAME
        // AG_WINDOW_CANCEL_TYPE
        // AG_WINDOW_CANCEL_FRAME
        // AG_WINDOW_SFX_FRAME
        // HG_EXTRA_CAMERA_SHAKE
        // HG_IGNORES_PROJECTILES
        // HG_HIT_LOCKOUT
        // HG_EXTENDED_PARRY_STUN
        // HG_HITBOX_GROUP
        // HG_HITSTUN_MULTIPLIER

    // obsolete, expected to be set indirectly VVV
        // AG_WINDOW_HAS_CUSTOM_FRICTION
        // AG_WINDOW_HAS_SFX

#define _get_next_open_window_index(_attack_index) {
    // Look at each window in the attack until you find one with a lifetime of 0. I think its safe to assume no window will have a lifetime of 0?
    var current_window = 1
    var max_windows = 20
    while current_window < max_windows {
        var window_length = get_window_value(_attack_index, current_window, AG_WINDOW_LENGTH)
        if window_length == 0 {
            return current_window
        }
        current_window += 1
    }
    prints("ERROR: _get_next_open_window_index found no open windows for", _attack_index, "in", get_script_name())
}

#define get_default_ag_category() {
    if is_air_attack_script() {
        return ATTACK_CATEGORY_AIR;
    } else {
        return ATTACK_CATEGORY_GROUND;
    }
}

#define get_default_whifflag(_window_name) {
    if _window_name == "recovery" {
        return 1
    } else {
        return 0
    }
}


#define get_owner() {
    var levels_searched = 0
    var max_levels_to_search = 10
    var current_level = self
    while levels_searched < max_levels_to_search {
        if current_level.object_index == oPlayer {
            return current_level
        } else {
            current_level = current_level.player
            levels_searched += 1
        }
    }
    prints("ERROR: Couldn't find an owning player for object with index", object_index)
}

#define get_window_names {
/// get_window_names(_attack = attack)
    var _attack = argument_count > 0 ? argument[0] : attack;

    owner = get_owner()
    if "_window_name_registry" not in owner {
        return []
    }
    if owner._window_name_registry[_attack] == undefined {
        return []
    }
    var names =  owner._window_name_registry[_attack]
    return names
}

#define get_window_name {
    // no args - get name of current window of current attack
    var _attack = attack
    var _index = window
    
    // 1 arg, get name of given window of current attack
    if argument_count == 1 {
        _index = argument[0]
    }
    // 2 args, get name of given window of given attack
    if argument_count == 2 {
        _attack = argument[0]
        _index = argument[1]
    }
    
    owner = get_owner()
    if "_window_name_registry" not in owner {
        return undefined
    }
    if owner._window_name_registry[_attack] == undefined {
        return undefined
    }
    // var name = owner._window_name_registry[_attack][_index] // Version for array
    var name = list_get(owner._window_name_registry[_attack], _index)
    return name
}

#define set_window_name(_attack, window_index, name) {
    owner = get_owner()
    if "_window_name_registry" not in owner {
        owner._window_name_registry = array_create(50, undefined)
    }

    if owner._window_name_registry[_attack] == undefined {
        owner._window_name_registry[_attack] = list_create(window_index, undefined)
    }
    
    list_set(owner._window_name_registry[_attack], window_index, name)
}

#define get_attack_index_from_filename() {
    var manually_set_index = variable_instance_get(self, get_attack_index_variable_name())
    if manually_set_index != undefined {
        return manually_set_index
    } else {
         var script_name = get_script_name()
        var attack_index = attack_name_to_index(script_name)
        if attack_index == undefined {
            prints("ERROR: could not find an attack named", script_name, "for easy attack functions.")
            prints("    Please call set_attack_index_for_file(AT_DAIR) for your attack of choice.")
        }
        return attack_index
    }
}


#define get_attack_index_variable_name() {
    return get_script_name() + "_attack_index"
}

#define set_attack_index_for_file(attack_index) {
    variable_instance_set(self, get_attack_index_variable_name(), attack_index)
}


#define get_ag_window_name_from_index(index) {
/// get_ag_window_name_from_index(window_name, ?attack_index = undefined)
    var index_to_name = array_create(70)
    index_to_name[AG_WINDOW_TYPE] = "AG_WINDOW_TYPE"
    index_to_name[AG_WINDOW_LENGTH] = "AG_WINDOW_LENGTH"
    index_to_name[AG_WINDOW_ANIM_FRAMES] = "AG_WINDOW_ANIM_FRAMES"
    index_to_name[AG_WINDOW_ANIM_FRAME_START] = "AG_WINDOW_ANIM_FRAME_START"
    index_to_name[AG_WINDOW_HSPEED] = "AG_WINDOW_HSPEED"
    index_to_name[AG_WINDOW_VSPEED] = "AG_WINDOW_VSPEED"
    index_to_name[AG_WINDOW_HSPEED_TYPE] = "AG_WINDOW_HSPEED_TYPE"
    index_to_name[AG_WINDOW_VSPEED_TYPE] = "AG_WINDOW_VSPEED_TYPE"
    index_to_name[AG_WINDOW_HAS_CUSTOM_FRICTION] = "AG_WINDOW_HAS_CUSTOM_FRICTION"
    index_to_name[AG_WINDOW_CUSTOM_AIR_FRICTION] = "AG_WINDOW_CUSTOM_AIR_FRICTION"
    index_to_name[AG_WINDOW_CUSTOM_GROUND_FRICTION] = "AG_WINDOW_CUSTOM_GROUND_FRICTION"
    index_to_name[AG_WINDOW_CUSTOM_GRAVITY] = "AG_WINDOW_CUSTOM_GRAVITY"
    index_to_name[AG_WINDOW_HAS_WHIFFLAG] = "AG_WINDOW_HAS_WHIFFLAG"
    index_to_name[AG_WINDOW_INVINCIBILITY] = "AG_WINDOW_INVINCIBILITY"
    index_to_name[AG_WINDOW_HITPAUSE_FRAME] = "AG_WINDOW_HITPAUSE_FRAME"
    index_to_name[AG_WINDOW_CANCEL_TYPE] = "AG_WINDOW_CANCEL_TYPE"
    index_to_name[AG_WINDOW_CANCEL_FRAME] = "AG_WINDOW_CANCEL_FRAME"
    index_to_name[AG_WINDOW_HAS_SFX] = "AG_WINDOW_HAS_SFX"
    index_to_name[AG_WINDOW_SFX] = "AG_WINDOW_SFX" 
    index_to_name[AG_WINDOW_SFX_FRAME] = "AG_WINDOW_SFX_FRAME"
    index_to_name[AG_WINDOW_GOTO] = "AG_WINDOW_GOTO"

    return index_to_name[index]
}

#define get_window_index() {
/// get_window_index(window_name, attack_index = attack;)
    var window_name = argument[0];
var attack_index = argument_count > 1 ? argument[1] : attack;;
    if attack_index == 0 || attack_index == undefined {
        attack_index = get_attack_index_from_filename()
    }
    var window_names = get_window_names(attack_index)
    var index_of_window_name = array_find_index(window_names.a, window_name)
    return index_of_window_name
}