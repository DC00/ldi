(* Expected behavior
   2 Person objects with different locations in the store
   Both objects reference the SAME name location
*)

class Person {
	name : String <- "daniel" ;
} ;

class Main inherits IO {
	main () : Object {{
		let raymond : Person <- (new Person) in
		let kpop : Person <- raymond.copy() in
		0;
	}};
} ;
