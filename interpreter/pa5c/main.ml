(* pa5c
 * Daniel Coo (djc4ku)
 * Raymond Zhao (rfz5nt)
 *)

(* Won't be considering line number locations, but we have to *)
(* New, Dispatch, Variable, Assign, Integer, Plus *)
open Printf

(* Expression types used in Cool AST *)
type exp =
    | New of string (* new Point *)
    | Dispatch of exp * string * (exp list) (* self.foo(a1, a2, ..., an) *)
    | Variable of string (* x *)
    | Assign of string * exp (* x <- 2 + 2 *)
    | Integer of Int32.t (* int32 these are 32 bit integer in Cool. can't be 64 bit *)
    | Plus of exp * exp (* x + 5 *)

(* You would read in the annotated AST to get these .... have to to this on our
 * own, not in video *)


(* Environment, Store, Values *)
type cool_address = int
type cool_value =
    | Cool_Int of Int32.t (* int32 *)
    | Cool_Bool of bool
    | Cool_String of string
    | Cool_Object of string * ((string * cool_address) list)
    | Void

(* Goal of interpreter is to boil down Expressions into values and to update the
 * store *)

(* Want a function that takes in expressions and produces Cool values,
 * e.g. 2 + 2 = 4 *)

(* Environment: Maps Variable Names -> Cool Addresses *)
(* Could use Hashtables, Maps, ... *)

(* In Ocaml, will use an association list 
 * If x lives at 33 and y lives at address 7, we would have
 * [ ("x", 33)  ; ("y", 7) ]
 *)
type environment = (string * cool_address) list

(* Store: Maps Cool Addresses -> Cool Values *)
type store = (cool_address * cool_value) list

(* We found new attributes and initializers, now we need to give them new
 * locations. Start at 1000 to distinguish from numbers in our program *)
let new_location_counter = ref 1000
let newloc () =
    incr new_location_counter ;
    !new_location_counter

(* Class Map, Implementation Map *)
(* The Class Map maps "Class Names" -> "Attribute names and attribute
 * initializers"
 * TODO: I am not doing types.
 * TODO: READ in from Annotated AST
 *)
type class_map = (string * ((string * exp) list)) list

(* Implementation map:
    * Maps ("Class Name", "Method Name") to
    * the method formal parameter names and the method body
    * TODO: check what the full version should be!
    * TODO: READ in from Annotated AST
*)
type imp_map =
    (* Class name, method name -> formals and method body *)
    ( (string * string)
      *
      ((string list) * exp) ) list

(* For now, just going to have a test type of class map,
 * Just has a class called Main with one attribute x <- 5
 * Sample test program we will interpret with hardcoded class_map
 * and imp_map
 *
 *
 * class Main {
        x : Int <- 5;
        y : Int <- x + 2;
        main () : Object { x + y }
   };
*)
let class_map : class_map =
    [ ("Main", [ "x", Integer(5l) ;
                 "y", (Plus(Variable("x"),Integer(2l)))])]

(* Need hardcoded implementation map for testing *)
(* TODO: Read in imp map from AST *)
let imp_map : imp_map =
    [ (("Main", "main") , ([],
                          (Plus(Variable("x"), (Variable("y")))))) ]

(* NOTE: The Annotated AST and the AST are redundant for the class_map and
 * the implementation map *)

(************************************************************************************)
(* Debugging and Tracing                                                            *)
(************************************************************************************)

(* TODO: NEED TO READ IN EVERY PART OF THE ANNOTATED AST *)


(* Sometimes want to run interpreter with a lot of debugging and sometimes dont
 * *)

(* Debug flag and simple print function *)
(* Set debug to false if you don't want to debug *)
let do_debug = ref true
let debug fmt =
    let handle result_string =
        if !do_debug then printf "%s" result_string
    in
    (* Continuation printf (K) *)
    kprintf handle fmt

(* debug method handles conditional debugging, but it's also helpful to have a
 * way to take all the data types and turn them into strings. Python and Ruby
 * have methods for this!! *)

let rec exp_to_str e =
    match e with
    | New(s) -> sprintf "New(%s)" s
    | Dispatch(ro, fname, args) ->
        (* Fold left, start with empty string and go over all of the arguments*)
        let arg_str = List.fold_left (fun acc elt ->
            acc ^ ", " ^ (exp_to_str elt)
        ) "" args in
        sprintf "Dispatch(%s,%s,[%s])" (exp_to_str ro) fname arg_str
    | Variable(x) -> sprintf "Variable(%s)" x
    | Assign(x,e) -> sprintf "Assign(%s,%s)" x (exp_to_str e)
    | Integer(i) -> sprintf "Integer(%ld)" i
    | Plus(e1,e2) -> sprintf "Plus(%s,%s)" (exp_to_str e1) (exp_to_str e2)

(* Want a way to convert Cool VALUES to strings *)
(* Well.. *)
let value_to_str v =
    match v with
    | Cool_Int(i) -> sprintf "Integer(%ld)" i
    | Cool_Bool(b) -> sprintf "Bool(%b)" b
    | Cool_String(s) -> sprintf "String(%s)" s
    | Void -> sprintf "Void"
    | Cool_Object(cname, attrs) -> 
        let attr_str = List.fold_left (fun acc (aname, aaddr) ->
            sprintf "%s, %s=%d" acc aname aaddr
        ) "" attrs in
        sprintf "%s([%s])" cname attr_str

(* Want to print out Environments and Stores *)
let env_to_str env =
    let binding_str = List.fold_left (fun acc (aname, aaddr) ->
        sprintf "%s, %s=%d" acc aname aaddr
    ) "" (List.sort compare env) in
    sprintf "[%s]" binding_str

(* Print Stores *)
let store_to_str env =
    let binding_str = List.fold_left (fun acc (addr, cvalue) ->
    sprintf "%s, %d=%s" acc addr (value_to_str cvalue)
    ) "" (List.sort compare env) in
    sprintf "[%s]" binding_str


(* Implement TRACING so that you can easily where something goes wrong
 * TRACING = tabbing successive output lines for easy debugging
 * e.g.
 * 5+3
 *      5
 *          3
 * 8
 *)
let indent_count = ref 0
let debug_indent () =
    debug "%s" (String.make !indent_count ' ')


(************************************************************************************)
(* Evaluation (Interpretation)                                                      *)
(************************************************************************************)

(* Want an evaluation procedure that takes 'so' and 's' 'e' and the expression and
 * returns a new value and a new store *)
(* Read off the rules from Operational Semantics stuff *)
(* Everytime you see a turnstile, convert it into a recursive call *)
let rec eval (so : cool_value)  (* self object *)
             (s : store)        (* store = memory maps addresses to values *)
             (e : environment)  (* maps variables to addresses *)
             (exp : exp)        (* the expression to evaluate *)
             :
             (cool_value *      (* result value *)
             store)             (* updated store *)
             =
    indent_count := !indent_count + 2;
    debug "\n" ;
    debug_indent() ; debug "eval: %s\n" (exp_to_str exp) ;
    debug_indent() ; debug "env = %s\n" (value_to_str so) ;
    debug_indent() ; debug "sto = %s\n" (store_to_str s) ;
    debug_indent() ; debug "env = %s\n" (env_to_str e) ;

    let new_value, new_store = match exp with
    | Integer(i) -> Cool_Int(i), s
    | Plus(e1,e2) -> 
        let v1, s2 = eval so s e e1 in
        let v2, s3 = eval so s2 e e2 in
        let result_value = match v1, v2 with
            | Cool_Int(i1), Cool_Int(i2) ->
                Cool_Int(Int32.add i1 i2)
            | _,_ -> failwith "impossible in plus"
        in
        result_value, s3
    (* Assign statement has a variable and a rhs expression *)
    | Assign(vname, rhs) ->
        (* First rule in Assign *)
        let v1, s2 = eval so s e rhs in

        (* Look up the variable name in the environment *)
        let l1 = List.assoc vname e in  (* E[vname] *)

        (* Third Rule in assign *)
        (* Remove any old associations in the store (s2) associated with the old
         * address. Then add a new associations on the front that says this
         * address holds value 1 (v1). anything you used to have in store bound
         * to l1 is gone, and we updated it with something exciting VIDEO -
         * 40:14 *)
        let s3 = (l1, v1) :: List.remove_assoc l1 s2 in
        v1, s3
    | New(cname) -> 
        (* TODO: what if it's not in there? *)
        let attrs_and_inits = List.assoc cname class_map in
        let new_attr_locs = List.map (fun (aname, ainit) ->
            newloc ()
        ) attrs_and_inits in

        (* Third Rule for Operational Symantics for New *)
        let attr_names = List.map (fun (aname, ainit) ->
            aname) attrs_and_inits in
        let attrs_and_locs = List.combine attr_names new_attr_locs in

        (* Fourth Rule in Operational Symantics for New *)
        let v1 = Cool_Object(cname, attrs_and_locs) in

        (* TODO: Default Values *)
        let store_updates = List.map (fun newloc ->
            (newloc, Cool_Int(0l)) (* SHOULD BE: DEFAULT VALUE *)
        ) new_attr_locs in

        (* Fifth rule in Oper. Symantcs for New VIDEO - 37:45 *)
        (* s2 is like s1 but with store updates associated with it *)
        (* Now, evaluate all initializers as assignment statements *)
        let s2 = s @ store_updates in
    
        (* Sixth rule in Operational Symantics of New *)
        (* We have a list of attr initializers, fold left over them *)
        let final_store =List.fold_left (fun accumulated_store (aname, ainit) ->
            let _, updated_store = eval v1 accumulated_store attrs_and_locs (Assign(aname, ainit)) in
            updated_store
        ) s2 attrs_and_inits in
        v1, final_store

    (* Weimer gets a Steam update at 48:20 *)
    | Variable(vname) ->
        let l = List.assoc vname e in
        let final_value = List.assoc l s in
        final_value, s
    | Dispatch(e0, fname, args) ->
        (* evaluate all of the args in turn, then do the receiver object *)
        (* arguments must come first. Note the values, and build up the final
           store. Can use for loop or fold_left
        *)
        
        (* Evaluate the arguments *)
        let current_store = ref s in
        let arg_values = List.map (fun arg_exp ->
            let arg_value, new_store = eval so !current_store e arg_exp in
            current_store := new_store ;
            arg_value
        ) args in
        (* !current_store = s_n in the CRM *)

        (* Evaluate Receiver Object *)
        let v0, s_nplus2 = eval so !current_store e e0 in
        
        (* Look up things in implementation map *)
        begin match v0 with
            | Cool_Object(x, attrs_and_locs) -> 
                (* TODO: Make sure it is there, if not you have a PA5 bug *)
                let formals, body = List.assoc (x, fname) imp_map in

            (* Make new locations for each of the actual arguments
             * VIDEO  56:06 *)
            let new_arg_locs = List.map (fun arg_exp ->
                newloc ()
            ) args in

            (* Make an updated store, where in each of those new locations, we
             * store the corresponding argument value *)
            let store_update = List.combine new_arg_locs arg_values in

            (* Last rule of Dispatch *)
            (* TODO: Should put formal parameters first so that they are visible
             * and they shadow the attributes *)
            let s_nplus3 = store_update @ s_nplus2 in
            eval v0 s_nplus3  attrs_and_locs body
            | _ -> failwith "not handled yet in Dispatch"
        end
    | _ -> failwith "unhandled so far"
    in

    (* Current return value *)
    debug_indent () ; debug "ret = %s\n" (value_to_str new_value) ;

    (* Current value of Store *)
    debug_indent () ; debug "rets = %s\n" (store_to_str  new_store) ;


    (* Could also print the outgoing store *)
    (* Makes funny sound at 42:24 *)
    indent_count := !indent_count - 2;
    new_value, new_store

let main () = begin
    (* There are L's after each digit *)
    (* let old_exp = Plus(Integer(5l), Integer(3l)) in *)
    (* let my_exp = New("Main") in *)

    (* Implicitly Cool programs start with. this is what Cool interpreter does:
        *
        *    (new Main).main()
        *
        *)
    let my_exp = Dispatch(New("Main"), "main", []) in

    debug "my_exp = %s\n" (exp_to_str my_exp); 

    let so = Void in
    let store = [] in
    let environment = [] in
    let final_value, final_store = eval so store environment my_exp in
    debug "result = %s\n" (value_to_str final_value)

    (* OUTPUT *)
    (*
     *  # Start. Expression is 5 + 3
        my_exp = Plus(Integer(5),Integer(3))
          
          # Eval is called with no self object, no store, no env
          eval: Plus(Integer(5),Integer(3))
          env = Void
          sto = []
          env = []

            # Call recursively to evaluate just the 5
            eval: Integer(5)
            env = Void
            sto = []
            env = []
            ret = Integer(5)

            # Call recursively to evalute just the 3
            eval: Integer(3)
            env = Void
            sto = []
            env = []
            ret = Integer(3)

          ret = Integer(8)
        result = Integer(8)
    *)


    (* OUTPUT WITH NEW EXP VIDEO 45:38 *)
    (*
        my_exp = New(Main)
            eval: New(Main)
            env = Void
            sto = []
            env = []
    
                # x is five to start out
                # We made a new env that says x=1001 and y=1002
                eval: Assign(x,Integer(5))
                env = Main([, x=1001, y=1002])

                # Store initially holds default value 0
                sto = [, 1001=Integer(0), 1002=Integer(0)]
                env = [, x=1001, y=1002]
                    eval: Integer(5)
                    env = Main([, x=1001, y=1002])
                    sto = [, 1001=Integer(0), 1002=Integer(0)]
                    env = [, x=1001, y=1002]
                    ret = Integer(5)
                    rets = [, 1001=Integer(0), 1002=Integer(0)]
                ret = Integer(5)

                # Video 46:49
                # After the assignment statement, we change the Store
                rets = [, 1001=Integer(5), 1002=Integer(0)]

                # y is 3
                eval: Assign(y,Integer(3))
                env = Main([, x=1001, y=1002])
                sto = [, 1001=Integer(5), 1002=Integer(0)]
                env = [, x=1001, y=1002]
                    eval: Integer(3)
                    env = Main([, x=1001, y=1002])
                    sto = [, 1001=Integer(5), 1002=Integer(0)]
                    env = [, x=1001, y=1002]
                    ret = Integer(3)
                    rets = [, 1001=Integer(5), 1002=Integer(0)]
                ret = Integer(3)
                rets = [, 1001=Integer(5), 1002=Integer(3)]
            ret = Main([, x=1001, y=1002])
            rets = [, 1001=Integer(5), 1002=Integer(3)]
        result = Main([, x=1001, y=1002])

    *) 
end ;;
main () ;;




