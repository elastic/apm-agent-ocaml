open Lwt.Infix

module Host = struct
  type t = {
    server : Uri.t;
    token : string;
  }

  let server_env_key = "ELASTIC_APM_SERVER_URL"
  let token_env_key = "ELASTIC_APM_SECRET_TOKEN"

  let of_env () =
    match (Sys.getenv_opt server_env_key, Sys.getenv_opt token_env_key) with
    | (None, _)
    | (_, None) ->
      None
    | (Some server, Some token) -> Some { server = Uri.of_string server; token }
  ;;

  let make server ~token = { server; token }
end

type t = {
  metadata : Elastic_apm.Metadata.t;
  events : Elastic_apm.Request.t Lwt_stream.t;
  push : Elastic_apm.Request.t option -> unit;
  max_messages_per_batch : int;
  host : Host.t;
  cohttp_ctx : Cohttp_lwt_unix.Client.ctx option;
}

let make_headers t =
  let headers = [ ("content-type", "application/x-ndjson") ] in
  let auth = `Other (Printf.sprintf "Bearer %s" t.host.token) in
  Cohttp.Header.add_authorization (Cohttp.Header.of_list headers) auth
;;

let make_body events =
  let jsons =
    List.map
      (fun e -> Yojson.Safe.to_string (Elastic_apm.Request.yojson_of_t e))
      events
  in
  String.concat "\n" jsons
;;

let send_events t headers events =
  Logs.info (fun m -> m "Sending events");
  let uri = Uri.with_path t.host.server "/intake/v2/events" in
  let body = Cohttp_lwt.Body.of_string (make_body events) in
  Cohttp_lwt_unix.Client.post ?ctx:t.cohttp_ctx ~headers ~body uri
  >>= fun (resp, body) ->
  Logs.info (fun m -> m "Response: %a" Cohttp.Response.pp_hum resp);
  Cohttp_lwt.Body.to_string body >|= fun body ->
  Logs.info (fun m -> m "Body %s" body)
;;

let start_reporter t =
  let headers = make_headers t in
  let rec loop () =
    ( Lwt_stream.peek t.events >|= fun _ ->
      Lwt_stream.get_available_up_to t.max_messages_per_batch t.events
    )
    >>= function
    | [] -> loop ()
    | requests ->
      let payload = Elastic_apm.Request.Metadata t.metadata :: requests in
      send_events t headers payload >>= fun () -> loop ()
  in

  Lwt.async (fun () ->
      Lwt.catch
        (fun () ->
          Logs.info (fun m -> m "starting loop");
          loop ()
        )
        (fun exn ->
          Logs.err (fun m ->
              m "Exception in the reporter loop: %S" (Printexc.to_string exn)
          );
          loop ()
        )
  )
;;

let create ?cohttp_ctx ?(max_messages_per_batch = 20) host metadata =
  let (stream, push) = Lwt_stream.create () in
  let t =
    {
      metadata;
      events = stream;
      push;
      max_messages_per_batch;
      host;
      cohttp_ctx;
    }
  in
  start_reporter t;
  t
;;

let push t event =
  Logs.info (fun m -> m "Pushing events");
  t.push (Some event)
;;
