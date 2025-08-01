# Roblox Tower Defense Island

This repository is an early prototype of the **Islebound** tower defense/survival project. The folder layout matches the design specification and contains initial Lua scripts for the core systems.

Implemented systems include:

- Day/night game loop that fires local and remote events (`DayStart`, `NightStart`, `TimeOfDayChanged`).
- Wave manager spawning scaled zombie waves with a boss every tenth night.
- DataStore v2 save service with autosave, player join/load and shutdown saves.
- Resource manager replacing tagged map objects with breakable prefabs that respawn after five minutes.
- Server-side build handler validating placement and enforcing per-player turret limits.
- Basic monster AI plus tower logic for attacking spawned monsters.
- Lightweight anti exploit checks for speed and teleport abuse.

The scripts are simplified for demonstration and do not represent final gameplay quality.
