include Elastic_apm.Reporter_intf.S

val create : ?src:Logs.src -> Elastic_apm.Metadata.t -> t

val src : t -> Logs.src
