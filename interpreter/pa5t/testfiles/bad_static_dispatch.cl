class Parent inherits IO{
	x : Int;
	funky() : Object { 
		out_string("in Parent")
	};
};

class Child inherits IO{
	y : Int;
	funky() : Object { 
		out_string("in Chile")
	};
};

class Main {
	z : Child ;
	main () : Object {
		z@Child.funky()
	};
};
