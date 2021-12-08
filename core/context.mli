module Http : sig
  module Url : sig
    type t = Uri.t [@@deriving yojson_of]
  end
  module Request : sig
    type t [@@deriving yojson_of]

    val make :
      ?body:string ->
      ?headers:(string * string) list ->
      http_version:string ->
      meth:string ->
      Uri.t ->
      t

    val url : t -> Url.t
  end

  module Response : sig
    type t [@@deriving yojson_of]
    val make :
      ?decoded_body_size:int ->
      ?encoded_body_size:int ->
      ?headers:(string * string) list ->
      ?transfer_size:int ->
      int ->
      t

    val status_code : t -> int
  end
end
