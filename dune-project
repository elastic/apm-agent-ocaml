(lang dune 2.5)

(name elastic-apm)

(license Apache-2.0)
(maintainers
 "Adam Ringwood <adam.ringwood@elastic.co>"
 "Hezekiah M. Carty <hezekiah.carty@elastic.co>")
(authors
 "Adam Ringwood <adam.ringwood@elastic.co>"
 "Hezekiah M. Carty <hezekiah.carty@elastic.co>")

(source (github elastic/ocaml-apm))

(generate_opam_files true)

(package
 (name elastic-apm)
 (synopsis "Elastic Application Performance Monitoring (APM) client library")
 (depends
  (ocaml (>= 4.08.0))
  (dune (>= 2.5.0))
  (ppx_deriving (>= 4.5))
  (ptime (>= 0.8.5))
  (uri (>= 3.0.0))
  (yojson (>= 1.6.0))))