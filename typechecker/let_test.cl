class Foo inherits Bazz {
     doh() : Int { (let i : Int <- h in { h <- h + 2; i; } ) };

};

class Bazz inherits IO {
     h : Int <- 1;
};

class Main inherits IO {
  a : Bazz <- new Bazz;
  b : Foo <- new Foo;
  main(): String { { out_string("\n") ; "do nothing" ; } };

};





