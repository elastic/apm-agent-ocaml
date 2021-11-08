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

let init () =
  Fmt_tty.setup_std_outputs ();
  Logs.set_level (Some Info);
  Logs.set_reporter (Logs_fmt.reporter ());
  Elastic_apm_opium_middleware.Apm.Init.setup_reporter "opium-elastic-apm-demo"
;;

let () =
  init ();
  App.empty
  |> App.middleware Elastic_apm_opium_middleware.Apm.m
  |> App.post "/reverse" reverse_handler
  |> App.run_command
;;
