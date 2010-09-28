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


GLOBAL
	camera_id;
	f_small; f_big;
	g_player_stand; g_player_stand_row;
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
	set_mode (640,480,16);
	set_fps  (30,0);
	_key_init();
	f_small = fnt_load("small.fnt");
	f_big   = fnt_load("big.fnt");
	level_start(1);

	LOOP
		if (key(_esc)) exit(); end
		if (key(_alt) && key(_f4)) exit(); end
		frame;
	END
END


PROCESS level_start(which_level)
PRIVATE
	player player_id;
	distancia;
	tiempo;
	timer_tiempo = 0;
BEGIN
	g_player_stand       = png_load("stage/" + which_level + "/player_stand.png");
	g_player_stand_row   = png_load("stage/" + which_level + "/player_stand_row.png");
	g_bomb     = png_load("stage/" + which_level + "/bomb.png");
	g_ball     = png_load("stage/" + which_level + "/ball.png");
	g_back     = png_load("stage/" + which_level + "/back.png");
	g_water    = png_load("stage/" + which_level + "/water.png");
	g_splash   = png_load("stage/" + which_level + "/splash.png");
	g_blank    = png_load("stage/blank.png");
	g_distance = png_load("stage/distance.png");
	g_time     = png_load("stage/time.png");
	point_set(0,g_splash,0,324,150);

	scroll_mechanics();
	camera_id = scroll_camera();
	scroll[0].camera = camera_id;
	camera_id.x = 200;

	player_id = player();
	bomb(220);
	bomb(1220);
	bomb(2220);
	bomb(3220);
	bomb(4220);
	bomb(5220);
//	ball(300,50,5000);
	ball(rand(0,300),rand(50,200),rand(5000,15000),rand(25,100));

	write_var(f_big,10,10,0,fps);
//	write_var(0,10,50,0,player_id.x);
//	write_var(0,10,60,0,camera_id.x);

	tiempo=99;
	gui(g_time,320,16);
	write_var(f_big,321,6,1,tiempo);
	gui(g_distance,320,468);
	write_var(f_small,122,457,1,distancia);

	fade_on();

	LOOP
		timer_tiempo++;
		if (timer_tiempo == 30)
			tiempo--;
			timer_tiempo = 0;
		end
		distancia = 75 - ((camera_id.x*100) / 8192);
		if (distancia <= 0)
			break;
		end
		if (_key(_f2,_key_down))
			break;
		end

		if ((rand(0,1000) > 950) && (!exists(type ball)))
			ball(rand(100,300),rand(50,200),rand(5000,10000),rand(25,100));
		end
		frame;
	END

	fade_off();
	for (x = 0; x < 30; x++)
		frame;
	end
	level_stop();
	level_start(which_level+1);
END


PROCESS level_stop()
BEGIN
	stop_scroll(0);
	stop_scroll(1);
	stop_scroll(2);
	stop_scroll(3);
	map_unload(0,g_player_stand);
	map_unload(0,g_player_stand_row);
	map_unload(0,g_bomb);
	map_unload(0,g_ball);
	map_unload(0,g_back);
	map_unload(0,g_water);
	map_unload(0,g_splash);
	map_unload(0,g_blank);
	map_unload(0,g_distance);
	map_unload(0,g_time);
	delete_text(ALL_TEXT);
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
		x += 5;
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
	graph = g_player_stand;
	reflejo();
//	write_var(0,10,50,0,max_speed_temp);
	LOOP
		// TODO: hacer marcador de energía sobre la cabeza de Marcos
		if (speed == 0 && max_speed <= -300)
			max_speed = 30; // debug
		end
		if (key( _right))
			x += 12 + 3;
		end
		if (key( _left))
			x -= 5 + 3;
		end
//		if (_key(_enter,_key_up))

		if (max_speed > 0)
			speed += acceleration;
			splash();
			graph = g_player_stand_row;
		else
			graph = g_player_stand;
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

		// enemy hit
		if ((collision(type bomb) || collision(type ball)) && invincible == 0)
			camera_id.angle = 500;
			invincible = 90;
			signal(type ball,S_KILL);
//			play_wav(s_explosion,0,1);
//			mission();
		end
		if (invincible > 0)
			flags = 4;
			invincible--;
		else
			flags = 0;
		end
		// if camera is going back to restart a life
		if (camera_id.angle > 0)
			x = 0;
			alpha = 0;
		else
			alpha = 256;
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
			if (y > 150)
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



PROCESS ball(y,length,angle_stepsize,size)
PRIVATE
	start_x; start_y;
	angulo = 0;
BEGIN
	ctype = C_SCROLL;
	graph = g_ball;
	start_x = camera_id.x + 300 + rand(0,300);
	start_y = y;
	x = start_x;
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
		angulo += angle_stepsize;
		frame;
	END
END
