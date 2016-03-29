class Falco inherits Main {
    x : SELF_TYPE <- new Falco ;

};
class Main inherits IO {
    main ( ) : String { { out_string("\n") ; "do nothing" ; } };
} ;
