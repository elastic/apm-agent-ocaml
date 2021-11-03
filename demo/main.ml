exception Dummy_exn of string

let () = Printexc.record_backtrace true

let boom () = raise (Dummy_exn "Hello")

let foo () = boom ()

let test_error () = foo ()

let secret_token = Sys.getenv "DEV_ELASTIC_TOKEN"
let server_url = Uri.of_string (Sys.getenv "ELASTIC_ENDPOINT")

let metadata () =
  let open Elastic_apm_core in
  let agent =
    Elastic_apm_core.Metadata.Agent.make ~name:"elastic-apm" ~version:"0.1.0"
  in
  let service =
    Elastic_apm_core.Metadata.Service.make ~language:Metadata.Language.t
      ~runtime:Metadata.Runtime.t ~agent "demo-apm-service"
  in
  Elastic_apm_core.Metadata.make ~system:(Metadata.System.make ()) service
;;

let fail span b =
  let open Elastic_apm_core in
  try
    if b then test_error ();
    None
  with
  | exn ->
    let backtrace = Printexc.get_raw_backtrace () in
    let err =
      Some
        (Elastic_apm_core.Error.make ~trace_id:span.Span.trace_id ~backtrace
           ~exn
           ~timestamp:(Elastic_apm_core.Timestamp.now ())
           ~parent_id:span.id ()
        )
    in
    err
;;

let () =
  Fmt_tty.setup_std_outputs ();
  Logs.set_reporter (Logs_fmt.reporter ());
  let reporter =
    Elastic_apm_lwt_reporter.Reporter.create ~apm_server:server_url
      ~server_token:secret_token (metadata ())
  in
  let open Elastic_apm_core in
  let trace_id = Id.Trace_id.create () in
  let transaction =
    Transaction.make
      ~duration:(Duration.of_span @@ Mtime.Span.of_uint64_ns 80000000L)
      ~id:(Id.Span_id.create ())
      ~span_count:(Transaction.Span_count.make 1)
      ~trace_id ~kind:"request" "Test12"
  in
  let span =
    Span.make
      ~duration:(Duration.of_span @@ Mtime.Span.of_uint64_ns 40000000L)
      ~transaction_id:transaction.id ~parent_id:transaction.id
      ~timestamp:(Timestamp.now ()) ~id:(Id.Span_id.create ()) ~trace_id
      ~kind:"db" "Test7"
  in
  let transaction2 =
    Transaction.make
      ~duration:(Duration.of_span @@ Mtime.Span.of_uint64_ns 30000000L)
      ~id:(Id.Span_id.create ()) ~parent_id:span.id
      ~span_count:(Transaction.Span_count.make 0)
      ~trace_id ~kind:"db" "Test13"
  in
  let events =
    match fail span false with
    | None ->
      [
        Elastic_apm_core.Request.Transaction transaction;
        Span span;
        Transaction transaction2;
      ]
    | Some e ->
      [
        Elastic_apm_core.Request.Transaction transaction;
        Span span;
        Transaction transaction2;
        Elastic_apm_core.Request.Error e;
      ]
  in
  Logs.info (fun m -> m "push events");
  List.iter
    (fun event -> Elastic_apm_lwt_reporter.Reporter.push reporter event)
    events;
  Lwt_main.run (Lwt_unix.sleep 20.)
;;
