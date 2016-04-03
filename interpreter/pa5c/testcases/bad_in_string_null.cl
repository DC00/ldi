class Main inherits IO {
	x : String <- "" ;
	main() : Object {
	{
		x <- in_string() ;
		out_string(x) ;
	}
	} ;
} ;
