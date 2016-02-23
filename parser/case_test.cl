class Foo inherits Bazz {
     a : Razz <- case self of
		      n : Razz => (new Bar);
		      n : Foo => (new Razz);
		      n : Bar => n;
   	         esac;

};

class Bar inherits Razz {
};


class Razz inherits Foo {
     e : Bar <- case self of
		  n : Razz => (new Bar);
		  n : Bar => n;
		esac;
};

class Bazz inherits IO {
     h : Int <- 1;
     g : Foo  <- case self of
		     	n : Bazz => (new Foo);
		     	n : Razz => (new Bar);
			n : Foo  => (new Razz);
			n : Bar => n;
		  esac;
};

class Main inherits IO {
  main(): String { { out_string("\n") ; "do nothing" ; } };
};





