module Metric_transaction = struct
  type t = {
    type_ : string; [@key "type"]
    name : string;
  }
  [@@deriving yojson_of]

  let make ~name ~type_ = { name; type_ }
end

module Metric_span = struct
  type t = {
    type_ : string; [@key "type"]
    subtype : string;
  }
  [@@deriving yojson_of]

  let make ~type_ ~subtype = { type_; subtype }
end

module Metric = struct
  type json = {
    type_ : string; [@key "type"]
    unit_ : string option; [@key "unit"] [@yojson.option]
    value : float option; [@yojson.option]
    values : float list option; [@yojson.option]
    counts : int64 list option; [@yojson.option]
  }
  [@@deriving yojson_of]

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

  let yojson_of_t t =
    let payload =
      match t with
      | Guage { value; unit_ } ->
        {
          type_ = "guage";
          unit_;
          value = Some value;
          values = None;
          counts = None;
        }
      | Counter { value; unit_ } ->
        {
          type_ = "counter";
          unit_;
          value = Some value;
          values = None;
          counts = None;
        }
      | Histogram { counts; values } ->
        {
          type_ = "histogram";
          unit_ = None;
          value = None;
          values = Some values;
          counts = Some counts;
        }
    in
    yojson_of_json payload
  ;;
end

module StringMap = Map.Make (String)

type labels = string StringMap.t

let yojson_of_labels labels =
  `Assoc
    (labels
    |> StringMap.to_seq
    |> Seq.map (fun (k, v) -> (k, `String v))
    |> List.of_seq
    )
;;

type samples = Metric.t StringMap.t

let yojson_of_samples samples =
  `Assoc
    (samples
    |> StringMap.to_seq
    |> Seq.map (fun (k, v) -> (k, Metric.yojson_of_t v))
    |> List.of_seq
    )
;;

type t = {
  timestamp : Timestamp.t;
  labels : labels;
  samples : samples;
  span : Metric_span.t option; [@yojson.option]
  transaction : Metric_transaction.t option; [@yojson.option]
}
[@@deriving yojson_of]

let create
    ?(timestamp = Timestamp.now ())
    ?(labels = [])
    ?metric_span
    ?metric_transaction
    ~samples
    () =
  match samples with
  | [] -> invalid_arg "Can't create metrics without any samples"
  | samples ->
    {
      timestamp;
      span = metric_span;
      transaction = metric_transaction;
      samples = StringMap.of_seq (List.to_seq samples);
      labels = StringMap.of_seq (List.to_seq labels);
    }
;;
