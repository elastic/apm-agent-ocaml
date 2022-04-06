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
  lwt_ppx
  cohttp-lwt-unix
  (elastic-apm
   (= :version))
  (elastic-apm-async-reporter
   (= :version))))

(package
 (name elastic-apm-async-reporter)
 (depends
  (ocaml
   (>= 4.12.0))
  async
  blue_http
  (elastic-apm
   (= :version))))

(package
 (name elastic-apm-async-client)
 (depends
  (ocaml
   (>= 4.12.0))
  async
  blue_http
  (elastic-apm
   (= :version))
  (elastic-apm-async-reporter
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
 (name elastic-apm-rock)
 (synopsis "Rock middleware for Elastic APM")
 (description "Application performance monitoring for rock services")
 (depends
  (ocaml
   (>= 4.12.0))
  rock
  dune-build-info
  rock
  lwt_ppx
  (elastic-apm-lwt-client
   (= :version))))
