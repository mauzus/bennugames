                /***********************************
                * JUEGO: "Marcos Lopez: Part II"   *
                * PROGRAMADOR: mz                  *
                * FECHA DE INICIO: 23-09-2010      *
                * FECHA DE TERMINADO: 00-00-2010   *
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
import "mod_scroll";
import "mod_sound";
import "mod_text";
import "mod_timers";
import "mod_video";
import "mod_wm";

#include "key_event.lib"

CONST
	STATE_STORY   = 0;
	STATE_PLAYING = 1;
	STATE_WAITING = 2;
	DATA_FOLDER   = "data/";

GLOBAL
	color_depth = 16;
	game_state;
	game_stage;
	camera_id;
	t_time; t_distance; t_fps = 0;
	f_small; f_big;
	g_player_stand; g_player_row; g_player_hitbox_stand; g_player_hitbox_row;
	g_splash; g_bomb; g_ball; g_blank; g_back; g_water; g_distance; g_time;


DECLARE PROCESS player()
	PUBLIC
		speed;
		max_speed;
	END
END


PROCESS Main()
BEGIN
	set_title("Marcos Lopez: Part II");
	set_mode (640,480,color_depth);
	set_fps  (30,0);
	_key_init();
	rand_seed(time());

	f_small               = fnt_load(DATA_FOLDER + "small.fnt");
	f_big                 = fnt_load(DATA_FOLDER + "big.fnt");
	g_player_hitbox_stand = png_load(DATA_FOLDER + "player_hitbox_stand.png");
	g_player_hitbox_row   = png_load(DATA_FOLDER + "player_hitbox_row.png");

	game_stage = 1;
	story();

	LOOP
		if (key(_esc)) exit(); end
		if (key(_alt) && key(_f4)) exit(); end

		if (_key(_f1,_key_down))
			if (t_fps != 0) delete_text(t_fps); t_fps = 0;
			else t_fps = write_var(f_big,10,10,0,fps); end
		end
		if (_key(_f3,_key_down)) // doesn't work
//			if (color_depth == 16) color_depth = 32; set_mode(640,480,color_depth);
//			else color_depth = 16; set_mode(640,480,color_depth); end
		end
		if (_key(_f4,_key_down) || (key(_alt) && _key(_enter,_key_down)))
			if (full_screen == 0) full_screen = 1; set_mode(640,480,color_depth);
			else full_screen = 0; set_mode(640,480,color_depth); end
		end
		frame;
	END
END


PROCESS level_start()
PRIVATE
	player player_id;
	distance;
	time;
	time_counter = 0;
	ball_count = 0;
BEGIN
	g_player_stand = png_load(DATA_FOLDER + game_stage + "/player_stand.png");
	g_player_row   = png_load(DATA_FOLDER + game_stage + "/player_row.png");
	g_bomb         = png_load(DATA_FOLDER + game_stage + "/bomb.png");
	g_ball         = png_load(DATA_FOLDER + game_stage + "/ball.png");
	g_back         = png_load(DATA_FOLDER + game_stage + "/back.png");
	g_water        = png_load(DATA_FOLDER + game_stage + "/water.png");
	g_splash       = png_load(DATA_FOLDER + game_stage + "/splash.png");
	g_blank        = png_load(DATA_FOLDER + "blank.png");
	g_distance     = png_load(DATA_FOLDER + "distance.png");
	g_time         = png_load(DATA_FOLDER + "time.png");
	point_set(0,g_splash,0,324,150);

	scroll_mechanics();
	camera_id = scroll_camera();
	scroll[0].camera = camera_id;
	camera_id.x = 200;

	time     = 99;
	distance = 75;
	gui(g_time,320,16);
	t_time = write_var(f_big,321,6,1,time);
	gui(g_distance,320,468);
	t_distance = write_var(f_small,122,457,1,distance);

	game_state = STATE_WAITING;
	mission_brief();
	fade_on();
	while (game_state == STATE_WAITING)
		frame;
	end

	player_id = player();
	bomb(700);
	for (x = 1; x <= 5; x++)
		bomb((200 + (1000*x) + (100*rand(0,5) + 10*rand(0,10))));
	end

//	write_var(0,10,50,0,player_id.x);
//	write_var(0,10,60,0,camera_id.x);

	game_state = STATE_PLAYING;

	LOOP
		time_counter++;
		if (time_counter == 30)
			time--;
			time_counter = 0;
		end
		distance = 75 - ((camera_id.x*100) / 8192);
		if (distance <= 0)
			break;
		end
		if (_key(_f2,_key_down))
			break;
		end

		// ball() calling
		while(get_id(type ball))
			ball_count++;
		end
		if (ball_count < game_stage)
			ball();
		end
		ball_count = 0;

		frame;
	END

	game_state = STATE_WAITING;
	mission_accomplished();
	frame(100*30*4);
	fade_off();
	frame(100*30*1);
	level_stop();
	game_stage++;
	story();
END


PROCESS level_stop()
BEGIN
	stop_scroll(0);
	stop_scroll(1);
	stop_scroll(2);
	stop_scroll(3);
	map_unload(0,g_player_stand);
	map_unload(0,g_player_row);
	map_unload(0,g_bomb);
	map_unload(0,g_ball);
	map_unload(0,g_back);
	map_unload(0,g_water);
	map_unload(0,g_splash);
	map_unload(0,g_blank);
	map_unload(0,g_distance);
	map_unload(0,g_time);
	delete_text(t_time);
	delete_text(t_distance);
	signal(type gui, s_kill);
	signal(type scroll_mechanics, s_kill);
	signal(type scroll_camera, s_kill);
	signal(type player, s_kill);
	signal(type splash, s_kill);
	signal(type reflejo, s_kill);
	signal(type bomb, s_kill);
	signal(type ball, s_kill);
END


PROCESS gui(graph,x,y)
BEGIN
	LOOP
		frame;
	END
END


PROCESS mission_brief()
PRIVATE
	g_gui;
BEGIN
	g_gui = png_load(DATA_FOLDER + game_stage + "/mission.png");
	graph = g_gui;
	flags = B_NOCOLORKEY;
	x = 320;
	y = 240;
	frame(100*30*1);
	WHILE (scan_code == 0)
		frame;
	END
	graph = 0;
	map_unload(0,g_gui);
	frame(100*30/2);
	game_state = STATE_PLAYING;
END


PROCESS mission_accomplished()
PRIVATE
	g_gui;
BEGIN
	g_gui = png_load(DATA_FOLDER + "mission_accomplished.png");
	graph = g_gui;
	flags = B_NOCOLORKEY;
	x = 320;
	y = 240;
	frame(100*30*4);
	graph = 0;
	map_unload(0,g_gui);
END


PROCESS story()
PRIVATE
	g_gui; g_picture; g_story; s_story; w_story;
BEGIN
	g_gui     = png_load(DATA_FOLDER + "story.png");
	g_picture = png_load(DATA_FOLDER + game_stage + "/picture.png");
	g_story   = png_load(DATA_FOLDER + game_stage + "/story.png");
	s_story   = load_song(DATA_FOLDER + game_stage + "/story.ogg");

	screen_put(0,g_picture);
	xput(0,g_gui,320,480-34-68/2,0,100,B_NOCOLORKEY,0);
	put(0,g_story,320,480-34-68/2+4);
	drawing_alpha(128);
	drawing_color(rgb(255,0,0));
	draw_box(0,480-34,640,480);

	fade_on();
//	w_story = play_song(s_story,0);
	WHILE (is_playing_song())
		frame;
	END

	fade_off();
	frame(100*30*1);

	map_unload(0,g_gui);
	map_unload(0,g_picture);
	map_unload(0,g_story);
	unload_song(s_story);
	delete_draw(0);
	screen_clear();

	level_start();
END


PROCESS scroll_mechanics()
PRIVATE
	scroll_blit = 4;
BEGIN
	start_scroll(0,0,g_blank,0,0,1);

	start_scroll(1,0,g_back,0,0,2);
	scroll[1].y0 = 480*4;
	scroll[1].z = 2048;

	start_scroll(2,0,g_water,g_water,0,15);
	scroll[2].ratio = 0;
	scroll[2].x0 = rand(0,1024);
	scroll[2].x1 = rand(0,1024);
	scroll[2].y0 = 150+640*4;
	scroll[2].y1 = 170+640*4;
	scroll[2].flags1 = scroll_blit;
	scroll[2].flags2 = scroll_blit;
	scroll[2].z = 1024;

	start_scroll(3,0,g_water,g_water,0,15);
	scroll[3].ratio = 0;
	scroll[3].x0 = rand(0,1024);
	scroll[3].x1 = rand(0,1024);
	scroll[3].y0 = 100+640*4;
	scroll[3].y1 = 130+640*4;
	scroll[3].flags1 = scroll_blit;
	scroll[3].flags2 = scroll_blit;

	LOOP
		scroll[1].x0 = (scroll[0].x0*1024)/16384;
		scroll[2].x1 += 2;
		scroll[2].x0 += 4;
		scroll[3].x1 += 8;
		scroll[3].x0 += 16;
		frame;
	END
END


PROCESS scroll_camera()
PRIVATE
	back_step = 50;
BEGIN
	ctype = C_SCROLL;
	x = 20;
	y = 380;
	graph = g_player_stand;
	alpha = 0;
	LOOP
		if (game_state != STATE_WAITING)
			x += 5;
		end
//		x += 75;
		if (angle > 0)
			angle -= back_step;
			x -= back_step;
		end
		if (x < 200)
			x = 200;
			angle = 0;
		end
		if (x > 8192-2048)
			x = 8192-2048;
		end
		frame;
	END
END


PROCESS player()
PRIVATE
	acceleration = 4;
	max_speed_temp = 0;
	angle_direction = 0;
	_ANGLE_RIGHT = 0;
	_ANGLE_LEFT = 1;
	invincible;
BEGIN
	ctype = C_SCROLL;
	x = 20;
	y = 380;
	graph = g_player_hitbox_stand;
	alpha = 0;
	player_graph();
//	write_var(0,10,50,0,max_speed_temp);
	LOOP
		if (game_state != STATE_WAITING)
			if (speed == 0 && max_speed <= -300)
				max_speed = 30;
			end
			if (key( _right))
				x += 12 + 3;
			end
			if (key( _left))
				x -= 5 + 3;
			end
	
			if (max_speed > 0)
				speed += acceleration;
				splash();
				graph = g_player_hitbox_row;
			else
				graph = g_player_hitbox_stand;
			end
			max_speed -= acceleration;
	
			if (speed > 0)
				speed--;
			end
			if (speed <= 0)
				x -= 2;
			end
	
			x += speed;
			if (x > (camera_id.x+200))
				x = camera_id.x+200;
			end
			if (x < (camera_id.x-200))
				x = camera_id.x-200;
			end

			// enemy hit
			if (((collision(type bomb) || collision(type ball)) && invincible == 0))
				camera_id.angle = 600;
				invincible = 90;
				signal(type ball,S_KILL);
	//			play_wav(s_explosion,0,1);
			end
			if (invincible > 0)
				flags = 4;
				invincible--;
			else
				flags = 0;
			end
		else // STATE_WAITING
			graph = g_player_hitbox_stand;
			flags = 0;
			invincible = 0;
			x += 4;
		end

		// bamboleo
		if (angle_direction == _ANGLE_RIGHT)
			angle += 200;
		end
		if (angle_direction == _ANGLE_LEFT)
			angle -= 200;
		end
		if (angle > 4000)
			angle_direction = _ANGLE_LEFT;
			angle = 4000;
		end
		if (angle < -4000)
			angle_direction = _ANGLE_RIGHT;
			angle = -4000;
		end
		frame;
	END
END


PROCESS player_graph()
BEGIN
	ctype = C_SCROLL;
	y = father.y;
	graph = g_player_stand;
	priority = father.priority - 1;
	reflejo();
	WHILE (exists(father))
		x     = father.x;
		angle = father.angle;
		flags = father.flags;
		if (father.graph == g_player_hitbox_stand)
			graph = g_player_stand;
		else
			graph = g_player_row;
		end

		// if camera is going back to restart a life
		if (camera_id.angle > 0)
			father.x = 0;
			x        = 0;
			alpha    = 0;
		else
			alpha    = 256;
		end
		frame;
	END
END


PROCESS splash()
PRIVATE
	explotando=25;
BEGIN
	ctype = C_SCROLL;
	graph = g_splash;
	flags = B_TRANSLUCENT;
	size = 80;
	x = father.x + 70;
	y = father.y + 55;
	z = father.z - 1;
	reflejo();
	LOOP
		if (explotando >= 1)
			x += 15;
			size -= 5;
			explotando--;
		else
			break;
		end
		frame;
	END
END


PROCESS reflejo()
BEGIN
	ctype = C_SCROLL;
	graph = father.graph;
	z     = father.z + 1;
	priority = father.priority - 1;
	flags = B_VMIRROR | B_TRANSLUCENT;
	WHILE (exists(father))
		x = father.x;
		y = 380 + (380 - father.y) + 95; // why 95?!?!
		if (y < (father.y+48))
			y = father.y+48;
		end
		size  = father.size;
		frame;
	END
END


PROCESS bomb(x)
PRIVATE
	direction = 0;
	_GOING_DOWN = 0;
	_GOING_UP = 1;
BEGIN
	ctype = C_SCROLL;
	y = 350;
	graph = g_bomb;
	reflejo();
	LOOP
		if (direction == _GOING_UP)
			if (y > (150 - (4 - game_stage) * 5) )
				y -= 5;
			else
				direction = _GOING_DOWN;
			end
		end
		if (direction == _GOING_DOWN)
			if (y < 350)
				y += 20;
			else
				direction = _GOING_UP;
			end
		end
		frame;
	END
END



PROCESS ball()
PRIVATE
	start_x;
	start_y;
	length;
	angle_stepsize;
	angulo = 0;
BEGIN
	ctype = C_SCROLL;
	graph = g_ball;
	rand_seed(get_timer() + time() + rand(0,20000));
	start_x = camera_id.x + 555 + rand(0,1000+100*game_stage);
	start_y = rand(100,300);
	x = start_x;
	y = start_y;
	size = rand(25,100);
	z = 75 - size;
	length = rand(100,150);
	angle_stepsize = rand(7000,9000);
	reflejo();

	WHILE (x > camera_id.x-400)
		x = start_x - (angulo/1000);
		y = start_y + (length * sin(angulo));
		if (y < 10)
			y = 10;
		end
		if (y > 470)
			y = 470;
		end
		if (game_stage != 2)
			angle = angulo;
		end
		angulo += angle_stepsize;
		frame;
	END
END
