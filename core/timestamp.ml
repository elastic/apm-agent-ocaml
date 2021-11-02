type t = int [@@deriving yojson_of]

let now () : t =
  let t = Ptime_clock.now () in
  let seconds = Ptime.to_float_s t in
  Float.to_int (seconds *. 1000. *. 1000.)

let of_us_since_epoch us : t = us
