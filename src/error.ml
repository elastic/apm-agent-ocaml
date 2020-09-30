module Stack_trace = struct
  type stack_frame = {
    filename : string option;
    fn : string option; [@key "function"]
    lineno : int option;
    colno : int option;
  } [@@deriving to_yojson, make]

  type t = stack_frame list [@@deriving to_yojson]

  let make_stacktrace (st : Printexc.raw_backtrace) : t =
    let make_slot slot : stack_frame =
      let fn = Printexc.Slot.name slot in
      let lineno, colno, filename = match Printexc.Slot.location slot with
        | Some l -> (Some l.line_number, Some l.start_char, Some l.filename)
        | None -> (None, None, None)
      in
      { fn; filename; lineno; colno }
    in
    match Printexc.backtrace_slots st with
    | None -> []
    | Some slots -> Array.map make_slot slots |> Array.to_list
end

module Exception = struct
  type t = {
    message : string;
    type_ : string; [@key "type"]
    stacktrace : Stack_trace.t
  }
  [@@deriving to_yojson, make]

  let make st (exn : exn) : t =
    let stacktrace = Stack_trace.make_stacktrace st in
    let () = Printf.printf "stacktrace is %d long.\n" (List.length stacktrace) in
    make  ~message:(Printexc.to_string exn) ~type_:"exn" ~stacktrace
end

type t = {
  id : string;
  timestamp : int;
  trace_id : string option;
  transaction_id : string option;
  parent_id : string option;
  exception_t : Exception.t; [@key "exception"]
}
[@@deriving to_yojson, make]

let make st (exn : exn) : t =
  let id = Id.make () in
  let timestamp = Timestamp.now_ms () in
  let trace_id = Id.make () in
  let transaction_id = Id.make () in
  let parent_id = Id.make () in
  let exception_t = Exception.make st exn in
  make ~id ~timestamp ~trace_id ~transaction_id ~parent_id ~exception_t ()
