include Elastic_apm_core.Client_intf.S with type 'a io := 'a Lwt.t

val set_reporter : Elastic_apm_lwt_reporter.Reporter.t option -> unit
