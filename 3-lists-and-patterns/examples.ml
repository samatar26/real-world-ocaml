open Base
open Base.Poly
open Core_bench
module Sys = Core.Sys
module Filename = Core.Filename

let rec drop_value l el = 
  match l with 
  | [] -> []
  | hd::tl -> 
    if hd = el then drop_value tl el 
    else  hd :: drop_value tl el 

let rec drop_zero l = 
  match l with 
  | [] -> []
  | 0::tl -> drop_zero tl 
  | hd :: tl -> hd :: drop_zero tl


(* Performance benchmarking pattern matches *)

let plus_one_match x = 
  match x with 
  | 0 -> 1
  | 1 -> 2
  | 2 -> 3
  | 3 -> 4
  | 4 -> 5
  | 5 -> 6
  | _ -> x + 1

let plus_one_if x = 
  if      x = 0 then 1
  else if x = 1 then 2
  else if x = 2 then 3
  else if x = 3 then 4
  else if x = 4 then 5
  else if x = 5 then 6
  else x + 1

(* plus_one_if is considerably slower than the match equivalent. And it's advantage gets larger as the number of cases increases. *)

let benchmark () = 
  [Bench.Test.create ~name: "plus_one_match" (fun () -> plus_one_match 10 |> ignore);
   Bench.Test.create ~name: "plus_one_if" (fun () -> plus_one_if 10 |> ignore)]
  |>
  Bench.bench


let rec sum l = 
  match l with 
  | [] -> 0 
  | hd::tl -> hd + sum tl

let rec sum_if l = 
  if List.is_empty l then 0 
  else List.hd_exn l + sum_if (List.tl_exn l)

let bench_sum () = 
  let numbers =  List.range 0 1000 in 
  [Bench.Test.create ~name:"sum" (fun () -> sum numbers);
   Bench.Test.create ~name:"sum_if" (fun () -> sum_if numbers);]
  |> Bench.bench

(* One of the reasons the if version is many times slower, is because we effectively need to do the same work multiple times,
   each function call has to reexamine the first element of the list to determine whether or not it's the empty cell. *)


(* List module examples *)

let list_map l = List.map ~f:String.length l 

(* throws an exception if they're not the same length *)
let list_map2_exn l1 l2 = List.map2_exn ~f: (Int.max) l1 l2

let list_fold l = List.fold ~init:0 ~f:(+) l 

let list_fold_reverse l = List.fold ~init:[] ~f:(fun list x -> x :: list ) l

let list_reduce l = List.reduce ~f:(+) l

let list_filter l = List.filter ~f:((fun x -> x % 2 = 0)) l 

let extensions filenames = 
  List.filter_map filenames 
    ~f: (fun fname ->
        match String.rsplit2 ~on:'.' fname with 
        | None | Some ("",_) -> None 
        | Some(_, ext) -> Some ext )
  |> List.dedup_and_sort ~compare:String.compare


let is_ocaml s = 
  match String.rsplit2 s ~on:'.' with 
  | Some(_,("ml"|"mli")) -> true 
  | _ -> false

let (ml_files, other_files) = 
  List.partition_tf ~f:is_ocaml ["foo.c"; "foo.ml"; "bar.ml"; "bar.mli"] 


let rec ls_rec s = 
  if Sys.is_file_exn ~follow_symlinks:true s
  then [s]
  else 
    Sys.ls_dir s 
    |> List.concat_map ~f: (fun sub -> ls_rec (Filename.concat s sub))

(* Rendering table example *)

let max_column_widths header rows = 
  let lengths l = List.map ~f:String.length l in 
  List.fold rows 
    ~init: (lengths header) 
    ~f: (fun acc row -> 
        List.map2_exn ~f:Int.max acc (lengths row))


let render_separator widths = 
  let pieces = List.map widths 
      ~f:(fun w -> String.make (w + 2) '-')
  in 
  "|" ^ String.concat ~sep:"+" pieces ^ "|"

let pad s length = 
  " " ^ s ^ String.make (length - String.length s + 1) ' '

let render_row row widths = 
  let padded = List.map2_exn row widths ~f: pad in 
  "|" ^ String.concat ~sep: "|" padded ^ "|"

let render_table header rows = 
  let widths = max_column_widths header rows in
  String.concat ~sep:"\n"
    (render_row header widths
     :: render_separator widths
     :: List.map rows ~f:(fun row -> render_row row widths)
    )


(* Terser and faster patterns *)

let rec destutter l = 
  match l with 
  | [] -> []
  | [hd] -> [hd]
  | hd::(hd'::_ as tl) -> 
    if hd = hd' then destutter tl 
    else hd :: destutter tl

(* improvements: 
   - The pattern [hd] -> [hd] actually allocates a new list element, when really it should be able to just return the list being matched. 
   - We can also reduce allocation by using an as pattern, which allows you to declare a name for the thing matched by a pattern or subpattern. 
   - We can also use the function keyword to eliminate the need for an explicit match. 
*)

let rec destutter_v2 = function 
  | [] as l -> l 
  | [_] as l -> l 
  | hd::(hd' :: _ as tl ) -> 
    if hd = hd' then destutter tl 
    else hd :: destutter tl

(* Can further collapse this by coming the first two cases into one, using an or pattern *)

let rec destutter_v3 = function 
  | [] | [_] as l -> l 
  | hd::(hd' :: _ as tl ) -> 
    if hd = hd' then destutter tl 
    else hd :: destutter tl

(* We can make the code slightly terser now by using a when clause. 
   A when clause allows you to add an extra precondition to a pattern in the form of an arbitrary OCaml expression. 

   Note - When clauses have some downsides, in particular the ability for the compiler to determine if a match is exhaustive. 
   Should prefer patterns wherever they're sufficient.

*)


let rec destutter_final = function 
  | [] | [_] as l -> l 
  | hd :: (hd' :: _ as tl) when hd = hd' -> destutter tl 
  | hd :: tl -> hd :: destutter_final tl 


