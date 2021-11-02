type t [@@deriving yojson_of]

val now : unit -> t

val of_us_since_epoch : int -> t
