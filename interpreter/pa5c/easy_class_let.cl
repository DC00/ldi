class A {
	x : Int;
};

class Main inherits IO{
	main () : Object {
		let a : A <- new A in
		out_string("done!")
	};
};
