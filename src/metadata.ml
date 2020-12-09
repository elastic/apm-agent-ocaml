type process = {
  pid : int;
  title : string;
  ppid : int;
  argv : string list;
}
[@@deriving to_yojson, make]

let current_process =
  let argv = Sys.argv |> Array.to_list in
  let title = Sys.executable_name in
  let pid = Unix.getpid () in
  let ppid = Unix.getppid () in
  make_process ~pid ~title ~ppid ~argv ()

type system = {
  architecture : string;
  detected_hostname : string;
  configured_hostname : string;
}
[@@deriving to_yojson, make]

let current_system =
  let architecture = Sys.os_type in
  let detected_hostname = Unix.gethostname () in
  let configured_hostname = Unix.gethostname () in
  make_system ~architecture ~detected_hostname ~configured_hostname

type agent = {
  name : string;
  version : string;
}
[@@deriving to_yojson, make]

let agent =
  let name = "OCaml" in
  let version = match Build_info.V1.version () with
    | None -> "n/a"
    | Some v -> Build_info.V1.Version.to_string v
  in
  make_agent ~name ~version

type runtime = {
  name : string;
  version : string;
}
[@@deriving to_yojson, make]

let current_runtime =
  let name = "OCaml" in
  let version = Sys.ocaml_version in
  make_runtime ~name ~version

type service = {
  name : string;
  runtime : runtime;
  agent : agent;
}
[@@deriving to_yojson, make]

let make_service name = make_service ~name ~runtime:current_runtime ~agent

type t = {
  process : process;
  system : system;
  service : service;
}
[@@deriving to_yojson, make]

let make ~name =
  let service = make_service name in
  make ~process:current_process ~system:current_system ~service
