(* OCAML: Reverse-sort the lines from standard input *) 
let lines = ref [] in (* store the lines; a 'ref' is a mutable pointer *) 
try
  while true do (* we'll read all the lines until something stops us *) 
    lines := (read_line ()) :: !lines (* read one line, add it to the list *)
    (* X :: Y makes a new list with X as the head element and Y as the rest *)
    (* !reference loads the current value of 'reference' *) 
    (* reference := value assigns value into reference *) 
  done (* read_line will raise an exception at the end of the file *) 
with _ -> begin (* until we reach the end of the file *) 
  let sorted = List.sort (* sort the list *)
    (fun line_a line_b -> (* how do we compare two lines? *)
      compare line_b line_a) (* in reverse order! *) 
      (* (fun (argument) -> body) is an anonymous function *) 
    !lines (* the list we are sorting *)  
  in (* let ... in introduces a new local variable *) 
  List.iter print_endline sorted (* print them to standard output *) 
  (* List.iter applies the function 'print_endline' to every element 
   * in the list 'sorted' *) 
end 
