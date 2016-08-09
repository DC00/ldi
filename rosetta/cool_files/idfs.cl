-- Daniel Coo (djc4ku)
-- DFS in Cool

class Main inherits IO {
	edges : List ;
	print(l : List) : Object { {
		(* if list is null, then stop. Else, print the head and call recursively on tail *)
		if isvoid l then
			self
		else {
			out_string(l.getA()) ;
			out_string(l.getB()) ;
			out_string("\n") ;
			print(l.getNext()) ;
		} fi ;
	} } ;
	
	-- See if list contains a string
	contains(l : List, a : String) : Bool { {
		if isvoid l then
			false
		else {
			if l.getA() = a then
				true
			else
				contains(l.getNext(), a)
			fi ;
		} fi ;
	} } ;
	printed : Bool <- false ;

	dfs(src : String, dst : String, visited : List) : Object { {
		if contains(visited, src) then
			self
		else
			if src = dst then
				if not printed then {
					out_string(src);
					out_string("\n");
					print(visited);
					printed <- true ;
				} else
					self
				fi
			else {
				-- iterator over edges
				let edge_ptr : List <- edges in
				while not (isvoid edge_ptr) loop {
					if edge_ptr.getA() = src then
						dfs(edge_ptr.getB(), dst, (new List).init(src,"",visited))
					else
						self
					fi ;
					edge_ptr <- edge_ptr.getNext() ;
				} pool ;
			} fi
		fi ;
	} } ;

	main() : Object { {
		let reading : Bool <- true in
		let visited : List in
		{
			while reading loop
				let a : String <- in_string() in
				let b : String <- in_string() in
				if b = "" then
					reading <- false
				else
					edges <- (new List).init(a,b,edges)
				fi
			pool ;
			out_string("hello, world\n");
			dfs("A", "C",visited);
		} ;
	} } ;
} ;

class List {
	a : String ;
	b : String ;
	next : List ; -- next ptr
	
	init(newa : String, newb : String, newnext : List) : List { {
		a <- newa ;
		b <- newb ;
		next <- newnext ;
		self ;
	} } ;

	getA() : String { a } ;
	getB() : String { b } ;
	getNext() : List { next } ;
} ;
