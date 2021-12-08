module Http = struct
  module Url = struct
    type payload = {
      full : string;
      hash : string option; [@yojson.option]
      hostname : string option; [@yojson.option]
      pathname : string;
      port : int option; [@yojson.option]
      protocol : string option; [@yojson.option]
    }
    [@@deriving yojson_of]

    let to_payload uri =
      let full = Uri.to_string uri in
      let hash = Uri.fragment uri in
      let hostname = Uri.host uri in
      let pathname = Uri.path uri in
      let port = Uri.port uri in
      let protocol = Uri.scheme uri in
      { full; hash; hostname; pathname; port; protocol }
    ;;

    type t = Uri.t

    let yojson_of_t t = yojson_of_payload (to_payload t)
  end
  module Response = struct
    type t = {
      decoded_body_size : int option; [@yojson.option]
      encoded_body_size : int option; [@yojson.option]
      headers : (string * string) list;
      status_code : int;
      transfer_size : int option; [@yojson.option]
    }
    [@@deriving yojson_of]

    let make
        ?decoded_body_size
        ?encoded_body_size
        ?(headers = [])
        ?transfer_size
        status_code =
      {
        decoded_body_size;
        encoded_body_size;
        headers;
        transfer_size;
        status_code;
      }
    ;;
  end

  module Request = struct
    type t = {
      body : string option; [@yojson.option]
      headers : (string * string) list;
      http_version : string;
      meth : string; [@yojson.key "method"]
      url : Url.t;
      status_code : int; (* response : response; *)
    }
    [@@deriving yojson_of]

    let make ?body ?(headers = []) ~http_version ~meth ~url status_code =
      { body; headers; http_version; meth; url; status_code }
    ;;
  end
end
