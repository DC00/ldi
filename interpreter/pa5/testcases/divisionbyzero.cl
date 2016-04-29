class IntWrapper {
	myInt : Int <- 0;
	set(newInt : Int) : Int { myInt <- newInt };
	get() : Int { myInt };
	incr() : Int { myInt <- myInt + 1 } ;
	divide() : Int { myInt <- myInt / 0 } ;
} ;


class Main inherits IO {
	a : IntWrapper <- new IntWrapper ;
	b : IntWrapper <- new IntWrapper ;

	process(x : IntWrapper, y: IntWrapper) : Object {
	{
		x.divide();
		y.divide();
	}
	} ;

	main() : Object {
	{
		a.set(11);
		b.set(33);
		process(a,b);
	}
	} ;

} ;
