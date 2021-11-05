FROM ocaml-base as build

RUN mkdir /home/opam/dist
RUN mkdir /home/opam/vendor
RUN mkdir /home/opam/dist/lib
WORKDIR /home/opam/dist
COPY --chown=opam:opam example/3-polyglot-services/ocaml/ .

RUN opam install ./demo_polyglot.opam --deps-only -y

COPY --chown=opam:opam codegen vendor/codegen
COPY --chown=opam:opam core vendor/core
COPY --chown=opam:opam logs_reporter vendor/logs_reporter
COPY --chown=opam:opam lwt_client vendor/lwt_client
COPY --chown=opam:opam lwt_reporter vendor/lwt_client
COPY --chown=opam:opam opium_middleware vendor/opium_middleware
COPY --chown=opam:opam dune-project vendor/dune-project


RUN opam exec -- dune build

RUN ldd ./_build/default/hello.exe | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp -v '{}' ./lib/

FROM alpine:3.14

WORKDIR /dist
COPY --from=build /home/opam/dist/_build/default/hello.exe .
COPY --from=build /home/opam/dist/lib /lib/
ENTRYPOINT ./hello.exe -p $port
