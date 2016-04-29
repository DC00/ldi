class Raymond inherits Chinese {
     baby : Int <- gg(9191);
};

class Food inherits Raymond {
     f : Int <- 5;
};

class Chinese {
     gg(x:Int) : Int { 2 };
};

class Main inherits IO {
  a : Chinese <- new Chinese;
  main(): String { { out_string("\n") ; "do nothing" ; } };

};





