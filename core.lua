-- /run print(PositiveAffirmations.roleCache["Wìts"])

PositiveAffirmations = {}

-- List of roles inn group
PositiveAffirmations.roleCache = {}

function PositiveAffirmations:Debug()
  for k, v in pairs(PositiveAffirmations.roleCache) do
    print(k..' is '..v)
  end
end

-- /run PositiveAffirmations:DebugPlay('damage', 'healer')
function PositiveAffirmations:DebugPlay(death, role)
  PositiveAffirmations.roleCache = { damage = 'damage', healer = 'healer', tank = 'tank', [UnitName("player")] = role}
  PositiveAffirmations:PlayAffirmation(death, role)
  PositiveAffirmations.lgist:Rescan()
end

-- If the addon is currently playing an affirmation
PositiveAffirmations.isPlayingAffirmation = false

-- List of currently playing affirmation handles
PositiveAffirmations.currentPlayingHandleIds = {}

-- List of available affirmation sound files
PositiveAffirmations.affirmationFilenames = {
  spuds = {
    generic = {
      "spuds_generic_1",
      "spuds_generic_2",
      "spuds_generic_3",
      "spuds_generic_4",
      "spuds_generic_5",
      "spuds_generic_6",
    },
    ashealer = {
      generic = {
        "spuds_generic_as_healer_2",
        "spuds_generic_as_healer_3",
        "spuds_generic_as_healer_4",
        "spuds_generic_as_healer_5",
      }
    },
    astank = {
      generic = {
        "spuds_generic_as_tank_1",
        "spuds_generic_as_tank_2"
      }
    },
    asdamage = {
      generic = {
        "spuds_damage_as_damage_1"
      }
    }
  }
}

-- Check if a combat log event destination name (target of death) is in the raid or party
function PositiveAffirmations:IsPartyOrRaidMember(destName)
  return UnitInParty(destName) or UnitInRaid(destName)
end

-- Check if a particular death event is for a member of the party or raid
function PositiveAffirmations:IsPartyMemberDeath(event, destName)
  return event == "UNIT_DIED" and GetNumGroupMembers() > 0 and PositiveAffirmations:IsPartyOrRaidMember(destName)
end

-- Check what role the player that died is
function PositiveAffirmations:GetPartyMemberRole(name)
  local role = PositiveAffirmations.roleCache[name]
  if (role) then
    return role
  end
  return nil
end

function PositiveAffirmations:PlayGenericAffirmation() return math.random(1, 2) % 2 == 0 end

-- Selects a random affirmation file name from the affirmation table
function PositiveAffirmations:SelectRandomAffirmation(roleOfDeadPlayer, roleOfPlayer)
-- Coin flip to see if the sfx is generic or role-specific

  if (PositiveAffirmations:PlayGenericAffirmation()) then
    local index = math.random(1, #PositiveAffirmations.affirmationFilenames['spuds']['generic'])
    return PositiveAffirmations.affirmationFilenames['spuds']['generic'][index]
  else
    if (PositiveAffirmations:PlayGenericAffirmation()) then
      local index = math.random(1, #PositiveAffirmations.affirmationFilenames['spuds']['as'..roleOfPlayer]['generic'])
      return PositiveAffirmations.affirmationFilenames['spuds']['as'..roleOfPlayer]['generic'][index]
    end
    -- else
    --   print('Getting '..roleOfPlayer..' affirmation for '..roleOfDeadPlayer..' death')
    --   local index = math.random(1, #PositiveAffirmations.affirmationFilenames['spuds']['as'..roleOfPlayer][roleOfDeadPlayer])
    --   return PositiveAffirmations.affirmationFilenames['spuds']['as'..roleOfPlayer][roleOfDeadPlayer][index]
    -- end

  end
end

-- Do the affirmation playing
function PositiveAffirmations:PlayAffirmation(guid, name)
  local roleOfPlayer = PositiveAffirmations:GetPartyMemberRole(UnitName("player"))
  local roleOfDeadPlayer = PositiveAffirmations:GetPartyMemberRole(name)

  if(roleOfDeadPlayer and roleOfPlayer) then
    local affirmation = PositiveAffirmations:SelectRandomAffirmation(roleOfDeadPlayer, roleOfPlayer)

    if (affirmation) then
      -- Stop all other affirmations (should only be one, but just incase multiple are playing)
      for i,handle in ipairs(PositiveAffirmations.currentPlayingHandleIds) do
        StopSound(handle)
        table.remove(PositiveAffirmations.currentPlayingHandleIds, i);
      end

      -- Playing the actual sound
      local _, handle = PlaySoundFile("Interface\\AddOns\\PositiveAffirmations\\sfx\\spuds\\" .. affirmation .. ".mp3", "MASTER")
      table.insert(PositiveAffirmations.currentPlayingHandleIds, handle)
    end

  end
end

-- Spec Related
function PositiveAffirmations:LGIST_UpdateHandler(event, guid, unit, info)
  if info.spec_role_detailed then
    -- Get name for guid
    local name = UnitName(unit)
    if (PositiveAffirmations:IsPartyOrRaidMember(name)) then
      -- Change melee or ranged to be damage
      local role = info.spec_role_detailed
      if (role == 'ranged' or role == 'melee') then role = 'damage' end

      PositiveAffirmations.roleCache[name] = role
    end
  end
end

function PositiveAffirmations:LGIST_RemoveHandler(event, guid)
  local name = UnitName(guid)
  if (name and PositiveAffirmations.roleCache[name]) then PositiveAffirmations.roleCache[name] = nil end
end

PositiveAffirmations.lgist = LibStub("LibGroupInSpecT-1.1");
PositiveAffirmations.lgist.RegisterCallback (PositiveAffirmations, "GroupInSpecT_Update", "LGIST_UpdateHandler")
PositiveAffirmations.lgist.RegisterCallback (PositiveAffirmations, "GroupInSpecT_Remove", "LGIST_RemoveHandler")

-- Set up addon frame
PositiveAffirmations.EventFrame = CreateFrame("frame", "EventFrame")
PositiveAffirmations.EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

-- Set up frame event handler
PositiveAffirmations.EventFrame:SetScript("OnEvent", function(self, event, ...)
  if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
    local _, event, _, guid, _, _, _, _, destName = CombatLogGetCurrentEventInfo()
    local isPartyMemberDeath = PositiveAffirmations:IsPartyMemberDeath(event, destName)

    if (isPartyMemberDeath) then
      PositiveAffirmations:PlayAffirmation(guid, destName)
    end
  end
end
)