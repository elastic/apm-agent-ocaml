FROM ocaml-base as build

RUN mkdir /home/opam/dist
WORKDIR /home/opam/dist
COPY --chown=opam:opam example/2-database-ocaml/ .

RUN opam exec -- dune build --profile=static

FROM alpine:3.14

WORKDIR /dist
COPY --from=build /home/opam/dist/_build/default/hello.exe .
ENTRYPOINT ./hello.exe -p $port
