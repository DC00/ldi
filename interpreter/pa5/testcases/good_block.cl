(* Tests for simple block imlementation
 * Blocks are evaluated from the first expression to the last expression, 
 * in order. The result is the result of the last expression
 * No Lets 
*)
class Main inherits IO{
	almost : Int <- 1;
	done : Int <- 2;
	with : Int <- 3;
	ldi : Int <- 4;	
	main () : Object { {
		almost <- 11;
		done <- 22;
		with <- 33;
		ldi <- 44; 	
		out_int(almost);
		out_int(done);
		out_int(with);
		out_int(ldi);
	} };
};
