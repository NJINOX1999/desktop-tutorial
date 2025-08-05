# Audit Report

| Nr. | Feature | Status | Pfad/Kommentar |
| --- | ------- | ------ | -------------- |
| 1 | Kristall: Platzieren, zerstören → Buff, Ersatz-Kristall, Game Over erst bei Kristall + alle Spieler tot | ✅ | ServerScriptService/Core/srv_CrystalHandler.lua |
| 2 | Tag-/Nacht-System, Wellen nur nachts, Boss alle 10 Wellen | ✅ | ServerScriptService/Core/srv_GameLoop.lua, srv_WaveManager.lua |
| 3 | Easy/Normal/Hard: Gegner + XP ±50% | ✅ | ReplicatedStorage/Modules/mod_Config.lua, ServerScriptService/Modules/mod_Utilities.lua |
| 4 | Tower-Bau: Ghost, Coin-Kosten, Tower-Limit (3 + Level) | ❌ | TODO: Ghost-Visualisierung unvollständig (StarterPlayer/StarterPlayerScripts/cli_UIManager.lua) |
| 5 | Coins durch Loot, XP durch Kills, Tower-Limit ↑ bei Level-Up | ✅ | ServerScriptService/Core/srv_LootHandler.lua, Modules/mod_LevelService.lua |
| 6 | Down/Revive-System: 60 Sek. Down, 15 Sek. Heal | ✅ | ServerScriptService/Core/srv_DownSystem.lua |
| 7 | Buyback beim Bürgermeister für 10.000 Coins | ❌ | TODO: Config.BuybackPrice in ReplicatedStorage/Modules/mod_Config.lua |
| 8 | 3 Speicher-Slots (nur Host) | ✅ | ServerScriptService/Core/srv_SaveService.lua |
| 9 | Lobby: Slot- & Schwierigkeits-GUI, Start durch Host, max. 6 Spieler | ❌ | TODO: Slot-GUI/Host-Start (StarterGui/ScreenGui_Menu/ls_Menu.lua) |
| 10 | Sicherheitsprüfung aller Remotes, Aufräumroutinen | ✅ | ServerScriptService/Core/srv_AntiExploit.lua |
| 11 | Ordnerstruktur vollständig | ✅ | Projektstruktur vorhanden |
| 12 | Config.Version = v1.0.0 | ❌ | TODO: Version in ReplicatedStorage/Modules/mod_Config.lua |
| 13 | BuildReport mit „ALLE 10 KRITERIEN ERFÜLLT“ & „Tests A–E PASS“ | ❌ | BuildReport.txt fehlt geforderte Inhalte |
| 14 | Linter (Luau) läuft ohne Fehler (mit type stubs) | ❌ | `luau-lint` nicht installiert |
| 15 | Headless-TestEZ-Tests vorhanden oder als SKIP markiert | ❌ | Keine Tests gefunden |

## Ergebnis
Nicht alle Kriterien erfüllt.
