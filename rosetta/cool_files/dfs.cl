-- Daniel Coo (djc4ku)
-- DFS with Cool in an OO way

-- Key Data Structures
-- 
--	List of Strings
--		"list of visited nodes"
--		add a node to a list of visited nodes
--		check membership in list of visited nodes
--		
--		"list of al nodes in the graph
--	List of (String, String) Pairs:
--		"list of edges"
--		(list of remaining edges)
--		"do DFS function over this list of edges" method
--

Class Main inherits IO {
	main() : Object {
		let 
			edges : SSList <- new SSNil,
			done : Bool <- false -- are we done reading lines? 
	 	in {
	   		while not done loop {
		 		let a : String <- in_string () in
				let b : String <- in_string () in
		 		if b = "" then
					done <- true 
		 		else 
		   			edges <- edges.cons(a,b)
		 		fi ;
	   		} pool ; -- loop/pool deliniates a while loop body
	   		edges.print_list () ; -- print out the result
	 	}
	};
};

(* The List type is not built in to Cool, so we'll have to define it 
 * ourselves. Cool classes can appear in any order, so we can define
 * List here _after_ our reference to it in Main. *) 
Class List inherits IO { 
        (* We only need three methods: cons, insert and print_list. *) 
           
        (* cons appends returns a new list with 'hd' as the first
         * element and this list (self) as the rest of the list *) 
	cons(hd : String) : Cons { 
		let new_cell : Cons <- new Cons in
		new_cell.init(hd,self)
	};

        (* You can think of List as an abstract interface that both
         * Cons and Nil (below) adhere to. Thus you're never supposed
         * to call insert() or print_list() on a List itself -- you're
         * supposed to build a Cons or Nil and do your work there. *) 
	insert(i : String) : List { self };
	print_list() : Object { abort() };
	contains(x : String) : Bool { false } ;
	
} ;

Class Cons inherits List { -- a Cons cell is a non-empty list 
	xcar : String;          -- xcar is the contents of the list head 
	xcdr : List;            -- xcdr is the rest of the list

	init(hd : String, tl : List) : Cons { {
	    xcar <- hd;
	    xcdr <- tl;
	    self;
	} };
	  
        (* insert() does insertion sort (using a reverse comparison) *) 
	insert(s : String) : List {
		if not (s < xcar) then          -- sort in reverse order
			(new Cons).init(s,self)
		else
			(new Cons).init(xcar,xcdr.insert(s))
		fi
	};

	print_list() : Object { {
		     out_string(xcar);
		     out_string("\n");
		     xcdr.print_list();
	} };
	
	contains(x : String) : Bool {
		if x = xcar then
			true
		else
			xcdr.contains(x)
		fi
	} ;
};

Class Nil inherits List { -- Nil is an empty list 
	insert(s : String) : List { (new Cons).init(s,self) }; 
	print_list() : Object { true }; -- do nothing 
	contains(x : String) : Bool { false } ;
} ;


Class SSList inherits IO { 
	cons(a : String, b : String) : SSCons {
		let new_cell : SSCons <- new SSCons in
		new_cell.init(a,b,self)
	} ;
	print_list() : Object { abort() };
} ;


Class SSCons inherits SSList { -- a Cons cell is a non-empty list 
	xa : String;
	xb : String;    	
	xcdr : SSList ;

	init(a : String, b : String, tl : SSList) : SSCons { {
	    xa <- a;
	    xb <- b;
		xcdr <- tl ;
	    self;
	} };
	  
	print_list() : Object { {
		out_string("<");
		out_string(xa);
		out_string(",");
		out_string(xb);
		out_string(">\n");
		xcdr.print_list();
	} };
};

Class SSNil inherits SSList { -- Nil is an empty lsit
	print_list() : Object { true } ;  -- do nothing
} ;
