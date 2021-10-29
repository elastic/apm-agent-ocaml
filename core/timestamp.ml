type t = int [@@deriving yojson_of]

let of_time t =
  let seconds = Ptime.to_float_s t in
  Float.to_int (seconds *. 1000. *. 1000.)
