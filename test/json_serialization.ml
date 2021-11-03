open Elastic_apm_core

exception Dummy_exn of string

let boom () = raise (Dummy_exn "Hello")

let foo () = boom ()

let test_error () = foo ()

let state = Random.State.make [| 1; 2; 3; 4; 5 |]

let print_json json =
  let pp ppf json = Yojson.Safe.pretty_print ppf json in
  Format.fprintf Format.std_formatter "%a@." pp json
;;

let%expect_test "duration" =
  print_json (Duration.of_span Mtime.Span.one |> Duration.yojson_of_t);
  [%expect {| 1e-06 |}]
;;

let%expect_test "span id" =
  print_json (Id.Span_id.create_gen state |> Id.Span_id.yojson_of_t);
  [%expect {| "5e00cc610bf958d2" |}]
;;

let%expect_test "trace id" =
  print_json (Id.Trace_id.create_gen state |> Id.Trace_id.yojson_of_t);
  [%expect {| "33ad4932f4e954cc3e466abbf8b38218" |}]
;;

let process =
  Metadata.Process.make ~parent_process_id:1 ~argv:[| "hello"; "world" |] 2
    "process.exe"
;;

let%expect_test "metadata - process" =
  let _default : Metadata.Process.t = Lazy.force Metadata.Process.default in
  print_json (Metadata.Process.yojson_of_t process);
  [%expect
    {|
    { "pid": 2, "title": "process.exe", "ppid": 1, "argv": [ "hello", "world" ] } |}];
  let process =
    Metadata.Process.make ~argv:[| "hello"; "world" |] 2 "process.exe"
  in
  print_json (Metadata.Process.yojson_of_t process);
  [%expect
    {|
    { "pid": 2, "title": "process.exe", "argv": [ "hello", "world" ] } |}]
;;

let container = Metadata.Container.make "hiimacontainer"

let%expect_test "metadata - container" =
  print_json (Metadata.Container.yojson_of_t container);
  [%expect {| { "id": "hiimacontainer" } |}]
;;

let system =
  let system_info =
    System_info.Platform.make ~platform:"testplatform" ~hostname:"testhost"
      ~architecture:"256bit"
  in
  Metadata.System.make ~container ~system_info ()
;;

let%expect_test "metadata - system" =
  print_json (Metadata.System.yojson_of_t system);
  [%expect
    {|
    {
      "architecture": "256bit",
      "hostname": "testhost",
      "platform": "testplatform",
      "container": { "id": "hiimacontainer" }
    } |}];
  let system_info =
    System_info.Platform.make ~platform:"testplatform" ~hostname:"testhost"
      ~architecture:"256bit"
  in
  let system = Metadata.System.make ~system_info () in
  print_json (Metadata.System.yojson_of_t system);
  [%expect
    {|
    {
      "architecture": "256bit",
      "hostname": "testhost",
      "platform": "testplatform"
    } |}]
;;

let agent = Metadata.Agent.make ~name:"secret agent" ~version:"vNext"

let%expect_test "metadata - agent" =
  print_json (Metadata.Agent.yojson_of_t agent);
  [%expect {| { "name": "secret agent", "version": "vNext" } |}]
;;

let framework = Metadata.Framework.make ~version:"beta" "frame"

let%expect_test "metadata - framework" =
  print_json (Metadata.Framework.yojson_of_t framework);
  [%expect {| { "name": "frame", "version": "beta" } |}];
  let framework = Metadata.Framework.make "frame" in
  print_json (Metadata.Framework.yojson_of_t framework);
  [%expect {| { "name": "frame" } |}]
;;

let language = Metadata.Language.t

let%expect_test "metadata - language" =
  print_json (Metadata.Language.yojson_of_t language);
  [%expect {| { "name": "OCaml", "version": "4.13.1" } |}]
;;

let runtime = Metadata.Runtime.t

let%expect_test "metadata - runtime" =
  print_json (Metadata.Runtime.yojson_of_t runtime);
  [%expect {| { "name": "OCaml", "version": "4.13.1" } |}]
;;

let cloud =
  let id : Metadata.Cloud.id_with_name = { id = "012"; name = "abc" } in
  Metadata.Cloud.make ~region:"reg" ~availability_zone:"az" ~instance:id
    ~machine:"fast" ~account:id ~project:id "name"
;;

