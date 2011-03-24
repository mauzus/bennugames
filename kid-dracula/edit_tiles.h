
import "mod_say"
import "mod_debug"

import "mod_draw"
import "mod_file"
import "mod_grproc"
import "mod_key"
import "mod_map"
import "mod_math"
import "mod_mem"
import "mod_mouse"
import "mod_proc"
import "mod_rand"
import "mod_screen"
import "mod_scroll"
import "mod_sound"
import "mod_text"
import "mod_time"
import "mod_video"
import "mod_wm"

#include "key_event.lib"

GLOBAL
	byte* tile_type;
	f_tiles;
	tile_count = 0;

	t_fps = 0;
	slow_mode = 0;
