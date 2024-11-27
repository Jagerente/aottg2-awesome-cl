# Counter Strike Logic

| Author    | Version |
|-----------|---------|
| Jagerente | v1.0.1  |

## Features

- Custom modes
  - Bomb Plant
  - Hostage
  - Team Deathmatch
  - Deathmatch
- Custom Weapons
- Weapon Swap
- Headshots
- Shopping
- Custom Movement | Custom Abilities
  - Bunny Hop
  - Air Movement
  - Air Dash
- Custom Weapons Specials
  - Smoke Bomb
  - Zoom
  - Thermal Vision
- Throwables
  - Frag Grenade

---

## Guide

> Inspect the info text on the left side of the screen; 
> it contains useful information about your status, hotkeys,
> and much more.

### Bomb Plant

Mission:
- Red Team: Plant the bomb.
- Blue Team: Defuse the bomb.

Win Conditions:
- Red Team wins if:
  - The bomb explodes, or
  - They eliminate the Blue Team.
- Blue Team wins if:
  - They defuse the bomb, or
  - No bomb is planted, and they eliminate the Red Team.

---

### Hostage

Mission:
- Red Team: Escort all hostages.
- Blue Team: Prevent the escort.

Win Conditions:
- Red Team wins if:
  - All hostages are escorted, or
  - They eliminate the Blue Team.
- Blue Team wins if:
  - They eliminate the Red Team.

---

### Team Deathmatch

Mission:
- Red Team: Eliminate the Blue Team.
- Blue Team: Eliminate the Red Team.

Win Conditions:
- Red Team wins by eliminating the Blue Team.
- Blue Team wins by eliminating the Red Team.

---

### Deathmatch

- No mission.
- No win conditions.
- Free weapons available.

---

## Usage

- Do not attach CL directly to the map. Use it as a separate logic game mode.
- Supported maps can be found here: [maps](./maps).

### Setup Instructions:

1. Ensure the selected `Map` is correct under CL settings (`Settings/Mode`).
2. Choose the desired `Game mode` under CL settings.
3. Set game settings as follows:

| Setting                       | Value                                                                        |
|-------------------------------|------------------------------------------------------------------------------|
| Mode/Game mode                | `cs`                                                                         |
| Misc/PVP                      | `FFA` for `Deathmatch` <br/> `Team` for `Bomb Plant/Hostage/Team Deathmatch` |
| Mode/Map                      | Must be equal to the map you are playing.                                    |
| Mode/Game Mode                | Do not forget to update Misc/PVP as well.                                    |
| Misc/Realism Mode             | On                                                                           |
| Misc/Allow Blades/AHSS/TS/APG | On                                                                           |
| Misc/Allow player titans      | Off                                                                          |
| Misc/Allow shifters           | Off                                                                          |
| Misc/Allow shifter specials   | Off                                                                          |
| Misc/Guns air reload          | On                                                                           |
| Titans/Custom sizes           | On<br/>Min: 0.1<br/>Max: 0.1                                                 |
| Titans/Armor mode             | On<br/>Armor: 99999                                                          |

---

## Adapting map

To adapt your map for this logic, it must include specific objects:

1. Attach Custom Logic to your map for adding components. Remove it before use. 
2. Add reference objects outside the map using following code (add it to the `Objects` section).
```
Scene,General/EditorPointLight,83000,0,1,1,0,0,BlueHighlightReference,0,-200,0,0,0,0,1,1,1,None,Entities,Default,DefaultNoTint|255/255/255/255,PointLight|Color:0/0/255/255|Intensity:6|Range:1.5;
Scene,General/EditorPointLight,83001,0,1,1,0,0,RedHighlightReference,20,-200,0,0,0,0,1,1,1,None,Entities,Default,DefaultNoTint|255/255/255/255,PointLight|Color:255/0/0/255|Intensity:6|Range:1.5;
Scene,General/HumanReference,83002,0,1,1,1,0,Human Reference,40,-201.4004,0,0,0,0,1,1,1,None,Entities,Default,Default|255/255/255/255,;
Scene,Geometry/Cube1,83003,0,1,1,0,0,Hitbox_HEAD,40,-200,0,0,0,0,0.7,0.7,0.7,Region,Humans,Default,Transparent|255/0/0/15|Misc/None|1/1|0/0,;
Scene,Geometry/Hedron1,83004,0,1,1,1,0,FragGrenade,60,-200,0,0,0,0,0.5,0.5,0.5,Physical,MapObjects,Default,Transparent|0/67/0/255|Misc/None|1/1|0/0,Rigidbody|Mass:1|Gravity:0/-20/0|FreezeRotation:false|Interpolate:false,PointLight|Color:139/0/0/255|Intensity:15|Range:3;
Scene,Geometry/Sphere1,83005,83004,1,1,1,0,FragGrenade_ExplosionRegion,60,-200,0,0,0,0,25,25,25,Region,Humans,Default,Transparent|255/0/0/15|Misc/None|1/1|0/0,FragGrenadeZone|;
Scene,Geometry/Cube1,83006,0,1,1,1,0,ShoppingRegionDM,40,-200.5,0,0,0,0,5,5,5,Region,Characters,Default,Transparent|0/255/0/56|Misc/None|1/1|0/0,ShoppingZone|Name:Weapons_T|Width:300|Height:230,
```
3. Add necessary regions and spawn points:
  - Shopping Region:
    - Name: `ShoppingRegion`
    - Component: `ShoppingZone`
  - Spawn Points:
    - `Human SpawnPoint (blue)`
    - `Human SpawnPoint (red)`
    - `Human SpawnPoint`
  - Optional (Bomb Plant):
    - Bomb plant regions:
      - Name: `BombPlantRegion`
      - Component: `BombPlant`
    - Explosion zone:
      - Name: `ExplosionKillRegion`
      - Component: `KillZone`
  - Optional (Hostage):
    - Escort zone:
      - Name: `HostageEscortRegion`
      - Component: `HostageEscortZone`
    - Hostage references:
      - Name: `HostageReference`
4. Remove Custom Logic from the map and save.
