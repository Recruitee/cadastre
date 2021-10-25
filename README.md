# Cadastre
https://hexdocs.pm/cadastre

A repository of languages, countries and country subdivisions from the iso-codes Debian package.

## Installation

The package can be installed
by adding `cadastre` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:cadastre, "~> 0.2"}
  ]
end
```

## Development

The `lib` directory is compiled to the library, the `dev` directory is only for development (downloading data and creating *.json and *.po files).

Run `mix load_data` to download new ISO data.
Run `mix update_data` to add it to the project.
