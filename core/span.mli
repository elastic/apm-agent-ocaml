type http_context = {
  url : string;
  status_code : int option; [@yojson.option]
}
[@@deriving yojson_of]

type context = { http : http_context option [@yojson.option] }
[@@deriving yojson_of]

type t = {
  duration : Duration.t;
  id : Id.Span_id.t;
  name : string;
  transaction_id : Id.Span_id.t;
  parent_id : Id.Span_id.t;
  trace_id : Id.Trace_id.t;
  type_ : string;
  timestamp : Timestamp.t;
  context : context option;
}
[@@deriving yojson_of]

val make :
  ?http_context:http_context ->
  duration:Duration.t ->
  id:Id.Span_id.t ->
  kind:string ->
  transaction_id:Id.Span_id.t ->
  parent_id:Id.Span_id.t ->
  trace_id:Id.Trace_id.t ->
  timestamp:Timestamp.t ->
  string ->
  t
