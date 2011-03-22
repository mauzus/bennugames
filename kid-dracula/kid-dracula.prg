                /***********************************
                * JUEGO: "Kid Dracula Something"   *
                * PROGRAMADOR: mz                  *
                * FECHA DE INICIO: 03-20-2011      *
                * FECHA DE TERMINADO: 00-00-2011   *
                ***********************************/
//debug
import "mod_say";
import "mod_debug";

import "mod_draw";
import "mod_grproc";
import "mod_key";
import "mod_map";
import "mod_math";
import "mod_proc";
import "mod_rand";
import "mod_screen";
import "mod_scroll";
import "mod_sound";
import "mod_text";
import "mod_time";
import "mod_video";
import "mod_wm";

#include "key_event.lib"

CONST
	STATE_STORY   = 0;
	STATE_PLAYING = 1;
	STATE_WAITING = 2;
	DATA_FOLDER   = "data/";

GLOBAL
	game_state;
	t_fps = 0;
	slow_mode = 0;
	level_struct[13][15] = 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
	                       2,2,2,2,2,13,2,2,2,2,2,2,2,2,2,2,
	                       2,2,2,2,18,14,2,2,2,2,2,2,2,2,2,2,
	                       2,2,2,17,16,15,2,2,2,2,2,2,2,2,9,9,
	                       2,2,2,2,2,2,2,2,2,2,2,2,2,9,9,2,
	                       2,2,2,2,2,2,2,2,2,2,2,9,9,9,9,2,
	                       2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
	                       2,2,9,9,9,2,2,2,2,2,2,2,2,2,2,2,
	                       2,2,2,2,2,2,2,2,2,9,9,2,2,2,2,2,
	                       9,9,9,9,9,9,9,9,9,9,9,9,2,2,2,2,
	                       9,9,9,9,9,9,9,9,9,9,9,9,9,2,2,2,
	                       9,9,9,9,9,9,9,9,9,9,9,9,9,2,2,2,
	                       2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
	                       2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2;

PROCESS Main()
BEGIN
	set_title("Kid Dracula Something");
	scale_mode = SCALE_NORMAL2X;
//	scale_resolution = 6400480;
	set_mode(256,224,16);
	set_fps(60,0);
	t_fps = write_var(0,10,10,0,fps);
	_key_init();
	player();
	load_level();

	LOOP
		if (key(_alt) && key(_f4)) exit(); end
		if (key(_esc)) exit(); end

		if (_key(_f1,_key_down))
			if (t_fps != 0) delete_text(t_fps); t_fps = 0;
			else t_fps = write_var(0,10,10,0,fps); end
		end
		if (_key(_f2,_key_down))
			if (slow_mode != 0) slow_mode = 0; set_fps(60,0);
			else slow_mode = 1; set_fps(10,0); end
		end
		if (_key(_f4,_key_down) || (key(_alt) && _key(_enter,_key_down)))
			if (full_screen == 0) full_screen = 1; set_mode(256,224,16);
			else full_screen = 0; set_mode(256,224,16); end
		end
		frame;
	END
END

PROCESS player()
PRIVATE
	move_charge;
	move_charge_max = 6;
	f_char;
	i;

	anim_state = 0;
	anim_graph[4] = 0, 0, 10, 12, 12;
	anim_leg = 1;
	point_x;
	point_y;
	control_point[8];
	gravity = 64;
	y_speed = 0;
	y_sub_speed = 0;
	y_max_speed = 12;
	air_state = 0; // 0 = not in air; 1 = jumping; 2 = falling down
BEGIN
	f_char = fpg_load("fpg/char.fpg");
	file = f_char;
	graph = 1;
	x = 172;
	y = 128;
	write_var(0,10,20,0,x);
	write_var(0,50,20,0,y);
	write_var(0,10,30,0,air_state);
	write_var(0,10,40,0,y_speed);
	write_var(0,10,50,0,y_sub_speed);
	LOOP
		for (i = 0; i <= 8; i++)
			get_real_point(i, &point_x, &point_y);
			control_point[i] = get_tile_info(point_x,point_y);
		end

		// movement and animation
		if (_key(_right,_key_pressed))
			flags = 0;
		elseif (_key(_left,_key_pressed))
			flags = 1;
		end

		if (_key(_right,_key_pressed) || _key(_left,_key_pressed))
			if (move_charge <= move_charge_max)
				move_charge++;
			else
				if (graph == 1)
					graph = 2;
					anim_state = 9;
				elseif ((graph == 2) && (anim_state == anim_graph[2]))
					if (anim_leg == 1) graph = 3;
					else graph = 4; end
					anim_state = 1;
				elseif ((graph == 3 || graph == 4) && anim_state == anim_graph[3])
					graph = 2;
					anim_state = 1;
					if (anim_leg == 1) anim_leg = 2;
					else anim_leg = 1; end
				end
				anim_state++;

				if (control_point[4] != 9 && control_point[6] != 9)
					if (flags == 0) x++;
					else x--; end
				end
			end
		else
			graph = 1;
			move_charge = 0;
		end

		// jumping and gravity
		if ( (air_state == 0 && control_point[1] != 9 && control_point[2] != 9) ||
		     (air_state != 0 && (control_point[1] != 9 || control_point[2] != 9)) )
			if (y_speed <= y_max_speed)
				y_sub_speed += gravity;
			end
		else
			if (control_point[0] == 9)
				y_sub_speed = 0;
				y_speed = 0;
			end
		end

		if (y_sub_speed >= 256)
			y_speed++;
			y_sub_speed -= 256;
		end

		if (_key(_d,_key_down))
			y_speed = -4;
			y_sub_speed -= 16;
		end

		if (y_speed != 0 || y_sub_speed != 0)
			y += y_speed;
		end
		if (y_speed != 0)
			if (y_speed > 0)
				air_state = 2;
			else
				air_state = 1;
			end
		else
			air_state = 0;
		end

		// y position fixing
		if (air_state == 0 || air_state == 2)
			for (i = 0; i <= 8; i++)
				get_real_point(i, &point_x, &point_y);
				control_point[i] = get_tile_info(point_x,point_y);
			end
			if (control_point[1] == 9 || control_point[2] == 9)
				y = (y/16)*16;
			end
		end

		frame;
	END
END

FUNCTION get_tile_info(x,y)
BEGIN
	return (level_struct[y/16][x/16]);
END

PROCESS load_level()
PRIVATE
	f_tiles;
	m_canvas;
BEGIN
	f_tiles = fpg_load("fpg/tiles.fpg");
	m_canvas = map_new(256,224,16);
	map_clear(0,m_canvas,rgb(255,0,255));

	for(y = 0; y < 14; y++)
		for (x = 0; x < 16; x++)
			map_xputnp(0, m_canvas, f_tiles, level_struct[y][x], x*16+8, y*16+8, 0, 100, 100, B_NOCOLORKEY);
		end
	end
	screen_put(0, m_canvas);
END
