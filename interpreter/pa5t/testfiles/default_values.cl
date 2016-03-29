class Main inherits IO {
	main() : Object {
		{
			let x : String <- new String in
			out_string(x) ;
			let y : Int <- new Int in
			out_int(y) ;
			let z : Bool <- new Bool in
			if z then {
				out_string("True\n") ;
			} else {
				out_string("False\n") ;
			} fi ;
			let w : Object <- new Object in
			if isvoid w then {
				out_string("Void\n") ;
			} else {
				out_string("Not void\n") ;
			} fi ;
		}
	} ;

} ;
