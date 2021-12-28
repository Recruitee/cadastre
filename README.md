# Cadastre

[![Module Version](https://img.shields.io/hexpm/v/cadastre.svg)](https://hex.pm/packages/cadastre)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/cadastre/)
[![Total Download](https://img.shields.io/hexpm/dt/cadastre.svg)](https://hex.pm/packages/cadastre)
[![License](https://img.shields.io/hexpm/l/cadastre.svg)](https://github.com/Recruitee/cadastre/blob/master/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/Recruitee/cadastre.svg)](https://github.com/Recruitee/cadastre/commits/master)

A repository of languages, countries and country subdivisions from the
[iso-codes](https://packages.debian.org/sid/iso-codes) Debian package.

## Installation

The package can be installed by adding `:cadastre` to your list of dependencies
in `mix.exs`:

```elixir
def deps do
  [
    {:cadastre, "~> 0.2"}
  ]
end
```

## Development

The `lib` directory is compiled to the library, the `dev` directory is only for development (downloading data and creating `*.json` and `*.po` files).

Run `mix load_data` to download new ISO data.
Run `mix update_data` to add it to the project.

## Copyright and License

Copyright (c) 2020 Recruitee B.V.

This library is released under [MIT licensed](./LICENSE.md).
