(* Simple program with a let statement *)
class Main inherits IO {
	main () : Object {{
		let x : String <- "hello, world\n" in
		out_string(x);
	}};
};
