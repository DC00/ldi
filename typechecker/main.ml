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
and case_element = id * cool_type * exp
and binding = id * id * (exp option)
and exp = loc * exp_kind
and exp_kind =
	| Assign of id * exp
	| Dynamic_Dispatch of exp * id * (exp list)
	| Static_Dispatch of exp * id * id * (exp list)
	| Self_Dispatch of id * (exp list)
	| If of exp * exp * exp
	| While of exp * exp
	| Block of (exp list)
	| New of id
	| Isvoid of exp
	| Plus of exp * exp
	| Minus of exp * exp
	| Times of exp * exp
	| Divide of exp * exp
	| Lt of exp * exp
	| Le of exp * exp
	| Eq of exp * exp
	| Not of exp
	| Negate of exp
	| Integer of string
	| String of string
	| Identifier of id
	| Case of exp * (case_element list)
	| Let of (binding list) * exp
	| True
	| False

(* HELPER FUNCTIONS *)

(* Check to see if features are equal *)
let features_equal f1 f2 =
	match (f1, f2) with
		| Attribute (id, cool_type, exp), Attribute (id2, cool_type2, exp2) ->
      		let loc1, name1 = id in
      		let loc2, name2 = id2 in
			if name1 = name2 then
            	printf "ERROR: %s: Type-Check: class redefines attribute %s\n" loc2 name1 ;
      			name1 = name2
  (* Can check for method overrides here too *)
  		| _,_ -> false

let formals_equal f1 f2 =
	match (f1,f2) with
		| (id,cool_type), (id2,cool_type2) ->
			let loc1, name1 = id in
      		let loc2, name2 = id2 in
			name1 = name2

(* Check if a formal list has duplicates *)
let rec formal_duplicates lst = 
	match lst with
		| [] -> false
		| (hd :: tl) -> 
			let x = (List.filter (fun x -> formals_equal x hd) tl) in
				if x = [] then
					formal_duplicates tl
				else
					true

