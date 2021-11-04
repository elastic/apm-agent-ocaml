FROM ocaml-base as build

RUN mkdir /home/opam/dist
RUN mkdir /home/opam/dist/lib
WORKDIR /home/opam/dist
COPY --chown=opam:opam example/3-polyglot-services/ocaml/ .

RUN opam exec -- dune build --profile=static

RUN ldd ./_build/default/hello.exe | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp -v '{}' ./lib/

FROM alpine:3.14

WORKDIR /dist
COPY --from=build /home/opam/dist/_build/default/hello.exe .
COPY --from=build /home/opam/dist/lib /lib/
ENTRYPOINT ./hello.exe -p $port
