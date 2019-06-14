OCaml allows you to put underscores in the middle of numerical literals to improve readability.

```ocaml

let readable_million = 1_000_000

```

You can open a module in local scope in two ways:

```ocaml

let ratio x y =
  let open Float.O in
  of_int x / of_int y

let ratio x y =
  Float.O.(of_int x / of_int y)

(* Note - Float.O provides convenient operators and functions to work with floats, hence why / is working on a float type. *)

```

### Parametric polymorphism

```ocaml

let first_if_true test x y =
  if test x then x else y

val first_if_true : ('a -> bool) -> 'a -> 'a -> 'a
```

'a is a type variable which expresses that the type is generic. I.e. OCaml has parameterized the type in question with a type variable.

### Mutable record fields and refs

You can make record fields mutable using the mutable keyword:

```ocaml

type runnning_sum = {
  mutable sum : float;
}

```

There's nothing really special about refs, since it's just a record type with a single mutable field called contents. You could easily reimplement it:

```ocaml

(* Refs *)

type 'a ref = { mutable contents : 'a }
let ref x = { contents = x }
let (!) r = r.contents
let (:=) r x = r.contents <- x

```

### Dune

In order to compile our program using dune (a build system designed for use with OCaml projects), we first need to create a dune file to specify the build:

```dune
(executable
  (name sum)
  (libraries base stdio))

```

In order build an executable you run:

`dune build [name].exe`

This will result in the creation of a native-code executable and is located in the build folder: `_build/default/[name].exe`.
