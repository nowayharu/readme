include("shared.lua")


local function holdsBuildTool()
	local wep = LocalPlayer():GetActiveWeapon()
	if not IsValid(wep) then return false end
	local class = wep:GetClass()
	return class == "gmod_tool" or class == "weapon_physgun"
end

function ENT:Draw()
	local admin = holdsBuildTool() and DRATS.IsAdmin(LocalPlayer())

	if DRATS.Config.NestVisible or admin then
		self:DrawModel()
	end

	if not admin then return end

	-- Infos pour les admins
	local pos = self:GetPos() + Vector(0, 0, 30)
	local yaw = EyeAngles().y

	cam.Start3D2D(pos, Angle(0, yaw - 90, 90), 0.1)
		draw.SimpleTextOutlined("Nid de rats", "DermaLarge", 0, 0, Color(170, 255, 80), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black)
		draw.SimpleTextOutlined(
			string.format("Rats : %d / %d  |  %ds  |  rayon %d", self:GetRatCount(), self:GetMaxRats(), self:GetSpawnInterval(), self:GetWanderRadius()),
			"DermaDefaultBold", 0, 30, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
	cam.End3D2D()

	render.DrawWireframeSphere(self:GetPos(), self:GetWanderRadius(), 12, 12, Color(170, 255, 80, 60), true)
end
