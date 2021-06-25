#define random()
    //Gives a random float between 0 and 1.
	var seed = _get_seed()
	var rand = _get_rand(seed)
	return rand

#define rand_int
/// rand_int(start, ?stop = undefined)
#args start, ?stop
	// If one argument supplied, return random int between 0 and the argument, inclusive.
	// If two arguments supplied, return random int between start and stop inclusive.
	// Based on python's randrange implementation.
	var istart = floor(start)
    if istart != start {
    	print("non-integer arg 1 for rand_int()")
		exit
    }
    if stop == undefined {
        if istart > 0 {
        	return _rand_up_to(istart)
        }
        print("empty range for rand_int()")
        exit
    }
    
    // stop argument supplied.
    var istop = floor(stop)
    if istop != stop{
        print("non-integer stop for rand_int()")
        exit
    }
    
    var width = istop - istart
    if width > 0 {
    	return istart + _rand_up_to(width)
    }
    prints("empty range for randrange()", start, stop)



#define _rand_up_to(stop)
	return floor(random()*(stop+1))

#define _get_seed()
	if is_draw_script() {
		return _get_local_seed()
	} else {
		return _get_synced_seed()
	}

#define is_draw_script()
	// todo this should be cached.
	var script_name = script_get_name(1)
	var contains_draw = string_pos("draw", script_name) != 0
	return contains_draw or script_name == "init_shader"

#define _get_local_seed()
	return _get_seed_from_seed_name("_local_rand_counter")
	
#define _get_synced_seed()
	return _get_seed_from_seed_name("_synced_rand_counter")

#define _get_seed_from_seed_name(seed_name)
	var seed =  variable_instance_get(self, seed_name, 0)
	variable_instance_set(self, seed_name, seed+1)
	return seed

#define _get_rand(seed)
	var mask = 0xFFFFFFFF
	return ((seed * 69069 * random_func_2(seed%200, mask, false) + 12345) & mask) / mask
