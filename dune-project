(lang dune 2.9)

(name elastic-apm)

(license Apache-2.0)

(maintainers
 "Hezekiah M. Carty <hezekiah.carty@elastic.co>"
 "Pete Hampton <peter.hampton@elastic.co>"
 "Anurag Soni <anurag.soni@elastic.co>")

(authors
 "Adam Ringwood <adam.ringwood@elastic.co>"
 "Hezekiah M. Carty <hezekiah.carty@elastic.co>"
 "Pete Hampton <peter.hampton@elastic.co>"
 "Anurag Soni <anurag.soni@elastic.co>")

(source
 (github elastic/apm-agent-ocaml))

(generate_opam_files true)

(package
 (name elastic-apm)
 (synopsis "Elastic Application Performance Monitoring (APM) client library")
 (depends
  (ocaml
   (>= 4.12.0))
  mtime
  dune-configurator
  ppx_expect
  ppx_yojson_conv
  (ptime
   (>= 0.8.5))))
