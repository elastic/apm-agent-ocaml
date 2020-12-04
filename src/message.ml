type t =
  | Error of Error.t
  | Metadata of Metadata.t
  | Transaction of Transaction.t

let to_yojson (event : t) : Yojson.Safe.t =
  match event with
  | Error e -> `Assoc [ ("error", Error.to_yojson e) ]
  | Metadata m -> `Assoc [ ("metadata", Metadata.to_yojson m) ]
  | Transaction t -> `Assoc [ ("transaction", Transaction.to_yojson t) ]

let to_string (event : t) = Yojson.Safe.to_string (to_yojson event)

let make_headers (context : Context.t) =
  let headers = [ ("content-type", "application/x-ndjson") ] in
  match context with
  | { api_key = Some key; _ } -> ("Authorization", "ApiKey " ^ key) :: headers
  | { secret_token = Some token; _ } ->
    ("Authorization", "Bearer " ^ token) :: headers
  | _ -> headers

let make_body (context : Context.t) (events : t list) =
  let metadata = Metadata (Metadata.make ~name:context.service_name) in
  let jsons = List.map to_string (metadata :: events) in
  String.concat "\n" jsons

let send (context : Context.t) (events : t list) =
  let ( let* ) = Lwt.bind in
  let uri = Uri.with_path context.url "/intake/v2/events" in
  let headers = Cohttp.Header.of_list (make_headers context) in
  let body = Cohttp_lwt.Body.of_string (make_body context events) in
  let* (response, response_body) =
    Cohttp_lwt_unix.Client.post ~headers ~body uri
  in
  let* response_body = Cohttp_lwt.Body.to_string response_body in
  Lwt.return (response, response_body)
