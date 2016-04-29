class A inherits IO {
	x : Int <- 12 ;
} ;

class B inherits A {
	a : Int <- 12 ;
	newA : A <- new A ;
	newA2 : A  <- new A ;
	set(int : Int) : Object { a <- int };
	print() : Object { out_int(a) };
} ;

class C inherits B {
	newA3 : A <- new A ;
	newB : B <- new B ;
} ;

class Main inherits IO {

main() : Object {
	{
		let z : B <- new B in
		let w : B <- z.copy() in
		let a : B <- w.copy() in
		{
		if z = w then {
			out_string("they are equal\n") ;			
		} else {
			out_string("Error\n") ;
		} fi ;

		if z = a then {
			out_string("they are equal\n") ;			
		} else {
			out_string("Error\n") ;
		} fi ;

		a.set(15) ;
		w.set(13) ;
		z.print() ;
		w.print() ;
		a.print() ;

		} ;
	}
} ;

} ;
