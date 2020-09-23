module Apm = Elastic_apm.Apm

let url =
  Uri.of_string
    "https://000e13d9d96a4cf5b626d8d660b2e247.apm.us-east-1.aws.cloud.es.io"
let secret_token = Some "BxsUCry2J82rYTr9Xq"
let service_name = "veryRealService"

let foobar () = Unix.sleep 10

let foobar2 () =
  let () = Unix.sleep 5 in
  failwith "crash now."

let main () =
  let c = Apm.make_config ~secret_token ~service_name url in
  let (e, _results) = Apm.with_transaction "foobar" "http" foobar in
  let r = Apm.make_request c e in
  Lwt_main.run r

let () = main ()
