class Main inherits IO {
	x : Int <- 5 ;
	function(a : Int, b : Int) : Object {
		out_int(a + b)
	} ;
	main() : Object {
	{
		let x : Int <- 10 in
		let x : Int <- 11 in
		let x : Int <- 20 in
		function(x,x) ;
		let x : Int <- 12 in
		function(x,x <- 13) ;
		let y : Int <- 20 in
		function(x,y) ; 
	}
	} ;
} ;
