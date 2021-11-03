open Lwt.Infix

type t = {
  metadata : Elastic_apm_core.Metadata.t;
  events : Elastic_apm_core.Request.t Lwt_stream.t;
  push : Elastic_apm_core.Request.t option -> unit;
  max_messages_per_batch : int;
  apm_server : Uri.t;
  server_token : string;
}

let make_headers t =
  let headers = [ ("content-type", "application/x-ndjson") ] in
  let auth = `Other (Printf.sprintf "Bearer %s" t.server_token) in
  Cohttp.Header.add_authorization (Cohttp.Header.of_list headers) auth
;;

let make_body events =
  let jsons =
    List.map
      (fun e -> Yojson.Safe.to_string (Elastic_apm_core.Request.yojson_of_t e))
      events
  in
  String.concat "\n" jsons
;;

let send_events t headers events =
  Logs.info (fun m -> m "Sending events");
  let uri = Uri.with_path t.apm_server "/intake/v2/events" in
  let body = Cohttp_lwt.Body.of_string (make_body events) in
  Cohttp_lwt_unix.Client.post ~headers ~body uri >>= fun (resp, body) ->
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
      let payload = Elastic_apm_core.Request.Metadata t.metadata :: requests in
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

let create ?(max_messages_per_batch = 20) ~apm_server ~server_token metadata =
  let (stream, push) = Lwt_stream.create () in
  let t =
    {
      metadata;
      events = stream;
      push;
      max_messages_per_batch;
      apm_server;
      server_token;
    }
  in
  start_reporter t;
  t
;;

let push t event =
  Logs.info (fun m -> m "Pushing events");
  t.push (Some event)
;;
