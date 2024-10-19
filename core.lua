PositiveAffirmations = {}

-- If the addon is currently playing an affirmation
PositiveAffirmations.isPlayingAffirmation = false
-- List of currently playing affirmation handles
PositiveAffirmations.currentPlayingHandleIds = {}
PositiveAffirmations.affirmations = {
  "spuds_healer_1",
  "spuds_healer_2",
  "spuds_healer_3",
  "spuds_healer_4",
  "spuds_generic_2",
  "spuds_generic_1",
  "spuds_dps_1"
}

-- Get the player's role
function PositiveAffirmations:PlayerRole()
  return 'HEALER'
end

-- Get the role of the player that died
function PositiveAffirmations:PartyMemberRole(destName)
  return 'DAMAGE'
end

-- Check if a combat log event destination name (target of death) is in the raid or party
function PositiveAffirmations:IsPartyOrRaidMember(destName)
  return UnitInParty(destName) or UnitInRaid(destName)
end

-- Check if a particular death event is for a member of the party or raid
function PositiveAffirmations:IsPartyMemberDeath(event, destName)
  return event == "UNIT_DIED" and self.GetNumGroupMembers() > 0 and self.IsPartyOrRaidMember(destName)
end

-- Selects a random affirmation file name from the affirmation table
function PositiveAffirmations:SelectRandomAffirmation()
  local index = math.random(1, #self.affirmations)
  return self.affirmations[index]
end


-- Do the affirmation playing
function PositiveAffirmations:PlayAffirmation()
  local affirmation = PositiveAffirmations:SelectRandomAffirmation()

  -- Stop all other affirmations (should only be one, but just incase multiple are playing)
  for i,handle in ipairs(self.currentPlayingHandleIds) do
    StopSound(handle)
    table.remove(self.currentPlayingHandleIds, i);
  end

  -- Playing the actual sound
  local _, handle = PlaySoundFile("Interface\\AddOns\\PositiveAffirmations\\sfx\\" .. affirmation .. ".mp3", "MASTER")

  table.insert(self.currentPlayingHandleIds, handle)
end

-- Set up addon frame
PositiveAffirmations.EventFrame = CreateFrame("frame", "EventFrame")
PositiveAffirmations.EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

-- Set up frame event handler
PositiveAffirmations.EventFrame:SetScript("OnEvent", function(self, event, ...)
  if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
    local _, event, _, _, _, _, _, _, destName = CombatLogGetCurrentEventInfo()
    local isPartyMemberDeath = self.IsPartyMemberDeath(event, destName)

    if (isPartyMemberDeath) then
      self.PlayAffirmation()
    end
  end
end
)