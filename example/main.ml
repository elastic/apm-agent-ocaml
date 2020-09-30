let url =
  Uri.of_string
    "https://000e13d9d96a4cf5b626d8d660b2e247.apm.us-east-1.aws.cloud.es.io"
let secret_token = "BxsUCry2J82rYTr9Xq"
let service_name = "veryRealService"

module Bar = struct
  let test2 () = failwith "crash now."

  let test1 () =
    let () = Unix.sleep 1 in
    test2 ()
end

module Foo = struct
  let test1 () =
    let () = Unix.sleep 1 in
    Bar.test1 ()

  let test2 () = test1 ()
end

let foobar () = Lwt.return @@ Unix.sleep 1

let foobar2 () =
  let helloworld1 () = Unix.sleep 1 in
  let bazfoo2 () = Unix.sleep 1 in
  let () = helloworld1 () in
  let () = Foo.test2 () in
  let () = bazfoo2 () in
  print_endline "crash now."

let main () =
  let ( let* ) = Lwt.bind in
  let context = Elastic_apm.Context.make ~secret_token ~service_name ~url () in
  let () = (Printexc.record_backtrace true) in
  Elastic_apm.Apm.init context;
  let* () =
    Elastic_apm.Apm.with_transaction_lwt ~name:"foobar" ~type_:"http" foobar
  in
  (* Sleep a bit longer to give the sender time to do its job *)
  Lwt_unix.sleep 10.0

let () = Lwt_main.run (main ())
