type t = {
  url : Uri.t;
  api_key : string option;
  secret_token : string option;
  service_name : string;
}
[@@deriving make]
