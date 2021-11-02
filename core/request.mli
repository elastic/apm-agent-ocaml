type t =
  | Metadata of Metadata.t
  | Transaction of Transaction.t
  | Span of Span.t
  | Error of Error.t
[@@deriving yojson_of]
