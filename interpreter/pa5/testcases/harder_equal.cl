class NVIDIA {
	gtx1080 : String <- "omg";
	get() : String { gtx1080 };
};

class Main inherits IO {
	main () : Object {{
		let 
			a : NVIDIA <- new NVIDIA,
		    b : NVIDIA <- new NVIDIA
		in {
			if a = b then
				out_string("a = b\n")
			else
				out_string("a != b\n")
			fi;

			if a.get() = b.get() then
				out_string("getA = getB\n")
			else
				out_string("getA != getB\n")
			fi;
			0;	
		};
	}};
};
