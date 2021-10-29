type t [@@deriving yojson_of]

val of_span : Mtime.Span.t -> t
