(*
Daniel Coo (djc4ku)

Topological sort

(1) Read in the graph from the input. Find vertices and edges
(2) Use Kahn's algorithm to perform a topological sort

*)

let main () = begin
  let edges = ref [] in (* store the lines; a 'ref' is a mutable pointer *)
  let nodes = ref [] in
  let indegrees = Hashtbl.create 255 in (* Map of node -> incoming nodes *)

  (* Helper function, prints a list of strings *)
  let print_list lst = List.iter ( fun node -> Printf.printf "%s\n" node ) lst in
 
  (* Helper function, prints a hashtable of string to list of strings *) 
  (* let print_graph myGraph =
    Hashtbl.iter (fun key value ->
      Printf.printf "key: %s\n" key ;
      print_list value ;
    ) myGraph
  in *)

  (* Source: https://realworldocaml.org/v1/en/html/lists-and-patterns.html *)
  (* Recursive function that filters out an element from a list *)
  let rec drop_value l value_to_drop =
    match l with
    | [] -> []
    | hd :: tl ->
      let new_tl = drop_value tl value_to_drop in
      if hd = value_to_drop then new_tl else hd :: new_tl
  in

  try
    while true do
        let src = String.trim (read_line ()) in
        let dst = String.trim (read_line ()) in
        edges := (src,dst) :: !edges ;
        nodes := src :: dst :: !nodes ;
    done

  with _ -> begin
    (* Print the edges *) 
    (* List.iter (fun (a,b) ->
        Printf.printf "an edge is: %s,%s\n" a b
    ) !edges ; *)

    (* Sort the nodes *)
    nodes := List.sort compare !nodes ;

    (* Populate hash table *)
    List.iter (fun node ->
        Hashtbl.add indegrees node [] ;
    ) !nodes ;

    (* Populate hash table *)
    List.iter (fun (a, b) ->
      try
        let l = Hashtbl.find indegrees a in
        Hashtbl.replace indegrees a (b :: l)
      with
      | Not_found -> failwith "Should not be here"
      
    ) !edges ;

    let sorted_list = ref [] in (* Emtpy list that will contain sorted elements *)
    let nodes_to_remove = ref [] in (* Set of all nodes with no incoming edges *)

    Hashtbl.iter (fun key value ->
      if List.length (Hashtbl.find indegrees key) = 0 then begin
        nodes_to_remove := !nodes_to_remove@[key] ;
      end
    ) indegrees ;

    (* Sort before looping *)
    nodes_to_remove := List.sort compare !nodes_to_remove ;

    while (List.length !nodes_to_remove) > 0 do
      let n = List.hd !nodes_to_remove in
      let new_nodes_to_remove = List.filter (fun x -> x <> n) !nodes_to_remove in
      nodes_to_remove := new_nodes_to_remove ;
      sorted_list := !sorted_list@[n] ;

      Hashtbl.iter (fun key value ->
        try
          if List.mem n (Hashtbl.find indegrees key) then begin
            let new_list = ref [] in
            new_list := Hashtbl.find indegrees key ;
            new_list := drop_value !new_list n ;
            Hashtbl.replace indegrees key !new_list ;

            if List.length (Hashtbl.find indegrees key) = 0 then begin
              nodes_to_remove := !nodes_to_remove@[key] ;
              nodes_to_remove := List.sort compare !nodes_to_remove ;
            end
          end
        with
        | Not_found -> failwith "Not found"


      ) indegrees ;

    done ;

    (* Check for cycle *)
    Hashtbl.iter (fun key value ->
      if List.length (Hashtbl.find indegrees key) > 0 then begin
        Printf.printf "cycle" ;
        exit 1
      end
    ) indegrees ;

    print_list !sorted_list ;
    
  end
end ;;
main () ;;
