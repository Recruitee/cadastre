#!/usr/bin/env python3
"""Detect corrupt subdivision translations in cadastre.

A translation is flagged when a subdivision's name in some locale equals a
country name (in any locale, diacritic-insensitive) or another country's
subdivision name, while differing from the region's own native/English name.
This catches the "region shown as an unrelated country/place" corruption that
comes from the upstream Debian iso-codes data.

Usage:
    detect.py                 # whole-dataset summary (per-locale counts)
    detect.py LV              # list flagged pairs for one country, with fixes
    detect.py --apply LV      # write fixes into priv/dev/overrides/subdivisions.json

Run from the repo root. After --apply, run `mix update_data` to rebuild the etf.
"""
import json
import sys
import unicodedata
from collections import defaultdict

DATA = "priv/dev/data"
OVERRIDES = "priv/dev/overrides"


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def deep_merge(a, b):
    out = dict(a)
    for k, v in b.items():
        if k in out and isinstance(out[k], dict) and isinstance(v, dict):
            out[k] = deep_merge(out[k], v)
        else:
            out[k] = v
    return out


def key(s):
    n = unicodedata.normalize("NFKD", unicodedata.normalize("NFKC", s))
    return "".join(c for c in n if not unicodedata.combining(c)).strip().casefold()


def build():
    subs = deep_merge(load(f"{DATA}/subdivisions.json"), load(f"{OVERRIDES}/subdivisions.json"))
    countries = deep_merge(load(f"{DATA}/countries.json"), load(f"{OVERRIDES}/countries.json"))
    country_key = {}
    for code, tr in countries.items():
        for name in tr.values():
            if isinstance(name, str) and name.strip():
                country_key.setdefault(key(name), code)
    return subs, country_key


def flags_for(subs, country_key, country):
    """Yield (sid, locale, value, en_fix, reason) for one country."""
    other = defaultdict(set)
    for c, sd in subs.items():
        if c == country:
            continue
        for sid, tr in sd.items():
            for val in tr.values():
                if isinstance(val, str) and val.strip():
                    other[key(val)].add(f"{c}-{sid}")
    sd = subs[country]
    native = {key(tr.get("en", "")) for tr in sd.values() if tr.get("en")}
    for sid, tr in sd.items():
        en = tr.get("en", "") or ""
        root = key(en).split(" ")[0] if en else ""
        for loc, val in tr.items():
            if loc == "en" or not isinstance(val, str) or not val.strip():
                continue
            k = key(val)
            if k in native or (root and root in k):
                continue
            if k in country_key:
                yield sid, loc, val, en, f"country {country_key[k]}"
            elif k in other:
                yield sid, loc, val, en, "place " + ",".join(sorted(other[k])[:2])


def summary(subs, country_key):
    by_loc = defaultdict(int)
    total = 0
    for country in subs:
        for _sid, loc, _v, _en, _r in flags_for(subs, country_key, country):
            by_loc[loc] += 1
            total += 1
    print(f"Total flagged pairs: {total}")
    for loc, n in sorted(by_loc.items(), key=lambda x: -x[1]):
        print(f"  {loc}: {n}")


def main():
    args = sys.argv[1:]
    apply = "--apply" in args
    args = [a for a in args if a != "--apply"]
    subs, country_key = build()
    if not args:
        summary(subs, country_key)
        return
    country = args[0].upper()
    if country not in subs:
        sys.exit(f"unknown country: {country}")
    rows = list(flags_for(subs, country_key, country))
    for sid, loc, val, en, reason in sorted(rows):
        print(f"{country}-{sid} {loc}={val!r} -> {en!r} [{reason}]")
    print(f"\n{len(rows)} pairs across {len({r[0] for r in rows})} subdivisions")
    if apply:
        ov = load(f"{OVERRIDES}/subdivisions.json")
        ov.setdefault(country, {})
        for sid, loc, _val, en, _r in rows:
            ov[country].setdefault(sid, {})[loc] = en
        with open(f"{OVERRIDES}/subdivisions.json", "w", encoding="utf-8") as f:
            json.dump(ov, f, ensure_ascii=False, indent=2)
            f.write("\n")
        print(f"\nWrote overrides for {country}. Run `mix update_data` to rebuild the etf.")


if __name__ == "__main__":
    main()
