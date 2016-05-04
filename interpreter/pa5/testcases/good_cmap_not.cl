class Main inherits IO{
	x : Bool <- true;
	y : Bool <- not x;
	main () : Object {
		if y then
			out_string("y was true\n")
		else
			out_string("y was false\n")
		fi
	};
};
