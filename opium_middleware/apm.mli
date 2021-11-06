module Init : sig
  val setup_reporter :
    ?host:Elastic_apm_lwt_reporter.Reporter.Host.t ->
    ?version:string ->
    ?environment:string ->
    ?node:string ->
    string ->
    unit
end

module Apm_context : sig
  val find : Rock.Request.t -> Elastic_apm_lwt_client.Client.context option

  val get : Rock.Request.t -> Elastic_apm_lwt_client.Client.context
end

val m : Rock.Middleware.t
