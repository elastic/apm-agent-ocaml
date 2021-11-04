module Process : sig
  type t [@@deriving yojson_of]

  val make : ?parent_process_id:int -> ?argv:string array -> int -> string -> t

  val default : t Lazy.t
end

module Container : sig
  type t [@@deriving yojson_of]

  val make : string -> t
end

module System : sig
  type t [@@deriving yojson_of]

  val make :
    ?container:Container.t -> ?system_info:System_info.Platform.t -> unit -> t
end

module Agent : sig
  type t [@@deriving yojson_of]

  val t : t
end

module Framework : sig
  type t [@@deriving yojson_of]

  val make : ?version:string -> string -> t
end

module Language : sig
  type t [@@deriving yojson_of]

  val t : t
end

module Runtime : sig
  type t [@@deriving yojson_of]

  val t : t
end

module Cloud : sig
  type id_with_name = {
    id : string;
    name : string;
  }
  [@@deriving yojson_of]

  type t [@@deriving yojson_of]

  val make :
    ?region:string ->
    ?availability_zone:string ->
    ?instance:id_with_name ->
    ?machine:string ->
    ?account:id_with_name ->
    ?project:id_with_name ->
    string ->
    t
end

module Service : sig
  type t [@@deriving yojson_of]

  val make :
    ?version:string ->
    ?environment:string ->
    ?framework:Framework.t ->
    ?node:string ->
    string ->
    t
end

module User : sig
  type t [@@deriving yojson_of]

  val make : ?username:string -> ?id:string -> ?email:string -> unit -> t
end

type t [@@deriving yojson_of]

val make :
  ?process:Process.t ->
  ?system:System.t ->
  ?framework:Framework.t ->
  ?cloud:Cloud.t ->
  ?user:User.t ->
  Service.t ->
  t
