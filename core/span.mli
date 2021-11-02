type t = {
  duration : Duration.t;
  id : Id.Span_id.t;
  name : string;
  transaction_id : Id.Span_id.t;
  parent_id : Id.Span_id.t;
  trace_id : Id.Trace_id.t;
  type_ : string;
  timestamp : Timestamp.t;
}
[@@deriving yojson_of]

val make :
  duration:Duration.t ->
  id:Id.Span_id.t ->
  name:string ->
  transaction_id:Id.Span_id.t ->
  parent_id:Id.Span_id.t ->
  trace_id:Id.Trace_id.t ->
  timestamp:Timestamp.t ->
  string ->
  t
