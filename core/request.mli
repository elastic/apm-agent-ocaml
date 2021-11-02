type t = {
  metadata : Metadata.t;
  transaction : Transaction.t;
  spans : Span.t list;
}

val make : Metadata.t -> Transaction.t -> Span.t list -> t

val serialize : t -> string
