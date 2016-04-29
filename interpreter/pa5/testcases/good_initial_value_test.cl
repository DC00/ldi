-- Tests to see if default values are implemented and
-- that the class map is implemented in order
class Main inherits IO {
	x : Int <- 5 + y;
	y : Int <- x;
	main () : String { {
		out_int(y);
		"do nothing";
	} };
};
