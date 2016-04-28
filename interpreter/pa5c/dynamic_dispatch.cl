class A {
	method() : Object {1};
} ;
class Main {
	a : A <- new A;
	main() : Object {
		a.method()
	};
};
