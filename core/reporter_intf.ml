module type S = sig
  type t

  val push : t -> Request.t -> unit
end
