                /***********************************
                * JUEGO: "Kid Dracula Something"   *
                * PROGRAMADOR: mz                  *
                * FECHA DE INICIO: 03-20-2011      *
                * FECHA DE TERMINADO: 00-00-2011   *
                ***********************************/

#include "main.h"

PROCESS Main()
BEGIN
	set_title("Kid Dracula Something");
	scale_mode = SCALE_NORMAL2X;
	scale_mode = SCALE_SCALE2X;
//	scale_resolution = 6400480;
	set_mode(320,240,16);
	set_fps(60,0);
	t_fps = write_var(0,10,10,0,fps);
	_key_init();
	load_tiles();
	load_level();
	object(OBJECT_TYPE_PLAYER, 172, 128);

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


PROCESS object(object_type, x, y)
BEGIN
	switch(object_type)
		case OBJECT_TYPE_PLAYER:
			object_player(x, y);
		end
	end
	LOOP
		// we enter a loop so we can easily pause the game by freezing this tree
		frame;
	END
END


FUNCTION get_tile_info(x,y)
BEGIN
	return (tile_type[level_struct[y/16][x/16]]);
END


PROCESS load_level()
PRIVATE
	m_canvas;
BEGIN
	m_canvas = map_new(320,240,16);
	map_clear(0,m_canvas,rgb(255,0,255));

	for(y = 0; y < 15; y++)
		for (x = 0; x < 20; x++)
			map_xputnp(0, m_canvas, f_tiles, level_struct[y][x], x*16+8, y*16+8, 0, 100, 100, B_NOCOLORKEY);
		end
	end
	screen_put(0, m_canvas);
END

PROCESS load_tiles()
PRIVATE
	i = 1;
	fp;
BEGIN
	f_tiles = fpg_load("fpg/tiles.fpg");
	while (map_exists(f_tiles, i))
		i++;
	end
	i--;
	tile_type = alloc(i);
	memset(tile_type,0,i);
	tile_count = i;
	fp = fopen("fpg/tiles.info",O_READ);
	i = 1;
	while (!feof(fp))
		fread(tile_type+i, 1, fp);
		i++;
	end
	fclose(fp);
END
