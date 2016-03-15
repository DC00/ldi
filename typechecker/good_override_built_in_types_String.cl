(* You are allowed to override the built in String methods *)
class BadObject {
    length() : String { "string" } ;
    concat(s:String, x:String) : String { "test" } ;
    substr(i:Int, l:Int, what:String) : Int { 3  } ;
} ;

class Main inherits IO {
    main ( ) : String { { out_string("\n") ; "do nothing" ; } };
} ;
