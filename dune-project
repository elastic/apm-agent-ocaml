(lang dune 2.9)

(name elastic-apm)

(license Apache-2.0)
(maintainers
 "Adam Ringwood <adam.ringwood@elastic.co>"
 "Hezekiah M. Carty <hezekiah.carty@elastic.co>")
(authors
 "Adam Ringwood <adam.ringwood@elastic.co>"
 "Hezekiah M. Carty <hezekiah.carty@elastic.co>")

(source (github elastic/apm-agent-ocaml))

(generate_opam_files true)

(package
 (name elastic-apm)
 (synopsis "Elastic Application Performance Monitoring (APM) client library")
 (depends
  (ocaml (>= 4.08.0))
  (cohttp-lwt-unix (>= 2.5.4))
  (dune (>= 2.9.1))
  (dune-build-info (>= 2.9.1))
  (ppx_deriving (>= 4.5))
  (ppx_deriving_yojson (>= 3.5.3))
  (ptime (>= 0.8.5))
  (uri (>= 3.0.0))
  (uuidm (>= 0.9.7))
  (yojson (>= 1.6.0))))
