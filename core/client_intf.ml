module type S = sig
  type context
  type 'a io

  val trace_id : context -> Id.Trace_id.t

  val id : context -> Id.Span_id.t

  val parent_id : context -> Id.Span_id.t
  val set_response : context -> Context.Http.Response.t -> unit

  module Transaction : sig
    val init :
      ?request:Context.Http.Request.t ->
      ?context:context ->
      kind:string ->
      string ->
      context

    val close : context -> unit
  end

  module Span : sig
    val init : context -> kind:string -> string -> context

    val close : context -> unit
  end

  val with_transaction :
    ?context:context ->
    ?request:Context.Http.Request.t ->
    kind:string ->
    string ->
    (context -> 'a io) ->
    'a io

  val with_span :
    context -> kind:string -> string -> (context -> 'a io) -> 'a io
end
