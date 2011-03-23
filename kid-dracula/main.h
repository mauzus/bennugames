
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
#include "object_player.prg"

CONST
	STATE_STORY   = 0;
	STATE_PLAYING = 1;
	STATE_WAITING = 2;
	DATA_FOLDER   = "data/";

	OBJECT_TYPE_PLAYER = 1;

GLOBAL
	game_state;
	t_fps = 0;
	slow_mode = 0;
	level_struct[14][19] = 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
	                       2,2,2,2,2,2,2,13,2,2,2,2,2,2,2,2,2,2,2,2,
	                       2,2,2,2,2,2,18,14,2,2,2,2,2,2,2,2,2,2,2,2,
	                       2,2,2,2,2,17,16,15,2,2,2,2,2,2,9,9,9,9,9,9,
	                       2,2,2,2,2,2,2,2,2,2,2,2,2,9,9,2,2,2,2,2,
	                       2,2,2,2,2,2,2,2,2,2,2,9,9,9,2,2,2,2,2,2,
	                       2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,9,2,2,
	                       2,2,9,9,9,2,2,2,2,2,2,2,2,2,2,2,2,9,2,2,
	                       2,2,2,2,2,2,2,2,2,9,9,2,2,2,9,9,9,9,2,2,
	                       9,9,9,9,9,9,9,9,9,9,9,9,2,2,2,2,2,2,2,2,
	                       9,9,9,9,9,9,9,9,9,9,9,9,9,2,2,2,2,2,2,2,
	                       9,9,9,9,9,9,9,9,9,9,9,9,9,2,2,2,2,2,2,2,
	                       2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
	                       2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
	                       9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9;
