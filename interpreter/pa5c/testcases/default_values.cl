class A inherits IO {
(* default initialization *)
	x : Object ; 
	y : Int ;
	z : Bool ;
	function() : Object { 
		if isvoid x then {
			out_string("Void\n") ;
		} else {
			out_string("NOT Void\n") ;
		} fi
	} ;
	function1() : Object { out_int(y) } ;
	function2() : Object { 
		if z then {
			out_string("True\n") ;
		} else {
			out_string("False\n") ;
		} fi
	} ;
} ;

class Main inherits IO {
	a : A <- new A ;
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
			let r : Object <- new Object in
			if isvoid r then {
				out_string("Void\n") ;
			} else {
				out_string("Not void\n") ;
			} fi ;
			a.function() ;
			a.function1() ;
			a.function2() ;
		}
	} ;

} ;
