(* Raymond Zhao rfz5nt
   Daniel Coo djc4ku
   PA4 - Type Checker *)

open Printf

type static_type =
	| Class of string
	| SELF_TYPE of string
let type_to_str t = match t with
	| Class(x) -> x
	| SELF_TYPE(c) -> "SELF_TYPE"

let rec is_subtype t1 t2 =
	match t1,t2 with
		| Class(x), Class(y) when x = y -> true
		| Class(x), Class("Object") -> true
		| Class(x), Class(y) -> false (* TODO: check the parent map *)
		| _,_ -> false (* TODO: Check the class notes *)
		(* TODO: Do the 8 CASES HERE *)

type object_environment =
	(string,static_type) Hashtbl.t

let empty_object_environment() = Hashtbl.create 255

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
and exp = {
	loc : loc ;
	exp_kind : exp_kind ;
	mutable static_type : static_type option
}

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




(* Helper function for rtrim. Find rightmost position of string *)
let right_pos s len =
    let rec aux i =
        if i < 0 then None
        else match s.[i] with
            | ' ' | '\n' | '\t' | '\r' -> aux (pred i)
            | _ -> Some i
	in
aux (pred len)

(* Trim tabs, newlines, and carriage chars from right side of string *)
let rtrim s =
    let len = String.length s in
    match right_pos s len with
        | Some i -> String.sub s 0 (i + 1)
        | None -> ""

