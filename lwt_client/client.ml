open Elastic_apm_core
open Elastic_apm_lwt_reporter

module Global_state = struct
  let reporter : Reporter.t option ref = ref None

  let random_state : Random.State.t ref = ref (Random.State.make_self_init ())

  let push request =
    Option.iter (fun rep -> Reporter.push rep request) !reporter
  ;;
end

let set_reporter reporter = Global_state.reporter := reporter

type context = {
  start : Mtime.t;
  id : Id.Span_id.t;
  transaction_id : Id.Span_id.t;
  parent_id : Id.Span_id.t;
  trace_id : Id.Trace_id.t;
  kind : string;
  name : string;
  mutable span_count : Transaction.Span_count.t;
}

let trace_id ctx = ctx.trace_id

let make_context ?context ~kind name =
  let start = Mtime_clock.now () in
  let id = Id.Span_id.create_gen !Global_state.random_state in
  let parent_id =
    match context with
    | None -> id
    | Some ctx -> ctx.id
  in
  let trace_id =
    match context with
    | None -> Id.Trace_id.create_gen !Global_state.random_state
    | Some ctx -> ctx.trace_id
  in
  let transaction_id =
    match context with
    | None -> id
    | Some ctx -> ctx.transaction_id
  in
  {
    start;
    id;
    transaction_id;
    parent_id;
    trace_id;
    kind;
    name;
    span_count = Transaction.Span_count.make 0;
  }
;;

module Transaction = struct
  let init ?context ~kind name = make_context ?context ~kind name

  let close context =
    let finish = Mtime_clock.now () in
    let duration = Mtime.span context.start finish |> Duration.of_span in
    let parent_id =
      if Id.Span_id.equal context.id context.parent_id then
        None
      else
        Some context.parent_id
    in
    let transaction =
      Transaction.make ?parent_id ~duration ~id:context.id
        ~span_count:context.span_count ~trace_id:context.trace_id
        ~kind:context.kind context.name
    in
    Global_state.push (Transaction transaction)
  ;;
end

module Span = struct
  let init context ~kind name = make_context ~context ~kind name

  let close context =
    let finish = Mtime_clock.now () in
    let duration = Mtime.span context.start finish |> Duration.of_span in
    let timestamp = Timestamp.now () in
    let span =
      Span.make ~duration ~id:context.id ~kind:context.kind
        ~transaction_id:context.transaction_id ~parent_id:context.parent_id
        ~trace_id:context.trace_id ~timestamp context.name
    in
    Global_state.push (Span span)
  ;;
end

let report_exn f context =
  match%lwt f context with
  | result -> Lwt.return result
  | exception exn ->
    let backtrace = Printexc.get_raw_backtrace () in
    let err =
      Error.make ~random_state:!Global_state.random_state
        ~trace_id:context.trace_id ~backtrace ~exn
        ~timestamp:(Elastic_apm_core.Timestamp.now ())
        ~parent_id:context.id ~transaction_id:context.transaction_id ()
    in
    Global_state.push (Error err);
    raise exn
;;

let with_transaction ?context ~kind name f =
  let context = Transaction.init ?context ~kind name in
  (report_exn f context) [%lwt.finally Lwt.return (Transaction.close context)]
;;

let with_span context ~kind name f =
  let context = Span.init context ~kind name in
  context.span_count <-
    Elastic_apm_core.Transaction.Span_count.add_started context.span_count 1;
  (report_exn f context) [%lwt.finally Lwt.return (Span.close context)]
;;
