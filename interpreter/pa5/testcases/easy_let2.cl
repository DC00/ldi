(* Simple program with a let statement *)
class Main inherits IO {
	main () : Object {
		let x : String <- "reddit\n", y : String <- "facebook\n" in {
		out_string(x);
		out_string(y);
		}
	};
};
