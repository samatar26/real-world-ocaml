open Base

let rec find_first_repeat l = 
  match l with 
  | [] | [_] -> None 
  | x :: (y :: _ as tl) -> 
    if x = y then Some x 
    else find_first_repeat tl

(* (re)defining operators *)

let (+!) (x1, y1) (x2, y2) = (x1 + x2, y1 + y2)

let test_vector_addition = (3, 2) +! (-2, 4)


(* Reverse application operator example *)

let path = "/usr/bin:/usr/local/bin:/bin:/sbin:/usr/bin"

let reverse_application_operator () = 
  String.split ~on:':' path 
  |> List.dedup_and_sort ~compare:String.compare
  |> List.iter ~f:print_endline


(*  without reverse application operator *)
let non_reverse_application_operator () = 
  let split_path = String.split ~on:'.' path 
  in let deduped_path = List.dedup_and_sort ~compare:String.compare split_path in 
  List.iter ~f:print_endline deduped_path


(* Another way do define a function is using the function keyword *)

let some_or_zero = function 
  | Some x -> x 
  | None -> 0

let some_or_zero num_opt = 
  match num_opt with 
  | Some x -> x 
  | None -> 0


let some_or_default default = function
  | Some x -> x 
  | None -> default 

let example_some_or_default = some_or_default 100 (Some 5)

let example_some_or_default = List.map ~f:(some_or_default 100) [Some 4; None; Some 5] 


(* Labeled arguments *)

let ratio ~num ~denom = Float.O.(of_int num / of_int denom)

let example_label_punning = 
  let num = 3 in 
  let denom = 4 in 
  ratio ~num ~denom 