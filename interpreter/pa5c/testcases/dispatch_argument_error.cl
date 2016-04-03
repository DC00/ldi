class Main inherits IO {
	x : Int <- 4 ;
	function(a : Int, b : Int, c : Int) : Object { out_int(c) };

	main() : Object {
	{
		function( { out_int(1) ; x ; out_int(3) ; x <- 5 ; x ; } , { out_int(2) ; x <- 2 ; x ;}, { out_int(5) ; x <- (x * 10) ; x ; } ) ;	
			
	}
	} ;

} ;
