module type S = sig
  type context
  type 'a io

  val trace_id : context -> Id.Trace_id.t

  module Transaction : sig
    val init : ?context:context -> kind:string -> string -> context

    val close : context -> unit
  end

  module Span : sig
    val init : context -> kind:string -> string -> context

    val close : context -> unit
  end

  val with_transaction :
    ?context:context -> kind:string -> string -> (context -> 'a io) -> 'a io

  val with_span :
    context -> kind:string -> string -> (context -> 'a io) -> 'a io
end
