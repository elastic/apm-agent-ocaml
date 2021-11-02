module Platform = struct
  type t = {
    architecture : string;
    hostname : string;
    platform : string;
  }
  [@@deriving yojson_of]

  let detect () =
    let architecture =
      Option.value ~default:"Unknown" Elastic_apm_generated_sysinfo.architecture
    in
    let platform =
      Option.value ~default:"Unknown" Elastic_apm_generated_sysinfo.platform
    in
    let hostname = Unix.gethostname () in
    { architecture; hostname; platform }
  ;;

  let default = Lazy.from_fun detect
end
