print("Positive Affirmations Loaded")

local function IsPartyMemberDeath(event)
  return event == "PARTY_KILL"
end

local function PlayAffirmation()
  local playing = PlaySoundFile("Interface\\AddOns\\_PositiveAffirmations\\sfx\\test_1.mp3", "SFX")
  print("Playing: ", playing)
end

local EventFrame = CreateFrame("frame", "EventFrame")
EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

EventFrame:SetScript("OnEvent", function(self, event, ...)
  if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
    local _, subEvent = CombatLogGetCurrentEventInfo()
    local isPartyMemberDeath = IsPartyMemberDeath(subEvent)

    if (isPartyMemberDeath) then
      PlayAffirmation()
    end
  end
end
)