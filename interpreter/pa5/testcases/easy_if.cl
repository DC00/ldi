class Main inherits IO {
	a : Int <- 10;
	b : Int <- 12;
	c : Int <- 14;
	main () : Object {
		(let test : Int <- 8 in
		if a < test 
			then out_int(a)
		else if b <= test 
			then out_int(b)
		else if c < test 
			then out_int(c)
		else
			out_int(test)
		fi fi fi
		)
	};
};
