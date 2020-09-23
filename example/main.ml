let url =
  Uri.of_string
    "https://000e13d9d96a4cf5b626d8d660b2e247.apm.us-east-1.aws.cloud.es.io"
let secret_token = "BxsUCry2J82rYTr9Xq"
let service_name = "veryRealService"

let foobar () = Unix.sleep 10

let foobar2 () =
  let () = Unix.sleep 5 in
  failwith "crash now."

let main () =
  let c = Elastic_apm.Context.make ~secret_token ~service_name ~url () in
  let (e, _results) =
    Elastic_apm.Apm.with_transaction ~name:"foobar" ~type_:"http" foobar
  in
  let r = Elastic_apm.Message.send c e in
  let (_response, body) = Lwt_main.run r in
  print_endline body

let () = main ()
