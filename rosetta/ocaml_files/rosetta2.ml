(*
Daniel Coo (djc4ku)

Topological sort

(1) Read in the graph from the input. Find vertices and edges
(2) Use Kahn's algorithm to perform a topological sort

*)

let main () = begin 
  let edges = ref [] in
  let nodes = ref [] in
  let newlist = [1; 2; 3;] in
  let printList l = List.iter Printf.printf l in


  try
    while true do
      let a = String.trim (read_line ()) in
      let b = String.trim (read_line ()) in
      edges := (a,b) :: !edges ;
      nodes := a :: b :: !nodes ;
    done
  
  with _ -> begin
    Printf.printf "Edges:\n" ;
    List.iter (fun (a,b) ->
      Printf.printf "%s -> %s\n" a b
    ) !edges ;

    Printf.printf "\nNodes:\n" ;
    List.iter (fun (x) ->
      Printf.printf "%s\n" x 
    ) !nodes ;

    
  end


end ;;
main () ;;