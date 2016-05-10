(* Program that makes a new object with self *)
class A {
	a : A <- new A;
};

class Main inherits IO {
	a : A <- new A;
	main () : Object {
		0
	};
};
