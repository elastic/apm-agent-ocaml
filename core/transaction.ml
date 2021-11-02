module Span_count = struct
  type t = {
    dropped : int option; [@yojson.option]
    started : int;
  }
  [@@deriving yojson_of]

  let make ?dropped started = { dropped; started }
end

type t = {
  duration : Duration.t;
  id : Id.Span_id.t;
  span_count : Span_count.t;
  trace_id : Id.Trace_id.t;
  type_ : string; [@key "type"]
  name : string;
}
[@@deriving yojson_of]

let make ~duration ~id ~span_count ~trace_id ~kind name =
  { duration; id; span_count; trace_id; type_ = kind; name }
;;
