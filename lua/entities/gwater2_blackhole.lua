AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Category     = "GWater2"
ENT.PrintName    = "Blackhole"
ENT.Author       = "Meetric"
ENT.Purpose      = ""
ENT.Instructions = ""
ENT.Spawnable    = true
ENT.Editable	 = true

function ENT:Initialize()
	if CLIENT then return end
	self:SetModel("models/hunter/misc/sphere075x075.mdl")
	self:SetMaterial("lights/white")
	
	self:SetColor(Color(0, 0, 0))
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
end

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "Radius", {KeyName = "Radius", Edit = {type = "Float", order = 0, min = 0, max = 2000}})
	self:NetworkVar("Float", 1, "Strength", {KeyName = "Strength", Edit = {type = "Float", order = 1, min = -200, max = 200}})
	self:NetworkVar("Bool", 0, "Linear", {KeyName = "Linear", Edit = {type = "Bool", order = 2}})
	self:NetworkVar("Int", 0, "Mode", {KeyName = "Force Mode", Edit = {type = "Int", order = 3, min = 0, max = 2}})

	if SERVER then return end

	self.PARTICLE_EMITTER = ParticleEmitter(self:GetPos(), false)
	hook.Add("gwater2_posttick", self, function()
		gwater2.solver:AddForceField(self:GetPos(), self:GetRadius(), -self:GetStrength(), self:GetMode(), self:GetLinear())
	end)
end

if SERVER then
	function ENT:SpawnFunction(ply, tr, class)
		if not tr.Hit then return end
		local ent = ents.Create(class)
		ent:SetPos(tr.HitPos + tr.HitNormal * 50)
		ent:Spawn()
		ent:Activate()

		ent:SetRadius(1000)
		ent:SetStrength(50)
		ent:SetMode(0)
		ent:SetLinear(1)

		return ent
	end
elseif CLIENT then
	function ENT:Think()
		-- VERY old code for blackhole visuals, reused from a script I made 3 years ago
		if !self.PARTICLE_EMITTER then return end
			
		local part = self.PARTICLE_EMITTER:Add("particle/warp_ripple", self:GetPos())
		part:SetVelocity(Vector())
		part:SetGravity(Vector())
		part:SetDieTime(FrameTime() * 10)
		part:SetStartSize(50)
		part:SetEndSize(50)
		part:SetLighting(false)

		-- particle/warp1_warp
		local part 
		if self:GetStrength() >= 0 then
			part = self.PARTICLE_EMITTER:Add("gwater2/blackhole", self:GetPos())
			self:SetColor(Color(0, 0, 0, 255))
		else 
			part = self.PARTICLE_EMITTER:Add("gwater2/whitehole", self:GetPos())
			self:SetColor(color_white)
		end
		part:SetVelocity(Vector())
		part:SetGravity(Vector())
		part:SetDieTime(FrameTime() * 20)
		part:SetStartSize(25 + (math.sin(CurTime() * 2) * 3))
		part:SetEndSize(22)
		self:SetNextClientThink(CurTime() + 0.001)
		self:RemoveAllDecals()
		return true
	end

	function ENT:OnRemove()
		hook.Remove("gwater2_posttick", self)
		if self.PARTICLE_EMITTER then 
			self.PARTICLE_EMITTER:Finish()
		end
	end
end