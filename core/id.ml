let default_rand = Random.State.make_self_init ()

let alphabet = "0123456789abcdef"

let hex_encode s =
  let b = Bytes.create (String.length s * 2) in
  let rec loop b_idx s_idx =
    if s_idx < String.length s then (
      let ch = Char.code (String.unsafe_get s s_idx) in
      Bytes.unsafe_set b b_idx (String.unsafe_get alphabet ((ch lsr 4) land 15));
      Bytes.unsafe_set b (b_idx + 1) (String.unsafe_get alphabet (ch land 15));
      loop (b_idx + 2) (s_idx + 1))
  in
  loop 0 0;
  Bytes.unsafe_to_string b

let fill_64_bits state buf ~pos =
  assert (Bytes.length buf - pos >= 8);
  let a = Random.State.bits state in
  let b = Random.State.bits state in
  let c = Random.State.bits state in
  Bytes.unsafe_set buf pos (Char.chr (a land 0xFF));
  Bytes.unsafe_set buf (pos + 1) (Char.chr ((a lsr 8) land 0xFF));
  Bytes.unsafe_set buf (pos + 2) (Char.chr ((a lsr 16) land 0xFF));
  Bytes.unsafe_set buf (pos + 3) (Char.chr (b land 0xFF));
  Bytes.unsafe_set buf (pos + 4) (Char.chr ((b lsr 8) land 0xFF));
  Bytes.unsafe_set buf (pos + 5) (Char.chr ((b lsr 16) land 0xFF));
  Bytes.unsafe_set buf (pos + 6) (Char.chr (c land 0xFF));
  Bytes.unsafe_set buf (pos + 7) (Char.chr ((c lsr 8) land 0xFF))

let fill_128_bits state buf ~pos =
  fill_64_bits state buf ~pos;
  fill_64_bits state buf ~pos:(pos + 8)

let make_id_module byte_count fill_buffer =
  let module M = struct
    type t = string

    let create_gen state =
      let b = Bytes.create byte_count in
      fill_buffer state b ~pos:0;
      Bytes.unsafe_to_string b

    let create () = create_gen default_rand

    let to_string t = t

    let to_hex t = hex_encode t
  end in
  (module M : Id_intf.S)

module Span_id = (val make_id_module 8 fill_64_bits)

module Trace_id = (val make_id_module 16 fill_128_bits)