let%expect_test "metadata - cloud" =
  print_json (Metadata.Cloud.yojson_of_t cloud);
  [%expect
    {|
    {
      "provider": "name",
      "region": "reg",
      "availability_zone": "az",
      "instance": { "id": "012", "name": "abc" },
      "machine": { "type": "fast" },
      "account": { "id": "012", "name": "abc" },
      "project": { "id": "012", "name": "abc" }
    } |}];
  let cloud = Metadata.Cloud.make "name" in
  print_json (Metadata.Cloud.yojson_of_t cloud);
  [%expect {|
      { "provider": "name" } |}]
;;

let%expect_test "metadata - service" =
  let service =
    Metadata.Service.make ~version:"v1" ~environment:"env" ~agent ~framework
      ~language ~runtime ~node:"central" "universal"
  in
  print_json (Metadata.Service.yojson_of_t service);
  [%expect
    {|
    {
      "name": "universal",
      "version": "v1",
      "environment": "env",
      "agent": { "name": "secret agent", "version": "vNext" },
      "framework": { "name": "frame", "version": "beta" },
      "language": { "name": "OCaml", "version": "4.13.1" },
      "runtime": { "name": "OCaml", "version": "4.13.1" },
      "node": { "configured_name": "central" }
    } |}];
  let service = Metadata.Service.make "universal" in
  print_json (Metadata.Service.yojson_of_t service);
  [%expect {| { "name": "universal" } |}]
;;

let user =
  Metadata.User.make ~username:"admin" ~id:"000" ~email:"example@example.com" ()
;;

let%expect_test "metadata - user" =
  print_json (Metadata.User.yojson_of_t user);
  [%expect
    {| { "username": "admin", "id": "000", "email": "example@example.com" } |}];
  (* An empty user is technically allowed and also not very useful *)
  let user = Metadata.User.make () in
  print_json (Metadata.User.yojson_of_t user);
  [%expect {| null |}]
;;

let metadata =
  Metadata.make ~process ~system ~agent ~framework ~cloud ~user
    (Metadata.Service.make "testservice")
;;

let%expect_test "metadata" =
  print_json (Metadata.yojson_of_t metadata);
  [%expect
    {|
    {
      "process": {
        "pid": 2,
        "title": "process.exe",
        "ppid": 1,
        "argv": [ "hello", "world" ]
      },
      "system": {
        "architecture": "256bit",
        "hostname": "testhost",
        "platform": "testplatform",
        "container": { "id": "hiimacontainer" }
      },
      "agent": { "name": "secret agent", "version": "vNext" },
      "framework": { "name": "frame", "version": "beta" },
      "language": { "name": "OCaml", "version": "4.13.1" },
      "runtime": { "name": "OCaml", "version": "4.13.1" },
      "cloud": {
        "provider": "name",
        "region": "reg",
        "availability_zone": "az",
        "instance": { "id": "012", "name": "abc" },
        "machine": { "type": "fast" },
        "account": { "id": "012", "name": "abc" },
        "project": { "id": "012", "name": "abc" }
      },
      "service": { "name": "testservice" },
      "user": {
        "username": "admin",
        "id": "000",
        "email": "example@example.com"
      }
    } |}]
;;

let span =
  Span.make
    ~duration:(Duration.of_span Mtime.Span.one)
    ~id:(Id.Span_id.create_gen state)
    ~kind:"test"
    ~transaction_id:(Id.Span_id.create_gen state)
    ~parent_id:(Id.Span_id.create_gen state)
    ~trace_id:(Id.Trace_id.create_gen state)
    ~timestamp:(Timestamp.of_us_since_epoch 123)
    "testspan"
;;

let%expect_test "span" =
  print_json (Span.yojson_of_t span);
  [%expect
    {|
    {
      "duration": 1e-06,
      "id": "e5bef682a829d9c1",
      "name": "testspan",
      "transaction_id": "b03d453ece40e404",
      "parent_id": "1769c499c60d46a0",
      "trace_id": "20ba51f22b32eb39321acd340ce87f80",
      "type": "test",
      "timestamp": 123
    } |}]
;;

let%expect_test "system info - platform" =
  let platform : System_info.Platform.t =
    { architecture = "fast"; hostname = "localhost"; platform = "awesome" }
  in
  print_json (System_info.Platform.yojson_of_t platform);
  [%expect
    {| { "architecture": "fast", "hostname": "localhost", "platform": "awesome" } |}]
;;

let%expect_test "timestamp" =
  let timestamp = Timestamp.of_us_since_epoch 1234567890 in
  print_json (Timestamp.yojson_of_t timestamp);
  [%expect {| 1234567890 |}]
;;

let transaction =
  Transaction.make
    ~duration:(Duration.of_span Mtime.Span.one)
    ~id:(Id.Span_id.create_gen state)
    ~span_count:(Transaction.Span_count.make 12)
    ~trace_id:(Id.Trace_id.create_gen state)
    ~kind:"request" "test"
