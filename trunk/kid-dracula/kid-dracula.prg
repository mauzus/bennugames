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

	LOOP
		if (key(_alt) && key(_f4)) exit(); end
		if (key(_esc)) exit(); end

		if (_key(_f1,_key_down))
			if (t_fps != 0) delete_text(t_fps); t_fps = 0;
			else t_fps = write_var(0,10,10,0,fps); end
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

	anim_state = 0;
	anim_graph[4] = 0, 0, 10, 12, 12;
	anim_leg = 1;
BEGIN
	f_char = fpg_load("fpg/char.fpg");
	file = f_char;
	graph = 1;
	x = 128;
	y = 150;
	write_var(0,10,20,0,graph);
	LOOP
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
				if (flags == 0) x++;
				else x--; end
			end
		else
			graph = 1;
			move_charge = 0;
		end

		frame;
	END
END
