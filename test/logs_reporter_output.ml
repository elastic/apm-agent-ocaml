let () =
  (* Setup log output *)
  Fmt_tty.setup_std_outputs ();
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level ~all:true (Some Info)
;;

let state = Random.State.make [| 1; 2; 3; 4; 5 |]

let service = Elastic_apm_core.Metadata.Service.make "testservice"
let process = Elastic_apm_core.Metadata.Process.make 1 "testprocess"
let system_info =
  Elastic_apm_core.System_info.Platform.make ~architecture:"testarch"
    ~hostname:"testhost" ~platform:"testplatform"
;;
let system = Elastic_apm_core.Metadata.System.make ~system_info ()
let metadata = Elastic_apm_core.Metadata.make ~system ~process service

let trace_id = Elastic_apm_core.Id.Trace_id.create_gen state
let transaction =
  let open Elastic_apm_core in
  Transaction.make
    ~timestamp:(Timestamp.of_us_since_epoch (365 * 50 * 86_4000 * 1_000_000))
    ~duration:(Duration.of_span @@ Mtime.Span.of_uint64_ns 80000000L)
    ~id:(Id.Span_id.create_gen state)
    ~span_count:(Transaction.Span_count.make 1)
    ~trace_id ~kind:"request" "testtransaction"
;;

let%expect_test "logs reporter - default logs src" =
  let reporter = Elastic_apm_logs_reporter.Reporter.create metadata in
  Elastic_apm_logs_reporter.Reporter.push reporter (Transaction transaction);
  [%expect
    {|
    inline_test_runner_apm_agent_tests.exe: [INFO] {"metadata":{"process":{"pid":1,"title":"testprocess","argv":[]},"system":{"architecture":"testarch","hostname":"testhost","platform":"testplatform"},"agent":{"name":"OCaml","version":"n/a"},"language":{"name":"OCaml","version":"4.13.1"},"runtime":{"name":"OCaml","version":"4.13.1"},"service":{"name":"testservice","agent":{"name":"OCaml","version":"n/a"},"language":{"name":"OCaml","version":"4.13.1"},"runtime":{"name":"OCaml","version":"4.13.1"}}}}
    inline_test_runner_apm_agent_tests.exe: [INFO] {"transaction":{"timestamp":15768000000000000,"duration":80.0,"id":"3e466abbf8b38218","span_count":{"started":1},"trace_id":"5e00cc610bf958d233ad4932f4e954cc","type":"request","name":"testtransaction"}}|}];
  (* No metadata on following log output *)
  Elastic_apm_logs_reporter.Reporter.push reporter (Transaction transaction);
  [%expect
    {| inline_test_runner_apm_agent_tests.exe: [INFO] {"transaction":{"timestamp":15768000000000000,"duration":80.0,"id":"3e466abbf8b38218","span_count":{"started":1},"trace_id":"5e00cc610bf958d233ad4932f4e954cc","type":"request","name":"testtransaction"}} |}]
;;

let%expect_test "logs reporter - custom logs src" =
  (* Setup custom log source *)
  let src = Logs.Src.create "test.src" in
  let reporter = Elastic_apm_logs_reporter.Reporter.create ~src metadata in
  (* First log output - has metadata *)
  Elastic_apm_logs_reporter.Reporter.push reporter (Transaction transaction);
  [%expect
    {|
    inline_test_runner_apm_agent_tests.exe: [INFO] {"metadata":{"process":{"pid":1,"title":"testprocess","argv":[]},"system":{"architecture":"testarch","hostname":"testhost","platform":"testplatform"},"agent":{"name":"OCaml","version":"n/a"},"language":{"name":"OCaml","version":"4.13.1"},"runtime":{"name":"OCaml","version":"4.13.1"},"service":{"name":"testservice","agent":{"name":"OCaml","version":"n/a"},"language":{"name":"OCaml","version":"4.13.1"},"runtime":{"name":"OCaml","version":"4.13.1"}}}}
    inline_test_runner_apm_agent_tests.exe: [INFO] {"transaction":{"timestamp":15768000000000000,"duration":80.0,"id":"3e466abbf8b38218","span_count":{"started":1},"trace_id":"5e00cc610bf958d233ad4932f4e954cc","type":"request","name":"testtransaction"}} |}];
  (* No metadata on following log output *)
  Elastic_apm_logs_reporter.Reporter.push reporter (Transaction transaction);
  [%expect
    {| inline_test_runner_apm_agent_tests.exe: [INFO] {"transaction":{"timestamp":15768000000000000,"duration":80.0,"id":"3e466abbf8b38218","span_count":{"started":1},"trace_id":"5e00cc610bf958d233ad4932f4e954cc","type":"request","name":"testtransaction"}} |}];
  (* Disable log output or set level too high - no output *)
  Logs.Src.set_level (Elastic_apm_logs_reporter.Reporter.src reporter) None;
  Elastic_apm_logs_reporter.Reporter.push reporter (Transaction transaction);
  [%expect {||}];
  Logs.Src.set_level
    (Elastic_apm_logs_reporter.Reporter.src reporter)
    (Some Warning);
  Elastic_apm_logs_reporter.Reporter.push reporter (Transaction transaction);
  [%expect {||}];
  (* Set level low enough - output *)
  Logs.Src.set_level
    (Elastic_apm_logs_reporter.Reporter.src reporter)
    (Some Debug);
  Elastic_apm_logs_reporter.Reporter.push reporter (Transaction transaction);
  [%expect
    {| inline_test_runner_apm_agent_tests.exe: [INFO] {"transaction":{"timestamp":15768000000000000,"duration":80.0,"id":"3e466abbf8b38218","span_count":{"started":1},"trace_id":"5e00cc610bf958d233ad4932f4e954cc","type":"request","name":"testtransaction"}} |}]
;;
