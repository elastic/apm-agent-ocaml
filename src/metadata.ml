type process = {
  pid : int;
  title : string;
  ppid : int;
  argv : string list;
} [@@deriving yojson]

let make_process () =
  let argv = Sys.argv |> Array.to_list in
  let title = Sys.executable_name in
  let pid = Unix.getpid () in
  let ppid = Unix.getppid () in
  { argv; title; pid; ppid; }

type system = {
  architecture : string;
  detected_hostname : string;
  configured_hostname : string;
} [@@deriving yojson]

let make_system () =
  let detected_hostname = Unix.gethostname () in
  let configured_hostname = Unix.gethostname () in
  let architecture = Sys.os_type in
  { detected_hostname; configured_hostname; architecture }

type agent = {
  name : string;
  version : string;
} [@@deriving yojson]

let agent =
  let name = "OCaml" in
  let version = "0.0.1" in
  { name; version }

type runtime = {
  name : string;
  version : string;
} [@@deriving yojson]

let make_runtime () =
  let name = "OCaml" in
  let version = Sys.ocaml_version in
  { name; version; }

type service = {
  name : string;
  runtime : runtime;
  agent : agent;
} [@@deriving yojson]

let make_service name =
  let runtime = make_runtime () in
  { name; runtime; agent }

type t = {
  process : process;
  system : system;
  service : service;
} [@@deriving yojson]

let make_metadata ~name =
  let process = make_process () in
  let system = make_system () in
  let service = make_service name in
  { process; system; service; }
