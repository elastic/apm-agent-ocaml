module Process = struct
  type t = {
    pid : int;
    title : string;
    parent_process_id : (int option[@key "ppid"] [@yojson.option]);
    argv : string array;
  }
  [@@deriving yojson_of]

  let make ?parent_process_id ?(argv = [||]) pid title =
    { pid; title; parent_process_id; argv }

  let default =
    lazy
      (let pid = Unix.getpid () in
       let parent_process_id =
         if Sys.win32 then None else Some (Unix.getppid ())
       in
       let argv = Sys.argv in
       make ?parent_process_id ~argv pid Sys.executable_name)
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
    container : (Container.t option[@yojson.option]);
  }
  [@@deriving yojson_of]

  let make ?container ~platform ~hostname ~architecture () =
    { architecture; hostname; platform; container }
end

module Agent = struct
  type t = { name : string; version : string } [@@deriving yojson_of]

  let make ~name ~version = { name; version }
end

module Framework = struct
  type t = { name : string; version : (string option[@yojson.option]) }
  [@@deriving yojson_of]

  let make ?version name = { name; version }
end

module Language = struct
  type t = { name : string; version : string } [@@deriving yojson_of]

  let t = { name = "OCaml"; version = Sys.ocaml_version }
end

module Runtime = struct
  type t = { name : string; version : string } [@@deriving yojson_of]

  let t = { name = "OCaml"; version = Sys.ocaml_version }
end
