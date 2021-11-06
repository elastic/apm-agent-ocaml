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
  hex
  mtime
  dune-configurator
  dune-build-info
  (ppx_expect :with-test)
  ppx_yojson_conv
  yojson
  (ptime
   (>= 0.8.5))))

(package
 (name elastic-apm-lwt-reporter)
 (depends
  (ocaml
   (>= 4.12.0))
  lwt
  cohttp-lwt-unix
  (elastic-apm
   (= :version))))

(package
 (name elastic-apm-lwt-client)
 (depends
  (ocaml
   (>= 4.12.0))
  lwt
  cohttp-lwt-unix
  (elastic-apm
   (= :version))
  (elastic-apm-lwt-reporter
   (= :version))))

(package
 (name elastic-apm-logs-reporter)
 (depends
  (ocaml
   (>= 4.12.0))
  logs
  (elastic-apm
   (= :version))))

(package
 (name elastic-apm-opium-middleware)
 (synopsis "Opium middleware for Elastic APM")
 (description "Application performance monitoring for opium services")
 (depends
  (ocaml
   (>= 4.12.0))
  opium
  dune-build-info
  (elastic-apm-lwt-client
   (= :version))))
