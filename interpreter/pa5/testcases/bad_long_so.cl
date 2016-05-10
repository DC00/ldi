class Main inherits IO {
	count : Int <- 0;
	main() : Object {{
		if count < 1001 then {
			count <- count + 1;
			main();
		} else 
			abort()
		fi;
		0;
	}};

} ;
