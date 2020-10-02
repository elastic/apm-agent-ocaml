exception Foo of string

let url =
  Uri.of_string
    "https://000e13d9d96a4cf5b626d8d660b2e247.apm.us-east-1.aws.cloud.es.io"
let secret_token = "BxsUCry2J82rYTr9Xq"
let service_name = "veryRealService"

module Bar = struct
  let test2 () = Lwt.fail (failwith "crash now.")

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
  let (let*) = Lwt.bind in
  let helloworld1 () = Unix.sleep 1 in
  let bazfoo2 () = Unix.sleep 1 in
  let () = helloworld1 () in
  let* () = Foo.test2 () in
  let () = bazfoo2 () in
  Lwt.return @@ print_endline "crash now."

let main () =
  let (let*) = Lwt.bind in
  let context = Elastic_apm.Context.make ~secret_token ~service_name ~url () in
  let () = (Printexc.record_backtrace true) in
  Elastic_apm.Apm.init context;
  let* () = Lwt.catch
    (fun () -> Elastic_apm.Apm.with_transaction_lwt ~name:"foobar2" ~type_:"http" foobar2)
    (function
    | _exn -> Lwt_io.printl "got exn for function.")
  in
  (* Sleep a bit longer to give the sender time to do its job *)
  Lwt_unix.sleep 10.0

let invoke () = Lwt_main.run (main ())

open Cmdliner

let main_t =
  let open Term in
  const invoke $ Ezlogs_cli_lwt.setup_log

let info =
  let doc = "test bin for apm." in
  let man =
    [ `S Manpage.s_bugs
    ; `P "Please report bugs to the issue tracker." ]
  in Term.info "example" ~version:"%%VERSION%%" ~doc ~exits:Term.default_exits ~man

let () = Term.exit @@ Term.eval (main_t, Term.info Sys.executable_name)
