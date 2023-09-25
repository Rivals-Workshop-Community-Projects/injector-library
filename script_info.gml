#define get_already_ran
    var script_name = get_script_name()
    var already_ran = script_name in self
    if not already_ran {
        variable_instance_set(self, script_name, true)
    }
    return already_ran

#define get_script_name() {
    return script_get_name(1)
}

#define is_air_attack_script() {
    var script_name = get_script_name()
    var air_string_position = string_pos("air", script_name)
    return air_string_position == 2 // Where air is in nair, dair, fair, etc
}

#define script_exists(script_name) {
    var script_index = script_get_index(script_name)
    return script_index >= 0 
}


#define get_defines() {
    var defines = list_create(5)
    
    var i = 2
    while(true) {
        var name = script_get_name(i)
        if name == undefined {
            break;
        } else {
            list_push(defines, name)
            i += 1
        }
    }
    return defines;
}

#define attack_name_to_index(attack_name){
    var attack_names_to_indices = {
        "bair" : AT_BAIR,
        "dair" : AT_DAIR,
        "dattack" : AT_DATTACK,
        "dspecial" : AT_DSPECIAL,
        "dspecial_2" : AT_DSPECIAL_2,
        "dspecial_air" : AT_DSPECIAL_AIR,
        "dstrong" : AT_DSTRONG,
        "dstrong_2" : AT_DSTRONG_2,
        "dthrow" : AT_DTHROW,
        "dtilt" : AT_DTILT,
        "extra_1" : AT_EXTRA_1,
        "extra_2" : AT_EXTRA_2,
        "extra_3" : AT_EXTRA_3,
        "fair" : AT_FAIR,
        "fspecial" : AT_FSPECIAL,
        "fspecial_2" : AT_FSPECIAL_2,
        "fspecial_air" : AT_FSPECIAL_AIR,
        "fstrong" : AT_FSTRONG,
        "fstrong2" : AT_FSTRONG_2,
        "fthrow" : AT_FTHROW,
        "ftilt" : AT_FTILT,
        "jab" : AT_JAB,
        "nair" : AT_NAIR,
        "nspecial" : AT_NSPECIAL,
        "nspecial_2" : AT_NSPECIAL_2,
        "nspecial_air" : AT_NSPECIAL_AIR,
        "nthrow" : AT_NTHROW,
        "taunt" : AT_TAUNT,
        "taunt_2" : AT_TAUNT_2,
        "uair" : AT_UAIR,
        "uspecial" : AT_USPECIAL,
        "uspecial2" : AT_USPECIAL_2,
        "ustrong_special_ground" : AT_USPECIAL_GROUND,
        "ustrong" : AT_USTRONG,
        "ustrong_2" : AT_USTRONG_2,
        "uthrow" : AT_UTHROW,
        "utilt" : AT_UTILT,
    }
    var attack_index = variable_instance_get(attack_names_to_indices, attack_name)
    return attack_index
}