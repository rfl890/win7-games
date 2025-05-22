# win7-games

Built-in Windows 7 games, patched to work on Modern Windows.

[Download](https://github.com/rfl890/win7-games/releases/download/v1.0.0/win7-games-patched.zip)

# Instructions
Download a Windows 7 Ultimate x64 ISO, any language.
Follow these instructions to get it set up:
- Open with 7-Zip
- Go into "sources" folder
- Enter "install.wim"
- Enter "2"   

You can copy the files from here.

Now,

- Make a new, empty folder named "games"
- Copy over all folders except "More" and "Multiplayer" from C:\Program Files\Microsoft Games into the games folder. 
- Go into each game folder, delete the existing locale folder, and change the .exe file extension to .exe.original.
- Grab CardGames.dll from System32 and place it into this directory.

Then, on a Microsoft Windows computer with Lua installed, run patch.lua. If successful, the games in the folder should become patched and ready to run on newer systems.