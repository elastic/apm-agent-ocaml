let url =
  Uri.of_string
    "https://000e13d9d96a4cf5b626d8d660b2e247.apm.us-east-1.aws.cloud.es.io"
let secret_token = "BxsUCry2J82rYTr9Xq"
let service_name = "veryRealService"

let foobar () = Lwt_unix.sleep 10.0

let foobar2 () =
  let () = Unix.sleep 5 in
  failwith "crash now."

let main () =
  let ( let* ) = Lwt.bind in
  let context = Elastic_apm.Context.make ~secret_token ~service_name ~url () in
  Elastic_apm.Apm.init context;
  let* () =
    Elastic_apm.Apm.with_transaction_lwt ~name:"foobar" ~type_:"http" foobar
  in
  (* Sleep a bit longer to give the sender time to do its job *)
  Lwt_unix.sleep 10.0

let () = Lwt_main.run (main ())
