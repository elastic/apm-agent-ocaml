type t =
  | Metadata of Metadata.t
  | Transaction of Transaction.t
  | Span of Span.t
  | Error of Error.t
  | Metrics of Metrics.t

let yojson_of_t payload =
  match payload with
  | Metadata metadata -> `Assoc [ ("metadata", Metadata.yojson_of_t metadata) ]
  | Transaction transaction ->
    `Assoc [ ("transaction", Transaction.yojson_of_t transaction) ]
  | Error e -> `Assoc [ ("error", Error.yojson_of_t e) ]
  | Span span -> `Assoc [ ("span", Span.yojson_of_t span) ]
  | Metrics metrics -> `Assoc [ ("metricset", Metrics.yojson_of_t metrics) ]
;;
