class A {
	a : Int <- 2;
	b : Int <- 3;
} ;

class Main {
	x : A <- new A;
	y : A <- new A;
	main() : Object { {
		if x = y then
			(new IO).out_string("x = y\n")
		else
			(new IO).out_string("x != y\n")
		fi;

		if x = x.copy() then
			(new IO).out_string("x = x.copy\n")
		else
			(new IO).out_string("x != x.copy\n")
		fi;
	} };
} ; 


