class Falco {
	x : Int <- 999;
};

class Main inherits IO{
	a : Falco <- new Falco;
	main () : Object {
		out_string("done!")
	};
};
