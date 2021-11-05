open! Base
open Opium
open Lwt
open Cohttp_lwt_unix

let upstream_service = Uri.of_string (Sys.getenv_exn "UPSTREAM_SERVICE")

type message_object = { name : string } [@@deriving yojson]

let ping_handler _req = Opium.Response.of_plain_text "pong" |> Lwt.return

let upstream_handler req =
  let apm_ctx = Elastic_apm_opium_middleware.Apm.Apm_context.get req in
  let id = Elastic_apm_lwt_client.Client.trace_id apm_ctx in
  let parent_id = Elastic_apm_lwt_client.Client.id apm_ctx in
  let traceparent =
    Printf.sprintf "00-%s-%s-01"
      (Elastic_apm_core.Id.Trace_id.to_hex id)
      (Elastic_apm_core.Id.Span_id.to_hex parent_id)
  in
  let headers = Cohttp.Header.of_list [ ("traceparent", traceparent) ] in
  Client.get ~headers upstream_service >>= fun (_resp, body) ->
  body |> Cohttp_lwt.Body.to_string >|= fun body ->
  Opium.Response.of_plain_text body
;;

let upstream_handler_greet req =
  let greet = Router.param req "greet" in
  let name = Router.param req "name" in
  let url =
    Uri.with_path upstream_service (String.concat ~sep:"/" [ greet; name ])
  in
  let apm_ctx = Elastic_apm_opium_middleware.Apm.Apm_context.get req in
  Elastic_apm_lwt_client.Client.with_span apm_ctx ~kind:"http"
    "fetch greeting from upstream" (fun ctx ->
      let trace_id = Elastic_apm_lwt_client.Client.trace_id ctx in
      let parent_id = Elastic_apm_lwt_client.Client.id ctx in
      let traceparent =
        Printf.sprintf "00-%s-%s-01"
          (Elastic_apm_core.Id.Trace_id.to_hex trace_id)
          (Elastic_apm_core.Id.Span_id.to_hex parent_id)
      in
      let headers = Cohttp.Header.of_list [ ("traceparent", traceparent) ] in
      Client.get ~headers url
  )
  >>= fun (_resp, body) ->
  body |> Cohttp_lwt.Body.to_string >|= fun body ->
  Opium.Response.of_plain_text body
;;

let init () =
  Fmt_tty.setup_std_outputs ();
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Debug);
  let service =
    Elastic_apm_core.Metadata.Service.make "elastic-apm-opium-example-polyglot"
  in
  Elastic_apm_opium_middleware.Apm.Init.setup_reporter service
;;

let () =
  init ();
  App.empty
  |> App.middleware Elastic_apm_opium_middleware.Apm.m
  |> App.get "/ping" ping_handler
  |> App.get "/upstream" upstream_handler
  |> App.get "/upstream/:greet/:name" upstream_handler_greet
  |> App.run_command
;;
