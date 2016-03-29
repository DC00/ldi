class Main inherits IO {
	x : Int;
	funkyfresh(y:String) : Int { {
		out_string("in funkyfresh");
		let x : Int <- 2 in
		x;
	} };
	main () : String { { 
		out_string("\n") ; 
		funkyfresh(x);
		"do nothing" ; 
	}};
};
