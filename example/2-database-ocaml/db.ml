open Opium

let create_db_pool size =
  Lwt_pool.create size
    ~validate:(fun conn -> Pgx_lwt_unix.alive conn)
    ~dispose:(fun conn -> Pgx_lwt_unix.close conn)
    (fun () ->
      Pgx_lwt_unix.connect ~host:"test-postgres" ~user:"ocaml_demo"
        ~password:"ocaml_demo" ~database:"ocaml_demo" ()
    )
;;

let key =
  Context.Key.create
    ( "database_pool",
      fun (_ : Pgx_lwt_unix.t Lwt_pool.t) -> Sexplib0.Sexp.Atom "<opaque>"
    )
;;

let m size =
  let filter handler ({ Request.env; _ } as req) =
    let env = Context.add key (create_db_pool size) env in
    let req = { req with env } in
    handler req
  in
  Rock.Middleware.create ~filter ~name:"Setup Database Pool"
;;

let with_conn { Request.env; _ } ~f =
  let pool = Context.find_exn key env in
  Lwt_pool.use pool (fun conn -> f conn)
;;
