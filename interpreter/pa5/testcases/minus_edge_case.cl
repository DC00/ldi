(* Simple program with a let statement *)
class Main inherits IO {
	main () : Object {{
		let x : Int <- 2147483647 in
		out_int(~x - 1 - 3);
	}};
};
