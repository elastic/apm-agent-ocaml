module type S = sig
  type t [@@deriving yojson_of]

  val equal : t -> t -> bool

  val create : unit -> t

  val create_gen : Random.State.t -> t

  val to_string : t -> string

  val to_hex : t -> string

  val of_hex : string -> t
end
