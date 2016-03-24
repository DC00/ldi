class StringWrapper {
	myString : String <- new String;
	set(newString : String) : String { myString <- newString };
	get() : String { myString };
} ;

class Main inherits IO {
	a : StringWrapper <- new StringWrapper ;
	b : StringWrapper <- new StringWrapper ;

	main() : Object {
	{
		let c : String <- "welp" in
		let d : String <- "welpsa" in
		let e : StringWrapper in

        e.get() ;
	}
	} ;

} ;
