# Roblox Tower Defense Island

This repository is an early prototype of the **Islebound** tower defense/survival project. The folder layout matches the design specification and contains initial Lua scripts for the core systems.

Implemented systems include:

- Day/night game loop dispatching `DayStart`, `NightStart`, and `TimeOfDayChanged` events.
- Wave manager that spawns scaled zombie waves and bosses every tenth night.
- DataStore v2 save service with autosave and player data loading.
- Resource manager that replaces tagged map objects with breakable prefabs and respawns them after 5 minutes.
- Simple monster AI targeting nearby players or the crystal.

The scripts are simplified for demonstration and do not represent final gameplay quality.
