FROM ocaml-base as build

RUN mkdir /home/opam/dist
RUN mkdir /home/opam/dist/lib
WORKDIR /home/opam/dist
COPY --chown=opam:opam example/1-hello-opium/ .

COPY --chown=opam:opam elastic-apm.opam elastic-apm-logs-reporter.opam elastic-apm-lwt-client.opam elastic-apm-lwt-reporter.opam elastic-apm-opium-middleware.opam dune-project .
COPY --chown=opam:opam codegen codegen
COPY --chown=opam:opam core core
COPY --chown=opam:opam logs_reporter logs_reporter
COPY --chown=opam:opam lwt_client lwt_client
COPY --chown=opam:opam lwt_reporter lwt_client
COPY --chown=opam:opam opium_middleware opium_middleware


RUN opam exec -- dune build
RUN ldd ./_build/default/hello.exe | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp -v '{}' /home/opam/dist/lib/

FROM alpine:3.14

WORKDIR /dist
COPY --from=build /home/opam/dist/lib /lib/
COPY --from=build /home/opam/dist/_build/default/hello.exe .
ENTRYPOINT ./hello.exe -p $port
