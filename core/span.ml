type http_context = {
  url : Context.Http.Url.t;
  status_code : int;
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
  type_ : string; [@key "type"]
  timestamp : Timestamp.t;
  context : context option; [@yojson.option]
}
[@@deriving yojson_of]

let make
    ?http_context
    ~duration
    ~id
    ~kind
    ~transaction_id
    ~parent_id
    ~trace_id
    ~timestamp
    name =
  let context = Option.map (fun http -> { http = Some http }) http_context in
  {
    duration;
    id;
    name;
    transaction_id;
    parent_id;
    trace_id;
    type_ = kind;
    timestamp;
    context;
  }
;;
