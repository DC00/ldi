class Raymond inherits Chinese {
     asian : Food <- case self of
		      n : Food => (new Rice);
		      n : Raymond => (new Food);
		      n : Rice => n;
   	         esac;

     baby : Int <- asian.gg() + grapes.gg() + gg() + happy();
     gg() : Int { (let i: Int <- yellow in { yellow <- yellow + 7; i; } ) };
	
};

class Rice inherits Food {
     dcoo : Object <- happy();
};

class Food inherits Raymond {
     f : Int <- asian@Chinese.gg();
};

class Chinese inherits IO {
     yellow : Int <- 1;
     grapes : Raymond  <- case self of
		     	n : Chinese => (new Raymond);
		     	n : Food => (new Rice);
			n : Raymond  => (new Food);
			n : Rice => n;
		  esac;

     happy() : Int { { out_int(yellow); 0; } };
     gg() : Int { (let i: Int <- yellow in { yellow <- yellow + 1; i; } ) };
};

class Main inherits IO {
  a : Chinese <- new Chinese;
  b : Raymond <- new Raymond;
  c : Food <- new Food;
  d : Rice <- new Rice;

  main(): String { { out_string("\n") ; "do nothing" ; } };

};





