print("Positive Affirmations Loaded")
print('GetNumGroupMembers: ', GetNumGroupMembers())

local function DebugEvent()
  local _, event, _, _, _, _, _, destGUID, destName = CombatLogGetCurrentEventInfo()
  print()
  print('[Event=', event,']')
  print('GetNumGroupMembers: ', GetNumGroupMembers())
  print('DEST NAME: ', destName, ' - ', UnitInParty(destName) or UnitInRaid(destName))
end

local function isPartyOrRaidMember(destName)
  return UnitInParty(destName) or UnitInRaid(destName)
end

local function IsPartyMemberDeath(event, destName)
  return event == "UNIT_DIED" and GetNumGroupMembers() > 0 and isPartyOrRaidMember(destName)
end

local function PlayAffirmation()
  local playing = PlaySoundFile("Interface\\AddOns\\_PositiveAffirmations\\sfx\\test_1.mp3", "SFX")
  print("Playing Affirmation - ", playing)
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