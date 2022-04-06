include Elastic_apm.Reporter_intf.S

module Host : sig
  type t

  val server_env_key : string

  val token_env_key : string

  val of_env : unit -> t option

  val make : Uri.t -> token:string -> t
end

val create :
  ?client:Blue_http.Client.t ->
  ?max_messages_per_batch:int ->
  Host.t ->
  Elastic_apm.Metadata.t ->
  t
