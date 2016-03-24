(* You are not allowed to override the built in Object methods
   inheriting from Object base class is optional, will still
   throw error *)
class BadObject {
    abort(x:String) : Object { 3 } ;
    type_name() : String { "test string" } ;
    copy() : SELF_TYPE { self } ;
} ;

class Main inherits IO {
    main ( ) : String { { out_string("\n") ; "do nothing" ; } };
} ;
