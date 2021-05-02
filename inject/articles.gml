// These defines are for evaluation. They are expected to change dramatically before stabilizing.

#define get_attacked_data
/// get_attacked_data(should_launch = true, damage = 50, knockback_adj = 1, should_hitstop = true, owner_can_hit = true, teammates_can_hit = true, enemies_can_hit = true, ?filter_func = undefined)
var should_launch = argument_count > 0 ? argument[0] : true;
var damage = argument_count > 1 ? argument[1] : 50;
var knockback_adj = argument_count > 2 ? argument[2] : 1;
var should_hitstop = argument_count > 3 ? argument[3] : true;
var owner_can_hit = argument_count > 4 ? argument[4] : true;
var teammates_can_hit = argument_count > 5 ? argument[5] : true;
var enemies_can_hit = argument_count > 6 ? argument[6] : true;
var filter_func = argument_count > 7 ? argument[7] : undefined;
///ARGUMENTS
//should_launch: If true, the article will be launched on hit.
//damage: Used in knockback & hitstun calculations.
//knockback_adj: Used in knockback & hitstun calculations.
//should_hitstop: If true, the article will go into hitstop when attacked. If false, only the attacker can receive hitpause.
//owner_can_hit: If false, the owner cannot attack the article
//teammates_can_hit: If false, the owner's teammates cannot attack the article.
//respect_rock_ignore: If true, attacks that are configured to ignore Kragg's rock cannot hit this article.
//enemies_can_hit: If false, enemies (and stage hitboxes) cannot attack the article.
/*filter_func:
		If set to the name of a function (as a string), the function with that name will run on hitboxes
	that have gotten through the *_can_hit checks. It receives the article's instance ID as an argument.
	The function must return either true or false. If the function returns false, the hitbox cannot hit
	the article. If it returns true, it will continue processing normally. The filter function is run
	BEFORE collision is checked.*/