let main () = begin
	(* De-serialize the CL-AST File *)

	let fname = Sys.argv.(1) in
	let fin = open_in fname in

	let read () =
		input_line fin ;(* FIXME: think about \r\n*)
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

	let rec read_cool_program () =
		read_list read_cool_class

	and read_id () =
		let loc = read () in
		let name = read () in
		(loc, name)

	and read_cool_class() =
		let cname = read_id() in
		let inherits = match read() with
			|"no_inherits" -> None
			|"inherits" ->
				let super = read_id() in
				Some(super)
			| x -> failwith ("cool_class: cannot happen: " ^ x)
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
			| x -> 
				failwith ("read_feature: cannot happen: " ^ x)

	and read_formal () =
		let fname = read_id() in
		let ftype = read_id () in
		(fname,ftype)
	
	and read_case_element() =
		let var = read_id() in
		let ctype = read_id() in
		let body = read_exp() in
		(var,ctype,body)
	
	and read_binding() =
		match read() with
			| "let_binding_no_init" ->
				let var = read_id() in
				let typeid = read_id() in
				(var,typeid, None)
			| "let_binding_init" ->
				let var = read_id() in
				let typeid = read_id() in
				let idvalue = read_exp() in
				(var,typeid,(Some idvalue))
			| x -> failwith ("binding doesn't exist: " ^ x)

	and read_exp () =
		let eloc = read() in
		let ekind = match read() with
			|"assign" ->
				let var = read_id() in
				let rhs = read_exp() in
				Assign(var,rhs)
			| "dynamic_dispatch" ->
				let e = read_exp() in
				let methodid = read_id() in
				let args = read_list read_exp in
				Dynamic_Dispatch(e,methodid,args)
			| "static_dispatch" ->
				let e = read_exp() in
				let typeid = read_id() in
				let methodid = read_id() in
				let args = read_list read_exp in
				Static_Dispatch(e,typeid,methodid,args)
			| "self_dispatch" ->
				let mname = read_id() in
				let exps = read_list read_exp in
				Self_Dispatch(mname,exps)
			| "if" ->
				let pred = read_exp() in
				let then_exp = read_exp() in
				let else_exp = read_exp() in
				If(pred,then_exp,else_exp)
			| "block" ->
				let exps = read_list read_exp in
				Block(exps)
			| "while" -> 
				let pred = read_exp() in
				let body = read_exp() in
				While(pred,body)
			| "new" ->
				let new_id = read_id() in
				New(new_id)
			| "isvoid" ->
				let e = read_exp() in
				Isvoid(e)
			| "plus" ->
				let x = read_exp() in
				let y = read_exp() in
				Plus(x,y)
			| "minus" ->
				let x = read_exp() in
				let y = read_exp() in
				Minus(x,y)
			| "times" -> 
				let x = read_exp() in
				let y = read_exp() in
				Times(x,y)
			| "divide" ->
				let x = read_exp() in
				let y = read_exp() in
				Divide(x,y)
			| "lt" ->
				let x = read_exp() in
				let y = read_exp() in
				Lt(x,y)
			| "le" ->
				let x = read_exp() in
				let y = read_exp() in
				Le(x,y)
			| "eq" -> 
				let x = read_exp() in
				let y = read_exp() in
				Eq(x,y)
			| "not" -> 
				let x = read_exp() in
				Not(x)
			| "negate" ->
				let x = read_exp() in
				Negate(x)
			|"integer" ->
				let ival = read() in
				Integer(ival)
			| "string" ->
				let act_string = read() in
				String(act_string)
			| "identifier" ->
				let act_id = read_id() in
				Identifier(act_id)
			| "true" ->
				True
			| "false" ->
				False
			| "case" ->
				let case_exp = read_exp() in
				let case_list = read_list read_case_element in
				Case(case_exp,case_list)
			| "let" ->
				let binding_list = read_list read_binding in 
				let body = read_exp() in
				Let(binding_list,body)

		| x -> 
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

	let nomain =
		List.fold_left (fun acc user_class -> (user_class <> "Main") && acc) true user_classes
	in
	
	if nomain then begin
		printf "ERROR: 0: Type-Check: class Main not found\n" ;
		exit 1
	end ;
	

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
			| Assign(var,rhs) -> ()
			| Dynamic_Dispatch(e,methodid,args) ->
				let loc,str = methodid in
				fprintf fout "dynamic_dispatch\n" ;
				output_exp e ;
				fprintf fout "%s\n%s\n" loc str;
				let size = List.length args in
				fprintf fout "%d\n" size ;
				List.iter (fun arg -> output_exp arg) args ;
			| Static_Dispatch(e,typeid,methodid,args) ->
				fprintf fout "static_dispatch\n" ;
				output_exp e ;
				let type_loc,type_str = typeid in
				let method_loc,method_str = methodid in
				fprintf fout "%s\n%s\n" type_loc type_str;
				fprintf fout "%s\n%s\n" method_loc method_str;
				let size = List.length args in
				fprintf fout "%d\n" size ;
				List.iter (fun arg -> output_exp arg) args ;
			| Self_Dispatch(mname, exps) -> 
				let loc,str = mname in
				fprintf fout "self_dispatch\n" ;
				fprintf fout "%s\n%s\n" loc str;
				let size = List.length exps in
				fprintf fout "%d\n" size ;
				List.iter (fun exp -> output_exp exp) exps ;
			| If(pred,then_exp,else_exp) -> ()
			| While(pred,body) -> ()
			| Block(exps) -> ()
			| New(new_id) -> 
				let loc,str = new_id in
				fprintf fout "new\n%s\n%s\n" loc str
			| Isvoid(exp) -> ()
			| Plus(x,y) ->
				fprintf fout "plus\n" ;
				output_exp x ;
				output_exp y ;
			| Minus(x,y) ->
				fprintf fout "minus\n" ;
				output_exp x ;
				output_exp y ;
			| Times(x,y) ->
				fprintf fout "times\n" ;
				output_exp x ;
				output_exp y ;
			| Divide(x,y) ->
				fprintf fout "divide\n" ;
				output_exp x ;
				output_exp y ;
			| Lt(x,y) -> ()
			| Le(x,y) -> ()
			| Eq(x,y) -> ()
			| Not(x) -> ()
			| Negate(x) -> ()
			| Integer(ival) -> fprintf fout "integer\n%s\n" ival
			| String(act_string) -> ()
			| Identifier(act_id) ->
				let loc,str = act_id in
				fprintf fout "identifier\n%s\n%s\n" loc str
			| True -> fprintf fout "true\n"
			| False -> fprintf fout "false\n"
			| Case(case_exp, case_list) ->
				fprintf fout "case\n" ;
				output_exp case_exp ;
				let size = List.length case_list in
				fprintf fout "%d\n" size ;
				List.iter (fun case_element -> output_case_element case_element) case_list ;
			| Let(binding_list,exp) -> ()
			(* TODO: Look at each case, figure out how output works (might be later on) *)

	and output_case_element (var,typeid,exp) =
			let var_loc,var_str = var in
			let typeid_loc,typeid_str = typeid in
			fprintf fout "%s\n%s\n" var_loc var_str ;
			fprintf fout "%s\n%s\n" typeid_loc typeid_str ;
			output_exp exp ;
	in


	fprintf fout "class_map\n%d\n" (List.length all_classes) ;
	List.iter (fun cname ->
		(* name of class, # attrs, each attr=feature in turn *)
		fprintf fout "%s\n" cname ;
		let methods = 
			try
				let _, inherits, features =	List.find (fun ((_,cname2),_,_) -> cname = cname2) ast in
				List.filter (fun feature -> match feature with
					| Attribute _ -> false
					| Method _ -> true
				) features
			with Not_found ->
				[]
		in
		let attributes =
			try
				let _, inherits, features =	List.find (fun ((_,cname2),_,_) -> cname = cname2) ast in
				let final_features = ref [] in

				let rec find_parents (inherits) =
					try
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

				List.iter (fun cname3 ->
					List.iter (fun ((_,cname4),_,feature_list) ->
						if cname3 = cname4 then
							final_features := !final_features @ feature_list ;
			
              (* TODO: Need to fix *)
			  (*
			   			if cname <> cname4 then begin		
              				List.iter (fun (feature) ->
                				List.iter (fun (feature2) ->
                  					if features_equal feature feature2 then begin
                    					exit(1) ;
                  					end
                				) features ;
              				) feature_list ;
						end
				*)	
					) ast
				) inheritance_list ;
				

				List.filter (fun feature -> match feature with
					| Attribute _ -> true
					| Method _ -> false
				) !final_features

			with Not_found ->
				[]
		in

		List.iter (fun attr ->
			match attr with
				| Attribute (id,cool_type,exp) -> 
					let loc,str = id in
					if str = "self" then
						printf "ERROR: %s: Type-Check: class %s has an attribute named self\n" loc cname ;
				| _ -> ()
		) attributes ;

		List.iter (fun meth ->
			match meth with
				| Method (id,formal_list,typeid,exp) ->
					let loc,str = id in
					if str = "main" && (List.length formal_list) <> 0 then
						printf "ERROR: 0: Type-Check: class Main method main with 0 parameters not found\n";
					List.iter (fun formal ->
						let id,typeid = formal in
						let formal_loc,formal_str = id in
						if formal_str = "self" then
							printf "ERROR: %s: Type-Check: class %s has method %s with formal parameter named self\n" loc cname str;

					) formal_list ;

					List.iter (fun formal ->
						let id,typeid = formal in
						let formal_loc,formal_str = id in
						if formal_duplicates formal_list then begin
							printf "ERROR: %s: Type-Check: class %s has method %s with duplicate formal parameter named %s\n" loc cname str formal_str;
							exit(1) ;
						end
					) formal_list ;

				| _ -> ()
		) methods ;

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
