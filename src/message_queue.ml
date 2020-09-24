let q : Message.t Queue.t = Queue.create ()
let max_length = ref 1000

let rec make_room () =
  let length = Queue.length q in
  if length > 0 && length >= !max_length then (
    let _discarded = Queue.take q in
    make_room ()
  )

let push message =
  make_room ();
  Queue.push message q

let pop_n ~max =
  let rec aux messages n =
    if n <= 0 then
      List.rev messages
    else (
      match Queue.take_opt q with
      | None -> List.rev messages
      | Some m -> aux (m :: messages) (pred n)
    )
  in
  aux [] max