;;

let%expect_test "transaction" =
  print_json (Transaction.yojson_of_t transaction);
  [%expect
    {|
    {
      "duration": 1e-06,
      "id": "a8d16b0a1559dc02",
      "span_count": { "started": 12 },
      "trace_id": "b77ebdf068cb10014b841a2a47df3011",
      "type": "request",
      "name": "test"
    } |}];
  let transaction =
    Transaction.make
      ~duration:(Duration.of_span Mtime.Span.one)
      ~id:(Id.Span_id.create_gen state)
      ~span_count:(Transaction.Span_count.make ~dropped:5 12)
      ~trace_id:(Id.Trace_id.create_gen state)
      ~kind:"request" "test"
  in
  print_json (Transaction.yojson_of_t transaction);
  [%expect
    {|
      {
        "duration": 1e-06,
        "id": "4e3d3c0df5a1f610",
        "span_count": { "dropped": 5, "started": 12 },
        "trace_id": "11d0fb00078f8c303deab2a1651e57fc",
        "type": "request",
        "name": "test"
      } |}]
;;

let%expect_test "serialize request payloads" =
  print_json (Request.yojson_of_t (Request.Span span));
  [%expect
    {|
    {
      "span": {
        "duration": 1e-06,
        "id": "e5bef682a829d9c1",
        "name": "testspan",
        "transaction_id": "b03d453ece40e404",
        "parent_id": "1769c499c60d46a0",
        "trace_id": "20ba51f22b32eb39321acd340ce87f80",
        "type": "test",
        "timestamp": 123
      }
    } |}];
  print_json (Request.yojson_of_t (Request.Transaction transaction));
  [%expect
    {|
    {
      "transaction": {
        "duration": 1e-06,
        "id": "a8d16b0a1559dc02",
        "span_count": { "started": 12 },
        "trace_id": "b77ebdf068cb10014b841a2a47df3011",
        "type": "request",
        "name": "test"
      }
    } |}];
  print_json (Request.yojson_of_t (Request.Metadata metadata));
  [%expect
    {|
    {
      "metadata": {
        "process": {
          "pid": 2,
          "title": "process.exe",
          "ppid": 1,
          "argv": [ "hello", "world" ]
        },
        "system": {
          "architecture": "256bit",
          "hostname": "testhost",
          "platform": "testplatform",
          "container": { "id": "hiimacontainer" }
        },
        "agent": { "name": "secret agent", "version": "vNext" },
        "framework": { "name": "frame", "version": "beta" },
        "language": { "name": "OCaml", "version": "4.13.1" },
        "runtime": { "name": "OCaml", "version": "4.13.1" },
        "cloud": {
          "provider": "name",
          "region": "reg",
          "availability_zone": "az",
          "instance": { "id": "012", "name": "abc" },
          "machine": { "type": "fast" },
          "account": { "id": "012", "name": "abc" },
          "project": { "id": "012", "name": "abc" }
        },
        "service": { "name": "testservice" },
        "user": {
          "username": "admin",
          "id": "000",
          "email": "example@example.com"
        }
      }
    } |}];
  try test_error () with
  | exn ->
    let backtrace = Printexc.get_raw_backtrace () in
    let err =
      Error.make ~random_state:state ~backtrace ~exn
        ~timestamp:(Timestamp.of_us_since_epoch 123)
        ()
    in
    print_json (Request.yojson_of_t (Request.Error err));
    [%expect
      {|
    {
      "error": {
        "id": "a884f8dd451e53e894be98608fc09892",
        "timestamp": 123,
        "exception": {
          "message": "Apm_agent_tests.Json_serialization.Dummy_exn(\"Hello\")",
          "type": "exn",
          "stacktrace": [
            {
              "filename": "test/json_serialization.ml",
              "lineno": 5,
              "function": "Apm_agent_tests__Json_serialization.boom",
              "colno": 14
            },
            {
              "filename": "test/json_serialization.ml",
              "lineno": 7,
              "function": "Apm_agent_tests__Json_serialization.foo",
              "colno": 13
            },
            {
              "filename": "test/json_serialization.ml",
              "lineno": 9,
              "function": "Apm_agent_tests__Json_serialization.test_error",
              "colno": 20
            },
            {
              "filename": "test/json_serialization.ml",
              "lineno": 382,
              "function": "Apm_agent_tests__Json_serialization.(fun)",
              "colno": 6
            }
          ]
        }
      }
    } |}]
;;
