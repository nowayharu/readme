--[[
	Logique client : surbrillance des rats pour les dératiseurs.
]]

local cfg = DRATS.Config

local visibleRats = {}
local nextScan = 0
local haloColor = Color(170, 255, 80)

hook.Add("PreDrawHalos", "DRATS_ExterminatorHalo", function()
	if not cfg.ExterminatorHalo then return end

	local ply = LocalPlayer()
	if not DRATS.IsExterminator(ply) then return end

	if CurTime() > nextScan then
		nextScan = CurTime() + 0.5
		visibleRats = {}
		local maxDist = cfg.HaloDistance * cfg.HaloDistance
		local eye = ply:EyePos()
		for _, rat in ipairs(ents.FindByClass(DRATS.RatClass)) do
			if eye:DistToSqr(rat:GetPos()) < maxDist then
				visibleRats[#visibleRats + 1] = rat
			end
		end
	end

	if #visibleRats > 0 then
		halo.Add(visibleRats, haloColor, 2, 2, 1, true, true)
	end
end)
