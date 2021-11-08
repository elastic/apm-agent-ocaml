include Elastic_apm.Client_intf.S with type 'a io := 'a Lwt.t

val set_reporter : Elastic_apm_lwt_reporter.Reporter.t option -> unit

val make_context' :
  ?trace_id:Elastic_apm.Id.Trace_id.t ->
  ?parent_id:Elastic_apm.Id.Span_id.t ->
  kind:string ->
  string ->
  context

val init_reporter :
  Elastic_apm_lwt_reporter.Reporter.Host.t ->
  Elastic_apm.Metadata.Service.t ->
  unit
