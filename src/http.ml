type response = {
  status_code : int;
  transfer_size : int;
} [@@deriving to_yojson]

type url = {
  raw : string;
  protocol : string;
  full : string;
  hostname : string;
  port : int;
  pathname : string;
} [@@deriving to_yojson]

type request = {
  meth : string;
  url : url;
  http_version : string;
} [@@deriving to_yojson]
