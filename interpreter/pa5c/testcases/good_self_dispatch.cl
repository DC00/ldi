class Main {
	x : Int;
	concat(y : Int) : Int {{
		x;
	}};
	main () : String {{ 
		let y : Int <- 5 in
		concat(y);	
		"do nothing" ; 
	}};
};
