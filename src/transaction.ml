open Utils

type span_count = { started : int } [@@deriving yojson]

let sc = { started = 0 }

type t = {
  id : string;
  name : string;
  timestamp : int;
  trace_id : string option;
  transaction_id : string option;
  parent_id : string option;
  duration : float;
  ttype : string; [@key "type"]
  span_count : span_count;
}
[@@deriving yojson]

let make_transaction name ttype =
  let trace_id = Some (make_id ()) in
  let transaction_id = Some (make_id ()) in
  let parent_id = Some (make_id ()) in
  let id = make_id () in
  let timestamp = Unix.time () |> int_of_float |> fun x -> x * 1000 in
  let now = Mtime_clock.counter () in
  let aux () =
    let finished_time = Mtime_clock.count now in
    let duration = Mtime.Span.to_ms finished_time in
    {
      id;
      name;
      trace_id;
      transaction_id;
      timestamp;
      parent_id;
      duration;
      ttype;
      span_count = sc;
    }
  in
  aux
