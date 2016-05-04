class Main inherits IO {
	x : Int;
	concat(y : Int) : Int {{
		x;
	}};
	main () : String {{ 
		let y : Int <- 5 in
		concat(y);	
		out_int(y);
		"do nothing" ; 
	}};
};
