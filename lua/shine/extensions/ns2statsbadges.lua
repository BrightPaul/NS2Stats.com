--[[
    Shine Ns2Stats Badges
]]
Script.Load( "lua/shine/core/server/playerinfohub.lua" )

local Shine = Shine

local Plugin = {}

local Notify = Shared.Message

Plugin.Version = "1.5"

Plugin.HasConfig = true

Plugin.ConfigName = "Ns2StatsBadges.json"
Plugin.DefaultConfig =
{
    Flags = true,
    SteamBadges = true,
}
Plugin.CheckConfig = true

--fix for no badge showing up
local function AvoidEmptyBadge( Client, Badge, Row )
    if getClientBadgeEnum( Client, Row ) == kBadges.None then
       setClientBadgeEnum( Client, kBadges[ Badge ], Row ) 
    end
end

function Plugin:SetBadge( Client, Badge, Row )
    if not ( Badge or Client ) then return end    
    if not Row then Row = 3 end
    
    if not GiveBadge then
        Notify( "[ERROR]: The Ns2StatsBadge plugin does not work without the Badges+ Mod !" )
        self.Enabled = false
        return
    end
 
    local ClientId = Client:GetUserId()
    if ClientId <= 0 then return end
    
    local SetBadge = GiveBadge( ClientId, Badge, Row )
    if not SetBadge then return end
    
    -- send bagde to Clients
    Server.SendNetworkMessage( Client, "Badge", BuildBadgeMessage( -1, kBadges[ Badge ], Row ), true )
    AvoidEmptyBadge( Client, Badge, Row )
    
    -- give default badge (disabled)
    GiveBadge( ClientId, "disabled", Row )
    Server.SendNetworkMessage( Client, "Badge", BuildBadgeMessage( -1, kBadges[ "disabled" ], Row ), true )
    
    return true
end

function Plugin:OnReceiveSteamData( Client, SteamData )
    if not self.Config.SteamBadges then return end
    
    if SteamData.Badges.Normal and SteamData.Badges.Normal ~= 0 then
        self:SetBadge( Client, SteamData.Badges.Normal )
    end
        
    if SteamData.Badges.Foil and SteamData.Badges.Foil ~= 0 then
        self:SetBadge( Client, SteamData.Badges.Normal )
    end
end

function Plugin:OnReceiveNs2StatsData( Client, Ns2StatsData )
    if not self.Config.Flags then return end
    
    local Nationality = type( Ns2StatsData ) == "table" and tostring( Ns2StatsData.nationality ) or "UNO"    
    local SetBagde = self:SetBadge( Client, Nationality, 2 )
    
    if not SetBagde then
        Nationality = "UNO"
        self:SetBadge( Client, Nationality, 2 )
    end
end

Shine:RegisterExtension( "ns2statsbadges", Plugin )