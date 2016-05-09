class A {
	a : A <- new A;
};

class Main inherits IO {
	stckvrflw : A <- new A ;
	main () : Object {
		out_string("bad\n")
	};
};
