type span_count = { started : int } [@@deriving to_yojson]

let no_span = { started = 0 }

type t = {
  id : string;
  name : string;
  timestamp : int;
  trace_id : string option;
  transaction_id : string option;
  parent_id : string option;
  duration : float;
  type_ : string; [@key "type"]
  span_count : span_count;
}
[@@deriving to_yojson, make]

let make_transaction
    ?(parent_id = Id.make ())
    ?(trace_id = Id.make ())
    ~name
    ~type_ =
  let id = Id.make () in
  let timestamp = Timestamp.now_ms () in
  let transaction_id = Id.make () in
  let now = Mtime_clock.counter () in
  let finished () =
    let finished_time = Mtime_clock.count now in
    let duration = Mtime.Span.to_us finished_time in
    make ~id ~name ~timestamp ~trace_id ~transaction_id ~parent_id ~duration
      ~type_ ~span_count:no_span ()
  in
  finished
