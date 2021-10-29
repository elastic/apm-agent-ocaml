module Platform : sig
  type t = { architecture : string; hostname : string; platform : string }

  val default : t lazy_t
end
