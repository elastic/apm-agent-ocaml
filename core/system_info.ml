module Platform = struct
  type t = { architecture : string; hostname : string; platform : string }

  let detect () =
    let architecture =
      Option.value ~default:"Unknown" Elastic_apm_generated_sysinfo.architecture
    in
    let platform =
      Option.value ~default:"Unknown" Elastic_apm_generated_sysinfo.platform
    in
    let hostname = Unix.gethostname () in
    { architecture; hostname; platform }

  let default = lazy (detect ())
end
