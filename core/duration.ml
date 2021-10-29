type t = Ptime.Span.t

let yojson_of_t t = `Float (Ptime.Span.to_float_s t *. 1000.)

let of_span t = t
