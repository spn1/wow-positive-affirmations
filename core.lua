-- /run print(PositiveAffirmations.roleCache["Wìts"])

PositiveAffirmations = {}

-- List of roles inn group
PositiveAffirmations.roleCache = {}

function PositiveAffirmations:LogRoleCache()
  for k, v in pairs(PositiveAffirmations.roleCache) do
    print(k..' is '..v)
  end
end

-- If the addon is currently playing an affirmation
PositiveAffirmations.isPlayingAffirmation = false

-- List of currently playing affirmation handles
PositiveAffirmations.currentPlayingHandleIds = {}

-- List of available affirmation sound files
PositiveAffirmations.affirmations = {
  "spuds_healer_1",
  "spuds_healer_2",
  "spuds_healer_3",
  "spuds_healer_4",
  "spuds_generic_2",
  "spuds_generic_1",
  "spuds_damage_1"
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
  return 'generic'
end

-- Selects a random affirmation file name from the affirmation table
function PositiveAffirmations:SelectRandomAffirmation()
  local index = math.random(1, #PositiveAffirmations.affirmations)
  return PositiveAffirmations.affirmations[index]
end

-- Do the affirmation playing
function PositiveAffirmations:PlayAffirmation(name)
  local roleOfDeadPlayer = PositiveAffirmations:GetPartyMemberRole(name)
  local affirmation = PositiveAffirmations:SelectRandomAffirmation()

  -- Stop all other affirmations (should only be one, but just incase multiple are playing)
  for i,handle in ipairs(PositiveAffirmations.currentPlayingHandleIds) do
    StopSound(handle)
    table.remove(PositiveAffirmations.currentPlayingHandleIds, i);
  end

  -- Playing the actual sound
  local _, handle = PlaySoundFile("Interface\\AddOns\\PositiveAffirmations\\sfx\\" .. affirmation .. ".mp3", "MASTER")

  table.insert(PositiveAffirmations.currentPlayingHandleIds, handle)
end

-- Spec Related
function PositiveAffirmations:LGIST_UpdateHandler(event, guid, unit, info)
  if info.spec_role then
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
    local _, event, _, _, _, _, _, _, destName = CombatLogGetCurrentEventInfo()
    local isPartyMemberDeath = PositiveAffirmations:IsPartyMemberDeath(event, destName)

    if (isPartyMemberDeath) then
      PositiveAffirmations:PlayAffirmation(destName)
    end
  end
end
)