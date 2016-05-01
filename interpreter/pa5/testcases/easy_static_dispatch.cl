class A {
	gg() : Int { 111 };
};

class B inherits A {
	b : B <- self;	
	gg() : Int { 222 };
};

class C inherits B {
	csgo : Int <- b@A.gg();
};

class Main inherits IO {
	a : C <- new C;
	main () : Object {
		0
	};
};
