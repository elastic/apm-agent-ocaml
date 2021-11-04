open! Base
open Opium

type message_object = { message : string } [@@deriving yojson]

let reverse_handler req =
  let%lwt body = Body.to_string req.Request.body in
  let message_object =
    body |> Yojson.Safe.from_string |> message_object_of_yojson
  in

  let rev_body =
    `String message_object.message |> Yojson.Safe.to_string |> String.rev
  in
  Response.make ~body:(Body.of_string rev_body) () |> Lwt.return
;;

let setup_apm () =
  let server_env = "ELASTIC_APM_SERVER" in
  let token_env = "ELASTIC_APM_TOKEN" in
  match (Sys.getenv server_env, Sys.getenv token_env) with
  | (None, _)
  | (_, None) ->
    Fmt.epr
      "APM reporting disabled because %s and %s are not both defined in the \
       environment"
      server_env token_env
  | (Some apm_server, Some server_token) ->
    let apm_server = Uri.of_string apm_server in
    let reporter =
      let framework = Elastic_apm_core.Metadata.Framework.make "opium" in
      let service =
        Elastic_apm_core.Metadata.Service.make "elastic-apm-opium-example"
      in
      let metadata = Elastic_apm_core.Metadata.make ~framework service in
      Elastic_apm_lwt_reporter.Reporter.create ~apm_server ~server_token
        metadata
    in
    Elastic_apm_lwt_client.Client.set_reporter (Some reporter)
;;

let () =
  setup_apm ();
  App.empty
  |> App.middleware Elastic_apm_opium_middleware.Apm.m
  |> App.post "/reverse" reverse_handler
  |> App.run_command
;;
