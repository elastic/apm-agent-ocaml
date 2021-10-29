module Platform = struct
  type t = { architecture : string; hostname : string; platform : string }

  let default =
    lazy
      (match
         ( Elastic_apm_generated_sysinfo.architecture,
           Elastic_apm_generated_sysinfo.platform )
       with
      | Some architecture, Some platform ->
          { architecture; platform; hostname = Unix.gethostname () }
      | _ -> invalid_arg "Failed to determine host platform's architecture")
end
