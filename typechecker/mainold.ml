(* Raymond Zhao rfz5nt
   Daniel Coo djc4ku
   PA4 - Type Checker *)

open Printf

(* Used PA3 to find all the types *)

(* PART 2 *)
type static_type =
    | Class of string
    | SELF_TYPE of string

let type_to_str t = match t with
    | Class(x) -> x
    | SELF_TYPE(c) -> "SELF_TYPE"

let rec is_subtype t1 t2 =
    match t1, t2 with
        | Class(x), Class(y) when x = y -> true
        | Class(x), Class("Object") -> true
        | Class(x), Class(y) -> (* HINT: check the parent map *) false
        | _,_ -> (* HINE: check the class notes *) false
        (* THERE ARE 8 CASES HERE *)

type object_environment = (* mapping from object identifiers (names) to types *)
    (string, static_type) Hashtbl.t

let empty_object_environment () = Hashtbl.create 255

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

(* PART 2 *)
and exp = {
    (* Read Only *)
    loc : loc ;
    exp_kind : exp_kind ;

    mutable static_type : static_type option
    (* Every exp node in the AST has mutable static_type annotation which we
     * have to fill in by typechecking *)

}
(* and exp = loc * exp_kind *)

and exp_kind =
    | Integer of string (* look @ loc *)
    | Plus of exp * exp
    | Identifier of id
    (* Only a single let *)
    | Let of id * id * (exp option) * exp (* let x : t <- e1 in e2 *)

