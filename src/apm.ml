let with_transaction ~name ~type_ f : Message.t list * ('a, exn) result =
  let now = Transaction.make_transaction ~name ~type_ in
  match f () with
  | x -> ([ Transaction (now ()) ], Ok x)
  | exception exn ->
    ([ Transaction (now ()); Error (Error.make exn) ], Error exn)
