include Elastic_apm_core.Reporter_intf.S

val create : ?src:Logs.src -> Elastic_apm_core.Metadata.t -> t

val src : t -> Logs.src
