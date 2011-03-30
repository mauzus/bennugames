
#define STATE_GROUND 0
#define STATE_JUMPING 1
#define STATE_FALLING 2

#define STATE_STANDING 0
#define STATE_WALKING 1

#define CP_CENTER     0
#define CP_FOOT_LEFT  1
#define CP_FOOT_RIGHT 2
#define CP_LEFT_DOWN  3
#define CP_LEFT_MID   5
#define CP_LEFT_UP    7
#define CP_RIGHT_DOWN 4
#define CP_RIGHT_MID  6
#define CP_RIGHT_UP   8
#define CP_HEAD_LEFT  9
#define CP_HEAD_RIGHT 10

PROCESS object_player(x, y)
PUBLIC
	object_pid;
	f_char;

	point_x; point_y;
	control_point[10];

	air_state  = STATE_GROUND;   // 0: not in air; 1: jumping; 2: falling down
	anim_state = STATE_STANDING; // 0: standing still; 1: walking

	i;
BEGIN
	ctype = C_SCROLL;
	object_pid = id;
	f_char = fpg_load("fpg/char.fpg");
	object_pid.file = f_char;
	object_pid.graph = 1;
//	priority = object_pid.priority - 1;
	write_var(0,10,20,0,object_pid.x);
	write_var(0,50,20,0,object_pid.y);
//	write_var(0,10,30,0,air_state);

	player_movement_x(object_pid);
	player_movement_y(object_pid);
	player_animation(object_pid);
	LOOP
		for (i = 0; i <= 10; i++)
			get_real_point(i, &point_x, &point_y);
			control_point[i] = get_tile_info(point_x, point_y);
		end

		// y position fixing
		if (control_point[CP_CENTER]     == TILE_SOLID ||
		    control_point[CP_FOOT_LEFT]  == TILE_SOLID ||
		    control_point[CP_FOOT_RIGHT] == TILE_SOLID)
			object_pid.y = (object_pid.y/16)*16;
		end

		frame;
	END
END


PROCESS player_movement_x(object_player object_pid)
PRIVATE
	move_charge;
	move_charge_max = 6;
	block_x_movement = 0;
	i;
BEGIN
//	priority = object_pid.priority - 1;
	LOOP
		if (_key(_right,_key_pressed))
			object_pid.flags = 0;
		elseif (_key(_left,_key_pressed))
			object_pid.flags = 1;
		end

		if (_key(_right,_key_pressed) || _key(_left,_key_pressed))
			if (move_charge <= move_charge_max)
				move_charge++;
			else
				object_pid.anim_state = STATE_WALKING;
				for (i = CP_RIGHT_DOWN; i <= CP_RIGHT_UP; i += 2)
					if (object_pid.control_point[i] == TILE_SOLID)
						block_x_movement = 1;
					end
				end
				if (!block_x_movement)
					if (object_pid.flags == 0) object_pid.x+=1;
					else object_pid.x-=1; end
				else
					block_x_movement = 0;
				end
			end
		else // if not pressing left or right
			object_pid.anim_state = STATE_STANDING;
			move_charge = 0;
		end

		frame;
	END
END


PROCESS player_movement_y(object_player object_pid)
PRIVATE
	gravity = 64;
	y_speed = 0;
	y_sub_speed = 0;
	y_max_speed = 4;
	i;
BEGIN
//	priority = object_pid.priority - 1;
//	write_var(0,10,50,0,y_speed);
//	write_var(0,10,60,0,y_sub_speed);
	LOOP
		// gravity
		if (object_pid.control_point[CP_FOOT_LEFT]  != TILE_SOLID &&
		    object_pid.control_point[CP_FOOT_RIGHT] != TILE_SOLID)
			if (y_speed <= y_max_speed) y_sub_speed += gravity; end
		else
			y_sub_speed = 0;
			y_speed = 0;
		end

		if (y_sub_speed >= 256)
			y_speed++;
			y_sub_speed -= 256;
		end

		// jump
		if (_key(_d,_key_down))
			y_speed = -4;
			y_sub_speed -= 196;
		end

		// if we have y_speed
		if (y_speed != 0 || y_sub_speed != 0)
			// if jumping and colliding the head
			if (object_pid.air_state != STATE_GROUND && y_speed < 0
			 && (object_pid.control_point[CP_HEAD_LEFT] == TILE_SOLID
			     || object_pid.control_point[CP_HEAD_RIGHT] == TILE_SOLID) )
				y_speed = 0;
				y_sub_speed = 0;
			else
				// update y position
				object_pid.y += y_speed;
			end
		end

		// set air_state depending on y_speed
		if (y_speed != 0)
			if (y_speed > 0)
				object_pid.air_state = STATE_FALLING;
			else
				object_pid.air_state = STATE_JUMPING;
			end
		else
			for (i = CP_CENTER; i <= CP_FOOT_RIGHT; i++)
				if (object_pid.control_point[i] == TILE_SOLID)
					object_pid.air_state = STATE_GROUND;
				end
			end
		end

		frame;
	END
END


PROCESS player_animation(object_player object_pid)
PRIVATE
	anim_count = 0;
BEGIN
//	priority = object_pid.priority - 1;
//	write_var(0,10,30,0,anim_count);
	LOOP
		if (object_pid.air_state == STATE_GROUND)
			if (object_pid.anim_state == STATE_WALKING)
				switch (anim_count)
					case 0,14..24,38..48:
						object_pid.graph = 2;
					end
					case 1..13:
						object_pid.graph = 3;
					end
					case 25..37:
						object_pid.graph = 4;
					end
				end
				anim_count++;
				if (anim_count >= 49) anim_count = 1; end
			else
				object_pid.graph = 1;
				anim_count = 0;
			end
		elseif (object_pid.air_state == STATE_FALLING)
			if (anim_count < 6)
				object_pid.graph = 6;
			else
				object_pid.graph = 7;
			end
			anim_count++;
			if (anim_count >= 12) anim_count = 0; end
		elseif (object_pid.air_state == STATE_JUMPING)
			object_pid.graph = 5;
			anim_count = 0;
		end

		frame;
	END
END
