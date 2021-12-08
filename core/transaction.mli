module Span_count : sig
  type t = {
    dropped : int option;
    started : int;
  }
  [@@deriving yojson_of]

  val make : ?dropped:int -> int -> t

  val add_started : t -> int -> t

  val add_dropped : t -> int -> t
end

type context = {
  request : Context.Http.Request.t option; [@yojson.option]
  response : Context.Http.Response.t option; [@yojson.option]
}
[@@deriving yojson_of]

type t = {
  timestamp : Timestamp.t;
  duration : Duration.t;
  id : Id.Span_id.t;
  span_count : Span_count.t;
  trace_id : Id.Trace_id.t;
  parent_id : Id.Span_id.t option;
  type_ : string;
  name : string;
  context : context;
}
[@@deriving yojson_of]

val make :
  ?parent_id:Id.Span_id.t ->
  ?request:Context.Http.Request.t ->
  ?response:Context.Http.Response.t ->
  timestamp:Timestamp.t ->
  duration:Duration.t ->
  id:Id.Span_id.t ->
  span_count:Span_count.t ->
  trace_id:Id.Trace_id.t ->
  kind:string ->
  string ->
  t
