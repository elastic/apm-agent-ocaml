open Core
open Async

module Log = Log.Make_global ()

module Host = struct
  type t = {
    server : Uri.t;
    token : string;
  }

  let server_env_key = "ELASTIC_APM_SERVER_URL"
  let token_env_key = "ELASTIC_APM_SECRET_TOKEN"

  let make server ~token = { server; token }

  let of_env () =
    let%bind.Option server = Sys.getenv server_env_key in
    let%bind.Option token = Sys.getenv token_env_key in
    Some (make (Uri.of_string server) ~token)
  ;;
end

module Spec = struct
  type t = {
    metadata : Elastic_apm.Metadata.t;
    max_messages_per_batch : int;
    client : Blue_http.Client.t;
    host : Host.t;
  }

  let make
      ?(client = Blue_http.Client.create ())
      ?(max_messages_per_batch = 20)
      host
      metadata =
    { metadata; max_messages_per_batch; client; host }
  ;;

  let to_headers t =
    let headers = [ ("content-type", "application/x-ndjson") ] in
    let auth = `Other (Printf.sprintf "Bearer %s" t.host.token) in
    Cohttp.Header.add_authorization (Cohttp.Header.of_list headers) auth
  ;;
end

type t = Elastic_apm.Request.t Pipe.Writer.t

let make_body events =
  let jsons =
    List.map events ~f:(fun e ->
        Yojson.Safe.to_string (Elastic_apm.Request.yojson_of_t e)
    )
  in
  String.concat ~sep:"\n" jsons
;;

let send_events (spec : Spec.t) headers events =
  Log.debug "Sending events";
  let uri = Uri.with_path spec.host.server "/intake/v2/events" in
  let body = Cohttp_async.Body.of_string (make_body events) in
  let%map resp =
    Blue_http.call_ignore_body ~client:spec.client ~headers ~body `POST uri
  in
  Log.debug "Response code: %d"
    (Cohttp.Code.code_of_status (Cohttp.Response.status resp))
;;

let read spec reader =
  let headers = Spec.to_headers spec in
  Deferred.repeat_until_finished () (fun () ->
      match%bind
        Pipe.read' ~max_queue_length:spec.max_messages_per_batch reader
      with
      | `Eof -> return (`Finished ())
      | `Ok queue ->
        let requests = Queue.to_list queue in
        let payload = Elastic_apm.Request.Metadata spec.metadata :: requests in
        let%map () = send_events spec headers payload in
        `Repeat ()
  )
;;

let create ?client ?max_messages_per_batch host metadata =
  let spec = Spec.make ?client ?max_messages_per_batch host metadata in
  Pipe.create_writer (read spec)
;;

let push t event =
  Log.debug "Pushing event";
  Pipe.write_without_pushback t event
;;
