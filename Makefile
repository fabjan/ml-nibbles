basis = $(wildcard *.mlb)
signatures = $(wildcard *.sig)
sources = $(wildcard *.sml *.mlb *.sig)

main.lua: $(basis) $(signatures) $(sources)
	lunarml compile --luajit main.mlb
