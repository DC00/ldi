class A {
	gg() : Int {(let i : Int <- 111 in {
			i <- i + 1;
			i;
		})
	};
};

class B inherits A {
	b : B <- self;	
	gg() : Int { (let j : Int <- 222 in {
			j <- j + 999;
			j;
		})
	};
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
