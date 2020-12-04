let make_uuid =
  let gen = Uuidm.v4_gen (Random.get_state ()) in
  (* NOTE: Yes, the `fun () -> gen ()` is redundant. It also makes the intent
     clear to readers. *)
  fun () -> gen ()

let make () =
  make_uuid ()
  |> Uuidm.to_string
  |> String.split_on_char '-'
  |> String.concat ""
