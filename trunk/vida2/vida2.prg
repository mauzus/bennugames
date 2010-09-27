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
	g_player; g_splash; g_bomb; g_ball; g_blank; g_back; g_water; g_distance; g_time;


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
	f_small = load_fnt("small.fnt");
	f_big   = load_fnt("big.fnt");
	g_player   = load_png("boat.png");
	g_bomb     = load_png("bomb.png");
	g_ball     = load_png("ball.png");
	g_blank    = load_png("blank.png");
	g_back     = load_png("back.png");
	g_water    = load_png("water.png");
	g_distance = load_png("distance.png");
	g_time     = load_png("time.png");
	g_splash   = load_png("splash.png");
	point_set(0,g_splash,0,324,150);
	level(1);

//	write_var(f_big,10,10,0,fps);
	LOOP
		if (key(_esc)) exit(); end
		if (key(_alt) && key(_f4)) exit(); end
		frame;
	END
END


PROCESS level(which_level)
PRIVATE
	player player_id;
	distancia;
	tiempo;
	timer_tiempo = 0;
BEGIN
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

//	write_var(0,10,50,0,player_id.x);
//	write_var(0,10,60,0,camera_id.x);

	tiempo=99;
	gui(g_time,320,16);
	write_var(f_big,321,6,1,tiempo);
	gui(g_distance,320,468);
	write_var(f_small,122,457,1,distancia);

	LOOP
		timer_tiempo++;
		if (timer_tiempo == 30)
			tiempo--;
			timer_tiempo = 0;
		end
		distancia = 75 - ((camera_id.x*100) / 8192);

		if (rand(0,1000) > 900)
			ball(rand(100,300),rand(50,200),rand(5000,10000),rand(25,100));
		end
		frame;
	END
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
BEGIN
	ctype = C_SCROLL;
	x = 20;
	y = 380;
	graph = g_player;
	alpha = 0;
	LOOP
		x += 5;
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
BEGIN
	ctype = C_SCROLL;
	x = 20;
	y = 380;
	graph = g_player;
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

		// balanceo
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
	start_x = camera_id.x + 300;
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
