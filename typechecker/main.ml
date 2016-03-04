(* Raymond Zhao rfz5nt
   Daniel Coo djc4ku 
   PA4 - Type Checker *)

open Printf

(* Used PA3 to find all the types *)

type cool_program = cool_class list
and loc = string (* these are ints but we have to put string since we are reading them*)
and id = loc * string
and cool_type = id
and cool_class = id * (id option) * feature list
and feature = 
	| Attribute of id * cool_type * (exp option)
		(* option takes care of noinit or init*)
	| Method of id * (formal list) * cool_type * exp
and formal = id * cool_type
and exp = loc * exp_kind
and exp_kind = 
	| Integer of string (* look @ comment for loc *)

let main () = begin
(*	
	printf "started main() \n" ;
*)
	(* De-serialize the CL-AST File *)

	let fname = Sys.argv.(1) in
	let fin = open_in fname in

	let read () =
		input_line fin (* FIXME: think about \r\n*)
	in

	let rec range k = 
		if k <= 0 then []
		else k :: (range(k-1))
	in
	
	let read_list worker =
		let k = int_of_string (read ()) in
		(*printf "read_list of %d\n" k ; *)
		let lst = range k in
		List.map (fun _ -> worker ()) lst
	in		

	(* many mutually-recursive procedures to read in CL_AST file *)

	let rec read_cool_program () =
		read_list read_cool_class

	and read_id () =
		let loc = read () in
		let name = read () in
		(loc, name)

	and read_cool_class () = (* CLASS *)
		let cname = read_id () in
		let inherits = match read() with
			|"no_inherits" -> None
			|"inherits" ->
				let super = read_id () in
				Some(super)
			| x -> failwith ("cannot happen: " ^ x)
		in
		let features = read_list read_feature in
		(cname, inherits, features)
	
	and read_feature () =
		match read() with
			| "attribute_no_init" ->
				let fname = read_id() in
				let ftype = read_id() in
				Attribute(fname, ftype, None)
			| "attribute_init" ->
				let fname = read_id() in
				let ftype = read_id() in
				let finit = read_exp() in
				Attribute(fname, ftype, (Some finit))
			| "method" ->
				let mname = read_id() in
				let formals = read_list read_formal in
				let mtype = read_id () in
				let mbody = read_exp () in
				Method(mname,formals,mtype,mbody)
			| x -> failwith ("cannot happen: " ^ x)

	and read_formal () =
		let fname = read_id() in
		let ftype = read_id () in
		(fname,ftype)

	and read_exp () = 
		let eloc = read () in
		let ekind = match read() with
			|"integer" ->
				let ival = read () in
				Integer(ival)
		| x -> (* FIXME: do all of the others *)
			failwith ("expression kind unhandled: " ^ x)
		in
		
		(eloc,ekind)

	in
	
	let ast = read_cool_program () in
	close_in fin ;
	(*printf "CL-AST de-serialized, %d classes\n" (List.length ast) ;*)

	(* Check for Class-Related Errors (look at PA4) *)

	let base_classes = ["Int" ; "String" ; "Bool" ; "IO" ; "Object" ] in
	let user_classes = List.map (fun ((_,cname),_,_) -> cname) ast in
	let all_classes = base_classes @ user_classes in
	let all_classes = List.sort compare all_classes in
	(* THEME IN PA4 -- you should make internal data structures to hold helper information so that you can do the checks more easily. *)


	(* Look for Inheritance from Int
	   Look for Inheritance from Undeclared Class *)

	List.iter (fun ((cloc,cname),inherits,features) ->
		match inherits with
		| None -> ()
		| Some(iloc,iname) -> (* inherited type identifier *)
			if iname = "Int" then begin
				printf "ERROR: %s: Type-Check: inheriting from forbidden class %s\n"
					iloc iname ;
				exit 1
			end ;
			if iname = "Bool" then begin
				printf "ERROR: %s: Type-Check: inheriting from forbidden class %s\n"
					iloc iname ;
				exit 1
			end ;
			if iname = "String" then begin
				printf "ERROR: %s: Type-Check: inheriting from forbidden class %s\n"
					iloc iname ;
				exit 1
			end ;
			if not (List.mem iname all_classes) then begin
				printf "ERROR: %s: Type-Check: inheriting from undefined class %s\n"
					iloc iname ;
				exit 1
			end ;
	) ast ;
				
	(* IF NO ERRORS *)

	(* CLASS MAP *)

		(* build inheritance graph*)
	
	let inheritance_tbl = Hashtbl.create 100 in
	List.iter (fun ((_,cname),inherits,_) ->
		match inherits with
			| None -> ()
			| Some (_,parentname) -> begin
				Hashtbl.add inheritance_tbl cname parentname ;
			end
	) ast ;

		(* toposort and find cycles, if cycle exists, output error *)
	

	

	let cmname = (Filename.chop_extension fname) ^ ".cl-type" in
	let fout = open_out cmname in

	let rec output_exp (eloc, ekind) =
		fprintf fout "%s\n" eloc ;
		match ekind with
			| Integer(ival) -> fprintf fout "integer\n%s\n" ival
	in
	
	fprintf fout "class_map\n%d\n" (List.length all_classes) ;
	List.iter (fun cname -> 
		(* name of class, # attrs, each attr=feature in turn *)
		fprintf fout "%s\n" cname ;
		let attributes =
			try
				let _, inherits, features =	List.find (fun ((_,cname2),_,_) -> cname = cname2) ast in
				let final_features = ref [] in 

				let rec find_parents (inherits) =
					try
						(* printf "FIND: %s\n" inherits ; *)
						let new_inherits = Hashtbl.find inheritance_tbl inherits in
						find_parents(new_inherits) @ [ inherits ] ;
					with Not_found ->
						[ inherits ]
				in
				
				let inheritance_list = match inherits with
					| Some (_,inherits) -> 
						find_parents inherits @ [ cname ]
					| None -> [ cname ]
				in

				List.iter (fun cname ->
					List.iter (fun ((_,cname2),_,feature_list) ->
						if cname = cname2 then
						final_features := !final_features @ feature_list ;
					) ast
					
				) inheritance_list ;

				List.filter (fun feature -> match feature with
					| Attribute _ -> true
					| Method _ -> false
				) !final_features

			with Not_found -> 
				[]
		in
		fprintf fout "%d\n" (List.length attributes) ;
		List.iter (fun attr -> match attr with
			| Attribute((_,aname),(_,atype),None) ->
				fprintf fout "no_initializer\n%s\n%s\n" aname atype
			| Attribute((_,aname),(_,atype),(Some init)) -> 
				fprintf fout "initializer\n%s\n%s\n" aname atype ;
				output_exp init
			| Method _ -> failwith "method unexpected"
		) attributes ;
	) all_classes ;
	close_out fout ;


end ;;
main () ;;
