# Ambassador

A repository of languages, countries and country subdivisions

## Installation

The package can be installed
by adding `ambassador` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ambassador, github: "recruitee/ambassador"}
  ]
end
```

## Usage

```ex
alias Ambassador.Language

Language.all() #=> [Language{id: "aa", name: "Afar"}, ...]
Language.new("ca") #=> Language{id: "ca", name: "Catalan"}
Language.new("ca") |> Language.native_name() #=> "català"
Language.new("ca") |> Language.name("de") #=> "Katalanisch"

alias Ambassador.Country

Country.all() #=> [%Country{id: "AD", name: "Andorra"}, ...]
Country.new("NL") #=> %Country{id: "NL", name: "Netherlands"}
Country.new("NL") |> Country.name("be") #=> "Нідэрланды"

alias Ambassador.Subdivision

Country.new("SK") |> Subdivision.all() #=> [Subdivision{country_id: "SK", id: "BC", name: "Banskobystrický kraj"}, ...]
Country.new("SK") |> Subdivision.new("KI") #=> Subdivision{country_id: "SK", id: "KI", name: "Košický kraj"}
Subdivision.new("SK", "KI") #=> Subdivision{country_id: "SK", id: "KI", name: "Košický kraj"}
Subdivision.new("SK", "KI") |> Subdivision.name("be") #=> "Кошыцкі край"
Subdivision.new("SK", "KI") |> Subdivision.name("de") #=> "Kaschauer Landschaftsverband"
```
