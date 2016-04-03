class Main inherits IO {
    x : Int <- 5;
	main() : Object { {
        x <- in_int() ;
        out_int(x) ;
    }
	} ;

} ;
