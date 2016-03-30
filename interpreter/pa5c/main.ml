(* pa5c
 * Daniel Coo (djc4ku)
 * Raymond Zhao (rfz5nt)
 *)

(* Won't be considering line number locations, but we have to *)
(* New, Dispatch, Variable, Assign, Integer, Plus *)
open Printf

type exp =
    | New of string (* new Point *)
    | Dispatch of exp * string * (exp list) (* self.foo(a1, a2, ..., an) *)
    | Variable of string (* x *)
    | Assign of string * exp (* x <- 2 + 2 *)
    | Integer of Int32.t (* Int32.t these are 32 bit integer in Cool. can't be 64 bit *)
    | Plus of exp * exp (* x + 5 *)

(* You would read in the annotated AST to get these .... have to to this on our
 * own, not in video *)


(* Environment, Store, Values *)
type cool_address = int
type cool_value =
    | Cool_Int of Int32.t (* Int32.t *)
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

(* Class Map, Implementation Map *)
(* The Class Map maps "Class Names" -> "Attribute names and attribute
 * initializers"
 * TODO: I am not doing types. *)
type class_map = (string * ((string * exp) list)) list

(* Implementation map:
    * Maps ("Class Name", "Method Name") to
    * the method formal parameter names
    * the method body
    * TODO: check what the full version should be! *)
type imp_map =
    (* Class name, method name -> formals and method body *)
    ( (string * string)
      *
      ((string list) * exp) ) list

(************************************************************************************)
(* Debugging and Tracing                                                            *)
(************************************************************************************)

(* NEED TO READ IN EVERY PART OF THE ANNOTATED AST *)


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
    | Cool_Int(i) -> sprintf "Int(%ld)" i
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
    ) "" env in
    sprintf "[%s]" binding_str

(* Print Stores *)
let store_to_str env =
    let binding_str = List.fold_left (fun acc (addr, cvalue) ->
    sprintf "%s, %d=%s" acc addr (value_to_str cvalue)
    ) "" env in
    sprintf "[%s]" binding_str


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
    | _ -> failwith "unhandled so far"
    in
    new_value, new_store
    

let main () = begin
    let my_exp = Plus(Integer(51), Integer(31)) in
    debug "my_exp = %s\n" (exp_to_str my_exp);
end ;;
main () ;;







