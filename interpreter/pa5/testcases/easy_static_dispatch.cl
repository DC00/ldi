class A inherits IO {
	gg() : String { { out_string("in A's gg\n"); "haha"; } };
};

class B inherits A {
	gg() : String { { out_string("in B's gg\n"); "haha"; } };
};

class Main inherits IO {
	a : B <- new B;
	main () : Object {{
		a@B.gg();
	}};
};
