-- Tests if LUB is implemented correctly
-- e should match with the closest parent, not Object
class Main inherits IO {
	main() : Object {
	{
		let b : String <- "welp" in
		let c : Object <- "raymond" in
		let d : Int <- 2 in
		let e : String <- "zhao" in

		case e of
			c : Object => out_string("Object\n");
			d : Int => out_string("Int\n");
			b : String => out_string("String\n");	
		esac;
	}
	} ;

} ;
