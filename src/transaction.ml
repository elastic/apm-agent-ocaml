type span_count = { started : int } [@@deriving to_yojson]

let no_span = { started = 0 }

type context = {
  request : Http.request option;
  response : Http.response option;
} [@@deriving to_yojson, make]

type t = {
  id : string;
  name : string;
  timestamp : int;
  trace_id : string;
  parent_id : string option;
  duration : float;
  type_ : string; [@key "type"]
  span_count : span_count;
  context : context;
}
[@@deriving to_yojson, make]

let make_transaction
  ?(trace : Trace.t option) ?request ~name ~type_ () =
  let id = Trace.make_id () in
  let parent_id, trace_id = match trace with
    | Some t -> t.transaction_id, t.trace_id
    | None -> None, Trace.make_id ()
  in
  let timestamp = Timestamp.now_ms () in
  let now = Mtime_clock.counter () in
  let finished ?response () =
    let finished_time = Mtime_clock.count now in
    let duration = Mtime.Span.to_ms finished_time in
    let span_count = no_span in
    let context = make_context ?request ?response () in
    make ~id ~name ~timestamp ~trace_id ?parent_id ~duration ~type_ ~span_count ~context ()
  in
  let new_trace = { Trace.trace_id; parent_id; transaction_id=(Some id); } in
  (new_trace, finished)
