module Exception = struct
  type t = {
    message : string;
    type_ : string; [@key "type"]
  }
  [@@deriving to_yojson, make]

  let make (exn : exn) : t = make ~message:(Printexc.to_string exn) ~type_:"exn"
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

let make (exn : exn) : t =
  let id = Id.make () in
  let timestamp = Timestamp.now_ms () in
  let trace_id = Id.make () in
  let transaction_id = Id.make () in
  let parent_id = Id.make () in
  let exception_t = Exception.make exn in
  make ~id ~timestamp ~trace_id ~transaction_id ~parent_id ~exception_t ()