///RETURN
//The function returns a struct with the following values:
/*{
	hit: <boolean>,
	hitbox_id: <instance ID>,
	
	hitstop: <number>,
	hitstun: <number>,
	
	launch_angle: <number>,
	launch_magnitude: <number>,
	launch_hsp: <number>,
	launch_vsp: <number>
}*/
//If the article didn't get hit, only the first value (hit) will exist; everything else will be missing.
//You can use these values however you see fit if you store the output in a variable, like so:
// var hit_data = get_attacked_data(true); if(hit_data.hit) print(hit_data.hitbox_id.throws_rock);
	
	if("_hittable_time" not in self) _hittable_time = -100;
	if(_hittable_time > get_gameplay_time()) return({hit: false});
	
	var found_hitbox = noone, found_priority = -1, use_filter_func = filter_func != undefined, filter_func_index = (use_filter_func?script_get_index(filter_func):undefined);
	with(pHitBox) {
		//Cancel if the hitbox is in hitpause, or if it doesn't have sufficient priority
		if(in_hitpause) continue;
		if(hit_priority <= found_priority) continue;
		
		//Cancel if the hitbox owner isn't allowed to hit the article
		if(!owner_can_hit && player == other.player) continue;
		if(!teammates_can_hit && player != other.player && get_player_team(player) == get_player_team(other.player)) continue;
		if(!enemies_can_hit && get_player_team(player) != get_player_team(other.player)) continue;
		
		//Cancel if this hitbox is set up to ignore Kragg's rocks, or it has 0 damage
		if(throws_rock == 2 || damage <= 0) continue;
		
		//Cancel if we're using a filter function and it says so
		if(use_filter_func && !script_execute(filter_func_index, other, id)) continue;
		
		
		
		//Remember this hitbox if it can hit the article
		if(place_meeting(x + hsp - other.hsp, y + vsp - other.vsp, other)) {
			found_hitbox = id;
			found_priority = hit_priority;
		}
	}
	if(found_hitbox == noone)
		return({hit: false});
	else {
		//Polite hitboxes don't cause knockback or hitstun or whatevs...
		if(found_hitbox.effect == 9) {
			should_launch = false;
			should_hitstop = false;
		}
		
		//Hit lockout
		_hittable_time = get_gameplay_time() + found_hitbox.no_other_hit + 10;
		
		//Process knockback
		var attack_angle = get_hitbox_angle(found_hitbox), attack_uses_muno_angle = false;
		if(found_hitbox.effect == 9)
			var attack_magnitude = 0;
		else
			var attack_magnitude = knockback_adj * (found_hitbox.kb_value + (found_hitbox.kb_scale * article_damage * 0.06));
		
		if("HG_MUNO_OBJECT_LAUNCH_ANGLE" in found_hitbox.player_id) {
			//If the attack's owner is a MunoPhone character, then respect their Muno Object Launch Angle hitbox grid index
			with(found_hitbox.player_id) var muno_launch_angle = get_hitbox_value(found_hitbox.attack, found_hitbox.hbox_num, HG_MUNO_OBJECT_LAUNCH_ANGLE);
			
			//If the muno launch angle isn't zero, then we should use it
			if(muno_launch_angle != 0) {
				if(found_hitbox.spr_dir < 0) muno_launch_angle = (180 - muno_launch_angle) % 360;
				attack_angle = muno_launch_angle;
				attack_uses_muno_angle = true;
			}
			
			//Note: If the hitbox has a Muno Object Launch Angle, then it will ignore its angle flipper.
		}
		var attack_launch_hsp = lengthdir_x(attack_magnitude, attack_angle), attack_launch_vsp = lengthdir_y(attack_magnitude, attack_angle);
		if(attack_launch_vsp > 0 && !free) attack_launch_vsp *= -1; //Launch up if we're spiked on the ground
		
		//Apply knockback
		if(should_launch) { hsp = attack_launch_hsp; vsp = attack_launch_vsp; }
		
		//Process hitpause
		var attack_hitstop = found_hitbox.hitpause, attacker_hitstop = 0;
		if(found_hitbox.type == 1 && attack_hitstop > 0) {
			attacker_hitstop = attack_hitstop;
			//For melee attacks, the enemy gets hitpause
			if(found_hitbox.player_id.hitpause) {
				found_hitbox.player_id.hitstop = max(attack_hitstop, found_hitbox.player_id.hitstop);
			}
			else {
				found_hitbox.player_id.hitpause = true;
				found_hitbox.player_id.hitstop = attack_hitstop;
				found_hitbox.player_id.hitstop_full = attack_hitstop;
				found_hitbox.player_id.old_hsp = found_hitbox.player_id.hsp;
				found_hitbox.player_id.old_vsp = found_hitbox.player_id.vsp;
				found_hitbox.player_id.hsp = 0; found_hitbox.player_id.vsp = 0;
			}
		}
		//Apply hitpause to article
		attack_hitstop += found_hitbox.extra_hitpause;
		if(should_hitstop && attack_hitstop > 0) {
			hitstop = max(hitstop, attack_hitstop);
			_hittable_time += attack_hitstop;
		}
		
		//Calculate hitstun
		if(found_hitbox.effect == 9)
			var attack_hitstun = 0;
		else
			var attack_hitstun = (found_hitbox.hitstun_factor == 0?1:found_hitbox.hitstun_factor) * (found_hitbox.kb_value * 4 * ((knockback_adj - 1) * 0.6 + 1) + article_damage * 0.12 * found_hitbox.kb_scale * 4 * 0.65 * knockback_adj);
		
		//Hit reactions
		if(found_hitbox.type == 1) {
			found_hitbox.player_id.has_hit = true;
		}
		else {
			if(found_hitbox.enemies == 0) found_hitbox.destroyed = true;
		}
		
		//Hit FX and sound effect
		sound_play(found_hitbox.sound_effect);
		if(found_hitbox.hit_effect != 1) with(found_hitbox) spawn_hit_fx((x + other.x + hit_effect_x) / 2, (y + other.y + hit_effect_y) / 2, hit_effect);
		
		//Return struct
		return({
			hit: true,
			hitbox_id: found_hitbox,
			
			hitstop: attack_hitstop,
			hitstun: attack_hitstun,
			
			launch_angle: attack_angle, launch_angle_uses_muno_angle: attack_uses_muno_angle,
			launch_magnitude: attack_magnitude,
			launch_hsp: attack_launch_hsp, launch_vsp: attack_launch_vsp
		});
	}


#define lib_physics() {
    // This is especially proof of concept, as I look for optimal usability.
    if(free) {
        if(abs(hsp) < air_friction) hsp = 0;
    else hsp -= sign(hsp) * air_friction;
    vsp += fall_accel;
    if(vsp > terminal_vel) vsp = terminal_vel;
        var par_block = asset_get("par_block"), par_jumpthrough = asset_get("par_jumpthrough");
        if(!place_meeting(x, y, par_block)) { //don't try and bounce off things if we're clipped into a solid
            var bounce_plat = (vsp > 0 && !place_meeting(x, y, par_jumpthrough) && place_meeting(x, y + vsp, par_jumpthrough));
            var bounced = false;
            if(bounce_plat || place_meeting(x, y + vsp, par_block)) {
                vsp *= -1 * elasticity;
                var bounced = true;
            }
            
            if(place_meeting(x + hsp, y + vsp, par_block)) {
                hsp *= -1 * elasticity;
                var bounced = true;
            }
            if bounced {
                // On bounce code
            }
        }
    }
    else {
    if(abs(hsp) < ground_friction) hsp = 0;
    else hsp -= sign(hsp) * ground_friction;
    }
}