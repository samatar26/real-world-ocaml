Using a pattern in a let binding makes the most sense if the pattern's _irrefutable_, i.e. where any value of the type in question is guaranteed to match the pattern. Tuple and record patterns are irrefutable, but list patterns are not.

Reminds me of **lambdas** (Functions and let bindings have a lot to do with each other. In some sense, you can think of the parameter of a function as a variable being bound to the value passed by the caller.)

You can define multiple mutually recursive functions using _let_ _rec_ combined with _and_:

```ocaml
let rec is_even x =
  if x = 0 then true else is_odd (x - 1)
and is_odd x =
  if x = 0 then false else is_even (x - 1)

(* Very inefficient example! *)
```

A function is treated syntactically as an operator if the name of the function is form this specialized set of identifiers:

`! $ % & * + - . / : < = > ? @ ^ | ~`

Or from a handful of predetermined strings, i.e. `mod`.

## Labeled arguments

Labeled arguments are very useful when definining a function with lots of arguments.
Beyon a certain number, arguments are easier to remember by name than position.

They're also useful when the meaning of a particular argument is unclear from the type alone:

```ocaml

val create_hashtable : int -> bool -> ('a, 'b) Hashtable.t


(* With labeled arguments *)
val create_hashtable :
  init_size: int -> allow_shrinking : bool -> ('a, 'b) Hashtable.t


(* Also useful for multiple arguments of the same type *):

val substring: string -> int -> int -> string

val substring: string -> pos:int -> len:int -> string
```

The order of labeled arguments does matter when passing a function with labeled arguments to another function, i.e.:

```ocaml

let apply_to_tuple f (first,second) = f ~first ~second;;
val apply_to_tuple : (first:'a -> second:'b -> 'c) -> 'a * 'b -> 'c

let apply_to_tuple_2 f (first,second) = f ~second ~first;;
val apply_to_tuple_2 : (second:'a -> first:'b -> 'c) -> 'b * 'a -> 'c

let divide ~first ~second = first / second;;
val divide : first:int -> second:int -> int

apply_to_tuple_2 divide (3,4);;
Characters 17-23:
Error: This expression has type first:int -> second:int -> int
       but an expression was expected of type second:'a -> first:'b -> 'c


(* Whereas apply_to_tuple divide (3,4) does work! *)

```

### Optional arguments

Under the hood, a function with an optional argument receives `None` when the caller doesn't provide the argument, and `Some` when it does. If you want to explicitly pass Some or None, you can do so using the `?` instead of `~` to mark the argument.

One reason for passing an explicit Some or None is if you're defining a wrapper function that mimics the optional arguments

```ocaml

let () = concat ~sep:":" "foo" "bar"
let () = concat ?sep:(Some ":") "foo" "bar"

let () = concat "foo" "bar"
let () = concat ?sep:None "foo" "bar"



let uppercase_concat ?sep a b = concat ?sep (String.uppercase a) b (* Now, if someone calls uppercase_concat without an argument, an explicit None will be passed to concat, leaving concat to decide what the default behavior should be. *)

```

Note - An optional argument is erased as soon as the first positional (i.e. neither labeled nor optional) argument defined _after_ the optional argument is passed in.

```ocaml

let concat ?(sep="") x y = x ^ sep ^ y

let prepend_pound = concat "# "
val prepend_pound : string -> string
prepend_pound "a BASH comment"
- : string = "# a BASH comment"

```

So if we had defined **concat** with the optional argument in the second position:

```ocaml

let concat x ?(sep="") y = x ^ sep ^ y

let prepend_pound = concat "# "
val prepend_pound : ?sep:string -> string -> string
prepend_pound "a BASH comment"
- : string = "# a BASH comment"
prepend_pound "a BASH comment" ~sep:"--- "
- : string = "# --- a BASH comment"
```

Note - An optional argument that doesn’t have any following positional arguments can’t be erased at all, which leads to a compiler warning.

```ocaml

let concat x y ?(sep="") = x ^ sep ^ y
Characters 17-23:
Warning 16: this optional argument cannot be erased.
val concat : string -> string -> ?sep:string -> string

concat "a" "b"
- : ?sep:string -> string =

```
