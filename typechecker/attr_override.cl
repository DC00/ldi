class Spacie {
    blaster : String ;
    waveshine : String ;
} ;

class Falco inherits Spacie {
    spike : String ;
    blaster : String ;
} ;
class Main inherits IO {
    f : Falco <- new Falco;
    main ( ) : String { { out_string("\n") ; "do nothing" ; } };
} ;
