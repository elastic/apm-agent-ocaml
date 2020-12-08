let log_src = Logs.Src.create "apm"
module Log = (val Logs_lwt.src_log (Logs.Src.create "apm"))

(* Default to no APM-specific logging *)
let () = Logs.Src.set_level log_src None

module Sender = struct
  type t = {
    max_message_batch_size : int;
    context : Context.t;
    send : Context.t -> Message.t list -> unit Lwt.t;
  }

  let global_sender : t option ref = ref None

  let send context messages =
    let ( let* ) = Lwt.bind in
    let* (response, body) = Message.send context messages in
    match response.status with
    | #Cohttp.Code.success_status -> Lwt.return_unit
    | _ ->
      Log.warn (fun m ->
          m "APM server response %d: %s"
            (Cohttp.Code.code_of_status response.status)
            body)

  let sleep () = Lwt_unix.sleep 5.0
  let rec run_forever () =
    let ( let* ) = Lwt.bind in
    let* () =
      match !global_sender with
      | None -> sleep ()
      | Some { max_message_batch_size; context; send } ->
        ( match Message_queue.pop_n ~max:max_message_batch_size with
        | [] -> sleep ()
        | messages -> send context messages
        )
    in
    run_forever ()
end

let init ?(max_message_batch_size = 50) ?(send = Sender.send) context =
  Sender.global_sender := Some { max_message_batch_size; context; send };
  Lwt.async Sender.run_forever

let send messages =
  match !Sender.global_sender with
  | None -> ()
  | Some _c -> List.iter Message_queue.push messages

let with_transaction ?trace ~name ~type_ f =
  let (trace, now) = Transaction.make_transaction ?trace ~name ~type_ () in
  match f () with
  | x ->
    send [ Transaction (now ()) ];
    x
  | exception exn ->
    let st = Printexc.get_raw_backtrace () in
    send [ Transaction (now ()); Error (Error.make ~trace st exn) ];
    raise exn

let with_transaction_lwt ?trace ~name ~type_ f =
  let (trace, now) = Transaction.make_transaction ?trace ~name ~type_ () in
  let on_success x =
    send [ Transaction (now ()) ];
    Lwt.return x
  in
  let on_failure exn =
    let st = Printexc.get_raw_backtrace () in
    send [ Transaction (now ()); Error (Error.make ~trace st exn) ];
    Lwt.fail exn
  in
  Lwt.try_bind f on_success on_failure
