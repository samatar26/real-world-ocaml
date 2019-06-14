open Base

type point2d = {x: float; y: float}

let magnitude  {x = x_pos; y = y_pos} = 
  Float.sqrt( x_pos **. 2. +. y_pos **. 2.)

(* Field punning - name of the field in the record type is the same as the name of the variable we're using in our function*)
let magnitude {x; y} = 
  Float.sqrt(x **. 2. +. y **. 2.)

(* Dot notation for accessing record fields *)
let distance v1 v2 = 
  magnitude {x = v1.x -. v2.x; y = v1.y -. v2.y}


(* We can also use our newly defined types in larger types *)
type circle_desc = {center: point2d; radius: float}
type rect_desc = {lower_left: point2d; width: float; height: float}
type segment_desc = {endpoint1: point2d; endpoint2: point2d}


(* variant type *)

type scene_element = 
  | Circle of circle_desc
  | Rect of rect_desc
  | Segment of segment_desc


let is_inside_scene_element point scene_element =  
  let open Float.O in 
  match scene_element with 
  | Circle {center; radius} ->
    distance center point < radius 
  | Rect {lower_left; width; height} -> 
    point.x > lower_left.x && point.x < lower_left.x + width
    && point.y > lower_left.y && point.y < lower_left.y + height
  | Segment {endpoint1; endpoint2} -> false 

let is_inside_scene point scene = 
  List.exists ~f:(is_inside_scene_element point) scene

let test_scene1 () = is_inside_scene {x=3.;y=7.}
    [ Circle {center = {x=4.;y= 4.}; radius = 0.5 } ]

let test_scene2 () =  is_inside_scene {x=3.;y=7.}
    [ Circle {center = {x=4.;y= 4.}; radius = 5.0 } ]