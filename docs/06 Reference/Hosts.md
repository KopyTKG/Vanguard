---
title: Hosts
tags: [reference]
---

# Hosts

All reach `hosting.thekrew.app` on the port shown, guarded by the MikroTik CHR (SSH as `root`, key `~/.ssh/vanguard/<name>`).

| Host        | Port | Group             | App / purpose                 | Host vars                      |
| ----------- | ---- | ----------------- | ----------------------------- | ------------------------------ |
| ts-server   | 2200 | generic           | TeamSpeak                     | —                              |
| worldle-db  | 2201 | postgress         | Worldle DB                    | —                              |
| worldle-api | 2202 | csharp            | Worldle API                   | —                              |
| worldle-web | 2203 | web               | Worldle web                   | —                              |
| allthemons | 2204 | minecraft *(commented out)* | All the Mons Minecraft server — worked example | `mc_*` ([[Minecraft#Worked example allthemons]]) |
| grafana     | 2206 | generic           | Grafana                       | —                              |
| proxy       | 2207 | generic           | proxy                         | —                              |
| jenkins     | 2208 | generic           | CI                            | —                              |
| avorion     | 2209 | steamcmd          | Avorion server                | `steam_games`, `steam_servers` |
| foundry     | 2210 | foundryvtt        | FoundryVTT **(v13+)**         | `foundry_version`              |
| cybervtt    | 2211 | foundryvtt        | FoundryVTT **(v12 or older)** | `foundry_version`              |
| dummyvtt    | 2212 | foundryvtt (test) | throwaway for rehearsals      | `foundry_version`              |
| *(next)*    | 2213 | —                 | e.g. `mcdummy` Minecraft test | `mc_*`                         |
| esl         | 2225 | generic           | ESL                           | —                              |

> [!note] Keep this in sync
> Ports and groups come from `inventory.yml`. Update both together — see [[Add a Client]]. Port 2205 is unused in the inventory.

Live platforms (always [[Test on a Dummy LXC]] first): foundry, cybervtt, avorion.
