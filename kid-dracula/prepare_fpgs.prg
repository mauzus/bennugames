
import "mod_map"

PROCESS Main()
PRIVATE
	temp_fpg;
	temp_png;
	i; j;

	char_points_x[] = 15,11,20, 8,23, 8,23, 8,23,11,20;
	char_points_y[] = 32,32,32,29,29,16,16, 4, 4, 0, 0;

BEGIN
	temp_fpg = fpg_new();
	for (j=1; j<=9; j++)
		temp_png = png_load("png/char/00" + j + ".png");
		for (i=0; i<=10; i++)
			point_set(0, temp_png, i, char_points_x[i], char_points_y[i]);
		end
		fpg_add(temp_fpg, j, 0, temp_png);
	end
	fpg_save(temp_fpg, "fpg/char.fpg");
END
