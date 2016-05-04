class Main inherits IO {
	main () : Object {{
		case self of
			n : Bool => out_string("Bool\n");
			n : Int => (new Int);
			n : Main => n;
		esac;
	}};
};
