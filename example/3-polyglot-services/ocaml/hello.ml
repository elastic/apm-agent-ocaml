open! Base
open Opium
open Lwt
open Cohttp_lwt_unix

let upstream_service = Uri.of_string (Sys.getenv_exn "UPSTREAM_SERVICE")

type message_object = { name : string } [@@deriving yojson]

let ping_handler _req = Opium.Response.of_plain_text "pong" |> Lwt.return

let upstream_handler req =
  let apm_ctx = Elastic_apm_opium_middleware.Apm.Apm_context.get req in
  Elastic_apm_lwt_client.Client.with_span apm_ctx ~kind:"http"
    "fetch data from upstream" (fun ctx ->
      let trace_id = Elastic_apm_lwt_client.Client.trace_id ctx in
      let headers =
        Cohttp.Header.of_list
          [ ("traceparent", Elastic_apm_core.Id.Trace_id.to_hex trace_id) ]
      in
      Client.get ~headers upstream_service
  )
  >>= fun (_resp, body) ->
  body |> Cohttp_lwt.Body.to_string >|= fun body ->
  Opium.Response.of_plain_text body
;;

let upstream_handler_greet req =
  let greet = Router.param req "greet" in
  let name = Router.param req "name" in
  let url =
    Uri.with_path upstream_service (String.concat ~sep:"/" [ greet; name ])
  in
  Client.get url >>= fun (_resp, body) ->
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
