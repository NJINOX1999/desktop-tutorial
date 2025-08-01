# Roblox Tower Defense Island

This repository is an early prototype of the **Islebound** tower defense/survival project. The folder layout matches the design specification and contains initial Lua scripts for the core systems.

Implemented systems include:

- Day/night game loop that fires local and remote events (`DayStart`, `NightStart`, `TimeOfDayChanged`).
- Wave manager spawning scaled zombie waves with a boss every tenth night.
- DataStore v2 save service with autosave, player join/load and shutdown saves.
- Resource manager replacing tagged map objects with breakable prefabs that respawn after five minutes.
- Server-side build handler validating placement and enforcing per-player turret limits.
- Basic monster AI with pathfinding and simple loot drops plus tower logic for attacking spawned monsters.
- Towers cost coins to build which are deducted from player save data. Additional turrets unlock through the new level system.
- Loot pickups grant coins via a server-side handler.
- Crystal health module tracks base health when monsters attack.
- Lightweight anti exploit checks for speed and teleport abuse.
- Difficulty and XP multiplier can be set by the host.
- Host player selects one of three save slots; guests play without persistent data.
- Crystal placement triggers wave 0 and day/night cycle. Destroyed crystals buff existing monsters until a replacement is set.
- Daytime spawns occasional wandering monsters in addition to nightly waves.
- Revive and healing system using `E` key when near teammates.
- Building preview client with server validation and placement limits.
- A simple level system that converts XP gains into levels which extend the turret limit.
- Game over cleanup with optional inventory buyback via `RF_BuyBack`.

The scripts are simplified for demonstration and do not represent final gameplay quality.
