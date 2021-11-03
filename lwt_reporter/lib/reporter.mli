type t

val push : t -> Elastic_apm_core.Request.t -> unit

val create :
  ?max_messages_per_batch:int ->
  apm_server:Uri.t ->
  server_token:string ->
  Elastic_apm_core.Metadata.t ->
  t
