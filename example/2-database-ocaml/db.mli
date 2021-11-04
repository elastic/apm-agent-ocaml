val m : int -> Rock.Middleware.t

val with_conn : Opium.Request.t -> f:(Pgx_lwt_unix.t -> 'a Lwt.t) -> 'a Lwt.t
