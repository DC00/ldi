class Main inherits IO {
    h : Int;
    g : Int <- case true of
        n : Bool => 3;
        m : Int => 4;
    esac;

    main(): String { { out_string("\n") ; "do nothing" ; } };
};





