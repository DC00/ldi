class Main inherits IO {
	i : Int <- 7;
	j : Int <- 7;
	main () : Object {{
		if i = j then
			out_string("equal\n")
		else
			out_string("not equal\n")
		fi;
		0;
	}};
};
