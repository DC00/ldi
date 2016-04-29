class Fun {
    x : Int ;

    get_int(i : Int) : Bool {
        if i < 0 then
            true
        else
            get_int(i)
        fi
    } ;
} ;

class Main inherits IO {
    f : Fun <- new Fun ;
	main() : Object {
       f.get_int(0)
	};

} ;
