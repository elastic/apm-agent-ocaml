module type S = sig
  type t

  val create : unit -> t

  val create_gen : Random.State.t -> t

  val to_string : t -> string

  val to_hex : t -> string
end
