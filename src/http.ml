type response = {
  status_code : int;
  transfer_size : int;
} [@@deriving to_yojson, make]

type url = {
  protocol : string option;
  full : string;
  hostname : string option;
  port : int option;
  pathname : string option;
} [@@deriving to_yojson, make]

type request = {
  meth : string;
  url : url;
  http_version : string;
} [@@deriving to_yojson, make]

let of_uri u =
  let protocol = Uri.scheme u in
  let full = Uri.to_string u in
  let hostname = Uri.host u in
  let port = Uri.port u in
  let pathname = Uri.path u in
  make_url ?protocol ~full ?hostname ?port ?pathname

let make_request ~meth ~uri ~http_version =
  let url = of_uri uri in
  make_request ~meth ~url ~http_version
