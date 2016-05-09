class Main inherits IO {
	a : String ;
	b : String ;
	c : String ;
	d : String ;
	main () : Object {{
		a <- in_string();
		out_string(a);
		b <- in_string();
		out_string(b);
		c <- in_string();
		out_string(c);
		d <- in_string();
		out_string(d);
	}};
};
