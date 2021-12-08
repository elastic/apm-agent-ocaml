module Span_count = struct
  type t = {
    dropped : int option; [@yojson.option]
    started : int;
  }
  [@@deriving yojson_of]

  let make ?dropped started = { dropped; started }

  let add_started t more = { t with started = t.started + more }

  let add_dropped t more =
    match more with
    | 0 -> t
    | _ ->
      let current = Option.value t.dropped ~default:0 in
      { t with dropped = Some (current + more) }
  ;;
end

type context = {
  request : Context.Http.Request.t option; [@yojson.option]
  response : Context.Http.Response.t option; [@yojson.option]
}
[@@deriving yojson_of]

type t = {
  timestamp : Timestamp.t;
  duration : Duration.t;
  id : Id.Span_id.t;
  span_count : Span_count.t;
  trace_id : Id.Trace_id.t;
  parent_id : Id.Span_id.t option; [@yojson.option]
  type_ : string; [@key "type"]
  name : string;
  context : context;
}
[@@deriving yojson_of]

let make
    ?parent_id
    ?request
    ?response
    ~timestamp
    ~duration
    ~id
    ~span_count
    ~trace_id
    ~kind
    name =
  let context = { request; response } in
  {
    timestamp;
    duration;
    id;
    span_count;
    trace_id;
    type_ = kind;
    name;
    parent_id;
    context;
  }
;;
