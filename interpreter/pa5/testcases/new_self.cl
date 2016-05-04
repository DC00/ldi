(* Program that makes a new object with self *)
class A {
	a : A <- new SELF_TYPE;
};

class Main inherits IO {
	a : A <- new A;
	main () : Object { {
		let s : String <- a.type_name() in
		out_string(s);
	}};
};
