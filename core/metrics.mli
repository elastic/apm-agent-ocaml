module Metric_transaction : sig
  type t [@@deriving yojson_of]

  val make : name:string -> type_:string -> t
end

module Metric_span : sig
  type t [@@deriving yojson_of]

  val make : type_:string -> subtype:string -> t
end

module Metric : sig
  type t =
    | Histogram of {
        counts : int64 list;
        values : float list;
      }
    | Guage of {
        value : float;
        unit_ : string option;
      }
    | Counter of {
        value : float;
        unit_ : string option;
      }
  [@@deriving yojson_of]
end

type t [@@deriving yojson_of]

val create :
  ?timestamp:Timestamp.t ->
  ?labels:(string * string) list ->
  ?metric_span:Metric_span.t ->
  ?metric_transaction:Metric_transaction.t ->
  samples:(string * Metric.t) list ->
  unit ->
  t
