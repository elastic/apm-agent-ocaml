type t = {
  metadata : Metadata.t;
  transaction : Transaction.t;
  spans : Span.t list;
}

let make metadata transaction spans = { metadata; transaction; spans }

let pp_json ppf json = Yojson.Safe.pretty_print ppf json

let serialize request =
  let meta_json =
    `Assoc [ ("metadata", Metadata.yojson_of_t request.metadata) ]
  in
  let transaction_json =
    `Assoc [ ("transaction", Transaction.yojson_of_t request.transaction) ]
  in
  let span_json span = `Assoc [ ("span", Span.yojson_of_t span) ] in
  let buf = Buffer.create 1_024 in
  let ppf = Format.formatter_of_buffer buf in
  Format.fprintf ppf "%a" pp_json meta_json;
  Format.pp_print_newline ppf ();
  Format.fprintf ppf "%a" pp_json transaction_json;
  List.iter
    (fun span ->
      Format.pp_print_newline ppf ();
      Format.fprintf ppf "%a" pp_json (span_json span)
    )
    request.spans;
  Format.pp_print_flush ppf ();
  Buffer.contents buf
;;
