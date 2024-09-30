local isPlayingAffirmation = false

local function isPartyOrRaidMember(destName)
  return UnitInParty(destName) or UnitInRaid(destName)
end

local function IsPartyMemberDeath(event, destName)
  return event == "UNIT_DIED" and GetNumGroupMembers() > 0 and isPartyOrRaidMember(destName)
end

local function PlayAffirmation()
  local playing = PlaySoundFile("Interface\\AddOns\\PositiveAffirmations\\sfx\\test_1.mp3", "MASTER")
end

local EventFrame = CreateFrame("frame", "EventFrame")
EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

EventFrame:SetScript("OnEvent", function(self, event, ...)
  if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
    local _, event, _, _, _, _, _, _, destName = CombatLogGetCurrentEventInfo()
    local isPartyMemberDeath = IsPartyMemberDeath(event, destName)

    if (isPartyMemberDeath) then
      PlayAffirmation()
    end
  end
end
)