OUTPK3 = starscream.pk3
EXECUTABLE = /Applications/Games/Sonic\ Robo\ Blast\ 2.app/Contents/MacOS/Sonic\ Robo\ Blast\ 2
DIRS = Lua Sprites Skins Sounds Soc 
PRIORITY_FILES = Skins/S_SKIN Lua/Def.lua

SKIN = skin starscream
MAP = map01
CHEATS = "godmode 1" + "devmode 1"

all: clean build launch

launch: 
	$(EXECUTABLE) -file $(OUTPK3) -warp $(MAP) + $(SKIN) + devmode 1
build:
	zip $(OUTPK3) $(PRIORITY_FILES)
	zip $(OUTPK3) -r $(DIRS)

host: build
	$(EXECUTABLE) -file $(OUTPK3) -warp $(MAP) -server + $(SKIN) + (CHEATS)
join: build
	$(EXECUTABLE) -file $(OUTPK3)  + $(SKIN) + color aether + connect localhost
clean:
	-rm $(OUTPK3)
