type t [@@deriving yojson_of]

val of_span : Ptime.Span.t -> t
