class Main inherits IO{
	a : Int <- 999;
	b : Bool <- 5 = 10;
	c : Bool <- 444 < 445;
	d : Int <- ~a;
	e : Bool <- 333 <= 332;
	f : Int <- d + 1;
	main () : Object {{
		out_int(a);
		out_string("\n");
		out_int(d);
		out_string("\n");
		out_int(f);
		out_string("\n");
		if e
			then out_string("e is true\n")
		else
			out_string("e is false\n")
		fi;
	}};
};
