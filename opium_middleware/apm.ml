module Apm_context = struct
  let sexp_of_apm_context (_ : Elastic_apm_lwt_client.Client.context) :
      Sexplib0.Sexp.t =
    Atom "<opaque>"
  ;;

  let key = Rock.Context.Key.create ("elastic-apm-context", sexp_of_apm_context)

  let pp_request ppf (req : Rock.Request.t) =
    Fmt.pf ppf "%a %s" Httpaf.Method.pp_hum req.meth req.target
  ;;

  let find (req : Rock.Request.t) = Rock.Context.find key req.env

  let get req =
    match find req with
    | Some apm -> apm
    | None ->
      Fmt.invalid_arg "APM context is not available in request environment %a"
        pp_request req
  ;;
end

let m : Rock.Middleware.t =
  let filter handler (req : Rock.Request.t) =
    let meth = Opium.Method.to_string req.meth in
    let path = req.target |> Uri.of_string |> Uri.path in
    let name = Fmt.str "%s %s" meth path in
    Elastic_apm_lwt_client.Client.with_transaction ~kind:"http" name (fun apm ->
        let env = Rock.Context.add Apm_context.key apm req.env in
        let req = { req with env } in
        handler req
    )
  in
  Rock.Middleware.create ~filter ~name:"Elastic APM"
;;
