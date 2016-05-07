class Main inherits IO {
	x : Int;
	y : Int;
	main () : Object {{
		x <- in_int();
		out_int(x);
		y <- in_int();
		out_int(y);
	}};
};
