class Main inherits IO {
	x : Int;
	main () : String {{ 
		let s : String in
		let i : Int <- s.length() in
		out_int(i);
		"do nothing" ; 
	}};
};
