module Apm_context : sig
  val find : Rock.Request.t -> Elastic_apm_lwt_client.Client.context option

  val get : Rock.Request.t -> Elastic_apm_lwt_client.Client.context
end

val m : Rock.Middleware.t
