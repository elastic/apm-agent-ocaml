module Init : sig
  val setup_reporter :
    ?host:Elastic_apm_lwt_reporter.Reporter.Host.t ->
    Elastic_apm_core.Metadata.Service.t ->
    unit
end

module Apm_context : sig
  val find : Rock.Request.t -> Elastic_apm_lwt_client.Client.context option

  val get : Rock.Request.t -> Elastic_apm_lwt_client.Client.context
end

val m : Rock.Middleware.t
