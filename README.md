# Rainbow Lasers

Makes your laser beams RGB. Works on laser turrets, personal laser defense and
destroyer robots — everything that fires the vanilla `laser-beam`.

This repository holds a **Factorio 2.1 port** of
[Rainbow Lasers by Honza2268](https://mods.factorio.com/mod/RainbowLasers),
which was published for 2.0 and never updated. The graphics are the original
author's, unchanged.

It ships as `RainbowLasers-2-1` rather than `RainbowLasers`, because the original
name belongs to the author's 2.0-only portal entry. The two are marked mutually
incompatible, so only one can be enabled at a time.

## Why a port was needed

Factorio matches `factorio_version` in `info.json` against one major version
only: a mod marked `"2.0"` covers every 2.0.x release and nothing else, so the
original mod simply does not load under 2.1
([mod structure docs](https://lua-api.factorio.com/latest/auxiliary/mod-structure.html)).

The prototypes the mod touches did not change: as of base 2.1.19 the
`laser-beam` beam still exposes `graphics_set.beam.{head,body,tail}` and
`graphics_set.ground.{head,body,tail}`, and every animation property used here
(`frame_count`, `line_length`, `repeat_count`, `animation_speed`, `tint`,
`draw_as_light`, `blend_mode`) is still supported. So the port is the version
bump plus robustness fixes — see `RainbowLasers/changelog.txt`.

## How it works

Each sheet in `graphics/` is the vanilla 8-frame beam animation repeated once
per hue step, 8 frames per row — 72 frames in a 8×9 grid. `data-updates.lua`
repoints the beam's visible layers at those sheets and stretches the vanilla
light layers over the same 72-frame cycle with `repeat_count`, so the glow stays
in sync while the beam walks through the hues. The ground glow is replaced
outright, including the red tint vanilla puts on it.

Two knobs at the top of `data-updates.lua`: `ANIMATION_SPEED` for how fast the
colours cycle, and `TINT` to dim the beams.

## Installing

Grab a zip from the releases, or build one:

```bash
./build.sh          # -> build/RainbowLasers-2-1_<version>.zip
```

Drop the zip in your Factorio `mods` folder — its filename already follows the
`{name}_{version}` pattern the game and the mod portal require. For development
you can instead symlink or copy the `RainbowLasers-2-1/` folder there directly.

## Tests

```bash
./tests/run.sh
```

The suite loads the mod on top of the **real** base-game beam prototypes, pulled
from [wube/factorio-data](https://github.com/wube/factorio-data), then checks
that every replaced animation's frame grid matches the actual pixel size of the
shipped PNGs, that the light layers stay in sync, and that unrelated beams are
left alone. A second pass covers the awkward cases other mods can create —
missing prototypes, reordered or extra beam layers, striped sheets.

Requires `lua5.4`, `python3` and `git`.

## Credits and licence

Original mod and all graphics by **Honza2268**, MIT licensed — which permits
redistribution as long as the copyright notice is kept, and it is kept in
`LICENSE`. `info.json` still credits Honza2268 as the author.

The original 2.0 entry on the mod portal remains the author's; this is a separate
entry under a separate name, not a replacement for it.
