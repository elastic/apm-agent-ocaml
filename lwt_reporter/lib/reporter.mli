include Elastic_apm.Reporter_intf.S

val log_source : Logs.Src.t
(** The log source used for all logging within the lwt apm reporter. This can be
    used to control the logging level filter for this library. *)

module Host : sig
  type t

  val server_env_key : string

  val token_env_key : string

  val of_env : unit -> t option

  val make : Uri.t -> token:string -> t
end

val create :
  ?cohttp_ctx:Cohttp_lwt_unix.Client.ctx ->
  ?max_messages_per_batch:int ->
  Host.t ->
  Elastic_apm.Metadata.t ->
  t
