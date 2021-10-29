type t [@@deriving yojson_of]

val of_time : Ptime.t -> t
