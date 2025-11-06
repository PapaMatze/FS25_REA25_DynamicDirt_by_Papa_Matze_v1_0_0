REA Dynamic Dirt - LS25 upgrade (v1.2)
Converted from FS22 by user request. This repo contains a basic compatibility update
and a few quality-of-life additions for Farming Simulator 25.

What I changed:
- modDesc.descVersion set to 92 and schema attributes added (FS25)
- Added MIT license and README
- Prepended a compatibility header to READynamicDirt.lua to log runtime info on startup

Notes & next steps for a full public release:
- Test in GIANTS Studio / FS25 with the SDK; update Lua API calls if any deprecated functions show errors in the log.
- Consider replacing custom puddle rendering with FS25's updated water/dirt shaders (requires shader/i3d updates).
- Add storeItems.xml and textures for ModHub compliance; ensure no copyrighted assets are included.

