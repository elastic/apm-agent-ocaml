open! Base
open Opium
open Lwt.Infix

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
      let agent =
        Elastic_apm_core.Metadata.Agent.make ~name:"OCaml" ~version:"0.1.0"
      in
      let service =
        Elastic_apm_core.Metadata.Service.make ~agent
          "elastic-apm-opium-example-database"
      in
      let metadata = Elastic_apm_core.Metadata.make ~framework service in
      Elastic_apm_lwt_reporter.Reporter.create ~apm_server ~server_token
        metadata
    in
    Elastic_apm_lwt_client.Client.set_reporter (Some reporter)
;;

type uuid = Uuidm.t

let yojson_of_uuid t = `String (Uuidm.to_string t)

type message = {
  id : uuid;
  message : string;
}
[@@deriving yojson_of]

type payload = { messages : message list } [@@deriving yojson_of]

let healthcheck _req = Lwt.return (Response.of_plain_text "")

let fetch_messages req =
  let apm_ctx = Elastic_apm_opium_middleware.Apm.Apm_context.get req in
  Elastic_apm_lwt_client.Client.with_span apm_ctx ~kind:"db" "postgres lookup"
    (fun _ctx ->
      Db.with_conn req ~f:(fun conn ->
          Pgx_lwt_unix.execute_fold conn "SELECT id, message from message"
            ~init:[] ~f:(fun acc row ->
              match row with
              | [ id; message ] ->
                let id = Pgx.Value.to_uuid_exn id in
                let message = Pgx.Value.to_string_exn message in
                Lwt.return ({ id; message } :: acc)
              | _ -> failwith "Unexpected response from database"
          )
      )
      (* Sleep for some time so we can demo a nice graph in the apm view *)
      >>=
      fun messages ->
      Lwt_unix.sleep 0.3 >|= fun () -> messages
  )
  (* Simulate some more busy work *)
  >>= fun messages ->
  Lwt_unix.sleep 0.2 >|= fun () -> messages
;;

let get_messages req =
  fetch_messages req >|= fun messages ->
  Response.of_json (yojson_of_payload { messages })
;;

let () =
  Fmt_tty.setup_std_outputs ();
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Debug);
  setup_apm ();
  App.empty
  |> App.middleware Elastic_apm_opium_middleware.Apm.m
  |> App.middleware (Db.m 10)
  |> App.middleware Middleware.logger
  |> App.get "/healthcheck" healthcheck
  |> App.get "/messages" get_messages
  |> App.run_command
;;
