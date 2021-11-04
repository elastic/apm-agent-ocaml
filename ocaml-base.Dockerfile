FROM ocaml/opam:alpine-3.14-ocaml-4.13 AS build

RUN sudo apk add libev-dev gmp-dev

COPY --chown=opam:opam elastic-apm.opam .

RUN opam install ./elastic-apm.opam --deps-only -y

ENTRYPOINT opam exec -- ocamlc -version
