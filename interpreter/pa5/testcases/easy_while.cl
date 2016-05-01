class Main inherits IO {
	main () : Object {{
		let count : Int <- 1 in
		while 0 < count loop {
			count <- count - 1;
			out_int(count);
		} pool;
	}};
};
