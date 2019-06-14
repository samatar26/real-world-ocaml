open Base

let ratio x y = Float.of_int x /. Float.of_int y 

(* You can also open a module in a local scope in two ways *)

let ratio x y = 
  let open Float.O in 
  of_int x / of_int y 

let ratio x y = 
  Float.O.(of_int x / of_int y)


let sum_if_true (test: int -> bool) (first: int) (second: int) : int = 
  match test first, test second with 
  | true, true -> first + second 
  | true, false -> first
  | false, true -> second 
  | false, false -> 0

let even x = 
  x % 2 = 0 

let test_sum_if_true () = sum_if_true even 2 4

let rec sum l = 
  match l with 
  | [] -> 0 
  | hd::tl -> hd + sum tl 

let rec remove_sequential_duplicates l = 
  match l with 
  | [] -> []
  | [x] -> [x]   
  | first :: (second :: _ as tl) -> 
    if first = second then remove_sequential_duplicates tl 
    else first :: remove_sequential_duplicates tl 


let downcase_extension filename =
  match String.rsplit2 filename ~on:'.' with 
  |  None -> filename 
  | Some (base, ext) -> base ^ "." ^ String.lowercase ext