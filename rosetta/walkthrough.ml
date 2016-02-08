(* Daniel Coo (djc4ku)

Compute the shortest path in a graph from node src to node dst
(1) Read in the graph from the input. Find vertices & edges
(2) Compute the shortest path
  
*)

let main () = begin
  let edges = ref [] in
  (* let vertices = ref [] in *)
  try
    while true do
      let line1 = String.trim (read_line ()) in
      let line2 = int_of_string (String.trim (read_line ())) in
      let line3 = String.trim (read_line ()) in
      (* vertices := line1 :: line3 :: !vertices ; *)
      edges := (line1, line2, line3) :: !edges
    done
  with _ -> begin

    List.iter (fun (node1,weight,node2) ->
      Printf.printf "an edge is: %S,%d,%S \n" node1 weight node2
    ) !edges ;

    let vertices = List.fold_left (fun acc (n1,w,n2) ->
      n1 :: n2 :: acc) [] !edges in
    List.iter (fun node ->
      Printf.printf "a vertex is: %S\n" node
    ) vertices ;


    (* Dijkstra's Shortest Path *)
    let my_infinity = 99999 in
    let undefined = "?" in
    let source = "A" in 
    let target = "C" in
    let dist = Hashtbl.create 255 in
    let prev = Hashtbl.create 255 in
    (* Iterating over hash table *)
    List.iter (fun v ->
      (* Hashtbl.replace dist key new_value *)
      (* Infinity is reserved in OCaml *)
      Hashtbl.replace dist v my_infinity ;
      Hashtbl.replace prev v undefined ;
    ) vertices ;
    Hashtbl.replace dist source 0 ;
    
    let q = ref vertices in
    (* while List.length q > 0 do *)
    (* while q is not equal to the empty list *)
    while !q <> [] do
      (* find "u", the vertex in q with the minimal distance *)
      (* if true, then keep x. false is y *)
      let min_dist_vertices = List.filter (fun x ->
        if List.exists (fun y ->
          (Hashtbl.find dist y) < (Hashtbl.find dist x)
        ) !q then false
        else true
      ) !q in

      List.iter (fun mdv ->
        Printf.printf "MDV is %S with distance %d\n"
        mdv (Hashtbl.find dist mdv)
      ) min_dist_vertices ;

      List.iter (fun x ->
        Printf.printf "Q contains %s\n" x;
      ) !q ;

      let u = List.hd min_dist_vertices in
      if (u = target) then begin
        (* we found it *)
        Printf.printf "we can get there\n" ;
        exit 1
      end ;
      (* use filter to create new q hashtable *)
      (* keep x but without "u" *)
      Printf.printf "doing filtering\n";
      let new_q = List.filter (fun x -> x <> u) !q in
      q := new_q ; (* update *)
      
      List.iter (fun x ->
        Printf.printf "Q contains %s\n" x ;
      ) !q ;

      List.iter (fun (a,w,b) ->
        if a = u then begin
          (* find each neighbor "v" of "u" *)
          let v = b in
          let alt = (Hashtbl.find dist u) + w in 
          if alt < Hashtbl.find dist v then begin
            Hashtbl.replace dist v alt ;
            Hashtbl.replace prev v u ;
          end
        end
      ) !edges ;


      (* plan: filter out all of the vertices that have a "too big" distance 
        -> filter out vertex x if there exists a vertex Y
           and dist[Y] < dist[X]
      *)

    done ;

    Printf.printf "got to end\n"
  end
end ;;
main () ;;