let main () = begin
	(* De-serialize the CL-AST File *)

	let fname = Sys.argv.(1) in
	let fin = open_in fname in

	let read () =
            let line_in = input_line fin in
            rtrim line_in
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

		{
			loc = eloc ;
			exp_kind = ekind ;
			static_type = None ;
		}

	in

	let ast = read_cool_program () in
	close_in fin ;
	(*printf "CL-AST de-serialized, %d classes\n" (List.length ast) ;*)

	(* Check for Class-Related Errors (look at PA4) *)

	let base_classes = ["Int" ; "String" ; "Bool" ; "IO" ; "Object" ] in
	let user_classes = List.map (fun ((_,cname),_,_) -> cname) ast in
	let all_classes = base_classes @ user_classes in
	let all_classes = List.sort compare all_classes in
	let valid_types = all_classes @ ["SELF_TYPE"] in

	(*
		for IO - same as Object but needs to inherit IO
			out_string (1)
			out_int (1)
			in_string (0)
			in_int (0)
	*)
	let object_methods = [("abort","Object", 0) ; ("type_name","String",0) ; ("copy","SELF_TYPE",0)] in

	(* TODO: Fix IO error
	let io_methods = [("out_string","SELF_TYPE",1) ; ("out_int","SELF_TYPE",1) ; ("in_string","String",0) ; ("in_int","Int",0)] in
	*)
	(* THEME IN PA4 -- you should make internal data structures to hold helper information so that you can do the checks more easily. *)


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

	List.iter (fun cname ->
		let duplicates = List.find_all(fun ((_,cname2),_,_) -> cname = cname2) ast in
		if List.length duplicates > 1 then
			let duplicates_tail = List.tl duplicates in
			List.iter (fun class_iter ->
				let (class_loc,redefined_class),_,_ = class_iter in
				printf "ERROR: %s: Type-Check: class %s redefined \n" class_loc redefined_class ;
				exit(1)
			) duplicates_tail ;
	) all_classes ;

	List.iter (fun cname ->
		let (loc,name),_,_ = List.find(fun ((_,cname2),_,_) -> cname = cname2) ast in
		if cname = "Object" then
			printf "ERROR: %s: Type-Check: class %s redefined \n" loc name ;
		if cname = "SELF_TYPE" then
			printf "ERROR: %s: Type-Check: class named %s\n" loc cname ;
	) user_classes ;

	(* TYPECHECKING *)

	let rec typecheck (o: object_environment) (* TODO: M C *) (exp : exp) : static_type =
		let static_type = match exp.exp_kind with
			| While(e1,e2) ->
				let t1 = typecheck o e1 in
				if t1 <> (Class "Bool") then begin
					printf "ERROR: %s: Type-Check predicate has type %s instead of Bool \n"
					exp.loc (type_to_str t1) ;
					exit 1 ;
				end ;
				(Class "Object")

			| Block(elist) ->
				let t = typecheck o (List.hd (List.tl elist)) in
				t ;
		(*
			| New(e) ->
		*)
			| Isvoid(e) -> (Class "Bool")
			| Plus(e1,e2) ->
				let t1 = typecheck o e1 in
				if t1 <> (Class "Int") then begin
					printf "ERROR: %s: Type-Check: adding %s instead of Int\n"
					exp.loc (type_to_str t1) ;
					exit 1 ;
				end ;
				let t2 = typecheck o e2 in
				if t2 <> (Class "Int") then begin
					printf "ERROR: %s: Type-Check: adding %s instead of Int\n"
					exp.loc (type_to_str t2) ;
					exit 1 ;
				end ;
				(Class "Int")
			| Minus(e1,e2) ->
				let t1 = typecheck o e1 in
				if t1 <> (Class "Int") then begin
					printf "ERROR: %s: Type-Check: subtracting %s instead of Int\n"
					exp.loc (type_to_str t1) ;
					exit 1 ;
				end ;
				let t2 = typecheck o e2 in
				if t2 <> (Class "Int") then begin
					printf "ERROR: %s: Type-Check: subtracting %s instead of Int\n"
					exp.loc (type_to_str t2) ;
					exit 1 ;
				end ;
				(Class "Int")
			| Times(e1,e2) ->
				let t1 = typecheck o e1 in
				if t1 <> (Class "Int") then begin
					printf "ERROR: %s: Type-Check: multiplying %s instead of Int\n"
					exp.loc (type_to_str t1) ;
					exit 1 ;
				end ;
				let t2 = typecheck o e2 in
				if t2 <> (Class "Int") then begin
					printf "ERROR: %s: Type-Check: multiplying %s instead of Int\n"
					exp.loc (type_to_str t2) ;
					exit 1 ;
				end ;
				(Class "Int")
			| Divide(e1,e2) ->
				let t1 = typecheck o e1 in
				if t1 <> (Class "Int") then begin
					printf "ERROR: %s: Type-Check: dividing %s instead of Int\n"
					exp.loc (type_to_str t1) ;
					exit 1 ;
				end ;
				let t2 = typecheck o e2 in
				if t2 <> (Class "Int") then begin
					printf "ERROR: %s: Type-Check: dividing %s instead of Int\n"
					exp.loc (type_to_str t2) ;
					exit 1 ;
				end ;
				(Class "Int")
			| Lt(e1,e2) ->
				let t1 = typecheck o e1 in
				let t2 = typecheck o e2 in
				(match t1 with
					| (Class "Int") ->
						if t2 <> (Class "Int") then begin
							printf "ERROR: %s: Type-Check: comparison between Int and %s"
							exp.loc (type_to_str t2) ;
							exit 1 ;
						end
					| (Class "Bool") ->
						if t2 <> (Class "Bool") then begin
							printf "ERROR: %s: Type-Check: comparison between Bool and %s"
							exp.loc (type_to_str t2) ;
							exit 1 ;
						end ;
					| (Class "String") ->
						if t2 <> (Class "String") then begin
							printf "ERROR: %s: Type-Check: comparison between String and %s"
							exp.loc (type_to_str t2) ;
							exit 1 ;
						end ;
					| _ -> () );
				(Class "Bool")
			| Le(e1,e2) ->
				let t1 = typecheck o e1 in
				let t2 = typecheck o e2 in
				(match t1 with
					| (Class "Int") ->
						if t2 <> (Class "Int") then begin
							printf "ERROR: %s: Type-Check: comparison between Int and %s"
							exp.loc (type_to_str t2) ;
							exit 1 ;
						end
					| (Class "Bool") ->
						if t2 <> (Class "Bool") then begin
							printf "ERROR: %s: Type-Check: comparison between Bool and %s"
							exp.loc (type_to_str t2) ;
							exit 1 ;
						end ;
					| (Class "String") ->
						if t2 <> (Class "String") then begin
							printf "ERROR: %s: Type-Check: comparison between String and %s"
							exp.loc (type_to_str t2) ;
							exit 1 ;
						end ;
					| _ -> () );
				(Class "Bool")
			| Eq(e1,e2) ->
				let t1 = typecheck o e1 in
				let t2 = typecheck o e2 in
				(match t1 with
					| (Class "Int") ->
						if t2 <> (Class "Int") then begin
							printf "ERROR: %s: Type-Check: comparison between Int and %s"
							exp.loc (type_to_str t2) ;
							exit 1 ;
						end
					| (Class "Bool") ->
						if t2 <> (Class "Bool") then begin
							printf "ERROR: %s: Type-Check: comparison between Bool and %s"
							exp.loc (type_to_str t2) ;
							exit 1 ;
						end ;
					| (Class "String") ->
						if t2 <> (Class "String") then begin
							printf "ERROR: %s: Type-Check: comparison between String and %s"
							exp.loc (type_to_str t2) ;
							exit 1 ;
						end ;
					| _ -> () );
				(Class "Bool")
			| Not(e) ->
				let t = typecheck o e in
				if t <> (Class "Bool") then begin
					printf "ERROR: %s: Type-Check: not applied to type %s instead of Bool"
					exp.loc (type_to_str t)	;
					exit 1 ;
				end ;
				(Class "Bool")
			| Negate(e) ->
				let t = typecheck o e in
				if t <> (Class "Int") then begin
					printf "ERROR: %s: Type-Check: negate applied to type %s instead of Int"
					exp.loc (type_to_str t) ;
					exit 1 ;
				end ;
				(Class "Int")
			| Integer(i) -> (Class "Int")
			| String(e) -> (Class "String")
			| Identifier(vloc,vname) ->
				if Hashtbl.mem o vname then
					Hashtbl.find o vname
				else begin
					printf "ERROR: %s: Type-Check: undeclared variable %s\n" vloc vname ;
					exit 1 ;
				end
			| True -> (Class "Bool")
			| False -> (Class "Bool")
			| _ -> failwith("Expression unhandled")
				(* TODO: apply to every expression *)
		in
		exp.static_type <- Some(static_type) ;
		static_type
	in

	List.iter (fun ((cloc,cname),inherits,features) ->
		List.iter (fun feat ->
			match feat with
				| Attribute((nameloc,name),(dtloc,declared_type),Some(init_exp)) ->
					let o = empty_object_environment() in
						(* TODO: add all features to object environment *)
					let init_type = typecheck o init_exp in
					if is_subtype init_type (Class declared_type) then
						()
					else begin
						printf "ERROR: %s: Type-Check: initializer for %s was %s did not match declared %s\n" nameloc name (type_to_str init_type) declared_type
					end
				| _ -> () (* TODO: Method dealing *)
		) features ;
	) ast ;

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


    Hashtbl.add inheritance_tbl "Bool" "Object" ;
    Hashtbl.add inheritance_tbl "String" "Object" ;
    Hashtbl.add inheritance_tbl "Int" "Object" ;
    Hashtbl.add inheritance_tbl "IO" "Object" ;

	let cmname = (Filename.chop_extension fname) ^ ".cl-type" in
	let fout = open_out cmname in

	let rec output_exp e =
		fprintf fout "%s\n" e.loc ;
		(match e.static_type with
			| None -> failwith "we forgot to do typechecking"
			| Some(Class(c)) -> fprintf fout "%s\n" c
			| Some(SELF_TYPE(c)) -> failwith "TODO: FIX THIS PLZ"
		) ;
		match e.exp_kind with
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
				let cycle_detect = ref [] in

				let rec find_parents (inherits) =
					try
						let new_inherits = Hashtbl.find inheritance_tbl inherits in

						if List.mem inherits !cycle_detect then begin
							printf "ERROR: 0: Type-Check: inheritance cycle\n " ;
							exit(1) ;
						end
						else
							cycle_detect := !cycle_detect @ [inherits] ;

						find_parents(new_inherits) @ [ inherits ] ;
					with Not_found ->
						[ inherits ] ;
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
					let type_loc,type_str = typeid in
					let len = List.length formal_list in
					if str = "main" && len <> 0 then
						printf "ERROR: 0: Type-Check: class Main method main with 0 parameters not found\n";
					if not (List.mem type_str valid_types) then
						printf "ERROR: %s: Type-Check: class %s has method %s with unknown return type %s\n" type_loc cname str type_str;

					List.iter (fun formal ->
						let id,typeid = formal in
						let formal_loc,formal_str = id in
						let type_loc, type_str = typeid in
						if type_str = "SELF_TYPE" then begin
							printf "ERROR: %s: Type-Check: class %s has method %s with formal parameter of unknown type %s\n" type_loc cname str type_str;
							exit(1) ;
							end
						else if formal_str = "self" then
							printf "ERROR: %s: Type-Check: class %s has method %s with formal parameter named self\n" loc cname str;
						if formal_duplicates formal_list then begin
							printf "ERROR: %s: Type-Check: class %s has method %s with duplicate formal parameter named %s\n" loc cname str formal_str;
							exit(1) ;
						end
					) formal_list ;

					List.iter(fun (mname,rtype,paramnum) ->
						if str = mname && type_str <> rtype then
							printf "ERROR: %s: Type-Check: class %s redefines method %s and changes return type (from %s to %s)\n" loc cname str rtype type_str ;
						if str = mname && type_str = rtype && len <> paramnum then
							printf "ERROR: %s: Type-Check: class %s redefines method %s and changes number of formals\n" loc cname str ;
					) object_methods ;
				| _ -> ()
		) methods ;

