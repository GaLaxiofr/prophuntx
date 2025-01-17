AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName 	= "Prop Decoy Entity"
ENT.Author 		= "Wolvindra-Vinzuerio"
ENT.Information	= "A fake prop entity, which only have 10 damage"
ENT.Category 	= ""
ENT.Editable 	= true
ENT.Spawnable 	= true
ENT.AdminOnly 	= false
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
	if SERVER then
		self.Entity:SetModel("models/player/kleiner.mdl")
        self.Entity:PhysicsInit(SOLID_BBOX)
        self.Entity:SetSolid(SOLID_BBOX)
		self.Entity:SetMoveType(MOVETYPE_NONE)
        self.Entity.owner = NULL
		self.health = GetConVar( "ph_decoy_health" ):GetInt() or 10
	end
end

if CLIENT then
	function ENT:Draw()
		self.Entity:DrawModel()
	end
end

ENT.LaughsSound = {
	-- SoundDuration() is broken, we have to put this temporarily.
	-- Todo: use PHX:SoundDuration() instead.
	{ "vo/ravenholm/madlaugh04.wav", 2.5 },
	{ "misc/fakeprop_laugh1.mp3", 11.5 },
	{ "misc/fakeprop_laugh2.mp3", 10 },
    { "misc/fakeprop_laugh3.mp3", 1.4 }
}


if SERVER then	

    function ENT:TakeModelFromMap()
        local physProp = ents.FindByClass("prop_physics*")
        local RandomProp = physProp[math.random(1, #physProp)]
        
        self:SetModel( RandomProp:GetModel() )
        self:SetCollisionBounds( RandomProp:GetCollisionBounds() )
    end

    function ENT:ChangeModel( strEnt, pos )
        self:SetModel( strEnt:GetModel() )
        self:SetCollisionBounds( strEnt:GetCollisionBounds() )
    end
    
    function ENT:TheOwner( ent )
        self.owner = ent
    end
	
	function ENT:OnTakeDamage(dmg)
		local attacker = dmg:GetAttacker()
		local inflictor = dmg:GetInflictor()
		local owner = self:GetOwner()

		-- Health
		if GAMEMODE:InRound() and attacker:IsPlayer() and attacker:Team() == TEAM_HUNTERS and dmg:GetDamage() > 0 then
			self.health = self.health - dmg:GetDamage()
			
			if self.health <= 0 then
				hook.Call("PH_OnFakePropKilled", nil, attacker)
				
				-- Steal attacker's frags and give the frags to the owner of this prop!
                if IsValid(owner) or owner ~= NULL then
                    attacker:SetFrags( attacker:Frags() - 1 )
                    owner:AddFrags( 1 )
                    owner.propdecoy = nil
                    owner:PHXChatInfo( "GOOD", "DECOY_FRAGS_RECEIVED", attacker:Nick() )
                end
				
				local targ = ents.Create("info_target")
				targ:SetPos(self:GetPos())
				targ:SetAngles(self:GetAngles())
				targ:Spawn()
				
				local randLaugh = self.LaughsSound[math.random(1,#self.LaughsSound)]
				timer.Simple(0, function()
					targ:EmitSound( randLaugh[1] , 85, math.random(80, 120) ) 
				end)
				
				SafeRemoveEntityDelayed(targ, randLaugh[2])
				
				net.Start("PHX.DeathNoticeDecoy")
                    net.WriteEntity( attacker )
                    net.WriteEntity( inflictor )
                net.Broadcast()
				self:Remove()
			end
		end
	end
    
    -- Remove this shitty props on Round End
    hook.Add("PH_RoundEndResult", "PHX.DestroyDecoys", function(r,rt)
        for _,v in pairs(player.GetAll()) do
            if IsValid(v.propdecoy) then
                v.propdecoy:SetOwner(NULL)
                v.propdecoy = nil
            end
        end
        
        timer.Simple(0.1, function()
            for _,decoys in pairs(ents.FindByClass("ph_fake_prop")) do
                decoys:Remove()
            end
        end)
    end)
	
end