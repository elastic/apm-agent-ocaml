## Elastic OCaml APM

Note: This software is in extremely early stages, to the point that it doesn't support the full api and may still contain significant bugs. It has not undergone usage in our productive environments and you probably shouldn't use it in production without extensive testing. To borrow a phrase from my colleague, if it breaks, you get to keep both halves.

Given this, you can find the current version under `early-wip` to reflect that nature.

This library is an attempt to allow for detailed level apm tracking of modern OCaml applications. Currently it supports error trapping and sending it in the context of a trace/transaction and sending detailed information about a transaction. It does not yet support metrics or (http/db) spans although we have plans to support both in the coming releases.

Currently if you use this with the current version of Elastic APM, it should support most of the basic apm dashboards with exception of the service map. Notably the waterfall request graph does work if you manually propagate the trace header between the services. If you don't need distributed tracing, you can make a seperate trace id for each request when it's being process. 

## How does it work?

### Initialization

```ocaml
let init () =
  let service_name = "service_helloworld" in
  (* url/secret token are strings you get from kibana. *)
  let context = Elastic_apm.Context.make ~secret_token ~service_name ~url () in
  (* you don't have to enable backtraces but it's very useful in my opinion. 
  Even more so on projects without lwt.*)
  let () = (Printexc.record_backtrace true) in 
  Elastic_apm.Apm.init context;
```

### Transactions & Error Handling

```ocaml
let trace_with_work () =
  let name = "/route_a/method_1" in
  let trace = Elastic_apm.Trace.of_headers original_headers in
  let new_trace, now = Elastic_apm.Transaction.make_transaction ~trace ~name () in
  let results = do_work () in
  Elastic_apm.Apm.send [ Transaction (now ()); ];
```