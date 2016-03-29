class A inherits IO {
	a : Int <- 1 ;	
	b : Object <- out_int(2) ;	
	c : Object <- out_int(a) ;	
} ;

class Main inherits IO {
	z : A <- new A ;
	main() : Object {
		out_string("hello")
	} ;

} ;
