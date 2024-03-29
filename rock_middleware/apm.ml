module Init = struct
  let setup_reporter ?host ?version ?environment ?node service_name =
    let open Elastic_apm in
    let service =
      let framework_version =
        match Build_info.V1.Statically_linked_libraries.find ~name:"rock" with
        | None -> None
        | Some library ->
          Option.map Build_info.V1.Version.to_string
            (Build_info.V1.Statically_linked_library.version library)
      in
      Metadata.Service.make ?version ?environment ?node
        ~framework:(Metadata.Framework.make ?version:framework_version "Rock")
        service_name
    in
    let module Reporter = Elastic_apm_lwt_reporter.Reporter in
    let host =
      match host with
      | None -> Reporter.Host.of_env ()
      | Some _ as h -> h
    in
    match host with
    | None ->
      Logs.warn (fun m ->
          m
            "APM reporting disabled because %s and %s are not defined in the \
             environment"
            Reporter.Host.server_env_key Reporter.Host.token_env_key
      )
    | Some host ->
      let reporter =
        let metadata = Elastic_apm.Metadata.make service in
        Elastic_apm_lwt_reporter.Reporter.create host metadata
      in
      Elastic_apm_lwt_client.Client.set_reporter (Some reporter)
  ;;
end

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
    let meth = Httpaf.Method.to_string req.meth in
    let path = req.target |> Uri.of_string |> Uri.path in
    let name = Fmt.str "%s %s" meth path in
    let parent_id =
      match Httpaf.Headers.get req.headers "traceparent" with
      | None -> None
      | Some traceparent ->
        ( match String.split_on_char '-' traceparent with
        | [ _version; trace_id; parent_id; _flags ] ->
          let trace_id = Elastic_apm.Id.Trace_id.of_hex trace_id in
          let parent_id = Elastic_apm.Id.Span_id.of_hex parent_id in
          Some (trace_id, parent_id)
        | _ -> None
        )
    in
    let ctx =
      Option.map
        (fun (trace_id, parent_id) ->
          Elastic_apm_lwt_client.Client.make_context' ~trace_id ~parent_id
            ~kind:"http" name
        )
        parent_id
    in
    let request =
      Elastic_apm.Context.Http.Request.make
        ~headers:(Httpaf.Headers.to_list req.headers)
        ~http_version:(Httpaf.Version.to_string req.version)
        ~meth (Uri.of_string req.target)
    in
    Elastic_apm_lwt_client.Client.with_transaction ~request ?context:ctx
      ~kind:"http" name (fun apm ->
        let env = Rock.Context.add Apm_context.key apm req.env in
        let req = { req with env } in
        let%lwt rock_response = handler req in
        let response =
          Elastic_apm.Context.Http.Response.make
            ~headers:(Httpaf.Headers.to_list rock_response.Rock.Response.headers)
            (Httpaf.Status.to_code rock_response.status)
        in
        Elastic_apm_lwt_client.Client.set_response apm response;
        Lwt.return rock_response
    )
  in
  Rock.Middleware.create ~filter ~name:"Elastic APM"
;;
