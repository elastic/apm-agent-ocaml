type config = {
  url : Uri.t;
  api_key : string option;
  secret_token : string option;
  service_name : string;
}

type t =
 | Error of Error.t
 | Metadata of Metadata.t
 | Transaction of Transaction.t

let to_string event =
  let (let+) = Lwt.bind in
  let json = match event with
    | Error e -> `Assoc [("error", Error.to_yojson e)]
    | Metadata m -> `Assoc [("metadata", Metadata.to_yojson m)]
    | Transaction t -> `Assoc [("transaction", Transaction.to_yojson t)]
  in
  let b = Yojson.Safe.to_string json ^ "\n" in
  let+ () = Lwt_io.printl b in
  Lwt.return b

let make_headers config =
  let header = Cohttp.Header.init_with "Content-Type" "application/x-ndjson" in
  match config with
  | { api_key = Some key; _ } -> Cohttp.Header.add header "Authorization" ("ApiKey " ^ key)
  | { secret_token = Some token; _ } -> Cohttp.Header.add header "Authorization" ("Bearer " ^ token)
  | _ -> header

let make_request config (events : t list) () =
  let (let+) = Lwt.bind in
  let uri = Uri.with_path config.url "/intake/v2/events" in
  let metadata = Metadata (Metadata.make_metadata ~name:config.service_name) in
  let+ items = Lwt_list.map_s to_string (metadata :: events) in
  let items = String.concat "" items in
  let headers = make_headers config in
  let body = Cohttp_lwt.Body.of_string items in
  let+ _resp, body = Cohttp_lwt_unix.Client.post ~headers ~body uri in
  let+ body = Cohttp_lwt.Body.to_string body in
  Lwt_io.printl body
