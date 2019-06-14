open Base
open Stdio

let rec read_and_accumulate accum = 
  let line = 
    let open In_channel in input_line stdin in 
  match line with 
  | None -> accum 
  | Some x -> read_and_accumulate (accum +. Float.of_string x)

let () = 
  printf "Total: %F\n" (read_and_accumulate 0.)