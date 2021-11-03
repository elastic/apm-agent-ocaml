include Elastic_apm_core.Reporter_intf.S

val create :
  ?max_messages_per_batch:int ->
  apm_server:Uri.t ->
  server_token:string ->
  Elastic_apm_core.Metadata.t ->
  t
