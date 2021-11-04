open Opium
open Lwt
open Cohttp_lwt_unix

type message_object = { name : string } [@@deriving yojson]

let ping_handler _req = Opium.Response.of_plain_text "pong" |> Lwt.return

let upstream_handler _req =
  Client.get (Uri.of_string "http://localhost:5000/") >>= fun (_resp, body) ->
  body |> Cohttp_lwt.Body.to_string >|= fun body ->
  Opium.Response.of_plain_text body
;;

let upstream_handler_greet req =
  let greet = Router.param req "greet" in
  let name = Router.param req "name" in
  let url =
    String.concat "/" [ "http://localhost:5000"; greet; name ] |> Uri.of_string
  in
  Client.get url >>= fun (_resp, body) ->
  body |> Cohttp_lwt.Body.to_string >|= fun body ->
  Opium.Response.of_plain_text body
;;

let () =
  App.empty
  |> App.get "/ping" ping_handler
  |> App.get "/upstream" upstream_handler
  |> App.get "/upstream/:greet/:name" upstream_handler_greet
  |> App.run_command
;;
