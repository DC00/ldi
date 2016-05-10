class Main inherits IO {
	count : Int <- 2;
	bs : Int <- 0;
	gg() : String  {{
		bs <- bs + 1;
		"nothing";
	}};
	main () : Object { {
		while count < 1001 loop {
			let a : Int <- (new Int) in
			count <- count + 1;	
		} pool;
		out_int(count);
	} };
};
