type t = {
  mutable metadata_logged : bool;
  metadata : Elastic_apm.Metadata.t;
  src : Logs.src;
  log : (module Logs.LOG);
}

let pp_request ppf request =
  let json = Elastic_apm.Request.yojson_of_t request in
  Format.fprintf ppf "%s" (Yojson.Safe.to_string json)
;;

let push t (request : Elastic_apm.Request.t) =
  let module Log = (val t.log) in
  if not t.metadata_logged then (
    Log.info (fun m -> m "%a" pp_request (Metadata t.metadata));
    t.metadata_logged <- true
  );
  match request with
  | (Metadata _ | Span _ | Transaction _ | Metrics _) as req ->
    Log.info (fun m -> m "%a" pp_request req)
  | Error _ as req -> Log.err (fun m -> m "%a" pp_request req)
;;

let create ?(src = Logs.Src.create "elastic-apm.logs-reporter") metadata =
  { metadata_logged = false; src; log = Logs.src_log src; metadata }
;;

let src t = t.src
