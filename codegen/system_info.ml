module C = Configurator.V1

let optional_var name var =
  let var =
    match var with None -> "None" | Some var -> Printf.sprintf "Some %S" var
  in
  Printf.sprintf "let %s = %s" name var

let () =
  let configurator = C.create "elastic-apm" in
  let arch = C.ocaml_config_var configurator "architecture" in
  let system = C.ocaml_config_var configurator "system" in
  print_endline (optional_var "architecture" arch);
  print_endline (optional_var "platform" system)
