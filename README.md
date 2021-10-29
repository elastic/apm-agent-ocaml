# OCaml agent for Elastic APM

## Dev setup

Clone

```bash
git clone git@github.com:elastic/apm-agent-ocaml-on-week-2021.git
cd apm-agent-ocaml-on-week-2021
```

Setup OCaml environment

```bash
opam switch init . 4.13.1
opam install ocamlformat ocamlformat-rpc ocaml-lsp-server
```

You can run a build in watch mode so new changes are automatically detected and
rebuilt. In a terminal, in or outside of your editor:

```bash
dune build -w
```

If you don't have it already, watch mode needs `fswatch` which can be installed
via `brew`:

```bash
brew install fswatch
```

If you're using vscode, install the OCaml Platform plugin by OCaml Labs. The
OCaml plugin should automatically detect the local opam switch you just created.
If you setup format on save in the editor it will automatically format new
changes via the LSP server to conform to the project's standard formatting.

Now hackity hackity hack ON!
