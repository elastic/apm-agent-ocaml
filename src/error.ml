open Utils

type texception = {
  message : string;
  exntype : string; [@key "type"]
} [@@deriving yojson]

type t = {
  id : string;
  timestamp : int;
  trace_id : string option;
  transaction_id : string option;
  parent_id : string option;
  texception : texception; [@key "exception"]
} [@@deriving yojson]

let make_e e =
  let message = Printexc.to_string e in
  let exntype = "EXN" in
  { message; exntype }

let make_error e =
  let trace_id = Some (make_id ()) in
  let transaction_id = Some (make_id ()) in
  let parent_id = Some (make_id ()) in
  let id = make_id () in
  let timestamp = Unix.time () |> int_of_float |> fun x -> x * 1000 in
  let texception = make_e e in
  { id; trace_id; transaction_id; texception; timestamp; parent_id }
