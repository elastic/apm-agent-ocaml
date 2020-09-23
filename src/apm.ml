let make_config ?secret_token:(secret_token=None) ?api_key:(api_key=None) ~service_name url =
  { Comms.url; secret_token; api_key; service_name }

let make_request config events =
  Comms.make_request config events ()

let make_error e : Comms.t =
  let event = Error.make_error e in
  Error event

let with_transaction name ttype f : Comms.t list * ('a, exn) result =
  let now = Transaction.make_transaction name ttype in
  match f () with
  | x -> ([(Transaction (now ()))], Ok x)
  | exception exn -> ([Transaction (now ()); make_error exn], Error exn)
