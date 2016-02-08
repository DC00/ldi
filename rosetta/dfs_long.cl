-- Daniel Coo (djc4ku)
-- Topological Sort

Class Main -- Main is where the program starts
  inherits IO { -- inheriting from IO allows us to read and write strings

	main() : Object { -- this method is invoked when the program starts
             let 
                 edges : SSList <- new SSNil, -- the sorted list input lines
                 done : Bool <- false -- are we done reading lines? 
             in {
               while not done loop {
                 let a : String <- in_string () in 
                 let b : String <- in_string () in 
                 if b = "" then (* if we are done reading lines then s will be "" *)
                   done <- true 
                 else 
                   edges <- edges.cons(a,b) 
                 fi ;
               } pool ; -- loop/pool deliniates a while loop body
				(*
			   	if l.contains("hello") then
					out_string("contains hello\n")
				else
					out_string("does not contain hello\n")
				fi ;
				*)
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

	contains(x : String) : Bool { false };
} ;


Class Cons inherits List { -- a Cons cell is a non-empty list 
	xcar : String;          -- xcar is the contents of the list head 
	xcdr : List;            -- xcdr is the rest of the list

	contains(x : String) : Bool {
		if x = xcar then
			true
		else
			xcdr.contains(x)
		fi
	} ;


	init(hd : String, tl : List) : Cons {
	  {
	    xcar <- hd;
	    xcdr <- tl;
	    self;
	  }
	};
	  
        (* insert() does insertion sort (using a reverse comparison) *) 
	insert(s : String) : List {
		if not (s < xcar) then          -- sort in reverse order
			(new Cons).init(s,self)
		else
			(new Cons).init(xcar,xcdr.insert(s))
		fi
	};

	print_list() : Object {
		{
		     out_string(xcar);
		     out_string("\n");
		     xcdr.print_list();
		}
	};
} ;

-- Build a list [1,2,3] using Cons(1, Cons(2, Cons(3, Nil)))

Class Nil inherits List { -- Nil is an empty list 

	insert(s : String) : List { (new Cons).init(s,self) }; 

	print_list() : Object { true }; -- do nothing 

	contains(x : String) : Bool { false };

} ;

-- Used for two strings
Class SSList inherits IO { 
	(* pass in two strings to make a new list *)
	cons(a : String, b : String) : SSCons { 
	  let new_cell : SSCons <- new SSCons in
		new_cell.init(a,b,self)
	};

        (* You can think of List as an abstract interface that both
         * Cons and Nil (below) adhere to. Thus you're never supposed
         * to call insert() or print_list() on a List itself -- you're
         * supposed to build a Cons or Nil and do your work there. *) 
	print_list() : Object { abort() };

	dfs(current : String, dest : String, edges : SSList,
		visited : List) : List { new List } ;
} ;


Class SSCons inherits SSList { -- a Cons cell is a non-empty list 
	xa 		: String;		-- a is the contents of left tuple part 
	xb 		: String;		-- b is the contents of right tuple part     
	xcdr	: SSList;			-- xcdr is the rest of the list



			-- self is a list of edges we still have to try
			-- but we can only Transition on an edge if
			-- "xa" matches "current"
				
			-- <A,B>
			-- <B,C>
			-- <B,D>
			-- <D, E>
			--
			-- dfs(current = B)
			-- 		skip <A,B>
			--		<B,C> -> call recursively current=C
			--		<B,D> -> call recursively current=D
			--		skip <D,E>

			

	-- (parameter : Type, parameter_b : Type ...) : Return Value
	init(a : String, b : String, tl : SSList) : SSCons {
		{
			xa <- a;
			xb <- b;
			xcdr <- tl;
			self;
		}
	};

	print_list() : Object {
		{
			out_string("<");
			out_string(xa);
			out_string(",");
		    out_string(xb);
		    out_string(">\n");
		    xcdr.print_list();
		}
	};
} ;

-- Inherits from SSList because it's the Nil thing for SSList
Class SSNil inherits SSList { -- Nil is an empty list 
	print_list() : Object { true }; -- do nothing 

	dfs(current : String, dest : String, edges : SSList,
		visited : List) : List { new Nil } ;

} ; 
