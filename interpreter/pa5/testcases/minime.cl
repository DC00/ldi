class Chinese inherits IO {
     grapes : Raymond  <- case self of
		     	n : Chinese => (new Raymond);
		     	n : Food => (new Rice);
				n : Raymond  => (new Food);
				n : Rice => n;
		  esac;
};
class Raymond inherits Chinese {};
class Food inherits Raymond {};
class Rice inherits Food {};
class Main inherits IO {
  a : Chinese <- new Chinese;
  main(): String { { out_string("\n") ; "do nothing" ; } };
};