(*		TODO: fix IO and dealing with bad method override error
		try
			let _,inherits,_ = List.find (fun ((_,class_name),_,_) -> cname = class_name) ast in
			let _,inherits_name = inherits in
			if inherits_name = "IO" then
			List.iter(fun meth ->
				List.iter(fun (mname,rtype,paramnum) ->
					if str = mname && type_str <> rtype then
						printf "ERROR: %s: Type-Check: class %s redefines method %s and changes return type (from %s to %s)\n" loc cname str rtype type_str ;
					if str = mname && type_str = rtype && len <> paramnum then
						printf "ERROR: %s: Type-Check: class %s redefines method %s and changes number of formals\n" loc cname str ;
				) io_methods ;
			) methods ;
		with Not_found ->
			[]
*)
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

(* IMPLEMENTATION MAP *)

	fprintf fout "implementation_map\n%d\n" (List.length all_classes) ;

	List.iter (fun cname ->
		fprintf fout "%s\n" cname ;
		let methods =
			try
				let _, inherits, features =	List.find (fun ((_,cname2),_,_) -> cname = cname2) ast in
				let final_features = ref [] in

				let rec find_parents (inherits) =
					try
						let new_inherits = Hashtbl.find inheritance_tbl inherits in
						find_parents(new_inherits) @ [ inherits ] ;
					with Not_found ->
						[ inherits ] ;
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
					) ast
				) inheritance_list ;

				List.filter (fun feature -> match feature with
					| Attribute _ -> false
					| Method _ -> true
				) !final_features

			with Not_found ->
				[]
		in

		fprintf fout "%d\n" (List.length methods) ;

		List.iter (fun meth ->
			match meth with
				| Method ((meth_loc,meth_name),formals,_,exp) ->
					fprintf fout "%s\n%d\n" meth_name (List.length formals) ;
					List.iter(fun ((form_loc,form_str),_) ->
					fprintf fout "%s\n" form_str ;
					) formals ;
					(* 	* TODO: If methods are not overridden but are inherited, output parent
						* class name otherwise, output the current class. *)

					fprintf fout "%s\n" cname ; (* THIS IS WRONG *)
					output_exp (exp) ;
				| _ -> failwith("Can't happen")
		) methods ;

	) all_classes ;


(* PARENT MAP *)
    fprintf fout "parent_map\n%d\n" (List.length all_classes - 1) ;
	List.iter (fun cname ->
        (* name of class, name of parent class. Class Object has no parent *)
        try
            if cname <> "Object" then begin
                fprintf fout "%s\n" cname ;
                let pname = Hashtbl.find inheritance_tbl cname in
                fprintf fout "%s\n" pname ;
            end ;
        with Not_found ->
            () ;
    ) all_classes ;

	close_out fout ;



end ;;
main () ;;
