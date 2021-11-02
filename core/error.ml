module Stack_frame = struct
  type t = {
    filename : string option; [@yojson.option]
    lineno : int option; [@yojson.option]
    function_ : string option; [@key "function"] [@yojson.option]
    colno : int option; [@yojson.option]
  }
  [@@deriving yojson_of]

  let make slot =
    let function_ = Printexc.Slot.name slot in
    let (lineno, colno, filename) =
      match Printexc.Slot.location slot with
      | Some loc ->
        (Some loc.line_number, Some loc.start_char, Some loc.filename)
      | None -> (None, None, None)
    in
    { filename; lineno; function_; colno }
  ;;
end

module Exception = struct
  type t = {
    message : string;
    type_ : string; [@key "type"]
    stacktrace : Stack_frame.t array option; [@yojson.option]
  }
  [@@deriving yojson_of]

  let concat_map t ~f = Array.concat (Array.to_list (Array.map f t))

  let make backtrace exn =
    let message = Printexc.to_string exn in
    let backtrace_entries = Printexc.raw_backtrace_entries backtrace in
    let stacktrace =
      concat_map backtrace_entries ~f:(fun raw_backtrace_entry ->
          Option.value ~default:[||]
            (Printexc.backtrace_slots_of_raw_entry raw_backtrace_entry)
      )
      |> Array.map Stack_frame.make
    in
    {
      message;
      stacktrace =
        ( if Array.length stacktrace = 0 then
          None
        else
          Some stacktrace
        );
      type_ = "exn";
    }
  ;;
end

type t = {
  id : string;
  timestamp : Timestamp.t;
  trace_id : Id.Trace_id.t option; [@yojson.option]
  transaction_id : Id.Span_id.t option; [@yojson.option]
  parent_id : Id.Span_id.t option; [@yojson.option]
  exception_ : Exception.t; [@key "exception"]
}
[@@deriving yojson_of]

let make ?trace_id ?transaction_id ?parent_id ~exn ~backtrace ~timestamp id =
  {
    id;
    timestamp;
    trace_id;
    transaction_id;
    parent_id;
    exception_ = Exception.make backtrace exn;
  }
;;
