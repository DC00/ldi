class Main inherits IO {
	x : Int <- 4 ;
	main() : Object { {
        x <- in_int() ;
        out_int(x) ;
    }
	} ;

} ;