let main () = begin
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
            | "integer" ->
                let ival = read () in
                Integer(ival)
            (* PART 2 *)
            | "plus" ->
                let e1 = read_exp () in
                let e2 = read_exp () in
                Plus(e1,e2)
            | "identifier" ->
                let id = read_id () in
                Identifier(id)
            | "let" ->
                (* FIXME: we currently only consider ONE let binding *)
                let number_of_bindings = read () in
                let lbni = read () in (* "let_binding_no_init" *)
                let let_variable = read_id () in
                let let_type = read_id () in
                let let_body = read_exp() in
                Let(let_variable, let_type, None, let_body)
            | x -> (* FIXME: do all of the others *)
                failwith ("expression kind unhandled: " ^ x)
        in
        (* PART 2 *)
        {
            loc = eloc ;
            exp_kind = ekind ;
            static_type = None ; (* have not annotated it yet *)
        }

        (* (eloc,ekind) *)

    in

    let ast = read_cool_program () in
    close_in fin ;

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
            if not (List.mem iname all_classes) then begin
                printf "ERROR: %s: Type-Check: inheriting from undefined class %s\n"
                    iloc iname ;
                exit 1
            end ;
    ) ast ;
    (* IF NO ERRORS *)

    (* CLASS MAP *)

        (* build inheritance graph and toposort it *)

    let inheritance_tbl = Hashtbl.create 100 in
    List.iter (fun (cname,inherits,_) ->
        match inherits with
            | None -> ()
            | Some parentname ->
                Hashtbl.add inheritance_tbl cname parentname
    ) ast ;

    (* This is the time to do expression typechecking. This is the heart of PA4
     *
     * We want to iterate over every class.
     *   Then over every feature
     *     Then typecheck the expressions in that feature
     *
     * We implement exp typechecking procedure by
     * reading the typing rules form the CRM or the class notes
     *
     * Every "line" in a typing rule corresponds to a line in the typechecking
     * code
     *
     *)

    (* PART 2 *)
    let rec typecheck (o : object_environment) (* TODO: M C *) (exp : exp) : static_type =
        let static_type = match exp.exp_kind with
            | Integer(i) -> (Class "Int")
            | Plus(e1, e2) ->
                let t1 = typecheck o e1 in
                if t1 <> (Class "Int") then begin
                    printf "ERROR: %s: Type-Check: adding %s instead of Int\n"
                    exp.loc (type_to_str t1) ;
                    exit 1
                end ;
                let t2 = typecheck o e2 in
                if t2 <> (Class "Int") then begin
                    printf "ERROR: %s Type-Check: adding %s instead of Int\n"
                    exp.loc (type_to_str t2) ;
                    exit 1
                end ;
                (Class "Int")

            | Identifier(vloc, vname) ->
                if Hashtbl.mem o vname then
                    Hashtbl.find o vname
                else begin
                    printf "ERROR: %s: Type-Check: undeclared variable %s\n"
                    vloc vname ;
                    exit 1
                end
            | Let((vloc, vname),(typeloc, typename),None,let_body) ->
                (* add vname to O -- add it to the current scope *)
                Hashtbl.add o vname (Class typename) ; (* TODO: SELF_TYPE? *)
                (* typecheck let body with the bound variable added to the
                 * object's environment *)
                    let body_type = typecheck o let_body in
                Hashtbl.remove o vname ;
                body_type
        in
        (* LARROW means 'get' or object.method *)
        exp.static_type <- Some(static_type) ;
        static_type
    in

    (* PART 2 *)
    (* Iterate over every class and typecheck all features *)
    List.iter (fun ((cloc, cname), inherits, features) ->
        List.iter (fun feat ->
            match feat with
                | Attribute((nameloc,name), (dtloc,declared_type), Some(init_exp)) -> (* x : Int <- 5 + 3 *)
                    let o = empty_object_environment () in (* THIS IS WRONG.
                    TODO: Add all features to object environment *)
                    let init_type = typecheck o init_exp in
                    if is_subtype init_type (Class declared_type) then
                        ()
                    else begin
                        printf "ERROR: %s: Type-Check: initializer for %s was %s did not match declared %s\n" nameloc name (type_to_str init_type)
                        declared_type

                    end
                | _ -> ()
                (* | Method _ -> () (* TODO *) *)
        ) features ;
    ) ast ;

    let cmname = (Filename.chop_extension fname) ^ ".cl-type" in
    let fout = open_out cmname in

    (* PART 2 *)
    let rec output_exp e =
        fprintf fout "%s\n" e.loc ;
        (* Output the TYPE ANNOTATION in the new ANNOTATED AST. None should be
         * filled with everything else*)
        (match e.static_type with
            | None -> failwith "we forgot to do typechecking?"
            | Some(Class(c)) -> fprintf fout "%s\n" c
            | Some(SELF_TYPE(c)) -> failwith "TODO: FIX THIS"
        ) ;
        match e.exp_kind with
            | Integer(ival) -> fprintf fout "integer\n%s\n" ival
            | _ -> failwith "aie"
    in



    (* OLD *)
    (* let rec output_exp (eloc, ekind) =
        fprintf fout "%s\n" eloc ;
        match ekind with
            | Integer(ival) -> fprintf fout "integer\n%s\n" ival
    in *)

    fprintf fout "class_map\n%d\n" (List.length all_classes) ;
    List.iter (fun cname ->
        (* name of class, # attrs, each attr=feature in turn *)
        fprintf fout "%s\n" cname ;
        let attributes = (* THIS IS INCOMPLETE - NEED TO FIND INHERITED ATTRIBUTES *)
                (*
                    1) construct mapping from child to parent
                        1a) use TOPOSORT here to find the right order of traversal
                    2) recurisively walk up that mapping until we hit object
                    3) add in all of the attributes we find
                        3a) look for attribute override problems
                ------------------------------------------------------------------
                    1) build hashtbl for inheritance (key: child, value: parent)
                    2) find all the attributes through inheritance by looking at the values
                    3) look at attr in parent and add them in feature list
                    4) toposort for cycles
                *)
            try
                let _, inherits, features = List.find (fun ((_,cname2),_,_) -> cname = cname2) ast in
                List.filter (fun feature -> match feature with
                    | Attribute _ -> true
                    | Method _ -> false
                ) features
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