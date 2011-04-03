
//debug
import "mod_say"
import "mod_debug"

import "mod_draw"
import "mod_file"
import "mod_grproc"
import "mod_key"
import "mod_map"
import "mod_math"
import "mod_mem"
import "mod_proc"
import "mod_rand"
import "mod_screen"
import "mod_scroll"
import "mod_sound"
import "mod_text"
import "mod_time"
import "mod_video"
import "mod_wm"

CONST
	STATE_STORY   = 0;
	STATE_PLAYING = 1;
	STATE_WAITING = 2;
	DATA_FOLDER   = "data/";

	OBJECT_TYPE_PLAYER = 1;

	TILE_BLANK  = 0;
	TILE_SOLID  = 1;
	TILE_LADDER = 2;

GLOBAL
	f_tiles;
	byte* tile_type;
	tile_count = 0;
	scroll_map;

	game_state;
	t_fps = 0;
	slow_mode = 0;

	level_size_x;
	level_size_y;
	byte* level_struct;

#include "key_event.lib"
#include "object_player.prg"
