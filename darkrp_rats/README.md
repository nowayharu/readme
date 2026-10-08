# DarkRP – Rats & Dératiseur

Addon Garry's Mod pour DarkRP : des rats apparaissent dans les propriétés à partir de **nids placés au toolgun**, et le métier **Dératiseur** les élimine avec son **pulvérisateur de raticide** pour gagner de l'argent.

## Installation

1. Copier le dossier `darkrp_rats` dans `garrysmod/addons/`.
2. Redémarrer le serveur.
3. Régler `lua/darkrp_rats/sh_config.lua` selon vos envies.

## Fonctionnement

| Élément | Description |
|---|---|
| **Outil « Nid de rats »** (onglet *DarkRP* du menu outils) | Clic gauche : placer un nid · Clic droit : le supprimer · R : appliquer les réglages (nombre max, intervalle, rayon) au nid visé. Réservé aux admins. |
| **Nid** (`rat_nest`) | Fait apparaître un rat toutes les X secondes jusqu'au maximum. Indestructible, sauvegardé automatiquement par map dans `data/darkrp_rats/<map>.json`. Les admins voient ses infos et son rayon avec le toolgun/physgun en main. |
| **Rat** (`darkrp_rat`) | Se promène autour de son nid, couine, s'enfuit quand il est touché. Seul le dératiseur peut le tuer (configurable). |
| **Métier Dératiseur** | Créé automatiquement (`/deratiseur`). Reçoit `weapon_deratiseur`. Voit les rats proches en surbrillance. |
| **Pulvérisateur** (`weapon_deratiseur`) | Clic gauche : nuage de poison à courte portée · Clic droit : détecteur de rats. |

Options utiles dans la config :

- `RequireOwnedProperty` : les rats n'apparaissent que si une porte proche du nid est achetée.
- `RequireExterminatorOnline` : pas de rats si aucun dératiseur n'est connecté.
- `NotifyOwner` / `NotifyExterminators` : préviennent le propriétaire et les dératiseurs d'une infestation.
- `KillReward` : argent gagné par rat tué.
- `NestVisible` : rendre les nids invisibles aux joueurs.

Commandes admin : `drats_killall` (supprime tous les rats), `drats_reload` (recharge les nids sauvegardés).

## Modèle de rat

Le jeu de base ne contient aucun rat : par défaut un petit headcrab est utilisé. Pour un vrai rat, prenez un modèle du Workshop, ajoutez-le au serveur (`resource.AddWorkshop`) et changez `RatModel`, `RatRunSequence` et `RatIdleSequence` dans la config.

## Déclarer le métier soi-même

Pour gérer le métier dans `darkrpmodification`, mettez `CreateJob = false` puis ajoutez dans `jobs.lua` :

```lua
TEAM_DERATISEUR = DarkRP.createJob("Dératiseur", {
    color = Color(120, 160, 60, 255),
    model = { "models/player/Group03/male_02.mdl" },
    description = [[Éliminez les rats qui envahissent la ville.]],
    weapons = { "weapon_deratiseur" },
    command = "deratiseur",
    max = 3,
    salary = 45,
    admin = 0,
    vote = false,
    category = "Citizens",
})
```

Le nom du métier doit correspondre à `JobName` (ou être ajouté dans `ExtraExterminatorJobs`).

## Hooks pour développeurs

- `DRATS_CanSpawnRat(nest)` : retourner `false` pour empêcher une apparition.
- `DRATS_RatKilled(ply)` : appelé quand un dératiseur tue un rat.
