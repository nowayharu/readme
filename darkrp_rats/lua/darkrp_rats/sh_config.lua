--[[
	Configuration de l'addon Rats & Dératiseur.
	Modifiez les valeurs ci-dessous selon votre serveur.
]]

DRATS.Config = {
	------------------------------------------------------------------
	-- Métier
	------------------------------------------------------------------
	-- Crée automatiquement le métier "Dératiseur".
	-- Mettez false si vous préférez le déclarer vous-même dans
	-- darkrpmodification (voir README.md).
	CreateJob = true,
	JobName = "Dératiseur",
	JobCommand = "deratiseur",
	JobSalary = 45,
	JobMax = 3,
	JobCategory = "Citizens",
	JobModels = {
		"models/player/Group03/male_02.mdl",
		"models/player/Group03/male_04.mdl",
		"models/player/Group03/female_02.mdl",
	},

	-- Noms de métiers autorisés à tuer les rats (en plus de JobName).
	ExtraExterminatorJobs = {
		-- ["Agent sanitaire"] = true,
	},

	------------------------------------------------------------------
	-- Rats
	------------------------------------------------------------------
	-- Aucun modèle de rat n'existe dans le jeu de base : remplacez-le par
	-- un modèle du Workshop si vous en avez un (pensez au resource.AddWorkshop).
	RatModel = "models/headcrabclassic.mdl",
	RatScale = 0.45,
	RatRunSequence = "run1",
	RatIdleSequence = "idle01",

	RatHealth = 20,
	RatSpeedMin = 60,       -- unités / seconde
	RatSpeedMax = 110,
	RatFleeSpeed = 200,     -- vitesse quand il est blessé
	RatLifetime = 0,        -- secondes avant disparition (0 = jamais)

	-- Seul le dératiseur peut tuer les rats ?
	OnlyExterminatorCanKill = true,

	-- Récompense pour chaque rat tué
	KillReward = 75,

	-- Nombre max de rats sur toute la map
	GlobalMaxRats = 60,

	------------------------------------------------------------------
	-- Nids (points d'apparition placés au toolgun)
	------------------------------------------------------------------
	NestModel = "models/props_junk/garbage_bag001a.mdl",
	-- false = le nid est invisible pour les joueurs (visible seulement
	-- avec le toolgun / physgun en main).
	NestVisible = true,

	-- Valeurs par défaut du toolgun
	DefaultMaxRats = 5,
	DefaultInterval = 60,   -- secondes entre deux apparitions
	DefaultRadius = 300,    -- rayon de déplacement des rats

	-- Les rats n'apparaissent que si une porte proche du nid est possédée
	-- (= la propriété est achetée par un joueur).
	RequireOwnedProperty = false,
	PropertyDoorRadius = 600,

	-- Les rats n'apparaissent que si au moins un dératiseur est connecté.
	RequireExterminatorOnline = true,

	-- Prévenir le propriétaire de la propriété et les dératiseurs.
	NotifyOwner = true,
	NotifyExterminators = true,
	NotifyCooldown = 120,

	-- Sauvegarde automatique des nids par map (data/darkrp_rats/<map>.json)
	SaveNests = true,

	------------------------------------------------------------------
	-- Pulvérisateur de raticide
	------------------------------------------------------------------
	SprayDamage = 7,
	SprayRange = 180,
	SprayDelay = 0.12,
	SprayConeDot = 0.85,    -- 1 = très précis, 0.7 = large

	-- Les dératiseurs voient les rats proches en surbrillance
	ExterminatorHalo = true,
	HaloDistance = 1200,

	------------------------------------------------------------------
	-- Permissions
	------------------------------------------------------------------
	-- Rangs ULX/SAM/etc. autorisés à utiliser le toolgun des nids.
	-- Les superadmins sont toujours autorisés.
	AdminGroups = {
		["superadmin"] = true,
		["admin"] = true,
	},

	------------------------------------------------------------------
	-- Messages
	------------------------------------------------------------------
	Lang = {
		RatKilled = "Rat éliminé ! +%s",
		NotExterminator = "Seul un dératiseur peut s'occuper des rats !",
		OwnerWarning = "Des rats ont envahi votre propriété ! Appelez un dératiseur.",
		ExterminatorWarning = "Une infestation de rats a été signalée !",
		NoPermission = "Vous n'avez pas la permission de gérer les nids de rats.",
		NestPlaced = "Nid de rats placé.",
		NestRemoved = "Nid de rats supprimé.",
		NestUpdated = "Paramètres du nid mis à jour.",
	},
}
