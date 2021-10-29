(lang dune 2.9)

(name elastic-apm)

(license Apache-2.0)

(maintainers
 "Adam Ringwood <adam.ringwood@elastic.co>"
 "Hezekiah M. Carty <hezekiah.carty@elastic.co>")

(authors
 "Adam Ringwood <adam.ringwood@elastic.co>"
 "Hezekiah M. Carty <hezekiah.carty@elastic.co>")

(source
 (github elastic/apm-agent-ocaml))

(generate_opam_files true)

(package
 (name elastic-apm)
 (synopsis "Elastic Application Performance Monitoring (APM) client library")
 (depends
  (ocaml
   (>= 4.08.0))
  (dune-build-info
   (>= 2.9.1))
  (ptime
   (>= 0.8.5))))
