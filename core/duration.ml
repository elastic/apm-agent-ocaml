type t = Mtime.Span.t

let yojson_of_t t = `Float (Mtime.Span.to_ms t)

let of_span t = t
