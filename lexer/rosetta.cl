-- Daniel Coo (djc4ku)
-- Topological Sort with Cool


-- Main
--
-- List
-- Cons  (constructor for list)
-- Nil   (Nil class for List)
--
-- SSList  (tuple list)
-- SSCons
-- SSNil
--
-- Graph   (list of lists)
-- GraphNode  (node in graph)
-- GraphNil   (base for Graph class)
--
--


Class Main inherits IO {
	main() : Object {
		let 
			edges : SSList <- new SSNil,
			nodes : List <- new Nil,
			topo_graph : Graph <- new GraphNil,
			zero_indegree : List <- new Nil,
			sorted_list : List <- new Nil,
			is_cycle : Bool <- false,
			done : Bool <- false -- are we done reading lines? 
	 	in {
	   		while not done loop {
		 		let a : String <- in_string () in
				let b : String <- in_string () in
		 		if b = "" then
					done <- true 
		 		else { 
		   			edges <- edges.cons(a,b) ;
					if not nodes.contains(a) then
						nodes <- nodes.cons(a)
					else
						self
					fi ;

					if not nodes.contains(b) then
						nodes <- nodes.cons(b)
					else
						self
					fi ;
		 		} fi ;
	   		} pool ; -- loop/pool deliniates a while loop body
			

			(* Make graph *)
			let itr : List <- nodes in
			let n : String <- itr.get_xcar() in
			while not n = "" loop {
				topo_graph <- topo_graph.insert_key(n) ;
				itr <- itr.get_nextList() ;
				n <- itr.get_xcar() ;
			} pool ;


			let itr2 : SSList <- edges in
			let n1 : String <- itr2.get_xa() in
			let n2 : String <- itr2.get_xb() in
			let pls_stop : Bool <- false in

			while not pls_stop loop {
				topo_graph <- topo_graph.add_edge(n1, n2) ;
				itr2 <- itr2.get_next() ;
				-- itr2.get_xa() = "" also works for some reason
				if itr2.empty() then
					pls_stop <- true
				else {
					n1 <- itr2.get_xa() ;
					n2 <- itr2.get_xb() ;
				} fi ;
			} pool ;
			
		

			-- Kahn's Algorithm

			-- Assemble list of nodes with zero indegree
			-- iterate over graph
			let itr3 : Graph <- topo_graph in
			while not itr3.get_key() = "" loop {
				-- if n in topo_graph[key_node]
				if itr3.get_value(itr3.get_key()).empty() then
					zero_indegree <- zero_indegree.insert(itr3.get_key())	
				else
					self
				fi ;
				itr3 <- itr3.get_next() ;
			} pool ;
			
			let n3 : String <- "" in
			let itr4 : Graph <- topo_graph in
			while not zero_indegree.empty() loop {
				-- pop off an element from zero indegree list and
				-- append it to end of sorted list
				itr4 <- topo_graph ;
				n3 <- zero_indegree.get_xcar() ;
				zero_indegree <- zero_indegree.remove(n3) ;
				sorted_list <- sorted_list.append(n3) ;
				-- Iterate over graph
				while not itr4.get_key() = "" loop {
					let l : List <- itr4.get_value(itr4.get_key()) in
					let k : String <- itr4.get_key() in
					if l.contains(n3) then {
						-- l <- l.remove(n3) ;
						-- l.print_list() ;
						itr4.update_value(k, l.remove(n3)) ;
						l <- l.remove(n3) ;
						if l.empty() then {
							zero_indegree <- zero_indegree.insert(k) ;
						} else
							self
						fi ;
					} else
						self
					fi ;
					itr4 <- itr4.get_next() ;
				} pool ;
			} pool ;


			-- Cycle logic
			let itr5 : Graph <- topo_graph in
			while not itr5.get_key() = "" loop {
				if not itr5.get_value(itr5.get_key()).empty() then
					is_cycle <- true
				else
					self
				fi ;
				itr5 <- itr5.get_next() ;
			} pool ;

			if is_cycle = true then
				out_string("cycle\n")
			else
				sorted_list.print_list()
			fi ;


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
	empty() : Bool { true } ;
	remove(string_to_remove : String) : List { self } ;
	get_xcar() : String { "" } ;
	get_nextList() : List { self } ;
	append(s : String) : List { self } ;
} ;

Class Cons inherits List { -- a Cons cell is a non-empty list 
	xcar : String;          -- xcar is the contents of the list head 
	xcdr : List;            -- xcdr is the rest of the list

	get_xcar() : String { xcar } ;
	get_nextList() : List { xcdr } ;

	  
	insert(s : String) : List {
		if  (s < xcar) then          -- sort in order
			(new Cons).init(s,self)
		else {
			-- (new Cons).init(xcar,xcdr.insert(s))
			xcdr <- xcdr.insert(s);	
			self ;
		} fi
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

	empty() : Bool { false } ;		

	remove(string_to_remove : String) : List {
		if string_to_remove = xcar then
			xcdr.remove(string_to_remove)
		else {
			xcdr <- xcdr.remove(string_to_remove) ;
			self ;
		} fi
	} ;

	append(s : String) : List {
		(new Cons).init(xcar, xcdr.append(s))
	} ;

	init(hd : String, tl : List) : Cons { {
	    xcar <- hd;
	    xcdr <- tl;
	    self;
	} };
};

Class Nil inherits List { -- Nil is an empty list 
	get_xcar() : String { "" } ;
	get_nextList() : List { self } ;
	empty() : Bool { true } ;
	insert(s : String) : List { (new Cons).init(s,self) }; 
	print_list() : Object { true }; -- do nothing 
	contains(x : String) : Bool { false } ;
	remove(elt : String) : List { self } ;
	append(s : String) : List { (new Cons).init(s, self) } ;
} ;


Class SSList inherits IO { 
	cons(a : String, b : String) : SSCons {
		let new_cell : SSCons <- new SSCons in
		new_cell.init(a,b,self)
	} ;
	print_list() : Object { abort() };
	get_xa() : String { "" } ;
	get_xb() : String { "" } ;
	get_next() : SSList { self } ;
	empty() : Bool { false } ;
	
} ;


Class SSCons inherits SSList { -- a Cons cell is a non-empty list 
	xa : String;
	xb : String;    	
	xcdr : SSList ;


	get_xa() : String { xa } ;
	get_xb() : String { xb } ;
	get_next() : SSList { xcdr } ;
	empty() : Bool { false } ;

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
	empty() : Bool { true } ;
	print_list() : Object { true } ;  -- do nothing
} ;

Class Graph inherits IO {
	cons(hd : String) : GraphCons {
		let new_cell : GraphCons <- new GraphCons in
		new_cell.init(hd,self,new Nil)
	} ;
	
	print_graph() : Object { abort() } ;
	contains(x : String) : Bool { false } ;
	
	get_key() : String { "" } ;
	get_next() : Graph { self } ;
	get_value(k : String) : List { new Nil } ;

	insert_key(k : String) : Graph { self } ;
	add_edge(src : String, dst : String) : Graph { self } ;
	update_value(node_to_remove : String, new_value_list : List) : Object { self } ;

} ;

Class GraphCons inherits Graph {
	key : String ;
	next : Graph ;
	value_list : List ;

	get_key() : String { key } ;
	get_next() : Graph { next } ;
	get_value(k : String) : List {
		if k = key then
			value_list
		else
			next.get_value(k)
		fi
	} ; 
	
	insert_key(k : String) : Graph {
		(new GraphCons).init(key, next.insert_key(k), value_list)
	} ;

	add_edge(src : String, dst : String) : Graph {
		if key = src then {
			value_list <- value_list.insert(dst) ;
			self ;	
		} else
			(new GraphCons).init(key, next.add_edge(src, dst), value_list)
		fi
	} ;

	print_graph() : Object { {
		out_string("key: ") ;
		out_string(key) ;
		out_string("\n") ;
		value_list.print_list() ;
		next.print_graph() ;
	} } ;

	update_value(node_to_remove : String, new_value_list : List) : Object {
		if node_to_remove = key then
			value_list <- new_value_list 
		else
			next.update_value(node_to_remove, new_value_list)
		fi
	} ;

	init(k : String, n : Graph, new_value_list : List) : GraphCons { {
		key <- k ;
		next <- n ;
		value_list <- new_value_list ;
		self ;
	} } ;
} ;

Class GraphNil inherits Graph {
	get_value(k : String) : List { new Nil } ;
	get_next() : Graph { self } ;
	get_key() : String { "" } ;

	insert_key(k : String) : Graph { (new GraphCons).init(k, self, new Nil) } ;
	add_edge(src : String, dst : String) : Graph { self } ;

	print_graph() : Object { true } ;
	update_value(node_to_remove : String, new_value_list : List) : Object { true } ;
} ;
