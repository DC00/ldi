class Main inherits IO {
	a : Int <- 1;
	main () : Object {
		if 1 = a
			then out_string("in if-true\n")
		else
			out_string("in if-false\n")	
		fi
	};
};
