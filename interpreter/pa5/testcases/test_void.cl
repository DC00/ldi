class Main inherits IO {
	count : Int <- 4;
	obj : Object;
	main () : Object {{
		obj <- while count < 5 loop {
			count <- count + 1;
		} pool;
		if isvoid(obj)
			then out_string("obj is void\n")
		else
			out_string("obj is NOT void\n")
		fi;
	}};
};
