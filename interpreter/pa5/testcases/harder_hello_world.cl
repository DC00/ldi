(* The return value for out_string is SELF_OBJECT, so chaining multiple
   methods like this is legal. This also tests for correct block implementation
*)
class Main inherits IO {
	main () : Object { {
		out_string("hello,").out_string(" world!\n");
	} };
};
