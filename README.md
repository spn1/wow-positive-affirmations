# Positive Affirmations for WoW Players

World of Warcraft AddOn that will provide positive affirmations when things dont go as planned during dungeons and raids.

For example, when you are a healer and a player dies under your watch, the AddOn will tell you that it is not your fault, that they took avoidable damage, and that you are doing a great job.

## Installation

There are a few options for installation:

- Install using [CurseForge](https://www.curseforge.com/wow/search?page=1&pageSize=20&sortBy=relevancy&search=PositiveAffirmations) (search for PositiveAffirmations)
- Download this repository and copy the folder into your WoW AddOn Directory. The folder must be called `PositiveAffirmations`

## Development

- Download this repository somewhere on your device
- Add a symlink folder in your WoW AddOn directory that links to the downloaded folder:
  **Powershell**
  ```powershell
  New-Item -ItemType SymbolicLink -Path "C:\Games\World of Warcraft\_retail_\Interface\AddOns\PositiveAffirmations" -Value "C:\<path-to-downloaded-repo>\wow-positive-affirmations"
  ```
  **Bash**
  ```powershell
  ln -s "/path-to-downloaded-repo/wow-positive-affirmations" "/<wow-installation-folder>/_retail_/Interface/AddOns/PositiveAffirmations"
  ```
- Load up WoW and enable the AddOn in your AddOn settings

After making changes, you need type `/reload` in the WoW chat window to see new changes.
