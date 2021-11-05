FROM ocaml/opam:alpine-3.14-ocaml-4.13 AS build

RUN sudo apk add libev-dev gmp-dev

COPY --chown=opam:opam elastic-apm.opam elastic-apm-logs-reporter.opam elastic-apm-lwt-client.opam elastic-apm-lwt-reporter.opam elastic-apm-opium-middleware.opam .

RUN opam install ./ --deps-only -y

ENTRYPOINT opam exec -- ocamlc -version
