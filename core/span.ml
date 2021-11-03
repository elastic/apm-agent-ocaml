type t = {
  duration : Duration.t;
  id : Id.Span_id.t;
  name : string;
  transaction_id : Id.Span_id.t;
  parent_id : Id.Span_id.t;
  trace_id : Id.Trace_id.t;
  type_ : string; [@key "type"]
  timestamp : Timestamp.t;
}
[@@deriving yojson_of]

let make
    ~duration
    ~id
    ~kind
    ~transaction_id
    ~parent_id
    ~trace_id
    ~timestamp
    name =
  {
    duration;
    id;
    name;
    transaction_id;
    parent_id;
    trace_id;
    type_ = kind;
    timestamp;
  }
;;
