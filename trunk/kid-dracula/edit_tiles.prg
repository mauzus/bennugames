
#include "edit_tiles.h"

PROCESS Main()
PRIVATE
	mouse_pressed;
BEGIN
	set_title("Tile Editor");
	scale_mode = SCALE_NORMAL2X;
//	scale_mode = SCALE_SCALE2X;
//	scale_resolution = 6400480;
	set_mode(320,240,16);
	set_fps(60,0);
//	t_fps = write_var(0,10,10,0,fps);
	_key_init();

	load_tiles();
	show_tiles();
	mouse.graph = 2;

	LOOP
		if (key(_alt) && key(_f4)) save_tiles(); exit(); end
		if (key(_esc)) save_tiles(); exit(); end

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
		if (_key(_f5,_key_down))
			save_tiles();
		end
		if(mouse.left)
			if (mouse_pressed == 0)
				tile_type[((mouse.y-8)/16*20)+(mouse.x-8)/16]++;
			end
			mouse_pressed = 1;
		elseif(mouse.right)
			if (mouse_pressed == 0)
				tile_type[((mouse.y-8)/16*20)+(mouse.x-8)/16]--;
			end
			mouse_pressed = 1;
		else
			mouse_pressed = 0;
		end
		frame;
	END
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
	i = 0;
	while (!feof(fp))
		fread(tile_type+i, 1, fp);
		i++;
	end
	fclose(fp);
END

PROCESS save_tiles()
PRIVATE
	fp;
BEGIN
	fp = fopen("fpg/tiles.info",O_WRITE);
	fwrite(tile_type, tile_count, fp);
	fclose(fp);
END

PROCESS show_tiles()
PRIVATE
	i = 1;
	m_canvas;
BEGIN
	m_canvas = map_new(320,240,16);
	map_clear(0,m_canvas,rgb(255,0,255));

	for(y = 0; y < 15; y++)
		for (x = 0; x < 20; x++)
			if (i <= tile_count)
				write_var(0,x*16+8,y*16+8,0,tile_type[i-1]);
				map_xputnp(0, m_canvas, f_tiles, i, x*16+8, y*16+8, 0, 100, 100, B_NOCOLORKEY);
				i++;
			end
		end
	end
	screen_put(0, m_canvas);
END
