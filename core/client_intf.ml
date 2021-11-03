module type S = sig
  type context
  type 'a io

  module Transaction : sig
    val init :
      ?parent_id:Id.Span_id.t ->
      trace_id:Id.Trace_id.t ->
      kind:string ->
      string ->
      context

    val close : context -> unit
  end

  module Span : sig
    val init :
      ?parent_id:Id.Span_id.t ->
      transaction_id:Id.Span_id.t ->
      trace_id:Id.Trace_id.t ->
      kind:string ->
      string ->
      context

    val close : context -> unit
  end

  val with_transaction :
    ?parent_id:Id.Span_id.t ->
    trace_id:Id.Trace_id.t ->
    kind:string ->
    string ->
    (context -> 'a io) ->
    'a io

  val with_span :
    ?parent_id:Id.Span_id.t ->
    transaction_id:Id.Span_id.t ->
    trace_id:Id.Trace_id.t ->
    kind:string ->
    string ->
    (context -> 'a io) ->
    'a io
end
