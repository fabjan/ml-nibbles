basis = $(wildcard *.mlb)
signatures = $(wildcard src/*.sig)
sources = $(wildcard src/*.sml)
assets = $(wildcard assets/*)

ml-nibbles.love: main.lua $(assets)
	zip -9 -r ml-nibbles.love main.lua assets

main.lua: $(basis) $(signatures) $(sources)
	lunarml compile --luajit main.mlb

.PHONY: clean
clean:
	rm -f ml-nibbles.love main.lua
