module Process = struct
  type t = {
    pid : int;
    title : string;
    parent_process_id : int option; [@key "ppid"] [@yojson.option]
    argv : string array;
  }
  [@@deriving yojson_of]

  let make ?parent_process_id ?(argv = [||]) pid title =
    { pid; title; parent_process_id; argv }
  ;;

  let default =
    lazy
      (let pid = Unix.getpid () in
       let parent_process_id =
         if Sys.win32 then
           None
         else
           Some (Unix.getppid ())
       in
       let argv = Sys.argv in
       make ?parent_process_id ~argv pid Sys.executable_name
      )
  ;;
end

module Container = struct
  type t = { id : string } [@@deriving yojson_of]

  let make id = { id }
end

module System = struct
  type t = {
    architecture : string;
    hostname : string;
    platform : string;
    container : Container.t option; [@yojson.option]
  }
  [@@deriving yojson_of]

  let make ?container ~platform ~hostname ~architecture () =
    { architecture; hostname; platform; container }
  ;;
end

module Agent = struct
  type t = {
    name : string;
    version : string;
  }
  [@@deriving yojson_of]

  let make ~name ~version = { name; version }
end

module Framework = struct
  type t = {
    name : string;
    version : string option; [@yojson.option]
  }
  [@@deriving yojson_of]

  let make ?version name = { name; version }
end

module Language = struct
  type t = {
    name : string;
    version : string;
  }
  [@@deriving yojson_of]

  let t = { name = "OCaml"; version = Sys.ocaml_version }
end

module Runtime = struct
  type t = {
    name : string;
    version : string;
  }
  [@@deriving yojson_of]

  let t = { name = "OCaml"; version = Sys.ocaml_version }
end

module Cloud = struct
  type id_with_name = {
    id : string;
    name : string;
  }
  [@@deriving yojson_of]

  type machine = { type_ : string [@key "type"] } [@@deriving yojson_of]

  type t = {
    provider : string;
    region : string option; [@yojson.option]
    availability_zone : string option; [@yojson.option]
    instance : id_with_name option; [@yojson.option]
    machine : machine option; [@yojson.option]
    account : id_with_name option; [@yojson.option]
    project : id_with_name option; [@yojson.option]
  }
  [@@deriving yojson_of]

  let make
      ?region
      ?availability_zone
      ?instance
      ?machine
      ?account
      ?project
      provider =
    {
      provider;
      region;
      availability_zone;
      instance;
      machine = Option.map (fun machine -> { type_ = machine }) machine;
      account;
      project;
    }
  ;;
end

module Service = struct
  type service_node = { configured_name : string } [@@deriving yojson_of]

  type t = {
    name : string;
    version : string option; [@yojson.option]
    environment : string option; [@yojson.option]
    agent : Agent.t option; [@yojson.option]
    framework : Framework.t option; [@yojson.option]
    language : Language.t option; [@yojson.option]
    runtime : Runtime.t option; [@yojson.option]
    node : service_node option; [@yojson.option]
  }
  [@@deriving yojson_of]

  let make ?version ?environment ?agent ?framework ?language ?runtime ?node name
      =
    {
      name;
      version;
      environment;
      agent;
      framework;
      language;
      runtime;
      node = Option.map (fun configured_name -> { configured_name }) node;
    }
  ;;
end

module User = struct
  type t = {
    username : string option; [@yojson.option]
    id : string option; [@yojson.option]
    email : string option; [@yojson.option]
  }
  [@@deriving yojson_of]

  let is_none { username; id; email } =
    match (username, id, email) with
    | (None, None, None) -> true
    | _ -> false
  ;;

  let yojson_of_t t =
    if is_none t then
      `Null
    else
      yojson_of_t t
  ;;

  let make ?username ?id ?email () = { username; id; email }
end

type t = {
  process : Process.t option;
  system : System.t option;
  agent : Agent.t option;
  framework : Framework.t option;
  language : Language.t option;
  runtime : Runtime.t option;
  cloud : Cloud.t option;
  service : Service.t;
  user : User.t option;
}
[@@deriving yojson_of]

let make
    ?(process = Lazy.force Process.default)
    ?system
    ?agent
    ?framework
    ?cloud
    ?user
    service =
  {
    process = Some process;
    system;
    agent;
    framework;
    language = Some Language.t;
    runtime = Some Runtime.t;
    cloud;
    service;
    user;
  }
;;
