class Main inherits IO {
	a : Int <- 0 ;
	b : String <- "haha\n" ;
	c : Bool <- false;
	main () : Object {{
		case c of
			n : Int => out_string("It was Int\n");
			n : String => out_string("It was String\n");
			n : Bool => out_string("It was Bool\n");
			n : Object => out_string("It was Object\n");
		esac;
	}};
};
