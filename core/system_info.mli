module Platform : sig
  type t = {
    architecture : string;
    hostname : string;
    platform : string;
  }
  [@@deriving yojson_of]

  val default : t lazy_t

  val make : architecture:string -> hostname:string -> platform:string -> t
end
