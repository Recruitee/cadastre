# AGENTS.md

Cadastre is a small Elixir library that provides ISO country, language, and
subdivision (region) data with translated names. It is published to Hex and
consumed by other Recruitee repos.

## What this library exposes

- `Cadastre.Country` — ISO 3166-1 countries + name translations
- `Cadastre.Subdivision` — ISO 3166-2 subdivisions (regions) + name translations
- `Cadastre.Language` — ISO 639 languages
- `Cadastre.name(struct, locale)` returns the translated name, falling back to
  the English/native name when a locale has no translation.

## Data pipeline (read before touching any data)

There are three layers per domain (`countries`, `languages`, `subdivisions`):

1. `priv/dev/data/<domain>.json` — raw source, **generated** from the Debian
   `iso-codes` package. Do **not** hand-edit; `mix load_data` overwrites it.
2. `priv/dev/overrides/<domain>.json` — manual corrections, deep-merged over the
   source (leaf values win). **This is the only place to fix bad data.**
3. `priv/data/<domain>.etf` — the compiled artifact shipped in the package.
   **Generated**, never hand-edited.

Build step (`CadastreDev.Updater`): source JSON → deep-merge overrides → sort →
`:erlang.term_to_binary` → write `.etf`.

### Why translations are sometimes wrong

The raw source comes from Debian `iso-codes` gettext data, which contains
mistranslations for some region/locale pairs (a region name rendered as an
unrelated country, e.g. Latvia's "Madonas novads" appearing as "Monaco" in
Latvian). These cannot be reverted away; they were wrong from the first import.
Fix them in `priv/dev/overrides/subdivisions.json`.

## Mix tasks

- `mix load_data` — re-fetch raw ISO data into `priv/dev/data/*.json` from the
  iso-codes source. Rarely needed. Overwrites local source edits.
- `mix update_data` — apply overrides and regenerate `priv/data/*.etf`. Run this
  after editing any override file. Purely local, no network.

## How to fix a bad region/country name

1. Add the correction under the country/subdivision/locale in
   `priv/dev/overrides/subdivisions.json`. Use the authoritative native ISO name
   (for most regions this equals the `en` value).
2. `mix update_data` to regenerate `priv/data/subdivisions.etf`.
3. Verify at runtime:
   `Cadastre.Subdivision.new("LV", "059") |> Cadastre.Subdivision.name("lv")`.
4. Bump `@version` in `mix.exs`.
5. `mix test` (doctests must pass), `mix format`.
6. Commit `priv/dev/overrides/*.json`, `priv/data/*.etf`, and `mix.exs` together.

The `fix-region-translation` skill (`.claude/skills/`) automates the audit and
override generation for this class of bug.

## Toolchain

The repo has no `.tool-versions`. Use a modern OTP/Elixir, e.g.:

```
ASDF_ERLANG_VERSION=27.3.4.3 ASDF_ELIXIR_VERSION=1.18.3 mix update_data
```

## Release and downstream

1. Merge the fix, tag the new version, `mix hex.publish`.
2. Bump the dependency in each consumer (constraint is `~> 0.2.x`, so a patch
   release needs only a lockfile update):
   - `Recruitee/api` — `mix deps.update cadastre`, commit `mix.lock`
   - `Recruitee/careers-site` — same
   - `Recruitee/groundcontrol` — same
   - `Recruitee/integrations` does **not** depend on cadastre.

## Conventions

- New modules need `@moduledoc`; public functions need `@doc` (non-trivial) and
  `@spec`.
- Tests are doctests in the module files plus `test/`. Run with `mix test`.
