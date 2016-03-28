class Foo inherits IO{
	foofield : Int <- 11 ;
	get() : Int { foofield };
	function(a : Int, b : Int, c : Foo) : Object { out_int(c.get()) };
} ;

class Main inherits IO {

	main() : Object {
	{
		let x : Foo <- new Foo in
		let y : Int <- 4 in
		x.function(y,{x <- new Foo ; y <- 12 ;},x) ;
			
	}
	} ;

} ;
