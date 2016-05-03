(* Program that makes a new object with self *)
class A {
	a : A <- new self;
};

class Main inherits IO {
	main () : Object {
	};
};
