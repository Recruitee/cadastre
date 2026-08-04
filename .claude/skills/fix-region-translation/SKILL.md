---
name: fix-region-translation
description: Fix corrupt country/region (subdivision) name translations in the cadastre library, where a region's name in some locale is shown as an unrelated country or place (e.g. Latvia's "Madonas novads" rendered as "Monaco" in Latvian). Use when a ticket reports a wrong translated location name, or to audit the dataset for this class of corruption.
---

# Fix cadastre region translations

The raw translation source (Debian `iso-codes`) contains mistranslations where a
subdivision name is replaced by an unrelated country or place for some locales.
These are fixed with entries in `priv/dev/overrides/subdivisions.json`, then the
`.etf` artifact is regenerated. See `AGENTS.md` for the full data pipeline.

## Steps

1. **Reproduce / locate.** Identify the country and subdivision. Region ids are
   ISO 3166-2 (e.g. Latvia `LV`, Madonas novads `059`). Decode the current value:

   ```
   Cadastre.Subdivision.new("LV", "059") |> Cadastre.Subdivision.name("lv")
   ```

2. **Audit.** Run the bundled detector to find every affected (region, locale)
   pair for the country. It flags any translation that equals a country name (in
   any locale, diacritic-insensitive) or another country's subdivision name, and
   proposes the authoritative native ISO name (the `en` value) as the fix:

   ```
   python3 .claude/skills/fix-region-translation/detect.py LV
   ```

   Pass no argument to scan the whole dataset and get per-locale corruption
   counts. Review the output; the country-name matches are unambiguous, the
   "other place" matches deserve a glance.

3. **Apply overrides.** Add each correction under the subdivision/locale in
   `priv/dev/overrides/subdivisions.json`. Deep-merge semantics mean a leaf value
   overwrites the source. For most regions the correct value equals the `en`
   name. `detect.py --apply LV` writes the overrides for you (review the diff).

4. **Regenerate the artifact.**

   ```
   ASDF_ERLANG_VERSION=27.3.4.3 ASDF_ELIXIR_VERSION=1.18.3 mix update_data
   ```

   Confirm `git status` shows only `priv/data/subdivisions.etf` and the override
   JSON changed.

5. **Verify.** Re-run the detector (expect 0 for the country) and check runtime:

   ```
   ASDF_ERLANG_VERSION=27.3.4.3 mix run -e 'IO.inspect Cadastre.Subdivision.new("LV","059") |> Cadastre.Subdivision.name("lv")'
   ```

6. **Bump + test.** Bump `@version` in `mix.exs`, run `mix test` and
   `mix format`. Commit the override JSON, the `.etf`, and `mix.exs` together.

7. **Release + downstream.** After merge: tag, `mix hex.publish`, then
   `mix deps.update cadastre` + commit `mix.lock` in `Recruitee/api`,
   `Recruitee/careers-site`, and `Recruitee/groundcontrol`.
   `Recruitee/integrations` does not depend on cadastre.

## Notes

- Never hand-edit `priv/data/*.etf` or `priv/dev/data/*.json`; both are
  regenerated. Overrides are the only durable fix.
- Overriding a Cyrillic/CJK locale with the Latin `en` name is acceptable and
  matches the library's fallback behavior; do not hand-invent script-specific
  translations unless you have an authoritative source.
- Stale data (e.g. a region merged in a boundary reform mislabeled as its former
  neighbor) is a separate accuracy issue from this country-name corruption. Fix
  it only when the correct value is unambiguous.
