type t [@@deriving yojson_of]

val make :
  ?random_state:Random.State.t ->
  ?trace_id:Id.Trace_id.t ->
  ?transaction_id:Id.Span_id.t ->
  ?parent_id:Id.Span_id.t ->
  exn:exn ->
  backtrace:Printexc.raw_backtrace ->
  timestamp:Timestamp.t ->
  unit ->
  t
