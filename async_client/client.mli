include Elastic_apm.Client_intf.S with type 'a io := 'a Async.Deferred.t

val set_reporter : Elastic_apm_async_reporter.Reporter.t option -> unit

val make_context' :
  ?trace_id:Elastic_apm.Id.Trace_id.t ->
  ?parent_id:Elastic_apm.Id.Span_id.t ->
  ?request:Elastic_apm.Context.Http.Request.t ->
  kind:string ->
  string ->
  context

val make_context :
  ?context:context ->
  ?request:Elastic_apm.Context.Http.Request.t ->
  kind:string ->
  string ->
  context

val init_reporter :
  Elastic_apm_async_reporter.Reporter.Host.t ->
  Elastic_apm.Metadata.Service.t ->
  unit
