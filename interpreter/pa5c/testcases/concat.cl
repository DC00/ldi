class Main inherits IO {
	a : String <- "Hello " ;
	b : String <- "World\n" ;
	main() : Object {
		{
			let c : String <- a.concat(b) in
			out_string(c) ;
		}
	} ;
} ;
