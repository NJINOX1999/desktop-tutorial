# Battlegrounds Roblox Server Kit

Dieses Repository enthält ein vollständiges, serverseitiges Battlegrounds-Grundgerüst für Roblox. Es richtet eine Rundenlogik, ein simples Nahkampf-System, Spawn-Handling und Leaderstats ein.

## Features
- Runden- & Intermission-Loop mit Score-to-Win
- Nahkampf-Hitbox mit Knockback
- Leaderstats (KOs, WOs, Streak, Score)
- Randomisierte Spawns
- RemoteEvent für Attacken & Rundenzustand

## Struktur
- `ServerScriptService/Main.server.lua`: Haupt-Loop, Round-Management, RemoteEvents
- `ServerScriptService/Modules/*.lua`: Konfiguration, Player-, Combat-, Match- und Spawn-Services

## Setup in Roblox Studio
1. Erstelle in **Workspace** einen Ordner `Arena`.
2. Lege in `Arena` einen Ordner `Spawns` an und platziere darin SpawnParts.
3. Kopiere die Ordnerstruktur dieses Repos in dein Roblox-Spiel:
   - `ServerScriptService` nach **ServerScriptService**
   - `ReplicatedStorage/Remotes` nach **ReplicatedStorage** (die Remotes werden zur Not auch serverseitig erzeugt).
4. Starte das Spiel und löse Client-seitig das `Attack`-RemoteEvent aus (z. B. über ein Tool oder Input-Script).

## Client-Hinweis
Das Server-Script erwartet einen Client, der bei einem Angriff `Remotes.Attack:FireServer()` aufruft. Außerdem kannst du den Rundenzustand über `Remotes.RoundState.OnClientEvent` anzeigen (HUD).

## Konfiguration
Alle Einstellungen befinden sich in `ServerScriptService/Modules/Config.lua`.
