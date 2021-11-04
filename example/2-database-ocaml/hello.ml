open Opium
open Lwt.Infix

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
  Db.with_conn req ~f:(fun conn ->
      Pgx_lwt_unix.execute_fold conn "SELECT id, message from message" ~init:[]
        ~f:(fun acc row ->
          match row with
          | [ id; message ] ->
            let id = Pgx.Value.to_uuid_exn id in
            let message = Pgx.Value.to_string_exn message in
            Lwt.return ({ id; message } :: acc)
          | _ -> failwith "Unexpected response from database"
      )
  )
;;

let get_messages req =
  fetch_messages req >|= fun messages ->
  Response.of_json (yojson_of_payload { messages })
;;

let () =
  Fmt_tty.setup_std_outputs ();
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Debug);
  App.empty
  |> App.middleware (Db.m 10)
  |> App.middleware Middleware.logger
  |> App.get "/healthcheck" healthcheck
  |> App.get "/messages" get_messages
  |> App.run_command
;;
