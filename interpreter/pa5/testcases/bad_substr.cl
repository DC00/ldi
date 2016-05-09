class Main inherits IO {
	x : Int;
	main () : String {{ 
		let s : String <- "hello world" in
		let substr : String <- s.substr(2, 15) in
		out_string(substr);	
		"do nothing" ; 
	}};
};
