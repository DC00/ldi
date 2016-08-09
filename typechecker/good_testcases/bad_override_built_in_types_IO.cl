(* You are not allowed to override IO base methods.
   Tricky part: You have to inherit from IO base class
   to throw the 'override redefines method _ and changes
   return type' error

   or changes formal list error *)
class BadObject inherits IO {
    out_string(x:String, y:String) : Int { 3 } ;
    out_int(x:Int) : SELF_TYPE { self } ;
    in_string() : String { "test" } ;
    in_int() : Int { 3 } ;
} ;

class Main inherits IO {
    main ( ) : String { { out_string("\n") ; "do nothing" ; } };
} ;
