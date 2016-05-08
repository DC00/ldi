(* Simple program with a let statement *)
class Main inherits IO {
	main () : Object {{
		let x : String <- new String in
		out_string(x);
		let y : Int <- new Int in
		out_int(y);
	}};
};
