# OCaml agent for Elastic APM

<p align="center">
  <img
    alt="Test and Build OCaml APM Client"
    src="https://github.com/elastic/apm-agent-ocaml-on-week-2021/actions/workflows/build-client.yml/badge.svg" />
</p>

## Dev setup

Clone

```bash
git clone git@github.com:elastic/apm-agent-ocaml-on-week-2021.git
cd apm-agent-ocaml-on-week-2021
```

Setup OCaml environment

```bash
opam switch create . 4.13.1
opam install ocamlformat ocamlformat-rpc ocaml-lsp-server
```

You can run a build in watch mode so new changes are automatically detected and
rebuilt. In a terminal, in or outside of your editor:

```bash
dune build -w
```

Tests can also be run in watch mode with expectation tests automatically
capturing changes in output! This gives an almost magical experience where test
results update as new tests are written _and_ as the library itself evolves.

```bash
dune build @runtest -w --auto-promote
```

If you don't have it installed already, watch mode needs `fswatch` which can be
installed via `brew`:

```bash
brew install fswatch
```

If you're using vscode, install the OCaml Platform plugin by OCaml Labs. The
OCaml plugin should automatically detect the local opam switch you just created.
If you setup format on save in the editor it will automatically format new
changes via the LSP server to conform to the project's standard formatting.

Now hackity hackity hack ON!

### Running the examples locally

* Install docker + docker compose
* `docker compose build ocaml-base`
* `docker compose build`
* `docker compose up -d`

Once docker compose up finishes the following endpoints will be available:

* http://localhost:5601 -> Kibana
* http://localhost:4000 -> [OCaml hello-world example](./example/1-hello-opium)
* http://localhost:4001 -> [OCaml example that talks to a python service](./example/3-polyglot-services/ocaml)
* http://localhost:5000 -> [Python flask application](./example/3-polyglot-services/python)
* http://localhost:4003 -> [OCaml example that talks to postgres](./example/2-database-ocaml)
